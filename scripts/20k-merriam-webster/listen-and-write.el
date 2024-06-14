:; exec emacs --batch -l "$0" -f main -- "$@"
;; -*- lexical-binding: t -*-

(package-initialize)

(require 'dom)
(require 'nadvice)
(require 'wordreference)
(require 'cl-lib)

(setq args-list (cdr command-line-args-left))
(setq range (plist-get args-list "-r" #'equal))
(setq cnt (plist-get args-list "-c" #'equal))
(setq study-mode (when (plist-get args-list "-s" #'equal) t))
(setq error-records nil)

;; shell color
;; https://azrael.digipen.edu/~mmead/www/mg/ansicolors/index.html
;; https://linuxhandbook.com/change-echo-output-color/
(setq shell-color-red "\033[0;31m"
      shell-color-green "\033[0;32m"
      shell-color-yellow "\033[1;33m"
      shell-color-purple "\033[0;35m"
      shell-color-cyan "\033[0;36m"
      shell-color-no-color "\033[0m")

(defun show-help-info (status)
  (message "Usage: %s -c COUNT [-r START,END] [-s STUDY-MODE]" (nth 2 command-line-args))
  (kill-emacs status))

(defun get-words (filename start end)
  (let ((words
         (with-temp-buffer
           (insert-file-contents-literally filename)
           (goto-char (point-min))
           (let ((p1
                  (progn
                    (forward-line (- start 1))
                    (point)))
                 (p2
                  (progn
                    (forward-line (+ 1 (- end start)))
                    (point))))
             (mapcar
              (lambda (line)
                (string-split line ":" t)
                ;; (car (string-split line ":" t))
                )
              (string-split
               (buffer-substring-no-properties p1 p2)
               "\n" t))))))
    words))

(defun play-audio (word)
  ;; (start-process "mpv" nil "mpv"
  ;;                "--audio-display=no"
  ;;                (format "./word-audios/%s.mp3" word))

  (call-process-shell-command
   (format "mpv --audio-display=no %s/%s.mp3"
           "./word-audios"
           word)))

(defun record-error (correct-answer your-input)
  (let ((input-records (alist-get correct-answer error-records nil nil #'equal)))
    (unless input-records
      (push (cons correct-answer nil) error-records))
    (unless (member your-input input-records)
      (setf
       (alist-get correct-answer error-records nil nil #'equal)
       (cons your-input input-records)))))


;; show statistics at exit
(defun quit-handler ()
  (interactive)
  (when (> (length error-records) 0)
    (message "%s\n\n============================== STATISTICS: ==============================\n%s"
             shell-color-yellow
             (string-join
              (mapcar #'(lambda (record)
                          (let* ((inputs (string-join (cdr record) ",")))
                            (format "The answer:\n%s\n\nYour wrong answers:\n%s" (car record) inputs))
                          )
                      error-records)
              "\n==============================\n"))))

;; get translations from wordreference.com
;;; ============================== based on wordreference.el ==============================
(defun retrieve-translation (word &optional source target collins)
  "Query wordreference.com for WORD, and parse the HTML response.
Optionally specify SOURCE and TARGET languages.
COLLINS means we are fetching collins dictionary data instead.

Return nil if the WORD not found."
  (let* ((url (wordreference--construct-url source target word collins))
         (url-user-agent wordreference-user-agent)
         (rsp (url-retrieve-synchronously url)))
    (with-temp-buffer
      (wordreference--parse-sync rsp word source target (current-buffer) collins))))

(defun wordreference--parse-sync (rsp word source target buffer &optional collins)
  "Parse query response for WORD from SOURCE to TARGET language.
Callback for `wordreference--retrieve-parse-html'.
BUFFER is the buffer that was current when we invoked the wordreference command.
COLLINS means we are fetching collins dictionary data instead."
  (let ((parsed (with-current-buffer rsp
                  (goto-char (point-min))
                  (libxml-parse-html-region
                   (search-forward "\n\n") (point-max)))))
    (if collins
        ;; (progn (setq wr-parsed-coll parsed)
        (wordreference-print-collins-dict parsed)
      (wordreference-print-translation-buffer word parsed source target buffer))))

(defun my-wordreference-print-translation-buffer (word html-parsed &optional source target buffer)
  "Get translation results.
WORD is the search query, HTML-PARSED is what our query returned.
SOURCE and TARGET are languages.
BUFFER is the buffer that was current when we invoked the wordreference command."
  (catch 'quit
    (with-current-buffer (get-buffer-create "*wordreference*")
      (let* ((inhibit-read-only t)
             (tables (wordreference--get-tables html-parsed))
             (word-tables (wordreference--get-word-tables tables))
             (pr-table (car word-tables))
             (pr-trs (wordreference--get-trs pr-table))
             (pr-trs-results-list (wordreference-collect-trs-results-list pr-trs))
             (post-article (dom-by-id html-parsed "postArticle"))
             (other-dicts (dom-by-id html-parsed "otherDicts"))
             (forum-heading (dom-by-id post-article "threadsHeader"))
             (forum-heading-string (dom-texts forum-heading))
             (forum-links (dom-children (dom-by-id post-article "lista_link")))
             (forum-links-propertized
              (wordreference-process-forum-links forum-links))
             (source-lang (or (plist-get (car pr-trs-results-list) :source)
                              source
                              wordreference-source-lang))
             (target-lang (or (plist-get (car pr-trs-results-list) :target)
                              target
                              wordreference-target-lang)))
        (erase-buffer)
        ;; print principle, supplementary, particule verbs, and compound tables:
        (if word-tables
            (wordreference-print-tables word-tables)
          ;; no result
          (throw 'quit nil))
        (wordreference--print-other-dicts other-dicts)
        ;; print list of term also found in these entries
        (wordreference-print-also-found-entries html-parsed)
        ;; print forums
        (wordreference-print-heading forum-heading-string)
        (if (dom-by-class forum-links "noThreads")
            ;; no propertize if no threads:
            (insert "\n\n" (dom-texts (car forum-links)))
          (wordreference-print-forum-links forum-links-propertized))
        ;; collins dictionary:
        (wordreference--retrieve-parse-html word source-lang target-lang :collins)
        (buffer-string)))))

(advice-add 'wordreference-print-translation-buffer :override #'my-wordreference-print-translation-buffer)

;;; ============================================================
(defun display-trans-info (word)
  (let ((trans-from-local (format "./word-translations/%s" word)))
    (if (file-exists-p trans-from-local)
        (with-temp-buffer
          (insert-file-contents-literally trans-from-local)
          (message "%s%s%s" shell-color-cyan (buffer-string) shell-color-no-color))
      (let ((trans (retrieve-translation word "en" "zh")))
        (when trans
          (write-region trans nil trans-from-local)
          (message "%s%s%s" shell-color-cyan trans shell-color-no-color))))))

(defun main ()
  ;; display summary
  (add-hook 'kill-emacs-hook #'quit-handler)

  ;; (unless (and cnt)
  ;;   (show-help-info 22))

  (unless (and
           (if range (string-match "^[[:digit:]]+,[[:digit:]]+$" range) t)
           ;; (string-match "^[[:digit:]]+$" cnt)
           )
    (show-help-info 22))

  (when (and cnt (null (string-match "^[[:digit:]]+$" cnt)))
    (show-help-info 22))

  (let* ((total-words (with-temp-buffer
                        (insert-file-contents-literally "progress.yaml")
                        (count-lines (point-min) (point-max))))
         (start-end-pair (mapcar #'string-to-number
                                 (string-split
                                  (or range (format
                                             "%d,%d" 1
                                             total-words))
                                  "," t)))
         (start (car start-end-pair))
         (end (cadr start-end-pair))
         (count (if cnt (string-to-number cnt) (- end start)))
         (i 0)
         full-words
         words)

    (unless (> end start)
      (message "END is REQUIRED to be larger than START")
      (kill-emacs 22))

    (unless (> start 0)
      (message "START is REQUIRED to be larger than 0")
      (kill-emacs 22))

    (unless (> count 0)
      (message "COUNT is REQUIRED to be larger than 0")
      (kill-emacs 22))

    (setq full-words (get-words "progress.yaml" 1 total-words))

    (catch 'quit
      (while (< i count)
        (message (format "\n============================== Word %d ==============================" (1+ i)))
        (let* ((order (if study-mode
                          (+ (- start 1) (% i (- end start)))
                        (+ (- start 1) (random (- end start)))))
               (word-and-syllable-pron (nth
                                        order
                                        full-words))
               (guess (string-trim (car word-and-syllable-pron)))
               (syllable-pron (string-split (cadr word-and-syllable-pron) ";"))
               ;; (word-translation (format "./word-translations/%s" guess))
               input)

          (when study-mode
            (message "WORD: %s, ORDER: %d, SYLLABLES: %s, PRONOUNCE: %s\n"
                     guess
                     (1+ order)
                     (string-trim (car syllable-pron))
                     (string-trim (cadr syllable-pron))))

          (play-audio guess)

          (catch 'break
            (while (string-match
                    "\\(\\|d|D\\)?"
                    (setq input
                          (if study-mode
                            (string-trim
                             (read-string (format
                                           "%sENTER%s to replay,\n%sQ|q%s to quit,\n%sD|d%s to play another audio file,\nT|t to show translations,\nthe word you listened: "
                                           shell-color-cyan shell-color-no-color
                                           shell-color-green shell-color-no-color
                                           shell-color-purple shell-color-no-color)))
                            (string-trim
                             (read-string (format
                                           "%sENTER%s to replay,\n%sQ|q%s to quit,\n%sD|d%s to play another audio file,\nthe word you listened: "
                                           shell-color-cyan shell-color-no-color
                                           shell-color-green shell-color-no-color
                                           shell-color-purple shell-color-no-color))))))
              ;; play-audio
              (cond
               ((zerop (length input)) (play-audio guess))
               ((string-equal "t" (downcase input))
                (if study-mode
                    (display-trans-info guess)
                  (message "\nCheating is not allowed!!!\n")))
               ((string-equal "d" (downcase input))
                (let ((word-to-compare (string-trim (read-string "Input the audio of word to play: "))))
                  (if (file-exists-p (format "./word-audios/%s.mp3" word-to-compare))
                      (progn
                        (play-audio word-to-compare)
                        (let* ((order-of-word-to-compare
                                (cl-position word-to-compare full-words
                                             :test #'(lambda (a b)
                                                       (string-equal a (car b)))))
                               (word-info (assoc word-to-compare full-words))
                               (word-syllable-pron (string-split (cadr word-info) ";" t)))
                          (message "%sOrder: %d, SYLLABLES: %s, PRONOUNCE: %s"
                                   shell-color-cyan
                                   (1+ order-of-word-to-compare)
                                   (string-trim (car word-syllable-pron))
                                   (string-trim (cadr word-syllable-pron)))
                          (display-trans-info word-to-compare)))
                    (message "No audio file of %s" word-to-compare))))
               (t (throw 'break nil)))))

          (cond
           ((string-equal "q" (downcase input)) (throw 'quit (message "\n")))
           ((string-equal input guess) nil)
           (t
            (record-error guess input)
            (message "the answer is %s%s(%d)%s"
                     shell-color-red guess (1+ order) shell-color-no-color))))

        ;; next word
        (setq i (+ i 1))))))

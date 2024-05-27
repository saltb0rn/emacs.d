:; exec emacs --batch -l "$0" -f main -- "$@"
;; -*- lexical-binding: t -*-

(package-initialize)

(require 'dom)

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
        (let* ((word-and-syllable-pron (nth
                                        (if study-mode
                                            (+ (- start 1) (% i (- end start)))
                                          (+ (- start 1) (random end)))
                                        full-words))
               (guess (string-trim (car word-and-syllable-pron)))
               (syllable-pron (string-split (cadr word-and-syllable-pron) ";"))
               input)

          (when study-mode
            (message "WORD: %s, SYLLABLES: %s, PRONOUNCE: %s\n"
                     guess
                     (string-trim (car syllable-pron))
                     (string-trim (cadr syllable-pron))))

          (play-audio guess)

          (catch 'break
            (while (string-match
                    "\\(\\|d|D\\)?"
                    (setq input
                          (string-trim
                           (read-string (format
                                         "%sENTER%s to replay,\n%sQ|q%s to quit,\n%sD|d%s to play another audio file,\nthe word you listened: "
                                         shell-color-cyan shell-color-no-color
                                         shell-color-green shell-color-no-color
                                         shell-color-purple shell-color-no-color)))))
              ;; play-audio
              (cond
               ((zerop (length input)) (play-audio guess))
               ((string-equal "d" (downcase input))
                (let ((word-to-compare (string-trim (read-string "Input the audio of word to play: "))))
                  (if (file-exists-p (format "./word-audios/%s.mp3" word-to-compare))
                      (progn
                        (play-audio word-to-compare)
                        (when study-mode
                          (let* ((word-info (assoc word-to-compare full-words))
                                 (word-syllable-pron (string-split (cadr word-info) ";" t)))
                            (message "%sSYLLABLES: %s, PRONOUNCE: %s"
                                     shell-color-cyan
                                     (string-trim (car word-syllable-pron))
                                     (string-trim (cadr word-syllable-pron))))))
                    (message "No audio file of %s" word-to-compare))))
               (t (throw 'break nil)))))

          (cond
           ((string-equal "q" (downcase input)) (throw 'quit (message "\n")))
           ((string-equal input guess) nil)
           (t
            (record-error guess input)
            (message "the answer is %s%s%s"
                     shell-color-red guess shell-color-no-color))))

        ;; next word
        (setq i (+ i 1))))))

:;exec emacs --batch -l "$0" -f main -- "$@"
;; -*- lexical-binding: t -*-

;; disposable script

(package-initialize)

(require 'cl-lib)
(require 'dom)
(require 'subr-x)
(require 'url)
(require 'dash)
(require 'yaml)

(setq args-list (cdr command-line-args-left))
(setq word-list (plist-get args-list "-l" #'equal))
(setq output-directory (plist-get args-list "-o" #'equal))
(setq retry-list nil)

(cl-defstruct response headers body)

(defun url-open (url &rest args)
  "Return the response by requesting the url"
  (let ((url-request-extra-headers (plist-get args :headers))
        (url-request-method (plist-get args :methods))
        (url-request-data (plist-get args :data)))

    (let ((rsp (url-retrieve-synchronously url)))
      (with-current-buffer rsp
        (set-buffer-multibyte t)
        (decode-coding-region (point-min) (point-max) 'utf-8-dos)
        (goto-char (point-min))
        (re-search-forward "^$" nil 'move)
        (make-response :headers (buffer-substring-no-properties (point-min) (point))
                       :body (buffer-substring-no-properties (point) (point-max)))))))

;; gnutls-error

(defun extract-audio-url (url)
  (let* ((rsp (url-open url))
         (match (string-match "\"contentURL\": *\"\\(.+\\)\",\n" (response-body rsp))))
    (if match
        (match-string 1 (response-body rsp))
      nil)))


(defun display-help-info ()
  (message (format "\nUSAGE: merriam-webster-audio-clawer.el -l WORD-LIST [-o OUTPUT-DIRECTORY]")))

(defun main ()

  (unless (file-exists-p "progress.yaml")
    (with-temp-file "progress.yaml"
      (insert "")))

  (when (or (null word-list) (null output-directory))
    (display-help-info)
    (kill-emacs 1))

  (setq input-file (expand-file-name word-list))

  (when (not (file-exists-p input-file))
    (message "Word List: %s doesn't exist !!" word-list)
    (kill-emacs 2))

  (setq output-directory-path (expand-file-name output-directory))

  (when (not (file-exists-p output-directory-path))
    (message "Output Directory: %s doesn't exist !!")
    (kill-emacs 2))

  (setq fd
        (with-temp-buffer
          (insert-file-contents-literally input-file)
          (buffer-string)))

  (setq words
        (-filter
         #'(lambda (l)
             (not (string-prefix-p "# " l)))
         (string-split fd "\n" t " *")))

  ;; download urls
  ;; (setq urls
  ;;       (mapcar
  ;;        (lambda (word)

  ;;          (let (res
  ;;                (record
  ;;                 (with-temp-buffer
  ;;                   (insert-file-contents-literally "progress.yaml")
  ;;                   (goto-char (point-min))
  ;;                   (re-search-forward (format "^%s: *\\(?:.*\\)$" word) nil t))))
  ;;            (unless record
  ;;              (condition-case err
  ;;                  (progn
  ;;                    (setq res (extract-audio-url (format "https://www.merriam-webster.com/dictionary/%s" word)))
  ;;                    (when res
  ;;                      (append-to-file (format "%s: %s\n" word res) nil "progress.yaml")
  ;;                      ))
  ;;                (error (message "Can not download audio of %s" word))))))
  ;;        words))

  (setq name-url-pairs
        (with-temp-buffer
          (insert-file-contents-literally "progress.yaml")
          (mapcar
           (lambda (l)
             (let* ((res (string-split l ":" t " *"))
                    (output (format
                             "%s%s.mp3"
                             (if (string-suffix-p "/" output-directory)
                                 output-directory
                               (format "%s/" output-directory))
                             (car res))))
               (condition-case err
                   (unless (file-exists-p output)
                     (url-copy-file (string-join (cdr res) ":") output))
                 (error (message "%s" (car res)))
                 )
               ))
           (string-split (buffer-string) "\n" t))))
  )

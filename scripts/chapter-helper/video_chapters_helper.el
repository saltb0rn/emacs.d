:;exec emacs --batch -l "$0" -f main -- "$@"
;; -*- lexical-binding: t -*-
;; Equals to 'emacs --batch -l ./video_chapters_helper.el -- -f chapters.txt -o output.txt'
;; About this shebang in this script: https://www.emacswiki.org/emacs/EmacsScripts
;; (info "(elisp) Command-Line Arguments")

;; This scripts is inspired by https://ikyle.me/blog/2020/add-mp4-chapters-ffmpeg

(package-initialize)

(setq args-list (cdr command-line-args-left))

(setq input-file (plist-get args-list "-f" #'equal))

(setq output-file (plist-get args-list "-o" #'equal))

(when (null output-file)
  (setq output-file (concat input-file "-chapters.txt")))

(defun display-help-info ()
  (message (format "\nUSAGE: video_chapters_helper.el -f INPUT [-o OUTPUT]")))

(defun main ()
  (when (member "-h" args-list)
    (display-help-info)
    (kill-emacs 0)) ;; kill-emacs used here is like the exit command in SHELL

  (when (null input-file)
    (display-help-info)
    (kill-emacs 1))

  (setq input-file (expand-file-name input-file))

  (when (null input-file)
    (message "INPUT file doesn't exist !!")
    (kill-emacs 2))

  (setq fd
        (with-temp-buffer
          (insert-file-contents-literally input-file)
          (buffer-string)))

  (setq chaps nil)
  (mapcar
   (lambda (line)
     (when (null (string-match "^ *$" line))
       (let ((trimed-line (string-trim line)))
         (when (string-match
                "^\\(?:\\([[:digit:]]*\\):\\)?\\([[:digit:]]\\{1,2\\}\\):\\([[:digit:]]\\{1,2\\}\\) +\\(.*\\)$"
                trimed-line)
           (let* ((hrs (string-to-number (or (match-string 1 trimed-line) "0")))
                  (mins (string-to-number (match-string 2 trimed-line)))
                  (secs (string-to-number (match-string 3 trimed-line)))
                  (title (match-string 4 trimed-line))
                  (minutes (+ (* hrs 60) mins))
                  (seconds (+ (* minutes 60) secs))
                  (timestamp (* seconds 1000)))
             (add-to-list 'chaps
                          (list
                           "title" title
                           "startTime" timestamp)
                          t) ;; add-to-list
             ) ;; let* ((hrs
           ) ;; when ((string-match
         ) ;; let
       ) ;; when (null
     ) ;; lambda
   (string-split fd "[\f\t\n\r\v]")) ;; mapcar

  (setq str-chaps nil)
  (let ((i 0)
        texts)
    (while (< i (1- (length chaps)))
      (add-to-list
       'texts
       (format
        "[CHAPTER]\nTIMEBASE=1/1000\nSTART=%d\nEND=%d\ntitle=%s"
        (plist-get (nth i chaps) "startTime" #'equal)
        (- (plist-get (nth (+ i 1) chaps) "startTime" #'equal) 1)
        (plist-get (nth i chaps) "title" #'equal))
       t)
      (setq i (1+ i))
      ) ;; while

    (write-region (string-join texts "\n\n") nil output-file)

    ) ;; let

  ) ;; main

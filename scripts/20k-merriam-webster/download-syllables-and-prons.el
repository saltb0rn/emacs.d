:; exec emacs --batch -l "$0" -f main -- "$@"
;; -*- lexical-binding: t -*-

(package-initialize)

(require 'dom)
(require 'url)
(require 'dash)

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

(defun download-syllables-and-pronounces (word)
  (catch 'return
    (let ((rsp
           (url-open (format "https://www.merriam-webster.com/dictionary/%s" word))))
      (with-temp-buffer
        (insert (response-body rsp))
        (set-buffer-multibyte t)
        (decode-coding-region (point-min) (point-max) 'utf-8)
        (let* ((tree (dom-by-id (libxml-parse-html-region (point-min) (point-max)) "dictionary-entry-1"))
               (syllables (dom-by-class tree "word-syllables-entry"))
               (prons
                (-filter (lambda (el) (equal (dom-tag el) 'a))
                         (dom-by-class (dom-by-class tree "prons-entries-list-inline")
                                       "prons-entry-list-item"))))

          ;; (when (< 1 (length prons))
          ;;   (throw 'return nil))

          (string-trim
           (string-join
            (list (if syllables (dom-text syllables) word)
                  (dom-text (nth 0 prons)))
            ";"
            ))
          )))))

(defun main ()
  ;; two prons => nil
  ;; (print (download-syllables-and-pronounces "often"))
  ;; no syllables, use word itself
  ;; (print (download-syllables-and-pronounces "at"))
  ;; syllables and be with single pron
  ;; (print (download-syllables-and-pronounces "specific"))

  (with-current-buffer (find-file-noselect "progress.yaml")
    (goto-char (point-min))
    (let ((state t)
          (i 0)
          cur-line
          append)
      (while state
        (setq cur-line (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
        (when (string-match "^\\(.*\\) *: *$" cur-line)
          (goto-char (line-end-position))
          (setq append (download-syllables-and-pronounces (match-string 1 cur-line)))
          (when append
            (if (string-suffix-p ":" cur-line)
                (insert (format " %s" append))
              (insert append))))
        (print (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
        (setq i (+ 1 i))
        (when (= 0 (% i 20))
          (save-buffer))
        (setq state (= 0 (forward-line)))))
    (save-buffer)))

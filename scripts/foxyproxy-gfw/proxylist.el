#!/usr/bin/emacs --script
;; -*- lexical-binding: t -*-

;; Description:
;;     This script is inspired by another project named Zm94eWdmdw== (base64 decode please).
;;     And some errors in Zm94eWdmdw== (base64 decode please) are fixed.
;;     Convert R0ZXTElTVA== (base64 decode please) into another format
;;     that used in Rm94eVByb3h5 (base64 decode please).

;; Usage:
;;     emacs -Q -q --script ./proxylist.el
;; or
;;     chmod u+x ./proxylist.el
;;     ./proxylist.el
;;
;; After script executed, that will generate a output.json

;; NOTICE:
;;     You may need a proxy (like proxychains) to access the source.

;; https://github.com/gfwlist/gfwlist/wiki/Syntax
;; https://help.getfoxyproxy.org/index.php/knowledge-base/url-patterns/

(package-initialize)

(require 'cl-lib)
(require 'json)
(require 'url)
(require 'dash)

(defconst URL
  "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt")

(cl-defstruct response headers body)

(defun url-open (url)
  "Return the response by requesting the url."
  (with-temp-buffer
    (insert-buffer (url-retrieve-synchronously url))
    (set-buffer-multibyte t)
    (decode-coding-region (point-min) (point-max) 'utf-8)
    (goto-char (point-min))
    (re-search-forward "^$" nil 'move)
    (make-response
     :headers
     (buffer-substring-no-properties (point-min) (point))
     :body
     (buffer-substring-no-properties (point) (point-max)))
    ))

(defun write-to-file (content file &optional coding-system)
  "Write CONTENT to FILE.
CONTENT should be string type.
FILE should be path to which CONTENT is written."
  (with-temp-buffer
    (insert content)
    (write-region (buffer-string) nil file)))

(defun read-from-file (file)
  "Read Content from FILE.
FILE should be a path to file."
  (with-temp-buffer
    (insert-file-contents-literally (expand-file-name file))
    (buffer-string)))

(defun regex-replace-in-string (regexp replacement string)
  "Replace content which matches REGEXP with
REPLACEMENT, and return the new content."
  (if (string-match regexp string)
      (string-replace
       (match-string 0 string)
       replacement
       string)
    string))

(defun pattern-to-alist (pattern)
  "Convert PATTERN into alist which will be used
as argument of `json-encode'"

  (let ((original-pattern pattern))

    (condition-case e
        (let ((black nil)
              (protocol 1)
              alist)

          (setq black t)

          ;; Determine if black pattern
          ;; black patterns are ones that start with "@@"
          (if (string-match "^@@" pattern)
              (setq pattern
                    (substring
                     pattern
                     2
                     (length pattern)))
            (setq black nil))

          ;; Get protocol
          ;; Some patterns HTTP pattern will looks like
          ;; this:
          ;; ^|?https?://
          (cond
           ((string-match "^|?http://" pattern)
            (setq protocol 2)
            (setq pattern
                  (regex-replace-in-string
                   "^|?http://" "|" pattern)))

           ((string-match "^|?https://" pattern)
            (setq protocol 4)
            (setq pattern
                  (regex-replace-in-string
                   "^|?https://" "||" pattern))))

          ;; Get match type
          (cond
           ((string-match "^||" pattern)
            (setq pattern
                  (format
                   "*.%s"
                   (substring pattern 2 (length pattern)))))

           ((string-match "^|" pattern)
            (setq pattern
                  (substring pattern 1 (length pattern)))))

          ;; Format the pattern
          (setq pattern
                (car (split-string pattern "/")))

          (unless (string-match "\\." pattern)
            (setq pattern (format "*%s*" pattern)))

          `((alist
            (original . ,original-pattern) ;; used for debug
            (include . ,(if black "exclude" "include"))
            (title . ,pattern)
            (pattern . ,pattern)
            (type . "wildcard")
            (active . t))))

      ;; handler list
      (error
       (message
        "%S"
        `((:unexpected-pattern . ,original-pattern)
          (:error . e)))
       '((alist))))))

(defun main ()
  (let (rsp
        content
        patterns
        user-patterns
        config)

    (condition-case e
        (progn

          ;; request
          (setq rsp
                (url-open URL))

          (setq content
                (base64-decode-string
                 (response-body rsp)))

          (setq patterns
                (-filter
                 (lambda (str) (> (length str) 0))
                 (split-string content "\n")))

          (when (file-exists-p "./user-patterns")
            (setq patterns
                  (append
                   patterns
                   (-filter
                    (lambda (str) (> (length str) 0))
                    (split-string
                     (read-from-file "./user-patterns")
                     "\n")))))

          (mapcar
           ;; func
           (lambda (pattern)
             (catch 'return

               (when (string-match
                      "\\(^\\[AutoProxy\\|^!\\|^/[[:ascii:]]+/$\\)"
                      pattern)
                 (throw 'return nil))

               (let ((pattern-alist
                      (pattern-to-alist pattern)))

                 (unless (alist-get 'alist pattern-alist)
                   (throw 'return nil))

                 (push (alist-get 'alist pattern-alist) config)
                 ;; (let ((key
                 ;;        (if (alist-get
                 ;;             'black pattern-alist)
                 ;;            'blackPatterns
                 ;;          'whitePatterns)))
                 ;;   (setf
                 ;;    (alist-get key config)
                 ;;    (append
                 ;;     (alist-get key config)
                 ;;     (list
                 ;;      (alist-get 'alist pattern-alist)))))
                 )))
           ;; seq
           patterns))

      ;; handler list
      (file-error
       (print (cdr e))))

    ;; out of condition-case, do something
    (write-to-file
     (json-encode
      config)
     "./output.json")))

(main)

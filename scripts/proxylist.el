#!emacs --script
;; -*- lexical-binding: t -*-

;; Description:
;;     This script inspired by another project named Zm94eWdmdw== (base64 decode please).
;;     And some errors in Zm94eWdmdw== (base64 decode please) are fixed.
;;     Convert R0ZXTElTVA== (base64 decode please) into another format
;;     that used in Rm94eVByb3h5 (base64 decode please).

;; Usage:
;;     emacs -Qq --script proxylist.el

;; NOTICE:
;;     You may need modified the `dash' library path to make it work,
;;     and also need a proxy to access the source.

(require 'cl-lib)
(require 'json)
(require 'url)
(require 'dash "~/.emacs.d/elpa/dash-20230304.2223/dash.el")

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
  (condition-case e
      (let (white
            protocol
            alist
            (original-pattern pattern))

        (setq white t)
        (setq protocol 1)

        (if (string-match "^@@" pattern)
            (setq pattern
                  (substring
                   "@@ab" 2
                   (length "@@ab")))
          (setq white nil))

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

        `((white ,white)
          (alist
           (original . ,original-pattern) ;; used for debug
           (title . ,pattern)
           (pattern . ,pattern)
           (type . 1)
           (protocols . ,protocol)
           (active . t))))

    ;; handler list
    (error
     `((white nil)
       (alist nil)))))

(defun main ()
  (let (rsp
        content
        patterns
        (config
         (json-read-file "./proxylist-base.json")))

    (setf (alist-get 'whitePatterns config) nil)

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

                 (let ((key
                        (if (alist-get 'white pattern-alist)
                            'whitePatterns
                          'blackPatterns)))
                   (setf
                    (alist-get key config)
                    (append
                     (alist-get key config)
                     (list
                      (alist-get 'alist pattern-alist))))))))
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

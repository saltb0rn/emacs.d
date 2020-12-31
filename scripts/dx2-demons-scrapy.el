(require 'cl-lib)
(require 'dom)
(require 'json)
(require 'subr-x)
(require 'url)

(cl-defstruct response headers body)

(defun url-open (url &rest args)
  "Retrun the response by requesting the url"
  (let ((url-request-extra-headers (plist-get args :headers))
        (url-request-method (plist-get args :method))
        (url-request-data (plist-get args :data)))
    (let ((rsp (url-retrieve-synchronously url)))
      (with-current-buffer rsp
        (set-buffer-multibyte t)
        (decode-coding-region (point-min) (point-max) 'utf-8-dos)
        (goto-char (point-min))
        (re-search-forward "^$" nil 'move)
        (make-response :headers (buffer-substring-no-properties (point-min) (point))
                       :body (buffer-substring-no-properties (point) (point-max)))))))

(defun url-open-async (url callback &rest args)
  "Asynchronously handle the response"
  (let ((url-request-extra-headers (plist-get args :headers))
        (url-request-method (plist-get args :method))
        (url-request-data (plist-get args :data))
        (cbargs (plist-get args :cbargs)))
    (url-retrieve url callback cbargs)))

;; https://dx2wiki.com/index.php/Demon_List
(defun main ()
  (url-open-async
   "https://dx2wiki.com/index.php/Demon_List"
   (lambda (status &optional args)
     (with-current-buffer (current-buffer)
       (set-buffer-multibyte t)
       (decode-coding-region (point-min) (point-max) 'utf-8-dos)
       (let ((tree (libxml-parse-html-region (point-min) (point-max))))
         (dolist (elt (dom-by-tag tree 'th))
           (if (dom-by-tag elt 'a)
               (url-copy-file
                (format "https://dx2wiki.com/index.php/Demon_List%s")
                )
             (message "%S" (dom-text elt))))
         )))))

(main)

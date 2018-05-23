;;; ob-compile.el --- Compile the org files into html files ;; -*- lexical-binding: t -*-
;;; Commentary:
;; it depends on `mustache' library
;; The function whose name starts with ob-- are not recommended for you to use in your render-ctrl
;;; Code:
(require 'ht)
(require 'mustache)
;;(autoload 'mustache-render "mustache")
(require 'ob-env)
(require 'ob-util)

(search-forward-regexp "\b\\:(\\[a-zA-Z\\]\\|-)*")

(defun ob-new-blog (name &optional path)
  "Create a blog project named NAME in PATH")

(defun ob-compile ()
  "Compile org files into html files.
ADD-CTX is a alist like ((\"key1\" \"value1\") (\"key2\" \"value2\") ...),
standing for parameters used by TPL."
  (ob--verify-configuration)
  (setq category-scheme (assoc ob-category-scheme ob-category-schemes))
  (message (format "You are using %s configuration" (car category-scheme)))
  (setq category-list (cadr category-scheme))
  (dolist (category category-list)
    ;; TODO: if there is some customized rendering functions, then use the them,
    ;; otherwise, just use the default one, if the render-ctrl of non-default category is nil
    ;; then the category will be not rendered.
    (let* ((settings (ob-get-category-setting "about"))
	   (render-ctrl (plist-get settings :render-ctrl)))
      (if render-ctrl
	  (let ((fun-def (or (symbol-function render-ctrl)
			     (functionp render-ctrl))))
	    (if fun-def (funcall fun-def settings)
	      (error "No such function named %s" (symbol-name render-ctrl))))
	(ob--default-render-ctrl category)))))

(defun ob-get-category-settings (category-name)
  "Return a alist of category setting."
  (let ((category-settings (assoc category-name ob-category-settings)))
    (if category-settings (cdr category-settings) nil)))

(defun ob-generate-uri (uri-template &optional title creation-date)
  ""
  )

(defun ob-file-to-string (file)
  "Return a string as content from the FILE"
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defun ob-string-to-file (string file &optional mode)
  "Write STRING to the FILE"
  (with-temp-buffer
    (insert string)
    (set-buffer-file-coding-system 'utf-8)
    (when (and mode (functionp mode))
      (funcall mode)
      (flush-lines "^[ \\t]*$" (point-min) (point-max))
      (delete-trailing-whitespace (point-min) (point-max))
      (indent-region (point-min) (point-max)))
    (when (file-writable-p file)
      (write-region (point-min) (point-max) file))))

(defun ob-render-template (tpl &optional ctx)
  "Return content from rendering template file TPL with context CTX"
  (let* ((template-directory (concat (ob-get-path-to-theme) "templates/"))
	 (mustache-partial-paths (or mustache-partial-paths template-directory)))
    (if (not (or (file-exists-p template-directory)
		 (directory-name-p template-directory)))
	(error "Can't find your templates")
      (mustache-render (ob-file-to-string tpl)
		       (eval `(ht ,@ctx))))))

(defun ob-get-path-to-theme ()
  "Return the path pointing to theme being used."
  (or ob-theme
      (concat (ob-load-directory) "themes/default/")))

(defun ob-get-path-to-target-directory ()
  ""
  (and ob-blog-source-directory
       (or ob-blog-target-directory
	   (concat ob-blog-source-directory "blog/"))))

(defun ob-load-directory ()
  "Return the path to `org-blogger' installtion."
  (cond
   (load-file-name (file-name-directory load-file-name))
   ((symbol-file 'ob-compile 'defun)
    (file-name-directory (symbol-file 'ob-compile 'defun)))
   ((string= (file-name-nondirectory buffer-file-name) "ob-compile.el")
    (file-name-directory buffer-file-name))
   (t nil)))

(defun ob-read-org-option (file option)
  "Return a alist as options from org-file"
  (with-temp-buffer
    (insert (ob-file-to-string file))
    (org-mode)
    (let ((match-regexp (concat "^[ \t]*#\\+"
				option
				":[ \t]*\\(.*\\)")))
      (goto-char (point-min))
      (when (re-search-forward match-regexp nil t)
	(match-string-no-properties 2 nil)))))

(defun ob--verify-confiugration ()
  ;;TODO: Required setting variables all, they must be
  ;; validate
  ;; every element in `ob-category-settings' must contains these data:
  ;; ("category-name"
  ;;  :name nil-or-string
  ;;  :comment t-or-nil
  ;;  :uri-template "uri"
  ;;  :tag t-or-nil
  ;;  :meta t-or-nil
  ;;  :render-ctl 'symbol-of-function or nil
  ;; )
  ;; then, you can add new :key new value into it for your purpose,
  ;; to graunted this data is validated TODO: write `set' function for `ob-category-settings'
  )

(defun ob--default-render-ctrl (category)
  "
"
  (let ((settings (ob-get-category-settings category)))
    (cond
     ((string= category "index") (ob--index-render-ctrl settings))
     ((string= category "about") (ob--about-render-ctrl settings))
     ((string= category "post") (ob--post-render-ctrl settings))
     (t nil))))

(defun ob--index-render-ctrl (settings)
  ;; What does index page look like? It lists all post titles. If "post" category is not
  ;; the member of `ob-category-settings'
  (let* ((post-settings (ob-get-category-settings "post"))
	 (uri-template (assoc "URI-TPL" post-settings))
	 (all-posts (ob--get-all-posts))
	 (all-posts-infos (and
			   all-posts
			   (mapcar
			    #'(lambda (file)
				;; (extract-info-from file)
				(let* ((date (or (ob-read-org-option file "DATE")
						 (format-time-string "%Y-%m-%d")))
				       (title (or (ob-read-org-option file "TITLE")
						  (file-name-base file)))
				       (uri (ob--generate-post-uri uri-template file date title)))
				  (list
				   (list "DATE" date)
				   (list "TITLE" title)
				   (list "POST-URI" uri))))
			    all-posts))))
    ;; TODO: NEED infos of categories, include their uri
    (ob-string-to-file
     (ob-render-template "index.mustache" all-posts-infos)
     (concat (ob-get-path-to-target-directory) "index.html"))))

(defun ob--about-render-ctrl (settings)
  ;; TODO: just a simple page gaving a introduction of you
  ;; find the `about.org' file to render
  ;; TODO: read the options from `about.org', then render it
  (let* ((about-settings (ob-get-category-settings "about"))
	 (settings-from-file (list
			      (list "DATE" (ob-read-org-option "about.org" "DATE"))
			      (list "CONTENT" (ob-read-org-content "about.org"))))
	 (compose-settings (ht-merge (eval `(ht ,@about-settings))
				     (eval `(ht ,@settings-from-file)))))
    ;; TODO: Change all the keys in `ob-category-settings' into string
  (ob-string-to-file
   (ob-render-template "about.org" (ob-get-category-settings "about"))
   (concat (ob-get-path-to-target-directory) "about/index.html"))))


(defun ob--post-render-ctrl (settings)
  ;; TODO: interate over all org files;
  ;; read each org-file and render each file into html
  ;; generate uri for each html
  )

(defun ob--get-all-posts ()
  ;; TODO:
  )

(defun ob--generate-post-uri (uri-template file creation-date title)
  (let ((date-list (split-string (fix-timestamp-string creation-date) "-")))
    (format-spec uri-template `((?y . ,(car date-list))
				(?m . ,(cadr date-list))
				(?d . ,(cl-caddr date-list))
				(?f . ,(concat (file-name-base file) ".html"))
				(? . ,(encode-string-to-url title))))))

(provide 'ob-compile)
;;; ob-compile.el ends here

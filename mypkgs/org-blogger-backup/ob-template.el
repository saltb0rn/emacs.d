;;; ob-templating.el --- Provide templating facilities to org-blogger ;; -*- lexical-binding: t -*-

;;; Code:
(require 'ht)
(require 'ob-utils)
(autoload 'mustache-render "mustache"
  "More informations on C-h f mustach-render")


(defconst EMTPY-CONTEXT (ht)
  "An empty context as the default context")

(defun ob/render (tpl &optional ctx)
  "
Return a string as the content of page render by
"
  )
  

(defun ob/render--template-as-string (tpl &optional ctx)
  "
Return a string as the content of page rendered by template with context.
This function will not resolve template including problem.
TPL: the path to template.
CTX: the context which is a hash table from mustache
"
  (mustache
   (read-file-as-string tpl)
   (or ctx EMPTY-CONTEXT)))


(defun ob/render--template-as-ht (tpl &optional ctx)
  "Return a hash table mapping template's name to it's content.
TPL: the path to template.
CTX: the context which is a hash table from mustache.
"
  (let ((fname
	 (file-name-nondirectory (expand-file-name tpl)))
	(content
	 (ob/render--template-as-string tpl ctx)))
    (ht fname content)))


(provide 'ob-template)
;;; ob-templating.el ends here

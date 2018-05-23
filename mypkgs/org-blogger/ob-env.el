;;; ob-env.el --- Environment for configuring ob-blogger ;; -*- lexical-binding: t -*-
;;; Commentary:
;;
;;; Code:

(defgroup org-blogger nil
  "Options for `org-blogger'"
  :tag "Org static site generator" :group 'org)

(defcustom ob-blog-source-directory nil
  "The directory to store your org files,
it is the required option."
  :group 'org-blogger :type 'string)

(defcustom ob-blog-target-directory nil
  "The directory to store your publicated files.
By default, it is the path pointing to a directory named \"blog\"
in `ob-blog-source-directory'"
  :group 'org-blogger :type 'string)

(defcustom ob-theme nil
  "The directory where theme used by `org-blogger' stored on.
By default, it will point the directory `themes/default/' in
`org-blogger' installation direcotry."
  :group 'org-blogger :type 'string)

(defcustom ob-category-scheme "default"
  "The current category scheme"
  :group 'org-blogger :type 'string)

(defcustom ob-category-schemes
  '(("default" ("index" "about")))
  ;; The first one is the name of scheme, the rest of the list
  ;; are the category names
  ;; you can add other schemes with different names, like
  ;;
  "The categories you want to put on your page."
  :group 'org-blogger :type 'alist)

(defcustom ob-category-settings
  '(("index"		; category name
     :name nil		; the name you want it to display
     :comment nil	; show comment or not
     :category t	; show the types of pages or not
     :uri-template "/"	; the format of uri
     :tag nil		; show tags or not
     :meta t		
     :render-ctrl nil)			; the function to render this category
    ("about"
     :name nil
     :comment nil
     :category t
     :uri-template "/about/"
     :tag nil
     :meta t
     :render-ctrl nil)
    ("post"
     :name nil
     :comment t
     :category t
     :meta t
     :tag t
     :uri-template "/post/%y/%m/%d/%t/"
     :render-ctrl nil))
  "Define schemes to control the behavior of rendering categories"
  ;; TODO: Each category corresponding to a main page
  :group 'org-blogger :type 'alist)

(provide 'ob-env)
;;; ob-env.el ends here


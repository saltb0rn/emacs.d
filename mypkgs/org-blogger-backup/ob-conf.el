;;; ob-conf.el --- Configurations required by org-blogger ;; -*- lexical-binding: t -*-


;;; Commentary:
;;

;;; Code:

(require 'ht)

(defun ob/verify-conf ()
  "Ensure all configuration fields are properly configured."
  )

(defconst ob/temp-buffer-name "*Org Blogger*"
  "Name of the temporary buffer used by org-blogger.")

(defconst ob/load-directory
  (cond
   (load-file-name (file-name-directory load-file))
   ((symbol-file 'ob/temp-buffer-name 'defconst)
    (file-name-directory (symbol-file 'op/temp-buffer-name 'defconst)))
   ((string= (file-name-nondirectory buffer-file-name) "ob-conf.el")
    (file-name-directory buffer-file-name))
   (t nil))
  "The directory where ob-blogger is loaded from.")

(defgroup org-blogger nil
  "Options for static site generator, the org-blogger."
  :tag "Org static site generator" :group 'org)

(defcustom ob/source-directory nil
  "The directory where org files stored on."
  :group 'org-blogger :type 'string)

(defcustom ob/target-directory nil
  "The directory where compiled org files should be stored on."
  :group 'org-blogger :type 'string)

(defcustom ob/export-backend 'html
  "The org-export backend used for page generation."
  :group 'org-blogger :type 'symbol)

(defcustom ob/site-domain nil
  "The domain name of entire site."
  :group 'org-blogger :type 'string)

(defcustom ob/site-main-title "Org Blogger"
  "The main title of entire site."
  :group 'org-blogger :type 'string)

(defcustom ob/site-sub-title nil
  "The sub title of entire site."
  :group 'org-blogger :type 'string)

(defcustom ob/theme-root-directory
  (concat ob/load-directory "themes/")
  "The root directory storing themes for page rendering.
By default, it
points to the directory `themes' in ob-blogger installation directory."
  :group 'org-blogger :type 'string)

(defcustom ob/theme
  (concat ob/theme-root-directory "default/")
  "The theme used to render page.
By default, org-blogger use default theme when
it is nil.  It points the sub directory of `ob/theme-root-directory'
."
  :group 'org-blogger :type 'string)

(defcustom ob/template-directory
  (concat ob/load-directory "templates/")
  "The directory stores template files that are used to render page.
By default, it point to the same directory level as `ob/theme-root-directory'"
  :group 'org-blogger :type 'string)

(defcustom ob/site-preview-directory "~/.ob-tmp"
  "Temporary directory path for site preview."
  :group 'org-blogger :type 'string)

(defcustom ob/category-config-alist
  "Configuration for different categories"
  '(("blog"
     :show-meta t
     :show-comment t
     :uri-generator ob/generate-uri
     :uri-template "/blog/%y/%m/%d/%t/"
     :sort-by :date
     :category-index t)
    ("index"
     :show-meta nil
     :show-comment nil
     :uri-generator ob/generate-uri
     :uri-template "/"
     :sort-by :date
     :category-index nil)
    ("about"
     :show-meta nil
     :show-comment nil
     :uri-generatr ob/generate-uri
     :uri-template "/about/"
     :sort-by :date
     :category-index nil))
  :group 'org-blogger :type 'alist)

(defcustom ob/rss-template
  (concat ob/template-directory "rss.html")
  "The RSS template path."
  :group 'org-blogger :type 'string)

(defcustom ob/comment-template
  (concat ob/template-directory "comment.html")
  "The comment template path."
  :group 'org-blogger :type 'string)

(defcustom ob/additional-context nil
  "Your new configuration variables or modifications you want to put into page.
It should be a alist of (SYMBOL . STRING)."
  :group 'org-blogger :type 'alist)

(defconst ob/defualt-template-context
  '(("blog-uri" "/blog")
    ("tags-uri" "/tags/")
    ("about-uri" "/about/")
    ("site-main-title" ob/site-main-title)
    ("site-sub-title" ob/site-sub-title))
  "Do NOT modify it unless you know what you are doing. If you want to extend
or update it, you can custom `ob/additional-cotext' to do so.")

(provide 'ob-conf)
;;; ob-conf.el ends here


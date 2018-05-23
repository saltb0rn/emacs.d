;;; org-blog-scratch-var.el --- Settings required by org blog scratch ;; -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(defgroup org-blog-scratch nil
  "Options for org-blog-scratch"
  :tag "A static site generator for scratch" :group 'org)

(defcustom obs-themes nil
  "Point to the directory where themes store on.
By default, it points to the directory named \"themes\" in
where org-blog-scratch installed on."
  :group 'org-blog-scratch :type 'string)

(defcustom obs-theme nil
  "The theme used by the user, it is the name of directory which in the
`obs-themes'. By default, it is \"default\"."
  :group 'org-blog-scratch :type 'string)

(defcustom obs-source-directory nil
  "Point to your post project. Not allowd to be nil"
  :group 'org-blog-scratch :type 'string)

(defcustom obs-target-directory nil
  "Point to directory where generated files stored on"
  :group 'org-blog-scratch :type 'string)

(defcustom obs-pages
  '(("index"
     :name "Index"
     :url "/"
     :filename "index.html"
     :render-ctrl 'obs--index-page-generator)
    ("about"
     :name "About"
     :url "/about/"
     :filename "about.html"
     :render-ctrl 'obs--about-page-generator)
    ("post"
     :name "Posts"
     :url "/post/%y/%m/%d/%t"
     :filename "%s"
     :render-ctrl 'obs--post-page-generator))
  "Pages"
  :group 'org-blog-scratch :type 'alist)



(provide 'org-blog-scratch-var)
;;; org-blog-scratch-interface-var.el ends here

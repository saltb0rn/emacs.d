;;; init-org-blog.el --- Configurations for blogging with Org-mode ;; -*- lexical-binding: t -*-
;;; Commentary:
;; I copied these code from "https://www.superloopy.io/articles/2017/blogging-with-org-mode.html"
;; and modified it to fit my requirement.

;; How to use it. First configurate your projects,
;;; Code:

(require 'ox)
(require 'org)
(require 'org-capture)
; (require 'simple-httpd)

;;(require 'clojure-mode)
;;(require 'scala-mode)
;;(require 'cc-mode)
;;(require 'sh-script)

(setq org-export-coding-system 'utf-8)

(define-key global-map "\C-cc" 'org-capture)

(setq project-path "~/Documents/DarkSalt/")

(setq publish-path (concat project-path "publish/"))

(setq script--load-path
      (cond
       (load-file-name (file-name-directory load-file-name))
       ((symbol-file 'project-path 'setq)
	(file-name-directory (symbol-file 'project-path 'setq)))
       ((string= (file-name-nondirectory buffer-file-name) "init-org-blog.el")
	(file-name-directory buffer-file-name))
       (t nil)))

(defun capture-blog-post-file ()
  "Return a path where to store post files. This path will be important.
Usually calling `org-capture' will store the captured content into
a existed file. We do something unusual that store the captured content
into a non-existed file.
When calling `org-capture', it will let you input the post file name,
the TITLE and something things accroding to the templates specified by
the `org-capture-templates'. "
  (let* ((title (read-string "Slug: "))
	 (slug (replace-regexp-in-string "[^a-z]+" "-" (downcase title))))
    (expand-file-name
     (format (concat project-path "posts/%s/%s.org")
	     (format-time-string "%Y" (current-time))
	     slug))))

(setq org-capture-templates nil)

(add-to-list 'org-capture-templates
	     `("b" "Blog Post" plain
	       (file capture-blog-post-file)
	       (file ,(concat script--load-path "org-blog-tpl.org"))))

(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))

      org-html-doctype "html5"

      org-html-home/up-format "
<div id=\"org-div-home-and-up\">
  <img src=\"/images/logo.png\" alt=\"Superloopy Logo\"/>
  <nav>
    <ul>
      <!-- <li><a accesskey=\"h\" href=\"%s\"> Up </a></li>\n -->
      <li><a accesskey=\"H\" href=\"%s\"> Home </a></li>
      <li><a accesskey=\"a\" href=\"/posts\"> Posts </a></li>
      <!-- <li><a accesskey=\"p\" href=\"/publications.html\"> Publications </a></li> -->
      <li><a accesskey=\"A\" href=\"/about.html\"> About </a></li>
    </ul>
  </nav>
</div>
"
      org-html-head (concat "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/main.css\" />\n"
			    "<link rel=\"icon\" type=\"image/png\" href=\"/images/icon.png\" />")

      org-html-scripts (concat org-html-scripts
			       "<script type=\"text/javascript\">
if(/superloopy\.io/.test(window.location.hostname)) {
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
  ga('create', 'UA-4113456-6', 'auto');
  ga('send', 'pageview');
}</script>")

      org-html-link-home "/"
      org-html-link-up "/"

      org-export-with-toc nil
      org-export-with-author t
      org-export-with-email nil
      org-export-with-creator nil
      org-export-with-date nil
      org-export-with-section-numbers nil

      org-html-preamble nil
      org-html-postamble 'auto
      org-publish-project-alist
      `(("static"
	 :base-directory ,project-path
	 :base-extension "js\\|css\\|png\\|jpg\\|pdf"
	 :publishing-directory ,publish-path
	 :publishing-function org-publish-attachment
	 :recursive t)
	("home"
	 :base-directory ,project-path
	 :base-extension "org"
	 :publishing-directory ,publish-path
	 :publishing-function org-html-publish-to-html)
	("posts"
	 :base-directory ,(concat project-path "posts/")
	 :makeindex t
	 :publishing-directory ,(concat publish-path "posts/")
	 :publishing-function org-html-publish-to-html
	 :recursive t)
	("DarkSalt" :components ("static" "home" "posts"))))

; (setq httpd-root publish-path)
; (httpd-start)

; (httpd-stop)

(provide 'init-org-blog)

;;; init-org-blog.el ends here

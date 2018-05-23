;;; org-blog-scratch.el --- A simple static site generator respects to "Simple is best" ;; -*- lexical-binding: t -*-

;;; Commentary:
;; This is a simple static site generator that provides less features but more customizables.
;; I believe this project is simple to read for who wants to learn to write a static site generator.
;; I will keep this project simple as I can.

;;; Code:

(require 'org-blog-scratch-interface)
(require 'org-blog-scratch-var)

(defun obs--construct-navigator-ctx (&optional opts)
  "
"
  ;; Construct a hash table for render the page
  (let ((pages
	 (mapcar
	  #'(lambda (page-opt)
	      (ht
	       ("PAGE-NAME" (assoc :name (cdr page-opt)))
	       ("PAGE-URL" (assoc :url (cdr page-opt)))))
	  obs-pages)))
    (ht ("PAGES" pages))))

(defun obs--construct-footer-ctx (&optional opts)
  "
"
  (ht))

(defun obs--construct-index-body-ctx (&optional opts)
  "A ht with post title."
  (ht))

(defun obs--construct-post-body-ctx (content-file &optional opts)
  (ht))

(defun obs--index-page-generator (tpl content-file &optional opts)
  "To generate the index page."
  (let* ((tpl-string (obs-file-to-string tpl-file))
	 (ctx (ht-merge
	       (obs--construct-navigator-ctx)
	       (obs--construct-footer-ctx)
	       (obs--construct-body-ctx)))
	 (string (mustache-render tpl-string ctx)))
    (obs-string-to-file string "Same location as index.org")))

(defun obs--about-page-generator (tpl content-file &optional opts)
  )

(defun obs--post-page-generator (tpl content-file &optional opts)
  )

(defun obs-compile ()
  ;; Every org file is like a request to be passed to the generator like the response function
  )

(provide 'org-blog-scratch)
;;; org-blog-scratch.el ends here

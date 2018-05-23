;;; org-blog-scratch-interface.el --- Interfaces that required by org-blog-scratch and for users ;; -*- lexical-binding: t -*-

;;; Commentary:
;; All org files must be contracted by contraction.
;;; Code:

(require 'mustache) ; We need `mustache-render' and `mustache-partial-paths'
(require 'ht)

;; TODO:
(defun obs-read-option (opt &optional org-file)
  "Return value of OPTION in ORG-FILE, if ORG-FILE is nil,
then it returns value of OPTION in current buffer."

  )

(defun obs-read-content (&optional org-file)
  "Return content of ORG-FILE, the content is without options."
  )

(defun obs-file-to-string (file)
  "Return content of FILE, which represented by string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defun obs-string-to-file (file &optional string mode)
  "Write STRING to a FILE.
If STRING is nil, then it is content of current buffer.
If FILE is nil, then it is the path (concat `obs-target-directory' (buffer-name))."
  (let ((string (or string (buffer-string))))
    (with-temp-buffer
      (insert string)
      (set-buffer-file-coding-system 'utf8)
      (when (and mode (functionp mode))
	(funcall mode)
	(flush-lines "^[ \\t]*$" (point-min) (point-max))
	(delete-trailing-whitespace (point-min) (point-max))
	(indent-region (point-min) (point-max)))
      (when (file-writable-p file)
	(write-region (point-min) (point-max))))))

(defun obs-compile-all (&optional recompile)
  "Compile all the org files in the (concat `obs-source-directory' \"blog/\").
Recompile all already existed files if RECOMPILE is t."
  )

(defun obs-post-directory ()
  "Return the path to directory where posts store on."
  (and obs-source-directory
       (concat obs-source-directory "posts/")))

(defun obs-tag-direcotry ()
  "Return the path to directory where tags store on."
  (and (obs-post-directory)
       (concat (obs-post-directory) "tags/")))

(defun obs-load-directory ()
  "Return the directory where org-blog-scratch is laoded from."
  (cond
   (load-file-name (file-name-directory load-file-name))
   ((symbol-file 'obs-theme-directory 'defun)
    (file-name-directory (symbol-file 'obs-theme-directory 'defun)))
   ((string= (file-name-nondirectory buffer-file-name) "org-blog-scratch-interface.el")
    (file-name-directory buffer-file-name))
   (t nil)))

(defun obs-theme-directory (theme)
  "Return the path to directory where themes store on."
  (if (null obs-themes)
      (and (obs-load-directory)
	   (concat (obs-load-directory) "themes/" theme "/"))
    obs-theme))

(defun obs-posts ()
  "Retrive posts from `(concat obs-source-directory \"posts/\")'."
  (let ((post-directory (obs-post-directory)))
    (and post-directory
	 (not (file-exists-p post-directory))
	 (make-directory-internal post-directory))
    (directory-files post-directory)))

(defun obs-post-tags ()
  "Return all tags, which are from posts."
  (let* ((posts (obs-posts))
	 (tags (split-string (mapconcat
			      #'(lambda (post)
				  (or
				   (obs-read-option "tags" post)
				   "others"))
			      posts " ")
			     " ")))
    (remove-duplicates tags)))

(defun obs-generate-tag-page (tag)
  "Every TAG have one page and every page lists all posts with tag TAG.
Return a ht object with form that looks like
(ht \"posts\" (list (ht (\"title\" title) (\"url\" url)) ...))."
  (let ((tag-directory (obs-tag-direcotry))
	(posts (obs-posts)))
    (unless (file-exists-p tag-directory)
      (make-directory-internal tag-directory))
    (obs-string-to-file
     (concat (obs-tag-directory) tag ".html")
     (mustache-renderf
      (obs-file-to-string (concat (obs-theme-directory obs-theme) "tag.mustache"))
      (ht ("posts"
	   (mapcar
	    #'(lambda (post)
		(when (member tag (split-string (or (obs-read-option tags) "others") " "))
		  (ht ("title" (or
				(obs-read-option "TITLE")
				(file-name-base post)
				(file-name-base (buffer-name))))
		      ("url" (obs-post-url post)))))
	    posts)))))))

(defun obs-generate-post-page (post)
  "Generate POST.html in `(obs-post-directory)'."

  )

(defun obs-src-url ()
  "Return url of SRC."
  )

(defun obs-tag-url (tag)
  "Return a tag url with applying `url-encode-url'
to relative path of TAG.html."
  (url-encode-url (file-relative-name
		   (concat (obs-tag-direcotry) tag ".html")
		   (obs-tag-direcotry))))

(defun obs-post-url (post)
  "Return a post url with applying `url-encode-url'
to relative path of POST.html."
  (url-encode-url
   (file-relative-name
		   (concat (obs-post-direcotry) post ".html")
		   (obs-post-directory))))

(provide 'org-blog-scratch-interface)
;;; org-blog-scratch-interface.el ends here

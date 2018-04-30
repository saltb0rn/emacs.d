(require-install 'org-plus-contrib)
(require 'org)

;;; Options

(setq-default TeX-engine 'xtex)

(setq

 org-export-with-sub-superscripts nil	; Toggle Tex-like syntax for sub- and superscripts. If you write "^:{}", 'a_{b}' will be interpreted, but simple 'a_b' will be left as it is
 org-export-with-author nil
 org-export-with-broken-links t	; Toggle if Org should continue exporting upon finding a broken internal link. When set to mark, Org clearly marks the problem link in the output
 org-publish-project-alist
       '(

	 ("org-darksalt"
	  ;; Path to your org files.
	  :base-directory "/media/saltb0rn/Files/workspace/DarkSalt/org/"
	  :base-extension "org"

	  ;; Path to your Jekyll project.
	  :publishing-directory "/media/saltb0rn/Files/workspace/DarkSalt/jekyll/"
	  :recursive t
	  :publishing-function org-html-publish-to-html
	  :headline-levels 4
	  :html-extension "html"
	  :body-only t ;; Only export section between <body> </body>
	  )

	 ("org-static-darksalt"
	  :base-directory "/media/saltb0rn/Files/workspace/DarkSalt/org/"
	  :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|php"
	  :publishing-directory "/media/saltb0rn/Files/workspace/DarkSalt/"
	  :recursive t
	  :publishing-function org-publish-attachment)

	 ("salt" :components ("org-darksalt" "org-static-darksalt"))

	 )
       )

(provide 'init-org)

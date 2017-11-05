;;; Initialize action to load site-lisp
(add-subdirs-to-load-path
 (expand-file-name "site-lisp/" user-emacs-directory))

(provide 'init-site-lisp)

;;; Initialize action to load site-lisp

;;; Code:
(require-install 'cl)
;;(eval-when-compile (require-install 'cl))
(defun add-subdirs-to-load-path (parent-dir)
  (let* ((default-directory parent-dir))
    (progn
      (setq load-path
	    (append
	     (remove-if-not
	      #'(lambda (dir) (file-directory-p dir))
	      (directory-files (expand-file-name parent-dir) t "^[^\\.]"))
	     load-path)))))

(add-subdirs-to-load-path
 (expand-file-name "site-lisp/" user-emacs-directory))

(provide 'init-site-lisp)

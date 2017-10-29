;; Configure melpa source
(require 'package)

(setq *latest-checked* nil)
(setq *use-proxy* nil)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
;; (add-to-list 'package-archives '("melpa" . "http://www.mirrorservice.org/sites/melpa/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

;; The function that adds the subdirs to load-path
(defun add-subdirs-to-load-path (parent-dir)
  (let* ((default-directory parent-dir)) ; `default-directory' is the built-in variable
    (setq load-path
	  (append
	   (remove-if-not
	    #'(lambda (dir) (file-directory-p dir))
	    (directory-files
	     (expand-file-name parent-dir) ; Need optional argument if `default-directory' variable
	     t "^[^\\.]"))		   ; is not used
	   load-path))))

;;; These are the way to wirte a hook and how to run hook(s)
;;; ==========================================================================
(defvar package-refresh-contents-hook
  nil "Hook call after package-refresh-contents")
(add-hook 'package-refresh-contents-hook
	  #'(lambda ()
	      (if (y-or-n-p (format "Use Proxy or NOT?"))
		  (setq url-proxy-services
			'(("no-proxy" . "^\\(localhost\\|10.*\\)")
			  ("http" . "127.0.0.1:8118"))))))

(defun package-refresh-contents-ex ()
  (interactive)
  (package-refresh-contents)
  (if (null *use-proxy*)
      (run-hooks 'package-refresh-contents-hook)))
;;; ==========================================================================

(defun require-install (package)
  "Assure package is installed"
  (let ((is-installed (package-installed-p package)))
    (when (not is-installed)
	(when (not *latest-checked*)
	  (setq *latest-checked* t)
	  (package-refresh-contents))
	(package-install package))
    (require package nil t)))

(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it's not."
  "Return a list of installed packages or nil for every skipped package."

  (mapcar
   (lambda (package)
     ;; (package-installed-p 'evil)
     (if (package-installed-p package)
	 nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
	 (progn
	   (if (null *latest-checked*)
	       (progn
		 (package-refresh-contents)
		 (setq *latest-checked* t)))
	   (package-install package))
	 package)))
   packages))

(or (file-exists-p package-user-dir)
    (package-refresh-contents))

(package-initialize)

(provide 'init-elpa)

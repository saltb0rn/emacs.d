;;; sysconf.el --- My script to install system packages -*- lexical-binding: t -*-

;; Copyright (C) 2017 Salt Ho

;; Author: Salt Ho <asche34@outlook.com>
;; Created: 17 Oct 2017
;; Version: 1.0
;; Package-Requires: nil
;; Keywords: processes, unix

;;; Commentary:

;; My script to install packages for system (Debian and Debian-based). Since it is not convince
;; to install the softwares (which includes emacs) every time I use new computer or new system.
;; So I write this script to solve this problem and practice writing Emacs lisp for fun
;; due to freetime.

;; About headers in the script, read from here:
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Library-Headers.html#Library-Headers

;; About comments conventions, read from here:
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Comment-Tips.html

;;; Code:

;; This function named call-process is not handy to use
;; (call-process
;;  "python3"
;;  nil
;;  t
;;  nil
;;  "/home/saltb0rn/Software/emacs.d/lisp/install-packages-for-elpy.py")

;; After some searches, I found that shell-command and shell-command are the functions
;; that meet my requirements.
;; (shell-command (concat "echo " (shell-quote-argument (read-passwd "Password? "))
;;		       " | sudo -S apt-get udpate"))
;; (shell-command "python3 /home/saltb0rn/Software/emacs.d/lisp/install-packages-for-elpy.py")

;; (shell-command-to-string (concat "echo " (shell-quote-argument (read-passwd "Password? "))
;;				 " | sudo -S apt-get update"))


(defconst script-path
  (expand-file-name
   "sysconf.py"
   (file-name-directory load-file-name)))

(defun mk-password-getter ()
  ;; (lexical-let ((password nil))
  (let ((password nil))
    (lambda (&optional clean)
      (cond
       (clean (progn
		(setq password nil)
		password))
       (password)
       (t (progn
	    (setq password
		  (read-passwd "Permission Denied. Input password here: "))
	    password))))))

(setf
 (symbol-function 'password-getter)
 (mk-password-getter))

(defmacro sysconf-* (cmdsym)
  `(let* ((symname (symbol-name ',cmdsym))
	  (newsym (intern (concat "sysconf-" symname)))
	  ;; Synchronous Process
	  ;; Do NOT use make-symbol since the newly allocated symbol is uninterned
	  ;; (func (lambda ()
	  ;;	  "Docstring later"
	  ;;	  (interactive)
	  ;;	  (shell-command
	  ;;	   (concat
	  ;;	    python-shell-interpreter
	  ;;	    " "
	  ;;	    script-path
	  ;;	    " "
	  ;;	    "--password "
	  ;;	    (password-getter)
	  ;;	    " "
	  ;;	    symname)
	  ;;	   "*sysconf*")))
	  ;; Asynchronous Process
	  (func (lambda ()
		  "Docstring later"
		  (interactive)
		  (if (process-status "sysconf")
		      nil
		    (progn
		      (start-process
		       "sysconf"
		       "*SYSCONF*"
		       python-shell-interpreter
		       script-path
		       "--password"
		       (password-getter)
		       symname)
		      (set-process-filter (get-process "sysconf")
					  #'(lambda (process output)
					      (with-current-buffer "*SYSCONF*"
						(let ((inhibit-read-only t))
						  (insert output)))
					      (view-buffer (get-buffer "*SYSCONF*")))))))))
     (setf (symbol-function newsym) func)))

;;;###autoload
(sysconf-* init)

;;;###autoload
(sysconf-* pip)

;;;###autoload
(sysconf-* upgrade)

(provide 'sysconf)
;;; sysconf.el ends here

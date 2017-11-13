;;; sysconf.el --- My script to install system packages -*- lexical-binding: t -*-

;; Copyright (C) 2017 Salt Ho

;; Author: Salt Ho <asche34@outlook.com>
;; Created: 17 Oct 2017
;; Version: 1.0
;; Package-Requires: nil
;; Keywords: processes, unix

;;; Commentary:

;; My script to install packages for system (Debian and Debian-based). Since every time
;; I use new computer or new system it is not convince to install the softwares (include emacs).
;; So I write this script to solve the problem and to practice writing Emacs lisp for fun
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

;;(require 'emacs-proxy-ctl) ;; This is script has been adbandoned

(require 'cl)

(defgroup sysconf nil
  "The Utilities To Setup Environment Quickly."
  :version "1.0"
  :prefix "sysconf-"
  :group 'environment
  )

(cl-defun sysconf-join-path (root &rest components)
  "Inspired by os.path.join of Python.

If directory root exists, return the path after joining.
Otherwise, return nil
"
  (cl-labels ((root-validp (root) (file-directory-p root))
	      (join (root components)
		    (if components
			(join
			 (expand-file-name (car components) root)
			 (cdr components))
		      root)))
    (if (not (root-validp root))
	(cl-return-from "sysconf-join-path" root)
      (join root components))))

(defconst sysconf-default-script-path
  (sysconf-join-path
   (file-name-directory load-file-name)
   "sysconf.py")
  "The path of current executable script")

(defcustom sysconf-script-path
  sysconf-default-script-path
  "The path to Python script"
  :type 'string
  :options '(custom-variable)
  :group 'sysconf)

(defcustom sysconf-password-keyname
  "PASSWORD"
  "The name of environment variable which passes `password' to py script"
  :type 'string
  :options '(custom-variable)
  :group 'sysconf)

(defun sysconf-password-getter (&optional clean)
  "Input password if record is nil.

If clean is non-nil, then clean the record."
  (cond
   (clean (setenv sysconf-password-keyname nil))
   (t
    (if (not (getenv sysconf-password-keyname))
	(setenv sysconf-password-keyname (read-passwd "Permission Denied. Input `password' here: "))
      (getenv sysconf-password-keyname)))))

(defun sysconf-clean-password ()
  "Clean the password record."
  (interactive)
  (sysconf-password-getter t))

(defmacro sysconf-* (cmdsym)
  "A fucntion maker to make functions execute the commands of script correspondingly."
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
	  ;;	    sysconf-script-path
	  ;;	    " "
	  ;;	    "--password "
	  ;;	    (sysconf-password-getter)
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
		      (let ((process-connection-type t))
			(sysconf-password-getter)
			(start-process
			 "sysconf"
			 "*SYSCONF*"
			 python-shell-interpreter
			 sysconf-script-path
			 "--passwordkey"
			 sysconf-password-keyname
			 symname))

		      (let ((proc (get-process "sysconf")))
			(set-process-filter proc
					    #'(lambda (process output)
						(with-current-buffer "*SYSCONF*"
						  (let ((inhibit-read-only t))
							(insert output)))
						(view-buffer (get-buffer "*SYSCONF*"))))))))))
     (setf (symbol-function newsym) func)))

;;;###autoload
(sysconf-* init)

;;;###autoload
(sysconf-* pip)

;;;###autoload
(sysconf-* upgrade)

(require 'sysconf-tramp)

(provide 'sysconf)

;; TODO: A practice, writing a mirror mode to control proxy, is necessary. Doing this in emacs-proxy-ctl.el

;;; sysconf.el ends here

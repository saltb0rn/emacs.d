;;; -*- lexical-binding: t -*-
;;; emacs-proxy-ctl.el --- Control network proxy of emacs
;;; Commentary:
;; This script has been abandoned because of that possibility of the way to implement
;; toggle proxy with custom-set-variables is almost zero.
;; Why keep this file? Because it is worth to referring the usage of defgroup and defcustom, also backquote.

;;; code:
(require 'url)

(defgroup econf nil
  "Configuration of Emacs"
  :group 'sysconf)

(defcustom original-url-proxy-services
  nil
  "Save the original value of url-proxy-services"
  :safe #'consp
  :group 'econf)


(defun toggle-proxy ()
  "Toggle whether enable `Network-Proxy' for Emacs."
  (interactive)
  (if url-proxy-services
      (progn
	(custom-set-variables
	 `(original-url-proxy-services ,url-proxy-services t)
	 '(url-proxy-services nil))
	(message "Proxy is disable now"))
    (if original-url-proxy-services
	(progn
	  (custom-set-variables
	   `(url-proxy-services ,original-url-proxy-services))
	  (message "Proxy is enable now"))
      (message "`url-proxy-services' is Not set yet"))))



(provide 'emacs-proxy-ctl)
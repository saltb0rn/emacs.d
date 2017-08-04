;; This file bootstraps the configuration, which is divided into
;; a number of other files.

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Display line number
;; (global-linum-mode)
;; This will hang out when use doc-view-mode to read pdf

;;-----------------------------------------------------------------------------

(require 'init-elpa)

(ensure-package-installed
 'org-plus-contrib
 'use-package)
 ;; 'chinese-pyim-greatdict)
(require 'init-utillities)

(require 'init-elisp-mode)

(require 'init-site-lisp)

(require 'init-evil) ;; vim keys-binding

(require 'init-ycmd) ;; youcompleteme

(require 'init-ecb)

(require 'init-emms)

(require 'init-tabbar)

(require 'init-all-the-icons)

(require 'init-rainbow-delimiters)

;;(require 'init-chinese-pyim)

(require 'init-nyan-mode)

(require 'init-slime)

;;(require 'init-scheme)

(require 'init-web-mode)

(require 'init-ace-window)

;; (require 'init-neotree) ;; file navigator

(require 'init-monokai-theme)

(require 'init-xwidget-browser-mode)

(require 'init-magit)

(require 'custom-env)

(provide 'init)

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

;; (ensure-package-installed
;;  'use-package
;; 'chinese-pyim-greatdict)

(require 'init-utillities)

(require 'init-other-utils)

(require 'init-site-lisp)

(require 'init-mypkgs)

;; (require 'init-evil) ;; vim keys-binding
;; I stop using evil just becase I don't use vim-like keybinding frequently anymore

;; (require 'init-ycmd) ;; youcompleteme as complete backend
;; I pause using ycmd because it conflicts with elpy

;; (require 'init-ecb)  ;; I directly use the builtin cedet insead of ecb, because ecb is too old and too many bugs.

(require 'init-emms)

(require 'init-org)

(require 'init-python)

(require 'init-lisp)

(require 'init-js)

(require 'init-web)

(require 'init-google-translate)

(require 'custom-env)

;; (require 'sysconf "sysconf.el")
(require 'sysconf) ;; Don't need to install the package for debugging during development

(provide 'init)

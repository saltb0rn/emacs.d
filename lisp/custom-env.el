(setq custom-file (expand-file-name "lisp/custom-env.el" user-emacs-directory))

;; set transparency
(set-frame-parameter (selected-frame) 'alpha '(85 85))
(add-to-list 'default-frame-alist '(alpha 85 85))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-default nil)
 '(ecb-options-version "2.50")
 '(geiser-implementations-alist
   (quote
    (((regexp "\\.scm$")
      guile)
     ((regexp "\\.ss$")
      chez)
     ((regexp "\\.rkt$")
      racket)
     ((regexp "\\.scm$")
      chicken)
     ((regexp "\\.release-info$")
      chicken)
     ((regexp "\\.meta$")
      chicken)
     ((regexp "\\.setup$")
      chicken)
     ((regexp "\\.ss$")
      racket)
     ((regexp "\\.def$")
      chez)
     ((regexp "\\.scm$")
      mit)
     ((regexp "\\.pkg$")
      mit)
     ((regexp "\\.scm$")
      chibi)
     ((regexp "\\.sld$")
      chibi))))
 '(inhibit-default-init nil)
 '(python-shell-interpreter "python3")
 '(tramp-default-method "ssh")
 '(inhibit-startup-screen nil)
 '(package-selected-packages
   (quote
    (highlight-indent-guides epc webkit emms fic-mode geiser paredit yaml-mode ace-window slime-company monokai-theme xwidgete org-plus-contrib org-multiple-keymap- company-web web-mode racket-mode ecb magit nyan-mode company-ycmd ycmd slime whitespace-cleanup-mode rainbow-delimiters evil pylint flymake-python-pyflakes flycheck flycheck-ycmd elpy el-get use-package tabbar)))
 '(slime-auto-select-connection (quote always))
 '(slime-auto-start (quote always))
 '(slime-company-completion (quote fuzzy))
 '(web-mode-indent-style 2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'narrow-to-region 'disabled nil)

(provide 'custom-env)

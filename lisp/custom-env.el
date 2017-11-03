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
 '(blink-cursor-mode nil)
 '(coffee-indent-like-python-mode t)
 '(coffee-tab-width 4)
 '(ecb-options-version "2.50")
 '(elpy-rpc-backend "jedi")
 '(elpy-rpc-python-command "python3")
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
 '(inhibit-startup-screen nil)
 '(org-pretty-entities t)
 '(package-selected-packages
   (quote
    (google-translate-default-ui google-translate company-jedi typing-game speed-type slime bison-mode emojify xref-js2 web-mode tabbar rainbow-delimiters org-plus-contrib nyan-mode monokai-theme magit js2-refactor indium highlight-indent-guides geiser flycheck-ycmd fic-mode evil emms elpy ecb company-tern coffee-mode all-the-icons ace-window)))
 '(python-shell-interpreter "python3")
 '(slime-auto-select-connection (quote always))
 '(slime-auto-start (quote always))
 '(slime-company-completion (quote fuzzy))
 '(tramp-default-method "ssh" nil (tramp))
 '(tramp-syntax (quote default) nil (tramp))
 '(url-proxy-services (quote (("http" . "127.0.0.1:8118"))))
 '(web-mode-indent-style 2))

(put 'narrow-to-region 'disabled nil)
(global-set-key (kbd "C-SPC") nil)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t (:background "#FFD700")))))
(setq-default bidi-display-reordering nil)

(provide 'custom-env)

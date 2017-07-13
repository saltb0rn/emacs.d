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
 '(fancy-splash-image (expand-file-name "images/aika.png" user-emacs-directory))
 '(url-proxy-services ("http" . "127.0.0.1:8118"))
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
 '(package-selected-packages
   (quote
    (epc webkit fuck pdf-tool emms chinese-pyim fcitx fic-mode geiser paredit chinese-pyim-wbdict yaml-mode dockerfile-mode ace-window slime-company smiles-mode monokai-theme scheme-complete xwidgete org-plus-contrib org-multiple-keymap- company-web web-mode racket-mode ecb magit nyan-mode ace-pinyin company-ycmd ycmd slime ein-mum\
	 amo ein whitespace-cleanup-mode rainbow-delimiters neotree evil pylint flymake-\
	 python-pyflakes elpy el-get)))
 '(slime-auto-start (quote always))
 '(web-mode-indent-style 2))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'narrow-to-region 'disabled nil)

(setq python-shell-interpreter "python3")

(provide 'custom-env)


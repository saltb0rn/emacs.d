(setq custom-file (expand-file-name "lisp/custom-env.el" user-emacs-directory))

;; remove tool/menu/scroll-bar from emacs
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; change the font for emacs using
;; (set-default-font "Source Code Pro" nil t)
;; (set-face-attribute 'default nil :height 100)

;; display time
(display-time-mode t)

;; display battry info
(display-battery-mode t)

;; use theme
(when window-system
  (require-install 'zenburn-theme)
  (load-theme 'zenburn t))

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
 '(bmkp-last-as-first-bookmark-file "/home/salt/.emacs.d/bookmarks")
 '(coffee-indent-like-python-mode t)
 '(coffee-tab-width 4)
 '(debug-on-quit t)
 '(ecb-options-version "2.50")
 '(elpy-rpc-backend "jedi")
 '(elpy-rpc-python-command "python3")
 '(fic-highlighted-words (quote ("FIXME" "TODO" "BUG" "NOTE" "FIXED")))
 '(inhibit-default-init nil)
 '(inhibit-startup-screen nil)
 '(org-pretty-entities t)
 '(package-selected-packages
   (quote
    (zenburn zenburn-theme geiser markdown-mode+ markdown-preview-mode org2ctex pandoc-mode dockerfile-mode which-key bookmark+ multi-term htmlize nginx-mode yaml-mode i3wm google-translate-default-ui google-translate company-jedi typing-game speed-type slime bison-mode emojify xref-js2 web-mode tabbar rainbow-delimiters org-plus-contrib nyan-mode monokai-theme magit js2-refactor indium highlight-indent-guides flycheck-ycmd fic-mode evil emms elpy company-tern coffee-mode all-the-icons ace-window pyim use-package pkg-info epl flycheck)))
 '(pyim-fuzzy-pinyin-alist
   (quote
    (("en" "eng")
     ("in" "ing")
     ("un" "ong")
     ("z" "zh")
     ("s" "sh")
     ("an" "ang")
     ("on" "ong")
     ("c" "ch"))))
 '(python-shell-interpreter "python3")
 '(slime-auto-select-connection (quote always))
 '(slime-auto-start (quote always))
 '(slime-company-completion (quote fuzzy))
 '(sysconf-tramp-additional-ssh-login-args (quote (("-o" "ServerAliveInterval=60"))))
 '(term-default-bg-color "#000000")
 '(term-default-fg-color "#ddd000")
 '(tramp-default-method "ssh" nil (tramp))
 '(tramp-syntax (quote default) nil (tramp))
 '(mode-line-format
   (quote
    ("%m: "
     "buffer %b, "
     (vc-mode vc-mode)
     " L %l "
     (:eval (list (nyan-create)))
     " "
     mode-line-misc-info
     mode-line-end-spaces
     )))
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

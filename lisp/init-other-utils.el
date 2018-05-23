;; Fix the problem that screen flash when use xwidget-browser-mode that due to evil-mode
(require 'xwidget)
(add-hook 'xwidget-webkit-mode-hook
	  #'(lambda ()
	      (if (require 'evil nil t)
		  (evil-mode 0))
	      (if (require 'nyan nil t)
		  (nyan-mode 0))))

;; Emoji display
(require-install 'emojify)
;;(add-hook 'after-init-hook #'global-emojify-mode)

;; Show the tabbar
(require-install 'tabbar)
(tabbar-mode)

;; Magit as frontend of git
(require-install 'magit)
(global-set-key (kbd "C-x g") 'magit-status)

;; Nyan mode is interesting, show the cat in bottom
(require-install 'nyan-mode)
(nyan-mode)
(nyan-start-animation)
(nyan-toggle-wavy-trail)

;; Some special comments, like TODO
(require-install 'fic-mode)
(require-install 'monokai-theme)

;; Use monokai as theme
(setq ;; foreground and background
 monokai-foreground     "#ABB2BF"
 monokai-background     "#282C34"
 ;; highlights and comments
 monokai-comments       "#F8F8F0"
 monokai-emphasis       "#282C34"
 monokai-highlight      "#FFB269"
 monokai-highlight-alt  "#66D9EF"
 monokai-highlight-line "#1B1D1E"
 monokai-line-number    "#F8F8F0"
 ;; colours
 monokai-blue           "#61AFEF"
 monokai-cyan           "#56B6C2"
 monokai-green          "#98C379"
 monokai-gray           "#3E4451"
 monokai-violet         "#C678DD"
 monokai-red            "#E06C75"
 monokai-orange         "#D19A66"
 monokai-yellow         "#E5C07B")
(setq monokai-user-variable-pitch t)

;; Buffer select
(require-install 'ace-window)
(global-set-key (kbd "<f4>") 'ace-window)

;(require-install 'bookmark+)
(require-install 'which-key)

(provide 'init-other-utils)

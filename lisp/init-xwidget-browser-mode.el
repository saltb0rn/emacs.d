;; Fix the problem that screen flash when use xwidget-browser-mode that due to evil-mode
(require 'xwidget)
(add-hook 'xwidget-webkit-mode-hook
	  #'(lambda ()
	      (if (require 'evil nil t)
		  (evil-mode 0))
	      (if (require 'nyan nil t)
		  (nyan-mode 0))))

(provide 'init-xwidget-browser-mode)

(require-install 'elpy)
(require-install 'flycheck)
(require-install 'fic-mode)
(require-install 'highlight-indentation)
(add-hook 'elpy-mode-hook #'fic-mode)
;;(add-hook 'elpy-mode-hook #'linum-mode)
(add-hook 'elpy-mode-hook #'rainbow-delimiters-mode)
(add-hook 'elpy-mode-hook #'flycheck-mode)
;; It will be slow while you typing if the buffer size if lagger than the elpy-rpc-ignored-buffer-size
;; So we need to turn off the highlight-inentation-mode
;; Elpy own it hightlight-indentation
(add-hook 'elpy-mode-hook
	  #'(lambda ()
	      (when (> (buffer-size) elpy-rpc-ignored-buffer-size)
		(progn
		    (highlight-indentation-mode 0)
		    (message "Turn the highlight-indentation-mode off")))))
(custom-set-variables
 '(python-shell-interpreter "python3")
 '(elpy-rpc-backend "jedi")
 '(elpy-rpc-python-command "python3")
 )
(elpy-enable)

(provide 'init-python)

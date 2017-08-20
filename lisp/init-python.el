(require-install 'elpy)
(require-install 'flycheck)
(require-install 'fic-mode)
(require-install 'highlight-indentation)

(add-hook 'elpy-mode-hook #'fic-mode)
(add-hook 'elpy-mode-hook #'linum-mode)
(add-hook 'elpy-mode-hook #'rainbow-delimiters-mode)
(add-hook 'elpy-mode-hook #'flycheck-mode)
(add-hook 'elpy-mode-hook #'highlight-indentation-mode)
(custom-set-variables
 '(python-shell-interpreter "python3"))

(elpy-enable)

(provide 'init-python)

(require-install 'ycmd)
(require-install 'company-ycmd)
(require-install 'flycheck-ycmd)
(require-install 'fic-mode)

(add-hook 'after-init-hook #'global-ycmd-mode)
(set-variable 'ycmd-server-command
			  '("python3" "/home/saltb0rn/Software/ycmd/ycmd"))

;; complete at point ----------------------------------------------------------
(defun ycmd-setup-completion-at-point-function ()
   "Setup `completion-at-point-functions' for `ycmd-mode'."
   (add-hook 'completion-at-point-functions
			 #'ycmd-complete-at-point nil :local))

(add-hook 'ycmd-mode #'ycmd-setup-completion-at-point-function)

(add-hook 'company-ycmd 'ycmd-mode)

(add-hook 'ycmd-file-parse-result-hook 'flycheck-ycmd--cache-parse-results)
(add-to-list 'flycheck-checkers 'ycmd)

;; (setq flycheck-indication-mode nil)
(when (not (display-graphic-p))
  (setq flycheck-indication-mode nil))

;; (add-hook 'ycmd-mode-hook 'ycmd-eldoc-setup)
(add-hook 'ycmd-mode-hook 'company-ycmd-setup)
(add-hook 'ycmd-mode-hook 'flycheck-ycmd-setup)
(add-hook 'ycmd-mode-hook 'fic-mode)
(add-hook 'ycmd-mode-hook #'rainbow-delimiters-mode)
(add-hook 'ycmd-mode-hook #'linum-mode)

;; keys binding
(global-company-mode)
(global-flycheck-mode)
(ycmd-toggle-force-semantic-completion)
;; (add-hook 'global-company-mode 'global-flycheck-mode)

(provide 'init-ycmd)

;; (add-hook 'emacs-lisp-mode-hook #'lisp-interaction-mode)
;; This will meet the max nested depth
;; (assoc "\\.el\\'" auto-mode-alist)
;; (assq "\\.el\\'" auto-mode-alist)
;; assq is used for alist whoes keys are symbols, use assoc instead if key is string
;; rainbow-delimiters-mode
;; fic-mode
;; ARE required
(setcdr
 (assoc "\\.el\\'" auto-mode-alist)
 'lisp-interaction-mode)

(add-hook 'lisp-interaction-mode-hook #'rainbow-delimiters-mode)
(add-hook 'lisp-interaction-mode-hook #'linum-mode)
(add-hook 'lisp-interaction #'fic-mode)

(provide 'init-elisp-mode)

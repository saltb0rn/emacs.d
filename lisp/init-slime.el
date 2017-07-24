(require-install 'slime)
(require-install 'slime-company)

(setq inferior-lisp-program "/usr/bin/sbcl")
(setq slime-contribs '(slime-fancy))
;; M-x customize-group [ENT] slime
;; customize slime-auto-select-connection
(custom-set-variables
 '(slime-auto-start 'always)
 '(slime-auto-select-connection 'always))
;; use (add-hook 'lisp-mode-hook #'slime-mode) instead

(add-hook 'slime-mode-hook #'rainbow-delimiters-mode)
(add-hook 'slime-mode-hook #'prettify-symbols-mode)
(add-hook 'slime-mode-hook #'linum-mode)
;;(add-hook 'lisp-mode-hook #'slime-mode)

(provide 'init-slime)
;; TODO: Try to collect all kind of lisp (scheme ,emacs lisp and common-lisp) in lisp-mode

;; This file is not about the package lisp for emacs.d, just about configuration for writing lisp.
(require-install 'highlight-indentation)
;; For elisp
(setcdr (assoc "\\.el\\'" auto-mode-alist) 'lisp-interaction-mode)
(add-hook 'lisp-interaction-mode-hook #'rainbow-delimiters-mode)
(add-hook 'lisp-interaction-mode-hook #'linum-mode)
(add-hook 'lisp-interaction-mode-hook #'highlight-indentation-mode)
(add-hook 'lisp-interaction #'fic-mode)

;; For common lisp
(require-install 'slime)
;;(require-install 'slime-company)
(setq inferior-lisp-program "/usr/bin/sbcl")
(setq slime-contribs '(slime-fancy))
;; Slime-company does not work for me anymore, so I just use slime-complete-symbol to complete
;; The shortcut of slime-complete-symbol is M-TAB, just change it if it conflicts with your any other shortcuts. I use i3 as my window manager, so this just works for me.

;; M-x customize-group [ENT] slime
;; customize slime-auto-select-connection
(custom-set-variables
 '(slime-auto-start 'always)
 '(slime-auto-select-connection 'always))
;; use (add-hook 'lisp-mode-hook #'slime-mode) instead
(add-hook 'slime-mode-hook #'rainbow-delimiters-mode)
(add-hook 'slime-mode-hook #'prettify-symbols-mode)
(add-hook 'slime-mode-hook #'linum-mode)
(add-hook 'slime-mode-hook #'highlight-indentation-mode)
(add-hook 'slime-mode-hook #'fic-mode)
;; (add-hook 'lisp-mode-hook #'slime-mode)

;; For scheme and its dialect
(require-install 'geiser)

(provide 'init-lisp)

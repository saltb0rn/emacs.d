(require 'eglot)
(require 'web-mode)

;; https://genehack.blog/2020/08/web-mode-eglot-vetur-vue-js-happy
(define-derived-mode genehack-vue-mode web-mode "ghVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . genehack-vue-mode))
(add-hook 'genehack-vue-mode-hook #'eglot-ensure)
(add-to-list 'eglot-server-programs '(genehack-vue-mode "vls"))

(provide 'genehack-vue)

(require 'eglot)
(require 'web-mode)

(defgroup genehack-vue-mode nil
  "Major mode for editing Vue files"
  :group 'languages
  :prefix "genehack-vue-")

(defcustom genehack-vue-mode-script-indent-offset 2
  "<script> indentation level"
  :type 'integer
  :safe #'integerp
  :group 'genehack-vue-mode)

(defcustom genehack-vue-mode-script-padding 0
  "<script> left padding"
  :type 'integer
  :safe #'integerp
  :group 'genehack-vue-mode)

(defcustom genehack-vue-mode-template-indent-offset 2
  "HTML element indentation level"
  :type 'integer
  :safe #'integerp
  :group 'genehack-vue-mode)

(defcustom genehack-vue-mode-style-indent-offset 2
  "<style> indentation level"
  :type 'integer
  :safe #'integerp
  :group 'genehack-vue-mode)

(defcustom genehack-vue-mode-style-padding 0
  "<style> left padding"
  :type 'integer
  :safe #'integerp
  :group 'genehack-vue-mode)

;; https://genehack.blog/2020/08/web-mode-eglot-vetur-vue-js-happy
(define-derived-mode genehack-vue-mode web-mode "ghVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . genehack-vue-mode))
(add-hook 'genehack-vue-mode-hook #'(lambda ()
                                      (setq-local
                                       web-mode-code-indent-offset genehack-vue-mode-script-indent-offset
                                       web-mode-script-padding genehack-vue-mode-script-padding
                                       web-mode-markup-indent-offset genehack-vue-mode-template-indent-offset
                                       web-mode-css-indent-offset genehack-vue-mode-style-indent-offset
                                       web-mode-style-padding genehack-vue-mode-style-padding)))
(add-hook 'genehack-vue-mode-hook #'eglot-ensure)
(add-to-list 'eglot-server-programs '(genehack-vue-mode "vls"))

(provide 'genehack-vue)

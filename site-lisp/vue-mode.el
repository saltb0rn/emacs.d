(require 'eglot)
(require 'web-mode)

(defgroup vue-mode nil
  "Major mode for editing Vue files"
  :group 'languages
  :prefix "vue-")

(defcustom vue-mode-script-indent-offset 2
  "<script> indentation level"
  :type 'integer
  :safe #'integerp
  :group 'vue-mode)

(defcustom vue-mode-script-padding 0
  "<script> left padding"
  :type 'integer
  :safe #'integerp
  :group 'vue-mode)

(defcustom vue-mode-template-indent-offset 2
  "HTML element indentation level"
  :type 'integer
  :safe #'integerp
  :group 'vue-mode)

(defcustom vue-mode-style-indent-offset 2
  "<style> indentation level"
  :type 'integer
  :safe #'integerp
  :group 'vue-mode)

(defcustom vue-mode-style-padding 0
  "<style> left padding"
  :type 'integer
  :safe #'integerp
  :group 'vue-mode)

;; https://github.com/joaotavora/eglot/discussions/1395
;; https://genehack.blog/2020/08/web-mode-eglot-vetur-vue-js-happy

(define-derived-mode vue-mode web-mode "ghVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")

(add-to-list 'auto-mode-alist '("\\.vue\\'" . vue-mode))

(add-hook 'vue-mode-hook (lambda ()
                                      ;; (setq-local
                                      ;;  web-mode-code-indent-offset vue-mode-script-indent-offset
                                      ;;  web-mode-script-padding vue-mode-script-padding
                                      ;;  web-mode-markup-indent-offset vue-mode-template-indent-offset
                                      ;;  web-mode-css-indent-offset vue-mode-style-indent-offset
                                      ;;  web-mode-style-padding vue-mode-style-padding)
                                      (eglot-ensure)
                                      ))

;; (add-to-list 'eglot-server-programs
;;              `(vue-mode . ("typescript-language-server" "--stdio"
;;                                     :initializationOptions
;;                                     (:plugins [(:name "@vue/typescript-plugin"
;;                                                 :location ,(string-trim-right (shell-command-to-string "npm list --global --parseable @vue/typescript-plugin | head -n1"))
;;                                                 :languages ["vue"])])))
;;              )

(add-to-list 'eglot-server-programs
             `(vue-mode . ("typescript-language-server" "--stdio" :initializationOptions
                           (:plugins [(:name "@vue/typescript-plugin" :location ,(string-trim-right (shell-command-to-string "npm list --global --parseable @vue/typescript-plugin | head -n1")) :languages ["vue"])]))))

(provide 'vue-mode)

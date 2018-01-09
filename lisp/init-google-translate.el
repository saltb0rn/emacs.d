(require-install 'google-translate)
;; (require 'google-translate-default-ui)
(require 'google-translate-smooth-ui)
;; (require 'google-translate-default-ui)
(global-set-key "\C-ct" 'google-translate-smooth-translate)

(global-set-key "\C-cT" 'google-translate-query-translate)

(setq google-translate-translation-directions-alist
      '(("en" . "zh-CN") ("zh-CN" . "en")))

(provide 'init-google-translate)


(require-install 'web-mode)

(if (null (assoc "\\.html\\?'" auto-mode-alist))
    (add-to-list 'auto-mode-alist (cons "\\.html?\\'" 'web-mode)))

(add-to-list 'auto-mode-alist (cons "\\.tmpl\\'" 'web-mode))
;; for djagno template
;; I prefer to this methodology
;; (add-to-list 'auto-mode-alist (cons "\\.djhtml\\'" 'web-mode))
(setq web-mode-engines-alist
      '(("django" . "\\.djhtml\\'")
	("mako" . "\\.tmpl\\'")))

;; Auto pairs

;;(setq auto-mode-alist
;;      (append '(("\\.html\\'" 'web-mode)) auto-mode-alist))
(setq web-mode-enable-auto-closing t)
(setq web-mode-enable-auto-pairing t)
(setq web-mode-enable-engine-detection t)

(add-hook 'web-mode-hook 'linum-mode)

(provide 'init-web)

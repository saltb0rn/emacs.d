(require-install 'neotree)

(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(global-set-key [f8] 'neotree-toggle)
(global-set-key [f9] 'neotree-enter)

(provide 'init-neotree)

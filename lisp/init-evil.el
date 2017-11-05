(require-install 'evil)

(if (yes-or-no-p (format "Do U want to enable evil mode?"))
    (evil-mode 1))

(global-set-key (kbd "C-x v") #'evil-mode)

(provide 'init-evil)

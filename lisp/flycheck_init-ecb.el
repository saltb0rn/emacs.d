(require-install 'ecb)

(defun display-buffer-at-bottom--display-buffer-at-bottom-around (orig-func &rest args)
  "Bugfix for ECB: cannot use display-buffer-at-bottom, call display-buffer-use-some-windows instead in ECB frame."
  (if (and ecb-minor-mode (equal (selected-frame) ecb-frame))
      (apply 'display-buffer-use-some-window args)
    (apply orig-func args)))

(advice-add 'display-buffer-at-bottom :around #'display-buffer-at-bottom--display-buffer-at-bottom-around)
;; the solution from https://github.com/ecb-home/ecbissues/10

(provide 'init-ecb)

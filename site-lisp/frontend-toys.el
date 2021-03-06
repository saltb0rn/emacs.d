;;; Code:

(defun glitch-animation-keyframes-generator-translate (animation-name &optional height)
  (interactive (let ((anim-name (read-string "Please input the animation name: " nil))
                     (height (read-number "Height of Element (50px by default): " 50)))
                 (list anim-name height)))
  (let ((times 20)
        numpairs)
    (while (> times 0)
      (let* ((r1 (random* 1.0))
             (r2 (random* 1.0))
             ;; (rMax (max r1 r2))
             ;; (rMin (min r1 r2))
             (rMax r2)
             (rMin r1)
             (offset (random* 5.0)))
        (push
         (format "    %d%% {\n        clip: rect(%dpx, auto, %dpx, 0);\n        transform: translateX(%.1fpx)\n    }"
                 (* times 5) (* rMin height) (* rMax height)
                 (* (if (> (% (floor (* (random* 1.0) 100)) 2) 0) 1 -1) offset)
                 )
         numpairs)
        (setq times (- times 1))))
    (insert (format "\n@keyframes %s {\n%s\n}" animation-name (string-join numpairs "\n")))))

(defun glitch-animation-keyframes-generator-skew (animation-name &optional height)
  (interactive (let ((anim-name (read-string "Please input the animation name: " nil))
                     (height (read-number "Height of Element (50px by default): " 50)))
                 (list anim-name height)))
  (let ((times 20)
        numpairs)
    (while (> times 0)
      (let* ((r1 (random* 1.0))
             (r2 (random* 1.0))
             ;; (rMax (max r1 r2))
             ;; (rMin (min r1 r2))
             (rMax r2)
             (rMin r1)
             (deg (random* 1.0)))
        (push
         (format "    %d%% {\n        clip: rect(%dpx, auto, %dpx, 0);\n        transform: skew(%.2fdeg)\n    }"
                 (* times 5) (* rMin 50) (* rMax 50)
                 (* (if (> (% (floor (* (random* 1.0) 100)) 2) 0) 1 -1) deg)
                 )
         numpairs)
        (setq times (- times 1))))
    (insert (format "\n@keyframes %s {\n%s\n}" animation-name (string-join numpairs "\n")))))

(provide 'frontend-toys)

;;; frontend-toys.el ends here

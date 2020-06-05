;; (defun geotrans-matrix-2d (coordinate a b c d e f)
;;   (let ((x (car coordinate))
;;         (y (cdr coordinate)))
;;     (cons
;;      (+ (* a x) (* b y) c)
;;      (+ (* d x) (* e y) f))))

(defun geotrans-rotate-2d (coordinate degrees)
  "equals to
(let ((radians (degrees-to-radians degree)))
  (geotrans-matrix-2d
   coordinate
   (cos radians)
   (- (sin radians))
   0
   (sin radians)
   (cos radians)
   0))
"

  (let ((x (car coordinate))
        (y (car coordinate))
        (radians (degrees-to-radians degrees)))
    (cons
     (+ (* (cos radians) x) (* -1 (sin radians) y))
     (+ (* (sin radians) x) (* (cos radians) y)))))

(defun geotrans-translate-2d (coordinate dx dy)
  (let ((x (car coordinate))
        (y (cdr coordinate)))
    (cons
     (+ x dx)
     (+ y dy))))

(defun geotrans-scale-2d (coordinate rx ry)
  (let ((x (car coordinate))
        (y (cdr coordinate)))
    (cons
     (* rx x)
     (* ry y))))

(provide 'geotrans)

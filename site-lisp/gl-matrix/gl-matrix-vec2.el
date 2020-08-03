;;; Code:

(defun gl-matrix-vec2-add (vec1 vec2)
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* 1.0 (elt vec2 1))))
    (list
     (+ vec1-x vec2-x)
     (+ vec1-y vec2-y))))

(defun gl-matrix-vec2-subtract (vec1 vec2)
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* 1.0 (elt vec2 1))))
    (list
     (- vec1-x vec2-x)
     (- vec1-y vec2-y))))

(defun gl-matrix-vec2-length (vec1)
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1))))
    (sqrt (+
           (* vec1-x vec1-x)
           (* vec1-y vec1-y)))))

(defun gl-matrix-vec2-normalize (vec1)
  (let* ((vec1-x (* 1.0 (elt vec1 0)))
         (vec1-y (* 1.0 (elt vec1 1)))
         (len (sqrt
               (+
                (* vec1-x vec1-x)
                (* vec1-y vec1-y)))))
    (when (> len 0)
      (setq len (/ 1 len)))
    (list
     (* vec1-x len)
     (* vec1-y len))))

(defun gl-matrix-vec2-cross (vec1 vec2)
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* 1.0 (elt vec2 1))))
    (list
     0.0
     0.0
     (- (* vec1-x vec2-y) (* vec1-y vec2-x)))))

(defun gl-matrix-vec2-dot (vec1 vec2)
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* 1.0 (elt vec2 1))))
    (+ (* vec1-x vec2-x)
       (* vec1-y vec2-y))))

(provide 'gl-matrix-vec2)

;;; gl-matrix-vec2.el ends here

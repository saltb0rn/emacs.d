;;; Code

(defun gl-matrix-vec3-add (vec1 vec2)
  "Adds two 3-dimension vector.

Return a new 3-dimension vector."
  (let ((vec1-x (elt vec1 0))
        (vec1-y (elt vec1 1))
        (vec1-z (elt vec1 2))
        (vec2-x (elt vec2 0))
        (vec2-y (elt vec2 1))
        (vec2-z (elt vec2 2)))
    (list
     (+ vec1-x vec2-x)
     (+ vec1-y vec2-y)
     (+ vec1-z vec2-z))))

(defun gl-matrix-vec3-subtract (vec1 vec2)
  (let ((vec1-x (elt vec1 0))
        (vec1-y (elt vec1 1))
        (vec1-z (elt vec1 2))
        (vec2-x (elt vec2 0))
        (vec2-y (elt vec2 1))
        (vec2-z (elt vec2 2)))
    (list
     (- vec1-x vec2-x)
     (- vec1-y vec2-y)
     (- vec1-z vec2-z))))

(defun gl-matrix-vec3-length (vec1)
  (let ((vec1-x (elt vec1 0))
        (vec1-y (elt vec1 1))
        (vec1-z (elt vec1 2)))
    (sqrt (+
           (* vec1-x vec1-x)
           (* vec1-y vec1-y)
           (* vec1-z vec1-z)))))

(defun gl-matrix-vec3-normalize (vec1)
  (let* ((vec1-x (elt vec1 0))
         (vec1-y (elt vec1 1))
         (vec1-z (elt vec1 2))
         (len (sqrt
               (+
                (* vec1-x vec1-x)
                (* vec1-y vec1-y)
                (* vec1-z vec1-z)))))
    (when (> len 0)
      (setq len (/ 1 len)))
    (list
     (* vec1-x len)
     (* vec1-y len)
     (* vec1-z len))))

(defun gl-matrix-vec3-cross (vec1 vec2)
  (let ((vec1-x (elt vec1 0))
        (vec1-y (elt vec1 1))
        (vec1-z (elt vec1 2))
        (vec2-x (elt vec2 0))
        (vec2-y (elt vec2 1))
        (vec2-z (elt vec2 2)))
    (list
     (- (* vec1-y vec2-z) (* vec1-z vec2-y))
     (- (* vec1-z vec2-x) (* vec1-x vec2-z))
     (- (* vec1-x vec2-y) (* vec1-y vec2-x)))))

(defun gl-matrix-vec3-dot (vec1 vec2)
  (let ((vec1-x (elt vec1 0))
        (vec1-y (elt vec1 1))
        (vec1-z (elt vec1 2))
        (vec2-x (elt vec2 0))
        (vec2-y (elt vec2 1))
        (vec2-z (elt vec2 2)))
    (+ (* vec1-x vec2-x)
       (* vec1-y vec2-y)
       (* vec1-z vec2-z))))

(provide 'gl-matrix-vec3)

;;; gl-matrix-vec3.el ends here

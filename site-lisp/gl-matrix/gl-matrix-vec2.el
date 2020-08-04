;;; Code:

(defun gl-matrix-vec2-add (vec1 vec2)
  "Adds two 2-dimension vectors."
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* 1.0 (elt vec2 1))))
    (list
     (+ vec1-x vec2-x)
     (+ vec1-y vec2-y))))

(defun gl-matrix-vec2-subtract (vec1 vec2)
  "Subtracts two 2-dimension vectors."
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* 1.0 (elt vec2 1))))
    (list
     (- vec1-x vec2-x)
     (- vec1-y vec2-y))))

(defun gl-matrix-vec2-length (vec1)
  "Calculates length/magnitudes of the 2 dimensional vector."
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1))))
    (sqrt (+
           (* vec1-x vec1-x)
           (* vec1-y vec1-y)))))

(defun gl-matrix-vec2-normalize (vec1)
  "Get the unit vector of the 2 dimensional vector."
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
  "Cross product of two 2-dimension vectors.

Return a 3 dimensional vector, the normal vector."
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* 1.0 (elt vec2 1))))
    (list
     0.0
     0.0
     (- (* vec1-x vec2-y) (* vec1-y vec2-x)))))

(defun gl-matrix-vec2-dot (vec1 vec2)
  "Dot product of two 2-dimension vectors"
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* 1.0 (elt vec2 1))))
    (+ (* vec1-x vec2-x)
       (* vec1-y vec2-y))))

(defun gl-matrix-vec2-exact-equals (vec1 vec2)
  "Determines if two 2-dimension vectors have exactly
the same element in the same position."
  )

(defun gl-matrix-vec2-equals (vec1 vec2)
  "Determines if two 2-dimension vectors have approximately
the same elements in the same position.

More details about this algorithm from: https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html."
  )

(defun gl-matrix-vec2-lerp (vec1 vec2 ip-amount)
  "Performs a linear interpolation between two 2-dimension vectors.

More details about the linear interpolation from: https://theeducationlife.com/interpolation-formula/


`IP-AMOUNT' is interpolation amount, in the range [0-1]."
  (let ((vec1-x (* 1.0 (elt vec1 0)))
        (vec1-y (* 1.0 (elt vec1 1)))
        (vec2-x (* 1.0 (elt vec2 0)))
        (vec2-y (* .10 (elt vec2 1))))
    (list
     (+ vec1-x (* ip-amount (- vec2-x vec1-x)))
     (+ vec1-y (* ip-amount (- vec2-y vec1-y))))))

(defun gl-matrix-vec2-angle (vec1 vec2)
  "Calculates angle between two 2-dimension vectors by their dot product."
  (let* ((vec1-x (* 1.0 (elt vec1 0)))
         (vec1-y (* 1.0 (elt vec1 1)))
         (vec2-x (* 1.0 (elt vec2 0)))
         (vec2-y (* 1.0 (elt vec2 1)))
         (mag1 (sqrt (+ (* vec1-x vec1-x) (* vec1-y vec1-y))))
         (mag2 (sqrt (+ (* vec2-x vec2-x) (* vec2-y vec2-y))))
         (mag (* mag1 mag2))
         (cosine
          (and mag (/ (+ (* vec1-x vec2-x) (* vec1-y vec2-y)) mag))))
    ;; cosine should be clamps between [-1,1],
    ;; however, the cosine of vectors like '(10 7) '(1 3) is out of the range.
    (acos (min (max cosine -1.0) 1.0))))

(provide 'gl-matrix-vec2)

;;; gl-matrix-vec2.el ends here

(ert-deftest gl-matrix-vec2-add-spec ()
  "Two 2-dimension vectors addition"
  (let ((vec1 '(1 2))
        (vec2 '(4 5))
        (result '(5.0 7.0)))
    (should (equal (gl-matrix-vec2-add vec1 vec2) result))))

(ert-deftest gl-matrix-vec2-substract-spec ()
  "Two 2-dimension vectors substraction"
  (let ((vec1 '(1 2))
        (vec2 '(4 5))
        (result '(-3.0 -3.0)))
    (should (equal (gl-matrix-vec2-subtract vec1 vec2) result))))

(ert-deftest gl-matrix-vec2-length-spec ()
  "Length of the 2-dimension vector"
  (let ((vec1 '(1 1))
        (result (sqrt 2)))
    (should (equal (gl-matrix-vec2-length vec1) result))))

(ert-deftest gl-matrix-vec2-normalize-spec ()
  "Normalize the 2-dimension vector"
  (let ((vec1 '(1 1))
        (result `(,(/ 1 (sqrt 2))
                  ,(/ 1 (sqrt 2)))))
    (should (equal (gl-matrix-vec2-normalize vec1) result))))

(ert-deftest gl-matrix-vec2-dot-spec ()
  "Dot product of two 2-dimension vectors"
  (let ((vec1 '(1 2))
        (vec2 '(4 5))
        (result 14.0))
    (should (equal (gl-matrix-vec2-dot vec1 vec2) result))))

(ert-deftest gl-matrix-vec2-cross-spec ()
  "Cross product of two 2-dimension vectors"
  (let ((vec1 '(1 3))
        (vec2 '(2 1))
        (result '(0.0 0.0 -5.0)))
    (should (equal (gl-matrix-vec2-cross vec1 vec2) result))))

(ert-deftest gl-matrix-vec2-angle-spec ()
  "Angle between two 2-dimension vectors"
  (let ((vec1 '(1 0))
        (vec2 '(0 1))
        (result (degrees-to-radians 90)))
    (should (equal (gl-matrix-vec2-angle vec1 vec2) result))))

(ert-deftest gl-matrix-vec2-distance-spec ()
  "Euclidian distance between two 2-dimension vectors"
  (let ((vec1 '(1 3))
        (vec2 '(2 1))
        (result (sqrt 5)))
    (should (and (equal (gl-matrix-vec2-distance vec1 vec2) result)
                 (equal (gl-matrix-vec2-distance vec2 vec1) result)))))

(ert-deftest gl-matrix-vec2-lerp-spec ()
  "Get the interpolation value between two 2-dimension vectors"
  (let ((vec1 '(1 3))
        (vec2 '(2 1))
        (t1 0.8)
        (t2 0.2)
        (result '(1.8 1.4)))
    (should (and (equal (gl-matrix-vec2-lerp vec1 vec2 t1) result)
                 (equal (gl-matrix-vec2-lerp vec2 vec1 t2) result)))))

(ert-deftest gl-matrix-vec2-negate-spec ()
  "Negates the components of the 2-dimension vector"
  (let ((vec1 '(1 3))
        (result '(-1.0 -3.0)))
    (should (equal (gl-matrix-vec2-negate vec1) result))))

(ert-deftest gl-matrix-vec2-scale-spec ()
  "Scales the 2-dimension vector"
  (let ((vec1 '(1 2))
        (ratio 2)
        (result '(2.0 4.0)))
    (should (equal (gl-matrix-vec2-scale vec1 ratio) result))))

(ert-deftest gl-matrix-vec2-multiply-spec ()
  "Multiplication of two 2-dimension vectors"
  (let ((vec1 '(1 2))
        (vec2 '(2 1))
        (result '(2.0 2.0)))
    (should (equal (gl-matrix-vec2-multiply vec1 vec2) result))))

(ert-deftest gl-matrix-vec2-divide-spec ()
  "Division between two 2-dimension vectors"
  (let ((vec1 '(1 2))
        (vec2 '(2 1))
        (result '(0.5 2.0)))
    (should (equal (gl-matrix-vec2-divide vec1 vec2) result))))

(ert-deftest gl-matrix-vec2-inverse-spec ()
  "Inverse the 2-dimension vectors"
  (let ((vec1 '(1 2))
        (result '(1.0 0.5)))
    (should (equal (gl-matrix-vec2-inverse vec1) result))))

(ert-deftest gl-matrix-vec2-equals-spec ())

(ert-deftest gl-matrix-vec2-exact-equals-spec ())

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

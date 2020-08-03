(ert-deftest gl-matrix-vec3-add-spec ()
  "Two 3-dimension vectors addition"
  (let ((vec1 '(1 2 3))
        (vec2 '(4 5 6))
        (result '(5 7 9)))
    (should (equal (gl-matrix-vec3-add vec1 vec2) result))))

(ert-deftest gl-matrix-vec3-substract-spec ()
  "Two 3-dimension vectors substraction"
  (let ((vec1 '(1 2 3))
        (vec2 '(4 5 6))
        (result '(-3 -3 -3)))
    (should (equal (gl-matrix-vec3-subtract vec1 vec2) result))))

(ert-deftest gl-matrix-vec3-length-spec ()
  "Length of the 3-dimension vector"
  (let ((vec1 '(1 1 1))
        (result (sqrt 3)))
    (should (equal (gl-matrix-vec3-length vec1) result))))

(ert-deftest gl-matrix-vec3-normalize-spec ()
  "Normalized the 3-dimension vector"
  (let ((vec1 '(1 1 1))
        (result `(,(/ 1 (sqrt 3))
                  ,(/ 1 (sqrt 3))
                  ,(/ 1 (sqrt 3)))))
    (should (equal (gl-matrix-vec3-normalize vec1) result))))

(ert-deftest gl-matrix-vec3-dot-spec ()
  "Dot product of two 3-dimension vectors"
  (let ((vec1 '(1 2 3))
        (vec2 '(4 5 6))
        (result 32))
    (should (equal (gl-matrix-vec3-dot vec1 vec2) result))))

(ert-deftest gl-matrix-vec3-cross-spec ()
  "Cross product of two 3-dimension vectors"
  (let ((vec1 '(1 0 0))
        (vec2 '(0 1 0))
        (result '(0 0 1)))
    (should (equal (gl-matrix-vec3-cross vec1 vec2) result))))

(ert-deftest gl-matrix-vec4-add-spec ()
  "Two 4-dimension vectors addition"
  (let ((vec1 '(1 2 3 4))
        (vec2 '(4 5 6 7))
        (result '(5.0 7.0 9.0 11.0)))
    (should (equal (gl-matrix-vec4-add vec1 vec2) result))))

(ert-deftest gl-matrix-vec4-substract-spec ()
  "Two 4-dimension vectors substraction"
  (let ((vec1 '(1 2 3 4))
        (vec2 '(4 5 6 7))
        (result '(-3.0 -3.0 -3.0 -3.0)))
    (should (equal (gl-matrix-vec4-subtract vec1 vec2) result))))

(ert-deftest gl-matrix-vec4-length-spec ()
  "Length of the 4-dimension vector"
  (let ((vec1 '(1 1 1 1))
        (result 2.0))
    (should (equal (gl-matrix-vec4-length vec1) result))))

(ert-deftest gl-matrix-vec4-normalize-spec ()
  "Normalize the 4-dimension vector"
  (let ((vec1 '(1 1 1 1))
        (result '(0.5 0.5 0.5 0.5)))
    (should (equal (gl-matrix-vec4-normalize vec1) result))))

(ert-deftest gl-matrix-vec4-dot-spec ()
  "Dot product of two 4-dimension vectors"
  (let ((vec1 '(1 2 3 4))
        (vec2 '(4 5 6 7))
        (result 60.0))
    (should (equal (gl-matrix-vec4-dot vec1 vec2) result))))

(ert-deftest gl-matrix-vec4-cross-spec ()
  "Cross product of three 4-dimension vectors"
  (let ((vec1 '(1 0 0 1))
        (vec2 '(0 1 0 1))
        (vec3 '(0 0 1 1))
        (result '(1.0 1.0 1.0 -1.0)))
    (should (equal (gl-matrix-vec4-cross vec1 vec2 vec3) result))))

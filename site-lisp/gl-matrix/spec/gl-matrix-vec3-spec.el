(ert-deftest gl-matrix-vec3-add-spec ()
  "3-dimension vector addition"
  (let ((vec1 '(1 2 3))
        (vec2 '(4 5 6))
        (result '(5 7 9)))
    (should (equal (gl-matrix-vec3-add vec1 vec2) result))))

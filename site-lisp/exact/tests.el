(ert-deftest exact-float-to-fraction ())

(ert-deftest exact-fraction-to-float ())

(ert-deftest exact-equal-2-fractions-spec ())

(ert-deftest exact-equal-fraction-and-nonfraction-spec ())

(ert-deftest exact-equal-2nonfraction-spec ())

(ert-deftest exact-add-2-fractions-spec ()
  (let* ((num1 (exact-fraction-create 10 2))
         (num2 (exact-fraction-create 4 3))
         (result (exact-fraction-create 19 3))
         (sum (exact-fraction-add-2 num1 num2)))
    (should
     (and (equal (exact-fraction-numerator sum) (exact-fraction-numerator result))
          (equal (exact-fraction-denominator sum) (exact-fraction-denominator sum))))))

(ert-deftest exact-add-fraction-and-nonfraction-spec ())

(ert-deftest exact-add-2-nonfractions-spec ())

(ert-deftest exact-substract-2-fractions-spec ())

(ert-deftest exact-substract-fraction-and-nonfraction-spec ())

(ert-deftest exact-substract-2-nonfractions-spec ())

(ert-deftest exact-multiply-2-fractions-spec ())

(ert-deftest exact-multiply-fraction-and-nonfraction-spec ())

(ert-deftest exact-multiply-2-nonfractions-spec ())

(ert-deftest exact-divide-2-fractions-spec ())

(ert-deftest exact-divide-fraction-and-nonfraction-spec ())

(ert-deftest exact-divide-2-nonfractions-spec ())

;;; -*- lexical-binding: t; -*-
;;; Commentray:
;;;   Inspired by https://github.com/python/cpython/blob/3.8/Lib/fractions.py

;;; Code:

(eval-and-compile
  (require 'cl-lib))

(cl-defstruct
    (exact-fraction
     (:constructor nil)
     (:constructor exact-fraction--create
                   (numerator &optional (denominator 1) (ef-gcd 1))))
  numerator denominator ef-gcd)

(defun exact-float-to-fraction (float &optional precision)
  "https://stackoverflow.com/questions/95727/how-to-convert-floats-to-human-readable-fractions"
  (let* ((precision (or precision 1000000000))
         (floating-part (- float (floor float)))
         (ef-gcd (gcd (round (* floating-part precision)) precision))
         (denominator (/ precision ef-gcd))
         (numerator (/ (round (* floating-part precision)) ef-gcd)))
    (list numerator denominator)))

(defsubst exact-fraction--from-number (num)
  (unless (numberp num)
    (error "exact-number-to-fraction: Argument must be a number"))
  (cond ((integerp num) (exact-fraction--create num 1))
        ((floatp num) (exact-float-to-fraction num))
        (nil ((error "exact-number-to-fraction: Argument must be a number")))))

(defsubst exact-fraction--simplify (num)
  "TODO: Deals with floating-point number."
  (if (exact-fraction-p num)
      (let* ((n
              (exact-fraction--simplify (exact-fraction-numerator num)))
             (d
              (exact-fraction--simplify (exact-fraction-denominator num))))
        (exact-fraction--create
         (* (exact-fraction-numerator n) (exact-fraction-denominator d))
         (* (exact-fraction-numerator d) (exact-fraction-denominator n))))
    (exact-fraction--from-number num)))

(defun exact-fraction-normalize (num)
  (let* ((snum (exact-fraction--simplify num))
         (n (exact-fraction-numerator snum))
         (d (exact-fraction-denominator snum))
         (ef-gcd (gcd n d)))
    (exact-fraction--create (/ n ef-gcd) (/ d ef-gcd) ef-gcd)))

(exact-fraction-normalize (exact-fraction--create 10 (exact-fraction--create 3 (exact-fraction--create 2 5))))

(defun exact-fraction-create (numerator &optional denominator)
  (let* ((denominator (or denominator 1))
         (ef-gcd (gcd numerator denominator))
         (ef-numerator (/ numerator ef-gcd))
         (ef-denominator (/ denominator ef-gcd)))
    (exact-fraction--create ef-numerator ef-denominator ef-gcd)))

;; (defmacro exact-add (&rest args)
;;   (let ((e-args (make-symbol "evaluated-args"))
;;         (ns (make-symbol "numerators"))
;;         (ds (make-symbol "denominator"))
;;         (nfs (make-symbol "nfs"))
;;         (ef-lcm (make-symbol "ef-lcm")))
;;     `(let* ((,e-args (list ,@args))
;;             (,ns (mapcar #'exact-fraction-numerator ,e-args))
;;             (,ds (mapcar #'exact-fraction-denominator ,e-args))
;;             (,ef-lcm (apply #'lcm ,ds))
;;             (,nfs
;;              (mapcar* (lambda (x y) (* (/ ,ef-lcm x) y)) ,ds ,ns)))
;;        (exact-fraction-create (reduce #'+ ,nfs) ,ef-lcm))))
;; (pp-macroexpand-expression
;;  '(exact-add (exact-fraction-create 10) (exact-fraction-create 3 4) (exact-fraction-create 7 4)))

(defun exact-add (&rest args)
  (let* ((numerators (mapcar #'exact-fraction-numerator args))
         (denominators (mapcar #'exact-fraction-denominator args))
         (ef-lcm (apply #'lcm denominators))
         (nfs (mapcar* (lambda (x y) (* (/ ef-lcm x) y)) denominators numerators)))
    (exact-fraction-create (reduce #'+ nfs) ef-lcm)))

(provide 'exact)

;;; exact.el ends here

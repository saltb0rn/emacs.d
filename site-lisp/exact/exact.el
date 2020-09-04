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

(cl-defstruct
    (exact-bounce
     (:constructor nil)
     (:constructor exact-bounce (res cont)))
  res cont)

(defun exact-tampoline (b)
  (let* ((kont (exact-bounce-cont b))
         (val (exact-bounce-res b))
         (res (funcall kont val)))
    (while (exact-bounce-p res)
      (setq
       kont (exact-bounce-cont res)
       val (exact-bounce-res res)
       res (funcall kont val)))
    res))

(defun exact-float-to-fraction (f &optional maxden)
  "Finds the approximate fraction of the floating-point number.
This function based on the theory of continued fraction.

BUG: This function is buggy.

Inspired by following resources:
https://github.com/python/cpython/blob/master/Lib/fractions.py#L201
https://www.ics.uci.edu/~eppstein/numth/frap.c
https://stackoverflow.com/questions/95727/how-to-convert-floats-to-human-readable-fractions.

  Argument `REAL' is the real number to be converted to the fraction.
  Argument `MAXDEN' is the max denomintor."
  (let ((mat (vector 1 0 0 1))
        (maxden (or maxden (expt 10 7)))
        (x f)
        (ai (floor f)))
    (catch 'break
      (while (<= (+ (* (aref mat 2) ai) (aref mat 3)) maxden)
        (let ((t1 (+ (* (aref mat 0) ai)
                     (aref mat 1))))
          (aset mat 1 (aref mat 0))
          (aset mat 0 t1)
          (setq t1 (+ (* (aref mat 2) ai)
                      (aref mat 3)))
          (aset mat 3 (aref mat 2))
          (aset mat 2 t1)
          (when (= x ai)
            (throw 'break nil))
          (setq x (/ 1.0 (- x ai)))
          (setq ai (floor x))
          (when (> x #x7FFFFFFF)
            (throw 'break nil)))))
    (setq ai (/ (- maxden (aref mat 3)) (aref mat 2)))
    (aset mat 0
          (+
           (* (aref mat 0) ai)
           (aref mat 1)))
    (aset mat 2
          (+
           (* (aref mat 2) ai)
           (aref mat 3)))
    (list (aref mat 0) (aref mat 2) (- f (/ (aref mat 0) (aref mat 2))))))

(defsubst exact-fraction--from-number (num)
  (unless (numberp num)
    (error "exact-number-to-fraction: Argument must be a number"))
  (cond ((integerp num) (exact-fraction--create num 1))
        ((floatp num) (exact-float-to-fraction num))
        (nil ((error "exact-number-to-fraction: Argument must be a number")))))

;; (defsubst exact-fraction--simplify (num)
;;   "Old impelmentation."
;;   (if (exact-fraction-p num)
;;       (let* ((n
;;               (exact-fraction--simplify (exact-fraction-numerator num)))
;;              (d
;;               (exact-fraction--simplify (exact-fraction-denominator num))))
;;         (exact-fraction--create
;;          (* (exact-fraction-numerator n) (exact-fraction-denominator d))
;;          (* (exact-fraction-numerator d) (exact-fraction-denominator n))))
;;     (exact-fraction--from-number num)))

(defsubst exact-fraction--simplify-bounce (num cont)
  "TODO: Deals with floating-point number."
  (if (exact-fraction-p num)
      (exact-bounce
       (exact-fraction-numerator num)
       (lambda (t1)
         (exact-fraction--simplify-bounce
          t1
          (lambda (n)
            (exact-bounce
             (exact-fraction-denominator num)
             (lambda (t2)
               (exact-fraction--simplify-bounce
                t2
                (lambda (d)
                  (exact-bounce
                   (exact-fraction--create
                    (* (exact-fraction-numerator n) (exact-fraction-denominator d))
                    (* (exact-fraction-numerator d) (exact-fraction-denominator n)))
                   cont)))))))))
    (exact-bounce (exact-fraction--from-number num) cont)))

(defsubst exact-fraction--simplify (num)
  (exact-tampoline (exact-fraction--simplify-bounce num (lambda (v) v))))

(defun exact-fraction-create (numerator &optional denominator)
  (let* ((denominator (or denominator 1))
         (ef-gcd (gcd numerator denominator))
         (ef-numerator (/ numerator ef-gcd))
         (ef-denominator (/ denominator ef-gcd)))
    (exact-fraction--create ef-numerator ef-denominator ef-gcd)))

;;;###autoload
(defun exact-add (&rest args)
  (let* ((fractions (mapcar #'exact-fraction--simplify args))
         (numerators (mapcar #'exact-fraction-numerator fractions))
         (denominators (mapcar #'exact-fraction-denominator fractions))
         (ef-lcm (apply #'lcm denominators))
         (nfs (mapcar* (lambda (x y) (* (/ ef-lcm x) y)) denominators numerators)))
    (exact-fraction-create (reduce #'+ nfs) ef-lcm)))

;;;###autoload
(defun exact-sub (&rest args)
  (let* ((fractions (mapcar #'exact-fraction--simplify args))
         (numerators (mapcar #'exact-fraction-numerator fractions))
         (denominators (mapcar #'exact-fraction-denominator fractions))
         (ef-lcm (apply #'lcm denominators))
         (nfs (mapcar* (lambda (x y) (* (/ ef-lcm x) y)) denominators numerators)))
    (exact-fraction-create (reduce #'- nfs) ef-lcm)))

;;;###autoload
(defun exact-mul (&rest args)
  (let* ((fractions (mapcar #'exact-fraction--simplify args))
         (numerators (mapcar #'exact-fraction-numerator fractions))
         (denominators (mapcar #'exact-fraction-denominator fractions)))
    (exact-fraction-create (reduce #'* numerators) (reduce #'* denominators))))

;;;###autoload
(defun exact-div (&rest args)
  (let ((dividend (car args))
        (divisors (cdr args)))
    )
  )

(defun exact-fraction-reduce (num)
  (let* ((snum (exact-fraction--simplify num))
         (n (exact-fraction-numerator snum))
         (d (exact-fraction-denominator snum))
         (ef-gcd (gcd n d)))
    (exact-fraction--create (/ n ef-gcd) (/ d ef-gcd) ef-gcd)))

(provide 'exact)

;;; exact.el ends here

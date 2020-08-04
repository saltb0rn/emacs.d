;;; -*- lexical-binding: t; -*-
;;; Commentray:
;;;   Inspired by https://github.com/python/cpython/blob/3.8/Lib/fractions.py

;;; Code:

(setq-local lexical-binding t)

(require 'cl-lib)

(cl-defstruct
    (exact-fraction
     (:constructor nil)
     (:constructor exact-fraction--create
                   (numerator &optional (denominator 1) (ef-gcd 1))))
  numerator denominator ef-gcd)

(defsubst exact-number-to-fraction (num)
  (unless (numberp num)
    (error "exact.el: Argument must be a number")))

(defun exact-fraction-create (numerator denominator)
  (let* ((ef-gcd (exact-gcd numerator denominator))
         (ef-numerator (/ numerator ef-gcd))
         (ef-denominator (/ denominator ef-gcd)))
    (exact-fraction--create ef-numerator ef-denominator ef-gcd)))


;; (defmacro exact-add (&rest args)
;;   (let ((tlcm (make-symbol "ef-lcm"))
;;         (nf (make-symbol "numerator-factorys"))
;;         (argsed (make-symbol "argsed")))
;;     `(let ((,argsed (list ,@args)))
;;        (let ((,tlcm (exact-lcm-lst (mapcar #'exact-fraction-denominator ,argsed)))
;;              (,nf (apply #'mapcar (lambda (x) (/ ,tlcm x)) (mapcar #'exact-fraction-numerator ,argsed))))
;;          ,nf
;;          )
;;        )
;;     ))


;; (macroexpand '(exact-add (exact-fraction-create 10 2) (exact-fraction-create 2 3)))

;; (exact-add (exact-fraction-create 10 2) (exact-fraction-create 2 3))


(defmacro exact-add (&rest args)
  (let ((eargs (make-symbol "eargs"))
        (ns (make-symbol "ns"))
        (ds (make-symbol "ds"))
        (nfs (make-symbol "nfs"))
        (ef-lcm (make-symbol "ef-lcm")))
    `(let* ((,eargs (list ,@args))
            (,ns (mapcar #'exact-fraction-numerator ,eargs))
            (,ds (mapcar #'exact-fraction-denominator ,eargs))
            (,ef-lcm (apply #'lcm ,ds))
            (,nfs
             (mapcar* (lambda (x y) (* (/ ,ef-lcm x) y)) ,ds ,ns)))
       (exact-fraction-create (reduce #'+ ,nfs) ,ef-lcm))))

(provide 'exact)

;;; exact.el ends here

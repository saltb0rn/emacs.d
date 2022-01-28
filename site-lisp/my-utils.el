(defun epsilon (order-arr)
  ;; 逆序数,就是统计一个序数列表里面有那几个元素是逆过来的
  ;; Brute Force Implementation, should use Merge-sort
  (let ((inv-sum 0)
        (len (length order-arr)))
    (while (null (zerop len))
      (let* ((cursor (- len 1))
             (cur-elm (nth cursor order-arr))
             (rest-len cursor))
        (while (null (zerop rest-len))
          (let* ((forward (- rest-len 1))
                 (forward-elm (nth forward order-arr)))
            (when (> forward-elm cur-elm)
              (setq inv-sum (1+ inv-sum)))
            (setq rest-len (1- rest-len)))))
      (setq len (- len 1)))
    (expt -1 inv-sum)))

(defun find-the-unmatched (seq el er)
  (let (err-li
        err-ri
        rest
        (i 0)
        (l (length seq)))
    (while (< i l)
      (let ((e (elt seq i)))
        (cond
         ((equal el e)
          (push i err-li))
         ((equal er e)
          (if (null err-li)
              (push i err-ri)
            (pop err-li)))
         (nil))
        (setq i (+ i 1))))
    (list err-li err-ri)))

(defun remove-if-unmatched (seq begin end)
  (let* ((unmatched (find-the-unmatched seq begin end))
         (l (car unmatched))
         (r (cadr unmatched))
         (lst `(,@l ,@r))
         (i 0)
         (len (length seq))
         res)
    (while (< i len)
      (unless (member i lst)
        (push (elt seq i) res))
      (setq i (+ i 1)))
    (reverse res)))

;; (string-join (mapcar #'char-to-string (remove-if-unmatched ")()abc)" ?\( ?\))) "")

(defun decimal-to-any-based-number (decimal base)
  ;; 十进制转任何进制
  (if (= 10 base)
      (list decimal)
    (let ((quotient decimal)
          tmp digits)
      (while (>= quotient base)
        (progn
          (setq tmp (floor quotient base))
          (push (- quotient (* base tmp)) digits)
          (setq quotient tmp)))
      (push quotient digits)
      digits)))

(defun any-based-number-convection (digits src-base target-base)
  ;; 进制之间的转换
  (if (= src-base target-base)
      digits
    (let ((decimal 0)
          (max-index (1- (list-length digits)))
          (digit-index 0))
      (while (<= digit-index max-index)
        (setq decimal (+ decimal
                         (*
                          (nth (- max-index digit-index) digits)
                          (expt src-base digit-index))))
        (setq digit-index (1+ digit-index)))
      (decimal-to-any-based-number decimal target-base))))

(defun component-to-original (component digit-num)
  ;; 补码转原码
  (if (or (< component 0) (not (integerp component)))
      (user-error "Make sure your value of component is in N+")
    (let ((range-of-positive (1- (expt 2 (1- digit-num))))
          digits)
      (setq digits
            (if (<= component range-of-positive)
                (decimal-to-any-based-number component 2)
              (decimal-to-any-based-number (- (expt 2 digit-num) component) 2)))
      (let ((rest-digits (make-list (- digit-num (length digits)) 0)))
        (when (> (length rest-digits) 0)
          (setcar rest-digits
                  (if (> component range-of-positive) 1 0)))
        `(,@rest-digits ,@digits)))))

(provide 'my-utils)

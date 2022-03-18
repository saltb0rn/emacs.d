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

(defun int-range-probability (from to num)
  ;; 写该函数是目的是计算游戏"三角战略"里面的"德西玛尔"HP[num]招式可攻击敌人的概率
  ;; 求从 from 到 to 的范围的整数里面,数字为 num 的倍数的占比为多少
  ;; 要求 from < to, 并且 num > 0
  ;; 可以把这个问题看做在固定步长下,求能走多少步.
  ;; 比如说从 1 到 12 的范围内,步长为 3 的情况下能够多少步,
  ;; 1 2 3] 4 5 6] 7 8 9] 10 11 12], 可以看到有 3, 6, 9 和 12 四个,
  ;; 接着转换成求下标个数的问题,就变成类似求余的问题了,把问题改变一下,
  ;; 求 21 - 30 范围内,是 7 的倍数的整数个数有多少,思路如下:
  ;; 先求出 0 - 30 里面为 7 的倍数的整数个数 x,
  ;; 再求出 0 - 20 里面为 7 的倍数的整数个数 y,
  ;; 那么在 21 - 30 范围里面为 7 的把倍数的整数个数为 x - y,
  ;; 最后用这个结果除以 21 - 30 这个范围内的数字个数 30 - 21 + 1 = 10 就能得出概率
  ;; 如果要求为同时是 3 和 7 倍数的整数个数,则需要先求出 3 和 7 的最小公倍数 21,然后进行上面的运算
  (let* ((trimed-range (abs (- from 1)))
         (total-range to)
         (total-numbers (+ (abs (- to from)) 1))
         (trimed-times (floor (/ trimed-range num)))
         (total-times (floor (/ total-range num)))
         (actual-times (abs (- total-times trimed-times))))
    (/ (* 1.0 actual-times) total-numbers)))

(provide 'my-utils)

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

(string-join (mapcar #'char-to-string (remove-if-unmatched ")((abc)" ?\( ?\))) "")

(require 'json)

(defconst pokemon-mod-denominator 4096.0)
(defconst pokemon-mod-xdot25 1024)
(defconst pokemon-mod-xdot33 1352)
(defconst pokemon-mod-xdot5 2048)
(defconst pokemon-mod-x2/3 2732)
(defconst pokemon-mod-xdot75 3072)
(defconst pokemon-mod-x1 #x1000)               ;; 4096
(defconst pokemon-mod-x1dot1 4505)
(defconst pokemon-mod-x1dot2 4915)
(defconst pokemon-mod-x1dot25 #x1400)          ;; 5120
(defconst pokemon-mod-x1dot29 #x14cc)          ;; 5324
(defconst pokemon-mod-x1dot3 #x14cd)           ;; 5325
(defconst pokemon-mod-x1dot33 #x1548)          ;; 5448
(defconst pokemon-mod-x1dot4 #x1666)           ;; 5734
(defconst pokemon-mod-x1dot5 #x1800)           ;; 6144
(defconst pokemon-mod-x1dot6 6553)
(defconst pokemon-mod-x1dot8 7372)
(defconst pokemon-mod-x2 8192)

(defun pokemon-round (arg &optional divisor)
  ;; Round developed by Game Freak
  (let* ((val (/ arg (or divisor 1) 1.0))
         (int (truncate val))
         (dec (- val int)))
    (if (> dec 0.5)
        (+ int 1)
      int)))

(defun pokemon-normal-round (arg &optional divisor)
  (let* ((val (/ arg (or divisor 1) 1.0))
         (int (truncate val))
         (dec (- val int)))
    (if (>= dec 0.5)
        (+ int 1)
      int)))

(defalias 'pokemon-flooring #'truncate)

(defun pokemon-load-data-from-json (file)
  (let* ((json-object-type 'hash-table)
         (json-array-type 'list)
        (json (json-read-file file)))
    json))

(defun pokemon-data-update (data1 data2)
  ;; `data1' is the object to update.
  ;; no need to worry about recursion problem,
  ;; since the depth of data won't be deep.
  (maphash
   (lambda (key data2-value)
     (let ((data1-value (gethash key data1 nil)))
       (if (and
            (hash-table-p data1-value)            
            (hash-table-p data2-value))
           (pokemon-data-update data1-value data2-value)
         (puthash key data2-value data1))))
   data2)
  data1)

(defalias 'pokemon-data-put #'puthash)

(defalias 'pokemon-data-rem #'remhash)

(defalias 'pokemon-data-item-names #'hash-table-keys)

(defalias 'pokemon-data-item-count #'hash-table-count)

(defun pokemon-data-get (obj attr1 &rest attrs)
  (let ((val (gethash attr1 obj nil))
        (err-path (list attr1)))
    (catch 'return
      (dolist (attr attrs val)
        (push attr err-path)
        (if (hash-table-p val)
            (setq val (gethash attr val nil))
          (throw 'return
                 (list :error
                       (format "can't access property \"%s\", <object>.%s is undefined"
                               (car (reverse err-path))
                               (string-join (reverse (cdr err-path)) ".")))))))))

(provide 'pokemon-utils)

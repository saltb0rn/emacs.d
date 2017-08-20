(defun greeting (msg)
  (message msg)
  msg)
;;    msg))

(defun before/greeting (msg)
  (message "Morning"))

(defun after/greeting (msg)
  (message "Bye Bye"))

(advice-add #'greeting :before #'before/greeting)
(greeting "hello")
(advice-remove #'greeting  #'before/greeting)

(add-function :before (symbol-function 'greeting) #'before/greeting)

(greeting "hello")


;; To input the middle finger, use M-x insert-char
(defvar 🖕 "fuck")
(defun 🖕 (msg)
  (message (format "🖕 %s" msg)))

(🖕 "you, Nvidia!")

(provide 'for-debug)

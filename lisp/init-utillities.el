(require-install 'cl)
;;; (defun new-buffer (&optional BUFFER-NAME)
;;;  "BUFFER-NAME is a string of name to buffer you want to create."
;;;  (interactive (list
	;;;	(read-string "Buffer-name (default *scratch*):"
	;;;		     nil nil "*scratch*")))
  ;;; (let ((buf (generate-new-buffer BUFFER-NAME)))
;;;    (switch-to-buffer buf)
;;;    (if (equal "*scratch*" BUFFER-NAME)
;;;	(lisp-interaction-mode))))

;;; This is no need to write this function, switch-to-buffer can do this.
;;;(defun new-buffer (&optional BUFFER-NAME)
;;;  "BUFFER-NAME is a string of name of buffer that you want to create."
;;;  (interactive (list
;;;		(read-string "Buffer-name (default *scratch*):"
;;;			     nil nil "*scratch*")))
;;;  (if (equal "*scratch*" BUFFER-NAME)
;;;      (switch-to-buffer "*scratch*")
;;;    (switch-to-buffer (generate-new-buffer BUFFER-NAME))))


;;(global-set-key (kbd "C-x n") #'new-buffer)
;;;(global-set-key (kbd "C-x n") 'new-buffer)

;; term-toggle is a quick way to toggle term below the current window.
;; TODO: Set the window to frame bottom, disable the ask for killing terminal.
;; TODO: Better make term-toggle a mirror mode.

(setf (symbol-function 'term-toggle)
      (lexical-let ((window nil)
		    (term-buf nil))
	(lambda ()
	  (interactive)
	  (if (null window)
	      (progn
		(let ((old-buf (current-buffer)))
		  (setq window (split-window
				nil
				(* (round (window-total-height) 3) 2))
			term-buf (term "/bin/bash"))
		  (set-window-buffer window term-buf)
		  (set-window-buffer nil old-buf)))
	    (progn
	      (if (buffer-live-p term-buf)
		  (kill-buffer term-buf))
	      (if (window-live-p window)
		  (delete-window window))
	      (setq window nil
		    term-buf nil))))))

;;;; I don't use term-toggle anymore, use shell-toggle instead.

(setf (symbol-function 'shell-toggle)
      (lexical-let ((window nil)
		    (shell-buf nil))
	(lambda ()
	  (interactive)
	  (if (null window)
	      (progn
		(let ((old-buf (current-buffer)))
		  (setq window (split-window
				nil
				(* (round (window-total-height) 3) 2))
			shell-buf (eshell))
		  (set-window-buffer window shell-buf)
		  (set-window-buffer nil old-buf)))
	    (progn
	      (if (buffer-live-p shell-buf)
		  (kill-buffer shell-buf))
	      (if (window-live-p window)
		  (delete-window window))
	      (setq window nil
		    shell-buf nil))))))

;;(global-set-key (kbd "<f4>") #'term-toggle)

(provide 'init-utillities)
;;; TODO: Should I separate the utillities in different files.

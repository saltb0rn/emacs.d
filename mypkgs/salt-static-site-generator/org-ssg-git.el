;;; org-ssg-git.el --- git ; -*- lexical-binding: t; -*-

;;; code:

;; test that lexical-binding works or not
(let ((count 0))
  (defun test ()
    (interactive)
    (let ((res (+ count 1)))
      (setq count res)
      (message "%d" res)
      res)))

(default-value 'lexical-binding)

(provide 'org-ssg-git)
;;; rog-ssg-git.el ends here

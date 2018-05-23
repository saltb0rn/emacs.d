;;; ob-utils.el --- Provide common utilities for org-blogger ;; -*- lexical-binding: t -*-

;;; Code:

(defun read-file-as-string (path)
  "Return string as file content of file located in PATH"
  (with-temp-buffer
    (insert-file-contents path)
    (buffer-string)))

(provide 'ob-utils)
;;; ob-utils.el ends here

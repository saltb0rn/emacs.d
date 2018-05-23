;;; ob-export.el --- Publication related functions required by org-blogger ;; -*- lexical-binding: t -*-

;;; Code:

(require 'ob-template)

(defun ob/compile ()
  "(Re)compile org files stored in `ob/source-directory' into `ob/target-directory'."
  )

(defun ob/read-org-option (option)
  "Read option value of org file opened in current buffer.
e.g:
#+TITLE: this is title
will return \"This is title\" if OPTION is \"TITLE\""
  (let ((match-regexp (org-make-options-regexp `(,option))))
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward match-regexp nil t)
	(match-string-no-properties 2 nil)))))

(provide 'ob-export)
;;; ob-export.el ends here

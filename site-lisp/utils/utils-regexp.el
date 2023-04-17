(defun utils-regex-replace-in-string (regexp replacement string)
  "Replace content which matches REGEXP with
REPLACEMENT, and return the new content.

Inspired by function `sub' provided by Python `re' module."
  (if (string-match regexp string)
      (string-replace
       (match-string 0 string)
       replacement
       string)
    string))

(provide 'utils-regexp)

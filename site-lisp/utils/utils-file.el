;; -*- lexical-binding: t -*-

(defun utils-write-to-file (content file &optional coding-system)
  "Write CONTENT to FILE.
CONTENT should be string type.
FILE should be path to which CONTENT is written."
  (with-temp-buffer
    (insert content)
    (write-region (buffer-string) nil file)))

(defun utils-read-from-file (file)
  "Read Content from FILE.
FILE should be a path to file."
  (with-temp-buffer
    (insert-file-contents-literally (expand-file-name file))
    (buffer-string)))

(provide 'utils-file)

;;; -*- lexical-binding: t -*-

(defun org-ssg/git-branch-name (repo-dir)
  "Return name of current branch of git repository presented by REPO-DIR"
  (let ((git-repo repo-dir))		; TODO: what is the type of repo-dir
    (git-on-branch)))

(provide 'org-ssg-config)

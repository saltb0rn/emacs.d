;;; org-ssg.el --- salt static site generator based on Org-mode -*- lexical-binding: t -*-

;; Copyright (C) 2018 Saltb0rn

;; Author: Saltb0rn <asche34@outlook.com>
;; Keywords: org-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; 1. Sources:
;; 2. Documents:

;;; Code:
(require 'ox-html)
(require 'ht)
(require 'simple-httpd)
(require 'org-ssg-util)			; op-vars.el
(require 'org-ssg-config)
(require 'org-ssg-export)
(require 'org-ssg-git)

(defconst org-static-site-generator-version "0.1")

(defun org-ssg/do-publication (&optional
			    force-all base-git-commit
			    pub-base-dir auto-commit
			    auto-push)
  "Publish the files accroding the configuration."
  (interactive
   (let* ((f (y-or-n-p "Publish all org files?"))
	  (b (unless f (read-string "Base git commit: " "HEAD~1")))
	  (p (when (y-or-n-p
		    "Publish to a directory? (to original rep if not) ")
	       (read-directory-name "Publication directory: ")))
	  (a (when (not p)
	       (y-or-n-p "Auto commit it to repo?")))
	  (u (when (and a (not p))
	       (y-or-n-p "Auto push to remote repo?")))))
   (list f b p a u))
  (org-ssg/verify-configuration)
  (setq op/item-cache nil)		; NOTE variable, op-vars.el, maybe we can remove it
  (let* ((orig-branch (op/git-branch-name op/repository-directory))
	 ;; NOTE op-git.el. function, `op/git-branch-name', return branch name of repo dir
	 ;; NOTE  op-vars.el. variable, `op/repository-directory', the git repository directory, where files stored on the branch `op/repository-org-branch'
	 (to-repo (not (stringp pub-base-dir)))
	 (store-dir (or pub-base-dir "~/.op-tmp/"))
	 (store-dir-abs (file-name-as-directory (expand-file-name store-dir))))
    (op/git-change-branch op/repository-directory op/repository-org-branch)
    ;; NOTE op-git.el. function, `op/git-change-branch', change branch name
    ;; NOTE op-vars.el. variable, `op/repository-org-branch', the branch where org file stored on
    (op/prepare-theme store-dir)	; NOTE function, op/prepare-theme, op-enhance.el
    ;; get all files represented by a list of file-relative name, remove the category directories ignored from them
    (setq all-files
	  (cl-remove-if
	   #'(lambda (file)
	       (let ((root-dir (file-name-as-directory
				(expand-file-name op/repository-directory))))
		 (member t
			 (mapcar
			  #'(lambda (cat)
			      (string-prefix-p
			       cat
			       (file-relative-name file root-dir)))
			  ;; NOTE op-vars.el, variable, `op/category-ignore-list', the subdirs/categories that are ignored for navigation. The categories are represented by directories.
			  op/category-ignore-list))))
	   (op/git-all-files op/repository-directory)))
    ;; NOTE op-git.el, function, op/git-al-files, returns a list of org file in repository
    (setq chaged-files (if force-all
			   '(:update ,all-files :delete nil)
			 ;; NOTE op-vars.el, function, `op/git-files-changed', return files modified/deleted org files from git repo, represented by a property list, (:updated list-of-updated-file :deleted list-of-deleted-file)
			 (op/git-files-changed op/repository-directory
					       (or base-git-commit "HEAD~1"))))
    (op/publish-changes all-files changed-files store-dir-abs)
    ;; NOTE op-export.el, function, `op/publish-changes'

    ;; copy the files from `store-dir' to `op/repository-directory' or not
    ;; `store-dir' specified by `pub-base-dir'
    (when to-repo
      (op/git-change-branch op/repository-directory op/repository-html-branch)
      ;; NOTE op-vars.el, variable, `op/repository-html-branch', the branch where html files are generated on
      (copy-directory store-dir op/repository-directory t t t)
      (delete-directory store-dir t))
    (when (and to-repo auto-commit)
      ;; NOTE op-git.el, function, `git-commit-chagnes'
      (op/git-commit-changes op/repository-directory
			     "Update publish html files, commited by org-page.")
      
      (when auto-push
	(setq remote-repos (op/git-remote-name op/repository-directory))
	;; NOTE op-git.el, function, `op/git-remote-name'
	(if (not remote-repos)
	    (message "No valid remote repository found.")
	  (let (repo)
	    (if (> (length remote-repos) 1)
		(setq repo (read-string
			    (format "Which repo to push %s: "
				    (prin1-to-string remote-repos))
			    (car remote-repos)))
	      (if (not (member (car remote-repos)))
		  (message "Invalid remote repository '%s.'" repo)
		(op/git-push-remote op/repository-directory
				    ;; NOTE op-git.el, function, `git-push-remote', push local branch to
				    ;; remote repo
				    repo
				    op/repository-html-branch))))))
      (op/git-change-branch op/repository-directory orig-branch))
    (if to-repo
	(message "Publication finished: on branch '%s' of repository '%s'."
		 op/repository-html-branch op/repository-directory)
      (message "Publication finished, output directory: %s." pub-base-dir))))


(defun org-ssg/verify-configuration ()
  "error if configuration is invalid
  `op/repository-directory': <required>
  `op/site-domain': <required>
  `op/personal-disqus-shortname': <optional>
  `op/personal-duoshuo-shortname': <optional>
"



(provide 'org-ssg.el)
;;; sssg.el ends here

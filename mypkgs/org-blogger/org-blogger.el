;;; org-blogger.el --- A simple tool to write your blog ;; -*- lexical-binding: t -*-

;;; Commentary:
;; the dependices includes:
;; mustache -- a logical less template library
;; org-mode -- our main character for writing your blog
;; ht -- a morden hash table library
;; This is all we need

;; workflow:
;; 1. change default directory to where your blog stored on
;; 2. search the org files, ie. your posts
;; 3. compile your post into the mirror directory

;;; Code:

(file-exists-p "~/Downloads")

(provide 'org-blogger)
;;; org-blogger.el ends here

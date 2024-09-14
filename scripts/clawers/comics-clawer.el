#!/usr/bin/emacs --script
;; -*- lexical-binding: t -*-
;; 该脚本用来批量下载新蝙蝠侠52的漫画

;; 用法:
;;     emacs -Qq --script ./comics-clawer.el
;; or
;;     chmod u+x ./comics-clawer.el
;;     ./comics-clawer.el
;;

(package-initialize)
(require 'cl-lib)
(require 'dom)
(require 'subr-x)
(require 'url)

(cl-defstruct response headers body)

;; 下载的文件作为样本进行解析
;; (url-copy-file "https://www.manhua456.com/manhua/xin52bianfuxia" "./comics-home-sample.html")
;; (url-copy-file "https://www.manhua456.com/manhua/xin52bianfuxia/318328.html" "./comics-chapter-sample.html")

(defun url-open (url &rest args)
  "Return the response by requesting the url"
  (let ((url-request-extra-headers (plist-get args :headers))
        (url-request-method (plist-get args :methods))
        (url-request-data (plist-get args :data)))

    (let ((rsp (url-retrieve-synchronously url)))
      (with-current-buffer rsp
        (set-buffer-multibyte t)
        (decode-coding-region (point-min) (point-max) 'utf-8-dos)
        (goto-char (point-min))
        (re-search-forward "^$" nil 'move)
        (make-response :headers (buffer-substring-no-properties (point-min) (point))
                       :body (buffer-substring-no-properties (point) (point-max)))))))


(defun log-error (url reason &optional log-path)
  (unless log-path
    (setq log-path "./comics-clawer-log.txt"))
  (write-region (format "[%s]%s: %s\n" (current-time-string) url reason) nil log-path 'append))


(defun parse-chapter-pics (url)
  (let* ((rsp (url-open url))
         (imgs
          (if (string-match ";var chapterImages = \\[\\(.+\\)\\];" (response-body rsp))
              (mapcar
               (lambda (img)
                 (replace-regexp-in-string "\"" "" img))
               (split-string (match-string 1 (response-body rsp)) ","))
              (error "没法找到图片列表")))
         (root
          (if (string-match ";var chapterPath = \\(.*?\\);" (response-body rsp))
              (replace-regexp-in-string "\"" "" (match-string 1 (response-body rsp)))
            (error "没有找到图片根路径")))
         (tree (with-temp-buffer
                 (insert (response-body rsp))
                 (libxml-parse-html-region nil nil)))
         (title (dom-text (dom-by-tag (dom-by-class tree "head_title") 'h2)))
         (dir-root (format "./%s" title))
         res)

    (unless (file-exists-p dir-root)
      (make-directory dir-root))
    (let ((index 0))
      (while (< index (length imgs))
        (push
         ;; (URL DIRNAME/INDEX-NAME)
         (cons
          (format "%s%s%s" "http://res.kingwar.cn/" root (elt imgs index))
          (format "%s/%s-%s" dir-root (1+ index) (elt imgs index)))
         res)
        (setq index (1+ index))))
    res))

(defun main ()
  (let* ((rsp (url-open "https://www.manhua456.com/manhua/xin52bianfuxia/"))
         (tree (with-temp-buffer
                 (insert (response-body rsp))
                 (libxml-parse-html-region nil nil)))
         (chs (dom-by-tag (dom-by-id tree "chapter-list-1") 'li)))

    (let ((index 0))
      (while (< index (length chs))
        (condition-case err-msg
            (let ((pics (parse-chapter-pics
                         (format "https://www.manhua456.com%s"
                                 (dom-attr (dom-by-tag (elt chs index) 'a) 'href)))))
              (mapcar
               (lambda (pic-info)
                 (url-copy-file (car pic-info) (cdr pic-info)))
               pics))
          (error (log-error (dom-attr (dom-by-tag (elt chs index) 'a) 'href) err-msg)))
        (setq index (1+ index))))
    ))

(main)

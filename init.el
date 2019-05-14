;; -*- lexical-binding: t -*-
;; I put all configurations into a single file and `use-package' to configure packages.


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(add-to-list 'load-path (expand-file-name "~/.emacs.d/site-lisp"))

;; Put the customized variables into another file to "protect" "init.el" file
(setq custom-file (expand-file-name "emacs-custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" "" custom-file))
(load custom-file)

(package-initialize)

;; (add-to-list 'package-archives '("elpamrgh" . "https://raw.githubusercontent.com/saltb0rn/emacs-pkg-backup/master/") t)

;; NOTE: about how to use bash on Windows, maybe I can try this thread: https://www.reddit.com/r/emacs/comments/4z8gpe/using_bash_on_windows_for_mx_shell/
(defcustom path-to-bash-on-Windows nil "Set the path to bash while on Windows")

(when (memq system-type '(windows-nt ms-dos cygwim))
  (when path-to-bash-on-Windows
    (setq shell-file-name (concat
                           path-to-bash-on-Windows
                           (if (string-suffix-p "/" path-to-bash-on-Windows)
                               "bash.exe"
                             (concat "/" "bash.exe"))))
    (setenv "PATH" (concat
                    path-to-bash-on-Windows
                    ";"
                    (getenv "PATH")))))

(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos cygwin))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(setq emacs-elpa-mirror "~/.emacs-elpa-mirror"
      package-archives-origin package-archives)

(if (file-exists-p emacs-elpa-mirror)
    (setq package-archives `(("elpamr" . ,(concat emacs-elpa-mirror "/"))))
  (setq package-archives `(("elpamr" . "https://raw.githubusercontent.com/saltb0rn/emacs-pkg-backup/master/"))))

;; update the package metadata if the local cache is missing
(cond ((null package-archive-contents) (package-refresh-contents))
      ((null (file-exists-p package-user-dir)) (package-refresh-contents)))

(setq user-full-name "saltb0rn"
      user-mail-address "asche34@outlook.com")

;; Set transparency
(set-frame-parameter (selected-frame) 'alpha '(90 85))
(add-to-list 'default-frame-alist '(alpha 90 85))

;; (setq debug-on-error t)
;; use `toggle-debug-on-error' instead

;; Always load newest byte code
(setq load-prefer-newer t)

;; Reduce the frequency of garbage collection by making it happen
;; on each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; Warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; Put backup files into specified directory
(setq backup-directory-alist
      `((".*" . ,(concat user-emacs-directory "backups/"))))

(unless (file-exists-p (concat user-emacs-directory "autosaved/"))
  (make-directory-internal (concat user-emacs-directory "autosaved/")))

(setq auto-save-file-name-transforms
      `((".*" ,(concat user-emacs-directory "autosaved/") t)))

;; Disable tool-bar, menu-bar and scroll-bar.
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode 0)
(display-battery-mode 1)

;; `y-or-n-p' is more convenience than `yes-or-no-p'
(fset 'yes-or-no-p 'y-or-n-p)

;; `eval-last-sexp' replaced by `pp-eval-last-sexp'
(fset 'eval-last-sexp 'pp-eval-last-sexp)

;; Disable startup screen
(setq inhibit-startup-screen t)

;; `(global-linum-mode)' will hang out emacs when use `doc-view-mode', so stop it.

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)


;; auto highlight left parenthesis and right parenthesis while cursor at position of either of them
(show-paren-mode 1)

;; no tabs
(set-default 'indent-tabs-mode nil)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(setq hippie-expand-try-functions-list
      `(try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-list
        try-expand-line
        try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))

;; smart tab behavior - (or indent complete)
(setq tab-always-indent 'complete)



;; Load additional files for reading
(and load-file-name
     (let ((load-extras-path (concat (file-name-directory load-file-name) "load-extras.el")))
       (unless (file-exists-p load-extras-path) (write-region "" "" load-extras-path))
       (load load-extras-path)))


;; Restart Emacs
;; https://emacs.stackexchange.com/questions/5428/restart-emacs-from-within-emacs/5446#5446?newreg=d67eacb8fb3849b28a1cd89ac1769461
;; There is a package name restart-emacs, use it instead
;;(defun launch-separate-emacs ()
;;  (if (display-graphic-p)
;;      (call-process "sh" nil nil nil "-c" "emacs &")
;;    (suspend-emacs "fg; emacs -nw")))

;;(defun restart-emacs ()
;;  (interactive)
;;  (add-hook kill-emacs-hook #'launch-separate-emacs t)
;;  (save-buffers-kill-emacs))

;; set key bidings
(define-key (current-global-map) (kbd "C-c C-c") #'whitespace-cleanup)

;; write to file
(defun write-to-file (content file)
  "Write CONTENT to FILE.
CONTENT should be string type.
FILE should be path to which CONTENT is written."
  (with-temp-buffer
    (insert content)
    (write-region (buffer-string) nil file)))

;; read from file
(defun read-from-file (file)
  "Read Content from FILE.
FILE should be a path to file."
  (with-temp-buffer
    (insert-file-contents-literally (expand-file-name file))
    (buffer-string)))

(defun get-path-to-asset-file (file)
  (expand-file-name (concat user-emacs-directory "assets/" file)))

(define-skeleton insert-mit-license
  "Insert MIT license"
  nil
  (concat "The MIT License\n\n"
          "Copyright © " (format-time-string "%Y") " " user-full-name "\n\n"
          "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\n"
          "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\n"
          "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."))

;;-----------------------------------------------------------------------------

;; use to `use-package' configure packages

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-verbose t)

(defadvice async-shell-command (around
                                async-shell-command-ask-password
                                (command &optional output-buffer error-buffer)
                                activate)
  (let ((default-directory "/sudo::"))
    (funcall (ad-get-orig-definition 'async-shell-command)
                        command output-buffer error-buffer)))

;; this package would install system packages if they were missing.
(use-package use-package-ensure-system-package
  :ensure t)

;; third-party packages

(use-package company
  :ensure t
  :hook
  (cond
   ((memq system-type '(windows-nt ms-dos cygwin)) ;; dsiable js2-mode when on Windows because I can not find way to  use nodejs
     '((c-mode
        c++-mode
        php-mode) . company-mode))
    ((null nil)
     '((c-mode
        c++-mode
        php-mode
        js2-mode) . company-mode))))

(use-package flycheck
  :ensure t
  :hook (elpy-mode . flycheck-mode))

(use-package web-mode
  :ensure t
  :mode ("\\.html?\\'" . web-mode)
  :config
  ;; (if (null (assoc "\\.html?\\'" auto-mode-alist))
  ;;     (add-to-list 'auto-mode-alist (cons "\\.html?\\'" 'web-mode)))
  ;; (defadvice hs-minor-mode (before hs-minor-mode-banned-for-web-mode activate)
  ;;   (interactive)
  ;;   (when (equal major-mode 'web-mode)
  ;;     (user-error "Don't turn on `hs-minor-mode' while using `web-mode'")))
  (setq web-mode-enable-auto-closing t
        web-mode-enable-auto-pairing t))

(use-package nyan-mode
  :ensure t
  :config
  (nyan-mode)
  (nyan-start-animation)
  (nyan-toggle-wavy-trail))

(use-package zenburn-theme
  :ensure t
  :config
  (when (display-graphic-p)
    (load-theme 'zenburn t)))

(use-package fic-mode
  :ensure t
  :hook (elpy-mode
         geiser-mode
         lisp-interaction-mode
         racket-mode
         php-mode
         js2-mode
         js2-jsx-mode)
  :config
  (setq fic-highlighted-words
        (quote ("FIXME" "TODO" "BUG" "NOTE" "FIXED")))

  (defvar fic-jump-buffer "*Fic-Jump*" "The buffer jump from")

  (defun fic--keyword-positions (&optional buffer limit)
  "Return the LIMIT positions of keywords in BUFFER."
  (with-current-buffer (or buffer (current-buffer))
    (save-excursion
      (save-match-data
        (let (pos)
          (goto-char (point-min))
          (while (re-search-forward (fic-search-re) limit t)
            (pcase (match-data)
              (`(,s ,e . ,_)
               (when (eq (get-char-property s 'face) 'fic-face)
                 (add-to-list 'pos e)))))
          (reverse pos))))))

  (defun fic--content-in-line-in-position (marker)
  "Return the content in line in location MARKER."
  (let ((frombuf (marker-buffer marker))
        (pos (marker-position marker)))
    (if (not (buffer-live-p frombuf))
        (message "Buffer %s is not alive"  (buffer-name frombuf))
      (with-current-buffer frombuf
        (goto-line (line-number-at-pos pos))
        (buffer-substring (line-beginning-position) (line-end-position))))))

  (defun fic--lineno-in-position (marker)
    "Return line number in MARKER."
    (let ((buf (marker-buffer marker))
          (pos (marker-position marker)))
      (if (not (buffer-live-p buf))
          (message "Buffer %s is not alive" (buffer-name frombuf))
        (with-current-buffer buf
          (line-number-at-pos pos)))))

  (defun fic--jump-to (marker)
    "Jump to the MARKER."
    (let ((tobuf (marker-buffer marker))
          (pos (marker-position marker)))
      (if (not (buffer-live-p tobuf))
          (message "Buffer %s is not alive" (buffer-name tobuf))
        (progn
          (switch-to-buffer tobuf)
          (goto-char pos)))))

  (defun fic--append-line-to-buffer (&optional buffer)
    "Append the lines where keywords located in to BUFFER.
By default, BUFFER is named \"*Fic-Jump*\"."
    (let* ((oldbuf (current-buffer))
           (newbuf (get-buffer-create (or buffer fic-jump-buffer)))
           (markers (fic--keyword-positions oldbuf)))
      (if (with-current-buffer oldbuf
            (bound-and-true-p fic-mode))
          (progn
            (with-current-buffer newbuf
              (let ((inhibit-read-only t))
                (dolist (marker markers)
                  (let ((beg (point)))
                    (insert (format "Visit" (fic--content-in-line-in-position marker)))
                    (make-text-button
                     beg (point)
                     'follow-link t
                     ;;            'face '(:underline nil)
                     'mouse-face 'highlight
                     'help-echo "Click to visit it in other window"
                     'action ((lambda (mkr)
                                (lambda (x)
                                  (let ((inhibit-read-only t)) (erase-buffer))
                                  (fic--jump-to mkr))) marker)))
                  (insert " ")
                  (insert (format "Buffer: %s  "(buffer-name (marker-buffer marker))))
                  (insert (format "Line: %s " (fic--lineno-in-position marker)))
                  (insert (format "%s " (fic--content-in-line-in-position marker)))
                  (insert "\n"))))
            (view-buffer (get-buffer newbuf)))
        (message "The fic-mode is disabled in this buffer."))))

  (defun fic-jump (&optional buffer)
    "Jump to where keyword located in.
BUFFER is the buffer to list the lines where keywords located in."
    (interactive)
    (let ((bufs (buffer-list))
          (buffer (get-buffer-create (or buffer fic-jump-buffer))))
      (with-current-buffer buffer
        (let ((inhibit-read-only t))
          (erase-buffer)))
      (dolist (buf bufs)
        (with-current-buffer buf
          (when fic-mode
            (fic--append-line-to-buffer buffer)))))))

(use-package helm
  :disabled
  :ensure t
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ([f10] . helm-buffers-list))
  :config
  (helm-mode 1)
  (defadvice helm-etags-select (around unlimited-candidate-number
                                       (reinit)
                                       activate)
    "Set `helm-candidate-number-limit' to nil while calling ’helm-etags-select’.
So that entire list of result will be showed."
    (let ((helm-candidate-number-limit nil))
      (funcall (ad-get-orig-definition 'helm-etags-select) reinit))))

(use-package helm-gtags
  :ensure t
  :hook
  ((dired-mode
    eshell-mode
    c-mode
    c++-mode) . helm-gtags-mode)
  :ensure-system-package (gtags . global)
  :bind
  (:map helm-gtags-mode-map
        ("C-c g a" . #'helm-gtags-in-this-function)
        ("C-j" . #'helm-gtags-select)
        ("M-." . #'helm-gtags-dwim)
        ("M-," . #'helm-gtags-pop-stack)
        ("C-c <" . #'helm-gtags-previous-history)
        ("C-c >" . #'helm-gtags-next-history)))

(use-package function-args
  :ensure t)

(use-package sr-speedbar
  :ensure t
  :config
  (setq sr-speedbar-skip-other-window-p t  ; use windmove to move
        sr-speedbar-right-side nil))

(use-package rainbow-delimiters
  :ensure t
  :hook ((lisp-interaction-mode
          elpy-mode
          geiser-mode
          racket-mode) . rainbow-delimiters-mode))

(use-package highlight-indentation
  :ensure t)

(use-package plantuml-mode
  :ensure t
  :config
  ;; On Debian/Ubuntu it's necessary to install graphviz
  (add-to-list 'auto-mode-alist '("\\.uml\\'" . plantuml-mode))
  (setq org-plantuml-jar-path "~/plantuml.jar")
  (defun plantuml-export (&optional format)
    (interactive)
    (when (not (equal major-mode 'plantuml-mode))
      (user-error "Please run in plantuml-mode"))
    (let* ((format (or format "png"))
           (res (shell-command
                 (concat "java -jar "
                         org-plantuml-jar-path " -t" "png"
                         " " (buffer-file-name)))))
      (if (not (equal 0 res))
          (message "Export failed")
        (message "Export successful"))))
  (require 'ob-plantuml))

(use-package simple-httpd
  :ensure t)

(use-package htmlize
  :ensure t)

(use-package dash
  :ensure t)

(use-package ht
  :ensure t)

(use-package org
  :ensure org-plus-contrib
  :requires (htmlize
             dash
             ht
             simple-httpd
             plantuml-mode)
  :bind (:map org-mode-map
         ("C-c i" . #'org-insert-src-block)
         :map global-map
         ("\C-c c" . org-capture))
  :config
  (require 'ox-publish)
  (define-skeleton org-insert-src-block
    "Insert source block in org-mode"
    "Insert the code name of language: "
    "#+BEGIN_SRC " str \n
    > _ \n
    "#+END_SRC")

  (setq org-export-coding-system 'utf-8
        project-path "~/Documents/DarkSalt/"
        posts-path (concat project-path "posts/")
        tags-path (concat project-path "tags/")
        files-path (concat project-path "files/")
        publish-path (concat project-path "site/")
        todos-path (concat project-path "todos/")
        about-path (concat project-path "about/")
        httpd-listings nil
        httpd-root publish-path)

  ;; `publish-all-posts' to publish
  ;; the rest of configuration of `org' is all about the blogging with Emacs.
  ;; the blog provides following features,
  ;; 1. an auto-generated post list ordered by creation date in index;
  ;; 2. an auto-generated post list ordered by capital letter of post name in "posts" category;

  ;; The structure of my blog project:
  ;; Project
  ;;    |- index.org
  ;;    |- theindex.inc
  ;;    |- about/
  ;;    |     `- index.org
  ;;    |- posts/
  ;;    |     |- theindex.org
  ;;    |     |- theindex.inc
  ;;    |     |- 2018/
  ;;    |     |     |- 05/
  ;;    |     |     |    |- hello-world.org
  ;;    |     |     |    `- other posts
  ;;    |     |     `- other months
  ;;    |     `- 20XX/
  ;;    |
  ;;    |- publish/, a mirror of Project, is the another project used to publish
  ;;    |- tags/
  ;;    |     |- tag1.org
  ;;    |-    `- tagxxx.org
  ;;    |- js/
  ;;    |- img/
  ;;    `- css/

  (defun postamble-dispatcher (scheme)
    (cadar
     (ht-get postambles scheme
             (ht-get postambles 'default))))

  (defun read-html-tpl (name)
    (read-from-file
     (concat
      (get-path-to-asset-file "blog-tpl")
      "/"
      name)))

  (setq

   disqus-shortname "darksalt-me"

   postambles (ht
               ('default
                 `(("en"
                    ,(read-html-tpl "default-postamble.html"))))
               ('disqus
                `(("en"
                   ,(read-html-tpl "disqus-postamble.html")))))

   home/up-formats (ht
                    ('default
                      (read-html-tpl "default-home-up-format.html"))
                    ('blog
                     (read-html-tpl "blog-home-up-format.html")))

   html-heads (ht
               ('default
                 (read-html-tpl "default-html-head.html"))
               ('blog
                (read-html-tpl "blog-html-head.html")))

   blog-alist
   `(("static"
      :base-directory ,project-path
      :base-extension "js\\|css\\|png\\|jpg\\|pdf"
      :publishing-directory ,publish-path
      :publishing-function org-publish-attachment
      :exclude "site"
      :recursive t)
     ("home"
      :base-directory ,project-path
      :base-extension "org"
      :publishing-directory ,publish-path
      :publishing-function org-html-publish-to-html
      :html-head-extra "<link rel=\"stylesheet\" type=\"text/css\" href=\"../../../css/index.css\"/>\n"
      :recursive t
      :html-postamble ,(postamble-dispatcher 'default)
      :exclude "site")
     ("about"
      :base-directory ,(concat project-path "about/")
      :base-extension "org"
      :publishing-directory ,about-path
      :publishing-function org-html-publish-to-html
      :html-postamble ,(postamble-dispatcher 'disqus)
      :recursive t
      :exclude "site")
     ("todos"
      :base-directory ,todos-path
      :base-extension "org"
      :publishing-directory ,(concat publish-path "todos/")
      :publishing-function org-html-publish-to-html
      :html-postamble ,(postamble-dispatcher 'disqus)
      :recursive t
      :exclude "site")
     ("posts"
      :base-directory ,posts-path
      :makeindex t
      :base-extension "org"
      :publishing-directory ,(concat publish-path "posts/")
      :publishing-function org-html-publish-to-html
      :html-postamble ,(postamble-dispatcher 'disqus)
      ;; :exclude "site"  this setting will stop org to compile all posts, so commented it out.
      :recursive t)
     ("tags"
      :base-directory ,tags-path
      :base-extension "org"
      :publishing-directory ,(concat publish-path "tags/")
      :publishing-function org-html-publish-to-html
      :html-head-extra "<link rel=\"stylesheet\" type=\"text/css\" href=\"../../../css/tags.css\"/>\n"
      :recursive t
      :html-postamble ,(postamble-dispatcher 'default)
      :exclude "site")
     ("files"
      :base-directory ,files-path
      :base-extension "js\\|css\\|png\\|jpg\\|pdf\\|jpeg"
      :publishing-directory ,(concat publish-path "files/")
      :publishing-function org-publish-attachment
      :exclude "site"
      :recursive t)
     ("DarkSalt" :components ("static" "home" "about" "posts" "files" "tags" "todos")))
   )

  (defun publish-all-posts (project &optional force async)
    "Now the project of blog is isolated from `org-publish-project-alist'.
That is, when calling `org-publish-project' or `org-publish' would not see
any project of blog, vice versa."
    (interactive
     (list (assoc (completing-read "Publish project: "
                                   blog-alist nil t)
                  blog-alist)
           current-prefix-arg))
    (create-project-directory-if-necessary)
    (write-posts-to-tag-inc)
    (rewrite-theindex-inc)
    (let ((org-publish-project-alist blog-alist)
          (org-html-home/up-format (ht-get home/up-formats 'blog))
          (org-html-head (ht-get html-heads 'blog))
          (org-html-preamble nil)
          (org-html-doctype "html5")
          (org-html-link-home "/")
          (org-html-link-up "/")
          (org-export-with-toc nil)
          (org-export-with-author t)
          (org-export-with-email nil)
          (org-export-with-creator nil)
          (org-export-with-date nil)
          (org-export-with-section-numbers nil))
      (org-publish project))
    (rename-theindex-to-index))

  (defun capture-blog-post-file ()
    "Return a path where to store post files. This path will be important.
Usually calling `org-capture' will store the captured content into
a existed file. We do something unusual that store the captured content
into a non-existed file.
When calling `org-capture', it will let you input the post file name,
the TITLE and something things accroding to the templates specified by
the `org-capture-templates'. "
    (let* ((title (read-string "Slug: "))
           (slug (replace-regexp-in-string "[^a-z]+" "-" (downcase title))))
      (expand-file-name
       (format (concat posts-path "%s/%s.org")
               (format-time-string "%Y/%m" (current-time))
               slug))))

  (setq org-capture-templates nil)

  (add-to-list 'org-capture-templates
               `("b" "Blog Post" plain
                 (file capture-blog-post-file)
                 ,(string-join
                   (list
                    "#+title: %^{Title}"
                    "#+date: %<%Y-%m-%d>"
                    "#+index: %^{Concept Index Entry}"
                    "#+tags: %^{Tags}"
                    "#+begin_abstract"
                    "%^{Abstract}"
                    "#+end_abstract"
                    "%?")
                   "\n")))

  (defun read-option-from-post (post option &optional default)
    "Read OPTION from POST. Return DEFAULT by default."
    (with-temp-buffer
      (insert-file-contents post)
      (goto-char (point-min))
      (if (re-search-forward (concat "^#\\+" option ":[ \t]*\\(.*\\)") nil t)
          (match-string-no-properties 1 nil)
        default)))

  (defun format-post-date (date)
    (let* ((components (split-string date "-"))
           (year (car components))
           (month (cadr components))
           (date (caddr components)))
      (format
       "%s-%s-%s"
       year
       (or (and (= (length month) 1) (format "0%s" month))
           month)
       date)))

  (defun retrieve-posts (root)
    "Search all the posts in `project-path', return a list of posts paths"
    (when (file-directory-p root)
      (let ((files (directory-files root t "^[^.][^.].*$" 'time-less-p))
            (res nil))
        (dolist (file files res)
          (if (file-directory-p file)
              (setq res (append res (retrieve-posts file)))
            (when (and (string-suffix-p ".org" file)
                       (not (string-suffix-p "theindex.org" file)))
              (setq res (add-to-list 'res file)))))
        (sort res
              #'(lambda (f1 f2)
                  (string<
                   (format-post-date (read-option-from-post f1 "date" (format-time-string "%Y-%m-%d")))
                   (format-post-date (read-option-from-post f2 "date" (format-time-string "%Y-%m-%d")))))))))

  (defun auto-generate-post-list (root)
    "Search the org files in `project-path', and generate a list of
string consisting of url and title of org-file"
    (let ((files (retrieve-posts root))
          res)
      (dolist (file files res)
        (setq res (add-to-list 'res (format "[[file:%s][%s]]%s"
                                            (url-encode-url
                                             (replace-regexp-in-string
                                              "\\.org" ".html"
                                              (file-relative-name file project-path)))
                                            (read-option-from-post
                                             file "TITLE" (file-name-base file))
                                            (with-temp-buffer
                                              (insert-file-contents file)
                                              (goto-char (point-min))
                                              (if (re-search-forward
                                                   (concat
                                                    "#\\+begin_abstract"
                                                    ;; "\\([[:ascii:][:nonascii:]]*\\)"
                                                    "\\(\\(?:.*\n\\)*.*\\)"
                                                    "#\\+end_abstract")
                                                   nil t)
                                                  (match-string-no-properties 1 nil)
                                                ""))))))))

  (defun retrieve-tags-from-post (post)
    "Retrieve tags from a post"
    (mapcar
     #'(lambda (elt)
         (--> elt
              downcase
              capitalize))
       (let ((tags (read-option-from-post post "tags")))
         (cond
          ((or (null tags)
               (string= (string-trim tags) "")) (list "Others"))
          (t (split-string (string-trim tags) " "))))))

  (defun tag-list (root)
    "Retrieve tags from posts, return a list of tags"
    (let ((files (retrieve-posts root))
          res)
      (dolist (file files res)
        (setq res (append res (retrieve-tags-from-post file))))
      (sort (remove-duplicates res :test 'string=) 'string<)))

  (defun posts-of-tag (tag &optional root)
    "Find the posts of tag, return a list of post.
The ROOT points to the directory where posts store on."
    (let ((files (retrieve-posts (or root posts-path)))
          res)
      (dolist (file files res)
        (when (member tag (retrieve-tags-from-post file))
          (setq res (add-to-list 'res file))))
      (cons tag (list (sort res 'string<)))))

  (defun group-posts-by-tags (root)
    "Return a alist of (TAG . (list POST)).
The ROOT points to the directory where posts store on."
    (let ((tags (tag-list root))
          res)
      (dolist (tag tags res)
        (setq res (add-to-list 'res (posts-of-tag tag))))))

  (defun rename-theindex-to-index ()
    "Rename theindex.html to index.html"
    (let ((old-index (concat publish-path "posts/" "theindex.html"))
          (new-index (concat publish-path "posts/" "index.html")))
      (rename-file old-index new-index t)
      (message "Renamed %s to %s" old-index new-index)))

  (defun rewrite-theindex-inc ()
    "Rewrite theindex.inc in `project-path'"
      (write-region
       (mapconcat
        #'(lambda (str) (format "*** %s\n\t" str))
        (auto-generate-post-list posts-path)
        "\n")
       nil
       (concat project-path "theindex.inc")))

  (defun write-posts-to-tag-inc ()
    (let ((grouped-posts (group-posts-by-tags posts-path))
          (tags (tag-list posts-path)))
      (write-region
       (format "
#+TITLE: TAGS\n
#+HTML_HEAD_EXTRA:<link rel=\"stylesheet\" type=\"text/css\" href=\"../../../css/tags.css\"/>\n\n%s"
               (mapconcat
                #'(lambda (tag)
                    (format "- [[file:%s][%s]]"
                            (url-encode-url
                             (file-relative-name
                              (concat tags-path tag ".html")
                              project-path))
                            tag))
                (tag-list posts-path)
                "\n"))
       nil (concat tags-path "index.org"))
      (dolist (tag tags)
        (write-region
         (mapconcat
          #'(lambda (post)
              (format "- [[file:%s][%s]]"
                      (url-encode-url (file-relative-name post tags-path))
                      (read-option-from-post
                       post "TITLE" (file-name-base post))))
          (cadr (assoc tag grouped-posts)) "\n")
         nil (concat tags-path tag ".inc"))
        (unless (file-exists-p (concat tags-path tag ".org"))
          (write-region
           (format "#+TITLE: %s\n#+INCLUDE: %s"
                   tag (concat tag ".inc"))
           nil (concat tags-path tag ".org"))))))

  (defun create-project-directory-if-necessary ()
    "Create Project directory if it does not exist."
    (dolist (path (list tags-path posts-path
                        todos-path about-path
                        publish-path))
      (unless (file-directory-p path)
        (make-directory path t))))

  ;; Define a advice before `org-publish-project' and `org-publish-projects' to
  ;; generate a list of posts in order by date time.
  ;; Define a advice after `org-publish-project' and `org-publish-projects' to
  ;; rename "theindex.html" to "index.html", because doing this manually is annoyed.

 ;;(defadvice org-publish-project
 ;;     (before org-publish-project-rewrite-theindex-inc activate)
 ;;   (create-project-directory-if-necessary)
 ;;   (write-posts-to-tag-inc)
 ;;   (rewrite-theindex-inc))

 ;;(defadvice org-publish-project
 ;;     (after og-publish-project-rename-theindex-to-index activate)
 ;;   (rename-theindex-to-index))

 ;;(defadvice org-publish-projects
 ;;     (before org-publish-projects-rewrite-theindex-inc activate)
 ;;   (create-project-directory-if-necessary)
 ;;   (write-posts-to-tag-inc)
 ;;   (rewrite-theindex-inc))

 ;; (defadvice org-publish-projects
 ;;     (after org-publish-projects-rename-theindex-to-index activate)
 ;;   (rename-theindex-to-index))
  )

;; (use-package pipenv
;;   :ensure t
;;   :init
;;   (add-hook 'elpy-mode-hook #'pipenv-mode)
;;   (setq pipenv-projectile-after-switch-function
;;         #'pipenv-projectile-after-switch-extended))

(use-package elpy
  :ensure t
  ;; :after (flycheck
  ;;         highlight-indentation)
  :config
  ;; It will be slow while you typing if the buffer size if lagger than the elpy-rpc-ignored-buffer-size
  ;; So we need to turn off the highlight-inentation-mode
  ;; Elpy own it hightlight-indentation
  (add-hook 'elpy-mode-hook
            #'(lambda ()
                (when (> (buffer-size) elpy-rpc-ignored-buffer-size)
                  (progn
                    (highlight-indentation-mode 0)
                    (message "Turn the highlight-indentation-mode off")))))
  (setq python-shell-interpreter "python3"
        python-shell-interpreter-args "-i"
        elpy-rpc-backend "jedi"
        elpy-rpc-python-command "python3")
  ;; (setq python-shell-interpreter "pipenv"
  ;;	python-shell-interpreter-args "run python3"
  ;;	python-shell-prompt-detect-failure-warning nil)
  ;; (add-to-list 'python-shell-completion-native-disabled-interpreters
  ;;           "pipenv")
  (elpy-enable))

(use-package geiser
  :ensure t
  :config
  (set-default 'geiser-scheme-implementation 'racket)
  (set-default 'geiser-active-implementations '(racket))
  (set-default 'geiser-repl-query-on-kill-p nil)
  (set-default 'geiser-repl-query-on-exit-p nil)
  (add-hook 'geiser-mode-hook #'prettify-symbols-mode))

(use-package racket-mode
  :disabled
  :ensure t
  :config
  ;; For racket, use this mode if you prefer drracket
  (add-hook 'racket-mode-hook #'prettify-symbols-mode)
  (let* ((regex-pat "\\.\\(rkt\\|scm\\|ss\\)\\'")
         (term (assoc regex-pat auto-mode-alist)))
    (cond
     ((equal nil term)
      (add-to-list 'auto-mode-alist (cons regex-pat 'racket-mode)))
     (t (setcdr (assoc regex-pat auto-mode-alist) 'racket-mode)))))

(use-package smarty-mode
  :ensure t)

(use-package company-php
  :ensure t)

(use-package php-mode
  :ensure t
  :bind (:map php-mode-map
              ("M-j" . #'pyim-convert-code-at-point))
  :config
  (add-hook 'php-mode-hook
            #'(lambda ()
                "Add `company-ac-php-backend' to buffer-local version of `company-backends'."
                (make-local-variable 'company-backends)
                (push 'company-ac-php-backend company-backends))))

(use-package pyim
  :unless (memq system-type '(windows-nt ms-dos cygwin))
  ;; This will slow down Emacs when on Windows operating system.
  ;; And we can use system input method on Windows system (tested on Windows 10 only), so this package is not needed anymore.
  :ensure t
  :custom
  (pyim-fuzzy-pinyin-alist
   '(("en" "eng") ("in" "ing") ("un" "ung")
     ("on" "ong") ("z" "zh") ("an" "ang")))
  :config
  (message "You should not able to see me")
  ;; 激活 basedict 拼音词库
  (use-package pyim-basedict
    :unless (memq system-type '(windows-nt ms-dos cygwin))
    :ensure nil
    :config (pyim-basedict-enable))

  ;; 五笔用户使用 wbdict 词库
  ;; (use-package pyim-wbdict
  ;;   :ensure nil
  ;;   :config (pyim-wbdict-gbk-enable))

  (setq default-input-method "pyim")

  ;; 我使用全拼
  (setq pyim-default-scheme 'quanpin)

  ;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
  ;; 我自己使用的中英文动态切换规则是：
  ;; 1. 光标只有在注释里面时，才可以输入中文。
  ;; 2. 光标前是汉字字符时，才能输入中文。
  ;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
  (setq-default pyim-english-input-switch-functions
                '(pyim-probe-dynamic-english
                  pyim-probe-isearch-mode
                  pyim-probe-program-mode
                  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation))

  ;; 开启拼音搜索功能
  (pyim-isearch-mode 1)

  ;; 使用 pupup-el 来绘制选词框
  (setq pyim-page-tooltip 'popup)

  ;; 选词框显示5个候选词
  (setq pyim-page-length 5)

  ;; 让 Emacs 启动时自动加载 pyim 词库
  (add-hook 'emacs-startup-hook
            #'(lambda () (pyim-restart-1 t)))
  :bind
  (("M-j" . pyim-convert-code-at-point) ;与 pyim-probe-dynamic-english 配合
   ("C-;" . pyim-delete-word-from-personal-buffer)))

(use-package restart-emacs
  :ensure t)

(use-package undo-tree
  :ensure t)

(use-package realgud
  :ensure t
  :config)

(use-package company-c-headers
  :ensure t
  :config
  (add-to-list 'company-c-headers-path-system "/usr/include/c++/8/"))

(use-package indium
  :ensure t
  :ensure-system-package
  ((indium . "npm install -g indium"))
  :hook (js2-mode . indium-interaction-mode)
  :config
  ;; to define a skeleton to auto insert .indium config file
  )

(use-package js2-mode
  :ensure t
  :mode ("\\.js\\'" . js2-mode)
  :ensure-system-package
  ((node . nodejs)
   npm)
  :bind (:map js-mode-map
              ("M-." . nil)
              :map js2-mode-map
              ("C-k" . #'js2r-kill))
  :config
  (add-hook 'js2-mode-hook
            #'(lambda ()
                (add-hook 'xref-backend-functions
                          #'xref-js2-xref-backend nil t)))

  (defun create-web-project (parent name)
    "Create a empty project using webpack to develop.

After creating the new empty project, go to the example/example and execute \"npm run init\" to install dev dependencies and start to develop your project."
    (interactive (list (read-directory-name "Input location of new project: " nil "" t)
                       (read-string "Input the name of the project: ")))
    (let ((webpack-project-root (format "%s%s/"
                                        (if (char-equal (car (last (string-to-list parent))) ?\c)
                                            parent
                                          (concat parent "/"))
                                        name)))
      (condition-case exn
          (progn
              (copy-directory
               (get-path-to-asset-file "web-conf")
               webpack-project-root nil nil t)
              (write-to-file
               (format (read-from-file (get-path-to-asset-file "web-conf/.gitignore-tpl")) name name)
               (concat webpack-project-root "/" ".gitignore"))

              (write-to-file
               (format (read-from-file (get-path-to-asset-file "web-conf/webpack/.package-json-tpl")) name)
               (concat webpack-project-root "webpack/package.json"))
              (rename-file (concat webpack-project-root "webpack")
                           (concat webpack-project-root name))
              ;; NOTE: avoid the name already exists in root
              ;; (shell-command (format "cd %s && npm init -y" webpack-project-root) nil nil)
              )
        (error
         (when (file-directory-p webpack-project-root)
           (delete-directory webpack-project-root t))
         (prin1 exn))))))


(use-package company-tern
  :unless (memq system-type '(windows-nt ms-dos cygwin))
  :ensure t
  :ensure-system-package
  (tern . "npm install -g tern")
  :hook
  ((js2-mode . tern-mode)
  (js2-mode . company-mode))
  :config
  (add-to-list 'company-backends 'company-tern)
  (define-key tern-mode-keymap (kbd "M-.") nil)
  (define-key tern-mode-keymap (kbd "M-,") nil))

(use-package js2-refactor
  :ensure t
  :hook (js2-mode . js2-refactor-mode)
  :config
  (js2r-add-keybindings-with-prefix "C-c C-r"))

(use-package xref-js2
  :ensure t)

(use-package elfeed
  :ensure t)

(use-package org-pomodoro
  :ensure t)

(use-package magit
  :unless (memq system-type '(windows-nt ms-dos cygwin))
  :bind
  (("C-x g" . #'magit-status))
  :ensure-system-package git
  :ensure t)

(use-package interaction-log
  :unless (memq system-type '(windows-nt ms-dos cygwin))
  :ensure t
  :config
  (interaction-log-mode +1)
  (global-set-key (kbd "C-h C-l")
                  #'(lambda ()
                      (interactive)
                      (display-buffer ilog-buffer-name))))

(use-package engine-mode
  :ensure t
  :config
  (engine-mode t)
  ;; the usage of engine-mode
  ;; https://github.com/hrs/engine-mode
  (defengine github
    "https://github.com/search?ref=simplesearch&q=%s"
    :keybinding "c")
  (defengine google
    "https://google.com/search?ie=utf-8&oe=utf-8&q=%s"
    :keybinding "g")
  (defengine duckduckgo
    "https://duckduckgo.com/?q=%s"
    :keybinding "d")
  (defengine stack-overflow
    "https://stackoverflow.com/search?q=%s")
  (defengine wikipedia
    "http://www.wikipedia.org/search-redirect.php?language=en&go=Go&search=%s"
    :keybinding "w"
    :docstring "Searchin' the wikis."))

;; (use-package ggtags
;;   :ensure t
;;   :bind
;;   (:map ggtags-mode-map
;;         ("C-c g s" . #'ggtags-find-other-symbol)
;;         ("C-c g h" . #'ggtags-view-tag-history)
;;         ("C-c g r" . #'ggtags-find-reference)
;;         ("C-c g f" . #'ggtags-find-file)
;;         ("C-c g c" . #'ggtags-create-tags)
;;         ("C-c g u" . #'ggtags-update-tags))
;;   :config
;;   (add-hook 'c-mode-common-hook
;;             (lambda ()
;;               (when (derived-mode-p 'c-mode 'c++-mode)
;;                 (ggtags-mode 1)))))

;; built-in libraries

;; (use-package auto-insert
;;   :config
;;   TODO js and html
;;   )

(use-package desktop
  :config
  ;; to save session and kill the buffers which start with and end with '*'
  (defun kill-annoying-buffers ()
    (add-hook 'kill-emacs-hook
              #'(lambda ()
                  (mapcar
                   #'(lambda (buf)
                       (condition-case err
                           (or
                            (and (string-match-p
                                  "\\*[[:ascii:][:nonascii:]]+?\\*" (buffer-name buf))
                                 (and (buffer-live-p buf)
                                      (kill-buffer buf))
                                 (buffer-name buf))
                            nil)
                         (error nil)))
                   (buffer-list)))))
  (add-hook 'desktop-save-mode-hook #'kill-annoying-buffers)
  (setq
   desktop-save t)
  (desktop-save-mode 1))

(use-package flyspell
  :hook ((elpy-mode. flyspell-prog-mode)
         (org-mode . flyspell-mode)))

(use-package tramp
  :config
  (setf (cadr (assoc 'tramp-login-args (assoc "ssh" tramp-methods)))
        (append '(("-o" "ServerAliveInterval=60"))
                (cadr (assoc 'tramp-login-args (assoc "ssh" tramp-methods))))))

(use-package lisp-interaction-mode
  :init
  (setcdr (assoc "\\.el\\'" auto-mode-alist) 'lisp-interaction-mode)
  (defadvice eval-buffer (after eval-buffer-with-message activate)
    (message "Buffer evaluation finished!!!"))
  :bind (:map lisp-interaction-mode-map
              ("C-c C-a" . eval-buffer)))

(use-package hideshow
  :hook ((lisp-interaction-mode
          elpy-mode
          php-mode
          web-mode) . hs-minor-mode)
  :config
  (define-key hs-minor-mode-map (kbd "C-c -") #'hs-toggle-hiding))

(use-package ispell
  :config
  (setq ispell-dictionary "english"))

(use-package eshell
  :init (require 'em-smart)
  :bind (("C-c t" . eshell))
  :config
  ;; Pay attention please, "C-q C-c Ret" is the way to
  ;; kill the executing process in eshell.
  ;; (define-key global-map (kbd "C-c t") #'eshell)
  (setq eshell-where-to-jump 'begin
        eshell-review-quick-commands nil
        eshell-smart-space-goes-to-end t))

(use-package eww
  :requires pyim
  :config
  (add-hook 'eww-mode-hook #'(lambda () (read-only-mode -1))))

(use-package etags
  :config
  ;; TODO: use `helm-etags-select' to navigate tags
  (defun generate-or-update-ctags-of-current-buffer ()
    (when (derived-mode-p 'prog-mode)
      (shell-command
       (string-join
        (list "ctags" "-e" "-f" tag-path buffer-file-name) " "))))
  ;; TODO: to check if the major-mode is derived from `prog-mode'
  ;; (derived-mode-p prog-mode)
  ;; TODO: find-file-hook, create ctags file
  ;; TODO: after-save-hook, refresh ctags file
  )

(use-package browse-url
  :config
  (when (executable-find browse-url-chrome-program)
    (setq browse-url-browser-function 'browse-url-chrome)))

(use-package elpa-mirror
  :ensure t
  :config
  (setq elpamr-default-output-directory emacs-elpa-mirror))

(use-package socks
  :disabled
  :init (setq socks-server-on nil)
  :config
  ;; BUG: `toggle-socks-proxy' does not work quite.
  (setq	socks-noproxy '("localhost")
        socks-server '("Default Server" "127.0.0.1" 1080 5)
        socks-address (format
                       "%s://%s:%s" "socks"
                       (cadr socks-server)
                       (caddr socks-server))
        url-proxy-services `(("http" . ,socks-address)
                             ("https" . ,socks-address)
                             ("no_proxy" . "127.0.0.1")
                             ("no_proxy" . "^.*\\(?:baidu\\|zhihu\\)\\.com")))

  (defun toggle-socks-proxy ()
    (interactive)
    (if socks-server-on
        (setq url-gateway-method 'native
              socks-server-on nil)
      (setq url-gateway-method 'socks
            socks-server-on t)))

  (toggle-socks-proxy))

;; (use-package go-mode
;;   :ensure t
;;   :init (add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))
;;   :config
;;   (require 'company)
;;   (require 'company-go)
;;   (setq company-tooltip-limit 20)
;;   (setq company-idle-delay .3)
;;   (setq company-echo-delay 0)
;;   (setq company-begin-commands '(self-insert-command))
;;   (add-hook 'go-mode-hook
;;             (lambda ()
;;               (unless (getenv "GOPATH")
;;                 (setenv "GOPATH" (expand-file-name "~/go/bin")))
;;               (unless (string-match (getenv "GOPATH") (getenv "PATH"))
;;                 (setenv "PATH" (concat (getenv "PATH") ":" (getenv "GOPATH"))))
;;               (set (make-local-variable 'company-backends) '(company-go))
;;               (setq tab-width 4)
;;               (company-mode))))

;; NOTE: To show the path to init file you can view either variable `user-init-file' or `M-:' (expand-file-name "~/.emacs.d/init.el")

(use-package url
  :ensure t
  :config
  (defun guid-generater (&optional guidNum chr2 chr13)
    (interactive (let* ((arg1
                         (read-string "Amount of guids (default 1): "))
                        (arg2
                         (read-string (format "The concat char for guid%s (default as none): "
                                              (if (or
                                                   (string-equal arg1 "1")
                                                   (string-equal arg1 ""))
                                                  ""
                                                "s"))))
                        (arg3
                         (read-string "Do you need {} around the guid (input anything if you want so): ")))
                   `(,arg1 ,arg2 ,arg3)))
    (let ((url-request-data
           (mapconcat (lambda (arg)
                        (when (cadr arg)
                          (concat (url-hexify-string (car arg))
                                  "="
                                  (url-hexify-string (cadr arg)))))
                      `(("guidNum" ,(if (string-equal guidNum "") "1" guidNum))
                        ("chr2" ,(or chr2 ""))
                        ("chr13" ,(or chr13 "")))
                      "&"))
          (url-request-method "POST")
          (url-request-extra-headers
           '(("Content-Type" . "application/x-www-form-urlencoded; charset=UTF-8")
             ("Accept" . "text/html, application/json, text/javascript, */*; q=0.01")
             ("User-Agent" .
              "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0"))))
      (url-retrieve "https://www.qvdv.com/tools/qvdv-guid-_index.html"
                    (lambda (status)
                      (let ((buf (current-buffer)))
                        (switch-to-buffer buf)))))))


;;-----------------------------------------------------------------------------
;; Libraries for development
(use-package websocket
  :unless (memq system-type '(windows-nt ms-dos cygwin)))

;;-----------------------------------------------------------------------------
;; the package setup must be preceding this part
(unless (file-exists-p elpamr-default-output-directory)
  (elpamr-create-mirror-for-installed))

(setq package-archives package-archives-origin)

;; NOTE: In my case, `kill-ring-save' will bound to `M-w' on Windows operating system, it will display `M-w' but binding `M-W', a.k.a, `M-Shift-w' while using QQ;
;; So, please change either your key binding or Emacs key binding for `kill-ring-save'.
;; I prefer changing key binding of QQ for `M-w';

(provide 'init)

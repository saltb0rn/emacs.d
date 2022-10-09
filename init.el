;; -*- lexical-binding: t -*-
;; I put all configurations into a single file and `use-package' to configure packages.


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'package)
(require 'cl-lib)

;;-----------------------------------------------------------------------------
;; packages to install manually
(unless (file-directory-p (expand-file-name "site-lisp" user-emacs-directory))
  (make-directory (expand-file-name "site-lisp" user-emacs-directory)))

(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory) t)

(let ((files (directory-files
              (expand-file-name "site-lisp" user-emacs-directory)
              t
              "^[^.]\\(?:.*\\)\\(?:\\.so\\|\\.elc?\\)?$")))
  (mapcar
   (lambda (file)
     (when (file-directory-p file)
       (add-to-list 'load-path file t)))
   files))
;;-----------------------------------------------------------------------------

;; Put the customized variables into another file to "protect" "init.el" file
(setq custom-file (expand-file-name "emacs-custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" "" custom-file))
(load custom-file)

;; NOTE: about how to use bash on Windows, maybe I can try this thread: https://www.reddit.com/r/emacs/comments/4z8gpe/using_bash_on_windows_for_mx_shell/
;; For example, I use MSYS2 so my `path-to-bash-on-Windows' will be something like 'c:/msys64/usr/bin'
(defcustom path-to-bash-on-Windows nil "Set the path to bash while on Windows")

;; Path to blog
(defcustom path-to-blog nil "Set the path to Blog"
  :set (lambda (variable value)
         (if (string-suffix-p "/" value)
             (set-default variable value)
           (set-default variable (concat value "/")))))

;; NOTE: this one will improve performance while on Windows compared to CMD
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

;; Git on Windows, you'll need to specify path for it.
(defcustom path-to-git-on-Windows nil "Set the path to Git while on Windows")

(when (memq system-type '(windows-nt ms-dos cygwim))
  (when path-to-git-on-Windows
    (add-to-list 'exec-path path-to-git-on-Windows)))

(defcustom path-to-node.js-on-Windows nil "Set the path to node.js on Windows")

(when (memq system-type '(window-nt ms-dos cygwim))
  (when path-to-node.js-on-Windows
    (add-to-list 'exec-path path-to-node.js-on-Windows)))

(defcustom path-to-tern-binary-on-Windows nil "Set the path to tern binary on Windows")

(defcustom path-to-x86-instruction-set-refs nil "Set the path to x86 instruction manuals")

(when (and
       (memq system-type '(windows-nt ms-dos cygwim))
       path-to-tern-binary-on-Windows)
  (setq tern-command (list path-to-tern-binary-on-Windows "--no-port-file")))


(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos cygwin))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when (> emacs-major-version 24)
    (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)))

(when (eq system-type 'windows-nt)
  (set-default 'process-coding-system-alist
               '(("[pP][lL][iI][nN][kK]" gbk-dos . gbk-dos)
                 ("[cC][mM][dD][pP][rR][oO][xX][yY]" gbk-dos . gbk-dos))))

;; (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(package-initialize)

;; update the package metadata if the local cache is missing
(cond ((null package-archive-contents) (package-refresh-contents))
      ((null (file-exists-p package-user-dir)) (package-refresh-contents)))

(setq user-full-name "saltb0rn"
      user-mail-address "asche34@outlook.com")

;; display bell, to flash the frame to represent a beeping/bell
(setq visible-bell t)

;; Set transparency
(setq frame-transparency-alpha '(85 70))
(setq is-frame-transparency t)
(set-face-attribute 'default nil :background "black" :foreground "white")
(add-to-list 'default-frame-alist frame-transparency-alpha)
(defun toggle-frame-transparency ()
  (interactive)
  (if is-frame-transparency
      (progn
        (mapcar
         #'(lambda (frame)
             (set-frame-parameter frame 'alpha frame-transparency-alpha))
         (frame-list))
        (setq is-frame-transparency nil))
    (progn
      (mapcar
       #'(lambda (frame)
           (set-frame-parameter frame 'alpha '(100 100)))
       (frame-list))
      (setq is-frame-transparency t))))
(toggle-frame-transparency)

;; turn on/off the light
(global-set-key (kbd "C-c f a") #'toggle-frame-transparency)

;; 参考 `text-scale-adjust' 编写一个可以动态改变 `frame-transparency-alpha' 的方法
;; 该方法也要更新 `default-frame-alist' 的值

(let ((_ (font-family-list)))
  (cond
   ((string-equal system-type "windows-nt") ; Microsoft Windows
    (when (member "Consolas" _)
      (set-frame-font "Consolas" t t)))
   ((string-equal system-type "darwin") ; macOS
    (when (member "Menlo" _)
      (set-frame-font "Menlo" t t)))
   ((string-equal system-type "gnu/linux") ; linux
    (when (member "DejaVu Sans Mono" _)
      (set-frame-font "DejaVu Sans Mono" t t)))))

;; (setq debug-on-error t)
;; use `toggle-debug-on-error' instead

;; Always load newest byte code
(setq load-prefer-newer t)

;; Reduce the frequency of garbage collection by making it happen
;; on each 100MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold (* 100 1000 1000))

;; Warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; Put backup files into specified directory
(setq temporary-file-directory
      (concat user-emacs-directory "autosaved/"))

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))

(unless (file-exists-p temporary-file-directory)
  (make-directory-internal temporary-file-directory))

(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Disable tool-bar, menu-bar and scroll-bar.
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(menu-bar-mode -1)

(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; note book style
(set-face-attribute 'region nil
                    :background "#e3cf56"
                    :foreground "#000"
                    :underline "#000"
                    :italic t)
(setq-default cursor-type '(hbar . 3))
(set-face-attribute 'cursor nil
                    :background "Gold")
(set-face-attribute 'isearch nil
                    :background "#f0f"
                    :foreground "#fff"
                    :italic t)
(blink-cursor-mode 1)

(condition-case err
    (display-battery-mode 1)
  (file-error
   (message "Permission to access power supply is not granted")))

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
;; (set-default-process-coding-system 'utf-8)
(set-language-environment 'utf-8)
(setq locale-coding-system 'utf-8)
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

;; calculate the checksum of a file
(defun calc-checksum (filename alg)
  (with-temp-buffer
    (insert-file-contents-literally filename)
    (secure-hash alg (current-buffer))))

;; write to file
(defun write-to-file (content file &optional coding-system)
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

(eval-when-compile
  (require 'use-package))

(setq use-package-verbose t)

(unless (memq system-type '(windows-nt ms-dos cygwin))
  (defadvice async-shell-command (around
                                  async-shell-command-ask-password
                                  (command &optional output-buffer error-buffer)
                                  activate)
    (let ((default-directory "/sudo::"))
      (funcall (ad-get-orig-definition 'async-shell-command)
               command output-buffer error-buffer))))

;; this package would install system packages if they were missing.
;; (use-package use-package-ensure-system-package
;;   :ensure t)

;; third-party packages

(use-package epkg
  :ensure t)

(use-package company
  :ensure t
  :hook
  (cond
   ((and (memq system-type '(windows-nt ms-dos cygwin))
         (null path-to-node.js-on-Windows))
    ;; dsiable js2-mode when on Windows because I can not find way to use nodejs
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

;; NOTE: Bad performance for rendering on Windows, the worst part is (nyan-start-animation), you can only disable that.
(use-package nyan-mode
  :if (not (memq system-type '(windows-nt ms-dos cygwin)))
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
                   ;; (add-to-list 'pos e)
                   (push e pos)
                   ))))
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
                    (insert (format "Visit %s" (fic--content-in-line-in-position marker)))
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

;; (use-package helm-gtags
;;   :ensure t
;;   :hook
;;   ((dired-mode
;;     eshell-mode
;;     c-mode
;;     c++-mode) . helm-gtags-mode)
;;   ;; :ensure-system-package (gtags . global)
;;   :bind
;;   (:map helm-gtags-mode-map
;;         ("C-c g a" . #'helm-gtags-in-this-function)
;;         ("C-j" . #'helm-gtags-select)
;;         ("M-." . #'helm-gtags-dwim)
;;         ("M-," . #'helm-gtags-pop-stack)
;;         ("C-c <" . #'helm-gtags-previous-history)
;;         ("C-c >" . #'helm-gtags-next-history)))

(use-package function-args
  :defer t
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
  :defer t
  :ensure t)

(use-package htmlize
  :defer t
  :ensure t)

(use-package dash
  :defer t
  :ensure t)

(use-package ht
  :ensure t)

(use-package maxima
  :ensure t)

(use-package valign
  :ensure t
  :config
  (add-hook 'org-mode-hook #'valign-mode))

(use-package org
  ;; :if (not (null path-to-blog))
  :ensure t
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

  (org-link-set-parameters
   "iframe"
    :follow (lambda (path _)
              (browse-url path))
    :export (lambda (path description back-end)
              (pcase back-end
                ('html
                 (format
                  "<iframe width=\"300\" height=\"300\" src=\"%s\">%s</iframe>"
                  path (or description "")))
                ('latex
                 (format
                  "\\href{%s}{%s}"
                  path (or description "")))
                (t path)
                ))
    :store (lambda ()))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((maxima . t)))

  (setq org-export-coding-system 'utf-8
        ;; path-to-blog "~/Documents/DarkSalt/"
        src-name "src"
        output-name "docs"
        publish-path (concat path-to-blog output-name "/")
        src-path (concat path-to-blog src-name "/")
        posts-path (concat path-to-blog src-name "/posts/")
        tags-path (concat path-to-blog src-name "/tags/")
        files-path (concat path-to-blog src-name "/files/")
        todos-path (concat path-to-blog src-name "/todos/")
        about-path (concat path-to-blog src-name "/about/")
        topic-path (concat path-to-blog src-name "/topics/")
        css-path (concat path-to-blog src-name "/css/")
        js-path (concat path-to-blog src-name "/js/")
        img-path (concat path-to-blog src-name "/img/")
        example-path (concat path-to-blog src-name "/examples/")
        httpd-listings nil
        httpd-root publish-path)

  (setf
   (cdr (assoc 'path org-html-mathjax-options))
   (list "../../../js/mathjax/es5/tex-mml-chtml.js"))

  ;; `publish-all-posts' to publish
  ;; the rest of configuration of `org' is all about the blogging with Emacs.
  ;; the blog provides following features,
  ;; 1. an auto-generated post list ordered by creation date in index;
  ;; 2. an auto-generated post list ordered by capital letter of post name in "posts" category;

  ;; The structure of my blog project:
  ;; .
  ;; ├── conf.d
  ;; │   ├── darksalt.conf
  ;; │   └── passwd
  ;; ├── docker-compose.yml
  ;; ├── Dockerfile
  ;; ├── docs
  ;; │   └── posts
  ;; │       └── index.html
  ;; └── src
  ;;     └── posts
  ;;         └── index.org
  ;;
  ;; `src' is the directory to source files, `docs' is the directory where the compiled files was put


  (defun postamble-dispatcher (scheme)
    (cadar
     (ht-get postambles scheme
             (ht-get postambles 'default))))

  (defun home/up-format-dispatcher (scheme)
    (ht-get home/up-formats scheme
            (ht-get home/up-formats 'default)))

  (defun html-head-dispatcher (scheme)
    (ht-get html-heads scheme
            (ht-get html-heads 'default)))

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
                    ('single
                     (read-html-tpl "single-home-up-format.html"))
                    ('index
                     (read-html-tpl "index-home-up-format.html"))
                    ('page
                     (read-html-tpl "page-home-up-format.html")))

   html-heads (ht
               ('default
                 (read-html-tpl "default-html-head.html"))
               ('single
                (read-html-tpl "single-html-head.html"))
               ('index
                (read-html-tpl "index-html-head.html"))
               ('page
                (read-html-tpl "page-html-head.html")))

   blog-alist
   `(;; ("static"
     ;;  :base-directory ,src-path
     ;;  :base-extension "js\\|css\\|png\\|jpg\\|pdf"
     ;;  :publishing-directory ,publish-path
     ;;  :publishing-function org-publish-attachment
     ;;  ;; :exclude "src"
     ;;  :recursive t)
     ("home"
      :base-directory ,src-path
      :base-extension "org"
      :publishing-directory ,publish-path
      :publishing-function org-html-publish-to-html
      :html-head-extra "<link rel=\"stylesheet\" type=\"text/css\" href=\"css/index.css\"/>\n"
      :recursive t
      :html-head ,(html-head-dispatcher 'index)
      :html-home/up-format ,(home/up-format-dispatcher 'index)
      :html-postamble ,(postamble-dispatcher 'default))
     ("about"
      :base-directory ,about-path
      :base-extension "org"
      :publishing-directory ,(concat publish-path "about/")
      :publishing-function org-html-publish-to-html
      :html-head ,(html-head-dispatcher 'single)
      :html-home/up-format ,(home/up-format-dispatcher 'single)
      :html-postamble ,(postamble-dispatcher 'default)
      :recursive t)
     ("todos"
      :base-directory ,todos-path
      :base-extension "org"
      :publishing-directory ,(concat publish-path "todos/")
      :publishing-function org-html-publish-to-html
      :html-head ,(html-head-dispatcher 'single)
      :html-home/up-format ,(home/up-format-dispatcher 'single)
      :html-postamble ,(postamble-dispatcher 'default)
      :recursive t)
     ("posts"
      :base-directory ,posts-path
      :makeindex t
      :base-extension "org"
      :publishing-directory ,(concat publish-path "posts/")
      :publishing-function org-html-publish-to-html
      :html-head ,(html-head-dispatcher 'page)
      :html-home/up-format ,(home/up-format-dispatcher 'page)
      :html-postamble ,(postamble-dispatcher 'default)
      ;; :exclude "site"  this setting will stop org to compile all posts, so commented it out.
      :recursive t)
     ("tags"
      :base-directory ,tags-path
      :base-extension "org"
      :publishing-directory ,(concat publish-path "tags/")
      :publishing-function org-html-publish-to-html
      :html-head-extra "<link rel=\"stylesheet\" type=\"text/css\" href=\"css/tags.css\"/>\n"
      :recursive t
      :html-head ,(html-head-dispatcher 'single)
      :html-home/up-format ,(home/up-format-dispatcher 'single)
      :html-postamble ,(postamble-dispatcher 'default))
     ("files"
      :base-directory ,files-path
      :base-extension "js\\|css\\|png\\|jpg\\|pdf\\|jpeg\\|gif\\|el"
      :publishing-directory ,(concat publish-path "files/")
      :publishing-function org-publish-attachment
      ;; :exclude "site"
      :recursive t)
     ("topics"
      :base-directory ,topic-path
      :base-extension "css\\|js\\|html\\|png\\|jpg\\|jpeg\\|gif\\|el"
      :publishing-directory ,(concat publish-path "topics/")
      :publishing-function org-html-publish-to-html
      :recursive t
      )
     ("examples"
      :base-directory ,example-path
      :base-extension "css\\|js\\|html\\|png\\|jpg\\|jpeg\\|gif\\|el\\|woff"
      :publishing-directory ,(concat publish-path "examples/")
      :publishing-function org-publish-attachment
      :recursive t
      )
     ("js"
      :base-directory ,js-path
      :base-extension "js\\|woff\\|png\\|jpg\\|jpeg\\|gif"
      :publishing-directory ,(concat publish-path "js/")
      :publishing-function org-publish-attachment
      :recursive t
      )
     ("css"
      :base-directory ,css-path
      :base-extension "css\\|png\\|woff\\|jpg\\|jpeg\\|gif"
      :publishing-directory ,(concat publish-path "css/")
      :publishing-function org-publish-attachment
      :recursive t
      )
     ("img"
      :base-directory ,img-path
      :base-extension "png\\|jpeg"
      :publishing-directory ,(concat publish-path "img/")
      :publishing-function org-publish-attachment
      :recursive t
      )
     ("DarkSalt" :components
      ("home" "about" "js" "img"
       "posts" "files" "tags" "css"
       "todos" "topics" "examples")))
   )

  ;; TODO: skip the modified files when compiling by making use of checksum
  ;; TODO maybe we can implement it with `buffer-hash' or functions in (`secure-hash-algorithms')
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
          ;; (org-html-home/up-format (ht-get home/up-formats 'blog))
          ;; (org-html-head (ht-get html-heads 'blog))
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
    "Search all the posts in `path-to-blog', return a list of posts paths"
    (when (file-directory-p root)
      (let ((files (directory-files root t "^[^.][^.].*$" 'time-less-p))
            (res nil))
        (dolist (file files res)
          (if (file-directory-p file)
              (setq res (append res (retrieve-posts file)))
            (when (and (string-suffix-p ".org" file)
                       (not (string-suffix-p "theindex.org" file))
                       (not (string= (downcase (read-option-from-post file "status" "f")) "wd")))
              (push file res)
              ;; (setq res (add-to-list 'res file)
              )))
        (sort res
              #'(lambda (f1 f2)
                  (string<
                   (format-post-date (read-option-from-post f1 "date" (format-time-string "%Y-%m-%d")))
                   (format-post-date (read-option-from-post f2 "date" (format-time-string "%Y-%m-%d")))))))))

  (defun auto-generate-post-list (root)
    "Search the org files in `path-to-blog', and generate a list of
string consisting of url and title of org-file"
    (let ((files (retrieve-posts root))
          res)
      (dolist (file files res)
        (push (format "[[file:%s][%s]]%s"
                      (url-encode-url
                       (replace-regexp-in-string
                        "\\.org"
                        (format ".html?hash=%s" (calc-checksum file 'md5))
                        (file-relative-name file src-path)))
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
                          "")))
              res))))

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
      (sort (cl-remove-duplicates res :test 'string=) 'string<)))

  (defun posts-of-tag (tag &optional root)
    "Find the posts of tag, return a list of post.
The ROOT points to the directory where posts store on."
    (let ((files (retrieve-posts (or root posts-path)))
          res)
      (dolist (file files res)
        (when (member tag (retrieve-tags-from-post file))
          (push file res)
          ;; (setq res (add-to-list 'res file))
          ))
      (cons tag (list (sort res 'string<)))))

  (defun group-posts-by-tags (root)
    "Return a alist of (TAG . (list POST)).
The ROOT points to the directory where posts store on."
    (let ((tags (tag-list root))
          res)
      (dolist (tag tags res)
        (push (posts-of-tag tag) res)
        ;; (setq res (add-to-list 'res (posts-of-tag tag)))
        )))

  (defun rename-theindex-to-index ()
    "Rename theindex.html to index.html"
    (let ((old-index (concat publish-path "posts/" "theindex.html"))
          (new-index (concat publish-path "posts/" "index.html")))
      (rename-file old-index new-index t)
      (message "Renamed %s to %s" old-index new-index)))

  (defun rewrite-theindex-inc ()
    "Rewrite theindex.inc in `path-to-blog'"
    (write-region
     (mapconcat
      #'(lambda (str) (format "*** %s\n\t" str))
      (auto-generate-post-list posts-path)
      "\n")
     nil
     (concat src-path "theindex.inc")))

  (defun write-posts-to-tag-inc ()
    (let ((grouped-posts (group-posts-by-tags posts-path))
          (tags (tag-list posts-path)))
      (write-region
       (format "
#+TITLE: TAGS\n
#+HTML_HEAD_EXTRA:<link rel=\"stylesheet\" type=\"text/css\" href=\"css/tags.css\"/>\n\n%s"
               (mapconcat
                #'(lambda (tag)
                    (format "- [[file:%s][%s]]"
                            ;; (url-encode-url
                            ;;  (file-relative-name
                            ;;   (concat tags-path tag ".html")
                            ;;   tags-path))
                            (url-encode-url
                             (concat tag ".html"))
                            tag))
                (tag-list posts-path)
                "\n"))
       nil (concat tags-path "index.org"))
      (dolist (tag tags)
        ;; FIXME: should not be any tag like React:FrontEnd.
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

  (defun file-to-base64-url (filename)
    (format "data:%s;base64,%s"
            (mailcap-extension-to-mime
             (file-name-extension filename))
            (base64-encode-string
             (with-temp-buffer
               (insert-file-contents filename)
               (buffer-string)))))
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

;; (use-package geiser
;;   :ensure t
;;   :config
;;   (setq geiser-scheme-implementation 'racket)
;;   (setq geiser-active-implementations '(racket))
;;   (setq geiser-repl-query-on-kill-p nil)
;;   (setq geiser-repl-query-on-exit-p nil)
;;   ;; (set-default 'geiser-racket-binary "C:/Program Files/Racket/Racket.exe")
;;   (add-hook 'geiser-mode-hook #'prettify-symbols-mode))

(use-package racket-mode
  ;; :disabled
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

(use-package glsl-mode
  :ensure t)

(use-package x86-lookup
  :ensure t
  :config
  (when path-to-x86-instruction-set-refs
    (setq x86-lookup-pdf path-to-x86-instruction-set-refs))
  (global-set-key
   (kbd "C-h x") #'x86-lookup))

(use-package nasm-mode
  :ensure t
;  :config
;  (add-hook 'asm-mode-hook 'nasm-mode))
  )

(use-package smarty-mode
  :ensure t)

(use-package company-php
  :ensure t)

(use-package pyim
  :if (not (memq system-type '(windows-nt ms-dos cygwin)))
  :config
  (use-package pyim-basedict
    :ensure t
    :config (pyim-basedict-enable))
  ;; (setq default-input-method "pyim")

  :bind
  (("M-j" . pyim-convert-string-at-point) ;与 pyim-probe-dynamic-english 配合
   ("C-;" . pyim-delete-word-from-personal-buffer)))

(use-package chinese-wbim
  :ensure t
  :config
  ;; Tooltip 暂时还不好用
  (setq chinese-wbim-use-tooltip nil)
  (register-input-method
   "chinese-wbim" "euc-cn" 'chinese-wbim-use-package
   "五笔" "汉字五笔输入法" "wb.txt")
  ;; 用 ; 暂时输入英文
  (require 'chinese-wbim-extra)
  (global-set-key ";" 'chinese-wbim-insert-ascii)
  ;设置默认输入法
  (setq default-input-method 'chinese-wbim))

(use-package restart-emacs
  :ensure t)

;; (use-package undo-tree)

(use-package realgud
  :ensure t)

(use-package company-c-headers
  :ensure t
  :config
  (add-to-list 'company-c-headers-path-system "/usr/include/c++/8/"))

(use-package indium
  :ensure t
  ;; :ensure-system-package
  ;; ((indium . "npm install -g indium"))
  :hook (js2-mode . indium-interaction-mode)
  :config
  ;; to define a skeleton to auto insert .indium config file
  )

(use-package js2-mode
  :ensure t
  :mode ("\\.js\\'" . js2-mode)
  ;; :ensure-system-package
  ;; ((node . nodejs)
  ;;  npm)
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

(use-package web-beautify
  :ensure t)

(use-package org-pomodoro
  :ensure t)

(use-package magit
  :if (not (and
            (memq system-type '(windows-nt ms-dos cygwin))
            (null path-to-git-on-Windows)))
  :bind
  (("C-x g" . #'magit-status))
  ;; :ensure-system-package git
  :ensure t)

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))

(use-package interaction-log
  :ensure t
  :config
  (interaction-log-mode +1)
  (global-set-key (kbd "C-h C-l")
                  #'(lambda ()
                      (interactive)
                      (display-buffer ilog-buffer-name))))

(use-package keyfreq
  :ensure t
  :config
  (keyfreq-mode 1)
  (keyfreq-autosave-mode 1))

(use-package langtool
  :ensure t
  :config
  (setq langtool-language-tool-jar "/home/saltb0rn/LanguageTool/languagetool.jar")
  (global-set-key "\C-x4w" 'langtool-check))

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

(use-package edit-server
  :ensure t
  :commands edit-server-start
  :init (if after-init-time
              (edit-server-start)
            (add-hook 'after-init-hook
                      #'(lambda() (edit-server-start))))
  :config (setq edit-server-new-frame-alist
                '((name . "Edit with Emacs FRAME")
                  (top . 200)
                  (left . 200)
                  (width . 80)
                  (height . 25)
                  (minibuffer . t)
                  (menu-bar-lines . t))))

;; (use-package cedet
;;   ;; :disabled
;;   ;; TODO: write a general setup for c/c++ language
;;   ;; http://alexott.net/en/writings/emacs-devenv/EmacsCedet.html
;;   ;; http://tuhdo.github.io/c-ide.html
;;   ;;
;;   :config
;;   (require 'ede)

;;   (ede-cpp-root-project "Test"
;;                         :name "Test Project"
;;                         :file "~/Documents/code/c/c-demo-project/Makefile"
;;                         :include-path '("/include1"
;;                                         "/include2")
;;                         :system-include-path '("/usr/include"))

;;   (global-ede-mode) ;; ede-minor-mode

;;   (semantic-mode 1)
;;   (global-semantic-idle-completions-mode t) ; semantic-idle-completions-mode
;;   (global-semantic-decoration-mode t) ; semantic-decoration-mode
;;   (global-semantic-highlight-func-mode t) ; semantic-highlight-func-mode
;;   (global-semantic-show-unmatched-syntax-mode t)) ; semantic-show-unmatched-syntax-mode


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
  :disabled
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

(use-package recentf
  :config
  (recentf-mode 1)
  (setq recentf-max-menu-items 25)
  (setq recentf-max-saved-items 25)
  (global-set-key "\C-x\ \C-r" 'recentf-open-files))

(use-package flyspell
  :if (not (memq system-type '(windows-nt ms-dos cygwin)))
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

;; (use-package aria2
;;   :ensure t)

(use-package octave
  :mode ("\\.m$'" . octave-mode)
  :config
  (add-hook
   'octave-mode-hook
   (lambda ()
     (abbrev-mode 1)
     (auto-fill-mode 1)
     (when (eq window-system 'x)
         (font-lock-mode 1)))))

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
  :config
  (add-hook 'eww-mode-hook #'(lambda () (read-only-mode -1)))
  (let ((eww-bookmarks-path
         (expand-file-name "eww-bookmarks" user-emacs-directory)))
    (unless (file-directory-p eww-bookmarks-path)
      (make-directory-internal eww-bookmarks-path))
    (setq eww-bookmarks-directory eww-bookmarks-path))
  (setq eww-search-prefix "https://cn.bing.com/search?ensearch=1&q="))

;; (use-package etags
;;   :config
;;   ;; TODO: use `helm-etags-select' to navigate tags
;;   (defun generate-or-update-ctags-of-current-buffer ()
;;     (when (derived-mode-p 'prog-mode)
;;       (shell-command
;;        (string-join
;;         (list "ctags" "-e" "-f" tag-path buffer-file-name) " "))))
;;   ;; TODO: to check if the major-mode is derived from `prog-mode'
;;   ;; (derived-mode-p prog-mode)
;;   ;; TODO: find-file-hook, create ctags file
;;   ;; TODO: after-save-hook, refresh ctags file
;;   )

(use-package browse-url
  :config
  (when (executable-find browse-url-chrome-program)
    (setq browse-url-browser-function 'browse-url-chrome)))

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

(use-package dictionary
  :ensure t
  :config
  (global-set-key "\C-cs" 'dictionary-search)
  (global-set-key "\C-cm" 'dictionary-match-words))

(use-package so-long
  ;; about the problem to solve:
  ;; https://emacs.stackexchange.com/questions/598/how-do-i-prevent-extremely-long-lines-making-emacs-slow
  ;; about the so-long mode
  ;; https://www.emacswiki.org/emacs/SoLong
  :ensure t
  :config
  (global-so-long-mode 1))

(use-package vlf
  :ensure t
  ;; use `vlf' command open very large file
  ;; for example, to open very large binary and turn on `hexl-mode'
  )

(use-package vscode-icon
  :ensure t
  :commands (vscode-icon-for-file))

(use-package dired-sidebar
  :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :init (add-hook
         'dired-sidebar-mode-hook
         (lambda ()
           (unless (file-remote-p default-directory)
             (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)
  (setq dired-sidebar-subtree-line-prefix ">> ")
  (setq dired-sidebar-theme 'vscode)
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t))

;; (use-package ace-jump-mode
;;   :ensure t
;;   :bind (("C-x j" . ace-jump-mode)))

(use-package avy
  :ensure t
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2)
         ("M-g f" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
         ("M-g e" . avy-goto-word-0)))

(use-package extempore-mode
  :ensure t)

;;-----------------------------------------------------------------------------
;; Libraries for development in Emacs Lisp
;; (use-package websocket
;;   :if (not (memq system-type '(windows-nt ms-dos cygwin))))

;;-----------------------------------------------------------------------------
;; Extensions for some functions
(defun re-kill-buffers (regexp)
  "Kill buffers according to `REGEXP' and return the amounts of killed buffers.
But there is difference between being used as a command and being called in function,
like if you want to kill all html files with matching `.html`, then just input `\.html`
when used as a command instead of `\\.html`."
  (interactive "sInput regexp:\s")
  (let ((buf-list (buffer-list))
        (count 0))
    (dolist (buf buf-list count)
      (when (string-match-p regexp (buffer-name buf))
        (setq count (+ count 1))
        (kill-buffer buf)))))

;;-----------------------------------------------------------------------------
;; configurations for packages which needs to be installed manually
(use-package godot-gdscript
  :config
  (require 'company-godot-gdscript)
  (add-to-list 'company-backends 'company-godot-gdscript)
  (add-hook 'godot-gdscript-mode-hook 'company-mode))

(use-package prettier-js
  :ensure t)

(use-package vue-mode
  :mode "\\.vue\\'"
  :hook (vue-mode . prettier-js-mode)
  :ensure t
  :config
  (setq prettier-js-args '("--parser vue")))

(use-package ox-reveal
  :config
  (setq org-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js"))

(use-package eaf
  :load-path "~/.emacs.d/site-lisp/emacs-application-framework"
  :custom
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker t)
  (browse-url-browser-function 'eaf-open-browser)  
  :config
  (require 'eaf-system-monitor)
  (require 'eaf-browser)
  (require 'eaf-org-previewer)
  (require 'eaf-netease-cloud-music)
  
  (defalias 'browse-web #'eaf-open-browser)
  (eaf-bind-key nil "M-q" eaf-browser-keybinding))

;;-----------------------------------------------------------------------------

;; NOTE: In my case, `kill-ring-save' will bound to `M-w' on Windows operating system,
;; it will display `M-w' but binding `M-W', a.k.a, `M-Shift-w' while using QQ;
;; So, please change either your key binding or Emacs key binding for `kill-ring-save'.
;; I prefer changing key binding of QQ for `M-w';

;; some commands confuse me, like `with-editor-cancel' which will sometimes "delete my file" by "accident"
(put 'with-editor-cancel 'disabled t)
;; (put 'list-timers 'disabled nil)

(provide 'init)

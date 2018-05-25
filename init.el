;; I put all configurations into a single file and `use-package' to configure packages.

(require 'package)

;(add-to-list 'package-archives
;	     '("melpa" . "http://melpa.org/packages") t)

(add-to-list 'package-archives
	     '("melpa" . "http://www.mirrorservice.org/sites/melpa.org/packages/") t)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(package-initialize)

;; update the package metadata if the local cache is missing
(unless (or package-archive-contents
	    (file-exists-p package-user-dir))
  (package-refresh-contents))

(setq user-full-name "saltb0rn"
      user-mail-address "asche34@outlook.com")

;; Set transparency
(set-frame-parameter (selected-frame) 'alpha '(85 85))
(add-to-list 'default-frame-alist '(alpha 85 85))

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
(blink-cursor-mode)

;; Disable startup screen
(setq inhibit-startup-screen t)

;; `(global-linum-mode)' will hang out emacs when use `doc-view-mode', so stop it.

;; revert buffers automaticaly when underlying files are changed externally
(global-auto-revert-mode t)

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

;; Put the customized variables into another file to "protect" "init.el" file
(setq custom-file (expand-file-name "emacs-custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" "" custom-file))
(load custom-file)

;;-----------------------------------------------------------------------------

;; third-party packages configuration
;; use `use-package' to configure

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-verbose t)

(use-package ispell
  :config
  (setq ispell-dictionary "english"))

(use-package tramp
  :config
  (setf (cadr (assoc 'tramp-login-args (assoc "ssh" tramp-methods)))
	(append '(("-o" "ServerAliveInterval=60"))
		(cadr (assoc 'tramp-login-args (assoc "ssh" tramp-methods))))))

(use-package lisp-mode
  :config
  (setcdr (assoc "\\.el\\'" auto-mode-alist) 'lisp-interaction-mode)
  (add-hook 'lisp-interaction-mode-hook
	    #'(lambda ()
		(rainbow-delimiters-mode t)))
  (add-hook 'lisp-interaction-mode-hook
	    #'(lambda () (fic-mode t)))
  (add-hook 'lisp-interaction-mode-hook
	    #'flyspell-prog-mode)
  (add-hook 'lisp-interaction-mode-hook
	  #'(lambda ()
	      (define-key lisp-interaction-mode-map
		(kbd "C-c C-e")
		#'(lambda ()
		    (interactive)
		    (eval-buffer)
		    (message "Buffer evaluation finished!!!!"))))))

(use-package nyan-mode
  :ensure t
  :config
  (nyan-mode)
  (nyan-start-animation)
  (nyan-toggle-wavy-trail))

(use-package zenburn-theme
  :ensure t
  :config
  (when window-system
    (load-theme 'zenburn t)))

(use-package web-mode
  :ensure t
  :config
  (if (null (assoc "\\.html\\?'" auto-mode-alist))
      (add-to-list 'auto-mode-alist (cons "\\.html?\\'" 'web-mode)))
  (setq web-mode-enable-auto-closing t
	web-mode-enable-auto-pairing t))

(use-package fic-mode
  :ensure t
  :config
  (setq fic-highlighted-words
	(quote ("FIXME" "TODO" "BUG" "NOTE" "FIXED"))))

(use-package rainbow-delimiters
  :ensure t)

(use-package highlight-indentation
  :ensure t)

(use-package org
  :ensure t
  :config
  (use-package ox)
  (use-package org-capture)

  (use-package cl)

  (add-hook 'org-mode-hook #'flyspell-mode)

  (setq org-export-coding-system 'utf-8)

  (define-key global-map "\C-cc" 'org-capture)

  (setq project-path "~/Documents/DarkSalt/")

  (setq publish-path (concat project-path "publish/"))

  (use-package simple-httpd
    :ensure t
    :config
    (setq
     httpd-listings nil
     httpd-root publish-path))

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
       (format (concat project-path "posts/%s/%s.org")
	       (format-time-string "%Y/%m" (current-time))
	       slug))))

  (setq org-capture-templates nil)

  (add-to-list 'org-capture-templates
	       `("b" "Blog Post" plain
		 (file capture-blog-post-file)
		  "
#+title: %^{Title}
#+date: %<%Y-%m-%d>
#+index: %^{Concept Index Entry}
#+begin_abstract
%^{Abstract}
#+end_abstract
#+begin_content
%?
#+end_content
"))

  (defun auto-generate-post-list (root)
    "Search the org files in `project-path', and generate a list of
string consisting of url and title of org-file"
    (when (file-directory-p root)
      (let ((files (reverse (directory-files root t "^[^.][^.].*$" 'time-less-p)))
	    (res nil))
	(dolist (file files res)
	  (if (file-directory-p file)
	      (setq res (append res (auto-generate-post-list file)))
	    (when (and (string-suffix-p ".org" file)
		       (not (string-suffix-p "theindex.org" file)))
	      (let ((url-title (format "[[file:%s][%s]]"
				       (replace-regexp-in-string
					"\\.org"
					".html"
					(file-relative-name file project-path))
				       (with-temp-buffer
					 (insert-file-contents file)
					 (goto-char (point-min))
					 (re-search-forward
					  (org-make-options-regexp '("TITLE")))
					 (or (match-string-no-properties 2 nil)
					     (file-name-base file))))))
		(setq res (add-to-list 'res url-title)))))))))

  ;; Put the result of `(auto-generated-post-list)' into `theindex.inc'

  ;; Renaming "theindex.html" to "index.html" manually is annoyed
  (defadvice org-publish-project
      (after org-publish-project-rename-theindex-to-index activate)
    (let ((old-index (concat publish-path "posts/" "theindex.html"))
	  (new-index (concat publish-path "posts/" "index.html")))
      (rename-file old-index new-index t)
    (message "Renamed %s to %s" old-index new-index)))

  (defadvice org-publish-projects
      (after org-publish-projects-rename-theindex-to-index activate)
    (let ((old-index (concat publish-path "posts/" "theindex.html"))
	  (new-index (concat publish-path "posts/" "index.html")))
      (rename-file old-index new-index t)
    (message "Renamed %s to %s" old-index new-index)))

  (setq

   org-html-doctype "html5"

   org-html-home/up-format "
<div id=\"org-div-home-and-up\">
  <nav>
    <a href=\"/\"><img src=\"/images/logo.png\" alt=\"Blog Logo\"/></a>
    <ul>
      <li><a accesskey=\"H\" href=\"%s\"> Home </a></li>
      <li><a accesskey=\"a\" href=\"/posts\"> Posts </a></li>
      <li><a accesskey=\"A\" href=\"/about.html\"> About </a></li>
    </ul>
  </nav>
</div>
"
   org-html-head (concat
		  "<link rel=\"stylesheet\" type=\"text/css\" href=\"../../../css/stylesheet.css\"/>\n"
		  "<link rel=\"icon\" type=\"image/png\" href=\"/images/icon.png\" />")

   org-html-scripts "
<script type=\"text/javascript\">
if(/superloopy\.io/.test(window.location.hostname)) {
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
  ga('create', 'UA-4113456-6', 'auto');
  ga('send', 'pageview');
}</script>"

   org-html-link-home "/"
   org-html-link-up "/"

   org-export-with-toc nil
   org-export-with-author t
   org-export-with-email nil
   org-export-with-creator nil
   org-export-with-date nil
   org-export-with-section-numbers nil

   org-html-preamble nil
   org-html-postamble t
   org-html-postamble-format `(("en"
				,(concat "<p class=\"author\">Author: %a (%e)</p>\n"
					 "<p class=\"date\">Date: %d</p>\n"
					 "<p class=\"creator\">Generated by %c</p>")))
   org-publish-project-alist
   `(("static"
      :base-directory ,project-path
      :base-extension "js\\|css\\|png\\|jpg\\|pdf"
      :publishing-directory ,publish-path
      :publishing-function org-publish-attachment
      :exclude "publish"
      :recursive t)
     ("home"
      :base-directory ,project-path
      :base-extension "org"
      :publishing-directory ,publish-path
      :publishing-function org-html-publish-to-html
      :recursive t
      :exclude "publish")
     ("about"
      :base-directory ,(concat project-path "about/")
      :base-extension "org"
      :publishing-directory ,(concat publish-path "about/")
      :publishing-function org-html-publish-to-html
      :recursive t
      :exclude "publish")
     ("posts"
      :base-directory ,(concat project-path "posts/")
      :makeindex t
      :publishing-directory ,(concat publish-path "posts/")
      :publishing-function org-html-publish-to-html
      :exclude "publish"
      :recursive t)
     ("DarkSalt" :components ("static" "home" "about" "posts")))))

(use-package elpy
  :ensure t
  :config
  (use-package flycheck
    :ensure t)
  (add-hook 'elpy-mode-hook #'fic-mode)
  (add-hook 'elpy-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'elpy-mode-hook #'flycheck-mode)
  (add-hook 'elpy-mode-hook #'flyspell-prog-mode)
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
	elpy-rpc-backend "jedi"
	elpy-rpc-python-command "python3")
  (elpy-enable))

(use-package geiser
  :ensure t
  :config
  (set-default 'geiser-scheme-implementation 'racket)
  (set-default 'geiser-active-implementations '(racket))
  (set-default 'geiser-repl-query-on-kill-p nil)
  (set-default 'geiser-repl-query-on-exit-p nil)
  (add-hook 'geiser-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'geiser-mode-hook #'prettify-symbols-mode)
  (add-hook 'geiser-mode-hook #'fic-mode))

;;(use-package racket-mode
;;  :ensure t
;;  :config
;;  ;; For racket, use this mode if you prefer drracket
;;  (add-hook 'racket-mode-hook #'rainbow-delimiters-mode)
;;  (add-hook 'racket-mode-hook #'prettify-symbols-mode)
;;  (add-hook 'racket-mode-hook #'fic-mode)
;;  (let* ((regex-pat "\\.\\(rkt\\|scm\\|ss\\)\\'")
;;	 (term (assoc regex-pat auto-mode-alist)))
;;    (cond
;;     ((equal nil term)
;;      (add-to-list 'auto-mode-alist (cons regex-pat 'racket-mode)))
;;     (t (setcdr (assoc regex-pat auto-mode-alist) 'racket-mode)))))


(use-package pyim
  :ensure t
  :config
  ;; 激活 basedict 拼音词库
  (use-package pyim-basedict
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

(provide 'init)

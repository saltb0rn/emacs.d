;; -*- lexical-binding: t -*-
;; I put all configurations into a single file and `use-package' to configure packages.

(require 'package)

(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(package-initialize)

;; update the package metadata if the local cache is missing
(unless (or package-archive-contents
            (file-exists-p package-user-dir))
  (package-refresh-contents))

(setq user-full-name "saltb0rn"
      user-mail-address "asche34@outlook.com")

;; Set transparency
(set-frame-parameter (selected-frame) 'alpha '(90 0))
(add-to-list 'default-frame-alist '(alpha 90 0))

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

;; Put the customized variables into another file to "protect" "init.el" file
(setq custom-file (expand-file-name "emacs-custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" "" custom-file))
(load custom-file)

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
  (when window-system
    (load-theme 'zenburn t)))

(use-package fic-mode
  :ensure t
  :hook (elpy-mode
         geiser-mode
         lisp-interaction-mode
         racket-mode
         php-mode)
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
  :ensure t
  :init
  (define-skeleton org-insert-src-block
    "Insert source block in org-mode"
    "Insert the code name of language: "
    "#+BEGIN_SRC " str \n
    "#+END_SRC")
  :requires (htmlize
             dash
             ht
             simple-httpd
             plantuml-mode)
  :bind (:map org-mode-map
         ("C-c i" . 'org-insert-src-block)
         :map global-map
         ("\C-c c" . org-capture))
  :config

  (setq org-export-coding-system 'utf-8
        project-path "~/Documents/DarkSalt/"
        posts-path (concat project-path "posts/")
        tags-path (concat project-path "tags/")
        files-path (concat project-path "files/")
        publish-path (concat project-path "site/")
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

  (setq
   disqus-shortname "darksalt-me"

   postambles (ht
               ('default
                 '(("en" "<p class=\"author\">Author: %a (%e)</p>\n<p class=\"date\">Date: %d</p>\n<p class=\"creator\">%c</p>\n<p class=\"validation\">%v</p>")))
               ('disqus
                `(("en"
                   ,(concat
                    "<div id=\"disqus_thread\"></div>\n<script id=\"dsq-count-scr\" src=\"//"
                    disqus-shortname
                    ".com/count.js\" async></script>\n\n<script>\n\n/**\n*  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.\n*  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables*/\n/*\nvar disqus_config = function () {\nthis.page.url = PAGE_URL;  // Replace PAGE_URL with your page's canonical URL variable\nthis.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable\n};\n*/\n(function() { // DON'T EDIT BELOW THIS LINE\nvar d = document, s = d.createElement('script');\ns.src = 'https://"
                    disqus-shortname
                    ".disqus.com/embed.js';\ns.setAttribute('data-timestamp', +new Date());\n(d.head || d.body).appendChild(s);\n})();\n</script>\n<noscript>Please enable JavaScript to view the <a href=\"https://disqus.com/?ref_noscript\">comments powered by Disqus.</a></noscript>\n<p class=\"author\">Author: %a (%e)</p>\n<p class=\"date\">Date: %d</p>\n<p class=\"creator\">Generated by %c</p>")))))

   home/up-formats (ht
                    ('default
                      "<div id=\"org-div-home-and-up\">\n <a accesskey=\"h\" href=\"%s\"> UP </a>\n |\n <a accesskey=\"H\" href=\"%s\"> HOME </a>\n</div>")
                    ('blog
                     `,(concat
                        "\n<div id=\"org-div-home-and-up\">"
                        "\n  <nav>"
                        "\n    <a href=\"/\"><img src=\"../../../img/logo.png\" alt=\"Logo is on the way\"/></a>"
                        "\n    <ul>\n      <li><a accesskey=\"H\" href=\"%s\"> Home </a></li>"
                        "\n      <!--<li><a accesskey=\"a\" href=\"/posts\"> Posts </a></li>-->"
                        "\n      <li><a accesskey=\"T\" href=\"/tags\"> Tags </a></li>"
                        "\n      <li><a accesskey=\"A\" href=\"/about\"> About </a></li>"
                        "\n    </ul>"
                        "\n  </nav>"
                        "\n</div>\n")))

   html-heads (ht
               ('default "")
               ('blog
                `,(concat
                   "\n<link rel=\"stylesheet\" type=\"text/css\" href=\"../../../css/stylesheet.css\"/>"
                   "\n<link rel=\"icon\" type=\"image/png\" href=\"../../../img/icon.png\" />"
                   "\n<script type=\"text/javascript\" src=\"http://livejs.com/live.js\"></script>"
                   "\n<script src=\"../../../js/main.js\" defer></script>")))

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
      :publishing-directory ,(concat publish-path "about/")
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
     ("DarkSalt" :components ("static" "home" "about" "posts" "files" "tags")))
   )

  (defun publish-all-posts (project &optional force async)
    "Now the project of blog is isolated from `org-publish-project-alist'.
That is, the when calling `org-publish-project' or `org-publish' would not
publish the files in blog, vice versa."
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
      (org-publish-project project))
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
                 ,(concat
                 "#+title: %^{Title}"
                 "#+date: %<%Y-%m-%d>"
                 "#+index: %^{Concept Index Entry}"
                 "#+tags: %^{Tags}"
                 "#+begin_abstract"
                 "%^{Abstract}"
                 "#+end_abstract"
                 "%?")))

  (defun read-option-from-post (post option &optional default)
    "Read OPTION from POST. Return DEFAULT by default."
    (with-temp-buffer
      (insert-file-contents post)
      (goto-char (point-min))
      (if (re-search-forward (concat "^#\\+" option ":[ \t]*\\(.*\\)") nil t)
          (match-string-no-properties 1 nil)
        default)))

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
                   (read-option-from-post f1 "date" (format-time-string "%Y-%m-%d"))
                   (read-option-from-post f2 "date" (format-time-string "%Y-%m-%d"))))))))

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
                                                    "#\\+begin_abstract\\("
                                                    "[[:ascii:][:nonascii:]]*"
                                                    "\\)#\\+end_abstract")
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
                        publish-path (concat project-path "about/")))
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
                (push 'company-ac-php-backend company-backends)
                (company-mode 1))))

(use-package pyim
  :ensure t
  :custom
  (pyim-fuzzy-pinyin-alist
   '(("en" "eng") ("in" "ing") ("un" "ung")
     ("on" "ong") ("z" "zh") ("an" "ang")))
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

(use-package restart-emacs
  :ensure t)

(use-package undo-tree
  :ensure t)

(use-package realgud
  :ensure t
  :config)

(use-package indium
  :disabled
  :ensure t
  :ensure-system-package
  ((indium . "npm install -g indium")))


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
                          #'xref-js2-xref-backend nil t))))

(use-package company-tern
  :ensure t
  :ensure-system-package
  (tern . "npm install -g tern")
  :hook
  ((js2-mode . tern-mode)
   (js2-mode . company-mode))
  :config
  (add-to-list 'company-backends 'company-tern)
  (define-key tern-mode-keymap (kbd "M-.") nil)
  (define-key tern-mode-keymap (kbd "M-,") nil)

  ;; create default config in ~/.tern-config

  )

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
  :bind
  (("C-x g" . #'magit-status))
  :ensure-system-package git
  :ensure t)

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

;; built-in libraries

(use-package desktop
  :config
  ;; to save session and kill the buffers which start with and end with '*'
  (defun kill-annoying-buffers ()
    (add-hook 'kill-emacs-hook
              #'(lambda ()
                  (mapcar
                   #'(lambda (buf)
                       (or
                        (and (string-match-p
                              "\\*[[:ascii:][:nonascii:]]+?\\*" (buffer-name buf))
                             (and (buffer-live-p buf)
                                  (kill-buffer buf))
                             (buffer-name buf))
                        nil))
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
              ("C-c C-e" . eval-buffer)))

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

(provide 'init)

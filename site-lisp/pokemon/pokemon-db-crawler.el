;; -*- lexical-binding: t -*-
(require 'cl-lib)
(require 'dom)
(require 'json)
(require 'subr-x)
(require 'url)

(cl-defstruct response
  status version code
  headers body)

(setq pokemon-db-crawler--page-dirs "download-pages")
(setq pokemon-db-crawler--root-url "https://wiki.52poke.com")
(setq pokemon-db-crawler--download-records "download-records.json")

(defun url-request-sync (url &optional method data headers
                             slient inhibit-cookies timeout)
  "Return the response by requesting the url."
  (let ((url-request-method (or method "GET"))
        (url-request-data data)
        (url-request-extra-headers headers))
    (with-current-buffer
        (url-retrieve-synchronously url slient inhibit-cookies timeout)
      (set-buffer-multibyte t)
      (decode-coding-region (point-min) (point-max) 'utf-8-dos)
      (goto-char (point-min))
      (setq first-line-components
            (split-string
             (buffer-substring-no-properties (point-min) (line-end-position 1))
             " " t " "))
      ;; (setq components (split-string first-line " " t " "))
      (re-search-forward "\n" nil 'move)
      (setq second-line-beginning (point))
      (re-search-forward "^$" nil 'move)
      (make-response
       :version (nth 0 first-line-components)
       :status (nth 2 first-line-components)
       :code (nth 1 first-line-components)
       :headers (buffer-substring-no-properties second-line-beginning (point))
       :body (buffer-substring-no-properties (point) (point-max))))))

(defun response-headers-parse (text)
  (setq lines (split-string text "\n"))
  (setq htable (make-hash-table :test 'equal))
  (mapcar
   (lambda (line)
     (message "line: %s" line)
     (when (string-match "^\\([^:]+\\):\\(.*\\)$" line)
       (setq item (string-trim (downcase (match-string 1 line))))
       (setq value (string-trim (match-string 2 line)))
       (puthash item value htable)))
   lines)
  htable)

;; 下载页面, 只有未下载页面或者页面内容未更新页面才能下载
;; TODO: OPTIONS 貌似是整个返回的, 所以先不判断内容是否最新的了
(defun download-page (url filename)
  (setq download-record-obj
        (let ((json-object-type 'hash-table))
          (json-read-file pokemon-db-crawler--download-records)))
  (if (not (file-exists-p filename))
    (with-temp-buffer
      (setq rsp (url-request-sync url))
      (setq headers (response-headers-parse (response-headers rsp)))
      (puthash filename (gethash "last-modified" headers) download-record-obj)
      (with-temp-buffer
        (insert (json-encode download-record-obj))
        (write-file pokemon-db-crawler--download-records))
      (insert (response-body rsp))
      (write-file filename) t)
    nil))

(defun extract-poke-id (text)
  (when (string-match "#\\([[:digit:]]+\\)" text)
  (match-string 1 text)))

(defun pokedex-filter (dom min-crawler-delay max-crawler-delay)
  (assert (< min-crawler-delay max-crawler-delay))
  (setq tbody (dom-by-tag dom 'tbody))
  (setq trs (dom-by-tag dom 'tr))

  ;; 遍历图鉴里面的条目
  (mapcar
   (lambda (tr)
     (setq tds (dom-by-tag tr 'td))
     (setq poke-id (extract-poke-id (dom-text (nth 0 tds))))
     (setq name-cn (dom-text (dom-by-tag (nth 2 tds) 'a)))
     (setq url (dom-attr (dom-by-tag (nth 2 tds) 'a) 'href))

     (when url
       (message "%s" (format "%s%s" pokemon-db-crawler--root-url url))

       (when (download-pokemon-pages-by-pokedex
              poke-id name-cn
              (format "%s%s" pokemon-db-crawler--root-url url))
         ;; 随机延迟
         (setq secs (+ min-crawler-delay (random (- max-crawler-delay min-crawler-delay))))
         (message "secs: %s" secs)
         (sleep-for secs))))
   trs))

(defun download-pokemon-pages-by-pokedex (poke-id name-cn poke-url)
  (setq dest-file-path
        (format "%s/%s-%s.html"
                pokemon-db-crawler--page-dirs poke-id name-cn))
  (download-page poke-url dest-file-path))

(defun pokemon-db-crawler--dom-next-siblings (dom node)
  "Return the siblings after NODE in DOM."
  (when-let* ((parent (dom-parent dom node)))
    (let ((siblings (dom-children parent))
          found)
      (while (and (not found) siblings)
        (when (eq node (car siblings))
          (setq found t))
        (setq siblings (cdr siblings)))
      siblings)))

;; TODO: 清洗精灵基本信息
(defun pokemon-detail-filter--base-info-filter (node)
  ;; (message "node: %s" node)
  node)

;; TODO: 清洗精灵的种族值信息
(defun pokemon-detail-filter--spec-info-filter (node)
  node)

;; TODO: 清洗精灵升级能学会的信息
(defun pokemon-detail-filter--skill-avaiable-filter (node)
  node)

;; TODO: 清洗精灵可用学习机
(defun pokemon-detail-filter--skill-machine-avaiable-filter (node)
  node)

(defun pokemon-detail-filter (filename)
  (setq dom (with-temp-buffer
              (insert-file-contents filename)
              (libxml-parse-html-region (point-min) (point-max))))

  ;; TODO: 清洗精灵的信息 -------------------------------------------------------------
  (setq pokemon-base-info-raw
        (car (pokemon-db-crawler--dom-next-siblings
         dom
         (car
          (dom-by-class
           (car (dom-by-class dom "mw-parser-output"))
           "prenxt-nav")))))

  (setq pokemon-base-info-raw--next-element
        (car (pokemon-db-crawler--dom-next-siblings dom pokemon-base-info-raw)))

  (if (eq 'table (dom-tag pokemon-base-info-raw--next-element))
      ;; true-branch, 有多种形态
      (let ((nodes
             (seq-filter
              (lambda (el)
                (and
                 (not (equal (dom-attr el 'class) "hide"))
                 (dom-by-class el ".*toggler.*")))
              (dom-by-tag pokemon-base-info-raw--next-element 'tr)))
            (tables
             (mapcar
              (lambda (tr) (cadr (dom-children (car (dom-by-tag tr 'td)))))
              (dom-by-tag pokemon-base-info-raw 'tr)))
            (count 0))
        (mapcar
         (lambda (node)
           (let ((_table (nth count tables)))
             (pokemon-detail-filter--base-info-filter _table)
             (setq count (+ count 1))
             _table))
         nodes))
    ;; false-branch, 没有多种形态
    (pokemon-detail-filter--base-info-filter pokemon-base-info-raw))

  ;; TODO: 清洗种族值 -------------------------------------------------------------
  (setq pokemon-spec-table-raw
        (nth 1 (pokemon-db-crawler--dom-next-siblings
                dom
                (dom-parent dom (car (dom-by-id dom "种族值"))))))

  (if (eq '(dom-tag pokemon-spec-table-raw) 'div)
      ;; true-branch, 多个形态
      (let ((tables (dom-by-tag pokemon-spec-table-raw 'table)))
        (mapcar #'pokemon-detail-filter--spec-info-filter tables))
    ;; false-branch, 没有多形态
    (pokemon-detail-filter--spec-info-filter
     pokemon-spec-table-raw))

  ;; TODO: 清洗可学会的招式 -------------------------------------------------------------
  (setq pokemon-skills-level-up-raw
        (nth 1 (pokemon-db-crawler--dom-next-siblings
                dom
                (dom-parent dom (car (dom-by-id dom "可学会的招式"))))))
  (pokemon-detail-filter--skill-avaiable-filter
   pokemon-skills-level-up-raw)

  ;; TODO: 清洗能使用的招式学习器 -------------------------------------------------------------
  (setq pokemon-skills-machine-available-raw
        (nth 1 (pokemon-db-crawler--dom-next-siblings
                dom
                (dom-parent dom (car (dom-by-id dom "能使用的招式学习器"))))))
  (pokemon-detail-filter--skill-machine-avaiable-filter
   pokemon-skills-machine-available-raw)

  )

(defun main ()
  ;; 文件初始化
  (unless (file-exists-p pokemon-db-crawler--page-dirs)
    (make-directory pokemon-db-crawler--page-dirs))
  (unless (file-exists-p pokemon-db-crawler--download-records)
    (with-temp-buffer
      (insert "{}")
      (write-file pokemon-db-crawler--download-records)))

  ;; 爬取全国图鉴页中每个宝可梦的详情链接
  (setq pokemon-indices-file (format "%s/%s" pokemon-db-crawler--page-dirs "pokemon-db.html"))
  (download-page
   (format "%s%s"
           pokemon-db-crawler--root-url
           "/wiki/%E5%AE%9D%E5%8F%AF%E6%A2%A6%E5%88%97%E8%A1%A8%EF%BC%88%E6%8C%89%E5%85%A8%E5%9B%BD%E5%9B%BE%E9%89%B4%E7%BC%96%E5%8F%B7%EF%BC%89")
   pokemon-indices-file)
  (setq pokemon-indices
        (with-temp-buffer
          (insert-file-contents pokemon-indices-file)
          (libxml-parse-html-region (point-min) (point-max))))

  ;; 爬取特性列表
  (setq ability-indices-file (format "%s/%s" pokemon-db-crawler--page-dirs "ability-db.html"))
  (download-page
   (format "%s%s" pokemon-db-crawler--root-url
           "/wiki/特性列表")
   ability-indices-file)
  (setq ability-indices
        (with-temp-buffer
          (insert-file-contents ability-indices-file)
          (libxml-parse-html-region (point-min) (point-max))))

  ;; 爬取招式列表
  (setq skill-indices-file (format "%s/%s" pokemon-db-crawler--page-dirs "skill-db.html"))
  (download-page
   (format "%s%s" pokemon-db-crawler--root-url
           "/wiki/招式列表")
   skill-indices-file)
  (setq skill-indices
        (with-temp-buffer
          (insert-file-contents skill-indices-file)
          (libxml-parse-html-region (point-min) (point-max))))  

  ;; 爬取每个宝可梦详情页面, 请求数量比较多, 因此设定每次请求间隔为 4 到 8 秒
  (setq tables (dom-by-class pokemon-indices "eplist"))  
  (mapcar (lambda (table) (pokedex-filter table 4 8)) tables)

  ;; TODO: 清洗精灵页面的数据
  (progn
    (pokemon-detail-filter "download-pages/964-海豚侠.html")
    ;; (pokemon-detail-filter "download-pages/001-妙蛙种子.html")
    )

  )

(main)

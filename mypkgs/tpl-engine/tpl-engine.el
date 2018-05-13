(cl-defstruct person name age sex)
(person-age (make-person :name "name" :age 18 :sex "male"))

;; get-tokens : (or text path-to-html-file) -> (list-of string)
(defun get-tokens (text)
  "Split the file text or html into tokens"
  ;(let ((tokens (split-string text "({{.*?}}|{%.?%}|{#.*?#})")))
					;  )
  (split-string "1.2.3" "\.")
  )
;; define the ast-syntax first
;; define an interpreter
(setq text "<p>Welcome, {{user_name}}!</p>
<p>Products:</p>
<ul>
{% for product in product_list %}
    <li>{{ product.name }}:
	{{ product.price|format_price }}</li>
{% endfor %}
</ul>")

(setq res (split-string text "\\({{.*?}}\\|{%.*?%}\\|{#.*?#}\\)"))

(defun evaluate-code (string)
  "evaluate the string elisp code and get the html code"
  (eval (read string))
  )

(let ((lst (list 1 2 3 4 5)))
  (dolist ((var lst))

    )
  )

(concat "a" "b" "c")

(setq res (evaluate-code (shell-command-to-string "python3 /home/salt/.emacs.d/mypkgs/tpl-engine/split.py")))

(defun get-current-line ()
  (buffer-substring-no-properties (line-beginning-position)
				  (line-end-position)))

(get-current-line)

(format "%s" 1)

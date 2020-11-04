(require 'pokemon-stat)
(require 'pokemon-damage)

;; (defstruct specStr-baseStat spec base) ;; 种族 基础点数

;; (defstruct type
;;   name
;;   no-effect-as-attacker->defender     ;; * 0
;;   not-effective-as-attacker->defender ;; * 1/2
;;   very-effective-as-attacker->defender ;; * 2
;;   very-effective-attacker->as-defender ;; * 1/2
;;   no-effective-<-attacker)

;; (defstruct nature
;;   name
;;   up
;;   down)

;; (defstruct pokemon ;; 宝可梦
;;   (remain-base-point 255) ;; 剩余基础点数
;;   (level 50)       ;; 等级
;;   (hp (make-specStr-baseStat :spec 0 :base 0)) ;; 生命
;;   (atk (make-specStr-baseStat :spec 0 :base 0)) ;; 普通攻击
;;   (sp-atk (make-specStr-baseStat :spec 0 :base 0)) ;; 特殊攻击
;;   (def (make-specStr-baseStat :spec 0 :base 0)) ;; 普通防御
;;   (sp-def (make-specStr-baseStat :spec 0 :base 0)) ;; 特殊防御
;;   (spd (make-specStr-baseStat :spec 0 :base 0))  ;; 速度
;;   types                                          ;; 属性
;;   ability                                        ;; 特性
;;   item                                           ;; 物品
;;   nature)                                        ;; 性格

;; (defstruct move
;;   name     ;; 名字
;;   type     ;; 属性
;;   power    ;; 威力
;;   atk-type ;; 特攻还是普攻
;;   ct       ;; 暴击等级
;;   hit      ;; 命中
;;   description ;; 技能描述
;;   )


;; (defstruct weather
;;   name        ;; 名字
;;   description ;; 描述
;;   )

;; (defstruct field
;;   name        ;;
;;   description ;;
;;   )


;; ;;; support dervided type, like fighting type with scrappy ability will be fighting-effective-to-ghost, it is neccessay because it's effective to ghost type

;; ;;(setq const-damage-rate (make-damage-rate))

;; ;; (setq element-rules
;; ;;       (list) ;; gen1 to genN
;; ;;       (list)) ;; genN to genM, etc.

;; (defun pokemon-sorted-by-base-stat (A B)
;;   (< (string-to-number A) (string-to-number B)))

;; (define-derived-mode pokemon-list-mode tabulated-list-mode "Pokemon Dex"
;;   "Pokemon dex"
;;   (interactive)
;;   (setq tabulated-list-format
;;         [
;;          ("No" 5 (lambda (A B) (string< A B)))
;;          ("Pokemon" 18 nil)
;;          ("Type1" 10 nil)
;;          ("Type2" 10 nil)
;;          ("HP" 5 #'pokemon-sorted-by-base-stat)
;;          ("Atk" 5 #'pokemon-sorted-by-base-stat)
;;          ("Def" 5 #'pokemon-sorted-by-base-stat)
;;          ("SpA" 5 #'pokemon-sorted-by-base-stat)
;;          ("SpD" 5 #'pokemon-sorted-by-base-stat)
;;          ("Spd" 5 #'pokemon-sorted-by-base-stat)
;;          ("Ability" 30 nil)
;;          ("Hidden Ability" 15 nil)
;;          ("Gen" 5 #'(lambda (A B) (string< A B)))
;;          ("Area" 18 nil)
;;          ("Description" 0 nil)
;;          ])
;;   (setq tabulated-list-sort-key '("No"))
;;   (tabulated-list-init-header))

;; (defun pokemon-load-dex--read-from-file (&optional generation)
;;   "Read Pokemons data from file"
;;   )

;; (defun pokemon-load-dex (&optional generation async)
;;   (interactive)
;;   (unless (derived-mode-p 'pokemon-list-mode)
;;     (user-error "The current buffer is not a Pokemon Dex"))
;;   (tabulated-list-init-header)
;;   (setq tabulated-list-entries
;;         (list
;;          (list "001"
;;                ["001" "喷火龙" "火" "飞行" "100" "90" "90" "100" "90" "100" "猛火" "太阳之力" "" "" "老喷"])

;;          ;; (list "002"
;;          ;;       ["002" "喷火龙" "火" "飞行" "100" "90" "90" "100" "90" "100" "猛火" "太阳之力" "" "" "老喷"])
;;          ))
;;   (tabulated-list-print))

;; (defun pokemon-dex ()
;;   (interactive)
;;   (let* ((buf (get-buffer-create "*Pokemon Dex*"))
;;         (win (get-buffer-window buf)))
;;     (with-current-buffer buf
;;       (setq buffer-file-coding-system 'utf-8)
;;       (pokemon-list-mode)
;;       (pokemon-load-dex))
;;     (if win
;;         (select-window win)
;;       (switch-to-buffer buf))))

;; (defun get-element-damage-rate
;;     (generation field weather move-type attacker-types attacker-ability defender-types defender-ability critical)
;;   )

;; (defun pokemon-round (arg &optional divisor)
;;   (let ((val (/ arg (or divisor 1) 1.0)))
;;     (if (> (- val (truncate val)) 0.5)
;;         (ceiling val)
;;       (floor val))))

;; (defun pokemon-damage-calculator
;;     (generation
;;      attacker
;;      defender
;;      move
;;      &optional
;;      weather
;;      field)
;;   ;; return rate

;;   ;; attacker/defender-item which affects damage
;;   ;; attacker/defender-ability which affects damage
;;   ;; effects includes field effect and move ability which affects damage

;;   (let ((rate 1))
;;     (when (memq attack-move-type attacker-types)
;;       (setq rate (* rate (damage-rate-attacker-type-match-move-type
;;                           const-damage-rate))))
;;     ;; determine rate according item
;;     ;; determine rate according effects
;;     ;; determine rate according to ability
;;     (loop for dtype in defender-types
;;           do
;;           (setq rate
;;                 (* rate
;;                    (get-element-damage-rate
;;                     generation
;;                     attack-move-type
;;                     dtype)))
;;           )
;;     rate))

;; (defun pokemon-stat (level base invidual effort &optional modifier)
;;   "stat calculator for the generations since gen3"
;;   (let* ((step1 (* base 2))
;;          (step2 (+ step1 invidual))
;;          (step3 (/  effort 4.0))
;;          (step4 (+ step2 step3))
;;          (step5 (* step4 level))
;;          (step6 (/ step5 100.0))
;;          (step7 (+ step6 5))
;;          (step8 (* step7 (or modifier 1))))
;;     (truncate step8)))

;; (defun pokemon-damage-formula
;;     (move-power attacker-level attacker-atk/spA defender-def/spD modifier)
;;   (let* (
;;          (step1 (* 2.00 attacker-level))
;;          (step2 (/ step1 5.00))
;;          (step3 (+ step2 2.00))
;;          (step4 (* step3 move-power))
;;          (step5 (* step4 attacker-atk/spA))
;;          (step6 (/ step5 defender-def/spD 1.00))
;;          (step7 (/ step6 50.00))
;;          (step8 (+ step7 2.00))
;;          (step9 (* step8 modifier 1.00)))
;;     (round step9)))

;; (defun pokemon-damage-modifier-formula ()
;;   )

;; (defun pokemon-damage-calculator (attacker-info defender-info attack-move)
;;   nil
;;   )

(provide 'pokemon)

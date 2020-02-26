(defstruct specStr-baseStat spec base) ;; 种族 基础点数 

(defstruct type
  name
  no-effect-as-attacker->defender     ;; * 0
  not-effective-as-attacker->defender ;; * 1/2
  very-effective-as-attacker->defender ;; * 2
  very-effective-attacker->as-defender ;; * 1/2
  no-effective-<-attacker)

(defstruct nature
  name
  up
  down)

(defstruct pokemon ;; 宝可梦
  (remain-base-point 255) ;; 剩余基础点数
  (level 50)       ;; 等级
  (hp (make-specStr-baseStat :spec 0 :base 0)) ;; 生命
  (atk (make-specStr-baseStat :spec 0 :base 0)) ;; 普通攻击
  (sp-atk (make-specStr-baseStat :spec 0 :base 0)) ;; 特殊攻击
  (def (make-specStr-baseStat :spec 0 :base 0)) ;; 普通防御
  (sp-def (make-specStr-baseStat :spec 0 :base 0)) ;; 特殊防御
  (spd (make-specStr-baseStat :spec 0 :base 0))  ;; 速度
  types                                          ;; 属性
  ability                                        ;; 特性
  item                                           ;; 物品
  nature)                                        ;; 性格

(defstruct move
  name     ;; 名字
  type     ;; 属性
  power    ;; 威力
  atk-type ;; 特攻还是普攻
  ct       ;; 暴击等级
  hit      ;; 命中
  description ;; 技能描述
  )


(defstruct weather
  name        ;; 名字
  description ;; 描述
  )

(defstruct field
  name        ;;
  description ;;
  )


;;; support dervided type, like fighting type with scrappy ability will be fighting-effective-to-ghost, it is neccessay because it's effective to ghost type

(setq const-damage-rate (make-damage-rate))

(setq element-rules
      (list) ;; gen1 to genN
      (list)) ;; genN to genM, etc.


(defun get-element-damage-rate
    (generation field weather move-type attacker-types attacker-ability defender-types defender-ability critical)
  ;; (let ((element-rule (nth (- n 1) element-rules))
  ;;       (same-type-attack-bonus (if (equal attack-type move-type) 1.5 1)))
  ;;   (loop for r in element-rule
  ;;         when (let ((mtype (element-rate-move-type r))
  ;;                    (dtype (element-rate-denfender-type r)))
  ;;                (and (equal mtype move-type)
  ;;                     (equal dtype defender-type)))
  ;;         return (element-rate-rate r)))
  )

(defun pokemon-damage-calculator
    (generation
     attacker
     defender
     move
     &optional
     weather
     field)
  ;; return rate

  ;; attacker/defender-item which affects damage
  ;; attacker/defender-ability which affects damage
  ;; effects includes field effect and move ability which affects damage

  (let ((rate 1))
    (when (memq attack-move-type attacker-types)
      (setq rate (* rate (damage-rate-attacker-type-match-move-type
                          const-damage-rate))))
    ;; determine rate according item
    ;; determine rate according effects
    ;; determine rate according to ability
    (loop for dtype in defender-types
          do
          (setq rate
                (* rate
                   (get-element-damage-rate
                    generation
                    attack-move-type
                    dtype)))
          )
    rate))

(defun pokemon-damage-calculator (attacker-info defender-info attack-move)
  nil
  )

(provide 'pokemon-calculator)

;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

(require 'pokemon)

(defmacro calc-damage-hp-ratio (lvl spec-a spec-d mov-power spec-h &rest mods)
  `(/ (reduce
       (lambda (v1 v2) (+ v1 v2))
       (mapcar (lambda (v) (/ v
                              (pokemon-hp-stat
                               ,lvl
                               ,spec-h
                               (or (plist-get (list ,@mods) :h-ivs) 0)
                               (or (plist-get (list ,@mods) :h-evs) 0))
                              1.0))
               (pokemon-damage-calc ,lvl
                                    (pokemon-base-stat
                                     ,lvl ,spec-a
                                     (or (plist-get (list ,@mods) :a-ivs) 0)
                                     (or (plist-get (list ,@mods) :a-evs) 0)
                                     (or (plist-get (list ,@mods) :a-nature) 1))
                                    (pokemon-base-stat
                                     ,lvl ,spec-d
                                     (or (plist-get (list ,@mods) :d-ivs) 0)
                                     (or (plist-get (list ,@mods) :d-evs) 0)
                                     (or (plist-get (list ,@mods) :d-nature) 1))
                                    ,mov-power
                                    ,@mods)))
      16))

;; https://tieba.baidu.com/p/8019499150

(calc-damage-hp-ratio 50 90 90 90 90 :d-ivs 31 :h-ivs 31)
;; 90 spec-atk(zero iv), 90 mov-power, 90 spec-def(max ivs), 90 spec-hp(max ivs)
(calc-damage-hp-ratio 50 90 90 90 90 :d-ivs 31 :h-ivs 31) ;; 0.20
;; 90 spec-atk, 90 mov-power, 90 spec-def, 90 spec-hp, all with max ivs
(calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :d-ivs 31 :h-ivs 31) ;; 0.23
;; 90 spec-atk(max ivs and evs), 90 mov-power, 90 spec-def(max ivs), 90 spec-hp(max ivs)
(calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252 :d-ivs 31 :h-ivs 31)
;; 90 spec-atk(max ivs and evs, with good nature), 90 mov-power, 90 spec-def(max ivs), 90 spec-hp(max ivs)

;; 攻击/特攻/防御/特防, 满个体约等于 * 1.2, 满努力约等于 * 1.2, 合起来约等于 1.2 * 1.2 ~ 1.5
;; HP 满个体约等于 * 1.1, 满努力约等于 * 1.1, 合起来约等于 1.1 * 1.1 ~ 1.2

(defun pokemon-base-stat-gradient-with-iv-ev ()
  (mapcar
   (lambda (v)
     (message "spec-base %s, ratio: %s"
              v
              (/
               (pokemon-base-stat 50 v 31 252)
               (pokemon-base-stat 50 v 0 0)
               1.0)))
   ;; (list 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230)
   (list 13 15 18 21 25 30 36 43 52 62 75 90 108 110 120 130 156 187 224)))

(pokemon-base-stat-gradient-with-iv-ev)


(defun pokemon-hp-stat-gradient-with-iv-ev ()
  (mapcar
   (lambda (v) (/
                (pokemon-hp-stat 50 v 31 252)
                (pokemon-hp-stat 50 v 0 0)
                1.0))
   ;; (list 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230)
   (list 13 15 18 21 25 30 36 43 52 62 75 90 108 110 120 130 156 187 224)
   ))

(pokemon-hp-stat-gradient-with-iv-ev)
;; 但当种族值大于一定程度时, 满努力个体的收益就达不到 2 段 的收益了,
;; 过了 120 后面的加成都在 1.3 到 1.2 范围内, 在 120 之后, 我们就把收益定义为 1 段


(defun pokemon-base-stat-gradient ()
  (mapcar
   (lambda (v)
     (message "spec %s: ratio: %s"
              v
              (/
               (pokemon-base-stat 50 v 0 0)
               (pokemon-base-stat 50 90 0 0)
               1.0)
              ))
   ;; (list 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230)
   (list 62 75 90 108 110 120 130 156 187 224)
   ))

;; 统一采用poke round
;; 种族值, 实际种族值靠近哪个就取哪个
;; 62  -> - 2
;; 75  -> - 1
;; 90  -> + 0
;; 108 -> + 1
;; 130 -> + 2
;; 156 -> + 3
;; 187 -> + 4
;; 224 -> + 5

(pokemon-base-stat-gradient)


(defun pokemon-hp-stat-gradient ()
  (mapcar
   (lambda (v)
     (message "spec %s: ratio: %s"
              v
              (/
               (pokemon-hp-stat 50 v 0 0)
               (pokemon-hp-stat 50 90 0 0)
               1.0)
              ))
   ;; (list 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230)
   (list 62 75 90 108 110 120 130 156 187 224)
   ))

(pokemon-hp-stat-gradient)


;; 刻度 ------------------------------------------------------------------------- start

;; level -5 往上开始不过 10 之一了
;; level -5
(calc-damage-hp-ratio 50 75 90 90 90 :a-boosts/drops-lvl -2) ;; 0.1

;; level -4

(calc-damage-hp-ratio 50 90 90 90 90 :a-boosts/drops-lvl -2) ;; 0.12

;; level -3
(calc-damage-hp-ratio 50 75 90 90 90 :a-boosts/drops-lvl -1) ;; 0.145

;; level -2
(calc-damage-hp-ratio 50 75 90 75 90) ;; 0.175
;; * 1.2
;; level -1
(calc-damage-hp-ratio 50 75 90 90 90) ;; 0.21
;; * 1.2
;; level 0
(calc-damage-hp-ratio 50 90 90 90 90) ;; 0.249 ~ 0.25
;; * 1.2
;; 攻击方方宝可梦满个体攻击
;; level 1
(calc-damage-hp-ratio 50 108 90 90 90) ;; 0.30

;; * 1.3 ~ 1.2
;; 攻击方宝可梦满个体满努力攻击
;; level 2
(calc-damage-hp-ratio 50 108 75 90 90) ;; 0.36


;; 攻击方宝可梦满个体满努力攻击, 带性格修正, 极限
;; * 1.1
;; < level 3
(calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252 :a-nature 1.1) ;; 0.41 ~ 0.40

;; 攻击方宝可梦满个体满努力攻击, 假设有个木炭之类的 1.2 倍加成
;; level 3
(* (calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252) 1.2) ;; 0.447 ~ 0.43
;; 攻击方宝可梦满个体满努力攻击, 假设有个命玉的 1.3 倍加成
;; > level 3
(* (calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252) 1.3) ;; 0.487 ~ 0.46

(* (calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252 :a-nature 1.1) 1.2)

;; 攻击方宝可梦满个体满努力攻击, 攻击上升 1 段
;; level 4
(calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252 :a-boosts/drops-lvl 1) ;; 0.55

;; level 5
(calc-damage-hp-ratio 50 108 90 90 90 :a-ivs 31 :a-evs 252 :a-boosts/drops-lvl 1) ;; 0.62

;; level 6
(calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252 :a-boosts/drops-lvl 2) ;; 0.735

;; level 7
(calc-damage-hp-ratio 50 108 90 90 90 :a-ivs 31 :a-evs 252 :a-boosts/drops-lvl 2) ;; 0.83

;; level 8
(calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252 :a-boosts/drops-lvl 3) ;; 0.92

;; level 10
(calc-damage-hp-ratio 50 90 90 90 90 :a-ivs 31 :a-evs 252 :a-boosts/drops-lvl 4) ;; 1.1

;; 刻度 ------------------------------------------------------------------------- end

;; 验证

;; 1) 满个体满努力攻击的故勒顿使用终极冲击 攻击 满个体满努力防御和HP的盐石巨灵
(calc-damage-hp-ratio 50 135 130 150 100
                      :type-eff-mod (expt 2 -1)
                      :a-ivs 31 :a-evs 252 :d-ivs 31 :d-evs 252
                      :h-ivs 31 :h-evs 252)

;; 攻击 135 lvl 2, 满个体努力 +1, 技能威力 +3
;; 防御 130 lvl 2, 满个体努力 +1, 生命 100 介于 +0 和 +1 之间, 接近 108, 取等级 1, 满个体努力+1
;; 岩石系 2 倍抵抗一般系列 -4
;; 2 + 1 + 3 - 2 - 1 - 1 - 4 = -3


;; 2) 满个体努力特攻的红莲铠骑使用铠农炮 攻击 满个体特防御HP的三首恶龙
(calc-damage-hp-ratio 50 125 90 120 92
                      :a-ivs 31 :a-evs 252
                      :d-ivs 31 :h-ivs 31
                      :same-type-atk-bouns-mod pokemon-mod-x1dot5
                      :type-eff-mod (expt 2 -1))

;; 先分析攻击方
;; 攻击 125 微小于 130, 远大于 108, 因此 +2, 由于 125 > 110, 所以特攻的满努力个体 +1, 技能为例同样技 +2
;; 红莲铠骑有火属性, 铠农炮也是火属性, 因此同类型加成 + 2
;; 再分析防御方
;; 防御 90 lvl 0, 满个体 + 1 抗性 x2, 也就是 +4, HP 92 lvl 0
;; 2 + 1 + 2 + 2 - 4 - 1 = 2
;; 实际上微小于 level 3

;; 3) 满个体努力攻击的风速狗使用神速 攻击 盐石巨灵
(calc-damage-hp-ratio 50 110 130 80 100
                      :type-eff-mod (expt 2 -1)
                      :a-ivs 31 :a-evs 252
                      :d-ivs 31 :h-ivs 31)

;; 先分析攻击方
;; 攻击 110 稍微大于 108, 因此等级 +1, 满个体努力 +2, 技能为例远小于 90, 微大于 75, 等级 -1, 攻击方等级为 2
;; 防御方
;; 130 +2, 防御 130 大于 110, 满个体加成不足等级1, 忽略不计, HP 100 + 1, 满个体加成也不足等级1, 最总等级 3
;; 一般打岩系 2 倍抵抗, -4
;; 2 - 3 - 4 = -6
;; 伤害在 1 / 10 以下

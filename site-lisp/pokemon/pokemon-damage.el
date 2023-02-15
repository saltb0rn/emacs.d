;; -*- lexical-binding: t -*-
(require 'pokemon-utils)

;; https://www.trainertower.com/dawoblefets-damage-dissertation/

(defun pokemon-base-damage (atker-lvl atk/spa def/spd mov-power &optional a-boosts/drops-lvl d-boosts/drops-lvl)
  (let* ((a-boosts/drops-mod (cond
                              ((null a-boosts/drops-lvl) (list 2 2 1.0))
                              ((> a-boosts/drops-lvl 0) (list (+ a-boosts/drops-lvl 2) 2 1.0))
                              ((< a-boosts/drops-lvl 0) (list 2 (+ (* -1 a-boosts/drops-lvl) 2) 1.0))
                              (t (list 2 2 1.0))))
         (d-boosts/drops-mod (cond
                              ((null d-boosts/drops-lvl) (list 2 2 1.0))
                              ((> d-boosts/drops-lvl 0) (list (+ d-boosts/drops-lvl 2) 2 1.0))
                              ((< d-boosts/drops-lvl 0) (list 2 (* -1 (+ d-boosts/drops-lvl 2)) 1.0))
                              (t (list 2 2 1.0))))
         (step1
          (pokemon-flooring
           (*
            (pokemon-flooring (+ (* 2 atker-lvl) 10) 5)
            mov-power
            (pokemon-flooring (* atk/spa (apply #'/ a-boosts/drops-mod))))
           (pokemon-flooring (* def/spd (apply #'/ d-boosts/drops-mod)))))
         (step2
          (pokemon-flooring step1 50)))
    (+ 2 step2)))

;; 在不考虑小数点取整的话, 基础伤害的公式可以写成这样: 1/250 * (2 * atker-lvl + 10) * (atk/spa / def/spd) * mov-dmg + 2.
;; 由于对战是有级别限制的, 比如在 50 级是, 1/250 * (2 * atker-lvl + 10) 是可以直接固定成 0.44.
;; 所以 50 级别的基伤计算变成: 0.44 * mov-dmg * (atk/spa / def/spd) + 2.
;; 我们把 (atk/spa / def/spd) 看作一个 mod, 也就是说这个 mod 的值得达到 25 / 11, 也就是约等于 2.27 才能得到完整的招式伤害

;; 作为进攻方法, 应该注意伤害攻击方法努力值的分配, 还得注意和速度努力值的平衡
;; 如何在对战中进行伤害估算: https://www.bilibili.com/read/mobile?id=7802299

;; 作为防御方, 应该注意如何平衡 hp/def/spd 三者的分配来达到最大的耐久

;; 我们把 k = \fraction{(a_{0} + a_{1} + a_{2} + ... + a_{n})}{n}, 那么 k \ge nth-root(a_{0} * a_{1} * a_{2} * ... * a_{n}), 这就是 AM-GM 不等式
;; 这条不等式可以变换成 k \ge (a_{0} * a_{1} * a_{2} * ... * a_{n})^{1/n} \rightarrow k^{n} \ge (a_{0} * a_{1} * a_{2} * ... * a_{n})
;; 只有 a_{0} = a_{1} = a_{2} = ... = a_{n} = k 时, k^{n} = a_{0} * a_{1} * a_{2} * ... * a_{n} 达到最大值.
;; AM-GM 不等式的介绍和证明: https://artofproblemsolving.com/wiki/index.php/AM-GM_Inequality

;; https://www.gcores.com/articles/104949

(defun pokemon--chain-mods (mods)
   (reduce
   (lambda (old-comb-mod next-mod)
     (pokemon-normal-round (/ (* old-comb-mod next-mod) pokemon-mod-denominator)))
   mods))

(defun pokemon--damage-calc (
     base-damage
     spread-mov-mod
     parental-bond-mod
     weather-mod
     critical-mod
     same-type-atk-bouns-mod
     type-eff-mod
     burn-mod
     final-mods
     protect-mod)
  (let* ((step-spread-mov-mod ;; spread mov mod
          (pokemon-round (* base-damage (/ spread-mov-mod pokemon-mod-denominator))))

         (step-parental-bond-mod ;; only applied the second hit of the move
          (pokemon-round
           (* step-spread-mov-mod (/ parental-bond-mod pokemon-mod-denominator))))

         (step-weather-mod ;; weather mod
          (pokemon-round
           (* step-parental-bond-mod  (/ weather-mod pokemon-mod-denominator))))

         (step-critical-hit-mod (pokemon-round (* step-weather-mod critical-mod)))

         ;; from now on, the calc result will be a list
         (step-random-mod ;; random mod
          (let ((res nil)
                (random-factor 0))
            (while (<= random-factor 15)
              (push
               (pokemon-flooring (* step-critical-hit-mod (- 100 random-factor)) 100) res)
              (setq random-factor (1+ random-factor)))
            res))

         (step-same-type-atk-bouns-mod ;; same type mod
          (mapcar
           (lambda (dmg)
             (pokemon-round (* dmg (/ same-type-atk-bouns-mod pokemon-mod-denominator))))
           step-random-mod))

         (step-type-eff-mod ;; type eff mod
          (mapcar
           (lambda (dmg)
             ;; 值应该是 2^n, 如果有一个克制, 那么 n = 1
             ;; 如果有一个被克制那么就是 n = -1
             ;; 一个单纯有效就是 n = 0
             (pokemon-flooring (* dmg type-eff-mod)))
           step-same-type-atk-bouns-mod))

         ;; 使用特攻的宝可梦不受到该修正影响
         (step-burn-mod (mapcar
                          (lambda (dmg)
                            (pokemon-round
                             (* dmg (/ burn-mod pokemon-mod-denominator))))
                          step-type-eff-mod))

         (step-final-mods ;; final mods, wrong
          (let ((mod (pokemon--chain-mods
                      (cons pokemon-mod-x1 final-mods))))
            (mapcar
             (lambda (dmg)
               (pokemon-round (* dmg (/ mod pokemon-mod-denominator))))
             step-burn-mod)))

         (step-protect-mod ;; 保护被Z招式或者极巨化穿透时
          (mapcar
           (lambda (dmg)
             (pokemon-round (* dmg (/ protect-mod pokemon-mod-denominator))))
           step-final-mods))

         (step-one-damage-check  ;; one damage check
          (mapcar
           (lambda (v) (or (and (= 0 v) 1) v))
           step-protect-mod))

         (step-ffff-damage-check  ;; 65535 damage check
          (mapcar
           (lambda (v) (or (and (< v #xffff) v) (% v #xffff)))
           step-one-damage-check))
         )
    step-ffff-damage-check))

(defun pokemon--damage-calc-mod-check (plst)
  (pcase plst
    (`nil t)
    (`(,key ,value) t)
    (`(,key ,value . ,rest)
     (pokemon--damage-calc-mod-check rest))))

;;;###autoload
(defmacro pokemon-damage-calc (atker-lvl atk/spa def/spd mov-power &rest mods)
    `(if (pokemon--damage-calc-mod-check (list ,@mods))
         (pokemon--damage-calc
          (pokemon-base-damage
           ,atker-lvl
           ,atk/spa                         ;; 受到攻击 mods 影响, 包括能力升降低, 特性加成, 道具影响
           ,def/spd                         ;; 同攻击 mods
           ,mov-power ;; 受到场地和天气的影响, 有些特性也会影响, 比如妖精皮肤在同类加成 1.2 倍, 招式也会有影响, 比如帮助加成 1.5 倍
           (plist-get (list ,@mods) :a-boosts/drops-lvl) ;; 攻击能力升降
           (plist-get (list ,@mods) :d-boosts/drops-lvl) ;; 防御能力升降
           )
          (or (plist-get (list ,@mods) :spread-mov-mod) pokemon-mod-x1)
          (or (plist-get (list ,@mods) :parental-bond-mod) pokemon-mod-x1)
          (or (plist-get (list ,@mods) :weather-mod) pokemon-mod-x1)
          (or (plist-get (list ,@mods) :critical-mod) 1)
          (or (plist-get (list ,@mods) :same-type-atk-bouns-mod) pokemon-mod-x1)
          (or (plist-get (list ,@mods) :type-eff-mod) 1)
          (or (plist-get (list ,@mods) :burn-mod) pokemon-mod-x1)
          (or (plist-get (list ,@mods) :final-mods) nil)
          (or (plist-get (list ,@mods) :protect-mod) pokemon-mod-x1))
       0))

;; examples:
;; (pokemon-damage-calc 50 232 109 120
;;                       :same-type-atk-bouns-mod pokemon-mod-x1dot5
;;                       :final-mods '(4096 2732 2048 3072 5324))

(provide 'pokemon-damage)

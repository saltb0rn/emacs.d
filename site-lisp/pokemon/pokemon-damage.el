(require 'pokemon-utils)

;; https://www.trainertower.com/dawoblefets-damage-dissertation/

(defun pokemon-base-damage (atker-lvl atk/spa def/spd mov-dmg)
  (let* ((step1
          (pokemon-flooring
           (*
            (pokemon-flooring (+ (* 2 atker-lvl) 10) 5)
            mov-dmg
            atk/spa)
           def/spd))
         (step2
          (pokemon-flooring step1 50)))
    (+ 2 step2)))

;; 在不考虑小数点取整的话, 基础伤害的公式可以写成这样: (1/50 * (2 * atker-lvl + 10) / 5) * (atk/spa / def/spd) * mov-dmg + 2.
;; 由于对战是有级别限制的, 比如在 50 级是, (1/50 * (2 * atker-lvl + 10) / 5) 是可以直接固定成 0.44.
;; 所以 50 级别的基伤计算变成: 0.44 * mov-dmg * (atk/spa / def/spd) + 2.
;; 我们把 (atk/spa / def/spd) 看作一个 mod, 也就是说这个 mod 的值得达到 25 / 11, 也就是约等于 2.27 才能得到完整的招式伤害

(defun pokemon-mul-mods (val &rest mods)
  (let ((final-mod
         (pokemon--chain-mods (cons pokemon-mod-denominator mods))))
    (pokemon-round (* val final-mod) pokemon-mod-denominator)))

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
             ;; 值应该是 2^n, 如果有一个克制, 那么 n = 1, 如果有一个被克制那么就是 n = -1, 一个单纯有效就是 n = 0
             (pokemon-flooring (* dmg type-eff-mod)))
           step-same-type-atk-bouns-mod))
         
         (step-burn-mod (mapcar
                          (lambda (dmg)
                            (pokemon-round
                             (* dmg (/ burn-mod pokemon-mod-denominator))))
                          step-type-eff-mod))
         
         (step-final-mods ;; final mods, wrong
          (let ((mod (pokemon--chain-mods final-mods)))
            (mapcar
             (lambda (dmg)
               (pokemon-round (* dmg (/ mod pokemon-mod-denominator))))
             step-burn-mod)))
         
         (step-one-damage-check  ;; one damage check
          (mapcar
           (lambda (v) (or (and (= 0 v) 1) v))
           step-final-mods)))
    step-one-damage-check))

(defun pokemon-damage-calc (
     atker-lvl
     atk/spa                            ;; 攻击 mods, 比如战斗种能力的升降, 以及讲究头带, 水珠等道具影响
     def/spd                            ;; 防御 mods, 和攻击 mods 类似
     mov-dmg                            ;; 招式伤害也有 mods, 比如地形, 帮手
     ;; general mods
     &optional
     spread-mov-mod
     parental-bond-mod
     weather-mod
     critical-mod
     same-type-atk-bouns-mod
     type-eff-mod
     burn-mod
     final-mods
     protect-mod)
  (let ((base-damage
         (pokemon-base-damage
          atker-lvl
          atk/spa
          def/spd
          mov-dmg)))
    (pokemon--damage-calc
     base-damage
     (or spread-mov-mod pokemon-mod-denominator)
     (or parental-bond-mod pokemon-mod-denominator)
     (or weather-mod pokemon-mod-denominator)
     (or critical-mod 1)
     (or same-type-atk-bouns-mod pokemon-mod-denominator)
     (or type-eff-mod 1)
     (or burn-mod pokemon-mod-denominator)
     (or final-mods nil)
     protect-mod)))

(provide 'pokemon-damage)

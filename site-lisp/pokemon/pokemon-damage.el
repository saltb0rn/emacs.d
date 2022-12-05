(require 'pokemon-utils)

;; https://www.trainertower.com/dawoblefets-damage-dissertation/

(defun pokemon-base-damage (atker-lvl atk/spa def/spd mov-power)
  (let* ((step1
          (pokemon-flooring
           (*
            (pokemon-flooring (+ (* 2 atker-lvl) 10) 5)
            mov-power
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
             ;; 值应该是 2^n, 如果有一个克制, 那么 n = 1
             ;; 如果有一个被克制那么就是 n = -1
             ;; 一个单纯有效就是 n = 0
             (pokemon-flooring (* dmg type-eff-mod)))
           step-same-type-atk-bouns-mod))

         (step-burn-mod (mapcar
                          (lambda (dmg)
                            (pokemon-round
                             (* dmg (/ burn-mod pokemon-mod-denominator))))
                          step-type-eff-mod))

         (step-final-mods ;; final mods, wrong
          (let ((mod (pokemon--chain-mods
                      (cons pokemon-mod-denominator final-mods))))
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
     (pokemon-damage-calc--mod-check rest))))

(defmacro pokemon-damage-calc (atker-lvl atk/spa def/spd mov-power &rest mods)
  `(if (pokemon--damage-calc-mod-check ',mods)
     (pokemon--damage-calc
      ,(pokemon-base-damage
        atker-lvl
        atk/spa                         ;; 受到攻击 mods 影响, 包括能力升降低, 特性加成, 道具影响
        def/spd                         ;; 同攻击 mods
        mov-power)                      ;; 受到场地和天气的影响, 有些特性也会影响, 比如妖精皮肤在同类加成 1.2 倍, 招式也会有影响, 比如帮助加成 2 倍
      ,(or (plist-get mods :spread-mov-mod) pokemon-mod-denominator)
      ,(or (plist-get mods :parental-bond-mod) pokemon-mod-denominator)
      ,(or (plist-get mods :weather-mod) pokemon-mod-denominator)
      ,(or (plist-get mods :critical-mod) 1)
      ,(or (plist-get mods :same-type-atk-bouns-mod) pokemon-mod-denominator)
      ,(or (plist-get mods :type-eff-mod) 1)
      ,(or (plist-get mods :burn-mod) pokemon-mod-denominator)
      ,(or (plist-get mods :final-mods) nil)
      ,(or (plist-get mods :protect-mod) pokemon-mod-denominator))
     0))

;; examples:
;; (pokemon-damage-calc 50 232 109 120
;;                       :same-type-atk-bouns-mod pokemon-mod-x1dot5
;;                       :final-mods '(4096 2732 2048 3072 5324))

(provide 'pokemon-damage)

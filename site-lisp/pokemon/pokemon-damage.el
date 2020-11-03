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

(defun pokemon-mul-mods (val &rest mods)
  (let* ((x_s (cons pokemon-mod-denominator mods))
         (final-mod (pokemon--chain-mods x_s)))
    (pokemon-round (* val final-mod) pokemon-mod-denominator)))

(defun pokemon--chain-mods (mods)
  (reduce
   (lambda (old-comb-mod next-mod)
     (pokemon-normal-round (* old-comb-mod next-mod) pokemon-mod-denominator))
   mods))

(defun pokemon--damage-calc (
     base-damage
     spread-mov-mod
     parental-bond-mod
     weather-mod
     same-type-atk-bouns-mod
     type-eff-mod
     burn-mod
     final-mods
     protect-mod)
  (let* (
         (step1
          (pokemon-round (* base-damage (/ spread-mov-mod pokemon-mod-denominator))))
         (step2
          (pokemon-round (* step1 (/ weather-mod pokemon-mod-denominator))))
         (step3
          (let ((res nil)
                (random-factor 0))
            (while (<= random-factor 15)
              (push
               (pokemon-flooring (* step2 (- 100 random-factor)) 100) res)
              (setq random-factor (1+ random-factor)))
            res))
         (step4
          (mapcar
           (lambda (dmg)
             (pokemon-round (* dmg (/ same-type-atk-bouns-mod pokemon-mod-denominator))))
           step3))
         (step5
          (mapcar
           (lambda (dmg)
             (pokemon-flooring (* dmg (/ type-eff-mod pokemon-mod-denominator))))
           step4))
         (step6
          (let ((mod (pokemon--chain-mods (cons pokemon-mod-denominator final-mods))))
            (mapcar
             (lambda (dmg)
               (pokemon-round (* dmg mod) pokemon-mod-denominator))
             step5)))
         )
    step6
    ;; TODO: one damage check and #16rffff, ie, 65535, damage check
    ))

(defun pokemon-damage-calc (
                            atker-lvl
                            atk/spa
                            def/spd
                            mov-dmg
                            spread-mov-mod
                            parental-bond-mod
                            weather-mod
                            same-type-atk-bouns-mod
                            type-eff-mod
                            burn-mod
                            final-mods
                            protect-mod)
  (let ((base-damage (pokemon-base-damage
                      atker-lvl
                      atk/spa
                      def/spd
                      mov-dmg)))
    (pokemon--damage-calc
     base-damage
     spread-mov-mod
     parental-bond-mod
     weather-mod
     same-type-atk-bouns-mod
     type-eff-mod
     burn-mod
     final-mods
     protect-mod)))

(provide 'pokemon-damage)

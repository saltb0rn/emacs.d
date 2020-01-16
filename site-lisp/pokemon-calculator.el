(defstruct specStr-baseStat spec base)

(defstruct damage-rate
  (attacker-type-match-move-type 1.5)
  (effective 1)
  (super-effective 2)
  (not-very-effective 0.5)
  (not-effective 0))

(defstruct element-rate
  move-type
  denfender-type
  rate)

(defstruct pokemon-info
  (hp (make-specStr-baseStat :spec 0 :base 0))
  (atk (make-specStr-baseStat :spec 0 :base 0))
  (sp-atk (make-specStr-baseStat :spec 0 :base 0))
  (def (make-specStr-baseStat :spec 0 :base 0))
  (sp-def (make-specStr-baseStat :spec 0 :base 0))
  (spd (make-specStr-baseStat :spec 0 :base 0))
  types
  ability
  item
  nature)

(defstruct attack-move-info
  type
  power
  ct
  hit)

;;; support dervided type, like fighting type with scrappy ability will be fighting-effective-to-ghost, it is neccessay because it's effective to ghost type

(setq const-damage-rate (make-damage-rate))

(setq element-rules
      (list) ;; gen1 to genN
      (list)) ;; genN to genM, etc.


(defun get-element-damage-rate (n move-type defender-type)
  (let ((element-rule (nth (- n 1) element-rules)))
    (loop for r in element-rule
          when (let ((mtype (element-rate-move-type r))
                     (dtype (element-rate-denfender-type r)))
                 (and (equal mtype move-type)
                      (equal dtype defender-type)))
          return (element-rate-rate r))))

(defun pokemon-damage-rate-calculator
    (generation
     attacker-types
     attack-move-type
     defender-types
     &optional
     attacker-item
     attacker-ability
     attacker-status-condition
     defender-item
     defender-ability
     defender-status-condition
     effects)
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
          do (setq rate
                   (* rate
                      (get-element-damage-rate
                       generation
                       attack-move-type
                       dtype))))
    rate))

(defun pokemon-damage-calculator (attacker-info defender-info attack-move)

  )

(provide 'pokemon-calculator)

(ert-deftest pokemon-round-test ()
  (should
   (and (equal 30 (pokemon-round 30.2))
        (equal 30 (pokemon-round 30.5))
        (equal 31 (pokemon-round 30.6)))))

(ert-deftest pokemon-normal-round-test ()
  (should
   (and (equal 30 (pokemon-normal-round 30.2))
        (equal 31 (pokemon-normal-round 30.5))
        (equal 31 (pokemon-normal-round 30.6)))))

(ert-deftest pokemon-flooring-test ()
  (should
   (and (equal 30 (pokemon-flooring 30.2))
        (equal 30 (pokemon-flooring 30.5))
        (equal 30 (pokemon-flooring 30.6)))))

(ert-deftest pokemon-base-damage-test ()
  (should
   (equal
    (pokemon-base-damage 50 255 145 150)
    118)))

(ert-deftest pokemon--damage-calc-test ()
  (let ((expectation '(47 48 48 49 49 50 50 51 52 52 53 53 54 54 55 56)))
    (should
     (equal
      (pokemon--damage-calc
       (pokemon-base-damage 50 232 109 120)
       pokemon-mod-x1
       pokemon-mod-x1
       pokemon-mod-x1
       pokemon-mod-x1
       pokemon-mod-x1
       pokemon-mod-x1
       (list pokemon-mod-xdot5 pokemon-mod-xdot75 pokemon-mod-x1dot3)
       pokemon-mod-x1)
      expectation
      ))))


(ert-deftest pokemon-base-damage-mul-mod ()
  (let ((dmg1 144)
        (dmg2 171))
    (should
     (and (equal 70 (pokemon-mul-mods dmg1 2048 3072 5324))
          (equal 83 (pokemon-mul-mods dmg2 2048 3072 5324))))))

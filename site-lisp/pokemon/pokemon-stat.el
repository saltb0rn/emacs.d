(require 'pokemon-utils)

(defun pokemon-base-stat (level spec-val invidual-val effort-val &optional modifier)
  "stat calculator for the generations since gen3"
  (let* ((step1 (* spec-val 2))
         (step2 (+ step1 invidual-val))
         (step3 (/  effort-val 4.0))
         (step4 (+ step2 step3))
         (step5 (* step4 level))
         (step6 (/ step5 100.0))
         (step7 (+ step6 5))
         (step8 (* step7 (or modifier 1))))
    (pokemon-flooring step8)))

(provide 'pokemon-stat)

(require 'pokemon-utils)

(defun pokemon-hp-stat (level spec-val invidual-val effort-val)
  (if (= spec-val 1)
      spec-val
    (let* ((step1 (* spec-val 2))
           (step2 (+ step1 invidual-val))
           (step3 (pokemon-flooring effort-val 4))
           (step4 (+ step2 step3))
           (step5 (* step4 level))
           (step6 (/ step5 100.0))
           (step7 (pokemon-flooring step6))
           (step8 (+ step7 level)))
      (+ step8 10))))

(defun pokemon-base-stat (level spec-val invidual-val effort-val &optional nature-mod)
  "stat (HP is not included) calculator for the generations since gen 3"
  (let* ((step1 (* spec-val 2))
         (step2 (+ step1 invidual-val))
         (step3 (pokemon-flooring effort-val 4))
         (step4 (+ step2 step3))
         (step5 (* step4 level))
         (step6 (/ step5 100.0))
         (step7 (+ step6 5))
         (step8 (* step7 (or nature-mod 1))))
    (pokemon-flooring step8)))

(provide 'pokemon-stat)

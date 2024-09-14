;;; https://registry.khronos.org/OpenGL-Refpages/gl4/html/clamp.xhtml
(defun clamp (x min-val max-val)
  (min (max x min-val) max-val))

;;; https://registry.khronos.org/OpenGL-Refpages/gl4/html/smoothstep.xhtml
(defun smoothstep (edge0 edge1 x)
  (let* ((x0 (/ (- x edge0) (- edge1 edge0)))
         (x1 (clamp x0 0.0 1.0)))
    (-
     (* 3 (expt x1 2))
     (* 2 (expt x1 3)))))

(smoothstep -0.2 0.9 0.2)
(smoothstep -0.2 0.9 -0.2)
(smoothstep -0.2 0.9 0.5)

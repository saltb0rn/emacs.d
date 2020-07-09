(defun geotrans-matrix-2d (coordinate a b c d e f)
  "This is the general form for transformation (rotation, translation and scale),
the matrix should be like this:

| a b e |
| c d f |
| 0 0 1 |

and the equation is

| a b e |   | x |   | x' |
| c d f | * | y | = | y' |
| 0 0 1 |   | 1 |   | 1  |

Some docs may haves different order of [a b c d e f],
there is no problem, totally.
"
  (let ((x (car coordinate))
        (y (cdr coordinate)))
    (cons
     (+ (* a x) (* b y) e)
     (+ (* c x) (* d y) f))))

(defun geotrans-rotate-2d (coordinate degrees)
  "equals to
(let ((radians (degrees-to-radians degrees)))
  (geotrans-matrix-2d coordinate
                      (cos radians) (- (sin radians))
                      (sin radians) (cos radians)
                      0 0)).

I will use degrees instead radians below,

and keep in mind that to use radians in programming.

The matrix should be like this:

| cos(d) cos(90+d) |
| sin(d) cos(d)    |

=>

| cos(d) -sin(d) |
| sin(d) cos(d)  |

You can think of the plane vector basis

| 1 0 |
| 0 1 |

rotates d degrees clockwise so that it becomes

| cos(d) cos(90+d) |
| sin(d) cos(d)    |
"
  (let ((x (car coordinate))
        (y (cdr coordinate))
        (radians (degrees-to-radians degrees)))
    (message "%s" radians)
    (cons
     (+ (* (cos radians) x) (* -1 (sin radians) y))
     (+ (* (sin radians) x) (* (cos radians) y)))))

(defun geotrans-translate-2d (coordinate dx dy)
  "equals to (geotrans-matrix-2d coordinate 1 0 0 1 dx dy),
The matrix should be like this:

| 1 0 dx |
| 0 1 dy |
| 0 0 1  |
"
  (let ((x (car coordinate))
        (y (cdr coordinate)))
    (cons
     (+ x dx)
     (+ y dy))))

(defun geotrans-scale-2d (coordinate rx ry)
  "equals to (geotrans-matrix-2d coordinate rx 0 0 ry 0 0),
The matrix should be like this:

| rx 0 |
| 0 ry |
"
  (let ((x (car coordinate))
        (y (cdr coordinate)))
    (cons
     (* rx x)
     (* ry y))))

(provide 'geotrans)

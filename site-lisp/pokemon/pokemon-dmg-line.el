(require 'pokemon)

(defmacro calc-damage-hp-ratio (lvl spec-a spec-d mov-power spec-h &rest mods)
  `(/ (reduce
       (lambda (v1 v2) (+ v1 v2))
       (mapcar (lambda (v) (/ v
                              (pokemon-hp-stat
                               ,lvl
                               ,spec-h
                               (or (plist-get (list ,@mods) :h-ivs) 0)
                               (or (plist-get (list ,@mods) :h-evs) 0))
                              1.0))
               (pokemon-damage-calc ,lvl
                                    (pokemon-base-stat
                                     ,lvl ,spec-a
                                     (or (plist-get (list ,@mods) :a-ivs) 0)
                                     (or (plist-get (list ,@mods) :a-evs) 0)
                                     (or (plist-get (list ,@mods) :a-nature) 1))
                                    (pokemon-base-stat
                                     ,lvl ,spec-d
                                     (or (plist-get (list ,@mods) :d-ivs) 0)
                                     (or (plist-get (list ,@mods) :d-evs) 0)
                                     (or (plist-get (list ,@mods) :d-nature) 1))
                                    ,mov-power
                                    ,@mods)))
      16))

(defun pokemon-damage-line-round (val &optional digits round-method)
  (let ((mod (expt 10.0 (or digits 2)))
        r-method)
    (fset 'r-method (or round-method #'pokemon-round))
    (if (functionp 'r-method)
        (/ (r-method (* val mod)) mod)
        (user-error "argument `round-method should be a round function"))))

;; 从非 HP 属性值反推出原本种族值
(defmacro pokemon-base-stat-to-spec (stat &rest args)
  (let ((step1 (make-symbol "step1"))
        (step2 (make-symbol "step2"))
        (step3 (make-symbol "step3"))
        (step4 (make-symbol "step4"))
        (step5 (make-symbol "step5"))
        (step6 (make-symbol "step6")))
    `(let* ((,step1  (/ ,stat (or (plist-get (list ,@args) :nature) 1)))
            (,step2 (- ,step1 5))
            (,step3 (* ,step2 100.0))
            (,step4 (/ ,step3 (or (plist-get (list ,@args) :level) 50)))
            (,step5 (* (pokemon-flooring  (or (plist-get (list ,@args) :ev) 0) 4)))
            (,step6 (/ (- ,step4 ,step5 (or (plist-get (list ,@args) :iv) 0)) 2)))
       ,step6)))

;; 从 HP 属性值反推出原本种族值
(defmacro pokemon-hp-stat-to-spec (stat &rest args)
  (let ((step1 (make-symbol "step1"))
        (step2 (make-symbol "step2"))
        (step3 (make-symbol "step3"))
        (step4 (make-symbol "step4"))
        (step5 (make-symbol "step5")))
    `(let* ((,step1  (- ,stat (or (plist-get (list ,@args) :level) 50.0)))
            (,step2 (* ,step1 100.0))
            (,step3 (/ ,step2 (or (plist-get (list ,@args) :level) 50.0)))
            (,step4 (pokemon-flooring  (or (plist-get (list ,@args) :ev) 0) 4))
            (,step5 (- (/ (- ,step3 ,step4 (or (plist-get (list ,@args) :iv) 0)) 2) 10)))
       ,step5)))

;; 取容易记忆的数值
(defun pokemon-spec-approximate (val)
  (let* ((last-digit (% val 10))
         (_val (- val last-digit))
         (dot5 (abs (- last-digit 5)))
         (toZero (abs (- last-digit 0)))
         (toOne (- 10 last-digit))
         (min-d (min dot5 toZero toOne))
         )
    (if (or (= dot5 0)
            (= toZero 0)
            (= toOne 0))
        val
        (cond
         ((= min-d dot5) (+ _val 5))
         ((= min-d toZero) (+ _val 0))
         ((= min-d toOne) (+ _val 10))))))

;; 属性等级划分
(defmacro spec-rank-generator (baseline stat-type &rest args)
  (let ((stat-func
         (intern (concat "pokemon-" (symbol-name stat-type) "-stat")))
        (stat-to-spec-func
         (intern (concat "pokemon-" (symbol-name stat-type) "-stat-to-spec")))
        (msg-header-tab-format
         ";; %s	%s	%s		%s	%s	%s	%s")
        (msg-tab-format
         ";; %s		%s			%s			%s		%s (%s)	%s (%s)	%s (%s)")

        (msg-records (make-symbol "msg-records"))
        (level (make-symbol "level"))
        (mod (make-symbol "mod"))
        (half-mod (make-symbol "half-mod"))
        (count (make-symbol "count"))
        (index (make-symbol "index"))

        (exact-spec-stat (make-symbol "exact-spec-stat"))
        (actual-stat (make-symbol "actual-stat"))
        (actual-stat-iv (make-symbol "actual-stat-iv"))
        (actual-stat-ev (make-symbol "actual-stat-ev"))
        (actual-stat-iv-ev (make-symbol "actual-stat-iv-ev"))
        (actual-stat-iv-boost (make-symbol "actual-stat-iv-boost"))
        (actual-stat-ev-boost (make-symbol "actual-stat-ev-boost"))
        (actual-stat-iv-ev-boost (make-symbol "actual-stat-iv-ev-boost"))

        (half-exact-spec-stat (make-symbol "half-exact-spec-stat"))
        (half-actual-stat (make-symbol "half-actual-stat"))
        (half-actual-stat-iv (make-symbol "half-actual-stat-iv"))
        (half-actual-stat-ev (make-symbol "half-actual-stat-ev"))
        (half-actual-stat-iv-ev (make-symbol "half-actual-stat-iv-ev"))
        (half-actual-stat-iv-boost (make-symbol "half-actual-stat-iv-boost"))
        (half-actual-stat-ev-boost (make-symbol "half-actual-stat-ev-boost"))
        (half-actual-stat-iv-ev-boost (make-symbol "half-actual-stat-iv-ev-boost")))

    `(progn
       (let ((,level (or (plist-get (list ,@args) :level) 50))
             (,mod (or (plist-get (list ,@args) :mod) 1.2))
             (,half-mod (or (plist-get (list ,@args) :half-mod) 1.1))
             (,count (or (plist-get (list ,@args) :count) 3))
             (,msg-records
              (list
               (format ,msg-header-tab-format
                       "level"
                       "approximate-spec-stat"
                       "exact-spec-stat"
                       "actual-stat"
                       "actual-stat-iv"
                       "actual-stat-ev"
                       "actual-stat-iv-ev")
               (format "\n;; %s 属性等级表 ------------------------------------------"
                       (if (string= (symbol-name ',stat-type) "base")
                           "非 HP"
                         "HP"))))
             ,exact-spec-stat
             ,actual-stat
             ,actual-stat-iv
             ,actual-stat-ev
             ,actual-stat-iv-ev
             ,actual-stat-iv-boost
             ,actual-stat-ev-boost
             ,actual-stat-iv-ev-boost)

         (dotimes (,index ,count)
           (setq ,exact-spec-stat
                 (if (null ,exact-spec-stat)
                     ,baseline
                   (pokemon-round
                    (,stat-to-spec-func
                     (* ,actual-stat-iv-ev ,mod)
                     :level ,level
                     :iv 31
                     :ev 252))))
           (setq ,actual-stat (,stat-func ,level ,exact-spec-stat 0 0))
           (setq ,actual-stat-iv (,stat-func ,level ,exact-spec-stat 31 0))
           (setq ,actual-stat-ev (,stat-func ,level ,exact-spec-stat 0 252))
           (setq ,actual-stat-iv-ev (,stat-func ,level ,exact-spec-stat 31 252))
           (setq ,actual-stat-iv-boost
                 (pokemon-damage-line-round (/ ,actual-stat-iv ,actual-stat 1.0)))
           (setq ,actual-stat-ev-boost
                 (pokemon-damage-line-round (/ ,actual-stat-ev ,actual-stat 1.0)))
           (setq ,actual-stat-iv-ev-boost
                 (pokemon-damage-line-round (/ ,actual-stat-iv-ev ,actual-stat 1.0)))

           (push
            (format ,msg-tab-format
                    ,index
                    (pokemon-spec-approximate ,exact-spec-stat)
                    ,exact-spec-stat
                    ,actual-stat
                    ,actual-stat-iv
                    ,actual-stat-iv-boost
                    ,actual-stat-ev
                    ,actual-stat-ev-boost
                    ,actual-stat-iv-ev
                    ,actual-stat-iv-ev-boost)
            ,msg-records)

           (unless (= ,index (- ,count 1))
             (let* ((,half-actual-stat-iv-ev (* ,actual-stat-iv-ev ,half-mod))
                    (,half-exact-spec-stat (pokemon-round
                                            (,stat-to-spec-func
                                             ,half-actual-stat-iv-ev
                                             :level ,level
                                             :iv 31
                                             :ev 252)))
                    (,half-actual-stat
                     (,stat-func ,level ,half-exact-spec-stat 0 0))
                    (,half-actual-stat-iv
                     (,stat-func ,level ,half-exact-spec-stat 31 0))
                    (,half-actual-stat-ev
                     (,stat-func ,level ,half-exact-spec-stat 0 252))
                    (,half-actual-stat-iv-ev
                     (,stat-func ,level ,half-exact-spec-stat 31 252))
                    (,half-actual-stat-iv-boost
                     (pokemon-damage-line-round
                      (/ ,half-actual-stat-iv ,half-actual-stat 1.0)))
                    (,half-actual-stat-ev-boost
                     (pokemon-damage-line-round
                      (/ ,half-actual-stat-ev ,half-actual-stat 1.0)))
                    (,half-actual-stat-iv-ev-boost
                     (pokemon-damage-line-round
                      (/ ,half-actual-stat-iv-ev ,half-actual-stat 1.0))))

               (push
                (format ,msg-tab-format
                         (+ ,index 0.5)
                         (pokemon-spec-approximate ,half-exact-spec-stat)
                         ,half-exact-spec-stat
                         ,half-actual-stat
                         ,half-actual-stat-iv
                         ,half-actual-stat-iv-boost
                         ,half-actual-stat-ev
                         ,half-actual-stat-ev-boost
                         ,half-actual-stat-iv-ev
                         ,half-actual-stat-iv-ev-boost)
                ,msg-records)
               )))
         (string-join (reverse ,msg-records) "\n")
         )
       )))

(defmacro move-power-rank-generator (baseline &optional args)
  (let ((count (make-symbol "count"))
        (mod (make-symbol "mod"))
        (index (make-symbol "index"))
        (cur-value (make-symbol "cur-value"))
        (msg-records (make-symbol "msg-records")))
    `(let ((,count
            (or (plist-get (list ,@args) :count) 4))
           (,mod
            (or (plist-get (list ,@args) :mod) 1.2))
           (,msg-records (list
                          ";; level	approximate	exact"
                          "\n;; 招式威力等级表格 ------------------------------------------"))
           ,cur-value)

       (dotimes (,index ,count)
         (setq ,cur-value
               (if (null ,cur-value)
                   ,baseline
                 (pokemon-round (* ,cur-value ,mod))))
         (push
          (format ";; %s		%s		%s" ,index (pokemon-spec-approximate ,cur-value) ,cur-value)
          ,msg-records)
         )
       (string-join (reverse ,msg-records) "\n")
       )))

;; https://tieba.baidu.com/p/8019499150
;; https://www.smogon.com/smog/issue4/damage_stats

;; --------------------------------------------------------------------------------------------------------------------------------------

;; 把乘以 1.2 叫做 +1 倍, 除以 1.2 叫做 -1 倍.
;; 1.2 ~ 1.1 * 1.1, 把乘以 1.1 叫做 +0.5 倍, 除以 1.1 叫做 -0.5 倍.
;; 1.5 ~ 1.2 ^ 2, 所以把乘除 1.5 叫做升降 2 倍.
;; 2 ~ 1.2 ^ 4, 所以把乘除 2 叫做升降 4 倍.
;; 4 ~ 1.2 ^ 8, 所以把乘除 4 叫做升降 8 倍.

;; --------------------------------------------------------------------------------------------------------------------------------------

;; 我们需要找出一个成等积数列的属性值列表, 后项是前项的 1.2 倍, 这里以常见的种族值 90 作为基准.
;; 先计算出在满个体和满努力的情况下, 90 的非 HP 种族值所对应的最终属性值为多少, 然后把结果乘以 1.2 再反求出下一个种族值, 如此类推, 得到以下列表:
;; 下面为非 HP 种族值列表, 其中括号里面的数字表示 actual-stat-* 比起 actual-stat 的提升率
;; 下面数据由该语句生成 (insert (spec-rank-generator 90 base :count 4))
;; 非 HP 属性等级表 ------------------------------------------
;; level	approximate-spec-stat	exact-spec-stat		actual-stat	actual-stat-iv	actual-stat-ev	actual-stat-iv-ev
;; -1           65                      66                      71              86 (1.21)       102 (1.44)      118 (1.67)
;; 0		90			90			95		110 (1.16)	126 (1.33)	142 (1.49)
;; 1		120			118			123		138 (1.12)	154 (1.25)	170 (1.38)
;; 2		150			152			157		172 (1.1)	188 (1.2)	204 (1.3)
;; 3		195			193			198		213 (1.08)	229 (1.16)	245 (1.24)

;; 满个体 & 满努力下, 每个最终非 HP 属性值都满足关系: 142 * 1.2 ^ level,
;; 同时也满足了 actual-stat-with-iv-ev-max - exact-spec-stat = 52 的关系,
;; 此外还能发现 acual-stat-iv - exact-spec-stat = 15 + 5 = 20
;; actual-stat-ev - exact-spec-stat = 31 + 5 = 36
;; 根据非 HP 属性的计算公式, 这里的 15 和 31 是进行过小数点处理的结果, 原本分别是 15.5 和 31.5, 加起来刚好等于 15.5 + 31.5 + 5 = 52.

;; 由于个体值和努力值的加成并非是按照比例增加的, 所以在非 HP 种族值越來越大的情况下, 个体值和努力值的收益会逐渐减少.
;; 在 level [0, 2] 区间中, 我们可以认为满努力值相对于 0 努力值大约有 1.2 倍的提升, 满个体相对于 0 个体大约有 1.1 倍的加成.
;; [0, 2] 区间的满个体和满努力可以看作对于 0 个体 和 0 努力提升大概 1.2^2 倍.
;; [0, 2] 区间则是大部分宝可梦的种族值范围, 65 和 190 这两个种族值非常少见.

;; --------------------------------------------------------------------------------------------------------------------------------------

;; 再来计算出 HP 种族值吧, 以 70 为基准线.
;; 下面数据由该语句生成:
;; (insert (spec-rank-generator 70 hp :count 4))
;; HP 属性等级表 ------------------------------------------
;; level	approximate-spec-stat	exact-spec-stat		actual-stat	actual-stat-iv	actual-stat-ev	actual-stat-iv-ev
;; -1           40                      40                      100             115 (1.15)      131 (1.31)      147 (1.47)
;; 0		70			70			130		145 (1.12)	161 (1.24)	177 (1.36)
;; 1		105			105			165		180 (1.09)	196 (1.19)	212 (1.28)
;; 2		145			147			207		222 (1.07)	238 (1.15)	254 (1.23)
;; 3		200			198			258		273 (1.06)	289 (1.12)	305 (1.18)

;; 在满个体 & 满努力下, 每个最终 HP 属性都满足关系: 177 * 1.2 ^ level
;; 在 level [0, 2] 区间中, 我们可以认为满努力值相对于 0 努力值大约有 1.1 ~ 1.2 倍的提升, 满个体相对于 0 个体大约有 1.1 倍的加成.
;; [0, 2] 区间的满个体和满努力可以看作对于 0 个体 和 0 努力提升大概 1.2 倍, 也就是上升 1 个等级.
;; 由于我们并不追求非常高的准确性, 因此, 我们默认没有加努力值为减少 1 个等级.


;; --------------------------------------------------------------------------------------------------------------------------------------

;; 在划分招式伤害等级, 同样以 90 作为基准线
;; (insert (move-power-rank-generator 90))
;; 招式威力等级表格 ------------------------------------------
;; level	approximate	exact
;; 0		90		90
;; 1		110		108
;; 1.5          120             119
;; 2		130		130
;; 3		155		156
;; 4            185             187
;; 5            225             224
;; 6            270             269


;; --------------------------------------------------------------------------------------------------------------------------------------
;; 基于上面的数据, 我们以百分比 0.21 对应 level 0
;; 任何 level 对应的百分比约等于 0.21 * 1.2^level
;; 伤害等级 = 攻击方的攻击属性等级 + 招式伤害等级 - 防御方的防御和HP属性等级 +- mods 对应的等级
;; 下面这张表严格上来说是一个刻度尺子, 牺牲部分精准性, 追求计算的简易和速度.
;; 下面数据的由来是以 (calc-damage-hp-ratio 50 90 90 90 70 :a-ivs 31 :a-evs 252 :d-ivs 31 :d-evs 252 :h-ivs 31 :h-evs 252) 的结果 0.21 作为基准线,
;; 然后在此基准线之上乘以对应 mod 得出的.
;; 伤害等级表格如下, 共 10 ranks ----------------

;; level	percent	multipiler
;; -1           0.17    x 1.2
;; 0		0.21    -
;; --------------------------- 五分之一
;; 1		0.25	x 1.2
;; --------------------------- 四分之一
;; 2		0.30	x 1.2
;; 3		0.36	x 1.2
;; --------------------------- 三分之一
;; 4		0.42	x 1.2
;; 4.5		0.46	x 1.1
;; 5		0.51	x 1.1
;; --------------------------- 二分之一
;; 5.5		0.56	x 1.1
;; 6		0.62	x 1.1
;; 6.5		0.68	x 1.1
;; -------------------------- 三分之二
;; 7		0.75	x 1.1
;; -------------------------- 四分之三
;; 7.5		0.82	x 1.1
;; -------------------------- 五分之四
;; 8		0.90	x 1.1
;; 8.5		0.99	x 1.1
;; 9		1.05	x 1.1

;; --------------------------------------------------------------------------------------------------------------------------------------
;; 试验
;; 口算的统一标准是按照最近超过的标准线来计算
;; 比如 HP 100, 很接近 105, 但满努力满个体下也只能算等级 0
;; 这样是为了让结果统一等同于某个伤害线, 然后自己再根据 (a * mp) / (hp * d)

;; case 1:
;; 满个体满努力攻击的请假王 使用 吸取拳 -> 满个体努力防御HP的戟脊龙
;; 请假王攻击种族 160, 略高于 150, 所以攻击等级 +2;
;; 吸取拳的招式威力是 75, 等级 -1, 请假王一般属性, 没有同系加成;
;; 吸取拳格斗系, 对龙 + 冰属性的戟脊龙有 2 倍克制, 所以效果加成级别 +4;
;; 戟脊龙的防御种族值是 92, 略高于 90, 满个体和努力时的防御等级是 0;
;; 戟脊龙的HP种族值是 115, 略高于 105,  满个体和努力时的HP等级 +1;
;; 因此最终伤害等级为 2 - 1 + 4 - 1 = 4, 对应 0.42
(calc-damage-hp-ratio
 50 160 92 75 115
 :a-ivs 31 :a-evs 252
 :d-ivs 31 :d-evs 252
 :h-ivs 31 :h-evs 252
 :type-eff-mod 2)

;; case 2:
;; 满个体满努力值攻击的请假王 使用吸取拳 -> 满个体 0 努力防御 0 努力的 HP 戟脊龙
;; 请假王攻击种族 160, 略高于 150, 所以攻击等级 +2;
;; 吸取拳的招式威力是 75, 等级 -1, 请假王一般属性, 没有同系加成;
;; 吸取拳格斗系, 对龙 + 冰属性的戟脊龙有 2 倍克制, 所以效果加成级别 +4;
;; 戟脊龙的防御种族值是 92, 略高于 90, 满个体 0 努力时防御等级是 -1;
;; 戟脊龙的HP种族值是 115, 略高于 105, 满个体 0 努力时的HP等级 0;
;; 因此最终伤害等级为 2 - 1 + 4 + 1 = 6, 对应 0.62
(calc-damage-hp-ratio
 50 160 92 75 115
 :a-ivs 31 :a-evs 252
 :d-ivs 31 :d-evs 0
 :h-ivs 31 :h-evs 0
 :type-eff-mod 2)

;; case 3:
;; 满个体满努力特攻的红莲铠骑 使用铠农炮 -> 满个体 0 努力特防和 HP 的盐石巨灵
;; 红莲铠骑特攻种族值 125, 略高于 120, 所以攻击等级 +1;
;; 铠农炮招式威力是 120, 介于 110 和 130 之间, 伤害等级是 1, 有同系加成, 等级 +2, 为 3;
;; 铠农炮火属性对岩石被 2 倍抵抗, 等级 -4;
;; 盐石巨灵 HP 种族值 100, 略低于 105, HP 等级为 0, 由于是满个体 0 努力, 所以最终 HP 等级为 -1
;; 盐石巨灵 特防 种族值 90, 由于是满个体 0 努力, 所以 特防 等级为 -1
;; 最终等级 1 + 3 - 4 + 1 + 1 = 2, 过 0.30
(calc-damage-hp-ratio
 50 125 90 120 100
 :a-ivs 31 :a-evs 252
 :d-ivs 31 :d-evs 0
 :h-ivs 31 :h-evs 0
 :same-type-atk-bouns-mod pokemon-mod-x1dot5
 :type-eff-mod (expt 2 -1))

;; case 4:
;; 满个体满努力特攻的红莲铠骑 使用铠农炮 -> 满个体满努力特防和 HP 的盐石巨灵
;; 红莲铠骑特攻种族值 125, 略高于 120, 所以攻击等级 +1;
;; 铠农炮招式威力是 120, 介于 110 和 130 之间, 伤害等级是 1, 有同系加成, 等级 +2, 为 3;
;; 铠农炮火属性对岩石被 2 倍抵抗, 等级 -4;
;; 盐石巨灵 HP 种族值 100, 略低于 105, 满个体和努力下 HP 等级为 0;
;; 盐石巨灵 特防 种族值 90, 由于是满个体和努力, 所以 特防 等级为 0
;; 最终等级 1 + 3 - 4  = 0, 过 0.21

(calc-damage-hp-ratio
 50 125 90 120 100
 :a-ivs 31 :a-evs 252
 :d-ivs 31 :d-evs 252
 :h-ivs 31 :h-evs 252
 :same-type-atk-bouns-mod pokemon-mod-x1dot5
 :type-eff-mod (expt 2 -1))

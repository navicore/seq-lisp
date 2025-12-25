;; Defmacro Tests
;; Tests for: defmacro, basic macro definition and expansion

;; Simple constant macro
(defmacro (always-42) 42)

;; Macro that returns its argument unevaluated
(defmacro (identity-macro x) x)

;; Macro with multiple params (returns quoted list)
(defmacro (swap-args a b) `',(list b a))

;; Macro that builds an if expression
(defmacro (when cond body)
  `(if ,cond ,body '()))

;; Macro that builds the opposite
(defmacro (unless cond body)
  `(if ,cond '() ,body))

;; Short-circuit and/or (2-arg versions)
(defmacro (and2 a b) `(if ,a ,b #f))
(defmacro (or2 a b) `(if ,a #t ,b))

;; Variadic macro
(defmacro (list-args . args) `(list ,@args))

(define defmacro-tests (list
  ;; Basic macro expansion
  (test 'macro-constant (assert-eq (always-42) 42))
  (test 'macro-identity (assert-eq (identity-macro (+ 1 2)) 3))
  ;; Macro with multiple params
  (test 'macro-swap (assert-eq (swap-args 1 2) '(2 1)))
  ;; when/unless
  (test 'when-true (assert-eq (when #t 'yes) 'yes))
  (test 'when-false (assert-eq (when #f 'yes) '()))
  (test 'unless-true (assert-eq (unless #t 'no) '()))
  (test 'unless-false (assert-eq (unless #f 'yes) 'yes))
  ;; Short-circuit and/or
  (test 'and2-tt (assert-eq (and2 #t #t) #t))
  (test 'and2-tf (assert-eq (and2 #t #f) #f))
  (test 'and2-ft (assert-eq (and2 #f #t) #f))
  (test 'and2-ff (assert-eq (and2 #f #f) #f))
  (test 'or2-tt (assert-eq (or2 #t #t) #t))
  (test 'or2-tf (assert-eq (or2 #t #f) #t))
  (test 'or2-ft (assert-eq (or2 #f #t) #t))
  (test 'or2-ff (assert-eq (or2 #f #f) #f))
  ;; Variadic macro
  (test 'variadic-macro-empty (assert-eq (list-args) '()))
  (test 'variadic-macro-one (assert-eq (list-args 'a) '(a)))
  (test 'variadic-macro-many (assert-eq (list-args 1 2 3) '(1 2 3)))))

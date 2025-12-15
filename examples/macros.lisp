;; Macros in SeqLisp
;;
;; Demonstrates the macro system with practical examples

;; ============================================
;; Control Flow Macros
;; ============================================

;; when: execute body only if condition is true
(defmacro (when cond body)
  `(if ,cond ,body '()))

;; unless: execute body only if condition is false
(defmacro (unless cond body)
  `(if ,cond '() ,body))

;; Examples
(print (when #t 'yes))
(print (when #f 'yes))
(print (unless #f 'executed))

;; ============================================
;; Variadic Short-Circuit Boolean Macros
;; ============================================

;; Variadic and: returns #f at first false, otherwise last value
;; Uses (. args) syntax to collect all arguments
(defmacro (and . args)
  (if (null? args)
      '#t
      (if (null? (cdr args))
          (car args)
          `(if ,(car args) (and ,@(cdr args)) #f))))

;; Variadic or: returns first truthy value, otherwise #f
;; NOTE: Uses gensym with prefix to avoid common symbol collisions.
;; For full hygiene, avoid using symbols starting with "__or" in user code.
(defmacro (or . args)
  (if (null? args)
      '#f
      (if (null? (cdr args))
          (car args)
          (let tmp (gensym '__or 0)
            `(let ,tmp ,(car args)
               (if ,tmp ,tmp (or ,@(cdr args))))))))

;; Short-circuit: args not evaluated when unnecessary
(print (and #t #t #t))       ;; #t
(print (and #t #f 'never))   ;; #f
(print (or #f #f #t #f))     ;; #t
(print (or 'first #f #f))    ;; first

;; ============================================
;; Increment/Decrement
;; ============================================

(defmacro (inc x) `(+ ,x 1))
(defmacro (dec x) `(- ,x 1))

(print (inc 5))
(print (dec 5))

;; ============================================
;; Let* - Sequential Bindings (2 vars)
;; ============================================

;; let*2 allows second binding to reference first
(defmacro (let*2 bindings body)
  `(let ,(car (car bindings)) ,(car (cdr (car bindings)))
     (let ,(car (car (cdr bindings))) ,(car (cdr (car (cdr bindings))))
       ,body)))

;; b can reference a
(print (let*2 ((a 10) (b (+ a 5))) (+ a b)))

;; ============================================
;; Assert Macro (for testing)
;; ============================================

(defmacro (assert expr)
  `(if ,expr 'ok 'FAIL))

(print (assert (= (+ 1 1) 2)))
(print (assert (> 5 3)))

;; ============================================
;; Compose two functions
;; ============================================

(defmacro (compose f g)
  `(lambda (x) (,f (,g x))))

(define double (lambda (x) (* x 2)))
(define add1 (lambda (x) (+ x 1)))
(define double-then-add1 (compose add1 double))

(print (double-then-add1 5))

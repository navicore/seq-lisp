;; SeqLisp Comprehensive Test Suite
;;
;; Run with: just lisp-test
;; Or: cat lib/test.lisp tests/all.lisp | ./seqlisp
;;
;; This file assumes lib/test.lisp has been prepended.

;; ============================================
;; Arithmetic Tests
;; ============================================

(define arithmetic-tests (list
  (test 'add-positive (assert-eq (+ 1 2) 3))
  (test 'add-zero (assert-eq (+ 0 5) 5))
  (test 'add-negative (assert-eq (+ -3 3) 0))
  (test 'sub-positive (assert-eq (- 10 4) 6))
  (test 'sub-negative (assert-eq (- 1 5) -4))
  (test 'mul-positive (assert-eq (* 3 4) 12))
  (test 'mul-zero (assert-eq (* 100 0) 0))
  (test 'mul-negative (assert-eq (* -2 3) -6))
  (test 'div-exact (assert-eq (/ 10 2) 5))
  (test 'div-negative (assert-eq (/ -12 3) -4))))

;; ============================================
;; Numeric Functions Tests
;; ============================================

(define numeric-tests (list
  ;; abs
  (test 'abs-positive (assert-eq (abs 5) 5))
  (test 'abs-negative (assert-eq (abs -5) 5))
  (test 'abs-zero (assert-eq (abs 0) 0))
  ;; min
  (test 'min-two (assert-eq (min 3 7) 3))
  (test 'min-many (assert-eq (min 5 2 8 1 9) 1))
  (test 'min-negative (assert-eq (min -3 -7 -1) -7))
  ;; max
  (test 'max-two (assert-eq (max 3 7) 7))
  (test 'max-many (assert-eq (max 5 2 8 1 9) 9))
  (test 'max-negative (assert-eq (max -3 -7 -1) -1))
  ;; modulo (result has same sign as divisor)
  (test 'mod-basic (assert-eq (modulo 17 5) 2))
  (test 'mod-exact (assert-eq (modulo 10 5) 0))
  (test 'mod-small (assert-eq (modulo 3 7) 3))
  (test 'mod-neg-dividend (assert-eq (modulo -17 5) 3))
  (test 'mod-neg-divisor (assert-eq (modulo 17 -5) -3))
  (test 'mod-both-neg (assert-eq (modulo -17 -5) -2))))

;; ============================================
;; Comparison Tests
;; ============================================

(define comparison-tests (list
  (test 'less-than (assert-true (< 1 2)))
  (test 'greater-than (assert-true (> 5 3)))
  (test 'less-eq (assert-true (<= 3 3)))
  (test 'greater-eq (assert-true (>= 4 4)))
  (test 'numeric-eq (assert-true (= 42 42)))))

;; ============================================
;; List Operations Tests
;; ============================================

(define list-tests (list
  (test 'car (assert-eq (car '(1 2 3)) 1))
  (test 'cdr (assert-eq (cdr '(1 2 3)) '(2 3)))
  (test 'cons (assert-eq (cons 1 '(2 3)) '(1 2 3)))
  (test 'length (assert-eq (length '(a b c d e)) 5))
  (test 'append (assert-eq (append '(1 2) '(3 4)) '(1 2 3 4)))
  (test 'reverse (assert-eq (reverse '(1 2 3)) '(3 2 1)))
  (test 'nth (assert-eq (nth 2 '(a b c d)) 'c))
  (test 'last (assert-eq (last '(1 2 3 4 5)) 5))
  (test 'take (assert-eq (take 3 '(1 2 3 4 5)) '(1 2 3)))
  (test 'drop (assert-eq (drop 2 '(1 2 3 4 5)) '(3 4 5)))))

;; ============================================
;; Higher-Order Function Tests
;; ============================================

(define hof-tests (list
  (test 'map-square (assert-eq (map (lambda (x) (* x x)) '(1 2 3)) '(1 4 9)))
  (test 'filter-positive (assert-eq (filter (lambda (x) (> x 0)) '(-1 2 -3 4)) '(2 4)))
  (test 'fold-sum (assert-eq (fold (lambda (a b) (+ a b)) 0 '(1 2 3 4)) 10))))

;; ============================================
;; Apply Tests
;; ============================================

(define (add2 a b) (+ a b))

(define apply-tests (list
  ;; apply with builtin functions
  (test 'apply-add (assert-eq (apply + '(1 2 3 4)) 10))
  (test 'apply-mul (assert-eq (apply * '(2 3 4)) 24))
  (test 'apply-list (assert-eq (apply list '(a b c)) '(a b c)))
  (test 'apply-min (assert-eq (apply min '(5 2 8 1 9)) 1))
  (test 'apply-max (assert-eq (apply max '(5 2 8 1 9)) 9))
  ;; apply with empty list
  (test 'apply-add-empty (assert-eq (apply + '()) 0))
  (test 'apply-mul-empty (assert-eq (apply * '()) 1))
  ;; apply with lambda
  (test 'apply-lambda (assert-eq (apply (lambda (x y) (+ x y)) '(3 4)) 7))
  ;; apply with defined function
  (test 'apply-defined (assert-eq (apply add2 '(5 7)) 12))
  ;; nested apply (composition)
  (test 'apply-nested (assert-eq (apply + (apply list '(1 2 3))) 6))
  ;; partial application via apply (currying)
  (test 'apply-partial (assert-eq ((apply (lambda (x y z) (+ x (+ y z))) '(1 2)) 3) 6))))

;; ============================================
;; Equality Tests
;; ============================================

(define equality-tests (list
  (test 'equal-numbers (assert-true (equal? 42 42)))
  (test 'equal-symbols (assert-true (equal? 'foo 'foo)))
  (test 'equal-lists (assert-true (equal? '(1 2 3) '(1 2 3))))
  (test 'equal-nested (assert-true (equal? '((a b) (c d)) '((a b) (c d)))))
  (test 'not-equal-numbers (assert-false (equal? 1 2)))
  (test 'not-equal-lists (assert-false (equal? '(1 2) '(1 3))))))

;; ============================================
;; Predicate Tests
;; ============================================

(define predicate-tests (list
  (test 'null-empty (assert-true (null? '())))
  (test 'null-nonempty (assert-false (null? '(1))))
  (test 'number-pred (assert-true (number? 42)))
  (test 'symbol-pred (assert-true (symbol? 'foo)))
  (test 'list-pred (assert-true (list? '(1 2 3))))
  (test 'boolean-true (assert-true (boolean? '#t)))
  (test 'boolean-false (assert-true (boolean? '#f)))))

;; ============================================
;; Special Forms Tests
;; ============================================

(define special-form-tests (list
  ;; if
  (test 'if-true (assert-eq (if #t 'yes 'no) 'yes))
  (test 'if-false (assert-eq (if #f 'yes 'no) 'no))
  (test 'if-zero-falsy (assert-eq (if 0 'yes 'no) 'no))
  (test 'if-number-truthy (assert-eq (if 42 'yes 'no) 'yes))
  ;; let
  (test 'let-simple (assert-eq (let x 10 x) 10))
  (test 'let-expr (assert-eq (let x 5 (+ x 3)) 8))
  (test 'let-nested (assert-eq (let a 1 (let b 2 (+ a b))) 3))
  ;; quote
  (test 'quote-symbol (assert-eq 'foo 'foo))
  (test 'quote-list (assert-eq '(1 2 3) '(1 2 3)))
  (test 'quote-nested (assert-eq '((a b) (c d)) '((a b) (c d))))
  ;; begin
  (test 'begin-single (assert-eq (begin 42) 42))
  (test 'begin-multi (assert-eq (begin 1 2 3) 3))
  ;; cond
  (test 'cond-first (assert-eq (cond (#t 'a) (#t 'b)) 'a))
  (test 'cond-second (assert-eq (cond (#f 'a) (#t 'b)) 'b))
  (test 'cond-else (assert-eq (cond (#f 'a) (else 'b)) 'b))))

;; ============================================
;; Closure and Lambda Tests
;; ============================================

(define closure-tests (list
  ;; basic lambda
  (test 'lambda-identity (assert-eq ((lambda (x) x) 42) 42))
  (test 'lambda-add (assert-eq ((lambda (x y) (+ x y)) 3 4) 7))
  ;; closure capturing environment
  (test 'closure-capture (assert-eq (let y 10 ((lambda (x) (+ x y)) 5)) 15))
  (test 'closure-nested (assert-eq (let a 1 (let b 2 ((lambda (x) (+ x (+ a b))) 3))) 6))
  ;; currying / partial application
  (test 'curry-basic (assert-eq (((lambda (x y) (+ x y)) 3) 4) 7))
  (test 'curry-three (assert-eq ((((lambda (x y z) (+ x (+ y z))) 1) 2) 3) 6))))

;; ============================================
;; Recursion Tests
;; ============================================

(define (factorial n)
  (if (< n 2) 1 (* n (factorial (- n 1)))))

(define (fibonacci n)
  (if (< n 2) n (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))

(define recursion-tests (list
  (test 'fact-0 (assert-eq (factorial 0) 1))
  (test 'fact-1 (assert-eq (factorial 1) 1))
  (test 'fact-5 (assert-eq (factorial 5) 120))
  (test 'fact-10 (assert-eq (factorial 10) 3628800))
  (test 'fib-0 (assert-eq (fibonacci 0) 0))
  (test 'fib-1 (assert-eq (fibonacci 1) 1))
  (test 'fib-10 (assert-eq (fibonacci 10) 55))))

;; ============================================
;; Equal? Edge Cases
;; ============================================

(define equal-edge-tests (list
  ;; empty lists
  (test 'equal-empty-lists (assert-true (equal? '() '())))
  (test 'equal-nested-empty (assert-true (equal? '(()) '(()))))
  ;; mismatched types return false (not error)
  (test 'equal-num-sym (assert-false (equal? 1 'one)))
  (test 'equal-num-list (assert-false (equal? 1 '(1))))
  (test 'equal-sym-list (assert-false (equal? 'a '(a))))
  ;; deeply nested
  (test 'equal-deep (assert-true (equal? '((((a)))) '((((a)))))))
  (test 'equal-deep-diff (assert-false (equal? '((((a)))) '((((b)))))))))

;; ============================================
;; Combine and Run All Tests
;; ============================================

(define all-results
  (append arithmetic-tests
    (append numeric-tests
      (append comparison-tests
        (append list-tests
          (append hof-tests
            (append apply-tests
              (append equality-tests
                (append predicate-tests
                  (append special-form-tests
                    (append closure-tests
                      (append recursion-tests equal-edge-tests))))))))))))

(print 'SeqLisp-Test-Suite)
(print-each all-results)
(print (list (count-passes all-results) 'passed (count-fails all-results) 'failed))
(if (= (count-fails all-results) 0) (exit 0) (exit 1))

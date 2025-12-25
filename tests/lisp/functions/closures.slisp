;; Closure and Lambda Tests
;; Tests for: lambda, define, let, currying, variadic functions

;; Helper for apply tests
(define (add2 a b) (+ a b))

(define closure-tests (list
  ;; Basic lambda
  (test 'lambda-identity (assert-eq ((lambda (x) x) 42) 42))
  (test 'lambda-add (assert-eq ((lambda (x y) (+ x y)) 3 4) 7))
  (test 'lambda-const (assert-eq ((lambda () 99)) 99))
  ;; Closure capturing environment
  (test 'closure-capture (assert-eq (let y 10 ((lambda (x) (+ x y)) 5)) 15))
  (test 'closure-nested (assert-eq (let a 1 (let b 2 ((lambda (x) (+ x (+ a b))) 3))) 6))
  ;; Define function shorthand
  (test 'define-func (assert-eq (add2 3 4) 7))
  ;; Let bindings
  (test 'let-simple (assert-eq (let x 10 x) 10))
  (test 'let-expr (assert-eq (let x 5 (+ x 3)) 8))
  (test 'let-nested (assert-eq (let a 1 (let b 2 (+ a b))) 3))
  (test 'let-shadow (assert-eq (let x 1 (let x 2 x)) 2))
  ;; Currying / partial application
  (test 'curry-basic (assert-eq (((lambda (x y) (+ x y)) 3) 4) 7))
  (test 'curry-three (assert-eq ((((lambda (x y z) (+ x (+ y z))) 1) 2) 3) 6))
  (test 'curry-nested (assert-eq (((((lambda (a b c d) (+ a (+ b (+ c d)))) 1) 2) 3) 4) 10))
  ;; Variadic lambdas (rest params)
  (test 'variadic-rest-only (assert-eq ((lambda (. rest) rest) 1 2 3) '(1 2 3)))
  (test 'variadic-rest-empty (assert-eq ((lambda (. rest) rest)) '()))
  (test 'variadic-with-required (assert-eq ((lambda (x . rest) (list x rest)) 1 2 3) '(1 (2 3))))
  (test 'variadic-required-only (assert-eq ((lambda (x y . rest) rest) 1 2) '()))
  (test 'variadic-two-plus-rest (assert-eq ((lambda (a b . rest) (list a b rest)) 1 2 3 4 5) '(1 2 (3 4 5))))))

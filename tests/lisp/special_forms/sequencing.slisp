;; Sequencing Tests
;; Tests for: begin

(define sequencing-tests (list
  ;; begin - basic
  (test 'begin-single (assert-eq (begin 42) 42))
  (test 'begin-multi (assert-eq (begin 1 2 3) 3))
  (test 'begin-many (assert-eq (begin 'a 'b 'c 'd 'e) 'e))
  ;; begin - expressions
  (test 'begin-expr (assert-eq (begin (+ 1 1) (+ 2 2) (+ 3 3)) 6))
  ;; begin - side effects ordering
  ;; (Can't easily test side effects without mutation, but we can test eval order)
  (test 'begin-nested (assert-eq (begin (begin 1 2) (begin 3 4)) 4))
  ;; begin - with define (environment extension)
  (test 'begin-define (assert-eq (begin (define x 10) (+ x 5)) 15))
  (test 'begin-define-multi (assert-eq (begin (define a 1) (define b 2) (+ a b)) 3))
  ;; begin - empty (edge case)
  (test 'begin-empty (assert-eq (begin) '()))))

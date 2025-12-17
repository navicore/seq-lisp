;; SeqLisp Test Framework Demo
;;
;; This demonstrates the test framework with a few example tests.
;; For the full test suite, run: just lisp-test
;;
;; Run with: just lisp-run tests/demo.lisp

(run-suite 'Demo
  ;; Arithmetic
  (test 'addition (assert-eq (+ 1 2) 3))
  (test 'subtraction (assert-eq (- 10 4) 6))

  ;; Lists
  (test 'car (assert-eq (car '(a b c)) 'a))
  (test 'cdr (assert-eq (cdr '(1 2 3)) '(2 3)))

  ;; Higher-order functions
  (test 'map (assert-eq (map (lambda (x) (* x 2)) '(1 2 3)) '(2 4 6)))
  (test 'filter (assert-eq (filter (lambda (x) (> x 0)) '(-1 2 -3 4)) '(2 4)))

  ;; Equality
  (test 'equal-lists (assert-true (equal? '(a b) '(a b))))
  (test 'not-equal (assert-false (equal? 1 2))))

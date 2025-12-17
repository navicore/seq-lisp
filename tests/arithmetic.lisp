;; SeqLisp Arithmetic Tests
;;
;; Run with: just lisp-run tests/arithmetic.lisp
;;
;; This file assumes lib/test.lisp has been prepended.

(run-suite 'Arithmetic
  (test 'addition (assert-eq (+ 1 2) 3))
  (test 'add-zero (assert-eq (+ 0 5) 5))
  (test 'add-negative (assert-eq (+ -3 3) 0))
  (test 'subtraction (assert-eq (- 5 3) 2))
  (test 'sub-negative (assert-eq (- 1 5) -4))
  (test 'multiplication (assert-eq (* 3 4) 12))
  (test 'mul-zero (assert-eq (* 100 0) 0))
  (test 'division (assert-eq (/ 10 2) 5))
  (test 'div-negative (assert-eq (/ -12 3) -4)))

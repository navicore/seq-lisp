;; Arithmetic Tests
;; Tests for: +, -, *, /, abs, min, max, modulo

(define arithmetic-tests (list
  ;; Addition
  (test 'add-positive (assert-eq (+ 1 2) 3))
  (test 'add-zero (assert-eq (+ 0 5) 5))
  (test 'add-negative (assert-eq (+ -3 3) 0))
  (test 'add-many (assert-eq (+ 1 2 3 4) 10))
  (test 'add-single (assert-eq (+ 5) 5))
  (test 'add-empty (assert-eq (+) 0))
  ;; Subtraction
  (test 'sub-positive (assert-eq (- 10 4) 6))
  (test 'sub-negative (assert-eq (- 1 5) -4))
  (test 'sub-many (assert-eq (- 10 1 2 3) 4))
  ;; Multiplication
  (test 'mul-positive (assert-eq (* 3 4) 12))
  (test 'mul-zero (assert-eq (* 100 0) 0))
  (test 'mul-negative (assert-eq (* -2 3) -6))
  (test 'mul-many (assert-eq (* 2 3 4) 24))
  (test 'mul-single (assert-eq (* 7) 7))
  (test 'mul-empty (assert-eq (*) 1))
  ;; Division
  (test 'div-exact (assert-eq (/ 10 2) 5))
  (test 'div-negative (assert-eq (/ -12 3) -4))
  ;; Absolute value
  (test 'abs-positive (assert-eq (abs 5) 5))
  (test 'abs-negative (assert-eq (abs -5) 5))
  (test 'abs-zero (assert-eq (abs 0) 0))
  ;; Minimum
  (test 'min-two (assert-eq (min 3 7) 3))
  (test 'min-many (assert-eq (min 5 2 8 1 9) 1))
  (test 'min-negative (assert-eq (min -3 -7 -1) -7))
  ;; Maximum
  (test 'max-two (assert-eq (max 3 7) 7))
  (test 'max-many (assert-eq (max 5 2 8 1 9) 9))
  (test 'max-negative (assert-eq (max -3 -7 -1) -1))
  ;; Modulo (result has same sign as divisor)
  (test 'mod-basic (assert-eq (modulo 17 5) 2))
  (test 'mod-exact (assert-eq (modulo 10 5) 0))
  (test 'mod-small (assert-eq (modulo 3 7) 3))
  (test 'mod-neg-dividend (assert-eq (modulo -17 5) 3))
  (test 'mod-neg-divisor (assert-eq (modulo 17 -5) -3))
  (test 'mod-both-neg (assert-eq (modulo -17 -5) -2))))

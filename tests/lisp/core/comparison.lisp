;; Comparison Tests
;; Tests for: <, >, <=, >=, =

(define comparison-tests (list
  ;; Less than
  (test 'less-than (assert-true (< 1 2)))
  (test 'less-than-false (assert-false (< 2 1)))
  (test 'less-than-equal (assert-false (< 3 3)))
  ;; Greater than
  (test 'greater-than (assert-true (> 5 3)))
  (test 'greater-than-false (assert-false (> 3 5)))
  (test 'greater-than-equal (assert-false (> 4 4)))
  ;; Less than or equal
  (test 'less-eq-less (assert-true (<= 2 3)))
  (test 'less-eq-equal (assert-true (<= 3 3)))
  (test 'less-eq-greater (assert-false (<= 4 3)))
  ;; Greater than or equal
  (test 'greater-eq-greater (assert-true (>= 5 4)))
  (test 'greater-eq-equal (assert-true (>= 4 4)))
  (test 'greater-eq-less (assert-false (>= 3 4)))
  ;; Numeric equality
  (test 'numeric-eq-true (assert-true (= 42 42)))
  (test 'numeric-eq-false (assert-false (= 42 43)))
  (test 'numeric-eq-negative (assert-true (= -5 -5)))))

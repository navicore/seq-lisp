;; Float Literal Tests
;; Tests for: float?, integer?, number?, float arithmetic and comparisons

(define float-tests (list
  ;; Float literal parsing
  (test 'float-literal (assert-true (float? 3.14)))
  (test 'float-negative (assert-true (float? -2.5)))
  (test 'float-zero (assert-true (float? 0.0)))
  (test 'float-small (assert-true (float? 0.001)))

  ;; float? predicate
  (test 'float-pred-float (assert-true (float? 1.5)))
  (test 'float-pred-int (assert-false (float? 42)))
  (test 'float-pred-sym (assert-false (float? 'pi)))
  (test 'float-pred-str (assert-false (float? "3.14")))
  (test 'float-pred-list (assert-false (float? '(1.5))))

  ;; integer? predicate
  (test 'integer-pred-int (assert-true (integer? 42)))
  (test 'integer-pred-neg (assert-true (integer? -10)))
  (test 'integer-pred-zero (assert-true (integer? 0)))
  (test 'integer-pred-float (assert-false (integer? 3.14)))
  (test 'integer-pred-sym (assert-false (integer? 'num)))

  ;; number? predicate (should be true for both int and float)
  (test 'number-pred-int (assert-true (number? 42)))
  (test 'number-pred-float (assert-true (number? 3.14)))
  (test 'number-pred-neg-float (assert-true (number? -2.5)))
  (test 'number-pred-sym (assert-false (number? 'num)))
  (test 'number-pred-str (assert-false (number? "42")))

  ;; Float arithmetic
  (test 'float-add (assert-true (> (+ 1.5 2.5) 3.9)))
  (test 'float-sub (assert-true (< (- 5.0 2.5) 2.6)))
  (test 'float-mul (assert-true (> (* 2.0 3.0) 5.9)))
  (test 'float-div (assert-true (< (/ 10.0 4.0) 2.6)))

  ;; Mixed arithmetic (int + float)
  (test 'mixed-add (assert-true (> (+ 1 2.5) 3.4)))
  (test 'mixed-sub (assert-true (< (- 10 2.5) 7.6)))
  (test 'mixed-mul (assert-true (> (* 3 2.5) 7.4)))
  (test 'mixed-div (assert-true (< (/ 5 2.0) 2.6)))

  ;; Float comparisons
  (test 'float-less (assert-true (< 1.5 2.5)))
  (test 'float-greater (assert-true (> 3.5 2.5)))
  (test 'float-less-eq (assert-true (<= 2.5 2.5)))
  (test 'float-greater-eq (assert-true (>= 3.0 3.0)))
  (test 'float-eq (assert-true (= 2.5 2.5)))
  (test 'float-not-eq (assert-false (= 2.5 3.5)))

  ;; Mixed comparisons (int vs float)
  (test 'mixed-less (assert-true (< 1 1.5)))
  (test 'mixed-greater (assert-true (> 3 2.5)))
  (test 'mixed-less-eq-eq (assert-true (<= 2 2.0)))
  (test 'mixed-greater-eq-eq (assert-true (>= 3 3.0)))

  ;; Float in lists
  (test 'float-in-list (assert-true (float? (car (list 3.14 2.71)))))
  (test 'float-list-equal (assert-true (equal? (list 1.5) (list 1.5))))

  ;; abs with floats
  (test 'abs-float-pos (assert-true (> (abs 2.5) 2.4)))
  (test 'abs-float-neg (assert-true (> (abs -2.5) 2.4)))

  ;; min/max with floats
  (test 'min-floats (assert-true (< (min 1.5 2.5 0.5) 0.6)))
  (test 'max-floats (assert-true (> (max 1.5 2.5 0.5) 2.4)))
  (test 'min-mixed (assert-true (< (min 1 2.5 0.5) 0.6)))
  (test 'max-mixed (assert-true (> (max 1 2.5 3) 2.9)))))

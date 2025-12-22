;; Conditional Tests
;; Tests for: if, cond

(define conditional-tests (list
  ;; if - basic
  (test 'if-true (assert-eq (if #t 'yes 'no) 'yes))
  (test 'if-false (assert-eq (if #f 'yes 'no) 'no))
  ;; if - truthiness
  (test 'if-zero-falsy (assert-eq (if 0 'yes 'no) 'no))
  (test 'if-number-truthy (assert-eq (if 42 'yes 'no) 'yes))
  (test 'if-negative-truthy (assert-eq (if -1 'yes 'no) 'yes))
  (test 'if-empty-list-truthy (assert-eq (if '() 'yes 'no) 'yes))
  (test 'if-list-truthy (assert-eq (if '(a b) 'yes 'no) 'yes))
  (test 'if-symbol-truthy (assert-eq (if 'foo 'yes 'no) 'yes))
  ;; if - nested
  (test 'if-nested (assert-eq (if #t (if #f 'a 'b) 'c) 'b))
  ;; if - expression results
  (test 'if-expr-then (assert-eq (if (< 1 2) (+ 1 1) (+ 2 2)) 2))
  (test 'if-expr-else (assert-eq (if (> 1 2) (+ 1 1) (+ 2 2)) 4))
  ;; cond - basic
  (test 'cond-first (assert-eq (cond (#t 'a) (#t 'b)) 'a))
  (test 'cond-second (assert-eq (cond (#f 'a) (#t 'b)) 'b))
  (test 'cond-third (assert-eq (cond (#f 'a) (#f 'b) (#t 'c)) 'c))
  ;; cond - else
  (test 'cond-else (assert-eq (cond (#f 'a) (else 'b)) 'b))
  (test 'cond-else-fallthrough (assert-eq (cond (#f 'a) (#f 'b) (else 'c)) 'c))
  ;; cond - expressions
  (test 'cond-expr-test (assert-eq (cond ((< 1 2) 'less) (else 'not-less)) 'less))
  (test 'cond-expr-result (assert-eq (cond (#t (+ 1 2))) 3))
  ;; cond - empty (no match)
  (test 'cond-no-match (assert-eq (cond (#f 'a) (#f 'b)) '()))))

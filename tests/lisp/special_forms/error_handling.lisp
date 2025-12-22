;; Error Handling Tests
;; Tests for: try, ok?, error?, assert-error

(define error-handling-tests (list
  ;; try - success cases
  (test 'try-ok-number (assert-eq (try (+ 1 2)) '(ok 3)))
  (test 'try-ok-list (assert-eq (try (list 'a 'b)) '(ok (a b))))
  (test 'try-ok-symbol (assert-eq (try 'foo) '(ok foo)))
  (test 'try-ok-quote (assert-eq (try '(1 2 3)) '(ok (1 2 3))))
  ;; try - error cases
  (test 'try-error-type (assert-true (error? (try (car 42)))))
  (test 'try-error-div (assert-true (error? (try (/ 1 0)))))
  (test 'try-error-undef (assert-true (error? (try undefined-symbol))))
  (test 'try-error-arity (assert-true (error? (try (cons 1)))))
  ;; ok? predicate
  (test 'ok-pred-true (assert-true (ok? '(ok 5))))
  (test 'ok-pred-false (assert-false (ok? '(error msg))))
  (test 'ok-pred-other (assert-false (ok? '(foo bar))))
  (test 'ok-pred-non-list (assert-false (ok? 42)))
  ;; error? predicate
  (test 'error-pred-true (assert-true (error? '(error msg))))
  (test 'error-pred-false (assert-false (error? '(ok 5))))
  (test 'error-pred-other (assert-false (error? '(foo bar))))
  (test 'error-pred-non-list (assert-false (error? 'error)))
  ;; ok-value accessor
  (test 'ok-value (assert-eq (ok-value '(ok 42)) 42))
  (test 'ok-value-list (assert-eq (ok-value '(ok (a b))) '(a b)))
  ;; error-message accessor
  (test 'error-message (assert-eq (error-message '(error oops)) 'oops))
  ;; assert-error - catches errors
  (test 'assert-error-type (assert-error (car 42)))
  (test 'assert-error-div (assert-error (/ 1 0)))
  (test 'assert-error-undef (assert-error no-such-function))
  (test 'assert-error-cdr-num (assert-error (cdr 5)))))

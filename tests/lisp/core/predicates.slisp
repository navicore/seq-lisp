;; Predicate Tests
;; Tests for: null?, number?, symbol?, list?, boolean?, equal?

(define predicate-tests (list
  ;; null?
  (test 'null-empty (assert-true (null? '())))
  (test 'null-nonempty (assert-false (null? '(1))))
  (test 'null-number (assert-false (null? 0)))
  ;; number?
  (test 'number-int (assert-true (number? 42)))
  (test 'number-negative (assert-true (number? -5)))
  (test 'number-zero (assert-true (number? 0)))
  (test 'number-symbol (assert-false (number? 'foo)))
  (test 'number-list (assert-false (number? '(1 2))))
  ;; symbol?
  (test 'symbol-sym (assert-true (symbol? 'foo)))
  (test 'symbol-number (assert-false (symbol? 42)))
  (test 'symbol-list (assert-false (symbol? '(a b))))
  ;; list?
  (test 'list-empty (assert-true (list? '())))
  (test 'list-nonempty (assert-true (list? '(1 2 3))))
  (test 'list-number (assert-false (list? 42)))
  (test 'list-symbol (assert-false (list? 'foo)))
  ;; boolean?
  (test 'boolean-true (assert-true (boolean? #t)))
  (test 'boolean-false (assert-true (boolean? #f)))
  (test 'boolean-number (assert-false (boolean? 1)))
  (test 'boolean-symbol (assert-false (boolean? 'true)))
  ;; equal? (structural equality)
  (test 'equal-numbers (assert-true (equal? 42 42)))
  (test 'equal-symbols (assert-true (equal? 'foo 'foo)))
  (test 'equal-lists (assert-true (equal? '(1 2 3) '(1 2 3))))
  (test 'equal-nested (assert-true (equal? '((a b) (c d)) '((a b) (c d)))))
  (test 'not-equal-numbers (assert-false (equal? 1 2)))
  (test 'not-equal-lists (assert-false (equal? '(1 2) '(1 3))))
  (test 'equal-empty-lists (assert-true (equal? '() '())))
  (test 'equal-nested-empty (assert-true (equal? '(()) '(()))))
  (test 'equal-num-sym (assert-false (equal? 1 'one)))
  (test 'equal-num-list (assert-false (equal? 1 '(1))))
  (test 'equal-sym-list (assert-false (equal? 'a '(a))))
  (test 'equal-deep (assert-true (equal? '((((a)))) '((((a)))))))
  (test 'equal-deep-diff (assert-false (equal? '((((a)))) '((((b)))))))))

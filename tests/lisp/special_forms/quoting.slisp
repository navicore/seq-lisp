;; Quoting Tests
;; Tests for: quote, '

(define quoting-tests (list
  ;; quote - symbols
  (test 'quote-symbol (assert-eq 'foo 'foo))
  (test 'quote-symbol-explicit (assert-eq (quote bar) 'bar))
  ;; quote - numbers (self-evaluating, but quote works)
  (test 'quote-number (assert-eq '42 42))
  ;; quote - lists
  (test 'quote-list (assert-eq '(1 2 3) '(1 2 3)))
  (test 'quote-list-symbols (assert-eq '(a b c) '(a b c)))
  (test 'quote-list-mixed (assert-eq '(a 1 b 2) '(a 1 b 2)))
  ;; quote - nested lists
  (test 'quote-nested (assert-eq '((a b) (c d)) '((a b) (c d))))
  (test 'quote-deeply-nested (assert-eq '(((1))) '(((1)))))
  ;; quote - empty list
  (test 'quote-empty (assert-eq '() '()))
  ;; quote - prevents evaluation
  (test 'quote-no-eval (assert-eq '(+ 1 2) '(+ 1 2)))
  (test 'quote-lambda-literal (assert-eq (car '(lambda (x) x)) 'lambda))
  ;; quote vs evaluation
  (test 'quote-vs-eval (assert-false (equal? '(+ 1 2) (+ 1 2))))))

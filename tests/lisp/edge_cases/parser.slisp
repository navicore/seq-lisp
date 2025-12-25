;; Parser Edge Cases
;; Tests for edge cases in parsing S-expressions
;;
;; TODO: These are aspirational tests for parser robustness.
;; Many may fail until parser improvements are made.

(define parser-edge-tests (list
  ;; Empty expressions
  (test 'parse-empty-list (assert-eq '() '()))
  ;; Nested empty lists
  (test 'parse-nested-empty (assert-eq '(()) '(())))
  (test 'parse-deep-empty (assert-eq '((())) '((()))))
  ;; Mixed nesting
  (test 'parse-mixed-nesting (assert-eq '(a (b (c)) d) '(a (b (c)) d)))
  ;; Long lists
  (test 'parse-long-list (assert-eq (length '(1 2 3 4 5 6 7 8 9 10)) 10))
  ;; Symbols with special characters (if supported)
  ;; (test 'parse-symbol-dash (assert-eq 'foo-bar 'foo-bar))
  ;; (test 'parse-symbol-question (assert-eq 'null? 'null?))
  ;; Numbers
  (test 'parse-negative (assert-eq '-42 -42))
  (test 'parse-zero (assert-eq '0 0))))

;; TODO: Future parser tests
;; - Unicode symbols (if supported)
;; - Very deeply nested expressions
;; - Comments handling
;; - String literals (when implemented)
;; - Reader macros (if implemented)

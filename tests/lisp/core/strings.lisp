;; String Literal Tests
;; Tests for: string?, equal? with strings, string literals

(define string-tests (list
  ;; String literal parsing
  (test 'string-literal (assert-true (string? "hello")))
  (test 'string-with-space (assert-true (string? "hello world")))
  (test 'empty-string (assert-true (string? "")))

  ;; string? predicate
  (test 'string-pred-str (assert-true (string? "test")))
  (test 'string-pred-sym (assert-false (string? 'test)))
  (test 'string-pred-num (assert-false (string? 42)))
  (test 'string-pred-float (assert-false (string? 3.14)))
  (test 'string-pred-list (assert-false (string? '(a b))))
  (test 'string-pred-nil (assert-false (string? '())))

  ;; String equality
  (test 'string-equal-same (assert-true (equal? "abc" "abc")))
  (test 'string-equal-diff (assert-false (equal? "abc" "xyz")))
  (test 'string-equal-empty (assert-true (equal? "" "")))
  (test 'string-equal-case (assert-false (equal? "ABC" "abc")))

  ;; Strings vs symbols
  (test 'string-not-symbol (assert-false (equal? "foo" 'foo)))
  (test 'string-pred-on-symbol (assert-false (string? 'hello)))

  ;; Escape sequences
  (test 'string-escaped-quote (assert-true (string? "hello\"world")))
  (test 'string-escaped-backslash (assert-true (string? "path\\to\\file")))
  (test 'string-escaped-newline (assert-true (string? "line1\nline2")))

  ;; Strings in lists
  (test 'string-in-list (assert-true (string? (car (list "hello" "world")))))
  (test 'string-list-equal (assert-true (equal? (list "a" "b") (list "a" "b"))))
  (test 'string-list-diff (assert-false (equal? (list "a") (list "b"))))))

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
  (test 'string-list-diff (assert-false (equal? (list "a") (list "b"))))

  ;; string-length
  (test 'string-length-empty (assert-eq 0 (string-length "")))
  (test 'string-length-basic (assert-eq 5 (string-length "hello")))
  (test 'string-length-with-space (assert-eq 11 (string-length "hello world")))
  (test 'string-length-with-newline (assert-eq 6 (string-length "hello\n")))

  ;; substring (start, length)
  (test 'substring-basic (assert-eq "ell" (substring "hello" 1 3)))
  (test 'substring-from-start (assert-eq "hel" (substring "hello" 0 3)))
  (test 'substring-to-end (assert-eq "lo" (substring "hello" 3 2)))
  (test 'substring-full (assert-eq "hello" (substring "hello" 0 5)))
  (test 'substring-empty (assert-eq "" (substring "hello" 2 0)))
  (test 'substring-single (assert-eq "e" (substring "hello" 1 1)))
  (test 'substring-clamp (assert-eq "lo" (substring "hello" 3 100)))

  ;; string-append
  (test 'string-append-two (assert-eq "helloworld" (string-append "hello" "world")))
  (test 'string-append-empty-left (assert-eq "hello" (string-append "" "hello")))
  (test 'string-append-empty-right (assert-eq "hello" (string-append "hello" "")))
  (test 'string-append-three (assert-eq "abc" (string-append "a" "b" "c")))
  (test 'string-append-one (assert-eq "hello" (string-append "hello")))
  (test 'string-append-zero (assert-eq "" (string-append)))))

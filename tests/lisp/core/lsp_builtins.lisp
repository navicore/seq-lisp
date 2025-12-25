;; LSP Builtins Tests
;; Tests for parse-with-errors and eval-with-errors builtins

;; Helper to check if result is (ok value)
(define (lsp-ok? result)
  (if (list? result)
      (equal? (car result) 'ok)
      #f))

;; Helper to check if result is (error ...)
(define (lsp-error? result)
  (if (list? result)
      (equal? (car result) 'error)
      #f))

;; Extract value from (ok value)
(define (lsp-ok-value result)
  (car (cdr result)))

;; Extract message from (error message line col end-line end-col)
(define (lsp-error-msg result)
  (car (cdr result)))

;; Extract start line from error
(define (lsp-error-line result)
  (car (cdr (cdr result))))

;; Extract start column from error
(define (lsp-error-col result)
  (car (cdr (cdr (cdr result)))))

;; ============================================
;; parse-with-errors tests
;; ============================================

(define parse-with-errors-tests
  (list
    ;; Successful parsing
    (test 'parse-ok-number
      (let result (parse-with-errors "42")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) 42)
            #f)))

    (test 'parse-ok-symbol
      (let result (parse-with-errors "foo")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) 'foo)
            #f)))

    (test 'parse-ok-list
      (let result (parse-with-errors "(+ 1 2)")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) '(+ 1 2))
            #f)))

    (test 'parse-ok-string
      (let result (parse-with-errors "\"hello\"")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) "hello")
            #f)))

    (test 'parse-ok-nested
      (let result (parse-with-errors "((a b) (c d))")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) '((a b) (c d)))
            #f)))
  ))

;; ============================================
;; eval-with-errors tests - success cases
;; ============================================

(define eval-with-errors-ok-tests
  (list
    ;; Successful evaluation
    (test 'eval-ok-number
      (let result (eval-with-errors "42")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) 42)
            #f)))

    (test 'eval-ok-arithmetic
      (let result (eval-with-errors "(+ 1 2)")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) 3)
            #f)))

    (test 'eval-ok-nested
      (let result (eval-with-errors "(* (+ 1 2) (- 5 3))")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) 6)
            #f)))

    (test 'eval-ok-string
      (let result (eval-with-errors "\"hello\"")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) "hello")
            #f)))

    (test 'eval-ok-boolean
      (let result (eval-with-errors "#t")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) #t)
            #f)))

    (test 'eval-ok-define
      (let result (eval-with-errors "(define x 42)")
        (if (lsp-ok? result)
            (equal? (lsp-ok-value result) 42)
            #f)))
  ))

;; ============================================
;; eval-with-errors tests - error cases
;; ============================================

(define eval-with-errors-err-tests
  (list
    ;; Undefined symbol error
    (test 'eval-err-undefined
      (let result (eval-with-errors "undefined-symbol")
        (lsp-error? result)))

    ;; Check error has correct message format
    (test 'eval-err-message
      (let result (eval-with-errors "xyz")
        (if (lsp-error? result)
            (string? (lsp-error-msg result))
            #f)))

    ;; Check error has position info (line should be 1)
    (test 'eval-err-line
      (let result (eval-with-errors "unknown")
        (if (lsp-error? result)
            (equal? (lsp-error-line result) 1)
            #f)))

    ;; Check error has position info (col should be 1 for first token)
    (test 'eval-err-col
      (let result (eval-with-errors "unknown")
        (if (lsp-error? result)
            (equal? (lsp-error-col result) 1)
            #f)))

    ;; Error in nested expression should have correct position
    (test 'eval-err-nested-pos
      (let result (eval-with-errors "(+ 1 bad)")
        (if (lsp-error? result)
            (equal? (lsp-error-col result) 6)
            #f)))

    ;; Type error - calling non-function
    (test 'eval-err-not-function
      (let result (eval-with-errors "(1 2 3)")
        (lsp-error? result)))
  ))

;; Combine all LSP builtin tests
(define lsp-builtin-tests
  (append parse-with-errors-tests
  (append eval-with-errors-ok-tests
          eval-with-errors-err-tests)))

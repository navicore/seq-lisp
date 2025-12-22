;; SeqLisp Test Framework
;;
;; A simple test framework built using macros.
;; Supports test suites with named tests, nice output, and exit codes.
;;
;; Usage:
;;   (run-suite 'MySuite
;;     (test 'addition (assert-eq (+ 1 2) 3))
;;     (test 'comparison (assert-eq '(a b) '(a b))))
;;
;; Note: Until file loading is implemented, copy this framework
;; into your test file or use inline.

;; ============================================
;; Result Constructors
;; ============================================

;; A passing test result: (pass name)
(define (make-pass name) (list 'pass name))

;; A failing test result: (fail name expected actual)
(define (make-fail name expected actual) (list 'fail name expected actual))

;; ============================================
;; Result Predicates
;; ============================================

(define (pass? result) (equal? (car result) 'pass))
(define (fail? result) (equal? (car result) 'fail))

;; ============================================
;; Result Accessors
;; ============================================

(define (result-name result) (car (cdr result)))
(define (result-expected result) (car (cdr (cdr result))))
(define (result-actual result) (car (cdr (cdr (cdr result)))))

;; ============================================
;; Try Result Helpers
;; ============================================

;; Check if a try result is successful: (ok value)
(define (ok? result)
  (if (list? result)
      (equal? (car result) 'ok)
      #f))

;; Check if a try result is an error: (error message)
(define (error? result)
  (if (list? result)
      (equal? (car result) 'error)
      #f))

;; Extract the value from (ok value)
(define (ok-value result) (car (cdr result)))

;; Extract the message from (error message)
(define (error-message result) (car (cdr result)))

;; ============================================
;; Assertion Macros
;; ============================================

;; assert-eq: Check if two values are structurally equal
;; Returns: #t on pass, (fail-info expected actual) on fail
(defmacro (assert-eq expected actual)
  `(if (equal? ,expected ,actual)
       '#t
       (list 'fail-info ,expected ,actual)))

;; assert-true: Check if expression is truthy (not #f)
(defmacro (assert-true expr)
  `(if (equal? ,expr '#f)
       (list 'fail-info '#t ,expr)
       '#t))

;; assert-false: Check if expression is #f
(defmacro (assert-false expr)
  `(if (equal? ,expr '#f)
       '#t
       (list 'fail-info '#f ,expr)))

;; assert-error: Check if expression produces an error
;; Usage: (assert-error (car 42)) or (assert-error (/ 1 0))
(defmacro (assert-error expr)
  `(let result (try ,expr)
     (if (error? result)
         '#t
         (list 'fail-info 'error result))))

;; ============================================
;; Test Wrapper
;; ============================================

;; test: Run an assertion and tag the result with a name
;; Returns: (pass name) or (fail name expected actual)
(defmacro (test name assertion)
  `(let result ,assertion
     (if (equal? result '#t)
         (make-pass ,name)
         (make-fail ,name
                    (car (cdr result))
                    (car (cdr (cdr result)))))))

;; ============================================
;; Printing Helpers
;; ============================================

;; Print a single test result
(define (print-result result)
  (if (pass? result)
      (print (list 'PASS (result-name result)))
      (print (list 'FAIL (result-name result))))
  result)

;; Print all results
(define (print-each results)
  (if (null? results)
      '()
      (begin
        (print-result (car results))
        (print-each (cdr results)))))

;; ============================================
;; Result Counting
;; ============================================

;; Count passes in a list of results
(define (count-passes results)
  (if (null? results)
      0
      (+ (if (pass? (car results)) 1 0)
         (count-passes (cdr results)))))

;; Count failures in a list of results
(define (count-fails results)
  (if (null? results)
      0
      (+ (if (pass? (car results)) 0 1)
         (count-fails (cdr results)))))

;; ============================================
;; Suite Runner
;; ============================================

;; run-suite: Collect tests, print results, exit with appropriate code
;; Usage: (run-suite 'SuiteName (test ...) (test ...) ...)
(defmacro (run-suite name . tests)
  `(let results (list ,@tests)
     (begin
       (print ,name)
       (print-each results)
       (let passes (count-passes results)
         (let fails (count-fails results)
           (begin
             (print (list passes 'passed fails 'failed))
             (if (= fails 0)
                 (exit 0)
                 (exit 1))))))))

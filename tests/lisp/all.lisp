;; SeqLisp Comprehensive Test Suite Runner
;;
;; This file is designed to be concatenated with all test files.
;; Run with: just lisp-test
;;
;; Test organization:
;;   tests/lisp/core/          - Core language features
;;   tests/lisp/functions/     - Functions and closures
;;   tests/lisp/special_forms/ - Special forms
;;   tests/lisp/macros/        - Macro system
;;   tests/lisp/edge_cases/    - Edge cases and aspirational tests

;; ============================================
;; Aggregate All Test Results
;; ============================================

(define all-results
  (append arithmetic-tests
  (append comparison-tests
  (append predicate-tests
  (append list-tests
  (append closure-tests
  (append higher-order-tests
  (append recursion-tests
  (append tco-tests
  (append conditional-tests
  (append sequencing-tests
  (append quoting-tests
  (append error-handling-tests
  (append defmacro-tests
  (append quasiquote-tests
  (append gensym-tests
  (append parser-edge-tests
          io-tests)))))))))))))))))

;; ============================================
;; Run Tests and Report
;; ============================================

(print 'SeqLisp-Test-Suite)
(print '------------------------)
(print-each all-results)
(print '------------------------)
(print (list (count-passes all-results) 'passed (count-fails all-results) 'failed))
(if (= (count-fails all-results) 0) (exit 0) (exit 1))

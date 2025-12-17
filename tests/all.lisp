;; SeqLisp Comprehensive Test Suite
;;
;; Run with: just lisp-test
;; Or: cat lib/test.lisp tests/all.lisp | ./seqlisp
;;
;; This file assumes lib/test.lisp has been prepended.

;; ============================================
;; Arithmetic Tests
;; ============================================

(define arithmetic-tests (list
  (test 'add-positive (assert-eq (+ 1 2) 3))
  (test 'add-zero (assert-eq (+ 0 5) 5))
  (test 'add-negative (assert-eq (+ -3 3) 0))
  (test 'sub-positive (assert-eq (- 10 4) 6))
  (test 'sub-negative (assert-eq (- 1 5) -4))
  (test 'mul-positive (assert-eq (* 3 4) 12))
  (test 'mul-zero (assert-eq (* 100 0) 0))
  (test 'mul-negative (assert-eq (* -2 3) -6))
  (test 'div-exact (assert-eq (/ 10 2) 5))
  (test 'div-negative (assert-eq (/ -12 3) -4))))

;; ============================================
;; Comparison Tests
;; ============================================

(define comparison-tests (list
  (test 'less-than (assert-true (< 1 2)))
  (test 'greater-than (assert-true (> 5 3)))
  (test 'less-eq (assert-true (<= 3 3)))
  (test 'greater-eq (assert-true (>= 4 4)))
  (test 'numeric-eq (assert-true (= 42 42)))))

;; ============================================
;; List Operations Tests
;; ============================================

(define list-tests (list
  (test 'car (assert-eq (car '(1 2 3)) 1))
  (test 'cdr (assert-eq (cdr '(1 2 3)) '(2 3)))
  (test 'cons (assert-eq (cons 1 '(2 3)) '(1 2 3)))
  (test 'length (assert-eq (length '(a b c d e)) 5))
  (test 'append (assert-eq (append '(1 2) '(3 4)) '(1 2 3 4)))
  (test 'reverse (assert-eq (reverse '(1 2 3)) '(3 2 1)))
  (test 'nth (assert-eq (nth 2 '(a b c d)) 'c))
  (test 'last (assert-eq (last '(1 2 3 4 5)) 5))
  (test 'take (assert-eq (take 3 '(1 2 3 4 5)) '(1 2 3)))
  (test 'drop (assert-eq (drop 2 '(1 2 3 4 5)) '(3 4 5)))))

;; ============================================
;; Higher-Order Function Tests
;; ============================================

(define hof-tests (list
  (test 'map-square (assert-eq (map (lambda (x) (* x x)) '(1 2 3)) '(1 4 9)))
  (test 'filter-positive (assert-eq (filter (lambda (x) (> x 0)) '(-1 2 -3 4)) '(2 4)))
  (test 'fold-sum (assert-eq (fold (lambda (a b) (+ a b)) 0 '(1 2 3 4)) 10))))

;; ============================================
;; Equality Tests
;; ============================================

(define equality-tests (list
  (test 'equal-numbers (assert-true (equal? 42 42)))
  (test 'equal-symbols (assert-true (equal? 'foo 'foo)))
  (test 'equal-lists (assert-true (equal? '(1 2 3) '(1 2 3))))
  (test 'equal-nested (assert-true (equal? '((a b) (c d)) '((a b) (c d)))))
  (test 'not-equal-numbers (assert-false (equal? 1 2)))
  (test 'not-equal-lists (assert-false (equal? '(1 2) '(1 3))))))

;; ============================================
;; Predicate Tests
;; ============================================

(define predicate-tests (list
  (test 'null-empty (assert-true (null? '())))
  (test 'null-nonempty (assert-false (null? '(1))))
  (test 'number-pred (assert-true (number? 42)))
  (test 'symbol-pred (assert-true (symbol? 'foo)))
  (test 'list-pred (assert-true (list? '(1 2 3))))
  (test 'boolean-true (assert-true (boolean? '#t)))
  (test 'boolean-false (assert-true (boolean? '#f)))))

;; ============================================
;; Combine and Run All Tests
;; ============================================

(define all-results
  (append arithmetic-tests
    (append comparison-tests
      (append list-tests
        (append hof-tests
          (append equality-tests predicate-tests))))))

(print 'SeqLisp-Test-Suite)
(print-each all-results)
(print (list (count-passes all-results) 'passed (count-fails all-results) 'failed))
(if (= (count-fails all-results) 0) (exit 0) (exit 1))

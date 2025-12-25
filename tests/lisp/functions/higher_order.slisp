;; Higher-Order Function Tests
;; Tests for: map, filter, fold, apply

;; Helper for apply tests
(define (add2 a b) (+ a b))

(define higher-order-tests (list
  ;; Map
  (test 'map-square (assert-eq (map (lambda (x) (* x x)) '(1 2 3)) '(1 4 9)))
  (test 'map-add-one (assert-eq (map (lambda (x) (+ x 1)) '(0 1 2)) '(1 2 3)))
  (test 'map-empty (assert-eq (map (lambda (x) x) '()) '()))
  (test 'map-identity (assert-eq (map (lambda (x) x) '(a b c)) '(a b c)))
  ;; Filter
  (test 'filter-positive (assert-eq (filter (lambda (x) (> x 0)) '(-1 2 -3 4)) '(2 4)))
  (test 'filter-even (assert-eq (filter (lambda (x) (= (modulo x 2) 0)) '(1 2 3 4 5 6)) '(2 4 6)))
  (test 'filter-all (assert-eq (filter (lambda (x) #t) '(a b c)) '(a b c)))
  (test 'filter-none (assert-eq (filter (lambda (x) #f) '(a b c)) '()))
  (test 'filter-empty (assert-eq (filter (lambda (x) #t) '()) '()))
  ;; Fold
  (test 'fold-sum (assert-eq (fold (lambda (a b) (+ a b)) 0 '(1 2 3 4)) 10))
  (test 'fold-product (assert-eq (fold (lambda (a b) (* a b)) 1 '(1 2 3 4)) 24))
  (test 'fold-cons (assert-eq (fold (lambda (a b) (cons b a)) '() '(1 2 3)) '(3 2 1)))
  (test 'fold-empty (assert-eq (fold (lambda (a b) (+ a b)) 99 '()) 99))
  ;; Apply with builtin functions
  (test 'apply-add (assert-eq (apply + '(1 2 3 4)) 10))
  (test 'apply-mul (assert-eq (apply * '(2 3 4)) 24))
  (test 'apply-list (assert-eq (apply list '(a b c)) '(a b c)))
  (test 'apply-min (assert-eq (apply min '(5 2 8 1 9)) 1))
  (test 'apply-max (assert-eq (apply max '(5 2 8 1 9)) 9))
  ;; Apply with empty list
  (test 'apply-add-empty (assert-eq (apply + '()) 0))
  (test 'apply-mul-empty (assert-eq (apply * '()) 1))
  ;; Apply with lambda
  (test 'apply-lambda (assert-eq (apply (lambda (x y) (+ x y)) '(3 4)) 7))
  ;; Apply with defined function
  (test 'apply-defined (assert-eq (apply add2 '(5 7)) 12))
  ;; Nested apply (composition)
  (test 'apply-nested (assert-eq (apply + (apply list '(1 2 3))) 6))
  ;; Partial application via apply (currying)
  (test 'apply-partial (assert-eq ((apply (lambda (x y z) (+ x (+ y z))) '(1 2)) 3) 6))))

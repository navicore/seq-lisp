;; Recursion Tests
;; Tests for recursive function definitions

;; Standard recursive factorial (not tail-recursive)
(define (factorial n)
  (if (< n 2) 1 (* n (factorial (- n 1)))))

;; Standard recursive fibonacci (not tail-recursive)
(define (fibonacci n)
  (if (< n 2) n (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))

;; Recursive list length
(define (my-length lst)
  (if (null? lst) 0 (+ 1 (my-length (cdr lst)))))

;; Recursive list sum
(define (list-sum lst)
  (if (null? lst) 0 (+ (car lst) (list-sum (cdr lst)))))

(define recursion-tests (list
  ;; Factorial
  (test 'fact-0 (assert-eq (factorial 0) 1))
  (test 'fact-1 (assert-eq (factorial 1) 1))
  (test 'fact-5 (assert-eq (factorial 5) 120))
  (test 'fact-10 (assert-eq (factorial 10) 3628800))
  ;; Fibonacci
  (test 'fib-0 (assert-eq (fibonacci 0) 0))
  (test 'fib-1 (assert-eq (fibonacci 1) 1))
  (test 'fib-10 (assert-eq (fibonacci 10) 55))
  ;; List length
  (test 'rec-length-empty (assert-eq (my-length '()) 0))
  (test 'rec-length-five (assert-eq (my-length '(a b c d e)) 5))
  ;; List sum
  (test 'rec-sum-empty (assert-eq (list-sum '()) 0))
  (test 'rec-sum-five (assert-eq (list-sum '(1 2 3 4 5)) 15))))

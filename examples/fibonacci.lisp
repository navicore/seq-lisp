;; Fibonacci sequence in SeqLisp
;;
;; Demonstrates recursion

(define fib
  (lambda (n)
    (if (<= n 1)
        n
        (+ (fib (- n 1))
           (fib (- n 2))))))

;; Expected: 0, 1, 5, 55
(print (fib 0))
(print (fib 1))
(print (fib 5))
(print (fib 10))

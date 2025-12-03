;; Fibonacci sequence in SeqLisp - demonstrates recursion
(define fib (lambda (n) (if (<= n 1) n (+ (fib (- n 1)) (fib (- n 2))))))
;; fib(0)=0, fib(1)=1, fib(5)=5, fib(10)=55
(print (fib 0))
(print (fib 1))
(print (fib 5))
(print (fib 10))

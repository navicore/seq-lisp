;; Factorial in SeqLisp - demonstrates recursion and conditionals
(define factorial (lambda (n) (if (<= n 1) 1 (* n (factorial (- n 1))))))
;; factorial(5) = 120, factorial(10) = 3628800
(print (factorial 5))
(print (factorial 10))

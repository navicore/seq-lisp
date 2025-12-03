;; Fibonacci sequence in SeqLisp
;;
;; Demonstrates recursion

(define fib
  (lambda (n)
    (if (<= n 1)
        n
        (+ (fib (- n 1))
           (fib (- n 2))))))

(print "Fibonacci sequence:")
(print (fib 0))   ;; 0
(print (fib 1))   ;; 1
(print (fib 5))   ;; 5
(print (fib 10))  ;; 55

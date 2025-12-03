;; Factorial in SeqLisp
;;
;; Demonstrates recursion and conditionals

(define factorial
  (lambda (n)
    (if (<= n 1)
        1
        (* n (factorial (- n 1))))))

;; Expected: 120, 3628800
(print (factorial 5))
(print (factorial 10))

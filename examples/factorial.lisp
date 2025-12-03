;; Factorial in SeqLisp
;;
;; Demonstrates recursion and conditionals

(define factorial
  (lambda (n)
    (if (<= n 1)
        1
        (* n (factorial (- n 1))))))

(print "Factorial examples:")
(print (factorial 5))   ;; 120
(print (factorial 10))  ;; 3628800

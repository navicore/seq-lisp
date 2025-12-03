;; Arithmetic in SeqLisp
;;
;; Demonstrates basic operations and nested expressions

(print "Basic arithmetic:")
(print (+ 1 2))           ;; 3
(print (- 10 4))          ;; 6
(print (* 3 4))           ;; 12
(print (/ 20 5))          ;; 4

(print "Nested expressions:")
(print (+ (* 2 3) (* 4 5)))   ;; 6 + 20 = 26
(print (/ (+ 10 20) (- 10 5))) ;; 30 / 5 = 6

(print "Comparisons:")
(print (< 1 2))   ;; true
(print (> 5 3))   ;; true
(print (= 4 4))   ;; true

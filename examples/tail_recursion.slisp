;; Tail Recursion Examples
;; These functions use O(1) stack space thanks to TCO

;; Tail-recursive factorial with accumulator
(define (factorial-tail n acc)
  (if (<= n 1)
      acc
      (factorial-tail (- n 1) (* acc n))))

;; Wrapper with default accumulator
(define (factorial n)
  (factorial-tail n 1))

;; Tail-recursive sum: 1 + 2 + ... + n
(define (sum-tail n acc)
  (if (<= n 0)
      acc
      (sum-tail (- n 1) (+ acc n))))

(define (sum n)
  (sum-tail n 0))

;; Tail-recursive length
(define (length-tail lst acc)
  (if (null? lst)
      acc
      (length-tail (cdr lst) (+ acc 1))))

;; Tail-recursive reverse
(define (reverse-tail lst acc)
  (if (null? lst)
      acc
      (reverse-tail (cdr lst) (cons (car lst) acc))))

;; Demo: these work to arbitrary depth
(print 'factorial-10)
(print (factorial 10))

(print 'factorial-20)
(print (factorial 20))

(print 'sum-100)
(print (sum 100))

;; This would overflow without TCO!
(print 'sum-10000)
(print (sum 10000))

(print 'reverse-list)
(print (reverse-tail '(1 2 3 4 5) '()))

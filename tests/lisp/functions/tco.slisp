;; Tail Call Optimization Tests
;; Tests that verify TCO works for deep recursion

;; Tail-recursive sum: (sum-tail n acc) -> acc + 1 + 2 + ... + n
(define (sum-tail n acc)
  (if (<= n 0)
      acc
      (sum-tail (- n 1) (+ acc n))))

;; Tail-recursive countdown: just recurses, no accumulation
(define (countdown n)
  (if (<= n 0)
      'done
      (countdown (- n 1))))

;; Tail-recursive with let in tail position
(define (let-loop n)
  (if (<= n 0)
      'done
      (let next (- n 1)
        (let-loop next))))

;; Tail-recursive factorial
(define (factorial-tail n acc)
  (if (<= n 1)
      acc
      (factorial-tail (- n 1) (* acc n))))

;; Tail-recursive length
(define (length-tail lst acc)
  (if (null? lst)
      acc
      (length-tail (cdr lst) (+ acc 1))))

;; TCO tests: these would stack overflow without proper tail call optimization
;; Depth 10000 is enough to crash without TCO but safe with it
(define tco-tests (list
  ;; Deep tail-recursive sum (tests if branches)
  (test 'tco-sum-10000 (assert-eq (sum-tail 10000 0) 50005000))
  ;; Deep countdown (tests if branches)
  (test 'tco-countdown-10000 (assert-eq (countdown 10000) 'done))
  ;; Deep let-based loop (tests let body)
  (test 'tco-let-10000 (assert-eq (let-loop 10000) 'done))
  ;; Tail-recursive factorial
  (test 'tco-factorial-20 (assert-eq (factorial-tail 20 1) 2432902008176640000))
  ;; Tail-recursive length (80 element list from 8 appends of 10 each)
  (test 'tco-length-deep (assert-eq (length-tail
    (append (append (append '(1 2 3 4 5 6 7 8 9 10) '(1 2 3 4 5 6 7 8 9 10))
      (append '(1 2 3 4 5 6 7 8 9 10) '(1 2 3 4 5 6 7 8 9 10)))
        (append (append '(1 2 3 4 5 6 7 8 9 10) '(1 2 3 4 5 6 7 8 9 10))
          (append '(1 2 3 4 5 6 7 8 9 10) '(1 2 3 4 5 6 7 8 9 10)))) 0) 80))))

;; List Operations Tests
;; Tests for: cons, car, cdr, list, append, reverse, length, nth, last, take, drop

(define list-tests (list
  ;; Basic list operations
  (test 'car (assert-eq (car '(1 2 3)) 1))
  (test 'car-single (assert-eq (car '(a)) 'a))
  (test 'cdr (assert-eq (cdr '(1 2 3)) '(2 3)))
  (test 'cdr-single (assert-eq (cdr '(a)) '()))
  (test 'cons (assert-eq (cons 1 '(2 3)) '(1 2 3)))
  (test 'cons-empty (assert-eq (cons 'a '()) '(a)))
  (test 'list-create (assert-eq (list 1 2 3) '(1 2 3)))
  (test 'list-empty (assert-eq (list) '()))
  (test 'list-single (assert-eq (list 'x) '(x)))
  ;; Length
  (test 'length-five (assert-eq (length '(a b c d e)) 5))
  (test 'length-empty (assert-eq (length '()) 0))
  (test 'length-one (assert-eq (length '(x)) 1))
  ;; Append
  (test 'append-two (assert-eq (append '(1 2) '(3 4)) '(1 2 3 4)))
  (test 'append-empty-left (assert-eq (append '() '(a b)) '(a b)))
  (test 'append-empty-right (assert-eq (append '(a b) '()) '(a b)))
  (test 'append-both-empty (assert-eq (append '() '()) '()))
  ;; Reverse
  (test 'reverse-three (assert-eq (reverse '(1 2 3)) '(3 2 1)))
  (test 'reverse-empty (assert-eq (reverse '()) '()))
  (test 'reverse-single (assert-eq (reverse '(a)) '(a)))
  ;; Nth (0-indexed)
  (test 'nth-first (assert-eq (nth 0 '(a b c d)) 'a))
  (test 'nth-middle (assert-eq (nth 2 '(a b c d)) 'c))
  (test 'nth-last (assert-eq (nth 3 '(a b c d)) 'd))
  ;; Last
  (test 'last-many (assert-eq (last '(1 2 3 4 5)) 5))
  (test 'last-single (assert-eq (last '(x)) 'x))
  ;; Take
  (test 'take-some (assert-eq (take 3 '(1 2 3 4 5)) '(1 2 3)))
  (test 'take-zero (assert-eq (take 0 '(a b c)) '()))
  (test 'take-all (assert-eq (take 5 '(1 2 3 4 5)) '(1 2 3 4 5)))
  ;; Drop
  (test 'drop-some (assert-eq (drop 2 '(1 2 3 4 5)) '(3 4 5)))
  (test 'drop-zero (assert-eq (drop 0 '(a b c)) '(a b c)))
  (test 'drop-all (assert-eq (drop 3 '(1 2 3)) '()))))

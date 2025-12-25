;; Quasiquote Tests
;; Tests for: ` (quasiquote), , (unquote), ,@ (splice)

(define quasiquote-tests (list
  ;; Basic quasiquote (same as quote when no unquotes)
  (test 'quasi-symbol (assert-eq `foo 'foo))
  (test 'quasi-number (assert-eq `42 42))
  (test 'quasi-list (assert-eq `(a b c) '(a b c)))
  (test 'quasi-nested (assert-eq `((a b) (c d)) '((a b) (c d))))
  ;; Unquote - inserts evaluated value
  (test 'unquote-number (assert-eq `,(+ 1 2) 3))
  (test 'unquote-in-list (assert-eq `(a ,(+ 1 2) c) '(a 3 c)))
  (test 'unquote-first (assert-eq `(,(* 2 3) b c) '(6 b c)))
  (test 'unquote-last (assert-eq `(a b ,(- 10 3)) '(a b 7)))
  (test 'unquote-multiple (assert-eq `(,(+ 1 0) ,(+ 1 1) ,(+ 1 2)) '(1 2 3)))
  ;; Unquote with variables
  (test 'unquote-var (assert-eq (let x 5 `(a ,x c)) '(a 5 c)))
  (test 'unquote-expr (assert-eq (let x 5 `(a ,(+ x 1) c)) '(a 6 c)))
  ;; Splice - inserts list elements
  (test 'splice-simple (assert-eq `(a ,@'(b c) d) '(a b c d)))
  (test 'splice-empty (assert-eq `(a ,@'() b) '(a b)))
  (test 'splice-var (assert-eq (let xs '(1 2 3) `(start ,@xs end)) '(start 1 2 3 end)))
  (test 'splice-first (assert-eq `(,@'(a b) c d) '(a b c d)))
  (test 'splice-last (assert-eq `(a b ,@'(c d)) '(a b c d)))
  ;; Mixed unquote and splice
  (test 'mixed-unquote-splice (assert-eq `(,(+ 1 1) ,@'(a b) ,(+ 2 2)) '(2 a b 4)))
  ;; Nested quasiquote (outer level)
  (test 'quasi-nested-list (assert-eq `((,1 ,2) (,3 ,4)) '((1 2) (3 4))))))

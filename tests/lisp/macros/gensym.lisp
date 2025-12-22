;; Gensym Tests
;; Tests for: gensym (unique symbol generation for macro hygiene)

(define gensym-tests (list
  ;; Basic gensym with counter
  (test 'gensym-basic (assert-eq (gensym 0) 'g0))
  (test 'gensym-counter-1 (assert-eq (gensym 1) 'g1))
  (test 'gensym-counter-42 (assert-eq (gensym 42) 'g42))
  ;; Gensym with prefix
  (test 'gensym-prefix (assert-eq (gensym 'temp 0) 'temp0))
  (test 'gensym-prefix-1 (assert-eq (gensym 'var 1) 'var1))
  (test 'gensym-prefix-x (assert-eq (gensym 'x 99) 'x99))
  ;; Gensym produces symbols
  (test 'gensym-is-symbol (assert-true (symbol? (gensym 0))))
  (test 'gensym-prefix-is-symbol (assert-true (symbol? (gensym 'foo 0))))
  ;; Gensyms with different counters are different
  (test 'gensym-unique (assert-false (equal? (gensym 0) (gensym 1))))
  (test 'gensym-prefix-unique (assert-false (equal? (gensym 'x 0) (gensym 'x 1))))))

;; TODO: Future tests when we have better macro hygiene support:
;; - Test that gensym creates symbols that don't conflict with user code
;; - Test macro expansion with gensym for hygienic variable capture
;; - Test nested macros with gensym

;; JSON Tests
;; Tests for json-parse and json-encode builtins

;; ============================================
;; json-parse tests
;; ============================================

(define json-parse-tests
  (list
    ;; Numbers
    (test 'parse-int (equal? (json-parse "42") 42))
    (test 'parse-negative (equal? (json-parse "-17") -17))
    (test 'parse-float (equal? (json-parse "3.14") 3.14))
    (test 'parse-zero (equal? (json-parse "0") 0))

    ;; Booleans
    (test 'parse-true (equal? (json-parse "true") #t))
    (test 'parse-false (equal? (json-parse "false") #f))

    ;; Null
    (test 'parse-null (equal? (json-parse "null") 'null))

    ;; Strings
    (test 'parse-string (equal? (json-parse "\"hello\"") "hello"))
    (test 'parse-empty-string (equal? (json-parse "\"\"") ""))
    (test 'parse-string-spaces (equal? (json-parse "\"hello world\"") "hello world"))

    ;; Arrays
    (test 'parse-array (equal? (json-parse "[1, 2, 3]") (list 1 2 3)))
    (test 'parse-empty-array (equal? (json-parse "[]") (list)))
    (test 'parse-nested-array (equal? (json-parse "[[1], [2, 3]]") (list (list 1) (list 2 3))))
    (test 'parse-mixed-array (equal? (json-parse "[1, \"two\", true]") (list 1 "two" #t)))

    ;; Objects
    (test 'parse-object (equal? (json-parse "{\"a\": 1}") (list (list 'a 1))))
    (test 'parse-empty-object (equal? (json-parse "{}") (list)))
    (test 'parse-multi-object (equal? (json-parse "{\"a\": 1, \"b\": 2}") (list (list 'a 1) (list 'b 2))))
    (test 'parse-nested-object (equal? (json-parse "{\"x\": {\"y\": 3}}") (list (list 'x (list (list 'y 3))))))
  ))

;; ============================================
;; json-encode tests
;; ============================================

(define json-encode-tests
  (list
    ;; Numbers
    (test 'encode-int (equal? (json-encode 42) "42"))
    (test 'encode-negative (equal? (json-encode -17) "-17"))
    (test 'encode-float (equal? (json-encode 3.14) "3.14"))
    (test 'encode-zero (equal? (json-encode 0) "0"))

    ;; Booleans
    (test 'encode-true (equal? (json-encode #t) "true"))
    (test 'encode-false (equal? (json-encode #f) "false"))

    ;; Null
    (test 'encode-null (equal? (json-encode 'null) "null"))

    ;; Strings
    (test 'encode-string (equal? (json-encode "hello") "\"hello\""))
    (test 'encode-empty-string (equal? (json-encode "") "\"\""))

    ;; Arrays (non-object lists)
    (test 'encode-array (equal? (json-encode (list 1 2 3)) "[1,2,3]"))
    (test 'encode-empty-array (equal? (json-encode (list)) "[]"))

    ;; Objects (lists of pairs)
    (test 'encode-object (equal? (json-encode (list (list 'a 1))) "{\"a\":1}"))
    (test 'encode-multi-object (equal? (json-encode (list (list 'a 1) (list 'b 2))) "{\"a\":1,\"b\":2}"))
  ))

;; ============================================
;; Round-trip tests
;; ============================================

(define json-roundtrip-tests
  (list
    (test 'roundtrip-int (equal? (json-parse (json-encode 42)) 42))
    (test 'roundtrip-float (equal? (json-parse (json-encode 3.14)) 3.14))
    (test 'roundtrip-string (equal? (json-parse (json-encode "hello")) "hello"))
    (test 'roundtrip-true (equal? (json-parse (json-encode #t)) #t))
    (test 'roundtrip-false (equal? (json-parse (json-encode #f)) #f))
    (test 'roundtrip-array (equal? (json-parse (json-encode (list 1 2 3))) (list 1 2 3)))
    (test 'roundtrip-object (equal? (json-parse (json-encode (list (list 'a 1)))) (list (list 'a 1))))
  ))

;; Combine all JSON tests
(define json-tests
  (append json-parse-tests
  (append json-encode-tests
          json-roundtrip-tests)))

;; Recursive Macro Expansion in SeqLisp
;;
;; Key insight: macro args are SYNTAX, not values
;; So (my-macro (a b c)) receives (a b c) as a list to process

;; ============================================
;; Recursive and-list macro
;; ============================================

;; Takes a syntactic list and expands recursively
(defmacro (and-list lst)
  (if (null? lst)
      '#t
      (if (null? (cdr lst))
          (car lst)
          `(if ,(car lst) (and-list ,(cdr lst)) #f))))

(print (and-list ()))              ;; #t (empty = true)
(print (and-list (#t)))            ;; #t
(print (and-list (#t #t)))         ;; #t
(print (and-list (#t #t #t)))      ;; #t
(print (and-list (#t #t #f #t)))   ;; #f (short-circuits!)
(print (and-list (#f)))            ;; #f

;; ============================================
;; Recursive or-list macro
;; ============================================

(defmacro (or-list lst)
  (if (null? lst)
      '#f
      (if (null? (cdr lst))
          (car lst)
          `(if ,(car lst) ,(car lst) (or-list ,(cdr lst))))))

(print (or-list ()))               ;; #f (empty = false)
(print (or-list (#f)))             ;; #f
(print (or-list (#f #f)))          ;; #f
(print (or-list (#f #t #f)))       ;; #t
(print (or-list (#t)))             ;; #t (short-circuits!)

;; ============================================
;; Recursive let* macro
;; ============================================

;; (let*-list ((a 1) (b 2) (c 3)) body) expands to nested lets
(defmacro (let*-list bindings body)
  (if (null? bindings)
      body
      `(let ,(car (car bindings)) ,(car (cdr (car bindings)))
         (let*-list ,(cdr bindings) ,body))))

;; Each binding can reference previous ones
(print (let*-list ((a 1) (b (+ a 1)) (c (+ b 1))) (+ a (+ b c))))
;; a=1, b=2, c=3, result = 1+2+3 = 6

(print (let*-list ((x 10) (y (* x 2)) (z (* y 2))) z))
;; x=10, y=20, z=40

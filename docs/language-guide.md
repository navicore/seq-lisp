# SeqLisp Language Guide

SeqLisp is a Lisp interpreter written in
[Seq](https://github.com/navicore/patch-seq), a stack-based concatenative
language. This guide covers the language features and how to use them.

## Why Lisp?

Lisp is one of the oldest programming languages still in active use, and for
good reason. Its core ideas remain powerful:

- **Homoiconicity**: Code is data. Programs are represented as the same data structures they manipulate.
- **Minimal syntax**: Just parentheses, symbols, and literals.
- **Extensibility**: Macros let you extend the language itself.

SeqLisp brings these ideas to the Seq ecosystem, creating an interesting
intersection of two very different paradigms: stack-based concatenative
programming and symbolic expression evaluation.

## Getting Started

### Running the REPL

```bash
just build
just run
```

Or directly:

```bash
seqc src/repl.seq -o seqlisp
./seqlisp
```

The REPL prompts you for input and evaluates expressions when you press Ctrl+D:

```
SeqLisp dev
Enter code (Ctrl+D to run):
(+ 1 2 3)
6
```

## Core Concepts

### S-Expressions

Everything in SeqLisp is an S-expression (symbolic expression):

- **Numbers**: `42`, `-7`, `0`
- **Symbols**: `foo`, `+`, `my-function`
- **Lists**: `(1 2 3)`, `(+ 1 2)`, `(define x 10)`

Lists are the fundamental structure. A list in function position is a function call:

```lisp
(+ 1 2)        ; Call + with arguments 1 and 2
(* 3 4 5)      ; Call * with arguments 3, 4, and 5
```

### Evaluation Rules

1. **Numbers** evaluate to themselves: `42` → `42`
2. **Booleans** (`#t`, `#f`) evaluate to themselves
3. **Symbols** are looked up in the environment: `x` → value of x
4. **Lists** are function applications: `(f arg1 arg2)` calls f with args

### Quoting

To prevent evaluation, use `quote` or the shorthand `'`:

```lisp
'x              ; The symbol x, not its value
'(1 2 3)        ; The list (1 2 3), not a function call
(quote (+ 1 2)) ; The list (+ 1 2), not 3
```

## Data Types

### Numbers

SeqLisp supports integers:

```lisp
42
-17
0
(+ 1 2 3)      ; 6
(- 10 3)       ; 7
(* 2 3 4)      ; 24
(/ 100 2 5)    ; 10
```

### Booleans

Scheme-style boolean literals:

```lisp
#t             ; true
#f             ; false
```

In conditionals, `#f` and `0` are false; everything else is true:

```lisp
(if #t 'yes 'no)   ; yes
(if #f 'yes 'no)   ; no
(if 0 'yes 'no)    ; no
(if 1 'yes 'no)    ; yes
(if '() 'yes 'no)  ; yes (empty list is truthy!)
```

### Symbols

Symbols are names that can be bound to values:

```lisp
'hello         ; The symbol hello
'my-function   ; Symbols can contain hyphens
'+             ; Even operators are symbols
```

### Lists

Lists are the core data structure:

```lisp
'(1 2 3)                    ; A list of numbers
'(a b c)                    ; A list of symbols
'((1 2) (3 4))              ; Nested lists
(list 1 2 3)                ; Build a list from values
(list (+ 1 2) (* 3 4))      ; (3 12) - arguments are evaluated
```

## List Operations

### Building Lists

```lisp
(cons 1 '(2 3))    ; (1 2 3) - prepend element
(cons 'a '())      ; (a) - single element list
(list 1 2 3)       ; (1 2 3) - build from elements
```

### Accessing Lists

```lisp
(car '(1 2 3))     ; 1 - first element
(cdr '(1 2 3))     ; (2 3) - rest of list
(car (cdr '(1 2 3))) ; 2 - second element
```

### Predicates

```lisp
(null? '())        ; #t
(null? '(1 2))     ; #f
(list? '(1 2 3))   ; #t
(list? 42)         ; #f
(number? 42)       ; #t
(number? 'x)       ; #f
(symbol? 'x)       ; #t
(symbol? 42)       ; #f
(boolean? #t)      ; #t
(boolean? 42)      ; #f
```

## Definitions and Binding

### Local Bindings with let

```lisp
(let x 10 x)                    ; 10
(let x 5 (+ x 3))               ; 8
(let a 10 (let b 20 (+ a b)))   ; 30 - nested bindings
```

### Global Definitions with define

```lisp
(define x 42)
(define square (lambda (n) (* n n)))
(square 7)         ; 49
```

## Functions

### Lambda Expressions

Create anonymous functions with `lambda`:

```lisp
(lambda (x) (* x x))           ; A squaring function
((lambda (x) (* x x)) 5)       ; 25 - immediately applied
```

### Defining Named Functions

```lisp
(define double (lambda (x) (* x 2)))
(double 21)        ; 42

(define add (lambda (a) (lambda (b) (+ a b))))
((add 5) 3)        ; 8 - curried function
```

### Closures

Functions capture their environment:

```lisp
(let y 10
  ((lambda (x) (+ x y)) 5))    ; 15 - y is captured

(define make-adder
  (lambda (n)
    (lambda (x) (+ x n))))
(define add5 (make-adder 5))
(add5 10)          ; 15
```

### Recursion

Functions can call themselves:

```lisp
(define factorial
  (lambda (n)
    (if (<= n 1)
        1
        (* n (factorial (- n 1))))))
(factorial 5)      ; 120

(define fibonacci
  (lambda (n)
    (if (<= n 1)
        n
        (+ (fibonacci (- n 1))
           (fibonacci (- n 2))))))
(fibonacci 10)     ; 55
```

## Control Flow

### if

Two-branch conditional:

```lisp
(if (< 1 2) 'less 'greater)    ; less
(if (> 1 2) 'greater 'less)    ; less
```

### cond

Multi-branch conditional:

```lisp
(cond
  ((< x 0) 'negative)
  ((= x 0) 'zero)
  (else 'positive))

(cond
  (#f 'never)
  (#f 'also-never)
  (else 'fallback))            ; fallback
```

Each clause is `(test expr ...)`. The first true test's expressions are
evaluated. `else` always matches.

### begin

Sequence multiple expressions, returning the last:

```lisp
(begin
  (print 'hello)
  (print 'world)
  42)                          ; prints hello, world, returns 42
```

## Comparisons

All comparisons return `#t` or `#f`:

```lisp
(< 1 2)            ; #t
(> 1 2)            ; #f
(<= 5 5)           ; #t
(>= 3 4)           ; #f
(= 7 7)            ; #t
```

## Output

```lisp
(print 'hello)     ; Prints: hello
(print 42)         ; Prints: 42
(print '(1 2 3))   ; Prints: (1 2 3)
```

`print` returns the value it prints, so you can use it inline:

```lisp
(+ 1 (print 2))    ; Prints 2, returns 3
```

## Examples

### List Length

```lisp
(define length
  (lambda (lst)
    (if (null? lst)
        0
        (+ 1 (length (cdr lst))))))
(length '(a b c d e))  ; 5
```

### List Append

```lisp
(define append
  (lambda (lst1 lst2)
    (if (null? lst1)
        lst2
        (cons (car lst1)
              (append (cdr lst1) lst2)))))
(append '(1 2) '(3 4))  ; (1 2 3 4)
```

### List Reverse

```lisp
(define reverse-helper
  (lambda (lst acc)
    (if (null? lst)
        acc
        (reverse-helper (cdr lst)
                        (cons (car lst) acc)))))
(define reverse
  (lambda (lst)
    (reverse-helper lst '())))
(reverse '(1 2 3 4))  ; (4 3 2 1)
```

### Map (apply function to each element)

```lisp
(define map
  (lambda (f lst)
    (if (null? lst)
        '()
        (cons (f (car lst))
              (map f (cdr lst))))))
(define square (lambda (x) (* x x)))
(map square '(1 2 3 4 5))  ; (1 4 9 16 25)
```

### Filter (keep elements matching predicate)

```lisp
(define filter
  (lambda (pred lst)
    (cond
      ((null? lst) '())
      ((pred (car lst))
       (cons (car lst) (filter pred (cdr lst))))
      (else (filter pred (cdr lst))))))
(define even? (lambda (n) (= 0 (- n (* 2 (/ n 2))))))
(filter even? '(1 2 3 4 5 6))  ; (2 4 6)
```

## Quick Reference

### Special Forms

| Form | Description |
|------|-------------|
| `(quote x)` or `'x` | Return x unevaluated |
| `(if test then else)` | Conditional branch |
| `(cond (test expr...)...)` | Multi-way conditional |
| `(let name value body)` | Local binding |
| `(lambda (params) body)` | Anonymous function |
| `(define name value)` | Global definition |
| `(begin expr...)` | Sequence expressions |

### Arithmetic

| Function | Description |
|----------|-------------|
| `(+ ...)` | Addition |
| `(- ...)` | Subtraction |
| `(* ...)` | Multiplication |
| `(/ ...)` | Division |

### Comparisons

| Function | Description |
|----------|-------------|
| `(< a b)` | Less than |
| `(> a b)` | Greater than |
| `(<= a b)` | Less than or equal |
| `(>= a b)` | Greater than or equal |
| `(= a b)` | Equal |

### List Operations

| Function | Description |
|----------|-------------|
| `(cons x lst)` | Prepend x to lst |
| `(car lst)` | First element |
| `(cdr lst)` | Rest of list |
| `(list ...)` | Build list from args |

### Predicates

| Function | Description |
|----------|-------------|
| `(null? x)` | Is x empty list? |
| `(number? x)` | Is x a number? |
| `(symbol? x)` | Is x a symbol? |
| `(list? x)` | Is x a list? |
| `(boolean? x)` | Is x #t or #f? |

### I/O

| Function | Description |
|----------|-------------|
| `(print x)` | Print x and return it |

## Language Heritage

SeqLisp draws inspiration from:

- **Scheme**: Minimal Lisp with clean semantics (`#t`/`#f`, `cond`, `let`)
- **Traditional Lisp**: `car`/`cdr`, `cons`, `quote`

While running on:

- **Seq**: A stack-based concatenative language with static typing

This creates an interesting hybrid: a dynamically-typed Lisp implemented in a
statically-typed stack language. The interpreter itself uses Seq's ADT unions
for type-safe S-expression representation.


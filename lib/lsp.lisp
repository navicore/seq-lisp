; SeqLisp Language Server Protocol Implementation
; Implements LSP lifecycle via JSON-RPC 2.0 over stdin/stdout
;
; Supported methods:
;   initialize, initialized, shutdown, exit

(define (string-starts-with? str prefix)
  (if (< (string-length str) (string-length prefix)) #f
    (equal? (substring str 0 (string-length prefix)) prefix)))

; Note: \r check is for when tokenizer supports \r escape (see issue #38)
; Currently io.read-line+ normalizes CRLF to LF, so \n check suffices
(define (string-blank? str)
  (if (equal? str "") #t
    (if (equal? str "\n") #t
      (if (equal? str "\r") #t
        (equal? str "\r\n")))))

(define (assoc key alist)
  (if (null? alist) (list key '())
    (if (equal? (car (car alist)) key)
      (car alist)
      (assoc key (cdr alist)))))

(define (assoc-val key alist)
  (car (cdr (assoc key alist))))

(define (lsp-read-headers-loop content-length)
  (let line (read-line)
    (if (equal? line #f) -1
      (if (string-blank? line) content-length
        (if (string-starts-with? line "Content-Length:")
          ; Extract Content-Length value: skip "Content-Length: " (16 chars), take remaining minus newline
          (lsp-read-headers-loop (json-parse (substring line 16 (- (string-length line) 17))))
          (lsp-read-headers-loop content-length))))))

(define (lsp-read-headers) (lsp-read-headers-loop 0))

; Read message body of given length
; Accumulates lines until we have enough characters
(define (lsp-read-body-loop remaining acc)
  (if (<= remaining 0)
      acc
      (let line (read-line)
        (if (equal? line #f)
            acc
            (let line-len (string-length line)
              (if (>= line-len remaining)
                  (string-append acc (substring line 0 remaining))
                  (lsp-read-body-loop (- remaining line-len)
                                      (string-append acc line))))))))

(define (lsp-read-body length)
  (lsp-read-body-loop length ""))

(define (lsp-send response)
  (let json-str (json-encode response)
    (let content-length (string-length json-str)
      (let header (string-append "Content-Length: " (json-encode content-length) "\r\n\r\n")
        (display (string-append header json-str))))))

; Send JSON-RPC error response
(define (lsp-send-error id code message)
  (lsp-send
    (list (list "jsonrpc" "2.0")
          (list "id" id)
          (list "error"
            (list (list "code" code)
                  (list "message" message))))))

(define (lsp-dispatch msg)
  (let method (assoc-val 'method msg)
    (let id (assoc-val 'id msg)
      (cond
        ((equal? method "initialize")
         (lsp-send
           (list (list "jsonrpc" "2.0")
                 (list "id" id)
                 (list "result"
                   (list (list "capabilities"
                           (list (list "textDocumentSync" 1)))
                         (list "serverInfo"
                           (list (list "name" "seqlisp-lsp")
                                 (list "version" "0.1.0"))))))))
        ((equal? method "initialized") '())
        ((equal? method "shutdown")
         (lsp-send
           (list (list "jsonrpc" "2.0")
                 (list "id" id)
                 (list "result" '()))))
        ((equal? method "exit") (exit 0))
        (else
          ; For unknown methods: notifications (no id) are ignored, requests get error
          (if (null? id)
              '()
              (lsp-send-error id -32601 "Method not found")))))))

; Check if try result is an error: (error message)
(define (try-error? val)
  (if (list? val)
      (if (null? val) #f
          (equal? (car val) 'error))
      #f))

; Extract value from (ok value)
(define (try-value val)
  (car (cdr val)))

(define (lsp-loop)
  (let cl (lsp-read-headers)
    (if (<= cl 0)
        '()
        (let body (lsp-read-body cl)
          (let parse-result (try (json-parse body))
            (if (try-error? parse-result)
                ; Parse error - send error response and continue
                (begin
                  (lsp-send-error '() -32700 "Parse error")
                  (lsp-loop))
                ; Success - extract value and dispatch
                (let msg (try-value parse-result)
                  (begin
                    (lsp-dispatch msg)
                    (lsp-loop)))))))))

(lsp-loop)

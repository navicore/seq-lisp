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
; Note: This reads one line and extracts 'length' characters.
; Works for compact single-line JSON (typical LSP messages).
; Multi-line or pretty-printed JSON would require buffered reading.
(define (lsp-read-body length)
  (let line (read-line)
    (if (equal? line #f) ""
      (if (>= (string-length line) length)
        (substring line 0 length)
        line))))

(define (lsp-send response)
  (let json-str (json-encode response)
    (let content-length (string-length json-str)
      (let header (string-append "Content-Length: " (json-encode content-length) "\r\n\r\n")
        (display (string-append header json-str))))))

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
        (else '())))))

(define (lsp-loop)
  (let cl (lsp-read-headers)
    (if (<= cl 0)
        '()
        (let body (lsp-read-body cl)
          (let msg (json-parse body)
            (begin
              (lsp-dispatch msg)
              (lsp-loop)))))))

(lsp-loop)

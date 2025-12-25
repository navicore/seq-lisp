; SeqLisp Language Server Protocol Implementation
; Implements LSP lifecycle via JSON-RPC 2.0 over stdin/stdout
;
; Supported methods:
;   initialize, initialized, shutdown, exit
;   textDocument/didOpen, textDocument/didChange (with diagnostics)

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

; ============================================
; Error handling helpers
; ============================================

; Check if try result is an error: (error message)
(define (try-error? val)
  (if (list? val)
      (if (null? val) #f
          (equal? (car val) 'error))
      #f))

; Extract value from (ok value)
(define (try-value val)
  (car (cdr val)))

; Extract error message from (error message)
(define (try-error-message val)
  (if (try-error? val)
      (car (cdr val))
      "Unknown error"))

; ============================================
; LSP I/O
; ============================================

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

; ============================================
; Diagnostics
; ============================================

; Make a position object {line, character}
; Note: LSP uses 0-based line/column numbers
(define (make-position line col)
  (list (list "line" line)
        (list "character" col)))

; Make a range object {start, end}
(define (make-range start-line start-col end-line end-col)
  (list (list "start" (make-position start-line start-col))
        (list "end" (make-position end-line end-col))))

; Make a diagnostic object
; Severity: 1=Error, 2=Warning, 3=Info, 4=Hint
(define (make-diagnostic range severity message)
  (list (list "range" range)
        (list "severity" severity)
        (list "message" message)))

; Publish diagnostics to client
(define (publish-diagnostics uri diagnostics)
  (lsp-send
    (list (list "jsonrpc" "2.0")
          (list "method" "textDocument/publishDiagnostics")
          (list "params"
            (list (list "uri" uri)
                  (list "diagnostics" diagnostics))))))

; Validate document text and return list of diagnostics
; TODO: Add parse/eval builtins to SeqLisp to enable real validation
; For now, just return empty diagnostics (no errors)
(define (validate-document text)
  (list))

; Handle document open - validate and publish diagnostics
(define (handle-did-open params)
  (let text-doc (assoc-val 'textDocument params)
    (let uri (assoc-val 'uri text-doc)
      (let text (assoc-val 'text text-doc)
        (publish-diagnostics uri (validate-document text))))))

; Handle document change - validate and publish diagnostics
; Using full document sync (textDocumentSync: 1)
(define (handle-did-change params)
  (let text-doc (assoc-val 'textDocument params)
    (let uri (assoc-val 'uri text-doc)
      (let changes (assoc-val 'contentChanges params)
        ; With full sync, changes is a list with one element containing the full text
        (if (null? changes)
            '()
            (let change (car changes)
              (let text (assoc-val 'text change)
                (publish-diagnostics uri (validate-document text)))))))))

; ============================================
; LSP Dispatch
; ============================================

(define (lsp-dispatch msg)
  (let method (assoc-val 'method msg)
    (let id (assoc-val 'id msg)
      (let params (assoc-val 'params msg)
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
          ((equal? method "textDocument/didOpen")
           (handle-did-open params))
          ((equal? method "textDocument/didChange")
           (handle-did-change params))
          (else
            ; For unknown methods: notifications (no id) are ignored, requests get error
            (if (null? id)
                '()
                (lsp-send-error id -32601 "Method not found"))))))))

; ============================================
; Main Loop
; ============================================

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

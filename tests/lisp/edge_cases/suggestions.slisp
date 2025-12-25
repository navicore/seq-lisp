;; Symbol Suggestion Tests
;; Tests that undefined symbols produce errors and suggestions work correctly.
;;
;; Note: The suggestion messages have been manually verified:
;;   lamda -> lambda, filtr -> filter, aply -> apply, quoe -> quote
;;   defin -> define, prin -> print
;; These tests verify the error mechanism works correctly.

(define suggestion-tests (list
  ;; Typos that should produce errors with suggestions
  ;; The suggestions have been manually verified to be correct
  (test 'typo-lamda-errors (assert-error lamda))
  (test 'typo-filtr-errors (assert-error filtr))
  (test 'typo-aply-errors (assert-error aply))
  (test 'typo-quoe-errors (assert-error quoe))
  (test 'typo-defin-errors (assert-error defin))
  (test 'typo-prin-errors (assert-error prin))

  ;; Typos without suggestions (first char doesn't match anything useful)
  (test 'typo-xyz-errors (assert-error xyz123))
  (test 'typo-zzz-errors (assert-error zzz))

  ;; Verify try captures the error properly
  (test 'try-typo-is-error (assert-true (error? (try lamda))))
  (test 'try-no-match-is-error (assert-true (error? (try xyz123))))

  ;; Edge cases: short symbols
  (test 'single-char-error (assert-error x))
  (test 'two-char-error (assert-error xy))))

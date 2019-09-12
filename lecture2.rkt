#lang racket
(require
 (rename-in
  redex/reduction-semantics
  [define-language define-universe]))


; Define a new universe
(define-universe U1)

; Defines a judgment that judges whether a thing is a Nat.
(define-judgment-form U1
  #:contract (⊢ any is Nat)

  [------------- "Zero"
   (⊢ z is Nat)]

  [(⊢ z is Nat)
   ------------------ "Add1"
   (⊢ (s any) is Nat)])


(define proof-that-z-Is-Nat
  (derivation
   '(⊢ z is Nat)
   "Zero"
   (list)))

(test-judgment-holds ⊢
 proof-that-z-Is-Nat)

;;

(define-universe U2)

; Defines a judgment that judges whether a thing is an Exp, representing an
; expression in some language.
(define-judgment-form U2
  #:contract (Is-Exp any)

  [---------- "E-Zero"
   (Is-Exp z)]

  [(Is-Exp any)
   --------------- "E-Add1"
   (Is-Exp (s any))]


  [(Is-Exp any_1)
   (Is-Exp any_2)
   ------------------------ "E-Plus"
   (Is-Exp (any_1 + any_2))]

  [------------- "E-True"
   (Is-Exp true)]

  [------------- "E-False"
   (Is-Exp false)]

  [(Is-Exp any_1)
   (Is-Exp any_2)
   (Is-Exp any_3)
   ------------------------------------------ "E-If"
   (Is-Exp (if any_1 then any_2 else any_3))])

(derivation
 '(Is-Exp (s z))
 "E-Add1"
 (list))

(test-judgment-holds
 Is-Exp
 (derivation
  '(Is-Exp (s z))
  "E-Add1"
  (list)))

(test-judgment-holds
 Is-Exp
 (derivation
  '(Is-Exp (s z))
  "E-Add1"
  (list
   (derivation
    '(Is-Exp z)
    "E-Zero"
    (list)))))

(define-judgment-form U2
  #:contract (→ any any)

  [-------------------------------------------- "Step-Add-Add1"
   (→ ((s any_1) + any_2) (any_1 + (s any_2)))]

  [----------------- "Step-Add-Zero"
   (→ (z + any) any)]

  [----------------- "Step-If-True"
   (→ (if true then any_1 else any_2) any_1)]

  [----------------- "Step-If-False"
   (→ (if false then any_1 else any_2) any_2)])

(test-judgment-holds →
 (derivation
  '(→ (if true then z else (s z)) z)
  "Step-If-True"
  (list)))

(test-judgment-holds →
 (derivation
  '(→ (if true then ((s z) + (s z)) else z) ((s z) + (s z)))
  "Step-If-True"
  (list)))

(define-judgment-form U2
  #:contract (->* any any)

  [(→ any_1 any_2)
   ----------------- "Step"
   (->* any_1 any_2)]

  [(→ any_1 any_2)
   (->* any_2 any_3)
   ----------------- "Trans"
   (->* any_1 any_3)]

  ; Stop here: does this make sense?
  ; No! It violates the "something gets smaller" test!
  ; .. doesn't it?
  ; well, maybe not. Intuitively, any_2 is "smaller" in the sense that one step
  ; of reduction has shrunk the number if possible reductions....

  ;
  #;[(-> any_1 any_2)
   (->* any_1 any_2)
   ----------------- "Trans"
   (->* any_1 any_2)]
  )

; First on board
(test-judgment-holds ->*
 (derivation
  '(->* (if true then ((s z) + (s z)) else z) (s (s z)))
  "Trans"
  (list
   (derivation
    '(→ (if true then ((s z) + (s z)) else z) ((s z) + (s z)))
    "Step-If-True"
    (list))
   (derivation
    '(->* ((s z) + (s z)) (s (s z)))
    "Trans"
    (list
     (derivation
      '(→ ((s z) + (s z)) (z + (s (s z))))
      "Step-Add-Add1"
      (list))
     (derivation
      '(->* (z + (s (s z))) (s (s z)))
      "Step"
      (list
       (derivation
        '(→ (z + (s (s z))) (s (s z)))
        "Step-Add-Zero"
        (list)))))))))

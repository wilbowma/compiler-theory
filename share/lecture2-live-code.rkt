#lang racket
(require
 (rename-in
  redex/reduction-semantics
  [define-language define-universe]))

(define-universe U1)

(define-judgment-form U1
  
  #:contract (Is-Bool any)

  [----------- "True"
   (Is-Bool true)]

  [-------- "False"
   (Is-Bool false)])

(test-judgment-holds
 Is-Bool
 (derivation
  '(Is-Bool true)
  "True"
  (list  )))


(define-judgment-form U1
  #:contract (Is-Nat any)

  [---------- "Zero"
   (Is-Nat z)]

  [(Is-Nat any)
   ------- "Add1"
   (Is-Nat (s any))])

(test-judgment-holds
 Is-Nat
 (derivation
  '(Is-Nat z)
  "Zero"
  (list)))
















(define-judgment-form U1
  #:contract (Is-Exp any)

  [(Is-Nat any)
   ------------- "Nat"
   (Is-Exp any)]

  [(Is-Bool any)
   ------------- "Bool"
   (Is-Exp any)]

  [(Is-Exp any_1)
   (Is-Exp any_2)
   --------------- "Add"
   (Is-Exp (any_1 + any_2))]

  [(Is-Exp any_1)
   (Is-Exp any_2)
   (Is-Exp any_3)
   -------------- "If"
   (Is-Exp (if any_1 then any_2 else any_3))])

(test-judgment-holds
 Is-Exp
 (derivation
  '(Is-Exp z)
  "Nat"
  (list
   (derivation
    '(Is-Nat z)
    "Zero"
    (list)))))

(test-judgment-holds
 Is-Exp
 (derivation
  '(Is-Exp (s z))
  "Nat"
  (list
   (derivation
    '(Is-Nat (s z))
    "Add1"
    (list
     (derivation
      '(Is-Nat z)
      "Zero"
      (list)))))))

#;(define-judgment-form U1
  #:contract (reduces any_1 any_2)

  [
   ------------------- "Add-Zero-Zero"
   (reduces (z + z) z)]

  [-------------------- "If-True"
   (reduces (if true then any_1 else any_2) any_1)]

  [----------------- "Plus-Zero"
   (reduces (any + z) any)]

  [--------------- "If-False"
   (reduces (if false then any_1 else any_2) any_2)]

  [-------------- "Add-Add1"
   (reduces (any_2 + (s any_1)) ((s any_2) + any_1))])

#;(test-judgment-holds
 reduces
 (derivation
  '(reduces (z + z) z)
  "Add-Zero-Zero"
  (list)))

(define-universe L1
  [n ::= z (s n)]
  [b ::= true false]
  [l ::= () (cons any l)]
  [e ::= n b l (e_1 + e_2) (if e_1 then e_2 else e_3)])

(redex-match? L1 e (term z))
(redex-match? L1 n (term z))
(redex-match? L1 b 'true)

(redex-match? L1 any 'meow)
(redex-match? L1 (any_1 any_2) (term (meow bark)))

(redex-match? L1 (any_1 any_1) (term (meow bark)))
(redex-match? L1 (any_1 any_1) (term (meow meow)))
(redex-match? L1 (e_1 e_1) (term (z z)))
(redex-match? L1 (e_1 e_2) (term (z (s z))))

(define-judgment-form L1
  #:contract (reduces e_1 e_2)

  [------------------- "Add-Zero-Zero"
   (reduces (z + z) z)]

  [-------------------- "If-True"
   (reduces (if true then any_1 else any_2) any_1)]

  [----------------- "Plus-Zero"
   (reduces (e + z) e)]

  [--------------- "If-False"
   (reduces (if false then e_1 else e_2) e_2)]

  [-------------- "Add-Add1"
   (reduces (any_2 + (s any_1)) ((s any_2) + any_1))])

(define-judgment-form L1
  #:contract (->* e_1 e_2)

  [(reduces e_1 e_2)
   ----------------- "Step"
   (->* e_1 e_2)]

  [------------- "Refl"
   (->* e_1 e_1)]

  [(reduces e_1 e_2)
   (->* e_2 e_3)
   ------------------ "Trans"
   (->* e_1 e_3)]

  [(->* e_1 e_11)
   ------------------- "If-Compat-e1"
   (->* (if e_1 then e_2 else e_3) (if e_11 then e_2 else e_3))]

  [(->* e_2 e_21)
   ------------------- "If-Compat-e2"
   (->* (if e_1 then e_2 else e_3) (if e_1 then e_21 else e_3))]

  [(->* e_3 e_31)
   ------------------- "If-Compat-e3"
   (->* (if e_1 then e_2 else e_3) (if e_1 then e_2 else e_31))]

  [(->* e_1 e_11)
   --------------------- "Plus-Compat-e1"
   (->* (e_1 + e_2) (e_11 + e_2))]

  [(->* e_2 e_21)
   --------------------- "Plus-Compat-e2"
   (->* (e_1 + e_2) (e_1 + e_21))])

(test-judgment-holds
 ->*
 (derivation
  '(->* (z + z) z)
  "Step"
  (list
   (derivation
    '(reduces (z + z) z)
    "Add-Zero-Zero"
    (list)))))

  

  
  

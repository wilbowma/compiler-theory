#lang racket

(require redex/reduction-semantics)

(define-language L
  [b ::= true false]
  [n ::= z (s n)]
  [e ::= b n (e + e) (if e then e else e) (λ x e) (e e) x]
  [x ::= variable-not-otherwise-mentioned]
  #:binding-forms
  (λ x e #:refers-to x))

(default-language L)

; substitute : Expression-to-substitute-in -> Variable to replace -> Expression-to-replace-by

(term (substitute (λ y x) x y))
(term (substitute (λ y x) x true))

(define-judgment-form L
  #:contract (→ e e)
  #:mode (→ I O)

  [-------------- "Step-Add-Zero"
   (→ (z + e) e)]

  [-------------------------------------------- "Step-Add-Add1"
   (→ ((s any_1) + any_2) (any_1 + (s any_2)))]

  [----------------- "Step-If-True"
   (→ (if true then any_1 else any_2) any_1)]

  [----------------- "Step-If-False"
   (→ (if false then any_1 else any_2) any_2)]

  [------------------------------- "Step-App"
   (→ ((λ x e) e_2) (substitute e x e_2))])

(judgment-holds (→ ((λ x x) false) e)
                e)

(judgment-holds (→ ((λ x (if x then false else true)) false) e)
                e)

(judgment-holds (→ ((λ x (λ y x)) y) e)
                e)
; Expect: (λ y y) (if not capture avoiding)
; or    : (λ z y), where z is totally fresh. (if capture avoiding)
   

#lang racket/base

(require redex/reduction-semantics)
(provide (all-defined-out))

(define-language L
  [A B ::= Nat Bool (A -> B)]
  [b ::= true false]
  [n ::= z (s n)]
  ; \lambda
  [e ::= b z (s e) (e + e) (if e then e else e) (λ x e) (λ (x : A) e) (e e) x]
  [o ::= b n]
  [x ::= variable-not-otherwise-mentioned]
  ; \Gamma, \cdot
  [Γ ::= · (Γ x : A)]
  #:binding-forms
  (λ x e #:refers-to x))

(define-judgment-form L
  #:contract (→ e e)

  [-------------- "Step-Add-Zero"
   (→ (z + e) e)]

  [-------------------------------------------- "Step-Add-Add1"
   (→ ((s any_1) + any_2) (any_1 + (s any_2)))]

  [----------------- "Step-If-True"
   (→ (if true then any_1 else any_2) any_1)]

  [----------------- "Step-If-False"
   (→ (if false then any_1 else any_2) any_2)]

  [------------------------------- "Step-App"
   (→ ((λ x e) e_2) (substitute e x e_2))]

  [------------------------------- "Step-AppAnn"
   (→ ((λ (x : A) e) e_2) (substitute e x e_2))])

;; Using modeless, single ->* relation, since it's a little easier to manually
;; write derivations for.
(define-judgment-form L
  #:contract (→* e_1 e_2)

  [------------- "Refl"
   (→* e_1 e_1)]

  [(→* e_1 e_2)
   (→* e_2 e_3)
   ------------------ "Trans"
   (→* e_1 e_3)]

  [(→* e_1 e_2)
   ----------------- "Step"
   (→* e_1 e_2)]

  [(→* e_1 e_11)
   ------------------- "S-Compat"
   (→* (s e_1) (s e_11))]

  [(→* e_1 e_11)
   ------------------- "If-Compat-e1"
   (→* (if e_1 then e_2 else e_3) (if e_11 then e_2 else e_3))]

  [(→* e_2 e_21)
   ------------------- "If-Compat-e2"
   (→* (if e_1 then e_2 else e_3) (if e_1 then e_21 else e_3))]

  [(→* e_3 e_31)
   ------------------- "If-Compat-e3"
   (→* (if e_1 then e_2 else e_3) (if e_1 then e_2 else e_31))]

  [(→* e_1 e_11)
   --------------------- "Plus-Compat-e1"
   (→* (e_1 + e_2) (e_11 + e_2))]

  [(→* e_2 e_21)
   --------------------- "Plus-Compat-e2"
   (→* (e_1 + e_2) (e_1 + e_21))]

  [(→* e_1 e_11)
   --------------------- "Fun-Compat"
   (→* (λ x e_1) (λ x e_11))]

  [(→* e_1 e_11)
   --------------------- "Fun-CompatAnn"
   (→* (λ (x : A) e_1) (λ x e_11))]

  [(→* e_1 e_11)
   --------------------- "App-Compat-e1"
   (→* (e_1 e_2) (e_11 e_2))]

  [(→* e_2 e_21)
   --------------------- "App-Compat-e2"
   (→* (e_1 e_2) (e_1 e_21))])

(define-judgment-form L
  #:contract (eval e o)
  ;#:mode (eval I O)

  [(→* e o)
   ----------
   (eval e o)])

(define-judgment-form L
  #:contract (∈ x A Γ)
  ;#:mode (∈ I O I)


  [---------------------
   (∈ x A (Γ x : A))]

  [(∈ x_1 A Γ)
   ---------------------
   (∈ (name x_1 x_!_1) A (Γ x_!_1 : A))])

(define-judgment-form L
  #:contract (⊢ Γ e : A)


  [(∈ x A Γ)
   ---------- "T-Var"
   (⊢ Γ x : A)]

  [---------- "T-Z"
   (⊢ Γ z : Nat)]


  [(⊢ Γ e : Nat)
   ---------- "T-S"
   (⊢ Γ (s e) : Nat)]


  [------------- "T-True"
   (⊢ Γ true : Bool)]


  [-------------- "T-False"
   (⊢ Γ false : Bool)]


  [(⊢ Γ e_1 : Bool)
   (⊢ Γ e_2 : A)
   (⊢ Γ e_3 : A)
   ---------- "T-If"
   (⊢ Γ (if e_1 then e_2 else e_3) : A)]


  [(⊢ Γ e_1 : Nat)
   (⊢ Γ e_2 : Nat)
   ---------- "T-Add"
   (⊢ Γ (e_1 + e_2) : Nat)]


  [(⊢ (Γ x : A) e : B)
   --------------- "T-λ"
   (⊢ Γ (λ x e) : (A -> B))]


  [(⊢ Γ e_1 : (A -> B))
   (⊢ Γ e_2 : A)
   ---------------
   (⊢ Γ (e_1 e_2) : B)])

;; Derivation (⊢ Γ e : A) -> Derivation (eval e o)
;; Type safety: If a term is well typed, then evaluates to an observation.
;; A proof of this is a program that transforms a typing derivation into an
;; evaluation derivation.
(require racket/match)
(define (type-safety-attempt-1 d)
  ;; By induction on the derivation Γ ⊢ e : A
  (match d
    ; T-Var case
    [(derivation
      `(⊢ ,Γ ,x : ,A)
      "T-Var"
      p)
     ; Must show eval(x) = o
     ; Um. This is impossible...
     (error "Skipped; don't know how to finish this part of the proof")]
    ; T-Var case
    [(derivation
      `(⊢ ,Γ true : Bool)
      "T-True"
      (list))
     ; Must show eval(true) = o)
     ; Pick o to be true, since true is an observation.
     ; Show eval(true) = true.
     ; It is simple to construct such a derivation:
     (derivation
      `(eval true true)
      #f
      (list
       (derivation
        `(→* true true)
        "Refl"
        (list))))]
    [_ (error "Haven't finished that case of the proof")]))

;; Since a theorem is a function, we can call the function to transform a
;; derivation
(test-judgment-holds
 eval
 (type-safety-attempt-1
  (derivation
   `(⊢ · true : Bool)
   "T-True"
   (list))))

;; Okay, the above type safety proof safes, not least because of the variable
;; case.
;; But also, the case for Γ ⊢ (s e) : Nat.
;; So we instead prove progress and preservation.

;; Derivation (⊢ Γ e : A) -> Derivation (e ->* e') -> Derivation (⊢ Γ e' : A)
;; If a term is well typed, and steps to a new term e', e' should have the same type.
;; This means we have two inputs: the derivation for e being well-typed (d1),
;; and the derivation for e stepping to e'.
(define (preservation d1 d2)
  ;; By induction on the derivation Γ ⊢ e : A
  (match d1
    ; Case: T-Var
    [(derivation
      `(⊢ ,Γ ,x : ,A)
      "T-Var"
      p1)
     ; By case analysis on e ->* e'
     ; There is one one sub-case: x ->* x.
     (match d2
       [(derivation
         `(→* ,x ,x)
         "Refl"
         (list))
        d1]
       ; x cannot step in any other way.
       [_ (error "This is impossible")])]
    ; Case: T-Z
    [(derivation
      `(⊢ ,Γ z : Nat)
      "T-Z"
      p1)
     ; By case analysis on e ->* e'
     ; Only one sub-case: z ->* z
     (match d2
       [(derivation
         `(→* z z)
         "Refl"
         (list))
        ; Must prove that Γ ⊢ z : Nat
        ; d1 is such a proof; i.e., we assumed this fact already, so it's
        ; obvious.
        d1]
       ; z cannot step any other way.
       [_ (error "This is impossible")])]
    ; T-S
    [(derivation
      `(⊢ ,Γ (s ,e) : Nat)
      "T-S"
      (list
       (derivation
        `(⊢ ,Γ ,e : Nat)
        l1
        p1)))
     ; By case analysis on e ->* e'
     (match d2
       ; Sub-case:
       ;      e ->* e_1
       ; ---------------- S-Compat
       ; (s e) ->* (s e_1)
       [(derivation
         `(→* (s ,e) (s ,e_1))
         "S-Compat"
         (list
          (derivation
           `(→* ,e ,e_1)
           l2
           p2)))
        ; We must show that
        ; Γ ⊢ (s e_1) : Nat
        (derivation
         `(⊢ ,Γ (s ,e_1) : Nat)
         "T-S"
         ; By T-S, it suffices to show that
         ; Γ ⊢ e_1 : Nat
         (list
          ; This follows by the induction hypothesis, (recursion)
          (preservation
           ;; Applied to the smaller derivation Γ ⊢ e : Nat (copy and pasted from the input above)
           (derivation
            `(⊢ ,Γ ,e : Nat)
            l1
            p1)
           ;; and to the smaller derivation e ->* e_1 (copy and pasted from the input above)
           (derivation
            `(→* ,e ,e_1)
            l2
            p2))))]
       ;; 3 sub-cases of e ->* e' remain
       [_ (error
           'preservation
           (format "Reached an incomplete sub-case: missing case for ~a"
                   (derivation-term d2)))])]
    ;; Many cases of Γ ⊢ e : A remain
    [_ (error
        'preservation
        (format "Reached an incomplete case: missing case for ~a"
                (derivation-term d1)))]))

(preservation
 (derivation
  `(⊢ (· x : Nat) x : Nat)
  "T-Var"
  (list
   (derivation
   `(∈ x Nat (· x : Nat))
   #f
   (list))))
 (derivation
  `(→* x x)
  "Refl"
  (list)))

(preservation
 (derivation
  `(⊢ · z : Nat)
  "T-Z"
  (list))
 (derivation
  `(→* z z)
  "Refl"
  (list)))

;; Why doesn't this one work?
;; Can you make progress on the proof to make it work?
(preservation
 (derivation
  `(⊢ · (s (z + z)) : Nat)
  "T-S"
  (list
   (derivation
    `(⊢ · (z + z) : Nat)
    "T-Add"
    (list
     (derivation
      `(⊢ · z : Nat)
      "T-Z"
      (list))
     (derivation
      `(⊢ · z : Nat)
      "T-Z"
      (list))))))
 (derivation
  `(→* (s (z + z)) (s z))
  "Trans"
  (list
   (derivation
    `(→* (s (z + z)) (s z))
    "S-Compat"
    (list
     (derivation
      `(→* (z + z) z)
      "Step"
      (list
       (derivation
        `(→ (z + z) z)
        "Step-Add-Zero"
        (list))))))
   (derivation
    `(→* (s z) (s z))
    "Refl"
    (list)))))

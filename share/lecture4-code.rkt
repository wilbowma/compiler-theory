#lang racket/base

(require redex/reduction-semantics)
(provide (all-defined-out))

(define-language L
  [A B ::= Nat Bool (A -> B)]
  [b ::= true false]
  [n ::= z (s n)]
  ; \lambda
  [e ::= b n (e + e) (if e then e else e) (λ x e) (λ (x : A) e) (e e) x]
  [o ::= b n]
  [x ::= variable-not-otherwise-mentioned]
  ; \Gamma, \cdot
  [Γ ::= · (Γ x : A)]
  #:binding-forms
  (λ x e #:refers-to x))

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
   (→ ((λ x e) e_2) (substitute e x e_2))]

  [------------------------------- "Step-AppAnn"
   (→ ((λ (x : A) e) e_2) (substitute e x e_2))]
  )

(define-judgment-form L
  #:contract (→+ e_1 e_2)
  #:mode (→+ I O)

  [(→ e_1 e_2)
   ----------------- "Step"
   (→+ e_1 e_2)]

  [(→+ e_1 e_11)
   ------------------- "If-Compat-e1"
   (→+ (if e_1 then e_2 else e_3) (if e_11 then e_2 else e_3))]

  [(→+ e_2 e_21)
   ------------------- "If-Compat-e2"
   (→+ (if e_1 then e_2 else e_3) (if e_1 then e_21 else e_3))]

  [(→+ e_3 e_31)
   ------------------- "If-Compat-e3"
   (→+ (if e_1 then e_2 else e_3) (if e_1 then e_2 else e_31))]

  [(→+ e_1 e_11)
   --------------------- "Plus-Compat-e1"
   (→+ (e_1 + e_2) (e_11 + e_2))]

  [(→+ e_2 e_21)
   --------------------- "Plus-Compat-e2"
   (→+ (e_1 + e_2) (e_1 + e_21))]

  [(→+ e_1 e_11)
   --------------------- "Fun-Compat"
   (→+ (λ x e_1) (λ x e_11))]

  [(→+ e_1 e_11)
   --------------------- "Fun-CompatAnn"
   (→+ (λ (x : A) e_1) (λ x e_11))]

  [(→+ e_1 e_11)
   --------------------- "App-Compat-e1"
   (→+ (e_1 e_2) (e_11 e_2))]

  [(→+ e_2 e_21)
   --------------------- "App-Compat-e2"
   (→+ (e_1 e_2) (e_1 e_21))])

(define-judgment-form L
  #:contract (→* e_1 e_2)
  #:mode (→* I O)

  [------------- "Refl"
   (→* e_1 e_1)]

  [(→+ e_1 e_2)
   (→* e_2 e_3)
   ------------------ "Trans"
   (→* e_1 e_3)])

(define-judgment-form L
  #:contract (eval e o)
  #:mode (eval I O)

  [(→* e o)
   ----------
   (eval e o)])

(define-judgment-form L
  #:contract (∈ x A Γ)
  #:mode (∈ I O I)


  [---------------------
   (∈ x A (Γ x : A))]

  [(∈ x_1 A Γ)
   ---------------------
   (∈ (name x_1 x_!_1) A (Γ x_!_1 : A))])

(define-judgment-form L
  #:contract (⊢spec Γ e : A)


  [(∈ x A Γ)
   ---------- "T-Var"
   (⊢spec Γ x : A)]

  [---------- "T-Z"
   (⊢spec Γ z : Nat)]


  [(⊢spec Γ e : Nat)
   ---------- "T-S"
   (⊢spec Γ (s e) : Nat)]


  [------------- "T-True"
   (⊢spec Γ true : Bool)]


  [-------------- "T-False"
   (⊢spec Γ false : Bool)]


  [(⊢spec Γ e_1 : Bool)
   (⊢spec Γ e_2 : A)
   (⊢spec Γ e_3 : A)
   ---------- "T-If"
   (⊢spec Γ (if e_1 then e_2 else e_3) : A)]


  [(⊢spec Γ e_1 : Nat)
   (⊢spec Γ e_2 : Nat)
   ---------- "T-Add"
   (⊢spec Γ (e_1 + e_2) : Nat)]


  [(⊢spec (Γ x : A) e : B)
   --------------- "T-λ"
   (⊢spec Γ (λ x e) : (A -> B))]


  [(⊢spec Γ e_1 : (A -> B))
   (⊢spec Γ e_2 : A)
   ---------------
   (⊢spec Γ (e_1 e_2) : B)])

(define-judgment-form L
  #:contract (⊢infer Γ e : A)
  #:mode (⊢infer I I I O)


  [(∈ x A Γ)
   ---------- "T-Var"
   (⊢infer Γ x : A)]

  [---------- "T-Z"
   (⊢infer Γ z : Nat)]


  [(⊢infer Γ e : Nat)
   ---------- "T-S"
   (⊢infer Γ (s e) : Nat)]


  [------------- "T-True"
   (⊢infer Γ true : Bool)]


  [-------------- "T-False"
   (⊢infer Γ false : Bool)]


  [(⊢infer Γ e_1 : Bool)
   (⊢infer Γ e_2 : A)
   (⊢infer Γ e_3 : A)
   ---------- "T-If"
   (⊢infer Γ (if e_1 then e_2 else e_3) : A)]


  [(⊢infer Γ e_1 : Nat)
   (⊢infer Γ e_2 : Nat)
   ---------- "T-Add"
   (⊢infer Γ (e_1 + e_2) : Nat)]


  [(⊢infer (Γ x : A) e : B)
   --------------- "T-λ"
   (⊢infer Γ (λ (x : A) e) : (A -> B))]


  [(⊢infer Γ e_1 : (A -> B))
   (⊢infer Γ e_2 : A)
   ---------------
   (⊢infer Γ (e_1 e_2) : B)])

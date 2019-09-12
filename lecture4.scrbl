#lang scribble/manual
@(require
   "lib.rkt"
   racket/sandbox
   scribble/example)

@title[#:tag "" #:tag-prefix "notes:lec4"]{Lecture 4 -- Type Systems}
@margin-note{In lecture, I covered some additional material about modeling
stateful language.
I'm retconning that; that never happened, and I'll cover it
later when it makes more sense.

I also covered type systems and proof by induction concurrently.
I'm going to type set those separately, to make the notes more self-contained.
}

You can find the Redex model for this lecture note in @url{share/lecture4-code.rkt}.

@section{Properties of Programs}
When we defined language, we said a language is:
@itemlist[
@item{A collection of expressions}
@item{Some operations on expressions}
@item{Some shared properties}
]
We now have the ability to model complete languages from a single foundational
mathematical framework, the inductively defined judgment.
We can model their syntax, model rewrites, and model evaluation of whole
programs.
This gives us a way of modeling a collection of expressions and modeling
operations on expressions.
But what properties do our programs share?

So far, not many.
We can reason about individual programs, even write proofs, but we can't make
many @emph{predictions}.
We can't say what will happen without actually trying to run the program.
We can't make claims about @emph{all} programs in the language.

We do have some properties in mind, probably.
We @emph{know}, intuitively, that if you only use booleans in the predicate of
an if expression, then it will successfully evaluate.
We @emph{know} if you only ever add natural numbers, then the program will
evaluate add correctly.
But we haven't @emph{formalized} that intuition in a @emph{judgment}, so we
can't prove it.

The way we foramlize this is with @emph{type systems}.
A type system is a judgment that encodes what it means for a program to be
well behaved, so that we can make formal, provable predictions about allll
well-typed programs.
Let's design a type system.

@section{The Language of NatBool Expressions}
We start simple, with our language of booleans and natural numbers.
In on-paper notation, we define the grammar, reduction judgment, conversion
judgments, and evaluation judgment as follows:
@verbatim{
  e ::= z | s e | true | false | if e then e₁ else e₂ | e₁ + e₂
  v ::= z | s v | true | false

[ e → e]

  ---------------------------- [Step-If-True]
  if true then e₁ else e₂ → e₁


  ---------------------------- [Step-If-False]
  if false then e₁ else e₂ → e₂


  --------- [Step-Add-Z]
  z + e → e


  ------------------------ [Step-Add-S]
  (s e₁) + e₂ → e₁ + (s e₂)

[ e →* e]


  ------ [Conv-Refl]
  e →* e


  e₁ → e₂
  ------ [Conv-Step]
  e₁ →* e₂


  e₁ →* e₂
  e₂ →* e₃
  ------ [Conv-Trans]
  e →* e₃


  e₁ →* e₁'
  e₂ →* e₂'
  e₃ →* e₃'
  ------------------------------------------------- [Conv-If-Cong]
  if e₁ then e₂ else e₃ →* if e₁' then e₂' else e₃'


  e₁ →* e₁'
  ------------- [Conv-S-Cong]
  s e₁ →* s e₁'


  e₁ →* e₁'
  e₂ →* e₂'
  ------------- [Conv-Add-Cong]
  e₁ + e₂ →* e₁' + e₂'

[ eval(e) = v ]

    e →* v
  -----------
  eval(e) = v
}

Note that I've take some liberties with the conversion judgment.
It is not easily implemented as a recursive function, and I've combined all the
congruence rules.
This is pretty standard.
All the congruence rules can be written as a single rule, because the conversion
judgment has a reflexivity rule allow us to ignore any of the premises.
This allows for a shorter judgment, but makes the relationship between rules
non-obvious and important.

This language, as specified, allows us to attempt to evaluate nonsense terms,
such as @tt{(s true)} or @tt{if (true + z) then z else false}.
What we would like to say is that there is some class of well-behaved terms, and
evaluation will never get stuck on those terms.
That class of well-behaved terms is the class of @emph{well-typed terms}, and we
can formalize it by writing down a typing judgment that builds derivations that
prove that reduction will succeeed.
Then, any well-typed term will evaluate to some value.
This property is called @emph{type safety}.

@emph{Theorem (Type Safety):}
If @tt{e is well-typed} then @tt{eval(e) = v}

Since type safety depends on the type system and the evaluation judgment,
actually there are many statements of type safety.
Usually, we also want to allow for non-termination, and raising valid run-time exceptions.
This would give us the more general statement:

@emph{Theorem (Type Safety, General):}
If @tt{e is well-typed} then @tt{eval(e) = o}

In general, our observations @tt{o} will include values, nontermination (written
Ω), and some set of valid run-time exceptions like division by zero
exception.

To make this theorem true, the type system needs to judge terms to be well-typed
only if evaluating them @emph{will succeed}.
We don't need to capture every term (completeness), but we must be correct in
our predictions (soundness).
@margin-note{Because our type system tells us how to build proofs that
evaluation will succeed, the theorem @emph{Type Safety} essentially states "if
we have a proof that evaluation will succeed, then evaluation will in fact
succeed".
For this reason, @emph{Type Safety} is sometimes called @emph{Type Soundness},
alluding to the fact that the type system is a sound proof system with respect
to the evaluation judgment.

You shouldn't use @emph{Type Soundness} unless you're ready to argue with the
philosophically inclined.
}

Note that the language NatBool exists @emph{before} the type system.
We can write down expressions that aren't well typed, and we can even try to
evaluate them.
We build the type system merely for its predictive power.

So enough about why and how we'd like to make predictions.
Let's build a type system.

@section{A Type System for NatBool}
The first thing we need when building a type system is some types.
We can define a new judgment (new syntax) for what is a valid type
For NatBool, we have two types: @tt{Nat} and @tt{Bool}.
The type @tt{Nat} will, intuitively, be assigned to expressions that compute to values that represnet natural numbers.
Similarly, @tt{Bool} will be assigned to expressions that compute to values that represent booleans.

@verbatim{
A ::= Nat | Bool
}

Phew.

To define a type system, we'll need a rule for each expression in our language.
We have 6 expressions, so we expect a judgment with at least 6 rules.

Beyond that, it's not always easy to know where to start.
Introduction and elimination forms can be of help to us again.
We should start with introduction forms, as they usually have obvious types.
For example, @tt{z} is meant to represent the natural number 0, so it ought to
have type @tt{Nat}.
We write this formally as @tt{⊢ z : Nat}.
Other introduction forms, such as @tt{true} and @tt{false}, are similarly obvious.

@verbatim{
[ ⊢ e : A ]

  ---------- [T-Z]
  ⊢ z : Nat


  ------------- [T-True]
  ⊢ true : Bool


  -------------- [T-False]
  ⊢ false : Bool
}

For expressions with sub-expressions, such as @tt{s e}, we have to think a little bit.
The question we must ask our selves is: what must we prove about the
sub-expression @tt{e} to prove that @tt{s e} will evaluate to a value of the
type we want it to be.
Since @tt{s e} is meant to represent a natural number, we want it to be of type @tt{Nat}.
But we would only consider it representing a type @tt{Nat} if @tt{e} is also a
@tt{Nat}; @tt{s true} doesn't represent anything sensible, for example.
We translate this into a formal type rule:

@verbatim{
  ⊢ e : Nat
  ---------- [T-S]
  ⊢ s e : Nat
}

The elimination forms are harder.
Elimination forms don't have an obvious type, but they do eliminate something of
an obvious type.
We can write their type rules by starting inside out.
For plus, @tt{e₁ + e₂}, we know we can only add two expressions that represent
natural numbers, so we know @tt{e₁} and @tt{e₂} must have type @tt{Nat}.

@verbatim{
  ⊢ e₁ : Nat
  ⊢ e₂ : Nat
  ---------- [T-Add]
  ⊢ e₁ + e₂ : ??
}

To figure out what the type of @tt{e₁ + e₂} is, though, we have to think.
We know that we want @tt{+} to behave like addition---it should compute to a
natural number.
So we give it the type @tt{Nat}.

@verbatim{
  ⊢ e₁ : Nat
  ⊢ e₂ : Nat
  ---------- [T-Add]
  ⊢ e₁ + e₂ : Nat
}

We do the same thing for if expressions.
We know that @tt{if} will only succeed when it branches on a boolean:

@verbatim{
  ⊢ e₁ : Bool
  ???
  ---------- [T-If]
  ⊢ if e₁ then e₂ else e₃ ₂ : ???
}

Now, what type will the expression evaluate to?
Well that depends on the boolean.
We know that it will evaluate to the type of the expression in which ever branch
it happens to jump to.
Since we don't know how to write anything as complicated as that, we make a
simplifying assumption.
We assume both branches have the same type, call it @tt{A}.
If both branches have the type @tt{A}, then the if expression will evaluate to
some value of type @tt{A}, as long as @tt{e₁} is a boolean.

@verbatim{
  ⊢ e₁ : Bool
  ⊢ e₂ : A
  ⊢ e₃ : A
  ---------- [T-If]
  ⊢ if e₁ then e₂ else e₃ ₂ : A
}

This gives us the final type system:


@verbatim{
[ ⊢ e : A ]

  ---------- [T-Z]
  ⊢ z : Nat


  ⊢ e : Nat
  ---------- [T-S]
  ⊢ s e : Nat


  ------------- [T-True]
  ⊢ true : Bool


  -------------- [T-False]
  ⊢ false : Bool


  ⊢ e₁ : Bool
  ⊢ e₂ : A
  ⊢ e₃ : A
  ---------- [T-If]
  ⊢ if e₁ then e₂ else e₃ ₂ : A


  ⊢ e₁ : Nat
  ⊢ e₂ : Nat
  ---------- [T-Add]
  ⊢ e₁ + e₂ : Nat
}


Now we can predict (although we haven't proven it) whether evaluation will suceed.
We know @tt{s true} won't evaluate property, and sure enough, it isn't well typed.
If we try to build a derivation, we get stuck:
@verbatim{
      X
  ------------
  ⊢ true : Nat
--------------
⊢ s true : Nat
}

If we prove some other facts about our type system, like that every term has a
unique type, we could @emph{formally} prove that this term @emph{cannot} be well
typed, since @tt{true}'s unique type is @tt{Bool}, which is not equal to
@tt{Nat}.
We're not going there in this class.

We can also formally prove that particular terms will definitely evaluate properly.
For example, @tt{(s z) + (s z)} is well typed at type @tt{Nat}:
@verbatim{

--------- T-Z             --------- T-Z
⊢ z : Nat                 ⊢ z : Nat
------------ T-S         -------------- T-S
⊢ (s z) : Nat            ⊢ (s z) : Nat
-------------------------------------- T-Add
         ⊢ (s z) + (s z) : Nat
}
This means that we predict that @tt{(s z) + (s z)} will evaluate successfully,
and produce a value of type @tt{Nat}.
Sure enough, it evaluates to @tt{(s (s z))} (the representation of 2), which has
type @tt{Nat}:
@verbatim{

--------- T-Z
⊢ z : Nat
------------- T-S
⊢ (s z) : Nat
----------------- T-S
⊢ (s (s z)) : Nat
----------------- T-S
⊢ (s (s z)) : Nat
}

@section{A Type System for λNatBool}
Let's extend our language, and our type system, with functions.

The first thing we need is a new type.
Intuitively, we know that functions take an argument (of some type) and return a
result (of some type).
This means the function's type is going to be non-trivial: it will have
sub-expressions, expressing the argument and result type.
We usually write the function type as an arrow: @tt{A -> A}.
@margin-note{This gets confusing, since we also write reduction as an arrow.
Sorry. PL people are bad at syntax, because they think they're so good at it.}
This gives us a new definition of our meta-variable @tt{A}.
@verbatim{
  A,B ::= Nat | Bool | A -> B
}
I also introduce an alias for the same meta-variable, @tt{B}, for convenience
and readability.
Both @tt{A} and @tt{B} refer to the "is a type" judgment, or (equivalently) the
syntax of types.

If we try to follow our recipe from earlier and start with the typing rule for
function, we get a bit puzzled.
Obviously, a function will have a function type:
@verbatim{
??
---------------
⊢ λx.e : A -> B
}

But to say that this function will evaluate correctly, we must say that the body
@tt{e} has type @tt{B}... assuming that it gets an argument of type @tt{A}.
@verbatim{
⊢ e : B
  if it gets an argument of type A
---------------
⊢ λx.e : A -> B
}

To formalize this assumption, we essentially add some additional information to
our typing judgment.
We keep track of assumptions about variables.
To do this, we define @emph{typing environment}, which is essentially a list of
mappings from variables names to types.
@verbatim{
  Γ ::= · | Γ,x:A
}
@tt{·} represents the empty environment, and @tt{Γ,x:A} is the environment
@tt{Γ} extended with the assumption that @tt{x} has type @tt{A}.
We have to change the entire form of our typing judgment, and every single
typing rule, to thread this environment around:

@verbatim{
[ Γ ⊢ e : A ]

  ---------- [T-Z]
  Γ ⊢ z : Nat


  Γ ⊢ e : Nat
  ---------- [T-S]
  Γ ⊢ s e : Nat


  ------------- [T-True]
  Γ ⊢ true : Bool


  -------------- [T-False]
  Γ ⊢ false : Bool


  Γ ⊢ e₁ : Bool
  Γ ⊢ e₂ : A
  Γ ⊢ e₃ : A
  ---------- [T-If]
  Γ ⊢ if e₁ then e₂ else e₃ ₂ : A


  Γ ⊢ e₁ : Nat
  Γ ⊢ e₂ : Nat
  ---------- [T-Add]
  Γ ⊢ e₁ + e₂ : Nat
}

Now, we can finish the rule for functions.
@verbatim{
  Γ,x:A ⊢ e : B
  ---------------
  Γ ⊢ λx.e : A -> B
}
A function @tt{λx.e} has type @tt{A -> B} if the body @tt{e} will evaluate to
something of type @tt{B} under the assumption that it is given an expression for
the argument @tt{x} that has type @tt{B}.

Following the pattern, we can give the type for application.
Application is an elimination rule, so we know it will be eliminating something
of function type.
@verbatim{
  Γ ⊢ e₁ : A -> B
  Γ ⊢ e₂ : ???
  ---------------
  Γ ⊢ e₁ e₂ : ??
}
Now we have think.
An application should succeed if the argument, @tt{e₂}, is of the same type
@tt{A} that the function expects.
@verbatim{
  Γ ⊢ e₁ : A -> B
  Γ ⊢ e₂ : A
  ---------------
  Γ ⊢ e₁ e₂ : ??
}
We also know that the function application should evaluate to the expression
returned by the function, @emph{i.e.}, to the value of type @tt{B}.
@verbatim{
Γ ⊢ e₁ : A -> B
Γ ⊢ e₂ : A
---------------
Γ ⊢ e₁ e₂ : B
}

Fantastic.
We can now predict the success of function applications.

Finally, we need a rule for names @tt{x}.
Names are always complicated, and the typing rule is no exceptions.
It behaves like neither an introduction nor elimination form.
It's type is not obvious just from its structure, nor is anything eliminating
something whose type is obvious.
Instead, we have to think.
And we think.... we have this convenient list of assumptions about variables, so
let's just look up the type in there.

If we assumed @tt{x} has type @tt{A}, in @tt{Γ}, then @tt{x} should have type
@tt{A} under @tt{Γ}.
This sounds like an obvious statement in English, but it's subtle in math: we're
moving from a formal @emph{expression}, @tt{Γ}, to a typing derivation.
@verbatim{
   x : A ∈ Γ
  ----------
  Γ ⊢ x : A
}

Formally, this requires the we define a new judgment:
@verbatim{
[ x : A ∈ Γ ]

  ---------------
  x : A ∈ (Γ,x:A)

  x₁ : A ∈ Γ
  x₁ != x₂
  ---------------
  x₁ : A ∈ (Γ,x₂:A)
}


This gives us the type system below.
@verbatim{
[ Γ ⊢ e : A ]

  x : A ∈ Γ
  ---------- [T-Var]
  Γ ⊢ x : A


  ---------- [T-Z]
  Γ ⊢ z : Nat


  Γ ⊢ e : Nat
  ---------- [T-S]
  Γ ⊢ s e : Nat


  ------------- [T-True]
  Γ ⊢ true : Bool


  -------------- [T-False]
  Γ ⊢ false : Bool


  Γ ⊢ e₁ : Bool
  Γ ⊢ e₂ : A
  Γ ⊢ e₃ : A
  ---------- [T-If]
  Γ ⊢ if e₁ then e₂ else e₃ ₂ : A


  Γ ⊢ e₁ : Nat
  Γ ⊢ e₂ : Nat
  ---------- [T-Add]
  Γ ⊢ e₁ + e₂ : Nat


  Γ,x:A ⊢ e : B
  ---------------
  Γ ⊢ λx.e : A -> B


  Γ ⊢ e₁ : A -> B
  Γ ⊢ e₂ : A
  ---------------
  Γ ⊢ e₁ e₂ : B
}

@section{Type Systems and Type Annotations}
This type system is a little unusual if you're familiar with typed languages.
Our language has no annotations at all.
We can actually prove that a function multiple types:
@verbatim{
x:Nat ⊢ x : Nat
---------------------
· ⊢ λx.x : Nat -> Nat
}

@verbatim{
x:Bool ⊢ x : Bool
---------------------
· ⊢ λx.x : Bool -> Bool
}

This is fine.
A type system exists regardless of the type annotations, or whether we think of
the language as "typed".
In fact, this is even good from the perspective of code reuse.

However, we have to construct a derivation manually: the syntax of programs is
not sufficient to infer a type.
In general, this means the type system is undecidable: we cannot decide if a
given program is well typed.

We can see this more clearly when we try to translate the judgment into Redex.
The only way to write the judgment is as a modeless judgment.
We cannot assign the type as an output, meaning it can be inferred, because the
argument type for functions would need to come out of thin-air.
This manifests in Redex telling us that that a pattern variable is unbound when
we try to define the judgment.

@(define eg
  (make-base-eval "(require redex/reduction-semantics \"share/lecture4-code.rkt\")"))

@examples[#:eval eg
(eval:error
 (define-judgment-form L
  #:contract (⊢ Γ e : A)
  #:mode (⊢ I I I O)


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
  (⊢ Γ (e_1 e_2) : B)]))
]

This is why usually typed language will require an annotation on the argument
name.
We can add a second syntax for functions that comes annotated with its
arguments.
For these functions, we can easily decide all types.
And we can see that by defining a moded judgment in which the type is an output,
and Redex will happily infer types for us.

@(define eg1
  (make-base-eval "(require redex/reduction-semantics \"share/lecture4-code.rkt\")"))

@examples[#:eval eg1
(define-judgment-form L
  #:contract (⊢ Γ e : A)
  #:mode (⊢ I I I O)


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
   (⊢ Γ (λ (x : A) e) : (A -> B))]


  [(⊢ Γ e_1 : (A -> B))
   (⊢ Γ e_2 : A)
   ---------------
   (⊢ Γ (e_1 e_2) : B)])

(judgment-holds (⊢ · (λ (x : Nat) x) : A) A)
]

Unfortunately, now that we have annotations, our functions are less generic.
We must define separate identity functions for natural numbers and booleans,
even though they behave the same, and work with ill-typed arguments

@examples[#:eval eg1
(judgment-holds (⊢ · (λ (x : Nat) x) : A) A)
(judgment-holds (⊢ · (λ (x : Bool) x) : A) A)

(judgment-holds (⊢ · ((λ (x : Bool) x) z) : A) A)
(judgment-holds (⊢ · ((λ (x : Bool) x) true) : A) A)

(judgment-holds (eval ((λ (x : Bool) x) true) o) o)
(judgment-holds (eval ((λ (x : Bool) x) z) o) o)

(judgment-holds (eval ((λ (x : Nat) x) true) o) o)
(judgment-holds (eval ((λ (x : Nat) x) z) o) o)
]

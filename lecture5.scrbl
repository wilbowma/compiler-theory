#lang scribble/manual
@(require
  "lib.rkt"
  racket/sandbox
  scribble/example)

@(define (theorem . rest)
   (apply list (emph "Theorem:") rest))
@(define (proof . rest)
   (apply list (emph "Proof:") rest))

@title[#:tag "" #:tag-prefix "notes:lec5"]{Lecture 5 and 6 -- Proof by
Induction}
In @secref[#:tag-prefixes '("notes:lec4") ""] we learend about type systems.
The point of a type system is to make predictions.
But we don't just want to make predictions about a single term, like @tt{z}.
We want to make predictions about whole classes of terms, like all terms of type
@tt{Nat}, or any well typed term.

A prediction is a theorem, so we need to write a proof to be sure our prediction
is true.
So far, we've seen one proof technique: build a derivation.
This essentially corresponds proof by Implication.
Judgments express implication: if @emph{A} then @emph{B}.
To show @emph{B}, I build a derivation @emph{B}, by build a derivation of
@emph{A}, and appling some rule.

Unfortunately, we can only build derivations when we have @emph{concrete},
@emph{particular} terms.
Rules refer to particular terms, like @tt{z}, or @tt{true}, or @tt{(s e)}.
How do we prove a theorem about an @emph{arbitrary} term @emph{e}?
There is no known structure to @emph{e}, so we can't immediately build a
derivation.

For this, we need Induction, our second axiom:

If I have an inductively defined judgement, @emph{J}, with rules
@emph{R@sub{0}},@emph{R@sub{1}},...,@emph{R@sub{N}}, and I want prove some
property @emph{P} holds for all derivations of @emph{J}, then it suffices to
prove:
@itemlist[#:style 'numbered
@item{If @emph{P} holds on the recursive subderivations of R@sub{0}, then
@emph{P} holds for derivations beginning with R@sub{0}}
@item{If @emph{P} holds on the recursive subderivations of R@sub{1}, then
@emph{P} holds for derivations beginning with R@sub{1}} @item{...}
@item{If @emph{P} holds on the recursive subderivations of R@sub{N}, then
@emph{P} holds for derivations beginning with R@sub{N}}
]

This is an axiom, not a provable fact.
This is an assertion by mathematicians that if we do this, then we use this
proof technique, then we can believe the proof.
We can't prove this axiom is reasonable; we trust that it is reasonable.
It's counter-intuitive, since it allows us to assume the very thing we're trying
to prove (albeit, assume it in a "smaller" way).
But so far, no proofs by induction have been at the root of an proof of an
untrue theorem, so it seems okay to use.

A good rule of thumb is that any time we have a theorem with some meta-varaible
with no additional structure, like @emph{e}, we need induction.
This isn't always true.
We may be able to appeal to previously proved lemmas that will let us build
generic derivations.
Sometimes, our judgments will happen to let us build derivations even when we
have no structure.
But it's a good rule of thumb if you're not sure where to start.

@section{Some Facts About Natural Numbers}
Let's warm up to induction by proving some things about natural numbers.
Natural numbers are an inductively defined judgment, given below (as a syntax):

@verbatim{
n, m ::= z | (s n) | n + m
}

Or below, as a judgment:

@verbatim{
[ z : Nat ]

------- [Z-Nat]
z : Nat


n : Nat
--------- [S-Nat]
s n : Nat


n : Nat
m : Nat
----------- [S-Plus]
n + m : Nat
}

We also define a simple reduction judgment and evaluation judgment:


@verbatim{
[ m -> m ]

---------- [Step-Plus-Z]
z + m -> m


---------------------- [Step-Plus-S]
(s n) + m -> n + (s m)
}

@verbatim{
[ eval(m) = n ]

 m ->* n
----------
eval(m) = n
}

I leave the conversion judgment undefined, but it's the obvious reflexive,
transitive, compatible closure of the reduction judgment.

We'll start simple:

@theorem{(For all m,) @tt{eval(0 + @emph{m})} = @emph{m}}

This theorem says that evaluating 0 plus any @emph{m} equal @emph{m}.
Often, we would leave out of the explicit quantification over all possible
@emph{m} in the theorem statement.
I've written it explicitly in parenthesis to suggest this quantification is
"obvious" (to a working PL theorist) from context.

The theorem is probably intuitively true to anyone reading it.
And of course, it is true.
But true is not the same as being proven, so lets see if we can prove it.

@theorem{(For all m,) @tt{eval(0 + @emph{m})} = @emph{m}}
@proof{Trivial, by the following derivation

@verbatim{
 ------------ [Step-Plus-Z]
 (0 + m) -> m
 ------------ [Step]
 0 + m ->* m
---------------
eval(0 + m) = m
}
}


Huh. That proof worked without any kind of induction even those it had a for all
quantification.

But this was an accident of our reduction judgment.
It just so happens that the @tt{[Step-Plus-Z]} rule works for any m, as long as
the left hand side is 0.
If we try to do the proof that @tt{eval(@emph{m} + 0) = @emph{m}}, it would be
so easy:

@theorem{(For all m,) @tt{eval(@emph{m} + 0)} = @emph{m}}
@proof{ ... erm, there is no reduction rule to apply, so we can't (immediately)
build a derivation.

The proof proceeds by induction on the structure of @emph{m} (by induction on
the derivation that @tt{m : Nat}).
@itemlist[
@item{@emph{Case}:
Suppose that @tt{m : Nat} is the derivation
@verbatim{
------- [Z-Nat]
z : Nat
}

We must show that
@tt{eval(z + z) = z}.
This is trivial, since @tt{z + z -> z}.
}
@item{@emph{Case}:
Suppose that @tt{m : Nat} is the derivation
@verbatim{
n : Nat
------- [S-Nat]
s n : Nat
}

We must show that @tt{eval((s n) + 0) = s n}.

By the induction hypothesis applied to the sub-derivation @tt{n : Nat} that
@tt{eval(n + 0) = n}.

Note that we can easily show that @tt{(s n) + 0 -> n + (s 0)}
But we can't seem to combine this with anything.
By deconstructing the derivation we get from the induction hypothesis, we know

@verbatim{
n + 0 ->* n
---------------
eval(n + 0) = n
}


But it's not clear how to combibe that fact with something of the shape
@tt{(s n) + 0 ->* n + (s 0)} to build any derivation.
So how do we proceed?
}
]
}

In general, when stuck in a proof, we have two options: change our theorem,
or change our model.
We could try to separate that @tt{n + (s 0) ->* s n}, and that might work.
It certainly ought to be true.
But actually, we can more easily complete the proof by changing our reduction
rule to something equivalent, but simpler to prove things about.

This is a pretty common trick in programming languages work.
If you see a judgment that seems correct, but different than the obvious thing,
you should ask yourself if this judgment is easier to use in proofs.

We change the reduction judgment to the following

@verbatim{
[ m -> m ]

---------- [Step-Plus-Z]
z + m -> m


---------------------- [Step-Plus-S]
(s n) + m -> s (n + m)
}

Note that now addition reduces to an addition where both sub-expressions are
inductively smaller.
This is a good sign that it will work better in inductive proofs.
@theorem{(For all m,) @tt{eval(@emph{m} + 0)} = @emph{m}}
@proof{ ... erm, there is no reduction rule to apply, so we can't (immediately)
build a derivation.

The proof proceeds by induction on the structure of @emph{m} (by induction on
the derivation that @tt{m : Nat}).

@itemlist[
@item{@emph{Case}:
Suppose that @tt{m : Nat} is the derivation
@verbatim{
n : Nat
------- [S-Nat]
s n : Nat
}

We must show that @tt{eval((s n) + 0) = s n}.

By the induction hypothesis applied to the sub-derivation @tt{n : Nat} that
@tt{eval(n + 0) = n}.
Recall that we are allowed to assume the very theorem we're trying to prove, but
only for sub-derivations of the thing we're doing induction on.
Here, we're doing induction on @tt{m : Nat}, and we are in the case where
@emph{m} is @tt{s n}, so we are allowed to assume the theorem holds for
@tt{n : Nat}.
This is the tricky part of an inductive proof.

Note that we can easily show that @tt{(s n) + 0 -> s (n + 0)}

Note we can now easily combine this with the fact we get from the induction
hypothesis.

We know that @tt{n + 0 ->* n}, since

@verbatim{
n + 0 ->* n
---------------
eval(n + 0) = n
}

Recall the compatibility rule for @tt{s}:
@verbatim{
  n ->* n'
----------- [S-Compat]
s n ->* s n'
}

So we know that @tt{s (n + 0) ->* s n}.
We have now shown:
@verbatim{
    (s n) + 0
->* s (n + 0)
->* s n
}
Which means @tt{eval((s n) + 0) = s n}
}
]
}

@section{An inductive proof is a recursive function over derivations}
It's sometimes mysterious to see an on-paper proof.
What tells us that the series of words I just wrote constitutes a proof?
What @emph{is} a proof?
How do I understand a proof that assumes the very thing it is proving?
What @emph{is} an induction hypothesis?

These are all questions I've had too.
I didn't really understand proofs until I understood that proofs @emph{are}
programs.
A theorem is a function: is has inputs (its premises) and produces outputs (its
conclusion).
An inductive proof is a recursive function: it pattern matches on its input,
deconstructing a derivation, builds a new derivation, and occassionally recurs
on a sub-derivation.

Understanding that proofs are programs is useful sometimes.
It's actually useful, sometimes, to structure a proof as loop with an
accumulator.
I've done this in one paper.
It's hard to think about that until you understand proofs as programs.

We don't need any fancy proof assistant to see this.
We can write recursive functions in any language.
I'll choose Racket since Redex provides derivations that Racket understands.

Below, I give a model of the natural numbers in Redex.
I use the judgment style for defining them.
I redefine @tt{n} and @tt{m} to be aliases for @tt{any}, to make the judgments
more readable.

@(define eg
  (make-base-eval "(require redex/reduction-semantics)"))

@examples[#:eval eg
(define-language U
  [n m ::= any])

(define-judgment-form U
  #:contract (⊢ n : Nat)

  [----------- "Z"
   (⊢ z : Nat)]

  [(⊢ n : Nat)
   --------------- "S"
   (⊢ (s n) : Nat)]

  [(⊢ any_1 : Nat)
   (⊢ any_2 : Nat)
   ----------------------- "Add"
   (⊢ (any_1 + any_2) : Nat)])

(define-judgment-form U
  #:contract (-> n n)

  [--------------- "Step-Add-Z"
   (-> (z + n) n)]

  [-------------------------- "Step-Add-S"
   (-> ((s n) + m) (s (n + m)))])

(define-judgment-form U
  #:contract (->* n n)

  [---------- "Refl"
   (->* n n)]

  [(-> n_1 n_2)
   ---------- "Step"
   (->* n_1 n_2)]

  [(->* n_1 n_2)
   (->* n_2 n_3)
   ---------- "Trans"
   (->* n_1 n_3)]

  [(->* n_1 n_11)
   (->* n_2 n_21)
   --------------- "Add-Compat"
   (->* (n_1 + n_2) (n_11 + n_21))]

  [(->* n_1 n_2)
   --------------- "S-Compat"
   (->* (s n_1) (s n_2))])

(define-judgment-form U
  [(->* n m)
   -----------
   (eval n m)])
]

We've seen how to do simple proofs in Redex: building a derivation @emph{is} a
proof.
(Note Redex normally won't accept a derivation with a meta-variable in it; this
only works because the symbol @tt{'n} matches @tt{any}.
I'm relying on a pun in my code and this is not always wise.)
@examples[#:eval eg
(test-judgment-holds
 eval
 (derivation
  `(eval (z + n) n)
  #f
  (list
   (derivation
    `(->* (z + n) n)
    "Step"
    (list
     (derivation `(-> (z + n) n) "Step-Add-Z" (list)))))))
]

But we can also do inductive proofs.
This requires us to understand a little bit about Racket: we need to know how to
pattern match on derivations, which involves using the pattern language.
(Note that Racket allows unusual characters in names, so we can use function
names like @racket{n+0-equals-n}.)
@examples[#:eval eg
(require racket/match)
(code:comment "Derivation (⊢ n : Nat) -> Derivation (eval (n + 0) n)")
(code:comment "Requires a derivation that n is a natural number, returns a derivation that n + 0 evaluates to n.")
(define (n+0-equals-n_incomplete d)
  (code:comment "Pattern match on the derivation d")
  (match d
    (code:comment "Case: the derivation begins:")
    (code:comment "")
    (code:comment "--------- \"Z\"")
    (code:comment "⊢ z : Nat")
    [(derivation `(⊢ z : Nat) "Z" (list))
     (code:comment "We must show that eval (0 + 0) = 0")
     (code:comment "Construct the derivation as follows:")
     (derivation
      `(eval (z + z) z)
      #f
      (list
       (derivation
        `(->* (z + z) z)
        "Step"
        (list
         (derivation `(-> (z + z) z) "Step-Add-Z" (list))))))]
    [_ (error "Incomplete proof")]))
]

So far, the proof is incomplete.
That's okay; we can run it as long as we don't reach the incomplete case:
@examples[#:eval eg
(n+0-equals-n_incomplete
 (derivation `(⊢ z : Nat) "Z" (list)))
]

The proof transforms one derivation, that @tt{z} is a natural number, into
another, that @tt{eval (z + z) = z}.

@examples[#:eval eg
(code:comment "Derivation (⊢ n : Nat) -> Derivation (eval (n + 0) n)")
(code:comment "Requires a derivation that n is a natural number, returns a derivation that n + 0 evaluates to n.")
(define (n+0-equals-n d)
  (code:comment "Pattern match on the derivation d")
  (match d
    [(derivation `(⊢ z : Nat) "Z" (list))
     (code:comment "In the z case, reuse our earlier proof that this works for z")
     (n+0-equals-n_incomplete d)]
    [(derivation `(⊢ (s ,n) : Nat) "S" (list sub-derivation))
     (code:comment "Case: the derivation begins:")
     (code:comment "  ⊢ n : Nat")
     (code:comment "  --------- \"S\"")
     (code:comment "  ⊢ (s n) : Nat")
     (derivation
      `(eval ((s ,n) + z) (s ,n))
      #f
      (list
       (derivation
        `(->* ((s ,n) + z) (s ,n))
        "Trans"
        (list
         (derivation
          `(->* ((s ,n) + z) (s (,n + z)))
          "Step"
          (list
           (derivation `(-> ((s ,n) + z) (s (,n + z))) "Step-Add-S" (list))))
         (derivation
          `(->* (s (,n + z)) (s ,n))
          "S-Compat"
          (code:comment "Requires a proof that (n + z) ->* n")
          (code:comment "This follows by the induction hypothesis applied to n, since (eval")
          (code:comment "(n + z) = n) implies (n + z) ->* n")
          (list
           (code:comment "Appealing to the induction hypothesis is recursion.")
           (code:comment "We then destruct the derivation we get from recursion.")
           (match (n+0-equals-n sub-derivation)
             [(derivation `(eval (,n + z) ,n) #f (list d2))
              d2])))))))]
    [(derivation `(⊢ (,n + ,m) : Nat) "Plus" (list sub-derivation-n sub-derivation-m))
     (code:comment "Case: the derivation begins:")
     (code:comment "  ⊢ n : Nat")
     (code:comment "  ⊢ m : Nat")
     (code:comment "  --------- \"Plus\"")
     (code:comment "  ⊢ n + m : Nat")
     (error "This theorem isn't true so we can't complete this case.")]))
]

In the second case of this proof, we know that the list of premises contains one
sub-derivation, which we name so we can use it later.
We use the "unquote" pattern, @racket[,n], to bind whatever expression the
@tt{s} is applied to.
This is part of Racket's pattern language; we know there is some term there, but
we don't know what.
Since it's a quasiquoted list, we need to use comma to tell Racket to treat that
as a pattern variable instead of a symbol.

Then we proceed to build a derivation that @tt{eval ((s n) + z) = (s n)}.
Most of this is standard, building derivations by hand, appealing to rules, and
building derivations for premises.

But, eventually we get to a point where we can't apply any rule directly.
We need to prove that @tt{(n + z) ->* n}, and there is no rule we can apply,
since we don't know anything about @tt{n}.
Thankfully, we can gleam this fact from induction!
We recursively call the function on the sub-derivation that @tt{n} is a natural
number.
We get back a derivation about @tt{eval}, so we destruct it.
We could have written the code more cleanly by using a helper function,
@emph{i.e.}, a lemma.

@examples[#:eval eg
(n+0-equals-n
 (derivation `(⊢ z : Nat) "Z" (list)))
(n+0-equals-n
 (derivation
  `(⊢ (s z) : Nat)
  "S"
  (list
   (derivation `(⊢ z : Nat) "Z" (list)))))
]

Unfortunately, when we try to finish the proof case for
@tt{n + m}, we discover that our theorem isn't general enough.
I leave it as an exercise to the read to discover the fix.
(Hint: evaluation and equality are different, but similar, judgments.)

Formally, a proof can't just be any function, though.
It must be a complete, bug free function.
It must always return something of the right type, handle all cases of any data
it consumes, and always terminate.
It's hard to trust a proof written in Racket since Racket can't check any of
these things, but it's easier to get started writing such a proof.
This is why many proof assistants aren't Turing-complete; it's very useful to
avoid the halting problem when one wants to check that a function terminates by
making it impossible to write an infinite loop.

But, thinking of proofs as functions can be helpful.

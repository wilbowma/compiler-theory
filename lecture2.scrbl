#lang scribble/manual
@(require
   "lib.rkt"
   scribble/example)

@title[#:tag "" #:tag-prefix "notes:lec2"]{Lecture 2 -- Modeling a Language, Continued}

@section{A little review}
Last lecture (@secref[#:tag-prefixes (list "notes:lec1") ""]), we introduced two Axioms and a small formal
system from which we can rebuild the universe, and formally defined a collection
of expressions for a language.
The Axioms are implication and induction, and we use judgments to define new
mathematical theories from these two axioms.

Using this formal system, we defined judgments that represent simple data
types, like the natural numbers and booleans.
We can define lots of data types this way.
In class, we saw how to define another common data type: lists.
Intuitively, a list is either empty, or contains some elements.

Something like this:
@box{@emph{any} is List}
@verbatim{
------- [Empty]
() is List

--------[1-Element]
(any_1) is List


--------[2-Element]
(any_1 any_2) is List

--------[3-Element]
(any_1 any_2 any_3) is List

...
}

But this doesn't work in our formal system.
Instead, we use the Axiom of induction to build up unbounded things.
Using induction, we define the @tt{is List} judgment below.
@box{@emph{any} is List}
@verbatim{
------- [Empty]
() is List

@emph{any@sub{2}} is List
-------- [Cons]
(cons @emph{any@sub{1}} @emph{any@sub{2}}) is List
}

This is essentially similar to how we define the natural numbers.

@section{Making Formal Judgments Really Formal}
While writing funny symbols on a board, or on paper, certainly seems like formal
mathematics, how do we know what we've written actually make sense?
There are several ways we can reassure ourselves.
@itemlist[
@item{Trust Me---I'm a professor}
@item{Learn some well-established mathematical theory that a large number of
mathematicians have agreed is a good theory for a long time, such as set theory,
and prove that your new formalism is sound with respect to that theory.
Since mathematicians have been unable to break the original theory, and your
theory is sound, probably your theory is formal system.}
]

Obviously, each of these options is a bad plan.
You shouldn't trust me because even professors make mistakes.
And learning set theory will take too long---we're trying to learn about
compilers.
Thankfully, there's a third option:
@itemlist[
@item{Run it on a computer}
]
If a computer can take your theory and do things with it, it probably makes some
amount of sense.

Thankfully, there exists a programming language that has essentially the same
underlying Axioms as this class.
We can use PLT Redex to write judgments, build derivations, and check derivations.
This can be very useful for experimenting with judgments---checking that the
definition formally means what you think it means intuitively, checking for
typos, checking that a derivation is a valid formal proof of some judgment.

To use Redex, make sure you have Racket installed, then install Redex on the
command line using @tt{raco pkg install redex}.

We can translate all our judgments into Redex.
We'll start with the @tt{is Bool} judgment
To start, we require @code{redex/reduction-semantics}.
@(define eg (make-base-eval)))
@examples[#:eval eg
(require
  redex/reduction-semantics
  (only-in redex/reduction-semantics (define-language define-universe)))
]
I also import the @racket[define-language] with the alias
@racket[define-universe].
Redex requires each judgment be defined in what is calls a language, but what I
call a universe in this class.

To get started, we need to define a new universe, @racket[U1].
@examples[#:eval eg
(define-universe U1)
]
Now we can define judgment in the universe @racket[U1].

We start by translating the @tt{any : Bool} judgment into Redex.
We do this in Redex using @racket[define-judgment-form], which expects a
universe name, optionally a declaration of the shape of the judgment (which
Redex calls a @racket[#:contract]), and a sequence of rules defining the
judgment.
@examples[#:eval eg
(define-judgment-form U1
  #:contract (Is-Bool any_1)

  [---------- "True"
   (Is-Bool true)]

  [---------- "False"
   (Is-Bool false)])
]
Redex understand the meta-variable @racket[any] in the same way we introduced it
in class.
The Redex pattern matcher will match any Racket @racket[symbol?] in a placed
declared to be @racket[any].
You can call the Redex pattern matcher directly to test your own understanding
of meta-variables:
@examples[#:eval eg
(redex-match? U1 any (term true))
(redex-match? U1 any 'false)
(redex-match? U1 (any_1 any_2) (term (true false)))
(redex-match? U1 (any_1 any_1) (term (true false)))
(redex-match? U1 (any_1 any_1) '(true true))
]
The function @racket[redex-match?] takes a universe, a pattern, and a Redex term
represented as an s-expression.
You can build Redex terms using Racket lists, or the Redex constructor
@racket[term].

Once we have a judgment, we can build derivations.
Derivations are a kind of data structure.
On paper, we write the following derivation to prove that @tt{true} is judged to
be @tt{is Bool}.
@verbatim{
-------- [True]
true is Bool
}

We can translate this into Redex as:
@examples[#:eval eg
(derivation
  '(Is-Bool true)
  "True"
  (list))
]
A derivation begins with the @racket[derivation] constructor, and expects three
arguments: a representation of the judgment we wish to conclude as a @racket[list],
a rule name from which this conclusion follows, and a list of
premises required by that rule.
This derivation is simple since it follows by the rule @racket["True"], which
takes no premises.

We can also ask Redex whether the derivation is in fact a proof of the judgment
@racket[Is-Bool].
@examples[#:eval eg
(test-judgment-holds Is-Bool
  (derivation
    '(Is-Bool true)
    "True"
    (list)))
]
We use @racket[test-judgment-holds], which expects a judgment name and a
derivation.
The test will silently succeed if the derivation is valid, and raise an error if
it is not valid.

Redex also understand inductive judgments.
We can translate the @tt{any : Nat} judgment into Redex as follows.
@examples[#:eval eg
(define-judgment-form U1
  #:contract (Is-Nat any)

  [----------- "Zero"
   (Is-Nat z)]

  [(Is-Nat any)
   ---------- "Add1"
   (Is-Nat (s any))])
]

And we can prove that @racket[(s z)] @racket[Is-Nat].
@examples[#:eval eg
(test-judgment-holds Is-Nat
  (derivation
    '(Is-Nat (s z))
    "Add1"
    (list
      (derivation
        '(Is-Nat z)
        "Zero"
        (list)))))
]
This derivation requires a sub-derivation to prove that the premise to the rule
@racket["Add1"] holds.

Finally, we can translate our simple language of boolean and natural number
expressions.
@examples[#:eval eg
(define-judgment-form U1
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
]

Now, we can formally prove that @racket[(s z)] @racket[Is-Exp], and have the
computer check our work.
@examples[#:eval eg
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
]

@section{BNF Grammars -- A short-hand for simple judgments}
Anyone familiar with compilers or programming languages may have seen an
alternative method of describing syntax before---BNF grammars.
BNF grammars are a much more terse description of a syntax, and most well-formed
grammars ARE judgments, in a more economical notation.

We could easily have defined all of the above judgments as the following
grammars.
@racketgrammar*[
  [b ::= true | false]
  [n ::= z | (s n)]
  [l ::= () | (cons any l)]
  [e ::= n | b | (e_1 + e_2) | (if e_1 then e_2 else e_3)]
]
Using a BNF grammar, we define a new meta-variable.
In the definition, self-references to the meta-variable stand in for inductive
references to the judgment.

Redex also understands grammars.
We could define a universe with these grammars by passing the grammar as an
optional argument to @racket[define-universe]:
@examples[#:eval eg
(define-universe U2
  [b ::= true false]
  [n ::= z (s n)]
  [l ::= () (cons any l)]
  [e ::= n b (e_1 + e_2) (if e_1 then e_2 else e_3)])
]
Redex does not expect a pipe character between expressions, but otherwise the
notation is essentially the same.

Once we define a grammar, the Redex pattern matcher will understand the new
meta-variables defined by the grammar.
@examples[#:eval eg
(redex-match? U2 b 'true)
(redex-match? U2 n 'z)
(redex-match? U2 n '(s z))
(redex-match? U2 e '(s z))
(redex-match? U2 (e_1 e_2) '((s z) true))
]

@section{Modeling Operatings on Expressions}
Until now, we have only brought things into existance in our universe.
We declare that the symbols @racket[true] and @racket[z] and @racket[if] exist
in our universe, and are "Expressions", whatever that means.
But they have no meaning at all.
They are merely symbols that satsify some formal judgment.
To give them meaning, we need to define operations on expressions---judgments
that relate the expressions to other expressions.

The most common operation we want to define expressions in a language is
evaluation.
We want to know what an expression computes---what value it will return, what
string it will print, or what meme it will display when browsing Twitter.

In programming languages, it's common to start defining evaluation by defining
one step of reduction.
The reduction judgment, commonly written with a single right arrow @racket[→],
defines a single step of reduction.
What happens when an expression that eliminates a value has a value to
eliminate.
We can define this on paper as the following judgment.

@box{@emph{e@sub{1}} → @emph{e@sub{2}}}
@verbatim{

------------ "Step-If-True"
(if true then e_1 else e_2) → e_1

------------ "Step-If-False"
(if false then e_1 else e_2) → e_2

------------- "Step-Add-Zero"
(z + e) → e)

------------- "Step-Add-Zero"
((s e_1) + e_2) → (e_1 + (s e_2))
}
This judgment defines how to reduce simple expressions.
@tt{(z + @emph{e})} can step to just @tt{@emph{e}}, representing the fact that zero
plus anything expression should just reduce to the expression.
When we have @tt{(if true then @emph{e@sub{1}} else @emph{e@sub{2}})}, this should just reduce to
the true branch, @tt{@emph{e@sub{1}}}.

By defining this judgment, we begin to give meaning to expressions.
Earlier, we define @tt{true} to be a @tt{Bool}, but it had no
interpretation.
We could not reasonably think of it as representing anything at all.
However, by declaring that @tt{(if true then @emph{e@sub{1}} else
@emph{e@sub{2}})} steps to @tt{@emph{e@sub{1}}}, we declare that @tt{true}
formally represents our intuition for "something that is true".
Similarly, by relating the expressions @tt{(z + @emph{e})} and @tt{@emph{e}}, we
declare that @tt{z} behaves like the natural number 0 if we consider
@tt{+} to be the mathematical addition function on natural numbers.

We have now rebuilt enough of the universe that we can formally prove some
interesting mathematical facts.
For example, we can formally zero plus one is equal to
one.
First, we must interpret @tt{@emph{e@sub{1}} → @emph{e@sub{2}}} as meaning
@tt{@emph{e@sub{1}}} is equal to @tt{@emph{e@sub{2}}}}.
Then we interpret @tt{z} as 0, and @tt{+} as addition, and @tt{(s z)} as one.
Now we construct the derivation.
@verbatim{
------------ "Step-Add-Zero"
(z + (s z)) → (s z)
}

Note that to interpret this as a proof of things we understand intuitively, like
0 and addition, we must assume an interpretation of the symbols we wrote down.
This is fine as long as our interpretation is consisistent.

We can translate this judgment and proof into Redex as follows.
@examples[#:eval eg
(define-judgment-form U2
  #:contract (→ e e)

  [----------------- "Step-If-True"
   (→ (if true then e_1 else e_2) e_1)]

  [----------------- "Step-If-False"
   (→ (if false then e_1 else e_2) e_2)]

  [-------------- "Step-Add-Zero"
   (→ (z + e) e)]

  [------------------------------------ "Step-Add-Add1"
   (→ ((s e_1) + e_2) (e_1 + (s e_2)))])

(test-judgment-holds →
  (derivation
    '(→ (z + (s z)) (s z))
    "Step-Add-Zero"
    (list)))
]

We can prove other simple facts, like that the expression @racket[if] when given
the boolean @racket[true] will step to its first branch.
@examples[#:eval eg
(test-judgment-holds →
 (derivation
  '(→ (if true then z else (s z)) z)
  "Step-If-True"
  (list)))
]

@section{Modeling Evaluation}
The single-step reduction judgment forms the basis for an interpreter.
We can model an interpreter, formally, as a judgment that applies each of the
above reductions over and over and over again, until there are none left.
Programming languages people sometimes call this the @emph{reflexive},
@emph{transitive}, @emph{compatible} closure of the reduction judgment.
I don't know why, since these terms do not exist in our universe, but it's good
to know.

@examples[#:eval eg
(define-judgment-form U2
  #:contract (→* e_1 e_2)

  [------------- "Refl"
   (→* e_1 e_1)]

  [(→ e_1 e_2)
   ----------------- "Step"
   (→* e_1 e_2)]

  [(→* e_1 e_2)
   (→* e_2 e_3)
   ------------------ "Trans"
   (→* e_1 e_3)]

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
   (→* (e_1 + e_2) (e_1 + e_21))])
]

To model the interpreter, we define the judgment @racket[→*].
Intuitively, this judgment applies the @racket[→] judgment any number of times,
to any sub-expression.
We start by declaring that an expression can take no steps, or, step to itself
@racket[(→* e_1 e_1)].
Next, we have a rule saying that if an expression steps in the
@racket[→] judgment, then it can step in the @racket[→*] judgment.
That is, any expression can take a single step.
Then, we have a rule that says we can evaluate from @racket[e_1] to
@racket[e_2], and then continue evaluating @racket[e_2] to @racket[e_3].

Before explaining the rest of the rules, we should carefully look at the rule
@racket["Trans"].
Here, we're defining an inductively relation.
However, in the @racket["Trans"] rule, nothing gets "smaller".
This violates one of the rules of thumb for defining good judgments.
We can still use this judgment, but this will have consequences later.
@margin-note{I screwed up this explanation in lecture. In lecture, I claimed we
had to modify the rule. This isn't necessarily true, and the modification I made
ended up giving us the wrong judgment.}

The rest of the rules are called "compatibility" rules.
We need one rule for each sub-expression, declaring that the interpreter is
allowed to evaluate the sub-expressions.

With this judgment, we can now prove that more complex equations between
expressions.
For example, we can prove that @racket[(if true then ((s z) + (s z)) else false)]
evaluates to 2.
First, we interpret @racket[→*] as "evaluates".
Then, we interpret @racket[(s (s z))] as 2.
We already assumed earlier that @racket[(s z)] is 1 and @racket[+] is addition.
Now we build the derivation

We'll build the derivation in two steps.
First, we'll prove that 1 plus 1 equals 2, @emph{(→* ((s z) + (s z)) (s (s z))))}.
Then we'll combine this fact with the fact that the if expression evaluates to
its true branch.
@examples[#:eval eg
(define one-plus-one-equals-two
  (derivation
   '(→* ((s z) + (s z)) (s (s z)))
   "Trans"
   (list
    (derivation
     '(→* ((s z) + (s z)) (z + (s (s z))))
     "Step"
     (list
      (derivation
       '(→ ((s z) + (s z)) (z + (s (s z))))
       "Step-Add-Add1"
       (list))))
    (derivation
     '(→* (z + (s (s z))) (s (s z)))
     "Step"
     (list
      (derivation
       '(→ (z + (s (s z))) (s (s z)))
       "Step-Add-Zero"
       (list)))))))

(test-judgment-holds →*
  one-plus-one-equals-two)

(test-judgment-holds →*
  (derivation
    '(→* (if true then ((s z) + (s z)) else false) (s (s z)))
    "Trans"
    (list
      (derivation
        '(→* (if true then ((s z) + (s z)) else false) ((s z) + (s z)))
        "Step"
        (list
          (derivation
            '(→ (if true then ((s z) + (s z)) else false) ((s z) + (s z)))
            "Step-If-True"
            (list))))
      one-plus-one-equals-two)))
]

The same derivation in on-paper notation is below:

@emph{Lemma 1 (One Plus One Equals Two):}
@tt{((s z) + (s z)) →* (s (s z))}

@emph{Proof:}
@verbatim{
--------------------------------- [Step-Add-Add1]      ------------------------------- [Step-Add-Zero]
((s z) + (s z)) → (z + (s (s z)))                       (z + (s (s z))) → (s (s z))))
---------------------------------- [Step]              ------------------------------ [Step]
((s z) + (s z)) →* (z + (s (s z)))                     (z + (s (s z))) →* (s (s z)))
------------------------------------------------------------------------------------- [Trans]
                          ((s z) + (s z)) →* (s (s z))
}

@emph{Theorem 1:}
@tt{(if true then ((s z) + (s z)) else false) →* (s (s z))}
@verbatim{


------------------------------------------------------------ [Step-If-True]
(if true then ((s z) + (s z)) else false) → ((s z) + (s z))                          Lemma 1
------------------------------------------------------------- [Step]        ------------------------------
(if true then ((s z) + (s z)) else false) →* ((s z) + (s z))                 ((s z) + (s z)) →* (s (s z))
------------------------------------------------------------------------------------- [Trans]
              (if true then ((s z) + (s z)) else false) →* (s (s z))

}

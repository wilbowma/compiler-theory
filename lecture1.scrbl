#lang scribble/manual
@(require "lib.rkt")

@title[#:tag "" #:tag-prefix "notes:lec1"]{Lecture 1 -- Introduction to Rebuilding the Universe}
About half of the students who take this course have no background in
programming languages, software verification, or formal abstract mathmetics.
That's okay.
One of my goals is to teach those students something new and interesting about a
research area that is relevant and possibly interesting to them, but not (yet)
accessibly.

Therefore, I do not assume any background in any mathematics.
Instead, I must rebuild formal mathematics from nothing, and do so in a short
amount time.

This necessitates a certain amount of handwaving...
In this section, I begin to make precise a formal system (with some handwaving)
that I hope will be accessible to the audience just described.
If you find the handwaving annoying, I end the notes with further reading.

@section{What @emph{is} math?}
Before we begin rebuilding the entire universe of mathematics sufficient to
formally define and reason about compilers, we must understand what math is.

I strongly recommend the following two articles as related reading:
@itemlist[
@item{@url{https://terrytao.wordpress.com/career-advice/theres-more-to-mathematics-than-rigour-and-proofs/}}
@item{@url{https://golem.ph.utexas.edu/category/2015/02/introduction_to_synthetic_math.html}}
]

In the first, the author describes the stages of mathematical eduction, roughly
describing the point of taking various kinds of math classes.
In short, there are three stages: pre-rigorous, rigorous, and post-rigorous.
In pre-rigorous math, you are taught to compute in order to build intuition,
but are not taught why or much about the underlying formal theory.
In rigorous math, you taught the underlying formal theory.
In post-rigorous math, you handwave over the formal theory when you know (or,
think) it's boring so you can focus on the big picture.

The bulk of this course exists in the "post-rigorous" phase---we want to have
some formal definitions of languages and compilers, but handwave over annoying
details so we can focus on what "compiler correctness" even means.
Unfortunately, I must assume you have no rigorous math background.
So before we can begin with the post-rigorous, I must drag you screaming through
the rigorous.
Sorry.

The second post describes two broad-strokes classifications of mathematics.
In short, math can either be @emph{analytic} or @emph{synthetic}.
The distinction between "analytic" and "synthetic" is not a formal distinction,
but a fuzzier, human distinction.

Most people are familiar with analytic math.
This kind of math teaches you to break a problem down into simple, well-understood
parts.
In calculus, we break things down in to real numbers, functions on real numbers,
equations between real numbers, etc.
If we want to answer a question, like "how big is the earth", we can define
"bigness" and "the earth" as real-numbery things and use calculus.

In synthetic math, we define a new theory, with new axioms, to describe the
things we're studying.
We do not break things down into a big theory of things we already understand,
but build them up from a small set of axioms.

Most of the work on compiler correctness, and indeed much work in programming
languages, is closer to synthetic mathematics.
We start from two(ish) simple axioms for reasoning and build the entire
universe---programming languages, computation, equivalence between programs and
expressions, compilation, linking---from these two(ish) axioms.

@section{The Two Axioms}
Philisophically, the axioms of a formal system are the things we can all agree
make sense, and which we just have to accept on faith (or something), because we
have to start somewhere and can't prove everything makes sense from nothing.

In this class, we will use two(ish) axioms.
These are not formal axioms like the axioms of set theory, because I don't have
time to get that precise.
These are... intuitive axioms, which I will connect to a formal system that I
will never fully define.
These two intuitive axioms are all you need to read and begin understanding most
of the papers in the compiler correctness literature.

@subsection{The First Axiom: Implication}
The first axiom is the Axiom of Implication.
It states that:

@itemlist[
@item{I can make @emph{judgments} of the form "A implies B".}
@item{If I have a @emph{judgments} of the form "A implies B", and a @emph{judgment}
"A", then I can conclude "B".}
]

We can all agree that this seems, intuitively, like a good logical reasoning
principle.

This refers to the idea of @emph{judgment}, any statement I can make in my
formal system.
These are judgments in the sense that they decide or judge the property of some
symbols you write on the page.
The formal system says you can write any symbols you like on the page, but they
only given meaning when some judgment pronounes that they indeed have meaning.

Formally, we write an implication using horizontal bar notation.
For example, the following notation means "A implies B".

@verbatim{
  A
-----
  B
}

We can also write implications with many premises.
The following examples mean "(A and B and C) implies D".

@verbatim{
A    B    C
-----------
     D
}

For the pieces of a judgment, we can use any symbol we like.
We can use English letters like "A", "B", or "meow", or numbers like "1" "42" or
"-0", or random symbols like "⊢", "+", or "↑".
Whatever symbol is there, remember: @emph{never assume you know what it means}.
Remember, we are rebuilding the entire universe, so nothing exists except what
we've defined.
The symbols are @emph{meaningless except for what the judgment says they mean}.
If I write 0, it may not be smallest natural number, the identity element on the
addition function, or an integer.
It could be string, or a boolean, or a function.
It means only what the judgments say it means.
Usually, though, we choose symbols to suggest a connection to an intuitive
meaning.
If I choose 0 but don't @emph{mean} zero, I'm a bad person.

To see an examples, we can define the booleans into our universe.
Formally, we define a @deftech{judgment} as a list of rules.
Each rule introduces a new axiom into the universe that we are defining.
The rule is valid if it follows from one of our philisophical Axioms.
Formally, we write:

@box{@emph{any} : Bool} @~ @tt{@emph{any} is Bool}
@verbatim{

----------- [True]
true : Bool

----------- [False]
false : Bool
}

This defines a @tech{judgment} with two rules.
By convention, I usually add a label to the right of each rule with a name for
the rule.
These rules are implications with no premises, so we can read the first rule,
@tt{[True]} as stating "anything implies @tt{true : Bool}".

Usually, when I define a judgment, I start with a box that defines the shape of
the judgment.
This helps the reader quickly parse the pieces of the judgment.
This judgment's shape means it expects @emph{any} symbol, followed by a colon
character, followed by the symbol "Bool".
For this course, I also give an English pronunciation and name for the judgment,
to aid in referring to it.
The English reading of this judgment is "@emph{any} is judged a boolean", or
"@emph{any} is a Bool".
Note that while we are suggesting booleans, we have not given these symbols any
meaning that actually makes them behave life booleans.

Here, @emph{any} is a @deftech{meta-variable}, something that is not really part
of the formal system but should be interpreted by your brain as a place-holder
for something.
The @emph{any} meta-variable stands for literally anything, and should match any
symbol.

Now that we have a judgment, we can make statements, and prove that the statement
is true or not in our universe.
For example, I can prove that @tt{true : Bool} holds (also pronounced "the @tt{_
: Bool} judgment holds on (the symbol) @tt{true}").
It follows easily by the rule @tt{[True]}; it's an axiom of our universe.
The @deftech{derivation}, the tree of rules to follow, is a tree of height 1
with the rule @tt{[True]}.

Typically, we write @tech{derivations} as trees of instances of the rules defining the
judgment.
A derivation looks just like a bunch of rules stacked on top of each other,
except they contain no meta-variables.
The @tech{derivation} proving that @tt{true : Bool} is written as follows.

@verbatim{
---------- [ True ]
true : Bool
}

On paper, it looks identical to the rule @tt{[True]}.

We can also prove that @tt{0 : Bool} does not hold ("the @tt{_ : Bool} judgment
does not hold on (the symbol) @tt{0}"): consider all possibly cases of the @tt{_
: Bool}.
There are exactly two, and neither allows the symbol @tt{0} on the left hand-side
of the colon.

We can also define a judgments that refer to previously defined judgments.
Below we define a judgment that says @tt{not} written in front a @tt{Bool} is a
valid thing to write in front of a @tt{Bool}.
Intuitively, we would like this to mean it's a valid operation on booleans.

@box{@emph{any@sub{1}}(@emph{any@sub{2}}) : Bool} @~ @tt{@emph{any@sub{1}} is an operation on Bool}
@verbatim{

  @emph{any} : Bool
----------- [Not]
not(@emph{any}) : Bool
}

This defines a @tech{judgment} with one rule.
That rule is a simple implication, and the premise refers to the previously
defined judgment.
The rule says @tt{not} can be written next to a symbol @tt{any}, if @tt{any} is
judged to be a @tt{Bool}.

Now we can prove that @tt{not(true) : Bool}, or intuitively, that @tt{not}
applied to @tt{true} is a valid @tt{Bool}.
The derivation is the following.
@verbatim{

  ----------- [True]
  true : Bool
---------------- [Not]
not(true) : Bool
}

This derivation has height 2.
The derivation has one @deftech{subderivation}, @emph{i.e.}, a derivation that
is a proof that the premise for some rule holds.

We didn't have to define the @tt{is operation on Bool} judgment as a separate judgment.
We could have equally defined @tt{not(any) : Bool} as a rule in @tt{is Bool}
judgment.
However, then we would need a premise that recursively refers to the same
judgment being defined.
The Axiom of Implication does not allow us to do that; we should only refer to
things that are already defined.

@subsection{The Second Axiom: Induction}
The second axiom is the Axiom of Induction.
It states that:

@itemlist[
@item{I can define a judgment by cases that recursively refers to itself, so
long as something gets small in the premise of each case.}
@item{If I have an inductively define judgment, @emph{J}, with rules
@emph{R@sub{0}}, @emph{R@sub{1}}, ..., @emph{R@sub{N}}, and I want prove some property holds on
instances of @emph{J}, then it suffices to prove:
@itemlist[#:style 'numbered
@item{If P holds on the recursive @tech{subderivations} of R@sub{0}, then P holds for the conclusion of R@sub{0}}
@item{If P holds on the recursive @tech{subderivations} of R@sub{1}, then P holds for the conclusion of R@sub{1}}
@item{...}
@item{If P holds on the recursive @tech{subderivations} of R@sub{N}, then P holds for the conclusion of R@sub{N}}
]}
]

It is far from obvious that this is a good, logical reasoning principle,
so you'll have to trust me on this one.
Thankfully, it is suffiently powerful to let us build up the universe.

For example, we can define a single @tt{is Bool} judgment that judges both
boolean values and boolean operations:

@box{@emph{any} : Bool} @~ @tt{@emph{any} is Bool}
@verbatim{

----------- [True]
true : Bool

----------- [False]
false : Bool

any : Bool
----------- [Not]
not(any) : Bool
}

The shape of the judgment puts no restrictions on the expression @tt{any}, so
for example, @tt{not(true)} is a valid @tt{any}, just as is @tt{true}.
Note that the rule @tt{[Not]} refers to the same judgment we're defining, but
it's okay since something got smaller---we removed the symbol @tt{not} from the
expression being judged.

We can conclude @tt{not(true) : Bool}, since @tt{true} @tt{is Bool} by
@tt{[True]}, and therefore @tt{not(true) : Bool} by @tt{[Not]}.
The derivation looks just like before, except now all the rules come from the
same judgment.

We can also build a judgment that defines the natural numbers.

@box{@emph{any} : Nat}
@verbatim{

-------- [Zero]
z : Nat

@emph{any} : Nat
------------ [Add1]
s @emph{any} : Nat
}

Note that in @tt{[Add1]} we recursively refer to the same judgment being defined.
This is okay, since something got smaller---we removed the symbol @tt{s} from
the expression being judged.

Intuitively, this judgment defines the natural numbers, @emph{if} the symbol
@tt{z} behaves like the number 0, and the symbol @tt{s} behaves like the
function that adds 1 to its argument.
We haven't defined any interpretation of the symbols @tt{z} or @tt{s}, so it's
not yet clear that they really do represent anything at all.

@subsection{Defining Not-False Things: Rules of Thumb}
Since we are rebuilding the entire universe by defining new axioms to reason
about, we must take care to define things that are not false.
It's beyond the scope of this course to describe formally how to do this.
Instead, I will give you some rules of thumb:

First, above the line, only refer to things that exist.
Judgments can only refer to other judgments.
Second, the premises should refer to parts of the conclusion, but in a way that
something gets smaller.

When we define the judgment @tt{any(any) : Bool}, we refered to the judgment
@tt{any : Bool}, which we had previously defined.
This obeys rule-of-thumb #1, and is is a good sign.
We also made something smaller in the rule @tt{[Not]}, by removing the symbol
@tt{not}.
This obeys rule-of-thumb #2, and is is a good sign.

There are exceptions to these rules, and they may be insufficient, but you'll
need to take something like a set theory course to formally understand why.
For example, in rule @tt{[S]} when defining natural number, we refer to the
very judgment we're still defining, thus violating rule-of-thumb #1.
However, the Axiom of Induction says this is okay, since something got smaller,
so we allow the exception.

@section{Defining a Language}
We now have enough tools to being defining a language.
But what is a language?

When polled, most students start describing a language features like the following:
@itemlist[
@item{Surface syntax}
@item{Operations}
@item{A way to for a human to express instructions to a machine}
]

However, when asked to name languages, they name a few languages with much in
common.
@itemlist[
@item{Java}
@item{C}
@item{Python}
]

To me, a language is:
@itemlist[
@item{A collection of expressions}
@item{Some operations on expressions}
@item{Some common properties}
]

@subsection{Modeling a Collection of Expressions}
To model a language, we begin by modeling the expressions.
We have only one way to model something: add it to our universe by defining
@tech{judgments}.
So we start by defining the @tt{is Expression} judgment.
For brevity, and because it's what programming language theorists usually do, I
write this as @tt{⊢ @emph{any}}.

Our language will be defined to have some numbers, plus, and user-defined
functions.
We define its expressions by the judgment below.

@box{⊢ @emph{any}} @~ @tt{@emph{any} is an Expression}
@verbatim{

@emph{any} : Nat
------------ [E-Nat]
⊢ @emph{any}


⊢ @emph{any@sub{1}}
⊢ @emph{any@sub{2}}
-------------------- [E-Plus]
⊢ @emph{any@sub{1}} + @emph{any@sub{2}}


--- [E-Var]
⊢ x


⊢ @emph{any}
--------- [E-Lam]
⊢ λx.@emph{any}


⊢ @emph{any@sub{1}}
⊢ @emph{any@sub{2}}
--------- [E-App]
⊢ @emph{any@sub{1}} @emph{any@sub{2}}
}

This defines a @tech{judgment} with gives rules, and refers to the @tt{is Nat}
judgment defined earlier.
Anything that @tt{is Nat} is also @tt{an Expression}.
So are two expression on either side of the symbol @tt{+}.
So is the symbol @tt{x}.
So is the symbols @tt{λx.} to the left of an @tt{Expression}.
So are two expressions seperated by a space.

In these rules, I put each premise on its own line for clarity.

Those familiar with programming languages might think they recognize this
language.
But rest assured, you do not, because I have not given these symbols any
meaning, so they cannot be related to anything you have seen before.
They only meaning they have is that they are @tt{Expressions}, whatever that
means.

@; Save this for after syntax.
@;@subsection{Modeling a Operations on Expressions}
@;When talk about operations on expressions, those with a programming background
@;might assume we mean things like built-in operations, and library functions.
@;In meta-theory, that is not what we mean.
@;We mean @tech{judgments} about expressions.
@;
@;What are some things we might like to judge about ex

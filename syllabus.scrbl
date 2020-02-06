#lang scribble/manual

@(define (todo . rest) @(apply margin-note "TODO:" rest))

@(define course-title "Compiler Theory---Topics in Compiler Correctness")
@(define course-number "CPSC 539B")

@title{Syllabus, @|course-number|}

@section{Land Acknowledgement}
UBC’s Point Grey Campus is located on the traditional, ancestral, and unceded
territory of the xwməθkwəy̓əm (Musqueam) people.
The land it is situated on has always been a place of learning for the Musqueam
people, who for millennia have passed on their culture, history, and traditions
from one generation to the next on this site.

@section{Course Description}
The goal of this course is to introduce students to one of the most foundational
research areas in programming languages theory---compiler correctness.
By the end of the course, students will not be experts able to do compiler
correctness research, but will be able to read and critically analyze such
research.
Students will learn to interpret the formal notation used in compiler
verification research, analyze compiler correctness research papers, and compare
them.

The course assumes no familiarity with programming languages theory, compiler
construction, or low level programming.
The course assumes students have background knowledge of programming and the
broad strokes of register machines.
Background in formal mathematics, verification, or programming languages will be
helpful but not necessary.

@section{Course Information}
@tabular[
#:style 'boxed
#:column-properties '(left left)
(list
  (list @bold{Course Title} course-title)
  (list @bold{Course Number} course-number)
  (list @bold{Room} @hyperlink["https://ssc.adm.ubc.ca/classroomservices/function/viewlocation?userEvent=ShowLocation&buildingID=ICCS&roomID=246"]{ICCS 246})
  (list @bold{Lectures} "Mon. Wed. 13:30--14:50"))
]

@section{Prequisites}
None.

@section{Course Materials}
No textbook is required.

Weekly lecture notes will be posted, and additional reading from the following
freely available sources may be suggested.

@itemlist[
@item{@hyperlink["http://www.cs.cmu.edu/~rwh/pfpl/2nded.pdf"]{Practical Foundations of Programming Languages}}
@item{@hyperlink["http://pl.cs.jhu.edu/pl/book/book.pdf"]{Principles of Programming Languages}}
]

I will give assignments and examples using the
@hyperlink["https://docs.racket-lang.org/redex/The_Redex_Reference.html"]{Redex
language}.
You should have access to a machine with Racket and Redex installed.

I do not expect you to know Redex or Racket, and will explain as much of Redex
as you need throughout the course.

@section{Contacts}
@tabular[
#:style 'boxed
#:column-properties '(center)
#:row-properties '(bottom-border)
(list
  (list @bold{Instructor} @bold{Contact Details} @bold{Office} @bold{Office Hours})
  (list "William J. Bowman" "wilbowma@cs.ubc.ca" @hyperlink["https://ssc.adm.ubc.ca/classroomservices/function/viewlocation?userEvent=ShowLocation&buildingID=ICCS&roomID=389"]{ICCS 389} "Mon. Thur. 16:00--17:00"))
]

You also can discuss the class with other students and the instructions via Piazza:
@url{https://piazza.com/ubc.ca/winterterm22019/cpsc539b}.

@section{Course Structure}

The course is divided into two parts: (1) an introduction to formal programming
language techniques and formal models of compilers, and (2) a seminar in which
we will read and discuss compiler correctness papers.

@subsection{Structure for Introduction}
The first part of the course will have a familiar course structure, with a
lecture and assignment component.
During lecture, I will introduce formal techniques that you will encounter in
the second part of the course.
There will be in-class activities and small assignments to complete outside of
class to reinforce lessons from lecture.

Assignments will be graded primarily to gauge how much of the formal techniques
students are understanding, and what needs to be discussed more in lecture.

@subsection{Structure for Seminar}
During the second part of the course, the structure will be in the style of a
research seminar.
Outside of class, students will read a selection of research papers on compiler
correctness submit summaries and critiques of the papers.
Students will also be able to discuss papers on an electronic forum outside of
class.
During class, we will discuss the papers the papers.
One student per paper will be assigned to lead the discussion.

Each critique should be ~2 paragraphs.
Start by briefly summarizing the paper, then describing its strengths and
weaknesses.

The summaries and critiques will be graded based on the understanding of the
work and the assessment of strengths and weakness of papers.

Students will also be graded on participation in the discussion.

@subsubsection{Discussion}
I’m planning for each paper to take up 1-2 days to present and discuss.
One student will be the discussion lead.
The goal of the discussion lead is to essentially guide the class through the
reading.
Part of the goal for this is to help you get confortable just talking about
technical material without much prep (a skill you will need as a researcher).
You may not understand everything in the paper, and that’s fine.
If you don’t understand part of the paper, or have questions, feel free to say
that and ask the class what they thought.
This will help us all understand the reading better.
Part of the goal is to ensure everyone is following and engaging critically in
the presented material---ask and encourage others to ask questions, and try to
question implicit assumptions in the technical work.
For instance, if the discussion lead thinks a particular section is confusing
but no one is asking questions, they should ask probing and clarifying
questions.
If the class accepts claims, contributions, or theorems at face value, the
discussion lead can ask if the English statements match technical results, or
match the stated goals.
When discussion and questions are flowing naturally, then the discussion lead
has little to do but engage normally.

@subsubsection{Project}
At the end of this section of the course, I will assign a project.

You will model a compiler---a source and target language with a translation
from source to target---and show the translation is both "correct" and
"incorrect".
That is, show that the translation satisfies one of the correctness properties
we discussed, but fails to satisfy another.

The project will involve writing up the formal definitions of the source,
target, and the translation, a counterexample demonstrating incorrectness, and
a semi-formal argument for correctness.

At the end of the course, the project write-ups will be critiqued by the class
using the same system we use for critiquing research papers.
If time allows, we will also discuss the projects in class.

@section{Grading}
Grades in this class are not important.
For context, everyone in my last class got an A.
Half of them had no experience in programming languages.
At the end of the course in their course projects, their proofs had bugs, their
theorems weren't completely precise, and the writing didn't always say what the
math said.
Which is to say, their projects were on par with research papers.

In the introduction portion of the class, I may give you assignments or
quizzes.
If I mark them, the marks are to teach you, and to let me know how much I
still need to cover.
The marks are not meant to assess you.
If you're participating, asking questions, and trying to learn, then
you're doing well.

Grading will be largely based on participation of in-class discussions, your
paper critiques, and on your project.
I don't expect you all to master this material; it's hard, and is an
active area of research.
There aren't terribly many "right" answers; we in the community are still
arguing about what the questions should be, let alone the answers.
This is a new research area to most of you; I don't expect you do always be
completely precise and rigorous, although I expect you to try.
But I do expect you to come to class prepared, ask questions, and engage
in discussion.

If you're here auditing, I strongly encourage you to take this class.
It won't be a massive drain on your time, and enrolling will make it the
course a more formal commitment and will encourage you to get more out of
the course.

@section{Learning Objectives}
@itemlist[
  @item{Read and interpret formal programming languages notation.}

  @item{Describe programming language features using formal notation.}

  @item{Recognize different compiler correctness theorems.}

  @item{Compare and contrast the strengths and weaknesses of different compiler
  correctness theorems.}

  @item{Critique compiler correctness research.}
]

@section{Schedule of Topics}

@itemlist[
#:style 'numbered
@item{
  Introduction to formal models, from a PL perspective
  @itemlist[
    @item{Formal mathematics}
    @item{Synthetic mathematics}
    @item{Inductively defined judgments}
  ]
}

@item{Formal models of programming languages
  @itemlist[
  @item{Modeling terms}
  @item{Modeling observations}
  @item{Modeling program}
  @item{Modeling reduction and evaluation}
  @item{Modeling linking}
  @item{Modeling type systems language-level guarantees}
  @item{Modeling language-level guarantees}
]
}

@item{Formal models of compilation
  @itemlist[
    @item{Modeling low-level languages}
    @item{Modeling translations}
    @item{A-normal form}
    @item{Continuation-passing style}
    @item{Closure conversion}
    @item{Heap allocation}
    @item{Code generation}
  ]
}

@item{Formal statements of compiler correctness
  @itemlist[
   @item{Whole program correctness}
   @item{Correctness of Separate compilation}
   @item{Compositional Correctness}
   @item{Secure Compilation/Full Abstraction}
  ]
}

@item{Type Preservation
@itemlist[
@item{@hyperlink["https://doi.org/10.1145/319301.319345"]{From System F to Typed Assembly Language}}
@item{@hyperlink["https://doi.org/10.1145/231379.231414"]{TIL: A Type-direct optimizing compiler for ML}}
@item{@hyperlink["https://doi.org/10.1145/263699.263712"]{Proof Carrying Code}}
@item{@hyperlink["https://doi.org/10.1145/507635.507657"]{Dependently Typed Assembly Language}}
@item{@hyperlink["https://doi.org/10.1145/3062341.3062363"]{Bringing the Web up to Speed with WebAssembly}}
]
}

@item{Semantics Preservation and Separate Compilation
@itemlist[
@item{@hyperlink["https://doi.org/10.1145/1111037.1111042"]{Formal Certification of a Compiler Back-end}}
@item{@hyperlink["https://doi.org/10.1145/2676726.2676985"]{Compositional CompCert}}
@item{@hyperlink["https://doi.org/10.1145/2837614.2837642"]{Lightweight Verification of Separate Compilation}}
@item{@hyperlink["https://doi.org/10.1145/3371091" "CompCertM: CompCert with C-Assembly Linking and Lightweight Modular Verification"]}
]
}

@item{Secure Compilation
@itemlist[
@item{@hyperlink["https://doi.org/10.1145/1411204.1411227"]{Typed Closure Conversion Preserves Observational Equivalence}}
@item{@hyperlink["https://doi.org/10.1109/SPW.2015.33"]{The Correctness-Security Gap in Compiler Optimization}}
@item{@hyperlink["https://doi.org/10.1016/j.tcs.2006.08.014"]{Securing the .NET Programming Model}}
@item{@hyperlink["https://doi.org/10.1145/3290390"]{CT-wasm: type-driven secure cryptography for the web ecosystem}}
]
}
]

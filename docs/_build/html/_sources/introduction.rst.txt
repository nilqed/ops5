1. Introduction
===============
0PS5 is a member of the class of programming languages known as production systems.
It is used primarily for applications in the areas of artificial intelligence, expert systems, and cognitive psychology. This manual is a combination introductory and reference manual for OPS5. 
The rest of Section 1 provides an overview of the language. Sections 2 through 8 describe the 
language and its interpreter in detail. To allow the new user to read the manual straight through, 
the material has been organized in a top-down fashion. To allow the experienced user to answer detailed questions quickly, the manual has been divided into short
sections describing individual features of the language, and an index has been provided.

Three interpreters for OPS5 have been written, one in BLISS [1], one in MACLISP [9], and one in 
FRANZ LISP [3]. As could be expected, there are a few incompatibilities between the interpreters. 
The manual points out the differences between die three interpreters.

1.1. The Production System Architecture
---------------------------------------
A production system is a program composed entirely of conditional statements called productions. 
These productions operate on expressions stored in a global data base called working memory. The productions are stored in a separate memory called production memory. The production is similar 
to the If-Then statement of conventional programming languages: a production that contains n conditions C1 through Cn and m actions A1 through Am means
::

	When working memory is such that C_1 through C_n are true simultaneously,
	then actions A_1 through A_m should be executed.
	
The condition part of a production is usually called its LHS (left hand side), and the action 
part is called its RHS  (right hand side).

The production system interpreter executes a production system by performing a sequence of operations
called the **recognize-act cycle**:

1. [Match] Evaluate the LHSs of the productions to determine which are satisfied given the current
contents of working memory.
2. [Conflict resolution] Select one production with a satisfied LHS. If no productions have satisfied
LHSs, halt the interpreter.
3. [Act] Perform the actions specified in the RHS of the selected production.
4. Go to step 1.

Production systems differ from conventional programs in two major respects.
The first is that the production system uses a different method for encoding the state of a computation. A conventional program
encodes state by assigning values to local and global variables. A production system encodes state by putting
expressions in the system's global working memory. The other difference between production systems and
conventional programs is the way flow of control is managed. A conventional program uses sequential
execution of statements plus a number of control constructs including subroutine calls, loops, and conditional
branching. A production system uses LHS satisfaction. Each production s LHS is a description of the states
in which the production is applicable; the LHS becomes true when there is some information in working
memory that the production can process. When the interpreter performs the match process, it is in effect
searching for a production that knows how to process the data that is in working memory. When it finds that
production and executes its RHS. working memory is changed, and so on the next cycle, the interpreter
performs the match again to find a production that can handle the new data.

1.2. OPS5's Working Memory
--------------------------
In OPS5, the most commonly used representation for information in working memory is the attribute-value
representation. This representation is oriented towards describing objects and relations among objects; that
is, even though it (like most representations) can be used for many other purposes, it is most naturally used to
describe objects and.relations. In this representauon. every element in working memory consists of an object
and a collection of associated attribute-value pairs. For example, in this representation, a single working
memory element might indicate that block1 is a red block weighing 500 grams, measuring 100 mm on a side.
The element would be

.. code-block:: lisp

	(block 
	   ^name      block1
	   ^color     red 
	   ^mass      500
	   ^length    100
	   ^width     100
	   ^thelght   100)
	
As this shows, an element consists of a class name (`block` in this case) followed by some number of attributes
and values, with everything enclosed in parentheses. Attributes are distinguished by being preceded with the operator `^`.


1.3. OPS5's Production Memory
-----------------------------
The LHS of a production consists of one or more patterns; i.e.. one or more expressions that describe
working memory elements. During the match part of the recognize-act cycle, the interpreter compares each
pattern with die elements in working memory to determine if the pattern matches any of them. The pattern is
considered satisfied if it matches at least one element. If all the patterns in a production's LHS are satisfied,
the LHS is satisfied.

Patterns arc abstract rcprcseniations of working memory elements.
One way a pattern can be an
abstraction of a working memory element is to contain fewer attributes and values than the clement. Such a
pattern will match any working memory element that contains the information in the pattern. (It does not
matter how much more information the working memory clement contains.) Thus the pattern

.. code-block:: lisp

      (block ^color red)
     
would match the working memory element

.. code-block:: lisp

	(block 
	   ^name      block1
	   ^color     red 
	   ^mass      500
	   ^length    100
	   ^width     100
	   ^thelght   100)
	   
Another way a pattern can be an abstraction of a working memory element is to contain incompletely
specified values. OPS5 provides special pattern operators that can be used to specify values at various levels
of detail. The most important operator is the **variable**. A variable is any symbol that begins with the character
`<` and ends with the character `>` -- for example, `<x>` or `<status>`. A variable in a pattern may match
anything, but if a variable occurs more than once in a production, it must match the same value everywhere.
Thus if a cube is defined to be a block whose three sides are the same length, the following pattern will match only cubes.

.. code-block:: lisp

     (block ^length <x> ^width <x> ^helght <x>)
     
The RHS of a production consists of an unconditional sequence of actions. OPS5's set of action types
indudes actions to manipulate working memory, actions to perform input and output, actions to add new
productions to production memory, and others. The most important of the actions are the ones to manipulate
working memory. The action **make** is used to create and add new elements. A **make** action consists of an
open parenthesis, the symbol **make**, a description of the element to create, and a close parenthesis. The
description of the element is similar in form to the patterns in the LHS. For example, the following would
create the element for block1 shown above.

.. code-block:: lisp

	(make block 
	   ^name      block1
	   ^color     red 
	   ^mass      500
	   ^length    100
	   ^width     100
	   ^thelght   100)
	  
The action **remove** is used to delete elements from working memory. A **remove** action consists of an open
parenthesis, the symbol **remove**, a pointer to the element to delete, and a close parenthesis. The following
for example would delete the element matching the third pattern of the production's LHS.

.. code-block:: lisp

    (remove 3)
    
The action **modify** is used to change one or more values of an existing element. A **modify** action consists of
an open parenthesis, the symbol **modify**, a pointer to the element to change, a description of the changes to
make, and a close parenthesis. The following for example would change the status of the element
matching the first pattern in the LHS to satisfied,

.. code-block:: lisp

     (modify 1 ^status satisfied)
     
A **production** consists of an open parenthesis, the symbol **p**, a name, the LHS of the production, the symbol `-->`, the RHS, and a ciose parenthesis. The following is a typical (though quite small) OPS5 production. The text after the semicolon on each line is a comment.

.. code-block:: lisp

	(p find-colored-block
	    (goal                              ; If there is a goal
	        ^status active                 ; which is active
	        ^type find                     ; to find
	        ^object block                  ; a block 
	        ^color <z>)                    ; of a certain color
	    (block                             ; And there is a block
	        ^color <z>                     ; of that color
	        ^name <block>)                 
	    -->
	    (make result                       ; Then make an element 
                ^pointer <block>)              ; to point to the block 
            (modify 1                          ; And change the goal
                ^status satisfied))            ; marking it satisfied
                


1.4. The OPS5 Lexical System
----------------------------
The input to OPS5 is completely free formal. Spaces, tabs, and new lines may be used at will to improve
the readability of productions and working memory elements; the interpreter uses the parentheses to
determine where units begin and end. In addition, comments like those shown above may be used anywhere;
when the interpreter reads a line containing a semicolon, it discards everything from the semicolon to the end
of the line. The above production could also have been written

.. code-block:: lisp

      (p find-colored-block
          (goal ^status active ^type find ^object block
                ^color <z>)
          (block ^color <z> ^name <block>)
          -->
          (make result ^pointer <block>)
          (modify 1 ^status satisfied))
      

1,5. Acknowledgements
---------------------
The first language in the OPS family [4, 5] was designed in 1975 at Carnegie-Mellon University by Charles Forgy, John McDermott, Allen Newell, and Michael Rychener. The design of the language was influenced
by earlier production systems languages, including PSG [10] and PSNLST [11]. Since 1975 OPS has been
revised several limes as better representations and more efficient interpreters have been developed [ö, 7, 12].
Many people have contributed to the development of OPS, including the members of the CMU production
systems expert systems, and cognitive psychology groups, as well as the members of Digital Equipment
Corporation's expert systems group.





















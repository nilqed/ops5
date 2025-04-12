2. Working Memory
=================
Working memory is a set of ordered pairs
::

    <Time tag, Working memory elemenO

A working memory element is a structure (usually a vector or record) of scalar 
values. The time tag is a unique numerical identifier that is supplied by the 
interpreter.

2.1. Organization of Working Memory
-----------------------------------
OPS5, like most programming languages, provides both scalar (sometimes called atomic) 
data types and structured data types. The elements in working memory may not be scalars. 
(However, it is legal to have a structure that contains only a single scalar value.)

The number of elements in working memory varies dynamically at run time. With 
the LISP-based interpreter, working memory may grow arbitrarily large. With the 
BLISS-based interpreter, a maximum size for the memory is established when the 
interpreter is installed; the current limit is 1023 elements.

2.2. Time Tags
--------------
Every element in working memory has an associated integer called the element's 
time tag. This integer indicates when the element was created or last modified; 
the elements with larger time tags were more recently created or modified. 
No two elements have the same time tag. Time tags are used in conflict resolution, 
and they are used to designate elements by many of the facilities that communicate 
with the user (see Section 8.1).

2.3. Scalar Values
------------------
OPS5 provides two scalar data types: numbers and symbolic atoms.

2.3.1. Numbers
^^^^^^^^^^^^^^
The numeric type on the LISP-based interpreters for OPS5 includes both floating 
point and fixed point numbers.
(The interpreters will make the appropriate conversions when mixed mode 
expressions are evaluated.) The BLISS-based interpreter allows only fixed point 
numbers to be used. Fixed point numbers consist of an optional sign, one or more 
decimal digits, and an optional decimal point. Valid fixed point
numbers include `0, 0., -7, -7.`.

A floating point number consists of an optional sign, zero or more decimal digits, 
a decimal point, zero or more digits after the decimal point, and an optional 
exponent, consisting of the letter "e" followed by a signed or unsigned integer. 
The number must include either an exponent or a digit after the decimal point; 
if it contains neither the interpreter will take it to be an integer. Typical 
floating point numbers include
::

        0.0
        .05
        6.020-23
        -1.812


The computer on which OPS5 is run determines the legal range for fixed and 
floating point numbers and the number of digits of precision in floating point 
numbers.

2.3.2. Symbolic Atoms
^^^^^^^^^^^^^^^^^^^^^
A symbolic atom is any sequence of characters that does not constitute a number 
and diat is treated as a single unit by the production system. Examples of 
symbolic atoms include
::

        a
        nil
        ---
        4-7-76


Some non-printing characters such as escape (ASCII 33 octal) or control-C 
(ASCII 3 octal) cannot conveniently be used in atom names. In addition, on the 
BLISS-based interpreters, symbolic atoms must not contain the character . But 
with this exception, all printing characters and many non-printing characters
such as space and tab can be used.

Some characters will be incorporated into atoms only if they are quoted. If they 
are used unquoted they are taken to be operators or separators. The characters 
that need to be quoted include (but are not limited to) space, tab, period, 
comma, uparrow ("t"), left and right braces ("{}"), and left and right 
parentheses ("()"). Different LISP interpreters provide different mechanisms 
for quoting characters. The best mechanism to use in OPS5 is probably the vertical 
bar (the character |) because it is understood by all the OPS5 interpreters. In
all the interpreters, everything that occurs between two vertical bars constitutes 
an atom. Thus the atom `) ) )` would be entered `| ) ) ) |`.

2.3.3. Case
^^^^^^^^^^^
The MACLISP-based interpreter and the BLISS-based interpreter do case folding; 
that is, they convert lower case characters to upper case on input. The 
FRANZ LISP-based interpreter does not do case folding. Thus on that interpreter, 
p and P are distinct atoms. All commands to the FRANZ LISP-based interpreter
must be given in lower case.


2.4. The Standard Structured Types
----------------------------------
0PS5 provides two non-scalar data types, plus a mechanism which allows the user 
to implement other non-scalar types. The standard types are attribute-value 
elements and vectors.

2.4.1. Attribute-Value Elements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
An attribute-value element consists of a class name and some number of attribute-value 
pairs, with everything enclosed in parentheses. Attributes are symbolic atoms, and 
values are either scalars or sequences of scalars. An attribute-value element may 
not contain more than 126 values. The following is a typical element

.. code-block:: lisp

      (goal ^status active ^type find ^object block ^color red)

The class name of this element is `goal`. Its attributes are `status` , `type`, 
`object`, and `color` ; the corresponding attributes are `active` , `find`, 
`object` , and `red`. The prefix operator `^` is used to distinguish
attributes from values.
The order in which attribute-value pairs are specified is not significant. Thus 
this element could also have been written say

.. code-block:: lisp

      (goal ^color red  ^object block ^status active ^type find)


2.4.1.1. Declarations
^^^^^^^^^^^^^^^^^^^^^
Attribute names **must** be declared before they can be used. The usual way to 
declare names is with
**1iteralize**. (Another method is described in Section 2.6.) A `1iteralize` 
declaration indicates which attributes will be used in elements of a given class. 
A declaration consists of the atom `1iteralize` , a class
name, and the attributes for that class, all enclosed in parentheses. For the 
goal shown above, a declaration like the following would be given.

.. code-block:: lisp

      (literalize goal
              status
              type
              object
              color)

This indicates that elements of class goal can have the attributes `status`, 
`type`, `object`, and `color`.

An attribute may have only one scalar value at a time unless it has appeared in 
a **vector-attribute** declaration. A vector attribute may have one, two, three, 
or more values; the only restriction is that the total size of the working memory 
element may not exceed 126 values. The number of values assigned to a vector
attribute may vary dynamically at run time. The declaration consists of the atom 
`vector-attribute` and one or more attribute names, all enclosed in parentheses. 
For example, if `contents` was to be made a vector attribute, it would be 
declared

.. code-block:: lisp

    (vector-attribute contents)
    
For an example of a vector attribute, consider a production system to solve the 
Towers of Hanoi problem. The vector attribute `contents` could be used to 
indicate which disks were on a given `peg`.

.. code-block:: lisp

      (peg
         ^name peg2
         ^contents disk1 disk3 d1sk4 disk5)
         
Two restrictions apply to vector attributes.

* An element class may not have more than one vector attribute.
* The vector attribute declaration is global. Each attribute is either a 
  scalar attribute everywhere it is used or a vector attribute everywhere it 
  is used. It is not possible for an attribute to be a scalar attribute in one 
  element class and a vector attribute in another.
  

2.4.1.2. Error Checking
~~~~~~~~~~~~~~~~~~~~~~~
OPS5 does not perform extensive error checking of attribute-value elements. It 
will permit attributes to be used with element classes they were not declared 
for, and it will allow the user to treat scalar attributes as vector attributes. 
It cannot check for errors like these because attribute-value elements are 
implemented using a general mechanism that is also available to the user 
(see Section 2.6).


2.4.2. Vector Elements
^^^^^^^^^^^^^^^^^^^^^^
The vector representation is used for data that needs to be represented as a 
sequence of symbols. An element in this representation consists of an open 
parenthesis, a sequence of atoms and numbers, and a close parenthesis. One 
common use for this representation is to hold input from the user. The element shown
below for example might be a command given to a system for algebraic manipulation,

.. code-block:: lisp

        (differentiate expression 4 wrt x)


Vector working memory elements do not have to be declared. Vectors can vary in 
length at run time. A vector cannot contain more than 127 values.


2.5. Details of Implementation
------------------------------
In the OPS5 interpreter, all working memory elements are stored as ordered lists 
or vectors of values. Attribute-value representations are implemented by mapping 
field names into indices. The lists shrink and grow as necessary when the 
elements are modified. An element may not grow to more than 127 values,
however.





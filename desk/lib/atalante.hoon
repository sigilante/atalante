  ::  /lib/atalante
::::  An ATL/APL compiler to Nock.
::
::    Atalante (ATL) formally requires five stages:
::    1.  The parsing pass (`++parser`)
::    2.  The inferencing pass (`++inferencer`)
::    3.  The access determination pass (`++optimizer`)
::    4.  The resource allocation pass (`++allocator`)
::    5.  The code generation pass (`++coder`)
::
::    “The initial pass of the APL compiler transforms an APLexpression into an
::    abstract syntax tree. The dataflow analysisalgorithms then operate on this
::    tree representation to propagatetype and rank information.”
::    (Budd1988, p. 15)
::
::    Atalante is built on top of Lagoon, the Linear AlGebra in hOON library
::    which supports basic vector, matrix, and linear algebra forms in Hoon.
::    Because of this connexion, ATL/APL types differ slightly from classical
::    APL types, including natively supporting a fixed-point type.
::    At the current time, a particular ATL text is interpreted by a particular
::    context which determines the type of all values in the evaluated ATL/APL
::    code source.
::
/-  *atalante
|%
::  ++parser is responsible for producing an AST as a Hoon/Nock noun.
::
::  Input:   @t            APL source
::  Output:  +$apple-tree  ATL AST
::
++  parser
  |%
  ::
  ++  parse  !!
  ::  ++input can accept shorthand ASCII inputs for values and convert them to
  ::  proper ATL/APL symbols.  See ++ascii-map for details.
  ++  input  !!
  --
::  ++inferencer is responsible to improve code quality by determining the
::  results of expressions.
::
::  Input:   +$apple-tree    ATL AST
::  Output:  +$apple-tree    ATL AST
::           +$symbol-table  Symbol table
++  inferencer  !!
::  ++optimizer is responsible for generating only the values that contribute
::  to the final result.
::
::  Input:   +$apple-tree    ATL AST
::  Output:  +$apple-tree    ATL AST
++  optimizer  !!
::  ++allocator is responsible to handle value declarations.
::
::  Input:   +$apple-tree    ATL AST
::  Output:  +$apple-tree    ATL AST
::           +$symbol-table  Symbol table
++  allocator  !!
::  ++coder is responsible to convert the ATL AST to an executable Nock noun.
::  This will be effected using Hoon's vase mode ++slap/++slop algebra.
::
::  Input:   +$apple-tree    ATL AST
::           +$symbol-table  Symbol table
::  Output:  +$apple-pie     Vase with executable Nock noun
++  coder  !!
--

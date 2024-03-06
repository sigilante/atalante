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
::    “The initial pass of the APL compiler transforms an APL expression into an
::    abstract syntax tree. The dataflow analysis algorithms then operate on this
::    tree representation to propagate type and rank information.”
::    (Budd1987, p. 15)
::
::    Atalante is built on top of Lagoon, the Linear AlGebra in hOON library
::    which supports basic vector, matrix, and linear algebra forms in Hoon.
::    Because of this connexion, ATL/APL types differ slightly from classical
::    APL types, including natively supporting a fixed-point type.
::    At the current time, a particular ATL expression is interpreted by a
::    particular context which determines the type of all values in the
::    evaluated ATL/APL code source.  This is analogous to scope or subject.
::
/-  *atl
|%
::  ++parser is responsible for producing an AST as a Hoon/Nock noun.
::
::  Input:   @t      APL source
::  Output:  +$tree  ATL AST
::
++  parser
  |%
  +$  token  cord
  ::  ++parse is responsible for parsing the APL source into a set of tokens.
  ::
  ::  Input:   cord          APL source
  ::  Output:  (list token)  ATL AST
  ++  parse
    |=  =tape
    |^
    ^-  (list @t)
    (scan tape ;~(pose command function operator variable value))
    :: +command parses only ATL commands like '←', '∇'
    ++  command
      %+  knee  *tree:atl
      |.  ~+
      ;~  pose
        :: %apply
        %+  cook
          ::  [%fork =form branches=(list tree)]
          |=(p=@ [%fork %assign ~[%empty %empty]])
        (jest '←')
        ::
      ==
    :: +function parses only ATL functions like '+', '×'
    ++  function  (cook |=(p=@ ?:(=('+' p) op+%add ~)) lus)
    :: +operator parses only ATL operators like '/', '\'
    ++  operator  (cook |=(p=@ ?:(=('+' p) op+%add ~)) lus)
    :: +variable parses only variable names like 'a', 'b';
    :: we permit all Unicode characters that aren't ASCII numbers,
    :: separated by whitespace.
    ++  variable
      !:  %+  cook
        |=  =(list cord)
        ::  trip crip because the inputs are not (list @tD) yet
        =.  list  (trip (crip `(^list @)`list))
        (split-all list " ")
        :: join symbols together unless separate by whitespace
      symbol-literal
    ++  symbol-literal
      (star ;~(pose all-symbols whitespace))
    ++  all-symbols
      ;~  pose
        (just '_')
        (shim 'a' 'z')  :: Latin minuscules
        (shim 'A' 'Z')  :: Latin majuscules
        (shim 'α' 'ω')  :: Greek minuscules
        (shim 'Α' 'Ω')  :: Greek majuscules
        (jest 'Ͱ')
        (jest 'ͱ')
        (jest 'Ͳ')
        (jest 'ͳ')
        (jest 'Ͷ')
        (jest 'ͷ')
        (shim 'Ϗ' 'Ͽ')
        (shim 'א' 'ת')  :: Hebrew
        (shim 'а' 'я')  :: Cyrillic minuscules
        (shim 'А' 'Я')  :: Cyrillic majuscules
        (shim '𐐀' '𐑏')  :: Deseret
        :: TODO add more that make sense
      ==
    ++  whitespace
      ;~  pose
        (jest '	')  :: tab
        (jest ' ')  :: space
        (jest '\0a')  :: newline
      ==
    :: +value parses only literals like '3', '4.5', '1 2 3 4 5'
    ++  value  array-literal
    ++  array-literal
      %+  cook
        (list @rd)
      ((slug |*([p=* q=*] [p q])) ace scalar-literal)
      :: (star ;~(pose ace scalar-literal))
    ++  scalar-literal
      %+  cook
        |=(=rn ^-(@rd ?>(?=(%d -.rn) (grd:rd (royl-cell:so rn)))))
      royl-rn:so
    ::
    ::  +split-all cribbed from jackfoxy's /lib/sequent
    ++  split-all
      |*  [p=(list) sep=(list)]
      =/  c=(list (list _?>(?=(^ p) i.p)))  ~
      =/  len  (lent sep)
      =/  q=(list @)  (flop (fand sep p))
      |-  ^+  c
      ?~  p  c
      ?~  q  $(p ~, c [p c])
      ?:  =(i.q 0)
        $(c [~ [(slag (add len i.q) `(list _?>(?=(^ p) i.p))`p) c]], p ~)
      %=  $
        c  [(slag (add len i.q) `(list _?>(?=(^ p) i.p))`p) c]
        p  (scag i.q `(list _?>(?=(^ p) i.p))`p)
        q  t.q
      ==
    --
  ::  ++conform is responsible for transforming the list of tokens into an AST.
  ::
  ::  Input:   (list token)  ATL AST
  ::  Output:  +$tree        ATL AST
  ++  conform  !!
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
::  Budd1987 p. 19
::
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
::
::  Parser tokens and AST adjuncts
++  commands
  ^~
  ^-  (list cord)
  :~  ')SAVE'
      ')OFF'
      '⎕IO'
      ')VARS'
      '⍝'
      '←'
      '∇'
  ==
++  functions
  ^~
  ^-  (list cord)
  :~  ::  Monadic functions
      '?'
      '⌈'
      '⌊'
      '⍴'
      '∼'
      '∣'
      '⍳'
      '⋆'
      '−'
      '+'
      '×'
      '÷'
      ','
      '⌹'
      '○'
      '⍟'
      '⌽'
      '⊖'
      '⍋'
      '⍒'
      '⍎'
      '⍕'
      '⍉'
      '!'
      '≡'
      '⍪'
      ::  Dyadic functions
      '+'
      '−'
      '×'
      '÷'
      '⋆'
      '○'
      '?'
      '∈'
      '⍷'
      '⌈'
      '⌊'
      '⍴'
      '↑'
      '↓'
      '⊥'
      '⊤'
      '∣'
      ','
      '\\'
      '/'
      '⍳'
      '⌹'
      '⌽'
      '⊖'
      '⍟'
      '⍕'
      '⍉'
      '!'
      '¨'
      '<'
      '≤'
      '='
      '≥'
      '>'
      '≠'
      '∨'
      '∧'
      '⍱'
      '⍲'
      '⊣'
      '⊢'
      '≡'
      '⍪'
  ==
++  operators
  ^~
  ^-  (list cord)
  :~  '+/'
      '+⌿'
      '+\\'
      '+⍀'
      '+.×'
      '∘.×'
  ==
--

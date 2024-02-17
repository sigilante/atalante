  ::  /sur/atalante
::::
::
/-  *lagoon
|%
+$  cultivar
  ^~
  $?  ::  Monadic functions
      %roll       :: ?B
      %ceiling    :: ⌈B
      %floor      :: ⌊B
      %shape      :: ⍴B
      %not        :: ∼B
      %abs        :: ∣B
      %index      :: ⍳B
      %exp        :: ⋆B
      %neg        :: −B
      %conj       :: +B
      %sgn        :: ×B
      %rec        :: ÷B
      %ravel      :: ,B
      %invert     :: ⌹B
      %pi-times   :: ○B
      %log        :: ⍟B
      %rev-last   :: ⌽B
      %rev-first  :: ⊖B
      %grade-up   :: ⍋B
      %grade-down :: ⍒B
      %execute    :: ⍎B
      %char       :: ⍕B
      %trans      :: ⍉B
      %fact       :: !B
      %depth      :: ≡B
      %table      :: ⍪B
      ::  Dyadic functions
      %add        :: A+B
      %sub        :: A−B
      %mul        :: A×B
      %div        :: A÷B
      %pow        :: A⋆B
      %circle     :: A○B
      %deal       :: A?B
      %in         :: A∈B
      %find       :: A⍷B
      %max        :: A⌈B
      %min        :: A⌊B
      %reshape    :: A⍴B
      %take       :: A↑B
      %drop       :: A↓B
      %decode     :: A⊥B
      %encode     :: A⊤B
      %mod        :: A∣B
      %cat        :: A,B
      %expand     :: A\B
      %compress   :: A/B
      %index-of   :: A⍳B
      %matdiv     :: A⌹B
      %rotate     :: A⌽B
      %rotate-first :: A⊖B
      %log-base   :: A⍟B
      %format     :: A⍕B
      %transpose-all :: A⍉B
      %comb       :: A!B
      %over-each  :: A¨B
      %lt         :: A<B
      %le         :: A≤B
      %eq         :: A=B
      %ge         :: A≥B
      %gt         :: A>B
      %ne         :: A≠B
      %or         :: A∨B
      %and        :: A∧B
      %nor        :: A⍱B
      %nand       :: A⍲B
      %left       :: A⊣B
      %right      :: A⊢B
      %is         :: A≡B
      %lam        :: A⍪B
      ::  Operators and axis indicators
      %assign       :: ←
      %separate     :: ⋄
      %reduce-last  :: +/B
      %reduce-first :: +⌿B
      %scan-last    :: +\B
      %scan-first   :: +⍀B
      %inner        :: A+.×B
      %outer        :: A∘.×B
      %func         :: ∇
  ==
++  symbol-map
  ^~
  ^-  (map @t cultivar)
  %-  malt
  ^-  (list (pair @t cultivar))
  :~  ::  Monadic operators
      :-  '?'  %roll
      :-  '⌈'  %ceiling
      :-  '⌊'  %floor
      :-  '⍴'  %shape
      :-  '∼'  %not
      :-  '∣'  %abs
      :-  '⍳'  %index
      :-  '⋆'  %exp
      :-  '−'  %neg
      :-  '+'  %conj
      :-  '×'  %sgn
      :-  '÷'  %rec
      :-  ','  %ravel
      :-  '⌹'  %invert
      :-  '○'  %pi-times
      :-  '⍟'  %log
      :-  '⌽'  %rev-last
      :-  '⊖'  %rev-first
      :-  '⍋'  %grade-up
      :-  '⍒'  %grade-down
      :-  '⍎'  %execute
      :-  '⍕'  %char
      :-  '⍉'  %trans
      :-  '!'  %fact
      :-  '≡'  %depth
      :-  '⍪'  %table
      ::  Dyadic operators
      :-  '+'  %add
      :-  '−'  %sub
      :-  '×'  %mul
      :-  '÷'  %div
      :-  '⋆'  %pow
      :-  '○'  %circle
      :-  '?'  %deal
      :-  '∈'  %in
      :-  '⍷'  %find
      :-  '⌈'  %max
      :-  '⌊'  %min
      :-  '⍴'  %reshape
      :-  '↑'  %take
      :-  '↓'  %drop
      :-  '⊥'  %decode
      :-  '⊤'  %encode
      :-  '∣'  %mod
      :-  ','  %cat
      :-  '\\'  %expand
      :-  '/'  %compress
      :-  '⍳'  %index-of
      :-  '⌹'  %matdiv
      :-  '⌽'  %rotate
      :-  '⊖'  %rotate-first
      :-  '⍟'  %log-base
      :-  '⍕'  %format
      :-  '⍉'  %transpose-all
      :-  '!'  %comb
      :-  '¨'  %over-each
      :-  '<'  %lt
      :-  '≤'  %le
      :-  '='  %eq
      :-  '≥'  %ge
      :-  '>'  %gt
      :-  '≠'  %ne
      :-  '∨'  %or
      :-  '∧'  %and
      :-  '⍱'  %nor
      :-  '⍲'  %nand
      :-  '⊣'  %left
      :-  '⊢'  %right
      :-  '≡'  %is
      :-  '⍪'  %lam
      ::  Operators and axis indicators
      :-  '+/'  %reduce-last
      :-  '+⌿'  %reduce-first
      :-  '+\\'  %scan-last
      :-  '+⍀'  %scan-first
      :-  '+.×'  %inner
      :-  '∘.×'  %outer
      ::  Function definitions
      :-  '∇'  %func
      :-  '←'   %assign
  ==
::  TODO  https://archive.is/jPzq
++  ascii-map
  ^~
  ^-  (map @t @t)
  %-  malt
  ^-  (list (pair @t @t))
  :~  ::  Monadic operators
      :-  '?'   '?'
      :-  '|^'  '⌈'
      :-  '|_'  '⌊'
      :-  '@r'  '⍴'
      :-  '~'   '∼'
      :-  '|'   '∣'
      :-  '@i'   '⍳'
      :-  '.'   '⋆'
      :-  '-'   '−'
      :: :-  '+'   '+'
      :-  'x'   '×'
      :-  ':-'  '÷'
      :-  '-:'  '÷'
      :: :-  ','   ','
      :-  ':8'  '⌹'
      :-  '8:'  '⌹'
      :-  'o'   '○'
      :-  'o*'  '⍟'
      :-  '*o'  '⍟'
      :-  'o|'  '⌽'
      :-  '|o'  '⌽'
      :-  'o-'  '⊖'
      :-  '-o'  '⊖'
      :-  '^|_'  '⍋'
      :-  '_|_'  '⍒'
      :-  'o|_'  '⍎'
      :-  'o|^'  '⍕'
      :-  'o\\'  '⍉'
      :-  '\o'  '⍉'
      :: :-  '!'  '!'
      :-  '-='  '≡'
      :-  '=-'  '≡'
      :-  ',-'  '⍪'
      :-  '-,'  '⍪'
      ::  Dyadic operators
      :: :-  '+'   '+'
      :-  '-'   '−'
      :-  'x'   '×'
      :-  '-:'  '÷'
      :-  ':-'  '÷'
      :-  '⋆'  %pow
      :-  '○'  %circle
      :-  '?'  %deal
      :-  '∈'  %in
      :-  '⍷'  %find
      :-  '⌈'  %max
      :-  '⌊'  %min
      :-  '⍴'  %reshape
      :-  '↑'  %take
      :-  '↓'  %drop
      :-  '⊥'  %decode
      :-  '⊤'  %encode
      :-  '∣'  %mod
      :-  ','  %cat
      :-  '\\'  %expand
      :-  '/'  %compress
      :-  '⍳'  %index-of
      :-  '⌹'  %matdiv
      :-  '⌽'  %rotate
      :-  '⊖'  %rotate-first
      :-  '⍟'  %log-base
      :-  '⍕'  %format
      :-  '⍉'  %transpose-all
      :-  '!'  %comb
      :-  '¨'  %over-each
      :-  '<'  %lt
      :-  '≤'  %le
      :-  '='  %eq
      :-  '≥'  %ge
      :-  '>'  %gt
      :-  '≠'  %ne
      :-  '∨'  %or
      :-  '∧'  %and
      :-  '⍱'  %nor
      :-  '⍲'  %nand
      :-  '⊣'  %left
      :-  '⊢'  %right
      :-  '≡'  %is
      :-  '⍪'  %lam
      ::  Operators and axis indicators
      :-  '+/'  %reduce-last
      :-  '+⌿'  %reduce-first
      :-  '+\\'  %scan-last
      :-  '+⍀'  %scan-first
      :-  '+.×'  %inner
      :-  '∘.×'  %outer
      ::  Function definitions
      :-  '∇'  %func
      :-  '←'   %assign
  ==
::  APL AST
::
::  The AST ultimately bottoms out in one of 
+$  apple-tree
  $%  [%empty ~]
      [%error ~]
      [%value p=apple]
      [%fruit p=apple]
      ::  Monadic functions
      [%roll p=apple-tree]
      [%ceiling p=apple-tree]
      [%floor p=apple-tree]
      [%shape p=apple-tree]
      [%not p=apple-tree]
      [%abs p=apple-tree]
      [%index p=apple-tree]
      [%exp p=apple-tree]
      [%neg p=apple-tree]
      [%conj p=apple-tree]
      [%sgn p=apple-tree]
      [%rec p=apple-tree]
      [%ravel p=apple-tree]
      [%invert p=apple-tree]
      [%pi-times p=apple-tree]
      [%log p=apple-tree]
      [%rev-last p=apple-tree]
      [%rev-first p=apple-tree]
      [%grade-up p=apple-tree]
      [%grade-down p=apple-tree]
      [%execute p=apple-tree]
      [%char p=apple-tree]
      [%trans p=apple-tree]
      [%fact p=apple-tree]
      [%depth p=apple-tree]
      [%table p=apple-tree]
      ::  Dyadic functions
      [%add p=apple-tree q=apple-tree]
      [%sub p=apple-tree q=apple-tree]
      [%mul p=apple-tree q=apple-tree]
      [%div p=apple-tree q=apple-tree]
      [%pow p=apple-tree q=apple-tree]
      [%circle p=apple-tree q=apple-tree]
      [%deal p=apple-tree q=apple-tree]
      [%in p=apple-tree q=apple-tree]
      [%find p=apple-tree q=apple-tree]
      [%max p=apple-tree q=apple-tree]
      [%min p=apple-tree q=apple-tree]
      [%reshape p=apple-tree q=apple-tree]
      [%take p=apple-tree q=apple-tree]
      [%drop p=apple-tree q=apple-tree]
      [%decode p=apple-tree q=apple-tree]
      [%encode p=apple-tree q=apple-tree]
      [%mod p=apple-tree q=apple-tree]
      [%cat p=apple-tree q=apple-tree]
      [%expand p=apple-tree q=apple-tree]
      [%compress p=apple-tree q=apple-tree]
      [%index-of p=apple-tree q=apple-tree]
      [%matdiv p=apple-tree q=apple-tree]
      [%rotate p=apple-tree q=apple-tree]
      [%rotate-first p=apple-tree q=apple-tree]
      [%log-base p=apple-tree q=apple-tree]
      [%format p=apple-tree q=apple-tree]
      [%transpose-all p=apple-tree q=apple-tree]
      [%comb p=apple-tree q=apple-tree]
      [%over-each p=apple-tree q=apple-tree]
      [%lt p=apple-tree q=apple-tree]
      [%le p=apple-tree q=apple-tree]
      [%eq p=apple-tree q=apple-tree]
      [%ge p=apple-tree q=apple-tree]
      [%gt p=apple-tree q=apple-tree]
      [%ne p=apple-tree q=apple-tree]
      [%or p=apple-tree q=apple-tree]
      [%and p=apple-tree q=apple-tree]
      [%nor p=apple-tree q=apple-tree]
      [%nand p=apple-tree q=apple-tree]
      [%left p=apple-tree q=apple-tree]
      [%right p=apple-tree q=apple-tree]
      [%is p=apple-tree q=apple-tree]
      [%lam p=apple-tree q=apple-tree]
      ::  Operators and axis indicators
      [%reduce-last p=apple-tree q=apple-tree]
      [%reduce-first p=apple-tree q=apple-tree]
      [%scan-last p=apple-tree q=apple-tree]
      [%scan-first p=apple-tree q=apple-tree]
      [%inner p=apple-tree q=apple-tree]
      [%outer p=apple-tree q=apple-tree]
      ::  Function definitions
      [%func p=apple-tree q=apple-tree r=apple-tree]
  ==
::  Symbol table
::    +$apple is a numeric value, nominally compatible with Lagoon but also
::    supporting characters and strings in the same interface.
::    ATL/APL needs to support inference, so there are some supertypes here.
::    ATL/APL distinguishes scalars from vectors for algorithmic efficiency.
+$  apple                    ::  +$apple: ATL type
  $?  ::  Vector number types
      [%real p=ray]          ::  IEEE 754 float
      [%uint p=ray]          ::  unsigned integer
      [%int2 p=ray]          ::  2s-complement integer
      [%cplx p=ray]          ::  BLAS-compatible packed floats
      [%unum p=ray]          ::  unum/posit
      [%fixp p=ray]          ::  fixed-precision
      ::  Scalar number types
      [%sreal p=@]           ::  IEEE 754 float
      [%suint p=@]           ::  unsigned integer
      [%sint2 p=@]           ::  2s-complement integer
      [%scplx p=@]           ::  BLAS-compatible packed floats
      [%sunum p=@]           ::  unum/posit
      [%sfixp p=@]           ::  fixed-precision
      ::  Compiler types
      [%any p=*]             ::  value prior to inference
      [%num p=*]             ::  number of some kind (Lagoon type)
      [%arr p=*]             ::  array (scalar or vector)
      ::  Other types
      [%bool p=?(%true %false)]  ::  boolean
      [%text p=@t]           ::  character string
  ==
::    +$leaf is a string.
+$  leaf  @t
+$  symbol-table  (map @t cultivar)
::  Executable Nock noun (evaluated with Nock 2 .*) and type.
+$  apple-pie  vase
::
+$  action
  $%  [%rise ~]
  ==
+$  update
  $%  [%risen values=(list @)]
  ==
--

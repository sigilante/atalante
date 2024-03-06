  ::  /sur/atl
::::  Atalante types
::
|%
+$  tree
  $%  [%fork =form branches=(list tree)]
      [%leaf name=@t branches=(list tree)]
      [%pome =pome]
      [%leaf name=@t]
  ==
::
+$  form
  $?  :: %add  %sub  %mul  %div  %pow
      :: %mod  %log-base   %circle
      :: %or   %and  %nor  %nand
      :: %comb       %ceiling    %floor
      :: %gt   %ge   %lt   %le
      :: %eq   %ne
      %assign
  ==
+$  trait  ?(%int %real)
+$  pome
  $%  [%empty ~]
      [%scalar =trait fruit=@]
      [%array =trait branches=(list pome)]
      [%string fruit=@t]
      [%bool fruit=?]
  ==
::  Primary variable store
::
+$  bushel  (map @t pome)
::  Lagoon-compatible store
::
:: +$  cider   (map @t ray)
::
::  Atalante commands
::
:: +$  formula
--

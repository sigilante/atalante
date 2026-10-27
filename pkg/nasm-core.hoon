::  pkg/nasm-core.hoon:  Nockasm as a Jock %nock library --- the vendored
::  reference expander and renderer (Jock's lib/nockasm, sigilante/nockasm
::  @ 6b3d812, IR v3), so an emitter written in Jock builds a $nasm noun
::  and lowers it to Nock here.  Pass-throughs only.  Battery order =
::  msig order;  new arms at the END.
::
::  The arguments cross as NOUNS (Jock's Nasm and Sema enums erase to
::  the $nasm and $sema cell layouts;  the clams here are the check).
/-  typ
/+  jf=jock
/+  nasm=nockasm
=/  jck  ~(. jf [~ %.n ~ ~])
::  `let` is a Jock keyword, so the Jock-side IR spells the #let node
::  %bind;  +fix rewrites that tag to %let along the IR's own structure
::  (never inside a %nock payload)
=/  fix
  |=  n=*
  ^-  *
  |^  (one n)
  ++  one
    |=  n=*
    ^-  *
    ?@  n  n
    ?+    -.n  n
        %bind  ?.(?=([@ * * *] n) n [%let +<.n (one +>-.n) (one +>+.n)])
        %let   ?.(?=([@ * * *] n) n [%let +<.n (one +>-.n) (one +>+.n)])
        %op    ?.(?=([@ @ *] n) n [%op +<.n (all +>.n)])
        %cell  [%cell (all +.n)]
    ==
  ++  all
    |=  l=*
    ^-  *
    ?@  l  l
    [(one -.l) $(l +.l)]
  --
=/  wlower   |=([s=* a=*] ^-(* (lower:nasm ;;((unit sema:nasm) s) ;;(nasm:nasm (fix a)))))
=/  wrender  |=([s=* a=*] ^-(@t (render:nasm ;;((unit sema:nasm) s) ;;(nasm:nasm (fix a)))))
=/  wparse   |=(t=@t ^-(* (parse:nasm t)))
=/  tnoun=typ:typ  [%noun ~]
=/  tstr=typ:typ   [%ref 'String' ~]
=/  g2   |=([a=typ:typ b=typ:typ r=typ:typ] ^-(typ:typ [%gate [%cell [%face 'a' a] [%face 'b' b]] r]))
=/  arms=(list msig:typ)
  :~  ['lower' [~ (g2 tnoun tnoun tnoun)]]
      ['render' [~ (g2 tnoun tnoun tstr)]]
      ['parse' [~ [%gate [%face 'a' tstr] tnoun]]]
  ==
:*  ^-  hvase:typ
    :-  %noun
    %-  habi:jck
    ^-  (list *)
    ~[wlower wrender wparse]
  arms
  `(map cord typedef:typ)`~
  `(list impy:typ)`~
  `(map @t [tr=cord mt=cord])`~
  `(unit *)`~
==

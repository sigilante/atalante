::  pkg/lagoon-core.hoon:  the Lagoon package --- Atalante's array
::  substrate as a Jock %nock library (docs/plan.md P3; Jock
::  docs/imports.md "what a package is").  Built by tools/pkg.sh
::  against the Jock compiler tree with vendor/numerics beside it.
::
::  Battery order = gate-list order = msig order (the ABI rule).  New
::  arms go at the END.  Every wrapper is a PASS-THROUGH into the
::  vendored Lagoon door (rounding pinned %n), the hoon-138 rd door
::  (rounding pinned %n), /lib/math's rd door, or /lib/twoc at 64 bits;
::  no arithmetic happens in this file.
::
::  Types the package declares for Jock:  Meta and Ray, two structs
::  whose erasure IS Lagoon's $meta and $ray cell layout, so a ray
::  crosses the boundary untouched and Jock reads r.meta.shape.
/-  typ
/-  lagoon
/+  jf=jock
/+  lag=lagoon
/+  math
/+  twoc
=/  jck   ~(. jf [~ %.n ~ ~])
=/  la    ~(. la:lag %n)
=/  rdm   ~(. rd:math [%n .~1e-10 .~0])
::  --- rays:  construction and reading
=/  wfill    |=([m=meta:lagoon x=@] ^-(ray:lagoon (fill:la m x)))
=/  wfrom    |=([m=meta:lagoon v=(list @)] ^-(ray:lagoon (spac:la [m (rep bloq.m v)])))
=/  wravel   |=(a=ray:lagoon ^-((list @) (ravel:la a)))
=/  wgetitem  |=([a=ray:lagoon d=(list @)] ^-(@ (get-item:la a d)))
::  --- rays:  elementwise, same meta both sides (Lagoon asserts it).  The
::  comparisons are not exported:  +bin-op walks the ravel with +snag
::  (quadratic, S-22), and a Jock zip over the ravel is exact and linear.
=/  wadd     |=([a=ray:lagoon b=ray:lagoon] ^-(ray:lagoon (add:la a b)))
=/  wsub     |=([a=ray:lagoon b=ray:lagoon] ^-(ray:lagoon (sub:la a b)))
=/  wmul     |=([a=ray:lagoon b=ray:lagoon] ^-(ray:lagoon (mul:la a b)))
=/  wabs     |=(a=ray:lagoon ^-(ray:lagoon (abs:la a)))
=/  wchange  |=([a=ray:lagoon k=kind:lagoon b=@] ^-(ray:lagoon (change:la a k b)))
::  --- rays:  structure (P7's specialised gates reach these).  The reductions
::  (cumsum, max, min) and dot/mmul are not exported:  measured at ~1.6 ms per
::  element through +reel under NockVM against ~10 µs for a Jock fold with
::  jetted arithmetic (S-22), and set-item is a rebuild per element.
::  Not exported, because no ATL path can use them bit-exactly:  div (APL's
::  0÷0), mod (APL's sign rule), pow-n (repeated multiplication rounds
::  differently from exp(b·log a)), prod (its fold starts from the integer
::  1, which as @rd bits is a denormal --- wrong for floats; S-21).
=/  wiota    |=(m=meta:lagoon ^-(ray:lagoon (iota:la m)))
=/  wreshape  |=([a=ray:lagoon s=(list @)] ^-(ray:lagoon (reshape:la a s)))
=/  wtranspose  |=(a=ray:lagoon ^-(ray:lagoon (transpose:la a)))
::  --- scalars:  the hoon-138 rd door, rounding %n
=/  wrsun    |=(a=@ ^-(@rd (~(sun rd %n) a)))
=/  wrsan    |=(a=@s ^-(@rd (~(san rd %n) a)))
=/  wrtoi    |=(a=@rd ^-((unit @s) (~(toi rd %n) a)))
=/  wrsqt    |=(a=@rd ^-(@rd (~(sqt rd %n) a)))
=/  wrdrg
  |=  a=@rd
  ^-  [s=? e=@s a=@u]
  =/  d  (~(drg rd %n) a)
  ?>  ?=(%d -.d)
  [s.d e.d a.d]
::  --- scalars:  /lib/math's rd door
=/  wrexp    |=(a=@rd ^-(@rd (exp:rdm a)))
=/  wrlog    |=(a=@rd ^-(@rd (log:rdm a)))
=/  wrpow    |=([a=@rd b=@rd] ^-(@rd (pow:rdm a b)))
=/  wrsin    |=(a=@rd ^-(@rd (sin:rdm a)))
=/  wrcos    |=(a=@rd ^-(@rd (cos:rdm a)))
=/  wrtan    |=(a=@rd ^-(@rd (tan:rdm a)))
=/  wrasin   |=(a=@rd ^-(@rd (asin:rdm a)))
=/  wracos   |=(a=@rd ^-(@rd (acos:rdm a)))
=/  wratan   |=(a=@rd ^-(@rd (atan:rdm a)))
=/  wrpi     |=(* ^-(@rd pi:rdm))
=/  wrfact   |=(a=@rd ^-(@rd (factorial:rdm a)))
::  --- scalars:  two's complement at 64 bits (bloq 6)
=/  wtneg    |=(a=@ ^-(@ (~(neg twoc:twoc 6) a)))
=/  wtabs    |=(a=@ ^-(@ (~(abs twoc:twoc 6) a)))
=/  wtmsb    |=(a=@ ^-(@ (~(msb twoc:twoc 6) a)))
::  --- appended 2026-10-27 (new arms go at the END):  floor and ceiling
::  as the rd door's toi under %d and %u, and twoc's @s conversions
=/  wrflo    |=(a=@rd ^-((unit @s) (~(toi rd %d) a)))
=/  wrcei    |=(a=@rd ^-((unit @s) (~(toi rd %u) a)))
=/  wts2t    |=(a=@s ^-(@ (~(s-to-twoc twoc:twoc 6) a)))
=/  wtt2s    |=(a=@ ^-(@s (~(twoc-to-s twoc:twoc 6) a)))
::  --- signatures
=/  tatom=typ:typ  [%atom %$ ~]
=/  tnoun=typ:typ  [%noun ~]
=/  tre=typ:typ    [%atom %real ~]
=/  tsi=typ:typ    [%atom %sint ~]
=/  ttas=typ:typ   [%atom %tas ~]
=/  tbool=typ:typ  [%atom %logical [~ [%loob ~]]]
=/  tlist=typ:typ  [%ref 'List' ~[tatom]]
=/  tmeta=typ:typ  [%ref 'Meta' ~]
=/  tray=typ:typ   [%ref 'Ray' ~]
::  signed values cross the boundary as BARE atoms (their ZigZag bits):
::  nothing casts into Jock's Int (L-127), so Jock decodes by parity.
=/  tosi=typ:typ   [%or ~[[%sing %n 0] [%cell [%sing %n 0] tatom]]]
=/  g1   |=([a=typ:typ r=typ:typ] ^-(typ:typ [%gate [%face 'a' a] r]))
=/  g2   |=([a=typ:typ b=typ:typ r=typ:typ] ^-(typ:typ [%gate [%cell [%face 'a' a] [%face 'b' b]] r]))
=/  g3   |=([a=typ:typ b=typ:typ c=typ:typ r=typ:typ] ^-(typ:typ [%gate [%cell [%face 'a' a] [%cell [%face 'b' b] [%face 'c' c]]] r]))
=/  rr   (g2 tray tray tray)
=/  r1   (g1 tray tray)
=/  arms=(list msig:typ)
  :~  ['fill' [~ (g2 tmeta tatom tray)]]
      ['from' [~ (g2 tmeta tlist tray)]]
      ['ravel' [~ (g1 tray tlist)]]
      ['getitem' [~ (g2 tray tlist tatom)]]
      ['add' [~ rr]]  ['sub' [~ rr]]  ['mul' [~ rr]]
      ['abs' [~ r1]]
      ['change' [~ (g3 tray ttas tatom tray)]]
      ['iota' [~ (g1 tmeta tray)]]
      ['reshape' [~ (g2 tray tlist tray)]]
      ['transpose' [~ r1]]
      ['rsun' [~ (g1 tatom tre)]]
      ['rsan' [~ (g1 tatom tre)]]
      ['rtoi' [~ (g1 tre tosi)]]
      ['rsqt' [~ (g1 tre tre)]]
      ['rdrg' [~ (g1 tre [%cell tbool [%cell tatom tatom]])]]
      ['rexp' [~ (g1 tre tre)]]  ['rlog' [~ (g1 tre tre)]]
      ['rpow' [~ (g2 tre tre tre)]]
      ['rsin' [~ (g1 tre tre)]]  ['rcos' [~ (g1 tre tre)]]  ['rtan' [~ (g1 tre tre)]]
      ['rasin' [~ (g1 tre tre)]]  ['racos' [~ (g1 tre tre)]]  ['ratan' [~ (g1 tre tre)]]
      ['rpi' [~ (g1 tnoun tre)]]
      ['rfact' [~ (g1 tre tre)]]
      ['tneg' [~ (g1 tatom tatom)]]
      ['tabs' [~ (g1 tatom tatom)]]
      ['tmsb' [~ (g1 tatom tatom)]]
      ['rflo' [~ (g1 tre tosi)]]
      ['rcei' [~ (g1 tre tosi)]]
      ['ts2t' [~ (g1 tatom tatom)]]
      ['tt2s' [~ (g1 tatom tatom)]]
  ==
=/  metatd=typedef:typ
  [~ [%struct ~[['shape' tlist] ['bloq' tatom] ['kind' ttas] ['tail' tnoun]]]]
=/  raytd=typedef:typ
  [~ [%struct ~[['meta' tmeta] ['data' tatom]]]]
=/  tys=(map cord typedef:typ)
  (malt ~[['Meta' metatd] ['Ray' raytd]])
:*  ^-  hvase:typ
    :-  %noun
    %-  habi:jck
    ^-  (list *)
    :~  wfill  wfrom  wravel  wgetitem
        wadd  wsub  wmul
        wabs  wchange
        wiota  wreshape  wtranspose
        wrsun  wrsan  wrtoi  wrsqt  wrdrg
        wrexp  wrlog  wrpow  wrsin  wrcos  wrtan  wrasin  wracos  wratan  wrpi  wrfact
        wtneg  wtabs  wtmsb
        wrflo  wrcei  wts2t  wtt2s
    ==
  arms
  tys
  `(list impy:typ)`~
  `(map @t [tr=cord mt=cord])`~
  `(unit *)`~
==

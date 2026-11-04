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
::  comparisons are not exported:  a Jock zip over the ravel is exact and
::  linear (+bin-op was quadratic before numerics #94, S-22).
=/  wadd     |=([a=ray:lagoon b=ray:lagoon] ^-(ray:lagoon (add:la a b)))
=/  wsub     |=([a=ray:lagoon b=ray:lagoon] ^-(ray:lagoon (sub:la a b)))
=/  wmul     |=([a=ray:lagoon b=ray:lagoon] ^-(ray:lagoon (mul:la a b)))
=/  wabs     |=(a=ray:lagoon ^-(ray:lagoon (abs:la a)))
=/  wchange  |=([a=ray:lagoon k=kind:lagoon b=@] ^-(ray:lagoon (change:la a k b)))
::  --- rays:  structure (P7's specialised gates reach these).  The reductions
::  (cumsum, max, min) and dot/mmul are not exported:  measured at ~1.6 ms per
::  element through +reel under a NockVM without float jets against ~10 µs for
::  a Jock fold with jetted arithmetic (S-22, closed upstream by numerics #94),
::  and set-item is a rebuild per element.
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
::  --- appended 2026-11-04 (P12, D-15):  the float doors by width.  w is the bloq:
::  4 half (rh), 5 single (rs), 6 double (rd), 7 quad (rq).  Values cross as bare
::  atoms, clammed to the door's aura inside; rounding pinned %n as above.  The
::  transcendentals come from /lib/math's door of the same width at its default
::  sample, which for rd is the rdm the arms above use.
=/  rsm  rs:math
=/  rhm  rh:math
=/  rqm  rq:math
::  o: 1 add  2 sub  3 mul  4 div
=/  wfop
  |=  [w=@ o=@ a=@ b=@]
  ^-  @
  ?+    w  !!
      %4
    ?+  o  !!
      %1  (~(add rh %n) (@rh a) (@rh b))
      %2  (~(sub rh %n) (@rh a) (@rh b))
      %3  (~(mul rh %n) (@rh a) (@rh b))
      %4  (~(div rh %n) (@rh a) (@rh b))
    ==
      %5
    ?+  o  !!
      %1  (~(add rs %n) (@rs a) (@rs b))
      %2  (~(sub rs %n) (@rs a) (@rs b))
      %3  (~(mul rs %n) (@rs a) (@rs b))
      %4  (~(div rs %n) (@rs a) (@rs b))
    ==
      %6
    ?+  o  !!
      %1  (~(add rd %n) (@rd a) (@rd b))
      %2  (~(sub rd %n) (@rd a) (@rd b))
      %3  (~(mul rd %n) (@rd a) (@rd b))
      %4  (~(div rd %n) (@rd a) (@rd b))
    ==
      %7
    ?+  o  !!
      %1  (~(add rq %n) (@rq a) (@rq b))
      %2  (~(sub rq %n) (@rq a) (@rq b))
      %3  (~(mul rq %n) (@rq a) (@rq b))
      %4  (~(div rq %n) (@rq a) (@rq b))
    ==
  ==
::  o: 1 lth  2 lte  3 gth  4 gte
=/  wfcmp
  |=  [w=@ o=@ a=@ b=@]
  ^-  ?
  ?+    w  !!
      %4
    ?+  o  !!
      %1  (~(lth rh %n) (@rh a) (@rh b))
      %2  (~(lte rh %n) (@rh a) (@rh b))
      %3  (~(gth rh %n) (@rh a) (@rh b))
      %4  (~(gte rh %n) (@rh a) (@rh b))
    ==
      %5
    ?+  o  !!
      %1  (~(lth rs %n) (@rs a) (@rs b))
      %2  (~(lte rs %n) (@rs a) (@rs b))
      %3  (~(gth rs %n) (@rs a) (@rs b))
      %4  (~(gte rs %n) (@rs a) (@rs b))
    ==
      %6
    ?+  o  !!
      %1  (~(lth rd %n) (@rd a) (@rd b))
      %2  (~(lte rd %n) (@rd a) (@rd b))
      %3  (~(gth rd %n) (@rd a) (@rd b))
      %4  (~(gte rd %n) (@rd a) (@rd b))
    ==
      %7
    ?+  o  !!
      %1  (~(lth rq %n) (@rq a) (@rq b))
      %2  (~(lte rq %n) (@rq a) (@rq b))
      %3  (~(gth rq %n) (@rq a) (@rq b))
      %4  (~(gte rq %n) (@rq a) (@rq b))
    ==
  ==
::  o: 1 sqt (the hoon-138 door)  2 exp  3 log  4 sin  5 cos  6 tan  7 asin  8 acos  9 atan  10 factorial
=/  wfun
  |=  [w=@ o=@ a=@]
  ^-  @
  ?+    w  !!
      %4
    ?+  o  !!
      %1  (~(sqt rh %n) (@rh a))
      %2  (exp:rhm (@rh a))
      %3  (log:rhm (@rh a))
      %4  (sin:rhm (@rh a))
      %5  (cos:rhm (@rh a))
      %6  (tan:rhm (@rh a))
      %7  (asin:rhm (@rh a))
      %8  (acos:rhm (@rh a))
      %9  (atan:rhm (@rh a))
      %10  (factorial:rhm (@rh a))
    ==
      %5
    ?+  o  !!
      %1  (~(sqt rs %n) (@rs a))
      %2  (exp:rsm (@rs a))
      %3  (log:rsm (@rs a))
      %4  (sin:rsm (@rs a))
      %5  (cos:rsm (@rs a))
      %6  (tan:rsm (@rs a))
      %7  (asin:rsm (@rs a))
      %8  (acos:rsm (@rs a))
      %9  (atan:rsm (@rs a))
      %10  (factorial:rsm (@rs a))
    ==
      %6
    ?+  o  !!
      %1  (~(sqt rd %n) (@rd a))
      %2  (exp:rdm (@rd a))
      %3  (log:rdm (@rd a))
      %4  (sin:rdm (@rd a))
      %5  (cos:rdm (@rd a))
      %6  (tan:rdm (@rd a))
      %7  (asin:rdm (@rd a))
      %8  (acos:rdm (@rd a))
      %9  (atan:rdm (@rd a))
      %10  (factorial:rdm (@rd a))
    ==
      %7
    ?+  o  !!
      %1  (~(sqt rq %n) (@rq a))
      %2  (exp:rqm (@rq a))
      %3  (log:rqm (@rq a))
      %4  (sin:rqm (@rq a))
      %5  (cos:rqm (@rq a))
      %6  (tan:rqm (@rq a))
      %7  (asin:rqm (@rq a))
      %8  (acos:rqm (@rq a))
      %9  (atan:rqm (@rq a))
      %10  (factorial:rqm (@rq a))
    ==
  ==
=/  wfpow
  |=  [w=@ a=@ b=@]
  ^-  @
  ?+  w  !!
    %4  (pow:rhm (@rh a) (@rh b))
    %5  (pow:rsm (@rs a) (@rs b))
    %6  (pow:rdm (@rd a) (@rd b))
    %7  (pow:rqm (@rq a) (@rq b))
  ==
=/  wfpi
  |=  w=@
  ^-  @
  ?+  w  !!
    %4  pi:rhm
    %5  pi:rsm
    %6  pi:rdm
    %7  pi:rqm
  ==
=/  wfsun
  |=  [w=@ a=@]
  ^-  @
  ?+  w  !!
    %4  (~(sun rh %n) a)
    %5  (~(sun rs %n) a)
    %6  (~(sun rd %n) a)
    %7  (~(sun rq %n) a)
  ==
=/  wfsan
  |=  [w=@ a=@s]
  ^-  @
  ?+  w  !!
    %4  (~(san rh %n) a)
    %5  (~(san rs %n) a)
    %6  (~(san rd %n) a)
    %7  (~(san rq %n) a)
  ==
::  m: the rounding mode, %n %d %u or %z
=/  wftoi
  |=  [w=@ m=@ a=@]
  ^-  (unit @s)
  =/  r  ?+(m !! %n %n, %d %d, %u %u, %z %z)
  ?+  w  !!
    %4  (~(toi rh r) (@rh a))
    %5  (~(toi rs r) (@rs a))
    %6  (~(toi rd r) (@rd a))
    %7  (~(toi rq r) (@rq a))
  ==
=/  wfdrg
  |=  [w=@ a=@]
  ^-  [s=? e=@s a=@u]
  =/  d=dn  ?+(w !! %4 (~(drg rh %n) (@rh a)), %5 (~(drg rs %n) (@rs a)), %6 (~(drg rd %n) (@rd a)), %7 (~(drg rq %n) (@rq a)))
  ?>  ?=(%d -.d)
  [s.d e.d a.d]
::  decimal to float, correctly rounded:  sign, exponent, mantissa (D-3, D-15)
=/  wfgrd
  |=  [w=@ s=? e=@s a=@u]
  ^-  @
  =/  d=dn  [%d s e a]
  ?+  w  !!
    %4  (~(grd rh %n) d)
    %5  (~(grd rs %n) d)
    %6  (~(grd rd %n) d)
    %7  (~(grd rq %n) d)
  ==
::  a real of width v to width w, rounded to nearest-even (exact when widening)
=/  wfconv
  |=  [v=@ w=@ a=@]
  ^-  @
  ?:  =(v w)  a
  =/  f=fn  ?+(v !! %4 (~(sea rh %n) (@rh a)), %5 (~(sea rs %n) (@rs a)), %6 (~(sea rd %n) (@rd a)), %7 (~(sea rq %n) (@rq a)))
  ?+  w  !!
    %4  (~(bit rh %n) f)
    %5  (~(bit rs %n) f)
    %6  (~(bit rd %n) f)
    %7  (~(bit rq %n) f)
  ==
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
=/  g4   |=([a=typ:typ b=typ:typ c=typ:typ d=typ:typ r=typ:typ] ^-(typ:typ [%gate [%cell [%face 'a' a] [%cell [%face 'b' b] [%cell [%face 'c' c] [%face 'd' d]]]] r]))
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
      ['fop' [~ (g4 tatom tatom tatom tatom tatom)]]
      ['fcmp' [~ (g4 tatom tatom tatom tatom tbool)]]
      ['fun' [~ (g3 tatom tatom tatom tatom)]]
      ['fpow' [~ (g3 tatom tatom tatom tatom)]]
      ['fpi' [~ (g1 tatom tatom)]]
      ['fsun' [~ (g2 tatom tatom tatom)]]
      ['fsan' [~ (g2 tatom tatom tatom)]]
      ['ftoi' [~ (g3 tatom tatom tatom tosi)]]
      ['fdrg' [~ (g2 tatom tatom [%cell tbool [%cell tatom tatom]])]]
      ['fgrd' [~ (g4 tatom tbool tatom tatom tatom)]]
      ['fconv' [~ (g3 tatom tatom tatom tatom)]]
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
        wfop  wfcmp  wfun  wfpow  wfpi  wfsun  wfsan  wftoi  wfdrg  wfgrd  wfconv
    ==
  arms
  tys
  `(list impy:typ)`~
  `(map @t [tr=cord mt=cord])`~
  `(unit *)`~
==

/-  atl
/+  atllib=atalante,
    default-agent,
    dbug,
    shoe,
    sole
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  %0
+$  card  card:agent:shoe
+$  command  @t
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
%-  (agent:shoe *)
^-  (shoe:shoe *)
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %|) bowl)
    leather  ~(. (default:shoe this *) bowl)
++  on-init   on-init:default
++  on-save   !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  `this(state !<(state-0 old))
++  on-poke   on-poke:default
++  on-peek   on-peek:default
++  on-arvo   on-arvo:default
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-agent  on-agent:default
++  on-fail   on-fail:default
++  command-parser
  |=  =sole-id:shoe
  ^+  |~(nail *(like [? *]))
  (stag | (cook * parse:parser:atllib))
  :: (stag | (cook tree:atl parse:parser:atllib))
++  on-command
  |=  [=sole-id:shoe tree=*]
  ^-  (quip card _this)
  ~&  >>>  tree
  :_  this
  ~
++  can-connect
  |=  =sole-id:shoe
  ^-  ?
  ?|  =(~zod src.bowl)
      (team:title [our src]:bowl)
  ==
++  on-connect     on-connect:leather
++  on-disconnect  on-disconnect:leather
++  tab-list       tab-list:leather
--


extensions [
  profiler
  sound
]

globals [
  cum-eggs
  cum-juveniles

  K_conv                ; -       ; Temperature conversion °C <-> K
  day-of-year
  hours-of-day
  start-plot
  location

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;        Environment parameters           ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  depthvalues
  widthvalues
  numdays
  temperature-data
  theta-data
  OM-data
  conc-data
  rho-data
  conc-pattern

  date-data
  date

  latitude
  photoperiod

  color-minT
  color-maxT
  color-minTh
  color-maxTh
  color-maxOM
  color-minOM
  color-maxBd
  color-minBd
  color-maxConc

  death-starvation
  death-ageing
  death-crowding
  death-predation
  death-dessication
  death-tox
  emigration

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;          Animal parameters              ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; DEB parameters
  F_m0                 ; g/d/cm^2 ; maximum specific searching rate
  kap_X                ; -        ; digestion efficiency of food to reserve
  HSK                  ; J/g      ; half-saturation constant based on pAm and Fm
  g                    ; -        ; energy investment ratio
  k_M0                 ; 1/d      ; somatic maintenance rate coefficient at reference temperature
  t_0                  ; d        ; dormancy of cocoon
  v0                   ; cm/d     ; energy conductance at reference temperature
  k_J0                 ; 1/d      ; maturity maint rate coefficient at reference temperature
  p_Am0                ; J/d*cm^2 ; surface-area specific maximum assimilation rate at reference temperature
  p_M0                 ; J/d*cm^3 ; vol-spec somatic maintenance rate at reference temperature
  h_a0                 ; d^-2     ; Weibull aging acceleration constant at reference temperature
  kap                  ; -        ; allocation fraction to soma
  E_G                  ; J/cm^3   ; spec cost for structure
  E_Hp                 ; J        ; maturity at puberty
  E_Hb                 ; J        ; maturity at birth
  kap_R0               ; -        ; reproduction efficiency
  L_0                  ; cm       ; structural length at birth
  L_i                  ; cm        ; ultimate length
  U_E0                 ;         ; scaled initial reserve (for f=1)
  E_0                  ; J        ; initial reserve at egg formation
  f-mat
  e_scal_mat           ; -        ; maternal scaled reserves tested
  E_0-mat              ; J        ; initial reserve at egg formation with maternal effect
  E0_f                 ; J        ; E0 at maternal scaled reserves
  L_b-f
  E_b                  ; J        ; initial reserve at birth
  del_M                ; -        ; shape coefficient
  d_V                  ; g/cm^3   ; specific density of structure
  w_E                  ; g/mol    ; mol-weights for (unhydrated) org. compounds: Reserve
  mu_E                 ; J/mol    ; chemical potential of reserve
  T_A                  ; K        ; Arrhenius temperature
  T_H                  ; K        ; Upper boundary temperature
  T_AH                 ; K        ; Arrhenius temperature for the rate of decrease at upper boundary
  T_ref                ; K        ; Reference temperature = 20°C
  s_g                  ; -        ; Gompertz aging stress coefficient

  ; DEB-move parameters
  b_diapause           ; 1/%      ; distribution width for diapause
  m_0                  ; %        ; moisture threshold for movement
  b_max                ; cm(soil) d−1 %−1 cm−2; Maximum moisture dependent specific movement rate
  k_b                  ; cm(soil) d−1 %−1 cm−2; Moisture-dependent specific movement rate

  ; biology + ecology
  u_OM                 ; Jg−1     ; organic matter-energy coupler
  ave_eggs             ; #        ; average number of juveniles per cocoon
  eco-type             ;          ; one of epigeic, endogeic or anecic
  undergoes-diapause   ;          ; true/false if species goes into diapause at low moistures
  cone-distance        ; cm       ; distance a worm can look ahead
  cone-angle           ; °        ; angle of vision
  cone-angle-litter    ; °        ; broader angle of vision for anecic worms in litter
  cone-angle-burrow    ; °        ; narrow angle of vision for anecic worms in burrow
  rate-desic           ; d^-1     ; desiccation rate applied at moistures < m0

  ; for worms with diapause (currently only endogeic species)
  min-days-diapause    ; d        ; minimal days the worm stays in diapause, for worms with quiescence only set to 0

  ; for anecic worms
  min-distance-between-burrows
  xcors-existing-burrows
  patches-burrow
  xcor-home
  dark

  ; Toxicity parameters
  ; toxicokinetics
  k_d_IT               ; mg/g/d   ; dominant rate constant IT
  k_d_SD               ; mg/g/d   ; dominant rate constant SD
  ; sublethal
  pMoA-feeding
  c01                  ; mg/g     ; tolerance conc pMoA feeding
  cT1                  ; mg/g     ; threshold conc pMoA feeding
  pMoA-somatic-maintenance
  c02                  ; mg/g     ; tolerance conc pMoA somatic maintenance
  cT2                  ; mg/g     ; threshold conc pMoA somatic maintenance
  pMoA-maturity-maintenance
  c03                  ; mg/g     ; tolerance conc pMoA maturity maintenance
  cT3                  ; mg/g     ; threshold conc pMoA maturity maintenance
  pMoA-cost-egg
  c04                  ; mg/g     ; tolerance conc pMoA egg cost
  cT4                  ; mg/g     ; threshold conc pMoA egg cost
  pMoA-hazard-oogenesis
  c05                  ; mg/g     ; tolerance conc pMoA oogenesis hazard
  cT5                  ; mg/g     ; threshold conc pMoA oogenesis hazard
  ; lethal
  m_w_IT               ; mg/g     ; median threshold IT (old: alpha)
  beta                 ;          ; slope factor IT
  h_b_IT               ; 1/d      ; background hazard rate IT
  m_w_SD               ; mg/g     ; threshold SD (old: z)
  b_w                  ; 1/d      ; killing rate SD (old: kk)
  h_b_SD               ; 1/d      ; background hazard rate SD

  ; for start with study info:
  ww-juv
  ww-adu
]

turtles-own [
  target-patches
  target-patch
  burrow-rate          ; cm/d     ; moisture + temperature dependent burrow rate
  moisture_list        ; %        ; moistures sensed from visited patches
  M                    ; %        ; mean moisture for diaupause and burrow-rate
  ;temperature_list     ; K        ; temperatures sensed from visited patches
  ;T                    ; K        ; mean temperature of visited patches
  TC_list              ; -        ; temperature corrections of visited patches
  TC_mean              ; -        ; mean temperature correction factor of visited patches
  p_A_list             ; J/d      ; assimilations on visited patches
  p_A                  ; J/D      ; mean assimilation over day
  diapause             ; -        ; logical for diapausing worms if moisture too low
  days-diapause        ; d        ; number of days, the worm has been in diapause
  time-since-last-mating
  num_eggs             ;          ; minimal number embryos per cocoon
  alive                ; -        ;
  age                  ; d        ;
  xcor-home-burrow
  puberty              ;          ; lets worm move out of parental burrow if maturation to adult

  ; state variables
  r                    ; cm/d     ; growth rate
  L                    ; cm       ; state variable 1 is the structural length at previous time point
  dL                   ; cm       ; difference in structural length
  L_0-ind              ; cm       ; structural length at birth with maternal effect
  E_                   ; J        ; state variable 2: energy reserve
  e_scal               ; -        ; scaled energy in reserve (for starvation rules)
  H                    ; J        ; state variable 3: energy invested in maturity
  E_R                  ; J        ; state variable 4: reproduction buffer (cumulative)
  dE_R                 ; J        ; flux in reproduction buffer
  repro                ; J        ; dynamic reproduction buffer
  R_                   ; -        ; cumulative reproduction
  L_w                  ; cm       ; physical length
  Ww                   ; g        ; wet weight
  q                    ; -        ; ageing acceleration
  hr                   ; -        ; hazard rate
  s                    ; -        ; state variable 5: survival probability ageing
  rs                   ; -        ; individual survival probability ageing

  ; toxicity
  D_i                  ; mg/kg    ; scaled internal damage
  rs_it                ;          ; individual survival probability toxic death IT
  max_Di               ;          ; maximal ci
  h_guts               ;          ; cumulative hazard
]

patches-own [
  habitat-type

  temperature
  OM
  food-quality
  moisture
  bulk-density        ; g/cm^3

  conc-total          ; mg/g
]

breed [eggs egg]
breed [juveniles juvenile]
breed [adults adult]

eggs-own [
  num_juv               ; -        ; number of worms per cocoon
]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;           Daily procedures                                                                                                                          ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go

  ;; update patches and calendar
  env-module

  ;; update worms
  ani-module

  tick
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Procedures worms     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to ani-module
  ;; development + hatching of cocoons
  development-eggs

  ;; movement, sensing and feeding of worms in hourly steps
  animals-hourly

  ;; worm procedures at the end of the day
  animals-daily
end

to animals-daily
  ;; at the end of the day, anecic worms move back to their burrows
  if eco-type = "anecic" [ move-to-burrow ]

  ;; development of worms at the end of the day
  ask (turtle-set juveniles adults) [
    ;; reset target-patch
    set target-patch NOBODY
    ;; set means of abiotic factors and assimilation for worms as seen over day for TD, DEB and new burrow-rate
    ifelse diapause [
      ;set T [temperature] of patch-here + K_conv
      set TC_mean temp-corr ([temperature] of patch-here + K_conv)
      set M [moisture] of patch-here
      set p_A 0
    ][
      ;set T mean temperature_list
      set TC_mean mean TC_list
      set M mean moisture_list
      ifelse empty? p_A_list [
        set p_A 0
      ][
        set p_A  mean p_A_list
      ]
    ]

    ;; calculate temperature-correction for mean temperature over day
    ;set TC_mean temp-corr T
    ;; calculate DEB including DEB-TKTD
    do-deb
    ;; calculate toxicodynamics based on scaled internal damage
    if substance and D_i > 0 [do-td]

    ;; death due to desiccation
    if M < m_0 and random-float 1 < rate-desic [
      set alive false
      set death-dessication death-dessication + 1
      die
    ]

    ;; crowding stress for all worms
    crowding-stress
    ;; all worms are reset and updated for the next day
    ;; set new burrow-rate based on moisture and mean TC
    burrow-activity
    ;; reset worm's lists
    ;set temperature_list []
    set TC_list []
    set p_A_list []
    set moisture_list []
    set time-since-last-mating time-since-last-mating + 1
    set age age + 1
  ]
end

to animals-hourly
  ;; anecic worms start with day
  ifelse eco-type = "anecic" [
    set dark false
  ][
    set dark true
  ]

  set hours-of-day 0
  ;; worms move through environment for 24-hour loop
  foreach range 24 [
    ;; let adults mate if they are on same patch
    ask adults with [not diapause] [
      if any? other adults-here with [not diapause] [
        set time-since-last-mating 0
      ]
    ]
    ;; when photoperiod is fulfilled, it gets dark
    if eco-type = "anecic" [
      ask (turtle-set juveniles adults) [predation]
      if hours-of-day = round photoperiod [
        set dark true
        ask (turtle-set juveniles adults) [
          set target-patch NOBODY
        ]
      ]
    ]
    ;; active worms move, sense and feed
;    foreach sort-on [( - l ) ] (turtle-set juveniles adults) with [not diapause] [
;      the-turtle -> ask the-turtle [
    ask (turtle-set juveniles adults) with [not diapause][
        move
        sense
        feed
;      ]
    ]
    set hours-of-day hours-of-day + 1
  ]
end

to development-eggs
  ask eggs [
    ;; death rate of cocoons is 3 times as high as for worms, based on an LD50 of -10000kPa for cocoons (Holmstrup & Westh 1995) vs an LD50 of -30000kPa for adult worms (Friis et al. 2004)
    if [moisture] of patch-here <= m_0 and random-float 1 < rate-desic * 3 [ die ]

    ;; if maturity at birth is reached, release juveniles
    if H >= E_hb [
      set cum-juveniles cum-juveniles + num_juv
      hatch-juveniles num_juv [
        initial-values
        set L_0-ind L
        set age 0
        set M [moisture] of patch-here
        set TC_mean temp-corr ([temperature] of patch-here + K_conv)
        burrow-activity
      ]
      die
    ]
    set age age + 1
    ;; if age of cocoon is over egg resting phase (from DEB) and moisture above m0 (Holmstrup 2001), embryos develop
    if age >= t_0 / TC_mean and [moisture] of patch-here >= m_0 [
      set TC_mean temp-corr ([temperature] of patch-here + K_conv)
      set p_A 0
      do-deb
    ]
  ]
end

to burrow-activity
  ;; worms with facultative diapause remain for set minimal time in diapause
  ifelse diapause and days-diapause < min-days-diapause [
    set days-diapause days-diapause + 1
  ][
    ;; calculate probability distribution of diapause (1 = 100% in diapause, 0 = 0% in diapause)
    let D exp(- b_diapause * max list 0 (M - m_0))
    (ifelse undergoes-diapause = true and random-float 1 < D [
      set diapause true
      set burrow-rate 0
      set days-diapause 0
      set target-patch NOBODY
    ][
      set diapause false
      ;; if worm does not go into diapause -> set burrow rate
      ifelse eco-type != "epigeic" [
        ;; based on deb-move
        set burrow-rate k_b * L ^ 2 * max ( list 0 (M - m_0) )
        set burrow-rate ( min list burrow-rate ( b_max * L ^ 2 ) ) * TC_mean
        ;; for epigeic worms move one patch per hour
      ][set burrow-rate 24]
    ])
  ]
end

to move
  ;; at the beginning of the day, anecic worms save coordinates of their burrow
  if hours-of-day = 0 and eco-type = "anecic" [
    set xcor-home-burrow xcor
    set xcor-home xcor
  ]
  ;; if length of photoperiod is reached (=night) anecic worms move to litter patch above their burrow
  if eco-type = "anecic" and dark and habitat-type != "litter"[
    setxy xcor-home-burrow 1
    set heading random-normal 0 30
    ;; reset burrow rate and angle of cone-of-vision during night for random walk in litter
    ifelse time-since-last-mating > 150 [
      set burrow-rate 18.41 * L / L_i * 24
    ][
      set burrow-rate 24
    ]
    set cone-angle cone-angle-litter
  ]
  ;; Choose target (for all worms the same)
  ;; Find target patches in cone of vision
  if target-patch = patch-here OR target-patch = NOBODY OR target-patch = 0 [
    set target-patches patches in-cone min (list 20 max (list 1.5 burrow-rate)) cone-angle ;;TODO: remove cone-distance from species parameters!
    choose-target
      ;; START: pattern oriented: avoidance of low moistures, higher activity at low food but avoidance if better food available
    ifelse random-float 1 < e_scal [
          let my-ycor ycor
          set target-patches target-patches with-min [abs (pycor - my-ycor) ]
          set target-patch one-of target-patches with-min [distance myself]
        ][
          set target-patch one-of other target-patches
        ]
        ;; STOP: pattern oriented
  ]
  ;; if target is same patch the worm is on or if no target-patches visible (upper/lower world end), stay and turn
  ifelse target-patch = patch-here OR target-patch = NOBODY OR target-patch = 0 [
    ;; anecic worms in burrow during day turn around
    ifelse eco-type = "anecic" and not dark [
      set heading heading + 180
    ][
      ;; in all other cases random turning
      set heading random-normal heading 30
    ]
  ][
    ;; else move toward target-patch by 1 / 24th burrowing rate
    if eco-type != "anecic" or dark [face target-patch]
    let factor-bd 1
    ;; limitation of endogeic worms by bd based on Capowiez et al. 2021
    if eco-type = "endogeic" [
      set factor-bd 516.04 * EXP(-5.205 * [bulk-density] of patch-here)
    ]
    ifelse distance target-patch < burrow-rate * factor-bd / 24 [
      move-to target-patch
    ][
      forward burrow-rate * factor-bd / 24
    ]
  ]

  ;; anecic worms in soil create burrow
  if eco-type = "anecic" and habitat-type = "soil" [
    set habitat-type "burrow"
  ]
end

to sense
  ;; Sense environment and save in daily lists
  set moisture_list lput [moisture] of patch-here moisture_list
  set TC_list lput temp-corr ([temperature] of patch-here + K_conv) TC_list
  if substance [ do-tk ]

end

to-report temp-corr [TinK]
  ; calculate temperature correction factor TC
  let s_A   exp( T_A / T_ref - T_A / TinK )
  ifelse TinK >= T_ref [
    let s_H_ratio (1 + exp( T_AH / T_H - T_AH / T_ref ) ) / (1 + exp( T_AH / T_H - T_AH / TinK ))
    report s_A * s_H_ratio
  ][
    report s_A
  ]
end

to feed
  let factor_X 1
  ;; available OM on patch [J/g]
  let X u_OM * [OM] of patch-here; * [food-quality] of patch-here
  ;; OM based functional response
  let f X / ( HSK + X )
  if scenario != "Ernst2021" and eco-type = "endogeic" [set f f * min list 1 (k_b * (max list 0 (moisture - m_0)) / b_max)]
  ;; assimilation rate [J/d]
  let pA f * p_Am0 * L ^ 2 * last TC_list;temp-corr ([temperature] of patch-here + K_conv)
  ;; ingestion per hourly step [J/h]
  let p_X pA / kap_X / 24
  ;; ingestion in g OM
  let m_X p_X / (u_OM * 100)

  ;; option: decrease OM of patch due to feeding activity of worms
;  if m_X > 0 [
;    ;; total OM of patch in g based on bulk density
;    let m_OM_patch [OM] of patch-here / 100 * [bulk-density] of patch-here
;    ;; if worm wants to eat more than patch allows, reduce assimilation + feeding rate by factor
;    set factor_X min list (m_OM_patch / m_X) 1
;
;      ; feeding feed-back (reduction of OM on patch)
;      set m_OM_patch m_OM_patch - factor_X * m_X
;      ask patch-here [
;        set OM max list 0 (m_OM_patch / bulk-density * 100 );/ food-quality
;      ]
;    ]

  ;; factor if turtle wants to eat more than available on patch
  set pA pA * factor_X

  ;; if sublethal effect on feeding
  if substance and pMoA-feeding [
    let stress 1 / cT1 * max list 0 (D_i - c01)
    set pA pA * max list 0 (1 - stress)
  ]

  set p_A_list lput pA p_A_list
end

to choose-target
  ;; anecic and epigeic worms are limited to patches of habitat-type litter or burrow + soil
  choose-habitat-type

  let rs-pref random-float 1
  ;; First prio: best moisture (based on deb-move: linear increase of attractiveness between lower and upper thresholds, above upper threshold always 1
  set target-patches target-patches with [k_b * (max list 0 (moisture - m_0)) / b_max > rs-pref ]
  ;; second prio: best food (based on functional response from DEB)
  if count target-patches > 1 [
    if (eco-type != "anecic" or dark) and rs-pref > 0.2 [
      set target-patches target-patches with-max [ OM * food-quality / ( OM * food-quality + HSK / u_OM)]
    ]
  ]
  ;; third prio: temperature
  if count target-patches > 1 [
    ifelse any? target-patches with [temp-corr (temperature + K_conv) > 0.5][
      set target-patches target-patches with [temp-corr (temperature + K_conv) > 0.5]
    ][
      set target-patches target-patches with-max [temp-corr (temperature + K_conv)]
    ]
  ]
  ;; fourth prio: lowest bulk density
  if count target-patches > 1 [
    set target-patches target-patches with-min [bulk-density]
  ]
end

to choose-habitat-type
  ;; for epigeic worms and anecic worms at night choose target patches with "litter" attribute
  ifelse eco-type != "endogeic" and dark [
    set target-patches target-patches with [habitat-type = "litter"]
    ;; for anecic worms during day and endogeic worms choose target patches that are not litter
  ][
    set target-patches target-patches with [habitat-type != "litter"]
  ]
end

to do-deb
  ;; Adjust rates with TC
  let v     v0 * TC_mean
  let k_J   k_J0 * TC_mean
  let p_M   p_M0 * TC_mean
  let h_a   (( sqrt h_a0 ) * TC_mean ) ^ 2

  ;; default values prior to sublethal stress
  let kap_R kap_R0

  ;; Adjust parameters for sublethal stress
  if breed != eggs and substance [
    if pMoA-somatic-maintenance [
      let stress 1 / cT2 * max list 0 (D_i - c02)
      set p_M p_M * (1 + stress)
    ]
    if pMoA-maturity-maintenance [
      let stress 1 / cT3 * max list 0 (D_i - c03)
      set k_J k_J * (1 + stress)
    ]
    if pMoA-cost-egg [
      let stress 1 / cT4 * max list 0 (D_i - c04)
      set kap_R kap_R / (1 + stress)
    ]
    if pMoA-hazard-oogenesis [
      let stress 1 / cT5 * max list 0 (D_i - c05)
      set kap_R kap_R * exp ( - stress)
    ]
  ]

  ;; scaled reserve density between 0 = no energy and 1 = full energy
  if breed != eggs [set e_scal min list 1 (E_ * v0 / (L ^ 3 * p_Am0))]

  ;; DEB-calculations (diapausing worms pay somatic maintenance costs only)
  ;; fluxes
  ;; growth rate
  ifelse diapause [
    set r 0
  ][
    set r     (( E_ * v / (L ^ 4)) - (p_M / kap)) / ((E_ / (L ^ 3)) + (E_G / kap))
  ]
  ;; catabolic flux
  let pC    E_ * (v / L - r)
  ;; diapausing worms pay less maintenance costs (manually fitted to Bayley et al. 2010)
  if diapause [
    set pC 0.3 * p_M * L ^ 3
  ]
  ;; flux in maturity maintenance
  let pJ     H * k_J
  if diapause [
    set pJ 0
  ]
  ;; flux in repro buffer
  let pR max (list 0 ((1 - kap) * pC - pJ))
  if diapause [
    set pR 0
  ]

  ;; calculate state variables

  ;; 1. structural length
  set dL    L * r / 3
  set L     L + dL

  ;; starvation rule from Johnston models: if worms become smaller than they were at birth -> die
  if breed != eggs and L < L_0-ind [
    set alive False
    set death-starvation death-starvation + 1
    die
  ]
  set L_w   ( L / del_M )
  if breed != eggs [set size L_w]

  ;; 2. energy in reserve
  set E_    E_ + (p_A - pC)
  ;; if energy from reserve is depleted, die
  if breed != eggs and E_ < 0 [
    set alive False
    set death-starvation death-starvation + 1
    die
  ]

  ifelse H < E_Hp [
  ;; 3. investment in maturity
    set H   H + pR
  ][

  ;; 4. reproduction buffer
    if breed = juveniles [
      set breed adults
      set color 135
      set puberty true
    ]
    set dE_R kap_R * pR
    set E_R ( E_R + dE_R )
    if not diapause [do-repro]
  ]
  set R_    E_R / E_0

  set Ww    L ^ 3 * 1  + (E_ * w_E / mu_E + repro * w_E / mu_E) / 0.16

  ;; 5. survival due to ageing
  if breed != eggs [ageing]
end

to do-repro
  ;; variable reproduction buffer
  set repro repro + dE_R
  let E_0-eggs E_0
  ifelse member? precision e_scal 2 e_scal_mat [
    set E_0-eggs item (position (precision e_scal 2) e_scal_mat) E0_f
  ][
    set E_0-eggs repro + 1
  ]

  let E_eggs floor ( repro / E_0-eggs )
  ;; if enough energy in reproduction buffer, create cocoons
  if E_eggs >= num_eggs [
    hatch-eggs E_eggs / num_eggs [
      ;; according to Butt et al. 1998:
      ;; First 5 months > 60 % viable eggs
      (ifelse time-since-last-mating <= 5 * 30 [
        if random-float 1 > 0.6 [die]
        ;; up to 6 months 11% viable eggs
      ] time-since-last-mating > 5 * 30 and time-since-last-mating < 7 * 30 [
        if random-float 1 > 0.1 [die]
        ;; after 7 months no more viable eggs produced
      ][ die ])
      set size 1
      set color 49
      set age 0
      set H 0
      set E_ E_0-eggs
      set L 1E-6
      set num_juv num_eggs
    ]
  ;; reset worms per cocoon for the parental worm if it is variable (here: only for E. fetida)
  if ave_eggs > 1 [
    set num_eggs random-poisson ave_eggs
  ]
    ;; subtract energy stored in cocoon from repro-buffer
    set repro repro - E_eggs * E_0-eggs
    set cum-eggs cum-eggs + E_eggs
  ]
end

to ageing
  ;; change in acceleration
  let dq    ( q * L ^ 3 / ( v0 / ( g * k_M0 )) ^ 3  * s_g  + h_a0 ) * ( v0 / L - r ) -  r * q
  set q     q + dq * TC_mean

  ;; change in hazard rate
  let dhr   q - r * hr
  set hr    hr + dhr * TC_mean
  if hr < 0 [ set hr 0 ]

  ;; survival probability
  set s     s - s * hr
  if s <= rs [
    set alive False
    set death-ageing death-ageing + 1
    die
  ]
end

to crowding-stress
  ;; Following crowding-stress from EEEWorm for L. terrestris (Johnston et al. 2018)
  ifelse eco-type = "anecic" [
    ;; other worms in burrow lead to increased mortality
    let my-xcor xcor
    if random-float 100 < (count (other (turtle-set juveniles adults) with [xcor = my-xcor]) * 1 / 100)[
      set death-crowding death-crowding + 1
      die
    ]
  ][
    ;; other worms in-radius lead to increased mortality
    if random-float 100 < (count (other (turtle-set juveniles adults) with [not diapause] in-radius 10) * 1 / 100) [
      set death-crowding death-crowding + 1
      die
    ]
  ]
end

to predation
  ;; Following predation from EEEWorm for L. terrestris (Johnston et al. 2018)
  if hours-of-day <= round photoperiod and ycor > -5 and random-float 100 < (count other (turtle-set juveniles adults) / width-environment  * 0.5 / 100 * L / L_i) [
    set death-predation death-predation + 1
    die
  ]
end

to do-tk
;; set factors for TC, growth dilution and size correction if they are turned on
  let factor-TC-kd 1
  let factor-size-correction 1
  let factor-growth-dilution 0
  ;if TC-kd [
    set factor-TC-kd last TC_list;temp-corr ([temperature] of patch-here + K_conv)
  ;]
  ;if size-correction [
    set factor-size-correction L_i / L
  ;]
  ;if growth-dilution [
    set factor-growth-dilution D_i * 3 / L * dL
  ;]

  ;; calculate toxicity based on IT
  ifelse death-model = "IT" [
    set D_i D_i + (k_d_IT * factor-TC-kd * factor-size-correction * ([conc-total] of patch-here - D_i) - factor-growth-dilution) / 24
    if D_i < 0 [ set D_i 0]
    set max_Di max list D_i max_Di
  ][
  ;; calculate toxicity based on SD
    set D_i D_i + ( k_d_SD * factor-TC-kd * factor-size-correction * ([conc-total] of patch-here - D_i) - factor-growth-dilution) / 24
    if D_i < 0 [ set D_i 0 ]
  ]
end

to do-td

  ;; calculate toxidynamics based on IT
  ifelse death-model = "IT" [
    set h_guts h_guts + h_b_IT
    let FS (1 / (1 + (max_Di / m_w_IT) ^ beta))
    let s_guts ( FS * exp( - h_guts) )
    if s_guts <= rs_it [
      set alive False
      set death-tox death-tox + 1
      die
    ]
  ][
  ;; calculate toxicodynamics based on SD
    let factor-TC-bw 1
    ;if TC-bw [
      set factor-TC-bw TC_mean
    ;]
    set h_guts b_w * factor-TC-bw * max ( list 0 (D_i - m_w_SD)) + h_b_SD
    let s_guts exp(- h_guts)
    if s_guts < random-float 1 [
      set alive False
      set death-tox death-tox + 1
      die
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Procedures anecic worms  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-to-burrow
  ;; put worms back in their burrow or let them find a new one if criterium is met
  ask turtles-on patches with [habitat-type = "litter"] [
    let xcor-home-turtle xcor-home-burrow
    if habitat-type != "burrow" [
      ifelse puberty and any? other adults with [xcor-home-burrow = xcor-home-turtle] [
        search-new-burrow
        set xcor-home-burrow xcor
      ][
        ;; jump anywhere into home burrow -> good digging behaviour, fast movement in burrow can be confirmed by expert knowledge and was assumed in EEEworm model as well
        move-to one-of patches with [habitat-type = "burrow" and pxcor = xcor-home-turtle]
      ]
      ;; worm only moves up and down in burrow, therefore it is oriented upwards or downwards
      set heading one-of list 0 180
    ]
    set puberty false
  ]
  ;; reset cone of vision to narrow cone of vision
  set cone-angle cone-angle-burrow
  ;; save existing burrows
  set xcors-existing-burrows sort-by < [pxcor] of patches with [habitat-type = "burrow" and pycor = 0]
end

to search-new-burrow
  ;; check other existing burrows
  let other-existing-burrows filter [i -> i != xcor-home-burrow] xcors-existing-burrows
  ;; first check if any adult-free burrows
  foreach other-existing-burrows [
    the-patch-xcor -> let new-home-burrow the-patch-xcor
    if not any? other adults with [xcor-home-burrow = new-home-burrow] [
      ;jump anywhere into new home burrow
      move-to one-of patches with [habitat-type = "burrow" and pxcor = new-home-burrow]
      stop
    ]
  ]
;; if no burrow available dig own burrow or emigrate
  if habitat-type != "burrow" [
    let xcor-possible-burrow ceiling (max xcors-existing-burrows + max list min-distance-between-burrows (random-normal min-distance-between-burrows (min-distance-between-burrows / 10)))
    ifelse xcor-possible-burrow > max-pxcor [
      set emigration emigration + 1
      die
    ][
      set xcor-home-burrow xcor-possible-burrow
      ask patch xcor-possible-burrow 0 [
        set habitat-type "burrow"
        set pcolor yellow
      ]
      set xcors-existing-burrows lput xcor-possible-burrow xcors-existing-burrows
      set xcors-existing-burrows sort-by < xcors-existing-burrows
      move-to patch xcor-possible-burrow 0
    ]
  ]
end

;; Procedure for maternal effects on offspring
to calc-embryo-reserve-investment

  let lower-bound 0
  let upper-bound E_0 + 10 ;repro / p_Am0;U_R * kap_R] ifelse-value (ticks = 0)  [0.001]
  let e_b_scal f-mat  ;; scaled reserve of the mother, that the embryo should have at birth ifelse-value (ticks = 0)  [1]

  let sim 0

  loop[
    set sim sim + 1

    let U_E^0-estim     0.5 * (lower-bound + upper-bound)
    let U_E_embryo      U_E^0-estim
    let U_H_embryo      0
    let L_embryo        1E-6
    let e_scaled_embryo v0 * (U_E_embryo / L_embryo ^ 3)

    while [U_H_embryo < (E_Hb / p_Am0) and e_scaled_embryo > e_b_scal]  ;; embryo development is simulated to get reserve at birth.
    [
      let S_C_embryo  L_embryo ^ 2 * (g * e_scaled_embryo / (g + e_scaled_embryo)) * (1 + (L_embryo / (g * (v0 / (g * k_M0)))))

      let dU_E_embryo (- S_C_embryo)
      let dU_H_embryo ((1 - kap) * S_C_embryo - (k_J0 * U_H_embryo))
      let dL_embryo   ((1 / 3) * (((v0 /(g * L_embryo ^ 2)) * S_C_embryo) - (k_M0 * L_embryo)))

      set U_E_embryo  U_E_embryo + dU_E_embryo / 24
      set U_H_embryo  U_H_embryo + dU_H_embryo / 24
      set L_embryo    L_embryo   + dL_embryo   / 24

      set e_scaled_embryo v0 * (U_E_embryo / L_embryo ^ 3)
    ]

    if e_scaled_embryo < (e_b_scal + 0.05) and e_scaled_embryo > (e_b_scal - 0.05) and U_H_embryo >= (E_Hb / p_Am0) [
      ;set L_b-mat L_embryo
      set E_0-mat U_E^0-estim * p_Am0
      set e_scal_mat lput precision f-mat 2 e_scal_mat
      set E0_f lput E_0-mat E0_f
      set L_b-f lput L_embryo L_b-f
      stop]

    ifelse U_H_embryo > (E_Hb / p_Am0)
    [set upper-bound U_E^0-estim]
    [set lower-bound U_E^0-estim]
    if sim > 1000 [;user-message ("Embryo submodel did not converge. More timesteps may be needed.")
      ;set L_b-mat L_0
      set E_0-mat 0
      stop]
    ;; if the timestep is too big relative to the speed of growth of the species this will not converge.

  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Procedures environment  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to env-module
  ;; update patches' OM, temperature + moisture
  setup-soildata-dynamic
  ;; update patches' color
  if member? soil-parameter (list "Moisture" "Temperature" "Conc Toxicant") [ recolor ]
  set day-of-year day-of-year + 1
  ;; update calendar
  set date item ticks date-data
  if substring date 0 4 = "1/1/" or substring date 0 5 = "01/01" or substring date 0 5 = "01.01"[
    set day-of-year 1
  ]
  circadian-by-latitude
end

to setup-soildata-dynamic

  let liststart ticks * (depthvalues - thickness-litter )          ; liststart is therewith 0 cause ticks=0
  let listend (ticks + 1) * (depthvalues - thickness-litter)        ; listend is therewith 1x100=100
;  if eco-type = "endogeic" [ set listend liststart + 30 ]         ; to increase computational time, updated patches are limited to the first 30cm for endogeic worms

  let n 0

  (foreach (range liststart listend) [
    the-index -> ask patches with [pycor = n] [
      ;; refinement option for seasonal food quality in Johnston scenarios
;      if member? scenario list "Johnston2014" "Johnston2018" [
;        ;; OM from [-] to [%]
;        set OM ( item (- 1 * n) OM-data ) * 100
;        ;; factor for season based on Johnston et al. 2018: cycle of OM during the year on a meadow with cows
;        let factor-season 0.6 * SIN (360 / 365 * (day-of-year + 178)) + 1
;        set OM OM * factor-season
;      ]
      set temperature item the-index temperature-data
      ;; moisture from v/v% to w/w%
      set moisture ( item the-index theta-data ) * 100 / bulk-density
      ;; concentration from kg / m^3 to g / kg (= mg/g)
      if substance [
        set conc-total (item the-index conc-data) * 1000 / bulk-density
      ]
    ]
    set n n - 1
])

;; litter patches receive same values as first soil cm
ask patches with [habitat-type = "litter"][
  set temperature [temperature] of patch pxcor 0
  set moisture [moisture] of patch pxcor 0
  set OM [OM] of patch pxcor 0
  if substance [ set conc-total [conc-total] of patch pxcor 0 ]
]

end

to recolor
  ask patches with [habitat-type != "litter"] [
    ;; display variable from chooser on interface
    (ifelse soil-parameter = "Temperature"
      ;; blue - white - red from low to high temperatures
      [ ifelse temperature > (T_ref - K_conv) [
        set pcolor scale-color red temperature color-maxT (T_ref - K_conv)
      ][
        set pcolor scale-color blue temperature color-minT (T_ref - K_conv)
        ]
      ]
      soil-parameter = "Moisture"
      ;; blue - white from high to low moisture
      [ set pcolor scale-color blue moisture color-maxTh color-minTh ]
      soil-parameter = "OM"
      ;; purple - white from high to low OM
      [ set pcolor scale-color violet OM ( color-maxOM + 0.014 ) (color-minOM - 0.006 ) ]
      soil-parameter = "Bulkdensity"
      ;; orange - white from high to low bd
      [ set pcolor scale-color orange bulk-density (color-maxBd) (color-minBd) ]
      soil-parameter = "natural"
      [ set pcolor brown - 2]
      soil-parameter = "Conc Toxicant"
      ;; red - white from high to low concentration
      [ set pcolor scale-color red conc-total color-maxConc m_w_SD ])
    if habitat-type = "burrow" [set pcolor yellow]
  ]

end

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;          Setup                                                                                                                                                                            ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  reset-ticks
  resize-world 0 (width-environment * 100 - 1) -99 thickness-litter
  set photoperiod 12
  setup-globals
  setup-scenario
  setup-patches
  if eco-type = "anecic" [ setup-burrows ]
  setup-worms
  set cum-eggs count eggs
  set cum-juveniles 0
end

to setup-globals
  set depthvalues world-height
  set widthvalues world-width
  set K_conv 273.15
  set u_OM 186.20
  ;; read species parameters
  let species-file file-species
  (ifelse
    species = "L. terrestris" [
      set species-file "input/input_species_Lt.txt"
    ] species = "A. caliginosa" [
      set species-file "input/input_species_Ac.txt"
    ] species = "E. fetida" [
      set species-file "input/input_species_Ef.txt"
    ] not no-user-dialogues [
      user-message "Choose .txt file to be uploaded for species' parameters"
      set species-file user-file
  ])
  read-species-from-file species-file
  ;; set compound parameters of DEB
  set k_M0  p_M0 / E_G
  set g     E_G / ( kap * (p_Am0 / v0 ))
  set E_b   p_Am0 / v0 * L_0 ^ 3
  set L_i   kap * p_Am0 / p_M0
  set E_0   U_E0 * p_Am0
  if HSK <= 0 [set HSK   p_Am0 / kap_X / F_m0]
  set e_scal_mat []
  set E0_f []
  set L_b-f []
  setup-maternal-effects
end

to setup-scenario
  (ifelse scenario = "FOCUS-Chateaudun-SB-1913" [
    setup-chat1913
  ] scenario = "Ernst2021" [
    setup-ernst2021
  ] scenario = "Johnston2014" [
    setup-john2014
  ] scenario = "Johnston2018" [
    setup-john2018
  ][
    read-from-folder
  ])
  read-scenario-from-files

  circadian-by-latitude
  set date item ticks date-data

  ;; read toxicity details
  if substance and not file-exists? "conc.txt" [
    set substance false
    if not no-user-dialogues [user-message "No existing concentration file. Substance was turned off"]
  ]
  ifelse substance [setup-tox][set-current-directory "../.."]
end

to setup-tox
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         PESTICIDES             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  file-open "conc.txt"
  set conc-data file-read
  file-close

  set-current-directory "../.."

  set pMoA-feeding False
  set pMoA-somatic-maintenance False
  set pMoA-maturity-maintenance False
  set pMoA-cost-egg False
  set pMoA-hazard-oogenesis False

  let tox-file file-tox
  (ifelse species != "choose file" and tox-parameter = "carbendazim" [
    (ifelse species = "L. terrestris" [
      set tox-file "input/input_tox_Lt-Carb.txt"
    ] species = "A. caliginosa" [
      set tox-file "input/input_tox_Ac-Carb.txt"
    ] species = "E. fetida" [
      set tox-file "input/input_tox_Ef-Carb.txt"
    ])
  ] not no-user-dialogues [
    user-message "Choose .txt file to be uploaded for toxicity parameters"
    set tox-file user-file
  ])
  set-tox-parameters tox-file
end

to circadian-by-latitude
;; module to calculate the photoperiod from latitude and current day of the year according to Forsythe et al. (1995)
  let p-latitude asin (0.39795 * cos ((180 / pi ) * (0.2163108 + 2 * (asin ((0.9671396 * tan ((180 / pi ) * 0.0086 * ( day-of-year - 186))) / sqrt (1 + (0.9671396 * tan ((180 / pi ) * 0.0086 * ( day-of-year - 186))) ^ 2)) * (pi / 180)))))
  set photoperiod 24 - (24 / pi) * acos (( sin (0.8333) + sin latitude * sin p-latitude) / cos (latitude) * cos p-latitude ) * (pi / 180)
end

to setup-maternal-effects
  set f-mat 1
  set E_0-mat E_0 * 1.1
  while [f-mat >= 0 and E_0-mat != 0] [
      calc-embryo-reserve-investment
      set f-mat f-mat - 0.01
    ]
end

to setup-worms

  set-default-shape eggs "egg"
  set-default-shape juveniles "juvWorm"
  set-default-shape adults "aduworm"

  ;; set-up of juveniles
  let rn-juv num-juv * width-environment; max list 0 (random-normal num-juv (num-juv / 5))
  let rn-adu num-adults * width-environment;max list 0 (random-normal num-adults (num-adults / 5))
  if eco-type = "anecic" [ set rn-adu min list rn-adu length xcors-existing-burrows ]
  let f precision (max OM-data * 100 * u_OM / (max OM-data * 100 * u_OM + HSK)) 2
  if eco-type = "epigeic" [set f 1]
  create-juveniles rn-juv * 3 [
    set D_i 0
    (ifelse eco-type = "endogeic" [
      move-to one-of patches with [habitat-type != "litter" and (k_b * (max list 0 (moisture - m_0)) / b_max) >= min list 1 (k_b * (max list 0 (max [moisture] of patches with [pycor > -10] - m_0)) / b_max) and pycor > -10]
    ] eco-type = "epigeic" [
        move-to one-of patches with [habitat-type = "litter"]
    ] eco-type = "anecic" [
        move-to one-of patches with [habitat-type = "burrow"]
        set xcor-home-burrow xcor
        set heading one-of list 0 180
    ])
    set L item (position min (list 1 f) e_scal_mat) l_b-f
    set H      E_Hb
    initial-values
    set age 1
    ;; if starting with a mixed population, worms grow up to a random size between length at birth and ultimate length
    set TC_mean temp-corr ([temperature] of patch-here + K_conv)
    set M [moisture] of patch-here
    set E_     p_Am0 / v0 * L ^ 3   ; maximal reserve at birth (rather than E_0)
    set l_0-ind l
    let H-ini (one-of (range (E_hb * 1000) (E_hp * 1000))) / 1000
    set time-since-last-mating 7 * 30
    while [H < H-ini] [
      set p_A p_Am0 * L ^ 2 * f
      do-deb
    ]
    set TC_mean temp-corr ([temperature] of patch-here + K_conv)
    burrow-activity
    set size L / del_M
  ]

  ;; set-up of adults
  create-juveniles rn-adu * 10 [
    set D_i 0
    (ifelse eco-type = "endogeic" [
      move-to one-of patches with [habitat-type != "litter" and (k_b * (max list 0 (moisture - m_0)) / b_max) >= min list 1 (k_b * (max list 0 (max [moisture] of patches with [pycor > -10] - m_0)) / b_max) and pycor > -10]
    ] eco-type = "epigeic" [
      move-to one-of patches with [habitat-type = "litter"]
    ] eco-type = "anecic" [
      move-to one-of patches with [habitat-type = "burrow" and count adults-here = 0]
      set xcor-home-burrow xcor
      set heading one-of list 0 180
    ])
    set L item (position min (list 1 f) e_scal_mat) l_b-f
    set H      E_Hb
    initial-values
    set age 1
    ;; if starting with a mixed population, worms grow up to a random size between length at birth and ultimate length
    set TC_mean temp-corr ([temperature] of patch-here + K_conv)
    set M [moisture] of patch-here
    set E_     p_Am0 / v0 * L ^ 3   ; maximal reserve at birth (rather than E_0)
    set l_0-ind l
    set time-since-last-mating 365
    while [H < E_hp] [
      set p_A p_Am0 * L ^ 2 * f
      do-deb
      set age age + 1
    ]
    let age-ini age + random 50
    while [age < age-ini] [
      set p_A p_Am0 * L ^ 2 * f
      do-deb
      set age age + 1
    ]
    set H E_hp
    set breed adults
    set color 135
    set time-since-last-mating random (8 * 30)
    set TC_mean temp-corr ([temperature] of patch-here + K_conv)
    burrow-activity
    set size L / del_M
  ]
  if eco-type = "anecic" [
    let n 0
    foreach (list adults) [
      the-adult -> ask the-adult [
        ifelse n >= length xcors-existing-burrows [die][
          move-to one-of patches with [habitat-type = "burrow" and pxcor = item n xcors-existing-burrows]
        ]
      set n n + 1
      ]
    ]
  ]

  ifelse ww-juv > 0 [
    while [count juveniles > rn-juv] [
      ask one-of juveniles with-max [abs (ww - ww-juv)][die]
    ]
    while [count adults > rn-adu] [
      ask one-of adults with-max [abs (ww - ww-adu)][die]
    ]
  ][
    ask n-of max list 0 (count juveniles - rn-juv) juveniles [die]
    ask n-of max list 0 (count adults - rn-adu) adults [die]
  ]

  ;; initiate eggs
  let TC-eggs temp-corr (min [temperature] of patches + K_conv)
  let E_0-eggs E_0
  if member? precision f 2 e_scal_mat [
    set E_0-eggs item (position precision f 2 e_scal_mat) E0_f
  ]
  let egg-per-adult 5
  if eco-type = "anecic" [set egg-per-adult 3]
  create-eggs egg-per-adult * count adults [
    set size 1
    set color 49
    set H 0
    set E_ E_0-eggs
    set L 1E-6
    set num_juv 1
    move-to one-of patches with [count adults-here > 0]
    set diapause false
    set TC_mean temp-corr ([temperature] of patch-here + K_conv)
    set age t_0 / TC_mean
    set p_A 0
    let H-ini random-float E_hb
    while [H < H-ini][
      do-deb
      set age age + 1
    ]
  ]
end

to setup-patches
  ask patches with [pycor <= 0][
    set habitat-type "soil"
  ]
  ask patches with [pycor > 0] [
    set habitat-type "litter"
    set pcolor green
  ]
  setup-soildata-static
  setup-soildata-dynamic

  setup-colordata
  recolor
end

to setup-soildata-static

  (foreach (range 0 -100 -1) [
    the-index -> ask patches with [pycor = the-index] [
      ;; OM from [-] to [%]
      set OM ( item (- 1 * the-index) OM-data ) * 100
      ;; bulk density from kg/m^3 to g/cm^3
      set bulk-density ( item (- 1 * the-index) rho-data ) / 1000
      ;; food quality to increase attractiveness of upper patches
      set food-quality ( 0.0037 * the-index + 1)
    ]
  ])

  ask patches with [habitat-type = "litter"][
    set OM [OM] of patch 0 0
    set bulk-density 1
    set food-quality [food-quality] of patch 0 0
  ]

end

to setup-colordata
    set color-maxT 40; max temperature-data ;+ 10          ; reports maximum value of list and adds 10 to it to have better shades
    set color-minT -20; min temperature-data ;- 10          ; reports minimum value of list - WORKS !

    set color-maxTh max theta-data * 100
    set color-minTh 0

    set color-maxOM 10
    set color-minOM 0

    set color-maxBd 2;( max rho-data )
    set color-minBd 1;( min rho-data )

    if substance [ set color-maxConc max conc-data * 1000000 / min rho-data ]
end

to setup-burrows
  let xcor-burrow random (min-distance-between-burrows / 2)
  set xcors-existing-burrows []
  let n 0
  while [xcor-burrow < max-pxcor ][
    let ycor-burrow random min-pycor
    ask patches with [habitat-type = "soil" and pxcor = xcor-burrow and pycor >= ycor-burrow][
      set habitat-type "burrow"
      set pcolor yellow
    ]
    set xcors-existing-burrows lput xcor-burrow xcors-existing-burrows
    set xcor-burrow ceiling (xcor-burrow + max list min-distance-between-burrows (random-normal min-distance-between-burrows (min-distance-between-burrows / 10)))
    set n n + 1
  ]
  set xcors-existing-burrows remove-duplicates xcors-existing-burrows
  set xcors-existing-burrows sort-by < xcors-existing-burrows
end

to initial-values
  set color 138
  set E_R    0
  set repro  0
  set time-since-last-mating 7 * 30 ;; Butt Nuutinen 1998: no viable eggs after 7 months
  set R_     0
  set L_w    ( L / del_M )
  set size L_w
  set puberty false

  set s      1
  set hr     0
  set q      0
  set rs     random-float 1
  set rs_it  random-float 1
  set max_Di 0
  set h_guts 0
  set alive  true
  ifelse ave_eggs > 1 [
    set num_eggs random-poisson ave_eggs
  ][
    set num_eggs ave_eggs
  ]
  set diapause false
;  set temperature_list []
  set TC_list []
  set moisture_list []
  set p_A_list []
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Scenarios           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Johnston                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-John2018
  set-current-directory "input/John2018"

  ifelse num-adults + num-juv > 0 [
    if eco-type = "anecic" [
      if num-adults > width-environment * 100 / min-distance-between-burrows [ set num-adults floor (width-environment * 100 / min-distance-between-burrows)]
      if num-juv > 20 * width-environment [set num-juv 20 * width-environment]
    ]
  ][
    ifelse eco-type = "anecic" [
      set num-adults floor (width-environment * 100 / min-distance-between-burrows)
      set num-juv num-adults * 4
    ][
      set num-adults 100 * width-environment
      set num-juv 100 * width-environment
    ]
  ]
end

to setup-John2014
  set-current-directory "input/John2014"

  ifelse num-adults + num-juv > 0 [
    if eco-type = "anecic" [
      if num-adults > width-environment * 100 / min-distance-between-burrows [ set num-adults floor (width-environment * 100 / min-distance-between-burrows)]
      if num-juv > 20 * width-environment [set num-juv 20 * width-environment]
    ]
  ][
    ifelse eco-type = "anecic" [
      set num-adults floor (width-environment * 100 / min-distance-between-burrows)
      set num-juv num-adults * 4
    ][
      set num-adults 100 * width-environment
      set num-juv 100 * width-environment
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                            CHATEAUDUN                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-chat1913
  set-current-directory "input/Chat1913"

  ifelse num-adults + num-juv > 0 [
    if eco-type = "anecic" [
      if num-adults > width-environment * 100 / min-distance-between-burrows [ set num-adults floor (width-environment * 100 / min-distance-between-burrows)]
      if num-juv > 20 * width-environment [set num-juv 20 * width-environment]
    ]
  ][
    ifelse eco-type = "anecic" [
      set num-adults floor (width-environment * 100 / min-distance-between-burrows)
      set num-juv num-adults * 4
    ][
      set num-adults 100 * width-environment
      set num-juv 100 * width-environment
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               WURZEN                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-ernst2021
  set-current-directory "input/Ernst2021"
  (ifelse eco-type = "anecic" [
    set num-adults 5
    set num-juv 20
    set ww-juv 1.5
    set ww-adu 4.3
    set min-distance-between-burrows 20
  ] species = "A. caliginosa" [
    set num-adults 33
    set num-juv 169
    set ww-juv 0.38
    set ww-adu 0.79
  ][
    set num-adults 100
    set num-juv 200
  ])
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                            Placeholder                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to read-from-folder
  ifelse no-user-dialogues [
    set-current-directory folder-scenario
  ][
    user-message "Choose directory with scenario .txt-files"
    set-current-directory user-directory
  ]
  ifelse num-adults + num-juv > 0 [
    if eco-type = "anecic" [
      if num-adults > width-environment * 100 / min-distance-between-burrows [ set num-adults floor (width-environment * 100 / min-distance-between-burrows)]
      if num-juv > 50 [set num-juv 50]
    ]
  ][
    ifelse eco-type = "anecic" [
      set num-adults floor (width-environment * 100 / min-distance-between-burrows)
      set num-juv num-adults * 4
    ][
      set num-adults 100
      set num-juv 200
    ]
  ]
end

to read-scenario-from-files
  file-open "ini.txt"
  set location file-read
  set latitude file-read
  set day-of-year file-read
  set start-plot file-read
  file-close

  file-open "calendar.txt"
  set date-data file-read
  file-close

  file-open "OM.txt"
  set OM-data file-read
  file-close

  file-open "rho.txt"
  set rho-data file-read
  file-close

  file-open "temp.txt"
  set temperature-data file-read
  file-close

  file-open "theta.txt"
  set theta-data file-read
  file-close
end

to read-species-from-file [file]
  file-open file

  set eco-type file-read

  set undergoes-diapause file-read
  set min-days-diapause file-read
  set b_diapause file-read
  set F_m0   file-read
  set m_0    file-read
  set b_max  file-read
  set k_b    file-read
  set kap_X  file-read
  set HSK    file-read
  set p_M0   file-read
  set v0     file-read
  set k_J0   file-read
  set p_Am0  file-read
  set kap    file-read
  set E_G    file-read
  set E_Hp   file-read
  set E_Hb   file-read
  set kap_R0 file-read
  set U_E0   file-read
  set del_M  file-read
  set d_V    file-read
  set w_E    file-read
  set mu_E   file-read
  set s_g    file-read
  set h_a0   file-read
  set t_0    file-read

  set T_A    file-read                ; as long as no data available: 0
  set T_H    file-read                ; as long as no data available: any number
  set T_AH   file-read                ; as long as no data available: 0
  set T_ref  file-read                ; in DEB always 20°C

  ; status variables
  set L_0    file-read

  set ave_eggs file-read
  set cone-distance file-read
  set cone-angle-burrow file-read
  set cone-angle-litter file-read
  if eco-type != "anecic" [ set cone-angle cone-angle-burrow]
  set min-distance-between-burrows file-read

  set rate-desic file-read

  file-close
end

to set-tox-parameters [file]
  file-open file

 ; toxicity parameters
  ; IT
  set k_d_IT file-read
  set h_b_IT file-read
  set m_w_IT file-read
  set beta file-read

  ; SD
  set k_d_SD file-read
  set h_b_SD file-read
  set b_w file-read
  set m_w_SD file-read

  if sublethal-effects [
    ; DEB-TKTD
    ; feeding
    set c01 file-read
    set cT1 file-read
    if cT1 > 0 [ set pMoA-feeding True]
    ; somatic maintenance
    set c02 file-read
    set cT2 file-read
    if cT2 > 0 [set pMoA-somatic-maintenance True]
    ; maturity maintenance
    set c03 file-read
    set cT3 file-read
    if cT3 > 0 [set pMoA-maturity-maintenance True]
    ; cost egg
    set c04 file-read
    set cT4 file-read
    if cT4 > 0 [set pMoA-cost-egg True]
    ; hazard oogenesis
    set c05 file-read
    set cT5 file-read
    if cT5 > 0 [set pMoA-hazard-oogenesis True]
  ]

  file-close
end
@#$#@#$#@
GRAPHICS-WINDOW
1131
63
1513
449
-1
-1
3.74
1
10
1
1
1
0
1
0
1
0
99
-99
1
0
0
1
ticks
30.0

BUTTON
24
62
87
95
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
22
100
89
133
go
ifelse ticks >= length date-data or count turtles < 1 [\nsound:play-note \"tubular bells\" 70 64 2\nstop][go]\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
458
60
872
380
Abundances
Time [d]
# / m^2
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Worms" 1.0 0 -16777216 true "" "if ticks >= start-plot [\n  ifelse scenario != \"Johnston2018\" [\n    plot count (turtle-set juveniles adults) / width-environment \n  ][\n    plot count (turtle-set juveniles adults) with [ycor > -20] / width-environment\n  ]\n]"
"Juveniles   " 1.0 0 -13840069 true "" "if ticks >= start-plot [\n  ifelse scenario != \"Johnston2018\" [\n    plot count juveniles / width-environment \n  ][\n    plot count juveniles with [ycor > -20] / width-environment\n  ]\n]"
"Adults" 1.0 0 -955883 true "" "if ticks >= start-plot [\n  ifelse scenario != \"Johnston2018\" [\n    plot count adults / width-environment \n  ][\n    plot count adults with [ycor > -20] / width-environment\n  ]\n]"

CHOOSER
1148
462
1335
507
soil-parameter
soil-parameter
"natural" "OM" "Moisture" "Temperature" "Bulkdensity" "Concentration substance"
4

MONITOR
877
65
941
110
Worms
count (turtle-set juveniles adults)
17
1
11

PLOT
1551
290
1822
456
Cumulative losses
Time [d]
#
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ageing" 1.0 0 -16777216 true "" "plot death-ageing"
"starvation" 1.0 0 -10899396 true "" "plot death-starvation"
"toxicity" 1.0 0 -2674135 true "" "plot death-tox"
"emigration" 1.0 0 -13791810 true "" "plot emigration"
"crowding" 1.0 0 -955883 true "" "plot death-crowding"
"predation" 1.0 0 -7500403 true "" "plot death-predation"
"dessication" 1.0 0 -6459832 true "" "plot death-dessication"

BUTTON
95
101
172
134
go-once
profiler:reset         ;; clear the data\nprofiler:start         ;; start profiling\ngo                     ;; run something you want to measure\nprofiler:stop          ;; stop profiling\n;print profiler:report  ;; view the results\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1628
10
1778
50
Expert view\n--------------
16
0.0
1

SWITCH
185
508
334
541
sublethal-effects
sublethal-effects
0
1
-1000

TEXTBOX
201
487
351
505
Sublethal effects
11
0.0
1

TEXTBOX
41
486
191
504
Lethal effects
11
0.0
1

CHOOSER
38
506
130
551
death-model
death-model
"SD" "IT" "GUTS-RED-SD" "GUTS-RED-IT"
0

TEXTBOX
38
415
108
436
Application
14
0.0
1

CHOOSER
36
340
174
385
species
species
"L. terrestris" "A. caliginosa" "E. fetida" "choose file"
1

PLOT
877
411
1127
532
Diapausing worms
Time [d]
%
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"            " 1.0 0 -16777216 true "" "if ticks > start-plot and any? (turtle-set juveniles adults) [plot count (turtle-set juveniles adults) with [diapause] / count (turtle-set juveniles adults) * 100]"

MONITOR
1000
65
1086
110
NIL
eco-type
17
1
11

MONITOR
944
65
998
110
Cocoons
count eggs
0
1
11

TEXTBOX
43
312
193
330
Animals
14
0.0
1

TEXTBOX
43
191
193
209
Environment
14
0.0
1

INPUTBOX
1560
68
1666
128
width-environment
1.0
1
0
Number

INPUTBOX
1691
67
1777
127
thickness-litter
1.0
1
0
Number

BUTTON
1175
517
1292
550
recolor patches
recolor
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1784
100
1819
118
[cm]
11
0.0
1

TEXTBOX
1670
104
1820
122
[m]
11
0.0
1

CHOOSER
33
215
244
260
scenario
scenario
"FOCUS-Chateaudun-SB-1913" "Ernst2021" "Johnston2014" "Johnston2018" "choose folder"
0

MONITOR
353
58
455
103
NIL
date
0
1
11

PLOT
456
528
870
672
Temperature
Time [d]
°C
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"1 cm" 1.0 0 -16777216 true "" "if ticks > start-plot [plot [temperature] of patch 0 0]"
"30 cm" 1.0 0 -7500403 true "" "if ticks > start-plot [plot [temperature] of patch 0 -29]"
"100 cm" 1.0 0 -2674135 true "" "if ticks > start-plot [plot [temperature] of patch 0 -99]"
"daylight [h]" 1.0 0 -1184463 true "" "if ticks > start-plot [plot photoperiod]"

PLOT
460
675
865
825
Substance
Time [d]
mg/kg
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"1 cm" 1.0 0 -16777216 true "" "if ticks > start-plot [plot [conc-total] of patch 0 0]"
"5 cm" 1.0 0 -7500403 true "" "if ticks > start-plot [plot [conc-total] of patch 0 -4]"
"10 cm" 1.0 0 -2674135 true "" "if ticks > start-plot [plot [conc-total] of patch 0 -9]"
"20 cm" 1.0 0 -955883 true "" "if ticks > start-plot [plot [conc-total] of patch 0 -19]"
"50 cm" 1.0 0 -6459832 true "" "if ticks > start-plot [plot [conc-total] of patch 0 -49]"
"100 cm     " 1.0 0 -1184463 true "" "if ticks > start-plot [plot [conc-total] of patch 0 -99]"

PLOT
457
383
869
525
Moisture
Time [d]
%
0.0
10.0
16.0
18.0
true
true
"" ""
PENS
"1 cm" 1.0 0 -16777216 true "" "if ticks > start-plot [plot [moisture] of patch 0 0]"
"30 cm" 1.0 0 -7500403 true "" "if ticks > start-plot [plot [moisture] of patch 0 -29]"
"100 cm     " 1.0 0 -2674135 true "" "if ticks > start-plot [plot [moisture] of patch 0 -99]"

MONITOR
354
106
455
151
Day of the year
day-of-year
0
1
11

PLOT
877
113
1126
263
Biomass
Time [d]
g / m^2
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "if ticks > start-plot [plot sum [ww] of (turtle-set juveniles adults) / width-environment]"
"Adults" 1.0 0 -955883 true "" "if ticks > start-plot [plot sum [ww] of adults / width-environment]"
"Juveniles" 1.0 0 -10899396 true "" "if ticks > start-plot [plot sum [ww] of juveniles / width-environment]"

PLOT
1551
134
1818
284
Cumulative offspring
Time [d]
#
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Cocoons" 1.0 0 -16777216 true "" "plot cum-eggs"
"Juveniles" 1.0 0 -7500403 true "" "plot cum-juveniles"

PLOT
877
266
1124
408
Depth of worms
Time [d]
cm
0.0
10.0
-31.0
0.0
true
true
"" ""
PENS
"minimal" 1.0 0 -16777216 true "" "if ticks > start-plot [plot max [ycor] of (turtle-set juveniles adults)]"
"mean" 1.0 0 -7500403 true "" "if ticks > start-plot [plot mean [ycor] of (turtle-set juveniles adults)]"
"maximal" 1.0 0 -2674135 true "" "if ticks > start-plot [plot min [ycor] of (turtle-set juveniles adults)]"

MONITOR
1058
209
1128
254
ww [g/m^2]
sum [ww] of (turtle-set juveniles adults) / width-environment
3
1
11

INPUTBOX
186
331
257
391
num-adults
33.0
1
0
Number

INPUTBOX
262
332
325
392
num-juv
169.0
1
0
Number

PLOT
877
535
1135
685
Abundance worms in depths
Time [d]
#
0.0
10.0
0.0
0.01
true
true
"" ""
PENS
"5cm" 1.0 0 -16777216 true "" "if ticks > start-plot [plot count (turtle-set juveniles adults) with [ycor > -5]]"
"10cm" 1.0 0 -7500403 true "" "if ticks > start-plot [plot count (turtle-set juveniles adults) with [ycor <= -5 and ycor > -10] ]"
"20cm" 1.0 0 -2674135 true "" "if ticks > start-plot [plot count (turtle-set juveniles adults) with [ycor <= -10 and ycor > -20] ]"
"30cm" 1.0 0 -955883 true "" "if ticks > start-plot [plot count (turtle-set juveniles adults) with [ycor <= -20 and ycor > -30] ]"
"50cm" 1.0 0 -6459832 true "" "if ticks > start-plot [plot count (turtle-set juveniles adults) with [ycor <= -30 and ycor > -50] ]"
"75cm" 1.0 0 -1184463 true "" "if ticks > start-plot [plot count (turtle-set juveniles adults) with [ycor <= -50 and ycor > -75] ]"
"100cm     " 1.0 0 -10899396 true "" "if ticks > start-plot [plot count (turtle-set juveniles adults) with [ycor <= -75] ]"

SWITCH
35
441
147
474
substance
substance
1
1
-1000

TEXTBOX
1531
10
1546
822
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0.0
1

TEXTBOX
1346
467
1505
551
By clicking on \"recolor patches\" the chosen soil parameter is colored in the world according to its gradient. This is a visual outpot only and has no effect on the simulation!
11
0.0
1

MONITOR
187
107
298
152
% of total runtime
ticks / length date-data * 100
2
1
11

MONITOR
187
60
298
105
total runtime [years]
length date-data / 365
2
1
11

CHOOSER
193
437
331
482
tox-parameter
tox-parameter
"carbendazim" "choose file"
0

MONITOR
355
156
455
201
NIL
location
17
1
11

SWITCH
1572
497
1708
530
no-user-dialogues
no-user-dialogues
0
1
-1000

INPUTBOX
1559
603
1816
663
file-species
input/input_species_Lt.txt
1
0
String

INPUTBOX
1558
731
1816
791
file-tox
input/input_tox_Ac-Carb.txt
1
0
String

INPUTBOX
1557
667
1820
727
folder-scenario
input/Chat1913
1
0
String

TEXTBOX
1569
539
1772
609
\"No-user-dialogues\" should be turned on, if model is run by behaviour space. If turned on, all files and folders must be provided by the inputs below.
11
0.0
1

TEXTBOX
339
10
354
822
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
11
0.0
1

TEXTBOX
135
10
202
52
 Settings \n-----------
16
0.0
1

TEXTBOX
872
10
1022
50
Output\n---------
16
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

adultworm
true
0
Rectangle -7500403 true true 135 15 165 285
Circle -7500403 true true 135 0 30
Circle -7500403 true true 135 270 30
Circle -7500403 true true 120 60 30
Circle -7500403 true true 120 105 30
Circle -7500403 true true 150 105 30
Rectangle -7500403 true true 120 75 180 120
Line -16777216 false 135 60 165 60
Line -16777216 false 135 135 165 135
Line -16777216 false 135 150 165 150
Line -16777216 false 135 165 165 165
Line -16777216 false 135 180 165 180
Line -16777216 false 135 195 165 195
Line -16777216 false 135 210 165 210
Line -16777216 false 135 225 165 225
Line -16777216 false 135 240 165 240
Line -16777216 false 135 255 165 255
Line -16777216 false 135 270 165 270
Line -16777216 false 135 270 165 270
Circle -7500403 true true 150 60 30

aduworm
true
13
Polygon -2064490 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45
Polygon -2064490 true true 165 90 150 105 150 120 165 135 165 90
Polygon -2064490 true true 210 60 225 60 240 105 225 150 210 150 210 60

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

egg
false
0
Circle -7500403 true true 96 76 108
Circle -7500403 true true 72 104 156
Polygon -7500403 true true 221 149 195 101 106 99 80 148

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

juvenileworm
true
0
Rectangle -7500403 true true 135 15 165 285
Circle -7500403 true true 135 0 30
Circle -7500403 true true 135 270 30
Line -16777216 false 135 60 165 60
Line -16777216 false 135 75 165 75
Line -16777216 false 135 90 165 90
Line -16777216 false 135 105 165 105
Line -16777216 false 135 120 165 120
Line -16777216 false 135 135 165 135
Line -16777216 false 135 150 165 150
Line -16777216 false 135 165 165 165
Line -16777216 false 135 180 165 180
Line -16777216 false 135 195 165 195
Line -16777216 false 135 210 165 210
Line -16777216 false 135 225 165 225
Line -16777216 false 135 240 165 240
Line -16777216 false 135 255 165 255
Line -16777216 false 135 270 165 270

juvworm
true
15
Polygon -1 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 165 120 225 120
Line -16777216 false 165 106 221 90
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="lter-ernst2021" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= length date-data</exitCondition>
    <metric>count juveniles / width-environment</metric>
    <metric>count adults / width-environment</metric>
    <enumeratedValueSet variable="death-model">
      <value value="&quot;SD&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-juv">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sublethal-effects">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tox-parameter">
      <value value="&quot;carbendazim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-user-dialogues">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="species">
      <value value="&quot;L. terrestris&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="folder-scenario">
      <value value="&quot;input/Ernst2021&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-parameter">
      <value value="&quot;natural&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="thickness-litter">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="substance">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-adults">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-environment">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="file-tox">
      <value value="&quot;input/input_tox_Lt-Carb.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="file-species">
      <value value="&quot;input/input_species_Lt.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;Ernst2021&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="acali-ernst2021" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= length date-data</exitCondition>
    <metric>count juveniles / width-environment</metric>
    <metric>count adults / width-environment</metric>
    <enumeratedValueSet variable="death-model">
      <value value="&quot;SD&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-juv">
      <value value="169"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sublethal-effects">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tox-parameter">
      <value value="&quot;carbendazim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-user-dialogues">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="species">
      <value value="&quot;A. caliginosa&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="folder-scenario">
      <value value="&quot;input/Chat1913&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-parameter">
      <value value="&quot;natural&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="thickness-litter">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="substance">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-adults">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-environment">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="file-tox">
      <value value="&quot;input/input_tox_Ac-Carb.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="file-species">
      <value value="&quot;input/input_species_Lt.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;Ernst2021&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="lter-ernst2021-noDEBTKTD" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= length date-data</exitCondition>
    <metric>count juveniles / width-environment</metric>
    <metric>count adults / width-environment</metric>
    <enumeratedValueSet variable="death-model">
      <value value="&quot;SD&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-juv">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sublethal-effects">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tox-parameter">
      <value value="&quot;carbendazim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-user-dialogues">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="species">
      <value value="&quot;L. terrestris&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="folder-scenario">
      <value value="&quot;input/Ernst2021&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-parameter">
      <value value="&quot;natural&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="thickness-litter">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="substance">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-adults">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-environment">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="file-tox">
      <value value="&quot;input/input_tox_Lt-Carb.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="file-species">
      <value value="&quot;input/input_species_Lt.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;Ernst2021&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="acali-ernst2021-noReproEffect" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= length date-data</exitCondition>
    <metric>count juveniles / width-environment</metric>
    <metric>count adults / width-environment</metric>
    <enumeratedValueSet variable="death-model">
      <value value="&quot;SD&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-juv">
      <value value="169"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sublethal-effects">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tox-parameter">
      <value value="&quot;carbendazim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-user-dialogues">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="species">
      <value value="&quot;A. caliginosa&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="folder-scenario">
      <value value="&quot;input/Chat1913&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="soil-parameter">
      <value value="&quot;natural&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="thickness-litter">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="substance">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-adults">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="width-environment">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="file-tox">
      <value value="&quot;input/input_tox_Ac-Carb.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="file-species">
      <value value="&quot;input/input_species_Lt.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;Ernst2021&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

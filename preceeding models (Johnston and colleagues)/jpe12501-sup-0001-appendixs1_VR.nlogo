; the ecotox profile used here is for carbendazim and the 28 day study of Lofs-Holmin (1982).
; full details of the ecotox proifle and parameter estimates are provided in Appendix S3 of the Supporting Information.
; based on the dose-response curves presented in Fig 3 of Johnston et al. (2015) the EC50's for growth, reproduction and mortality are 0.26, 0.54 and 0.66 mg/kg respectively.
; dissipation followed a first order decline with DT50 = 20 days.

;;;; Definition of Model Parameters ;;;;

globals
  [
    assimilation_efficiency     ;;;; assimilation efficiency (amount of energy assimilated from ingested food)
    B_0                         ;;;; taxon-specific normalization rate
    activation_energy           ;;;; activation energy (eV)
    energy_flesh                ;;;; energy content of flesh (kJ/g)
    energy_synthesis            ;;;; energy cost of synthesis (kJ/g)
    max_ingestion_rate          ;;;; maximum ingestion rate (g/day)
    half_saturation_coef        ;;;; half saturation coefficient, calculated by fitting a Holling Type II response curve to food ration vs. ingestion rate data.
    mass_birth                  ;;;; mass at birth (g)
    mass_sexual_maturity        ;;;; mass at sexual maturity (g)
    mass_maximum                ;;;; maximum attainable mass (g)
    mass_cocoon                 ;;;; mass of a single cocoon (g)
    growth_constant             ;;;; von Bertalanffy growth constant (day-1), calculated by fitting growth (individual biomass vs. time) data to the von Bertalanffy growth equation.
    max_reproduction_rate       ;;;; maximum reproduction rate (cocoons per 1g earthworm mass per day)
    incubation_period           ;;;; developmental time of cocoons before hatching (days)
    reference_T                 ;;;; reference temperature (Kelvins) used to calculate the effect of temperature on rate constants via the Arrhenius function.
    Arrhenius                   ;;;; the Arrhenius equation is used to correct parameter values according to temperature in K.
    Boltz                       ;;;; Boltzmanns constant, required for the calculation of temperature dependant maintenance costs.
    T                           ;;;; Temperature (in Kelvins).
    day                         ;;;; day of the year
    year                        ;;;; simulation year

    starvation_deathcount
  ]

patches-own
  [
    change_food_density         ;;;; change in food density per timestep
    food_density                ;;;; food density (g)
    energy_content_food         ;;;; energy content of food (kJ/g)
    temperature                 ;;;; patch temperature
    soil_moisture               ;;;; patch soil moisture content (cm/cm3)
    SWP                         ;;;; patch soil water potential (-kPa)
    patch_conc                  ;;;; patch concentration (mg/kg)
    application_time            ;;;; time in days since pesticide application
  ]

turtles-own
  [
    ;; State variables
    age                         ;;;; age (days) required for determining incubation period
    energy_reserve              ;;;; energy reserve (kJ) (amount of energy stored as tissue (7 kJ/g))
    mass                        ;;;; individual mass (g)

    ;; Energy management
    energy_assimilated          ;;;; intermediate daily energy reserve (kJ) which is the difference between assimilated and expended energy for an individual per day. Any remaining energy enters the energy reserves.
    energy_reserve_max          ;;;; maximum energy reserve (kJ): a maximum threshold for the storage of energy per individual (dependant on mass).
    ingestion_rate              ;;;; ingestion rate (g/day): amount of food ingested by an individual per day.

    ;; Survival/Maintenance
    BMR                         ;;;; energy cost of maintenance (kJ): this must be fulfilled per individual per day for survival.
    mortality                   ;;;; background or pesticide specific mortality rate

    ;; Growth parameters
    max_growth_rate             ;;;; maximum growth rate: maximum addition of mass per day (g/day) according to von Bertalanffy growth curve
    max_growth_rate_tox         ;;;; maximum growth rate at a specified pesticide concentration
    growth_rate                 ;;;; new growth rate: addition of mass (g/day) calculated if the energy costs for the maximum growth rate exceed available energy (results in a decreased growth rate).
    energy_growth               ;;;; energy cost for production of new mass added per day ((* energy_flesh + energy_synthesis) (kJ)).

    ;; Reproduction parameters
    embryonic_development       ;;;; accounts for embryo development (%), cocoons fully developed at 100%, dependent on fluctuating temperatures.
    hatchlings                  ;;;; cumulative number of hatchlings produced per adult.
    max_R                       ;;;: maximum reproduction rate of adults, dependant on mass (max_reproduction_rate * mass = number of cocoons per adult per day).
    max_R_tox                   ;;;; maximum reproduction rate at a specified pesticide concentration
    R                           ;;;; max_R values accumulate until enough energy is available to produce one cocoon (mass_cocoon * (energy_flesh + energy_synthesis)).

    aestivating                 ;;;; true/false determines whether an individual is aestivating
    time_aestivating            ;;;; time in days since an individual has been aestivating
    experienced_conc            ;;;; concentration (mg/kg) experienced by an individual
  ]

breed [adults adult]
breed [juveniles juvenile]
breed [cocoons cocoon]

to setup
  file-close-all
  file-open "JPEjohnstonS1weather.txt"      ;;;; opens the weather input file which records soil temperature and soil moisture content (cm/cm3) at different soil depths.

  ca

  set-default-shape adults "worm"
  set-default-shape juveniles "worm"
  set-default-shape cocoons "dot"

  ;;; Global parameters are set at specific values (Table 1) for E. fetida

  set assimilation_efficiency 0.19
  set B_0 967                       ; kJ/day
  set activation_energy 0.25        ; eV
  set energy_flesh 7                ; kJ/g
  set energy_synthesis 3.6          ; kJ/g
  set max_ingestion_rate 0.805      ; g/day
  set mass_birth  0.025             ; input so that individuals die once they lose a certain amount of weight - individual birth weight depends on parent adult
  set mass_sexual_maturity 0.5      ; g
  set mass_maximum 2                ; g
  set growth_constant 0.049         ; /day
  set max_reproduction_rate 0.054   ; kJ/g day
  set incubation_period 62          ; days
  set reference_T 288.15            ; Kelvins
  set Boltz (8.62 * (10 ^ -5))      ; eV K-1

  setup-patches
  setup-turtles

  set T 283.15

  reset-ticks
end

to setup-patches
  ;;; each patch is asked to set its colour as green and its food density to that of 'food_density_patch', the value of which is determined by the user on the interface.
  ask patches
  [
       set pcolor 50
       set food_density 3.5               ;;;;; sets food density to an arbitrary amount per patch at day 0
  ]
end

to setup-turtles
  ;;; the initial population density of each life cycle stage is determined by the user on the interface.
  ;;; colour, size and state variables are set depending on the life cycle stage.
  ;;; all individuals are allocated a random position within the landscape.
   create-adults initial_number_adults
    [
      set color red
      set size 0.3
      set mass mass_sexual_maturity
      set aestivating false
      set time_aestivating 1
      setxy random-xcor random-ycor
    ]
  create-juveniles initial_number_juveniles
   [
      set color pink
      set size 0.2
      set mass mass_birth
      set aestivating false
      set time_aestivating 1
      setxy random-xcor random-ycor
   ]
   create-cocoons initial_number_cocoons
   [
     set color white
     set size 0.1
     set mass mass_birth
     Set age 0
     set energy_reserve mass_cocoon * energy_flesh
     setxy random-xcor random-ycor
   ]
   ask turtles
   [
     if breed = adults or breed = juveniles
     [
        set energy_reserve (mass / 2) * energy_flesh    ;;; sets the energy reserves to their maximum value (cocoons have an energy reserve equivalent to cocoon mass (see above)).
     ]
   ]
end


to go ;;; when the go button on the interface is pressed, the following schedule of processes occurs in one timestep.

     if not any? turtles [stop]
     tick
     set day day + 1
     ask turtles
     [
       set age age + 1       ;;; age is not used in the metabolic algorithms but serves as a useful tool for checking the progress of individuals on the interface.
       calc_mortality        ;;; calculates the background and pesticide specific mortality rate
     ]

     ask patches
    [
     ;;; soil bulk density is set at different soil depths
      if pycor >= 15 [ set food_density random-normal 4 0.40]
      if pycor >= 7 and pycor < 15 [ set food_density random-normal 3.5 0.35]
      if pycor < 7 [ set food_density random-normal 3 0.30]

      set T 273.15 + Temperature

     ;;; the follwing soil retention curves are used to convert soil moisture content measurements to soil water potential depending on the soil texture at different soil depths
      if pycor >= 15 [ set SWP (exp (13.31 - 97.38 * soil_moisture + 298.80 * (soil_moisture ^ 2) - 349.70 * (soil_moisture ^ 3) ))  ]  ; silty loam
      if pycor >= 7 and pycor < 15 [ set SWP (exp (14.92 - 87.10 * soil_moisture + 209.30 * (soil_moisture ^ 2) - 188.30 * (soil_moisture ^ 3) ))  ]   ; silty clay loam
      if pycor < 7 [ set SWP (exp (50.75 - 339.1 * soil_moisture + 861.8 * (soil_moisture ^ 2) - 766.2 * (soil_moisture ^ 3) ))  ]    ; clay

      set pcolor 50
      setup_movement_Ex
      update_patches

     ;;; the following command simulates a pesticide application to the top 5 cm of the soil profile through the inputs provided by the user on the model interface.
      if year = application_year and day = application_day and pycor = 19
       [
          set patch_conc patch_conc + application_rate
       ]
    ]

     setup_env_fluctuations
     if (file-at-end?)
     [ file-close
       stop ]

     set Arrhenius (e ^ ((- activation_energy / Boltz ) * ((1 /  T ) - (1 / reference_T))))

    ;;; individuals are asked to undergo a number of processes, depending on those relevant at their life cycle stage e.g. only adults are asked to calculate their reproduction rate.
     ask adults
    [
      calc_ingestion_rate
      calc_maintenance
      mate
      move
      aestivate
    ]

    ask juveniles
    [
      calc_ingestion_rate
      calc_maintenance
      calc_growth
      transform_juvenile                    ;;; transforms juvenile to adult stage when necessary
      move
      aestivate
    ]

    ask cocoons
    [
      calc_embryo_development               ;;; sets the temperature dependant incubation period and tracks embyo development
      calc_maintenance
      transform_cocoon                      ;;; transforms cocoon to juvenile stage when necessary (embryo development is complete)
    ]

    ask turtles
    [
      update_turtles                        ;;; individuals update their variables at the end of each timestep
    ]

    if day > 365
    [
      set day 1
      set year year + 1
    ]
end

to setup_env_fluctuations
  ; the following commands simulate the daily fluctuations in environmental conditions (soil temperature and soil moisture) according to the weather input file.
    let in1 file-read
    let in2 file-read
    let in3 file-read
    let in4 file-read
    let in5 file-read
    let in6 file-read
    let in7 file-read
    let in8 file-read
    let in9 file-read
    let in10 file-read
    let in11 file-read
    let in12 file-read
    let in13 file-read
    let in14 file-read

   ask patches
    [
      if pycor >= 18   [ set temperature random-normal in1 0.20 ]
      if pycor >= 16 and pycor < 18   [ set temperature random-normal in2 0.20 ]
      if pycor >= 14 and pycor < 16   [ set temperature random-normal in3 0.20 ]
      if pycor >= 12 and pycor < 14   [ set temperature random-normal in4 0.20 ]
      if pycor >= 8 and pycor < 12   [ set temperature random-normal in5 0.20 ]
      if pycor >= 4 and pycor < 8   [ set temperature random-normal in6 0.20 ]
      if pycor < 4  [ set temperature random-normal in7 0.20 ]


      if pycor >= 18   [ set soil_moisture random-normal in8 (in8 / 10) ]
      if pycor >= 16 and pycor < 18   [ set soil_moisture random-normal in9 (in9 / 10) ]
      if pycor >= 14 and pycor < 16   [ set soil_moisture random-normal in10 (in10 / 10) ]
      if pycor >= 12 and pycor < 14   [ set soil_moisture random-normal in11 (in11 / 10) ]
      if pycor >= 8 and pycor < 12   [ set soil_moisture random-normal in12 (in12 / 10) ]
      if pycor >= 4 and pycor < 8   [ set soil_moisture random-normal in13 (in13 / 10) ]
      if pycor < 4  [ set soil_moisture random-normal in14 (in14 / 10) ]
    ]
end

to setup_movement_Ex
  ; sets patches with a higher energy content of food a lighter colour
    if energy_content_food >= 0.10 and energy_content_food < 0.20 [ set pcolor pcolor + 1]
    if energy_content_food >= 0.20 and energy_content_food < 0.30 [ set pcolor pcolor + 2]
    if energy_content_food >= 0.30 and energy_content_food < 0.40 [ set pcolor pcolor + 3]
    if energy_content_food >= 0.4 [ set pcolor pcolor + 4]
    setup_movement_SWP
end

to setup_movement_SWP
  ; sets patches with a lower soil water potential a lighter colour
    if swp >= 20  [set pcolor pcolor + 1]
    if swp >= 15 and swp < 20  [set pcolor pcolor + 2]
    if swp >= 7.5 and swp < 15  [set pcolor pcolor + 3]
    if swp >= 2.5 and swp < 7.5  [set pcolor pcolor + 4]
    if swp < 2.5 [set pcolor pcolor + 5]
end


;;;;;;;;;;;;;;; Movement of individuals ;;;;;;;;;;;;;;;;;;;;;;;;;
to move
 ; juveniles and adults preferentially move to neighbouring patches with a higher energy content of food and lower soil water potential, represented by lighter coloured patches in the model.
    ifelse [pcolor] of patch-here >= [pcolor] of one-of neighbors4
    [
     rt random 15
     lt random 15
     fd 0.5
    ]
    [
     move-to max-one-of neighbors4 [pcolor]
    ]
end

;;;;;;;;;;;;; Mortality ;;;;;;;;;;;;;;;;;;
to calc_mortality
  ; sets the pesticide specific mortality rate according to the dose-response curve and study duration
   if experienced_conc > 0
   [
     let tox_survival exp (-1.05 * experienced_conc)
     set mortality 1 - tox_survival
     if random-float 1 < ( mortality / 28 )
      [
        die
      ]
   ]
end

;;;;;;;;;;;;;;;; Incubation Period ;;;;;;;;;;;;;;;;;;
to calc_embryo_development
   set incubation_period  62 * e ^ ((- activation_energy / Boltz ) * ((1 /  reference_T) - (1 / T)))
   set embryonic_development embryonic_development + ( (1 / Incubation_period) * 100 )   ;;;; accounts for embryo development within the cocoon independent of the current incubation period (tracks environmental fluctuations). When Embryonic_development = 100% the embryo is fully developed.
end

;;;;;;;;;;;;;;;;; Life Stage Transformations ;;;;;;;;;;;;;;
to transform_cocoon
  ; cocoons transform to the juvenile stage when their age is equivalent to the temperature dependent incubation period and embryonic development is 100%
  if age >= incubation_period and embryonic_development >= 100 ;;;; cocoons become juvenile when their age equals the temperature dependant incubation period and development is complete.
  [
    set breed juveniles
    set color pink
    set size 0.2
  ]
end

;;; juveniles transform to the adult life stage when they have grown to a mass equivalent to that at puberty (mass_sexual_maturity).
to transform_juvenile
  if mass >= mass_sexual_maturity
  [
    set breed adults
    set color red
    set size 0.3
  ]
end

;;;;;;;;;;;;;;;;; Aestivation ;;;;;;;;;;;;;;;;
to aestivate
  ; aestivation is triggered when individuals come into contact with patches of a high soil water potential
  ifelse [SWP] of patch-here >= 25
  [
    if aestivating = true and time_aestivating <= 60
    [
      set aestivating TRUE
      calc_metabolic_rate
    ]
    if aestivating = false
    [
      set aestivating TRUE
      calc_metabolic_rate
    ]
  ]
  [
    ; individuals may leave aestivation if the soil water potential decreases to 20 and the individual has been aestivating for a minimum of 14 days
   if aestivating = true and SWP <= 20 and time_aestivating >= 14
   [
    set aestivating false
    set time_aestivating 1
    show-turtle
   ]
  ]
end

to calc_metabolic_rate
    ; when individuals aestivate their metabolic rates are lowered
      set BMR ((B_0 * (Mass ^ (3 / 4)) * e ^ ( - activation_energy / ( Boltz * T)) ) * exp (-0.0032 * time_aestivating))
      ;;; if energy assimilated in one time step is available to pay for maintenance, the costs are deducted from this intermediate reserve. If energy is not available the energy costs are depleted from the reserves in order to maximise survival.
      ifelse energy_reserve > BMR
      [
        set energy_reserve energy_reserve - BMR
      ]

      [
        set mass mass - (BMR / (energy_flesh + energy_synthesis))
        set energy_reserve energy_reserve + BMR
      ]

       ;;; if the mass of an individual adult falls below the mass at puberty due to starvation these individuals rejuvenate to their pre-sexual mature state and are classified as juveniles, unable to reproduce.
       if mass < mass_sexual_maturity
       [
          set breed juveniles
          set
          color pink
          set size 0.2
       ]
           ;;; if the mass of any individual falls below the mass at birth they die due to their inability to sustain such weight loss.
           if mass < mass_birth
           [
              set starvation_deathcount starvation_deathcount + 1
              die
           ]
end

;;;;;;;;;;;;;;;;;; Ingestion Rate ;;;;;;;;;;;;;;;;;;;;
;;; juveniles and adults calculate their ingestion rate (the amount of food ingested from the environment) which depends on the food density of the patch in which they are present and the mass dependent maximum ingestion rate.
to calc_ingestion_rate

 if [food_density] of patch-here > 0
 [
   ifelse SWP < 10
   ; the effect of soil water potential on ingestion rate is modelled as a dose response relationship (Johnston et al., 2014b)
     [
      set ingestion_rate (((max_ingestion_rate * Arrhenius) * (mass ^ (2 / 3)) ))
     ]
     [
        set ingestion_rate (((max_ingestion_rate * Arrhenius) * (mass ^ (2 / 3)) ))  * (exp (-0.04 * SWP))
     ]


     if sum [ingestion_rate] of turtles-here > [food_density] of patch-here
       [
         ask turtles-here
         [
           set ingestion_rate [food_density] of patch-here / count turtles-here
         ]
           set food_density 0
       ]

       if [food_density] of patch-here = 0
     [
       set ingestion_rate 0
     ]
 ]

     calc_assimilation
end

;;;;;;;;; Assimilation of Energy from Ingested Food ;;;;;;;;;

to calc_assimilation
  ; assimilation is the amount of energy available from the given amount of ingested food, determined by the energy content of food and assimilation efficiency, irrespective of mass or temperature.
  ; energy_assimilated provides an intermediate energy reserve, where the energy assimilated in one time step may be used by metabolic processes before being fixed within the energy reserves.
  ; the energy content of food is the soil organic matter, which varies with season and depth.

  if pycor >= 18 ; 10 cm
  [
    if day > 335 and day <= 32 [set energy_content_food random-normal 0.38 0.038] ;Winter
    if day > 32 and day <= 121 [set energy_content_food random-normal 0.44 0.044] ;Spring
    if day > 121 and day <= 213 [set energy_content_food random-normal 0.49 0.049] ;Summer
    if day > 213 and day <= 335 [set energy_content_food random-normal 0.41 0.041] ;Autumn
  ]

  if pycor >= 16 and pycor < 18 ; 20 cm
  [
    if day > 335 and day <= 32 [set energy_content_food random-normal 0.36 0.036] ;Winter
    if day > 32 and day <= 121 [set energy_content_food random-normal 0.42 0.042] ;Spring
    if day > 121 and day <= 213 [set energy_content_food random-normal 0.46 0.046] ;Summer
    if day > 213 and day <= 335 [set energy_content_food random-normal 0.37 0.037] ;Autumn
  ]

  if pycor >= 14 and pycor < 16 ; 30 cm
  [
    if day > 335 and day <= 32 [set energy_content_food random-normal 0.35 0.035] ;Winter
    if day > 32 and day <= 121 [set energy_content_food random-normal 0.40 0.040] ;Spring
    if day > 121 and day <= 213 [set energy_content_food random-normal 0.44 0.044] ;Summer
    if day > 213 and day <= 335 [set energy_content_food random-normal 0.37 0.037] ;Autumn
  ]

  if pycor >= 12 and pycor < 14 ; 40 cm
  [
    if day > 335 and day <= 32 [set energy_content_food random-normal 0.33 0.033] ;Winter
    if day > 32 and day <= 121 [set energy_content_food random-normal 0.38 0.038] ;Spring
    if day > 121 and day <= 213 [set energy_content_food random-normal 0.41 0.041] ;Summer
    if day > 213 and day <= 335 [set energy_content_food random-normal 0.35 0.035] ;Autumn
  ]

  if pycor >= 8 and pycor < 12 ; 60 cm
  [
    if day > 335 and day <= 32 [set energy_content_food random-normal 0.32 0.032] ;Winter
    if day > 32 and day <= 121 [set energy_content_food random-normal 0.36 0.036] ;Spring
    if day > 121 and day <= 213 [set energy_content_food random-normal 0.40 0.040] ;Summer
    if day > 213 and day <= 335 [set energy_content_food random-normal 0.33 0.033] ;Autumn
  ]

  if pycor >= 4 and pycor < 8 ; 80 cm
  [
    if day > 335 and day <= 32 [set energy_content_food random-normal 0.29 0.029] ;Winter
    if day > 32 and day <= 121 [set energy_content_food random-normal 0.33 0.033] ;Spring
    if day > 121 and day <= 213 [set energy_content_food random-normal 0.36 0.036] ;Summer
    if day > 213 and day <= 335 [set energy_content_food random-normal 0.30 0.030] ;Autumn
  ]

  if pycor < 4 ; 100 cm
  [
    if day > 335 and day <= 32 [set energy_content_food random-normal 0.26 0.026] ;Winter
    if day > 32 and day <= 121 [set energy_content_food random-normal 0.30 0.030] ;Spring
    if day > 121 and day <= 213 [set energy_content_food random-normal 0.33 0.033] ;Summer
    if day > 213 and day <= 335 [set energy_content_food random-normal 0.28 0.028] ;Autumn
  ]
    set energy_assimilated (ingestion_rate * (energy_content_food  * assimilation_efficiency) )
end

;;;;;;;;;;;;;;;; Change in Food Density ;;;;;;;;;;;;;;;;
;;; the change in food density per time step is equivalent to the amount individuals ingest from each patch.
to calc_change_food_density
    ifelse food_density <= 0
    [
      set change_food_density 0
    ]
    [
      set change_food_density sum [ ingestion_rate ] of turtles-here
    ]
end
;;;;;;;;;;;;;;;;;;;;; Somatic Maintenance ;;;;;;;;;;;;;;;;;;;;;;;;;;;

to calc_maintenance
  ; maintenance costs are calculated as BMR, which is essential for individual survival and is mass and temperature dependant.
  ; BMR increases linearly with carbendazim concentration
      ifelse experienced_conc > 1
      [
       set BMR (B_0  * (Mass ^ (3 / 4)) * e ^ ( - activation_energy / ( Boltz * T)) * (experienced_conc * 4.5))
      ]
      [
        set BMR (B_0 * (Mass ^ (3 / 4)) * e ^ ( - activation_energy / ( Boltz * T)) )
      ]

      ;;; if energy assimilated in one time step is available to pay for maintenance, the costs are deducted from this intermediate reserve. If energy is not available the energy costs are depleted from the reserves in order to maximise survival.
      ifelse energy_assimilated > BMR
      [
        set energy_assimilated energy_assimilated - BMR
      ]
      [
        set energy_reserve energy_reserve + energy_assimilated
        set energy_reserve energy_reserve - BMR
        set energy_assimilated 0
      ]

        ;;; if the conditions are such that scaled energy reserves fall below the scaled mass of an individual that individual is said to be starving and is asked to undergo processes to offset mortality through a starvation strategy.
        if energy_reserve < (energy_reserve_max * 0.5) and breed = adults
        [
          onset_starvation_strategy
        ]
        if energy_reserve < (energy_reserve_max * 0.5) and breed = juveniles
        [
          onset_starvation_strategy
        ]
end

;;;;;;;;;;;;;;;;;;;; Starvation Strategy ;;;;;;;;;;;;;;;;;;;;;;;;;
to onset_starvation_strategy
 ; the starvation strategy asks individuals to lose weight in order to catabolise energy for covering maintenance costs. This is taken from the mass of the individual and the energy content of the lost mass becomes available within the energy reserves to cover maintenance costs.
     set mass mass - (BMR / (energy_flesh + energy_synthesis))
     set energy_reserve energy_reserve + BMR

       ;;; if the mass of an individual adult falls below the mass at puberty due to starvation these individuals rejuvenate to their pre-sexual mature state and are classified as juveniles, unable to reproduce.
       if mass < mass_sexual_maturity
       [
          set breed juveniles
          set
          color pink
          set size 0.2
       ]
           ;;; if the mass of any individual falls below the mass at birth they die due to their inability to sustain such weight loss.
           if mass < mass_birth
           [
              set starvation_deathcount starvation_deathcount + 1
              die
           ]
end

;;;;;;;;;;;;;;;;;;; Reproduction ;;;;;;;;;;;;;;;;;;;;
;;; Energy available after maintenance in adults goes to ova development. Energy accumulates until enough is available to produce one cocoon containing one fully developed ova.
to mate
  ; adults must initially mate with another adult before becoming fertile and calculating their reproduction rate.
  if mass >= mass_sexual_maturity and any? other adults-here
  [
   move-to one-of other adults-here
    calc_reproduction
  ]
end


to calc_reproduction
  ; the daily reproduction rate is calculated according to the maximum possible reproduction rate, body mass, temperature and carbendazim concentration
     set max_R (max_reproduction_rate * Arrhenius) * mass

      ifelse energy_assimilated >= max_R
     [
       set energy_assimilated energy_assimilated - max_R
       set R R + max_R
     ]
      [
         if energy_assimilated > 0
         [
           set R R + energy_assimilated
           set energy_assimilated 0
         ]
      ]

     if experienced_conc > 0
     [
      let tox_repro exp (-1.28 * experienced_conc)
      set max_R_tox max_r * tox_repro

      ifelse energy_assimilated >= max_R
     [
       set energy_assimilated energy_assimilated - max_R
       set R R + max_R_tox
     ]
     [
         if energy_assimilated > 0
         [
           set R R + energy_assimilated
           set energy_assimilated 0
         ]

     ]
     ]

     ;;; if assimilated energy is available after expenditure to reproduction in adults, growth may occur.
       if Energy_assimilated > 0
        [
            calc_growth
        ]

         set mass_cocoon -0.01768 + 0.04035 * Mass ; cocoon mass is related to adult mass (Johnston et al., 2014b)
         if R >= (mass_cocoon * (energy_flesh + energy_synthesis) ) ; energy cost of producing one cocoon
           [
              reproduce
           ]
end

to reproduce
  ;;; when an individual adult has accumulated enough energy for the production of one hatchling, a cocoon is deposited within the landscape.
          hatch 1
           [
             set breed cocoons
             set color white
             set size 0.1
             set energy_reserve (mass_cocoon * energy_flesh)
             set energy_assimilated 0
             set mass -0.00152 + 0.794 * mass_cocoon  ; mass at birth is related to the cocoon mass
             set age 0
             set hatchlings 0
             set experienced_conc patch_conc
           ]

               set hatchlings hatchlings + 1
               set R R - (mass_cocoon * (energy_flesh + energy_synthesis) )
end

;;;;;;;;;;;;;;;;;;;;; GROWTH ;;;;;;;;;;;;;;;;;;;;;;;;
;;; after maintenance in juveniles and maintenance and reproduction in adults, available energy is expended on growth.
to calc_growth
  ; daily growth rates are calculated according to a maximum growth rate, following the von Bertalanffy growth equation, temperature and carbendazim concentration.
   set max_growth_rate (growth_constant * Arrhenius)  * ( mass_maximum ^ (1 / 3) * mass ^ (2 / 3) - mass)

   if experienced_conc > 0
     [
        let tox_mass exp (-2.66 * experienced_conc)
        set max_growth_rate_tox max_growth_rate * tox_mass
     ]
  ; individuals may only grow if their mass is below that of the stated maximum mass for the species.
   ifelse mass < mass_maximum
     [
       grow
     ]
     [
       stop
     ]
end

;;; Energy costs of growth are determined by the growth rate calculated above and the energy costs of producing flesh (energy content of flesh + energy costs of synthesising flesh).
;;; the maximum growth rate above is only achieved if enough energy is available in energy_assimilated. If less energy is available the growth rate is re-calculated.
to grow
   set energy_growth max_growth_rate *  (energy_flesh + energy_synthesis)

  ifelse experienced_conc > 0
  [
    ifelse energy_assimilated >= energy_growth
    [
      set mass mass + max_growth_rate_tox
      set energy_assimilated energy_assimilated - energy_growth
    ]
    [
      set growth_rate (max_growth_rate_tox / energy_growth) * energy_assimilated
      set mass mass + growth_rate
      set energy_assimilated 0
    ]
  ]
   [
     ifelse energy_assimilated >= energy_growth
    [
      set mass mass + max_growth_rate
      set energy_assimilated energy_assimilated - energy_growth
    ]
    [
      set growth_rate (max_growth_rate / energy_growth) * energy_assimilated
      set mass mass + growth_rate
      set energy_assimilated 0
    ]
  ]
end

to update_patches
      calc_change_food_density
      ifelse food_density > 0
      [
        set food_density food_density - change_food_density
      ]
      [
        set food_density 0
      ]

      if patch_conc > 0
      [
      set application_time application_time + 1
      set patch_conc ( application_rate * (exp (- 0.03214 * application_time)))
      ]
end

to update_turtles
    ;;; energy remaining after metabolic costs have been covered are fixed within the energy reserves, with the energy costs of synthesis taken into account as energy is stored as flesh.
    if breed = adults or breed = juveniles
    [
      set energy_reserve_max (mass / 2) * energy_flesh
    ]
       if aestivating = true
       [
            set time_aestivating time_aestivating + 1
           ; hide-turtle
       ]

    if energy_assimilated > 0
    [
      set energy_reserve energy_reserve + (energy_assimilated * (energy_flesh / (energy_flesh + energy_synthesis)))
    ]
        ;;; a maximum threshold of 50% mass * energy content of flesh is set for energy reserves.
        if energy_reserve > energy_reserve_max and breed = adults
        [
          set energy_reserve energy_reserve_max
          set mass mass + (energy_reserve / 10.6)
        ]
        if energy_reserve > energy_reserve_max and breed = juveniles
        [
          set energy_reserve energy_reserve_max
          set mass mass + (energy_reserve / 10.6)
        ]

      set experienced_conc (experienced_conc + patch_conc) / 2
end
@#$#@#$#@
GRAPHICS-WINDOW
267
10
730
170
-1
-1
7.583333333333334
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
59
0
19
1
1
1
ticks
30.0

BUTTON
23
32
87
65
NIL
Setup
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
178
34
241
67
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
62
142
234
175
Initial_Number_Adults
Initial_Number_Adults
0
500
300.0
100
1
NIL
HORIZONTAL

SLIDER
62
174
234
207
Initial_Number_Juveniles
Initial_Number_Juveniles
0
500
300.0
100
1
NIL
HORIZONTAL

SLIDER
62
206
236
239
Initial_Number_Cocoons
Initial_Number_Cocoons
0
500
300.0
100
1
NIL
HORIZONTAL

PLOT
925
251
1375
492
Population Density
Time (days)
Population Density
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"total" 1.0 0 -13840069 true "" "if ticks >= 365 [plot count turtles]"
"adults" 1.0 0 -2674135 true "" ";if ticks >= 365 [plot count adults]"
"juveniles" 1.0 0 -2064490 true "" ";if ticks >= 365 [plot count juveniles]"
"cocoons" 1.0 0 -13791810 true "" ";if ticks >= 365 [plot count cocoons]"

PLOT
247
176
529
374
Population Biomass (g)
Time (days)
Population Biomass (g/m2)
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"Total biomass (g)" 1.0 0 -16777216 true "" "if ticks > 365 [plot sum [Mass] of turtles with [breed = adults or breed = juveniles and aestivating = false and pycor >= 16 and pxcor >= 15 and pxcor <= 34]]"

PLOT
532
176
732
326
Temperature
Time (days) 
Temperature (deg C)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks > 365 [plot mean [temperature] of patches with [pycor = 1]]"

MONITOR
621
340
678
385
NIL
day
17
1
11

PLOT
925
488
1317
635
SWP
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks > 365 [plot mean [SWP] of patches with [pycor > 15]]"

MONITOR
568
340
618
385
NIL
year
17
1
11

INPUTBOX
87
262
194
322
Application_Rate
3.0
1
0
Number

INPUTBOX
87
321
194
381
Application_Year
10.0
1
0
Number

INPUTBOX
87
381
194
441
Application_Day
200.0
1
0
Number

TEXTBOX
64
83
244
128
The sliders below determine the composition of the starting population
12
0.0
1

TEXTBOX
66
451
249
541
The input boxes above determine the application rate of carbendazim, application year and application day, to be set by the user. 
12
0.0
1

BUTTON
94
32
171
65
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
769
13
871
58
Ad+juv 0-10 cm
(count adults with [ pycor >= 18 ] ) + ( count juveniles with [ pycor >= 18 ] )
17
1
11

MONITOR
769
113
878
158
Ad+juv 20-30 cm
(count adults with [ pycor < 16 and pycor >= 14 ] ) + ( count juveniles with [ pycor < 16 and pycor >= 14 ] )
17
1
11

MONITOR
769
62
873
107
Ad+juv 10-20 cm
(count adults with [ pycor < 18 and pycor >= 16 ] ) + ( count juveniles with [ pycor < 18 and pycor >= 16 ] )
17
1
11

MONITOR
771
165
879
210
Ad+Juv 30-40cm
(count adults with [ pycor < 14 and pycor >= 12 ] ) + ( count juveniles with [ pycor < 14 and pycor >= 12 ] )
17
1
11

MONITOR
773
213
881
258
Ad+Juv 40-60cm
(count adults with [ pycor < 12 and pycor >= 8 ] ) + ( count juveniles with [ pycor < 12 and pycor >= 8 ] )
17
1
11

MONITOR
773
260
881
305
Ad+Juv 60-80cm
(count adults with [ pycor < 8 and pycor >= 4 ] ) + ( count juveniles with [ pycor < 8 and pycor >= 4 ] )
17
1
11

MONITOR
774
307
882
352
Ad+Juv 80-100cm
(count adults with [ pycor < 4 ] ) + ( count juveniles with [ pycor < 4 ] )
17
1
11

PLOT
925
10
1383
251
Vertical distribution
time [days]
# individuals
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"0-10 cm" 1.0 0 -16777216 true "" "if ticks > 365 [ plot ((count adults with [ pycor >= 18 ] ) + ( count juveniles with [ pycor >= 18 ] ))]"
"10-20 cm" 1.0 0 -7500403 true "" "if ticks > 365 [ plot ((count adults with [ pycor < 18 and pycor >= 16 ] ) + ( count juveniles with [ pycor < 18 and pycor >= 16 ] )) ]"
"20-30 cm" 1.0 0 -2674135 true "" "if ticks > 365 [ plot ((count adults with [ pycor < 16 and pycor >= 14 ] ) + ( count juveniles with [ pycor < 16 and pycor >= 14 ] )) ]"
"30-40 cm" 1.0 0 -955883 true "" "if ticks > 365 [ plot ((count adults with [ pycor < 14 and pycor >= 12 ] ) + ( count juveniles with [ pycor < 14 and pycor >= 12 ] )) ]"
"40-60 cm" 1.0 0 -6459832 true "" "if ticks > 365 [ plot ((count adults with [ pycor < 12 and pycor >= 8 ] ) + ( count juveniles with [ pycor < 12 and pycor >= 8 ] )) ]"
"60-80 cm" 1.0 0 -1184463 true "" "if ticks > 365 [ plot ((count adults with [ pycor < 8 and pycor >= 4 ] ) + ( count juveniles with [ pycor < 8 and pycor >= 4 ] )) ]"
"80-100 cm" 1.0 0 -10899396 true "" "if ticks > 365 [ plot ((count adults with [ pycor < 4 ] ) + ( count juveniles with [ pycor < 4 ] )) ]"

MONITOR
771
355
889
400
Ad+Juv 90-100 cm
(count adults with [ pycor < 2 ] ) + ( count juveniles with [ pycor < 2 ] )
17
1
11

MONITOR
775
402
893
447
Ad+Juv 95-100 cm
(count adults with [ pycor = 0 ] ) + ( count juveniles with [ pycor = 0 ] )
17
1
11

MONITOR
1345
150
1420
195
Aestivating
count turtles with [ aestivating = true ]
17
1
11

PLOT
284
402
679
552
starvation deathcount
NIL
NIL
0.0
10.0
4000.0
4500.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks > 365 [ plot starvation_deathcount ]"

@#$#@#$#@
## Terms of use of the model

© [2014] Copyright in the implementation model belongs to Alice Johnston.  The implementation model software is licensed for use under the terms of the GNU General Public Licence version 3.0.


These software terms of use refer to ‘Netlogo programme code for the Aporrectodea caliginosa energy budget IBM’, submitted as Supporting Information for the paper Johnston, A.S.A., Sibly, R.M., Hodson, M.E., Alvarez, T., Throbek, P., 2015. Effects of agricultural management practices on earthworm populations and crop yield: validation and application of a mechanistic modelling approach. Journal of Applied Ecology.

This implementation is based on the software platform NetLogo (Wilensky 1999).
The software can be used under the GNU GENERAL PUBLIC LICENSE (Version 3, 29 June 2007 http://www.gnu.org/copyleft/gpl.html) for the exploration of basic and applied questions regarding earthworm population dynamics and pesticide application effects. Commercial use of this software, i.e. selling it to third party, is prohibited.

Using the model requires that you refer to the publication (Johnston et al., 2015: see above)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

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

worm
true
0
Polygon -7500403 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Sensitivity_X" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2006"/>
    <metric>sum [Mass] of turtles with [breed = juveniles]</metric>
    <metric>sum [mass] of turtles with [breed = adults]</metric>
    <metric>sum [hatchlings] of turtles with [breed = adults]</metric>
  </experiment>
  <experiment name="random - repro" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="56"/>
    <metric>sum [hatchlings] of turtles with [breed = adults]</metric>
    <enumeratedValueSet variable="Concentration">
      <value value="0"/>
      <value value="5"/>
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="t2" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>sum [Mass] of turtles with [breed = adults or breed = juveniles and aestivating = false and pycor &gt;= 16 and pxcor &gt;= 15 and pxcor &lt;= 34]</metric>
    <enumeratedValueSet variable="app_rate">
      <value value="2.716"/>
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

;;;; Terms of use of the model

;;;; The Netlogo program code for the Lumbricus terrestris EEEworm model was developed by Dr Alice Johnston and is designed for the exploration of basic and applied questions regarding earthworm population dynamics in response to tillage intensity and soil warming.
;;;; This implementation is based on the software platform NetLogo (Wilensky 1999) and includes or is derived from code released to the University of Reading under a compatible licence by Syngenta Limited.
;;;; The software is submitted as Supporting Information for the paper Johnston, A.S.A., Sibly, R.M., Thorbek, P., 2017. Forecasting tillage and soil warming effects on anecic earthworm populations. Journal of Applied Ecology.
;;;; This version Copyright © 2017 University of Reading. This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
;;;; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;;;; See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;;; THE EEEWORM MODEL CODE ;;;;

;;;; Definition of Model Parameters and Global State Variables

globals
  [
    assimilation_efficiency     ;;;; assimilation efficiency (amount of energy assimilated from ingested food)
    B_0                         ;;;; taxon-specific normalization rate
    activation_energy           ;;;; activation energy (eV)
    energy_flesh                ;;;; energy content of flesh (kJ/g)
    energy_synthesis            ;;;; energy cost of synthesis (kJ/g)
    max_ingestion_rate          ;;;; maximum ingestion rate (g/hour)
    half_saturation_coef        ;;;; half saturation coefficient, calculated by fitting a Holling Type II response curve to food ration vs. ingestion rate data.
    burrowing_costs             ;;;; energy costs of burrowing (kJ/cm/hour)
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
    background_mortality        ;;;; background population mortality (not management induced)
    dark?                       ;;;; true if dark, false if light, used to direct surface activity (e.g. foraging) during dark hours
    year                        ;;;; /year
    day                         ;;;; /day
    hour                        ;;;; /hour
  ]

patches-own
  [
    burrow-no                   ;;;; each burrow (set of burrow patches) has a unique number for their owners to identify them
    patch_quality               ;;;; index of patch quality varaible, indicating the favourability of landscape patches
    patch_T                     ;;;; the temperature component of patch quality
    patch_SWP                   ;;;; the soil water potential component of patch quality
    patch_Ex                    ;;;; the energy content of food component of patch quality
    habitat-type                ;;;; used to distinguish between soil, burrow and surface patches
    food_density                ;;;; food density (g)
    energy_content_food         ;;;; energy content of food (kJ/g)
    temperature                 ;;;; soil temperature (degrees celcius) of patch
    SWP                         ;;;; soil water potential (-kPa) of patch
  ]

turtles-own
  [
    ;;;; State variables
    age                         ;;;; age (days) required for determining incubation period
    energy_reserve              ;;;; energy reserve (kJ) (amount of energy stored as tissue (7 kJ/g))
    mass                        ;;;; individual mass (g)

    ;;;; Energy management
    energy_assimilated          ;;;; tracks daily energy assimilation from ingestion and expenditure to life cycle processes before it is stored in the energy reserves.
    energy_reserve_max          ;;;; maximum energy reserve (kJ), a maximum threshold for the storage of energy per individual (dependant on mass).
    ingestion_rate              ;;;; hourly ingestion rate (g/hour)

    ;;;; Survival/Maintenance
    BMR                         ;;;; energy cost of maintenance (kJ)

    ;;;; Burrowing/forgaing variables
    my-burrow                   ;;;; used by individuals to track their burrow number
    last-burrow                 ;;;; used by juveniles to track their parental burrow, which they can return to if they cannot find a suitable burrow site
    burrowing_speed             ;;;; an individuals maximum burrowing speed, used to calculate the maximum energy costs of burrowing per hour (cm/hour)
    max_burrowing_costs         ;;;; calculates an individuals burrowing costs (kJ/hour), which accounts for burrowing speed

    ;;;; Growth parameters
    max_growth_rate             ;;;; maximum growth rate (g/hour) according to the von Bertalanffy growth curve
    growth_rate                 ;;;; reduced growth rate if an individual cannot meet the energy requirements of maximum growth rate (g/hour)
    energy_growth               ;;;; energy cost of growth (kJ), based on the growth rate (g/hour).

    ;;;; Reproduction parameters
    embryonic_development       ;;;; tracks embryo development (%), cocoons are fully developed at 100% and can transform to the juvenile stage.
    hatchlings                  ;;;; tracks the cumulative number of hatchlings produced per adult.
    max_R                       ;;;: maximum rate of energy expenditure to reproduction (kJ/g/hour)
    R                           ;;;; reproduction reserve in which energy accumulate until enough energy is available to produce one cocoon (mass_cocoon * (energy_flesh + energy_synthesis)).
    sperm_counter               ;;;; tracks the time between copulations, adults must mate when sperm_counter exceeds 13 weeks (approx. 3 months)
    favourite-patch             ;;;; identifies the highest quality patch neighbouring an individuals current patch
    max_crawling_speed          ;;;; the maximum speed of individuals at the soil surface (cm/hour)
    burrow?                     ;;;; true if an individual has a burrow, false if it doesn't
  ]

breed [adults adult]
breed [juveniles juvenile]
breed [cocoons cocoon]

to setup
  file-close-all
  file-open "Rothamsted.txt"   ;;;; opens environmental input file, which includes temperature, soil water potential, and energy content of food variables at different depths per day.

  ca
  set-default-shape adults "worm"
  set-default-shape juveniles "worm"
  set-default-shape cocoons "dot"

  ;;; Global parameters are set according to literature data
  set assimilation_efficiency 0.55    ; no units
  set B_0 360                         ; no units
  set activation_energy 0.32          ; eV
  set energy_flesh 7                  ; kJ/g
  set energy_synthesis 3.6            ; kJ/g
  set max_ingestion_rate 0.37         ; g/hour/g2/3
  set burrowing_costs      0.0103     ; kJ/cm/hour
  set mass_birth           0.053      ; g
  set mass_cocoon          0.061      ; g
  set mass_sexual_maturity 4.2        ; g
  set mass_maximum         8.5        ; g
  set growth_constant 0.0023          ; /hour
  set max_reproduction_rate 0.00021   ; kJ/g/hour
  set incubation_period 90            ; days
  set reference_T 288.15              ; Kelvins
  set Boltz (8.62 * (10 ^ -5))        ; eV K-1
  set background_mortality 0.004      ; %/hour
  set year 1972

  setup-patches
  setup-adults

  set T 283.15

  reset-ticks
end

to setup-patches
  ;;; an initial environment with 12 burrows is set up
  ask patches
  [
    if pxcor = 9 and pycor > (20 + random 20) and pycor <= 99 [ set pcolor 38 set habitat-type "burrow" set burrow-no 1 ]
    if pxcor = 34 and pycor > (30 + random 20) and pycor <= 99 [  set pcolor 37 set habitat-type "burrow" set burrow-no 2]
    if pxcor = 59 and pycor > (10 + random 20) and pycor <= 99 [  set pcolor 36 set habitat-type "burrow" set burrow-no 3]
    if pxcor = 84 and pycor > (40 + random 20) and pycor <= 99 [  set pcolor 34 set habitat-type "burrow" set burrow-no 4]
    if pxcor = 109 and pycor > (20 + random 20) and pycor <= 99 [  set pcolor 33 set habitat-type "burrow" set burrow-no 5]
    if pxcor = 135 and pycor > (30 + random 20) and pycor <= 99 [  set pcolor 37 set habitat-type "burrow" set burrow-no 6]
    if pxcor = 159 and pycor > (40 + random 20) and pycor <= 99 [  set pcolor 36 set habitat-type "burrow" set burrow-no 7]
    if pxcor = 185 and pycor > (10 + random 20) and pycor <= 99 [  set pcolor 37 set habitat-type "burrow" set burrow-no 6]
    if pxcor = 209 and pycor > (20 + random 20) and pycor <= 99 [  set pcolor 36 set habitat-type "burrow" set burrow-no 7]
    if pxcor = 229 and pycor > (20 + random 20) and pycor <= 99 [ set pcolor 38 set habitat-type "burrow" set burrow-no 8 ]
    if pxcor = 254 and pycor > (30 + random 20) and pycor <= 99 [  set pcolor 37 set habitat-type "burrow" set burrow-no 9]
    if pxcor = 295 and pycor > (10 + random 20) and pycor <= 99 [  set pcolor 36 set habitat-type "burrow" set burrow-no 10]

    ;;; patches are set to different habitat types: soil surface, burrow and soil with different colours
    ifelse pycor > 99
    [
      set habitat-type "soil-surface"
      set pcolor green
    ]
    [
      if habitat-type != "burrow"
      [
       set pcolor 52
       set habitat-type "soil"
      ]
    ]
  ]
end

to setup-adults
  ;;; an initial population of 10 adults is set
  create-adults 10
    [
      set color red
      set mass mass_sexual_maturity
      setxy random-xcor 98
      set size mass
      set R 0 + random 0.4                            ;;; the reproduction reserve is set to a random value
      set sperm_counter 0 + random 2184               ;;; the sperm counter is set to a random value between its minimum and maximum
      set energy_reserve (mass / 2) * energy_flesh    ;;; sets the energy reserves to their maximum value (cocoons have an energy reserve equivalent to cocoon mass (see above)).
      set burrow? true
    ]
end

to go ;;; when the go button on the interface is pressed, the following schedule of processes occurs in one timestep.

     if not any? turtles [stop]
     tick
     if file-at-end? or ticks = 175200 [stop]

     set hour hour + 1

     ifelse hour <= 11
     [
       set dark? false
     ]
     [
       set dark? true
     ]

     setup_env_fluctuations

     ask patches
    [
      if pycor >= 80 [ set food_density random-normal 3 0.30]
      if pycor >= 40 and pycor < 80 [ set food_density random-normal 2.5 0.25]
      if pycor < 40 [ set food_density random-normal 2 0.20]

      if habitat-type != "burrow"
      [
        set burrow-no 0
      ]

      set T 273.15 + temperature
      setup_patch_quality

    ]

     set Arrhenius (e ^ ((- activation_energy / Boltz ) * ((1 /  T ) - (1 / reference_T))))

      ask turtles
      [
        if ticks = 1 [ move-to one-of patches with [habitat-type = "burrow"]]
        if [habitat-type] of one-of neighbors in-radius 5 = "burrow" [ set burrow? true]  ;;; individuals are initially allocated a random burrow

        if burrow? = false
        [
          set my-burrow 0
        ]

        if dark? = false and [habitat-type] of patch-here != "burrow" [ move-to one-of patches with [habitat-type = "burrow" ]]

        set max_crawling_speed 18.81 * (mass ^ 0.0006)   ;;; sets the maximum mass-specific speed at which individuals can move at the soil surface during dark hours
        set burrowing_speed 0.97 * (mass ^ 0.06)         ;;; sets the maximum mass-specific speed at which individuals can burrow and/or move through the soil profile
      ]

      ask turtles   ;;; individuals calculate their background mortality
      [
        calc_background_mortality

      ]

      if scenario = "direct_drilled"   ;;; tillage-specific effects are simulated, depending on intensity
      [
        ask turtles [setup-tillage-mortality]
      ]

      if scenario = "chisel_plough" or scenario = "deep_plough"
      [
        ask turtles [setup-tillage-mortality]
        ask turtles [remove-litter]
        ask patches [destroy-burrows]
      ]

     ;;; Individual energy budgets
     ask adults
    [
      calc_maintenance
      check_burrow
      if energy_assimilated > 0
      [
        mate?
      ]
    ]
    ask juveniles
    [
      transform_juvenile    ;;; transforms juvenile to adult stage when necessary
      calc_maintenance
      check_burrow
      if energy_assimilated > 0
      [
        calc_growth
      ]
    ]
    ask cocoons
    [
      transform_cocoon     ;;; transforms cocoon to juvenile stage when necessary (embryo development is complete)
      calc_maintenance
    ]

    ask patches
    [
      update_patches      ;;; each patch updates its variables at the end of an hourly timestep
    ]
    ask turtles
    [
      update_turtles       ;;; individuals update their variables at the end of each hourly timestep
    ]
    if hour >= 24
    [
      set hour 0
      set day day + 1
      ask turtles
     [
       set age age + 1       ;;; age is not used in the metabolic algorithms but serves as a useful tool for checking the progress of individuals on the interface.
     ]
    ]

    if day = 365
    [
      set day 1
      set year year + 1
    ]
end


;;;; PATCHES ;;;;
to setup_env_fluctuations    ;;; reads the environmental variables from the input file and allocates values to different patch variables at variuos depths
 ifelse hour = 1
  [
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
    let in15 file-read
    let in16 file-read
    let in17 file-read
    let in18 file-read
    let in19 file-read
    let in20 file-read
    let in21 file-read
    let in22 file-read

    ask patches
    [
      if pycor >= 89   [ set temperature  in1 ]
      if pycor >= 79 and pycor < 89   [ set temperature in2 ]
      if pycor >= 69 and pycor < 79   [ set temperature in3 ]
      if pycor >= 59 and pycor < 69   [ set temperature in4 ]
      if pycor >= 49 and pycor < 59   [ set temperature in5 ]
      if pycor >= 39 and pycor < 49   [ set temperature in6 ]
      if pycor < 39   [ set temperature in7 ]

      if pycor >= 89   [ set swp in8 ]
      if pycor >= 79 and pycor < 89   [ set swp in9 ]
      if pycor >= 69 and pycor < 79   [ set swp in10 ]
      if pycor >= 59 and pycor < 69   [ set swp in11 ]
      if pycor >= 49 and pycor < 59   [ set swp in12 ]
      if pycor >= 39 and pycor < 49   [ set swp in13 ]
      if pycor < 39   [ set swp in14]

      if pycor >= 99 [ set energy_content_food in15 ]
      if pycor >= 90 and pycor < 99 [ set energy_content_food in16 ]
      if pycor >= 80 and pycor < 90 [ set energy_content_food in17 ]
      if pycor >= 70 and pycor < 80 [ set energy_content_food in18 ]
      if pycor >= 60 and pycor < 70 [ set energy_content_food in19 ]
      if pycor >= 40 and pycor < 60 [ set energy_content_food in20 ]
      if pycor >= 20 and pycor < 40 [ set energy_content_food in21 ]
      if pycor < 20 [ set energy_content_food in22 ]

      set swp random-normal swp 0.02
      set temperature random-normal temperature 0.5
      set energy_content_food random-normal energy_content_food (energy_content_food / 10)
    ]
  ]
  [
    ask patches   ;;; sets random-normal environmental variations between patches during the day
      [
        set swp random-normal swp 0.02
        set temperature random-normal temperature 0.5
        set energy_content_food random-normal energy_content_food (energy_content_food / 10)
      ]
  ]
end

to setup_patch_quality
  ;;;; the index of patch quality represents the environmental favourability of a patch, which accounts for temperature, soil water potential and the energy content of food
  if temperature < 15  [set patch_T 0.065 * temperature]
  if temperature >= 15 [set patch_T (1.75 - (0.05 * temperature))]

  if swp < 5  [set patch_SWP (0.80 * swp)]
  if swp >= 5 [set patch_SWP (5 - (0.20 * swp))]

  if energy_content_food < 2.5  [set patch_Ex (0.80 * energy_content_food)]
  if energy_content_food >= 2.5 [set patch_Ex (1.8 + (0.12 * energy_content_food))]

    set patch_quality (patch_T + patch_SWP + patch_Ex)
    if dark? = false and pycor > 99 [ set patch_quality patch_quality - 5 ]

    if habitat-type = "soil" [set pcolor 52 + (patch_quality )]   ;;; sets the colour of soil patches on the interface according to their patch quality

end

;;;; TURTLES ;;;;
to calc_background_mortality

  ifelse ycor > 95 and dark? = false    ;;;; mortality rates at the soil surface are high during daylight hours due to predation
  [
  if random-float 100 < (count turtles * 0.50) / 100
  [
    die
  ]
  ]

  [
    if breed = juveniles   ;;;; background mortality is density-dependent and 5 times higher for adults
  [
  if random-float 100 < (count turtles * background_mortality) / 100
  [
    die
  ]
  ]
  if breed = adults
  [
  if random-float 100 < (count turtles * background_mortality * 5) / 100
  [
    die
  ]
  ]
  ]

end

to setup-tillage-mortality   ;;; during tillage events direct mortality is 50 % within the tilled soil layers
  if day = 270 and hour = 8
  [
     if scenario = "deep_plough"
     [
      if pycor > 79
      [
        if random-float 100 < 50
        [
          die
        ]
      ]
     ]
     if scenario = "chisel_plough"
     [
      if pycor > 87
      [
        if random-float 100 < 50
        [
          die
        ]
      ]
     ]
     if scenario = "direct_drilled"
     [
      if pycor > 97
      [
        if random-float 100 < 50
        [
          die
        ]
      ]
     ]
  ]
end

to remove-litter   ;;;; plant litter removal is simulated by reducing the energy content of food following tillage events
  if scenario = "deep_plough"
     [
      if pycor > 79
      [
        ifelse day < 270
        [
          set energy_content_food energy_content_food * (0.114 + 0.000675 * day)
        ]
        [
          set energy_content_food energy_content_food * (-0.1322 + 0.000675 * day)
        ]

      ]
     ]


     if scenario = "chisel_plough"
     [
      if pycor > 87
      [
       ifelse day < 270
        [
          set energy_content_food energy_content_food * (0.8144 + 0.000675 * day)
        ]
        [
          set energy_content_food energy_content_food * (0.5678 + 0.000675 * day)
        ]
      ]
     ]
end

to destroy-burrows
  if day = 270 and hour = 8
  [
    if scenario = "deep_plough"
    [
    if pycor > 79
      [
        ask patches with [habitat-type = "burrow"]
        [

          set pcolor 52
          set habitat-type "soil"
        ]
      ]
    ]

    if scenario = "chisel_plough"
    [
    if pycor > 87
      [
        ask patches with [habitat-type = "burrow"]
        [
          set pcolor 52
          set habitat-type "soil"
        ]
      ]
     ]
  ]
end

;;;; LIFE STAGE TRANSITIONS ;;;;

;;; cocoons transform to the juvenile stage when their age is equivalent to the temperature dependent incubation period and embryonic development is 100%
to transform_cocoon
  if age >= ( 90 * e ^ ((- activation_energy / Boltz ) * ((1 /  reference_T) - (1 / T)))) ;;;; cocoons become juvenile when their age equals the temperature dependant incubation period and development is complete.
  [
    set breed juveniles
    set color pink
    set size 2
  ]
end

;;; juveniles transform to the adult life stage when they have grown to a mass equivalent to that at puberty (mass_sexual_maturity).
to transform_juvenile
  if mass >= mass_sexual_maturity
  [
    set breed adults
    set color red
    set size mass
  ]
end

;;;; BURROWING AND FORAGING BEHAVIOUR ;;;;
to check_burrow
  ifelse burrow? = true
  [
    ifelse dark? = true
    [
      forage
    ]
    [
      move_in_burrow
    ]
  ]
  [
     find_burrow_site
  ]
end

to forage
  move-to one-of patches with [pxcor = pxcor and habitat-type = "soil-surface"]
  ifelse [habitat-type] of patches in-radius 50 = "burrow"
  [
    set heading 270
  ]
  [
    set heading 90
  ]
  fd 0 + random max_crawling_speed
  calc_ingestion_rate
end

to move_in_burrow
  let my-pxcor [pxcor] of patch-here
  let my-pcolor [pcolor] of patch-here

   set favourite-patch max-one-of patches with [pxcor = my-pxcor] [patch_quality]
   ifelse distance favourite-patch > int burrowing_speed
    [
      set heading towards favourite-patch
      fd int burrowing_speed
    ]
    [
      move-to max-one-of patches with [pxcor = my-pxcor] [patch_quality]
    ]

      if [habitat-type] of patch-here = "soil"
      [
        ask patch-here
        [
           set habitat-type "burrow"
           set pcolor my-pcolor
        ]
           calc_burrowing_costs
      ]
end

to find_burrow_site
  ifelse [habitat-type] of patches in-radius 20 = "burrow"
  [
    move-to one-of patches with [habitat-type = "burrow"]
    set burrow? true
    set my-burrow [burrow-no] of patch-here
    ifelse dark?
     [
       forage
     ]
     [
       move_in_burrow
     ]
  ]
  [
      if [habitat-type] of patch-here  = "soil"  ;;; to form a new burrow individuals must first identify a suitable soil patch
      [
        ifelse [habitat-type] of one-of patches in-radius 20 = "burrow"
        [
          stop
        ]
        [
          form_new_burrow
        ]
      ]
  ]
end

to form_new_burrow
  ask patch-here
  [
    set pcolor max [pcolor] of patches with [habitat-type = "burrow"] + 1
    set burrow-no max [burrow-no] of patches with [habitat-type = "burrow"] + 1
  ]
  set my-burrow [burrow-no] of patch-here
  calc_burrowing_costs
end

to check_parental_burrow
  if mass > 1.5   ;;; mass threshold of juveniles inhabiting their parental burrow
  [
    set last-burrow my-burrow
    ifelse any? adults with [my-burrow = my-burrow]
    [
     check_burrow
    ]
    [
      find_burrow_site
    ]
  ]
end

;;;; INDIVIDUAL ENERGY BUDGETS ;;;;

to calc_maintenance
;;; maintenance costs are calculated as BMR, which is essential for individual survival and is mass and temperature dependant.
      set BMR (B_0 * (Mass ^ (3 / 4)) * e ^ ( - activation_energy / ( Boltz * T)) )

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

        ;;; if food is limited and energy reserves fall below 50 % of their maximum, individuals enter a starvation strategy whereby tissue is catabolised to pay for maintenance costs
        if energy_reserve < (energy_reserve_max * 0.5) and breed = adults
        [
          onset_starvation_strategy
        ]
        if energy_reserve < (energy_reserve_max * 0.5) and breed = juveniles
        [
          onset_starvation_strategy
        ]
end

to onset_starvation_strategy
;;; the starvation strategy asks individuals to lose weight in order to catabolise energy for covering maintenance costs. This is taken from the mass of the individual and the energy content of the lost mass becomes available within the energy reserves to cover maintenance costs.
     set mass mass - (BMR / (energy_flesh + energy_synthesis))
     set energy_reserve energy_reserve + BMR

       ;;; if the mass of an individual adult falls below the mass at puberty due to starvation these individuals rejuvenate to their pre-sexual mature state and are classified as juveniles, unable to reproduce.
       if mass < mass_sexual_maturity
       [
          set breed juveniles
          set
          color pink
          set size 2
       ]
           ;;; if the mass of any individual falls below the mass at birth they die due to their inability to sustain such weight loss.
           if mass < mass_birth
           [
             pen-erase
              die
           ]
end

to calc_burrowing_costs
  set max_burrowing_costs burrowing_speed * (burrowing_costs * (mass ^ (2 / 5)) )

  ifelse energy_assimilated > 0
  [
    ifelse energy_assimilated > max_burrowing_costs
      [
        set energy_assimilated energy_assimilated - max_burrowing_costs
      ]
      [
        set burrowing_speed ( burrowing_speed / max_burrowing_costs ) * energy_assimilated
        set energy_assimilated 0
      ]
  ]
  [
    set burrowing_speed burrowing_speed / 4
    set energy_reserve energy_reserve - (max_burrowing_costs / 4)
  ]

  if [habitat-type] of patch-here = "burrow"
  [
    let last_patch_pcolor [pcolor] of patch-here
    let last_patch_no [burrow-no] of patch-here

    set heading towards max-one-of neighbors [patch_quality]
    if [pycor] of patch-ahead int burrowing_speed > 99 [ set heading 180]

    fd int burrowing_speed
    ask patch-here
    [
      set pcolor last_patch_pcolor
      set burrow-no last_patch_no
      set habitat-type "burrow"
    ]
  ]
end

;;;;;;;;;;;;;;;;;; Ingestion Rate ;;;;;;;;;;;;;;;;;;;;
;;; juveniles and adults calculate their ingestion rate (the amount of food ingested from the environment) which depends on the food density of the patch in which they are present and the mass dependent maximum ingestion rate.
to calc_ingestion_rate
 if [food_density] of patch-here > 0
 [
   set ingestion_rate (((max_ingestion_rate * Arrhenius) * (mass ^ (2 / 3)) ))  * (exp (-0.04 * SWP))
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

to calc_assimilation
    set energy_assimilated (ingestion_rate * ([energy_content_food ] of patch-here * assimilation_efficiency) )
end

;;;;;;;;;;;;;;;;;;; Reproduction ;;;;;;;;;;;;;;;;;;;;
;;; adults must initially mate with another adult before becoming fertile and calculating their reproduction rate.
;;; once an adult has produced one cocoon, the individual is unfertile again.
to mate?
  ifelse sperm_counter > 2184 ;;; 3 months in hours
  [
    if dark? = true and any? other adults in-radius 20
  [
    set sperm_counter 0
    calc_reproduction
  ]
  ]
  [
    calc_reproduction
  ]
end

;;; Energy available after maintenance in adults goes to ova development. Energy accumulates until enough is available to produce one cocoon containing one fully developed ova.
to calc_reproduction
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
  if R >= (mass_cocoon * (energy_flesh + energy_synthesis) ) ;;; energy cost of producing one cocoon.
    [
      reproduce
    ]

  ;;; if assimilated energy is available after expenditure to reproduction in adults, growth may occur.
  if energy_assimilated > 0
    [
      calc_growth
    ]
end

to reproduce
  ;;; when an  adult has accumulated enough energy for the production of one hatchling, a cocoon is deposited within the landscape.
  hatch 1
    [
      set breed cocoons
      set color white
      set size 1
      set energy_reserve (mass_cocoon * energy_flesh)
      set energy_reserve_max (mass_cocoon * energy_flesh)
      set mass mass_birth
      set energy_assimilated 0
      set age 0
      set hatchlings 0
    ]
      set hatchlings hatchlings + 1
      set R R - (mass_cocoon * (energy_flesh + energy_synthesis) )
end

;;;;;;;;;;;;;;;;;;;;; GROWTH ;;;;;;;;;;;;;;;;;;;;;;;;
;;; after maintenance in juveniles and maintenance and reproduction in adults, available energy is expended on growth.
;;; a maximum growth rate, following the von Bertalanffy growth equation.
to calc_growth
  set max_growth_rate (growth_constant * Arrhenius)  * ( mass_maximum ^ (1 / 3) * mass ^ (2 / 3) - mass)  ; { Equation 3b }

  ifelse mass < mass_maximum ;;; individuals may only grow if their mass is below that of the stated maximum mass for the species.
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
end

to update_patches
    ifelse food_density <= 0
    [
      set food_density food_density
    ]
    [
      set food_density food_density -  sum [ ingestion_rate ] of turtles-here
    ]

end

to update_turtles
  if hour = 24 and energy_assimilated > 0
  [
    set energy_reserve energy_reserve + (energy_assimilated * (energy_flesh / (energy_flesh + energy_synthesis)))   ;;; remaining assimilated energy is stored in the energy reserves at the end of the day
    set energy_assimilated 0

    if breed = adults or breed = juveniles
      [
        set energy_reserve_max (mass / 2) * energy_flesh
        if energy_reserve > energy_reserve_max    ;;; individual energy reserves cannot exceed the maximum
        [
          set energy_reserve energy_reserve_max
          set mass mass + (energy_reserve / (energy_flesh + energy_synthesis))
        ]
      ]
  ]

  ask adults   ;;; sizes are for visualisation purposes on the simulation interface only
    [
      set sperm_counter sperm_counter + 1
      if mass > mass_maximum [set mass mass_maximum]
      set size 4
    ]
  ask juveniles
    [
      set size 3
    ]
  ask cocoons
    [
      set size 2
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
246
40
856
261
-1
-1
2.0
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
300
0
105
0
0
1
ticks
30.0

BUTTON
45
44
109
77
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
128
44
191
77
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

PLOT
866
277
1220
514
Total Population Density
Time (days)
Population Density (no.)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "if hour = 8 [plot count turtles with [breed = adults or breed = juveniles]]"
"Adults" 1.0 0 -2674135 true "" "if hour = 8 [plot count turtles with [breed = adults ]]"
"Juveniles" 1.0 0 -2064490 true "" "if hour = 8 [plot count turtles with [breed = juveniles]]"

PLOT
253
293
453
443
Temperature
Time (days)
T (deg C)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if hour = 8 [plot mean [temperature] of patches]"

MONITOR
91
140
148
185
Day
day
17
1
11

PLOT
452
293
652
443
Soil water potential
Time (days)
SWP (-kPa)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"0-15" 1.0 0 -16777216 true "" "if hour = 8 [plot mean [SWP] of patches with [pycor >= 17]]"
"15-30" 1.0 0 -7500403 true "" "if hour = 8 [plot mean [SWP] of patches with [pycor >= 14 and pycor < 17]]"
"30-45" 1.0 0 -2674135 true "" "if hour = 8 [plot mean [SWP] of patches with [pycor >= 11 and pycor < 14]]"

MONITOR
35
140
92
185
Year
year
17
1
11

MONITOR
135
201
192
246
NIL
dark?
17
1
11

MONITOR
146
140
203
185
Hour
hour
17
1
11

MONITOR
36
202
135
247
Population Density
count turtles
1
1
11

CHOOSER
49
88
187
133
scenario
scenario
"control" "deep_plough" "chisel_plough" "direct_drilled"
3

MONITOR
37
246
89
291
Adults
count adults
17
1
11

MONITOR
88
246
141
291
Juveniles
count juveniles
17
1
11

MONITOR
140
246
195
291
Cocoons
count cocoons
17
1
11

PLOT
652
293
852
443
Energy content of patches
Time (days)
Ex (kJ)
0.0
10.0
0.0
0.5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "IF HOUR = 1[plot MEAN [ENERGY_CONTENT_FOOD] OF PATCHES]"

PLOT
866
40
1219
278
Population density (20 cm soil depth / 1 m2)
Time (days)
Population density (no./m2)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks >= 23688 and hour = 8 [plot count turtles with [breed = adults or breed = juveniles and pycor > 79 and pxcor > 99 and pxcor < 200]]"

@#$#@#$#@
## Terms of use of the model

The Netlogo program code for the Lumbricus terrestris EEEworm model was developed by Dr Alice Johnston and is designed for the exploration of basic and applied questions regarding earthworm population dynamics in response to tillage intensity and soil warming. This implementation is based on the software platform NetLogo (Wilensky 1999) and includes or is derived from code released to the University of Reading under a compatible licence by Syngenta Limited. The software is submitted as Supporting Information for the paper Johnston, A.S.A., Sibly, R.M., Thorbek, P.. Forecasting tillage and soil warming effects on anecic earthworm populations. Journal of Applied Ecology.

This version Copyright © 2017 University of Reading. This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

.
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
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="CP ONLY" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="175200"/>
    <metric>count turtles with [breed = adults or breed = juveniles and pxcor &gt; 99 and pxcor &lt; 200]</metric>
    <metric>hour</metric>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;chisel_plough&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="test" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43800"/>
    <metric>hour</metric>
    <metric>day</metric>
    <metric>count turtles with [breed = adults or breed = juveniles and pycor &gt;= 69]</metric>
    <enumeratedValueSet variable="tillage_effects">
      <value value="&quot;none&quot;"/>
      <value value="&quot;mortality&quot;"/>
      <value value="&quot;litter_removal&quot;"/>
      <value value="&quot;M+LR&quot;"/>
      <value value="&quot;burrow_destruction&quot;"/>
      <value value="&quot;M+BD&quot;"/>
      <value value="&quot;BD+LR&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 2327 * 24 - 1</exitCondition>
    <metric>year</metric>
    <metric>day</metric>
    <metric>hour</metric>
    <metric>count turtles with [breed = adults or breed = juveniles and pycor &gt; 79 and pxcor &gt; 99 and pxcor &lt; 200]</metric>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;direct_drilled&quot;"/>
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

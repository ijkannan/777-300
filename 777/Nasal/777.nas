# This procedure saves/loads the aircraft state depending on the saving/loading settings selected by the user.

var save_state = func {
    if (getprop("aircraft/settings/fuel_persistent")) {
        setprop("aircraft/settings/fuel/tank_level-lbs", getprop("consumables/fuel/tank/level-lbs"));
        setprop("aircraft/settings/fuel/tank1_level-lbs", getprop("consumables/fuel/tank[1]/level-lbs"));
        setprop("aircraft/settings/fuel/tank2_level-lbs", getprop("consumables/fuel/tank[2]/level-lbs"));
    };
    
    if (getprop("aircraft/settings/weight_persistent")) {
        #Pax
        setprop("aircraft/settings/weight/first-request-nr", getprop("services/payload/first-request-nr") or 0);
        setprop("aircraft/settings/weight/first-onboard-nr", getprop("services/payload/first-onboard-nr") or 0);
        setprop("aircraft/settings/weight/first-onboard-lbs", getprop("services/payload/first-onboard-lbs") or 0);
        setprop("aircraft/settings/weight/business-request-nr", getprop("services/payload/business-request-nr") or 0);
        setprop("aircraft/settings/weight/business-onboard-nr", getprop("services/payload/business-onboard-nr") or 0);
        setprop("aircraft/settings/weight/business-onboard-lbs", getprop("services/payload/business-onboard-lbs") or 0);
        setprop("aircraft/settings/weight/economy-request-nr", getprop("services/payload/economy-request-nr") or 0);
        setprop("aircraft/settings/weight/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") or 0);
        setprop("aircraft/settings/weight/economy-onboard-lbs", getprop("services/payload/economy-onboard-lbs") or 0);
        setprop("aircraft/settings/weight/pax-request-nr", getprop("services/payload/pax-request-nr") or 0);
        setprop("aircraft/settings/weight/pax-onboard-nr", getprop("services/payload/pax-onboard-nr") or 0);
        setprop("aircraft/settings/weight/pax-onboard-lbs", getprop("services/payload/pax-onboard-lbs") or 0);
        setprop("aircraft/settings/weight/SOB-nr", getprop("services/payload/SOB-nr") or 0);
        #Cargo
        setprop("aircraft/settings/weight/belly-request-lbs", getprop("services/payload/belly-request-lbs") or 0);
        setprop("aircraft/settings/weight/belly-onboard-lbs", getprop("services/payload/belly-onboard-lbs") or 0);
        #Catering
        setprop("aircraft/settings/weight/catering/weight-lbs", getprop("services/catering/weight-lbs") or 0);
        setprop("aircraft/settings/weight/catering/request-lbs", getprop("services/catering/request-lbs") or 0);
        setprop("aircraft/settings/weight/catering/total-trolley-nr", getprop("services/catering/total-trolley-nr") or 0);
        setprop("aircraft/settings/weight/catering/truck[0]/weight-lbs", getprop("services/catering/truck[0]/weight-lbs") or 0);
        setprop("aircraft/settings/weight/catering/truck[1]/weight-lbs", getprop("services/catering/truck[1]/weight-lbs") or 0);
        setprop("aircraft/settings/weight/catering/truck[2]/weight-lbs", getprop("services/catering/truck[2]/weight-lbs") or 0);
        setprop("aircraft/settings/weight/catering/truck[3]/weight-lbs", getprop("services/catering/truck[3]/weight-lbs") or 0);
        setprop("aircraft/settings/weight/catering/truck[0]/trolley-nr", getprop("services/catering/truck[0]/trolley-nr") or 0);
        setprop("aircraft/settings/weight/catering/truck[1]/trolley-nr", getprop("services/catering/truck[1]/trolley-nr") or 0);
        setprop("aircraft/settings/weight/catering/truck[2]/trolley-nr", getprop("services/catering/truck[2]/trolley-nr") or 0);
        setprop("aircraft/settings/weight/catering/truck[3]/trolley-nr", getprop("services/catering/truck[3]/trolley-nr") or 0);
        for (var i = 0; i <= 3; i += 1) {
            for (var j = 0; j <= getprop("services/catering/truck[" ~ i ~ "]/max-trolley-nr") - 1; j += 1) {
                setprop("aircraft/settings/weight/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", getprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs"));
            }
        }
        #Crew
        setprop("aircraft/settings/weight/crew-request-nr", getprop("services/payload/crew-request-nr") or 0);
        setprop("aircraft/settings/weight/crew-onboard-nr", getprop("services/payload/crew-onboard-nr") or 0);
        setprop("aircraft/settings/weight/crew-onboard-lbs", getprop("services/payload/crew-onboard-lbs") or 0);
        #Weights
        setprop("aircraft/settings/weight/weight0-lbs", getprop("sim/weight[0]/weight-lb"));
        setprop("aircraft/settings/weight/weight1-lbs", getprop("sim/weight[1]/weight-lb"));
        setprop("aircraft/settings/weight/weight2-lbs", getprop("sim/weight[2]/weight-lb"));
        setprop("aircraft/settings/weight/weight3-lbs", getprop("sim/weight[3]/weight-lb"));
        setprop("aircraft/settings/weight/weight4-lbs", getprop("sim/weight[4]/weight-lb"));
        setprop("aircraft/settings/weight/weight5-lbs", getprop("sim/weight[5]/weight-lb"));
    };
    
    if (getprop("aircraft/settings/ground_services_persistent")) {
        #stairs
        setprop("aircraft/settings/services/stairs/stairs1_enable", getprop("services/stairs/stairs1_enable") or 0);
        setprop("aircraft/settings/services/stairs/stairs2_enable", getprop("services/stairs/stairs2_enable") or 0);
        setprop("aircraft/settings/services/stairs/stairs3_enable", getprop("services/stairs/stairs3_enable") or 0);
        setprop("aircraft/settings/services/stairs/stairs4_enable", getprop("services/stairs/stairs4_enable") or 0);
        setprop("aircraft/settings/services/stairs/paint-end", getprop("services/stairs/paint-end"));
        setprop("aircraft/settings/services/stairs/cover", getprop("services/stairs/cover"));
        #jetway connections
        setprop("aircraft/settings/services/payload/jetway1_enable", getprop("services/payload/jetway1_enable") or 0);
        setprop("aircraft/settings/services/payload/jetway2_enable", getprop("services/payload/jetway2_enable") or 0);
        #baggage trucks
        setprop("aircraft/settings/services/payload/baggage-truck1-enable", getprop("services/payload/baggage-truck1-enable") or 0);
        setprop("aircraft/settings/services/payload/baggage-truck2-enable", getprop("services/payload/baggage-truck2-enable") or 0);
        #fuel truck
        setprop("aircraft/settings/services/fuel-truck/enable", getprop("services/fuel-truck/enable") or 0);
        setprop("aircraft/settings/services/fuel-truck/connect", getprop("services/fuel-truck/connect") or 0);
        setprop("aircraft/settings/services/fuel-truck/request-lbs", getprop("services/fuel-truck/request-lbs") or 0);
        #ground power unit
        setprop("aircraft/settings/services/ext-pwr/enable", getprop("services/ext-pwr/enable") or 0);
        setprop("aircraft/settings/services/ext-pwr/primary", getprop("services/ext-pwr/primary") or 0);
        setprop("aircraft/settings/services/ext-pwr/secondary", getprop("services/ext-pwr/secondary") or 0);
        setprop("aircraft/settings/services/ext-pwr/power1", getprop("controls/electric/external-power[0]") or 0);
        setprop("aircraft/settings/services/ext-pwr/power2", getprop("controls/electric/external-power[1]") or 0);
        #chocks
        setprop("aircraft/settings/services/chocks/nose", getprop("services/chocks/nose") or 0);
        setprop("aircraft/settings/services/chocks/left", getprop("services/chocks/left") or 0);
        setprop("aircraft/settings/services/chocks/right", getprop("services/chocks/right") or 0);
        #catering trucks
        for (var i = 0; i <= 3; i += 1) {
            setprop("aircraft/settings/services/catering/truck[" ~ i ~"]/connect", getprop("services/catering/truck[" ~ i ~"]/connect") or 0);
            setprop("aircraft/settings/services/catering/truck[" ~ i ~"]/enabled", getprop("services/catering/truck[" ~ i ~"]/enabled") or 0);
            setprop("aircraft/settings/services/catering/truck[" ~ i ~"]/position-norm", getprop("services/catering/truck[" ~ i ~"]/position-norm") or 0);
            setprop("aircraft/settings/services/catering/truck[" ~ i ~"]/cargo/position-norm", getprop("services/catering/truck[" ~ i ~"]/cargo/position-norm") or 0);
        }
        #pushback
        setprop("aircraft/settings/services/autopush/enabled", getprop("sim/model/autopush/enabled") or 0);
        #busses
        setprop("aircraft/settings/services/bus/bus1", getprop("services/bus/bus1-enable") or 0);
        setprop("aircraft/settings/services/bus/bus2", getprop("services/bus/bus2-enable") or 0);
        #safety cones
        setprop("aircraft/settings/services/cones/cone1", getprop("services/cones/cone1-enable") or 0);
        setprop("aircraft/settings/services/cones/cone2", getprop("services/cones/cone2-enable") or 0);
        #Air Start Unit
        setprop("aircraft/settings/services/ASU/enable", getprop("services/ASU/enable") or 0);
        setprop("aircraft/settings/services/ASU/hose1-enable", getprop("services/ASU/hose1-enable") or 0);
        setprop("aircraft/settings/services/ASU/hose2-enable", getprop("services/ASU/hose2-enable") or 0);
        #De-icing trucks
        setprop("aircraft/settings/services/deicing_truck/de-ice", getprop("services/deicing_truck/de-ice") or 0);
        setprop("aircraft/settings/services/deicing_truck/enable", getprop("services/deicing_truck/enable") or 0);
        for (var i = 0; i <= 4; i += 1) {
            setprop("aircraft/settings/services/deicing_truck/truck[" ~ i ~ "]/position-norm", getprop("services/deicing_truck/truck[" ~ i ~ "]/position-norm") or 0);
            setprop("aircraft/settings/services/deicing_truck/crane[" ~ i ~ "]/position-norm", getprop("services/deicing_truck/crane[" ~ i ~ "]/position-norm") or 0);
            setprop("aircraft/settings/services/deicing_truck/deicing[" ~ i ~ "]/position-norm", getprop("services/deicing_truck/deicing[" ~ i ~ "]/position-norm") or 0);
        }
        
    };
    
    # Keep last altimeter settings if radio persistent
    if (getprop("aircraft/settings/radio_persistent")) {
        setprop("aircraft/settings/radio/altimeter/setting-inhg", getprop("instrumentation/altimeter/setting-inhg") or 29.92);
        setprop("aircraft/settings/radio/efis/inputs/kpa-mode", getprop("instrumentation/efis/inputs/kpa-mode") or 0);
    }
    
    # Write everything to the aircraft specific config file
    
    io.write_properties(getprop("sim/fg-home") ~ "/Export/" ~ getprop("sim/aero") ~ "-specific_config.xml", "/aircraft/settings");
};

var load_state = func {
    
    # Read the config file
    
    io.read_properties(getprop("sim/fg-home") ~ "/Export/" ~ getprop("sim/aero") ~ "-specific_config.xml", "/aircraft/settings");
    
    # Load fuel properties
    
    if (getprop("aircraft/settings/fuel_persistent")) {
        # Make sure we don't pass a nil (first run with this model)
        if ((getprop("aircraft/settings/fuel/tank_level-lbs") != nil) and (getprop("aircraft/settings/fuel/tank1_level-lbs") != nil) and (getprop("aircraft/settings/fuel/tank2_level-lbs") != nil)) {
            setprop("consumables/fuel/tank/level-lbs", getprop("aircraft/settings/fuel/tank_level-lbs"));
            setprop("consumables/fuel/tank[1]/level-lbs", getprop("aircraft/settings/fuel/tank1_level-lbs"));
            setprop("consumables/fuel/tank[2]/level-lbs", getprop("aircraft/settings/fuel/tank2_level-lbs"));
            print("Fuel state ..... Loaded");
        } else {
            setprop("consumables/fuel/tank/level-norm", 0.25);
            setprop("consumables/fuel/tank[1]/level-norm", 0.0);
            setprop("consumables/fuel/tank[2]/level-norm", 0.25);
        };
    } else {
        setprop("consumables/fuel/tank[0]/level-norm", 0.25);
        setprop("consumables/fuel/tank[1]/level-norm", 0.0);
        setprop("consumables/fuel/tank[2]/level-norm", 0.25);
        setprop("aircraft/settings/fuel/tank_level-lbs", 0.0);
        setprop("aircraft/settings/fuel/tank1_level-lbs", 0.0);
        setprop("aircraft/settings/fuel/tank2_level-lbs", 0.0);
    };
    
    # Load weight properties
    
    if (getprop("aircraft/settings/weight_persistent")) {
        # Make sure we don't pass a nil (first run with this model)
        if (getprop("aircraft/settings/weight/first-request-nr") != nil) {
            #Pax
            setprop("services/payload/first-request-nr", getprop("aircraft/settings/weight/first-request-nr") or 0);
            setprop("services/payload/first-onboard-nr", getprop("aircraft/settings/weight/first-onboard-nr") or 0);
            setprop("services/payload/first-onboard-lbs", getprop("aircraft/settings/weight/first-onboard-lbs") or 0);
            setprop("services/payload/business-request-nr", getprop("aircraft/settings/weight/business-request-nr") or 0);
            setprop("services/payload/business-onboard-nr", getprop("aircraft/settings/weight/business-onboard-nr") or 0);
            setprop("services/payload/business-onboard-lbs", getprop("aircraft/settings/weight/business-onboard-lbs") or 0);
            setprop("services/payload/economy-request-nr", getprop("aircraft/settings/weight/economy-request-nr") or 0);
            setprop("services/payload/economy-onboard-nr", getprop("aircraft/settings/weight/economy-onboard-nr") or 0);
            setprop("services/payload/economy-onboard-lbs", getprop("aircraft/settings/weight/economy-onboard-lbs") or 0);
            setprop("services/payload/pax-request-nr", getprop("aircraft/settings/weight/pax-request-nr") or 0);
            setprop("services/payload/pax-onboard-nr", getprop("aircraft/settings/weight/pax-onboard-nr") or 0);
            setprop("services/payload/pax-onboard-lbs", getprop("aircraft/settings/weight/pax-onboard-lbs") or 0);
            setprop("services/payload/SOB-nr", getprop("aircraft/settings/weight/SOB-nr") or 0);
            #Cargo
            setprop("services/payload/belly-request-lbs", getprop("aircraft/settings/weight/belly-request-lbs") or 0);
            setprop("services/payload/belly-onboard-lbs", getprop("aircraft/settings/weight/belly-onboard-lbs") or 0);
            #Catering
            setprop("services/catering/weight-lbs", getprop("aircraft/settings/weight/catering/weight-lbs") or 0);
            setprop("services/catering/request-lbs", getprop("aircraft/settings/weight/catering/request-lbs") or 0);
            setprop("services/catering/total-trolley-nr", getprop("aircraft/settings/weight/catering/total-trolley-nr") or 0);
            setprop("services/catering/truck[0]/weight-lbs", getprop("aircraft/settings/weight/catering/truck[0]/weight-lbs") or 0);
            setprop("services/catering/truck[1]/weight-lbs", getprop("aircraft/settings/weight/catering/truck[1]/weight-lbs") or 0);
            setprop("services/catering/truck[2]/weight-lbs", getprop("aircraft/settings/weight/catering/truck[2]/weight-lbs") or 0);
            setprop("services/catering/truck[3]/weight-lbs", getprop("aircraft/settings/weight/catering/truck[3]/weight-lbs") or 0);
            setprop("services/catering/truck[0]/trolley-nr", getprop("aircraft/settings/weight/catering/truck[0]/trolley-nr") or 0);
            setprop("services/catering/truck[1]/trolley-nr", getprop("aircraft/settings/weight/catering/truck[1]/trolley-nr") or 0);
            setprop("services/catering/truck[2]/trolley-nr", getprop("aircraft/settings/weight/catering/truck[2]/trolley-nr") or 0);
            setprop("services/catering/truck[3]/trolley-nr", getprop("aircraft/settings/weight/catering/truck[3]/trolley-nr") or 0);
            for (var i = 0; i <= 3; i += 1) {
                for (var j = 0; j <= getprop("services/catering/truck[" ~ i ~ "]/max-trolley-nr") - 1; j += 1) {
                    setprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", getprop("aircraft/settings/weight/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs") or 0);
                }
            }
            #Crew
            setprop("services/payload/crew-request-nr", getprop("aircraft/settings/weight/crew-request-nr") or 0);
            setprop("services/payload/crew-onboard-nr", getprop("aircraft/settings/weight/crew-onboard-nr") or 0);
            setprop("services/payload/crew-onboard-lbs", getprop("aircraft/settings/weight/crew-onboard-lbs") or 0);
            #Weights
            setprop("sim/weight[0]/weight-lb", getprop("aircraft/settings/weight/weight0-lbs") or 0);
            setprop("sim/weight[1]/weight-lb", getprop("aircraft/settings/weight/weight1-lbs") or 0);
            setprop("sim/weight[2]/weight-lb", getprop("aircraft/settings/weight/weight2-lbs") or 0);
            setprop("sim/weight[3]/weight-lb", getprop("aircraft/settings/weight/weight3-lbs") or 0);
            setprop("sim/weight[4]/weight-lb", getprop("aircraft/settings/weight/weight4-lbs") or 0);
            setprop("sim/weight[5]/weight-lb", getprop("aircraft/settings/weight/weight5-lbs") or 0);
            print("Weight state ..... Loaded");
        };
    };
    
    # Load Radio properties
    
    if (!getprop("aircraft/settings/radio_persistent")) {
        setprop("instrumentation/comm/frequencies/selected-mhz", 119.10);
        setprop("instrumentation/comm/frequencies/standby-mhz", 125.00);
        setprop("instrumentation/comm[1]/frequencies/selected-mhz", 119.30);
        setprop("instrumentation/comm[1]/frequencies/standby-mhz", 118.70);
        setprop("instrumentation/comm[2]/frequencies/selected-mhz", 119.50);
        setprop("instrumentation/comm[2]/frequencies/standby-mhz", 135.705);
        setprop("instrumentation/nav/frequencies/selected-mhz", 109.50);
        setprop("instrumentation/nav/frequencies/standby-mhz", 109.55);
        setprop("instrumentation/nav/radials/selected-deg", 284);
        setprop("instrumentation/nav[1]/frequencies/selected-mhz", 110.10);
        setprop("instrumentation/nav[1]/frequencies/standby-mhz", 111.70);
        setprop("instrumentation/nav[1]/radials/selected-deg", 326);
        setprop("instrumentation/transponder/id-code-digit0",1);
        setprop("instrumentation/transponder/id-code-digit1",2);
        setprop("instrumentation/transponder/id-code-digit2",0);
        setprop("instrumentation/transponder/id-code-digit3",0);
        setprop("instrumentation/transponder/id-code",1200);
        setprop("instrumentation/transponder/id-code[1]",1200);
        setprop("instrumentation/transponder/id-code[2]",2400);
        setprop("instrumentation/transponder/tx-switch",0);
    } else {
        setprop("instrumentation/rmu/unit/selected-mhz", getprop("instrumentation/comm/frequencies/selected-mhz"));
        setprop("instrumentation/rmu/unit/standby-mhz", getprop("instrumentation/comm/frequencies/standby-mhz"));
        setprop("instrumentation/rmu/unit[1]/selected-mhz", getprop("instrumentation/comm[1]/frequencies/selected-mhz"));
        setprop("instrumentation/rmu/unit[1]/standby-mhz", getprop("instrumentation/comm[1]/frequencies/standby-mhz"));
        setprop("instrumentation/rmu/unit[2]/selected-mhz", getprop("instrumentation/comm[2]/frequencies/selected-mhz"));
        setprop("instrumentation/rmu/unit[2]/standby-mhz", getprop("instrumentation/comm[2]/frequencies/standby-mhz"));
        setprop("instrumentation/altimeter/setting-inhg", getprop("aircraft/settings/radio/altimeter/setting-inhg") or 29.92);
        setprop("instrumentation/efis/inputs/kpa-mode", getprop("aircraft/settings/radio/efis/inputs/kpa-mode") or 0);
        
        print("Radio channels ..... Loaded");
    };
    
    # Load Ground Services
    
    if (getprop("aircraft/settings/ground_services_persistent")) {
        if (getprop("aircraft/settings/services/stairs/stairs1_enable") != nil) {
            #Stairs
            setprop("services/stairs/stairs1_enable", getprop("aircraft/settings/services/stairs/stairs1_enable") or 0);
            setprop("services/stairs/stairs2_enable", getprop("aircraft/settings/services/stairs/stairs2_enable") or 0);
            setprop("services/stairs/stairs3_enable", getprop("aircraft/settings/services/stairs/stairs3_enable") or 0);
            setprop("services/stairs/stairs4_enable", getprop("aircraft/settings/services/stairs/stairs4_enable") or 0);
            setprop("services/stairs/paint-end", getprop("aircraft/settings/services/stairs/paint-end"));
            setprop("services/stairs/cover", getprop("aircraft/settings/services/stairs/cover"));
            #Jetway connections
            setprop("services/payload/jetway1_enable", getprop("aircraft/settings/services/payload/jetway1_enable") or 0);
            setprop("services/payload/jetway2_enable", getprop("aircraft/settings/services/payload/jetway2_enable") or 0);
            #Baggage trucks
            setprop("services/payload/baggage-truck1-enable", getprop("aircraft/settings/services/payload/baggage-truck1-enable") or 0);
            setprop("services/payload/baggage-truck2-enable", getprop("aircraft/settings/services/payload/baggage-truck2-enable") or 0);
            #Fuel truck
            setprop("services/fuel-truck/enable", getprop("aircraft/settings/services/fuel-truck/enable") or 0);
            setprop("services/fuel-truck/connect", getprop("aircraft/settings/services/fuel-truck/connect") or 0);
            setprop("services/fuel-truck/request-lbs", getprop("aircraft/settings/services/fuel-truck/request-lbs") or 0);
            #Ground Power Unit
            setprop("services/ext-pwr/enable", getprop("aircraft/settings/services/ext-pwr/enable") or 0);
            setprop("services/ext-pwr/primary", getprop("aircraft/settings/services/ext-pwr/primary") or 0);
            setprop("services/ext-pwr/secondary", getprop("aircraft/settings/services/ext-pwr/secondary") or 0);
            setprop("controls/electric/external-power[0]", getprop("aircraft/settings/services/ext-pwr/power1") or 0);
            setprop("controls/electric/external-power[1]", getprop("aircraft/settings/services/ext-pwr/power2") or 0);
            #Chocks
            setprop("services/chocks/nose", getprop("aircraft/settings/services/chocks/nose") or 0);
            setprop("services/chocks/left", getprop("aircraft/settings/services/chocks/left") or 0);
            setprop("services/chocks/right", getprop("aircraft/settings/services/chocks/right") or 0);
            #Catering trucks
            for (var i = 0; i <= 3; i += 1) {
                setprop("services/catering/truck[" ~ i ~"]/connect", getprop("aircraft/settings/services/catering/truck[" ~ i ~"]/connect") or 0);
                setprop("services/catering/truck[" ~ i ~"]/enabled", getprop("aircraft/settings/services/catering/truck[" ~ i ~"]/enabled") or 0);
                setprop("services/catering/truck[" ~ i ~"]/position-norm", getprop("aircraft/settings/services/catering/truck[" ~ i ~"]/position-norm") or 0);
                setprop("services/catering/truck[" ~ i ~"]/cargo/position-norm", getprop("aircraft/settings/services/catering/truck[" ~ i ~"]/cargo/position-norm") or 0);
            }
            #Pushback truck
            setprop("sim/model/autopush/enabled", getprop("aircraft/settings/services/autopush/enabled") or 0);
            #Busses
            setprop("services/bus/bus1-enable", getprop("aircraft/settings/services/bus/bus1") or 0);
            setprop("services/bus/bus2-enable", getprop("aircraft/settings/services/bus/bus2") or 0);
            #Safety Cones
            setprop("services/cones/cone1-enable", getprop("aircraft/settings/services/cones/cone1") or 0);
            setprop("services/cones/cone2-enable", getprop("aircraft/settings/services/cones/cone2") or 0);
            #Air Start Unit
            setprop("services/ASU/enable", getprop("aircraft/settings/services/ASU/enable") or 0);
            setprop("services/ASU/hose1-enable", getprop("aircraft/settings/services/ASU/hose1-enable") or 0);
            setprop("services/ASU/hose2-enable", getprop("aircraft/settings/services/ASU/hose2-enable") or 0);
            #De-icing trucks
            setprop("services/deicing_truck/de-ice", getprop("aircraft/settings/services/deicing_truck/de-ice") or 0);
            setprop("services/deicing_truck/enable", getprop("aircraft/settings/services/deicing_truck/enable") or 0);
            for (var i = 0; i <= 4; i += 1) {
                setprop("services/deicing_truck/truck[" ~ i ~ "]/position-norm", getprop("aircraft/settings/services/deicing_truck/truck[" ~ i ~ "]/position-norm") or 0);
                setprop("services/deicing_truck/crane[" ~ i ~ "]/position-norm", getprop("aircraft/settings/services/deicing_truck/crane[" ~ i ~ "]/position-norm") or 0);
                setprop("services/deicing_truck/deicing[" ~ i ~ "]/position-norm", getprop("aircraft/settings/services/deicing_truck/deicing[" ~ i ~ "]/position-norm") or 0);
            }
            print("Ground services ..... Loaded");
        }
        else
        {
            setprop("controls/gear/brake-parking", 1);
        };
    };
    
};

setlistener("sim/signals/fdm-initialized", func {
    load_state();
});

setlistener("sim/signals/exit", func {
    save_state();
});

setlistener("sim/signals/reinit", func {
    save_state();
});
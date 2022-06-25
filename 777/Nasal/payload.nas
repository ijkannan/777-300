#Ground Services added by Isaak Dieleman.

var cattruck0 = aircraft.door.new("services/catering/truck[0]", 15, 1);
var cattruck1 = aircraft.door.new("services/catering/truck[1]", 25, 1);
var cattruck2 = aircraft.door.new("services/catering/truck[2]", 22, 1);
var cattruck3 = aircraft.door.new("services/catering/truck[3]", 20, 1);
var catcargo0 = aircraft.door.new("services/catering/truck[0]/cargo", 25);
var catcargo1 = aircraft.door.new("services/catering/truck[1]/cargo", 24);
var catcargo2 = aircraft.door.new("services/catering/truck[2]/cargo", 27);
var catcargo3 = aircraft.door.new("services/catering/truck[3]/cargo", 26);
var activetruck = 0;
var activetrolley = 0;
var catloadstatus = 0;
var catconnect0 = 0;
var catconnect1 = 0;
var catconnect2 = 0;
var catconnect3 = 0;

var payload_boarding = {
    init : func {
    
    # pax
    
    props.globals.initNode("services/payload/first-request-nr", 0);
    props.globals.initNode("services/payload/first-onboard-nr", 0);
    props.globals.initNode("services/payload/first-onboard-lbs", 0);
    props.globals.initNode("services/payload/business-request-nr", 0);
    props.globals.initNode("services/payload/business-onboard-nr", 0);
    props.globals.initNode("services/payload/business-onboard-lbs", 0);
    props.globals.initNode("services/payload/economy-request-nr", 0);
    props.globals.initNode("services/payload/economy-onboard-nr", 0);
    props.globals.initNode("services/payload/economy-onboard-lbs", 0);
    props.globals.initNode("services/payload/pax-request-nr", 0);
    props.globals.initNode("services/payload/pax-onboard-nr", 0);
    props.globals.initNode("services/payload/pax-onboard-lbs", 0);
    props.globals.initNode("services/payload/pax-random-nr", 0);
    props.globals.initNode("services/payload/pax-boarding", 0);
    props.globals.initNode("services/payload/pax-force-deboard", 0);
    props.globals.initNode("services/stairs/stairs1_enable", 0);
    props.globals.initNode("services/stairs/stairs2_enable", 0);
    props.globals.initNode("services/stairs/stairs3_enable", 0);
    props.globals.initNode("services/stairs/stairs4_enable", 0);
    props.globals.initNode("services/stairs/paint-end", "blue-shade.png");
    props.globals.initNode("services/stairs/cover", 1);
    props.globals.initNode("services/payload/passenger-added", 0);
    props.globals.initNode("services/payload/passenger-removed", 0);
    props.globals.initNode("services/payload/speed", 6.0); #This defines the loading/boarding cycle speed. 6.0 equals 1 cycle every 6 seconds.
    props.globals.initNode("services/payload/SOB-nr", 0);
    props.globals.initNode("services/payload/jetway1_enable", 0);
    props.globals.initNode("services/payload/jetway2_enable", 0);
    props.globals.initNode("services/payload/boardingtime_remaining", " ");
    props.globals.initNode("services/payload/speed-text", "Normal");
    props.globals.initNode("services/payload/boardingcomplete", 0);
    
    # Baggage
    
    props.globals.initNode("services/payload/belly-request-lbs", 0);
    props.globals.initNode("services/payload/belly-onboard-lbs", 0);
    props.globals.initNode("services/payload/baggage-loading", 0);
    props.globals.initNode("services/payload/baggage-truck1-enable", 0);
    props.globals.initNode("services/payload/baggage-truck2-enable", 0);
    props.globals.initNode("services/payload/baggage-speed", 0);
    props.globals.initNode("services/payload/loadingtime_remaining", " ");
    props.globals.initNode("services/payload/loadingcomplete", 0);
    
    # Catering
    
    props.globals.initNode("services/catering/request-lbs", 0);
    props.globals.initNode("services/catering/weight-lbs", 0);
    props.globals.initNode("services/catering/loading", 0);
    props.globals.initNode("services/catering/total-trolley-nr", 0);
    props.globals.initNode("services/catering/time_remaining", " ");
    props.globals.initNode("services/catering/complete", 0);
    props.globals.initNode("services/catering/truck[0]/max-trolley-nr", 20);
    props.globals.initNode("services/catering/truck[1]/max-trolley-nr", 25);
    props.globals.initNode("services/catering/truck[2]/max-trolley-nr", 20);
    props.globals.initNode("services/catering/truck[3]/max-trolley-nr", 30);
    props.globals.initNode("services/catering/truck[0]/max-weight-lbs", 1850);
    props.globals.initNode("services/catering/truck[1]/max-weight-lbs", 2325);
    props.globals.initNode("services/catering/truck[2]/max-weight-lbs", 1850);
    props.globals.initNode("services/catering/truck[3]/max-weight-lbs", 2675);
    for (var i = 0; i <= 3; i += 1) {
        props.globals.initNode("services/catering/truck[" ~ i ~ "]/trolley-nr", 0);
        props.globals.initNode("services/catering/truck[" ~ i ~ "]/weight-lbs", 0);
        props.globals.initNode("services/catering/truck[" ~ i ~ "]/complete", 1);
        for (var j = 0; j <= getprop("services/catering/truck[" ~ i ~ "]/max-trolley-nr") - 1; j += 1) {
            props.globals.initNode("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", 0);
        }
    }
    cattruck0.enable(0);
    cattruck1.enable(0);
    cattruck2.enable(0);
    cattruck3.enable(0);
    
    # Crew
    
    props.globals.initNode("services/payload/crew-request-nr", 2.0);
    props.globals.initNode("services/payload/crew-onboard-nr", 2.0);
    props.globals.initNode("services/payload/crew-onboard-lbs", 300.0);

    _startstop();

    },
    
    update : func {
        
        #Keep the dialog up to date and prepare some values for calculations
        
        setprop("services/payload/pax-request-nr", getprop("services/payload/first-request-nr") + getprop("services/payload/business-request-nr") + getprop("services/payload/economy-request-nr"));
                
        #Passenger boarding
        
        # First: each passenger weighs between 85 and 189 Lbs (random for each passenger) and has 110 Lbs of luggage
        # Business: each passenger weighs between 85 and 189 Lbs (random for each passenger) and has 88 Lbs of luggage
        # Economy: each passenger weighs between 85 and 189 Lbs (random for each passenger) and has 33 Lbs of luggage
        
        # Passengers are boarding quite randomly (classwise) and the same amount of passengers will weigh a different amount with each flight. The average should be around the worldwide average weight of 137 Lbs pp.
        # First class passengers will only (de)board via door 1L, unless it is not connected with a staircase or jetway, in that case they will (de)board via door 2L. They will never (de)board via door 3L or 4L.
        # Business class passengers will only (de)board via door 1L and 2L, never via door 3L or 4L.
        # Economy class passengers will only (de)board via door 2L, 3L and 4L, not via door 1L, unless door 1L is the only one with a staircase or jetway connected. Only in that case they will (de)board via door 1L.
        # This boarding system can greatly affect the estimated (de)boarding speed in the weight & payload dialog.
        
        # The jetway toggles in the weight dialog only affect the boarding speed, they don't move jetways, because the AI jetway system is unable to do that. You still have to extend/retract the jetways separatly.
        
        if (getprop("services/payload/pax-boarding") == 1) {
        
            #If no stairs or Jetways are connected, cancel the boarding process.
            
            if (getprop("services/stairs/stairs1_enable") + getprop("services/stairs/stairs2_enable") + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable") + getprop("services/payload/jetway1_enable") + getprop("services/payload/jetway2_enable") == 0) {
                setprop("services/payload/pax-boarding", 0);
                screen.log.write("Captain, we cannot continue boarding, the stairs or jetways have been disconnected.", 1, 0, 0);
            }
            
            if (getprop("services/payload/pax-onboard-nr") < getprop("services/payload/pax-request-nr")) {
                
                # If Door 1L stairs or jetway are connected, a first, business or economy (only if no other stairs/jetways are connected) passenger is added every cycle
                
                # This random number defines which type of passenger (first/business/economy) is boarding in this cycle.
                setprop("services/payload/pax-random-nr", math.round(rand() * getprop("services/payload/pax-request-nr")));
                
                if ((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) {
                
                    if (getprop("services/payload/first-onboard-nr") < getprop("services/payload/first-request-nr")) {			    
                        if ((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) > (getprop("services/payload/first-request-nr"))) {
                            if (getprop("services/payload/pax-random-nr") <= getprop("services/payload/first-request-nr")) {
                                setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") + 1.0);
                                setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") + 195 + math.round(rand() * 104)));
                                setprop("services/payload/passenger-added", 1);
                            }
                        } else {
                            setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") + 1.0);
                            setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") + 195 + math.round(rand() * 104)));
                            setprop("services/payload/passenger-added", 1);
                        }
                    }
                    
                    # Economy passengers will only board here if no other stairs or jetways are connected.
                    
                    if ((getprop("services/payload/passenger-added") != 1) and (getprop("services/payload/economy-onboard-nr") < getprop("services/payload/economy-request-nr")) and (getprop("services/stairs/stairs2_enable") == 0) and (getprop("services/stairs/stairs3_enable") == 0) and (getprop("services/stairs/stairs4_enable") == 0) and (getprop("services/payload/jetway2_enable") == 0)) {			    
                        if ((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) > (getprop("services/payload/economy-request-nr"))) {
                            if (getprop("services/payload/pax-random-nr") >= (getprop("services/payload/pax-request-nr") - getprop("services/payload/economy-request-nr"))) {
                                setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1.0);
                                setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                                setprop("services/payload/passenger-added", 1);
                            }
                        } else {
                            setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1.0);
                            setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                            setprop("services/payload/passenger-added", 1);
                        }
                    }
                    
                    if (getprop("services/payload/passenger-added") != 1) {
                        if (getprop("services/payload/business-onboard-nr") < getprop("services/payload/business-request-nr")) {
                            setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") + 1.0);
                            setprop("services/payload/business-onboard-lbs", math.round(getprop("services/payload/business-onboard-lbs") + 173 + rand() * 104));
                        }
                    }
                }
                
                setprop("services/payload/passenger-added", 0);
                
                # if door 2L staircase or jetway is connected, an extra first (only if door 1L staircase/jetway is not connected), business or economy passenger is added every cycle because they can board faster.
                
                setprop("services/payload/pax-random-nr", math.round(rand() * getprop("services/payload/pax-request-nr")));
                
                if ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) {
                    
                    #First class passengers will only board here if there are no stairs or jetway connected to Door 1L.
                    
                    if ((getprop("services/stairs/stairs1_enable") == 0) and (getprop("services/payload/jetway1_enable") == 0)) {
                        if (getprop("services/payload/first-onboard-nr") < getprop("services/payload/first-request-nr")) {			    
                            if ((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) > (getprop("services/payload/first-request-nr"))) {
                                if (getprop("services/payload/pax-random-nr") <= getprop("services/payload/first-request-nr")) {
                                    setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") + 1.0);
                                    setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") + 195 + math.round(rand() * 104)));
                                    setprop("services/payload/passenger-added", 1);
                                }
                            } else {
                                setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") + 1.0);
                                setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") + 195 + math.round(rand() * 104)));
                                setprop("services/payload/passenger-added", 1);
                            }
                        }
                    }
                    
                    if ((getprop("services/payload/passenger-added") != 1) and (getprop("services/payload/economy-onboard-nr") < getprop("services/payload/economy-request-nr"))) {			    
                        if ((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) > (getprop("services/payload/economy-request-nr"))) {
                            if (getprop("services/payload/pax-random-nr") >= (getprop("services/payload/pax-request-nr") - getprop("services/payload/economy-request-nr"))) {
                                setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1.0);
                                setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                                setprop("services/payload/passenger-added", 1);
                            }
                        } else {
                            setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1.0);
                            setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                            setprop("services/payload/passenger-added", 1);
                        }
                    }
                    
                    if (getprop("services/payload/passenger-added") != 1) {
                        if (getprop("services/payload/business-onboard-nr") < getprop("services/payload/business-request-nr")) {
                            setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") + 1.0);
                            setprop("services/payload/business-onboard-lbs", math.round(getprop("services/payload/business-onboard-lbs") + 173 + rand() * 104));
                        }
                    }
                }
                
                #if the staircase of Door 3L is connected, an extra economy passenger is added every cycle because they can board faster.
                
                if (getprop("services/stairs/stairs3_enable") == 1) {
                    if (getprop("services/payload/economy-onboard-nr") < getprop("services/payload/economy-request-nr")) {
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1);
                        setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                    }
                }
                
                #if the staircase of Door 4L is connected, an extra economy passenger is added every cycle because they can board faster.
                
                if (getprop("services/stairs/stairs4_enable") == 1) {
                    if (getprop("services/payload/economy-onboard-nr") < getprop("services/payload/economy-request-nr")) {
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") + 1);
                        setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") + 118 + rand() * 104));
                    }
                }
                
                setprop("services/payload/passenger-added", 0);
                
                #####
                #Calculate the estimated remaining time (this is not so easy, as it depends on which stairs/jetway combination is connected; it will always be an estimate because we can't know on forehand which random passenger will be added in the next cycles).
                #####
                
                if (((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) and ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) and ((getprop("services/stairs/stairs3_enable") == 1) or (getprop("services/stairs/stairs4_enable")))) {
                
                # Stairs/jetways 1, 2 and 3 and/or 4 connected.
                
                    if ((getprop("services/payload/economy-request-nr") > getprop("services/payload/economy-onboard-nr"))) {
                        if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {
                            setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / (1 + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        } else {
                            setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        }
                    } else {
                        setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    }
                
                } elsif (((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) and ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) and (getprop("services/stairs/stairs3_enable") != 1) and (getprop("services/stairs/stairs4_enable") != 1)) {
                
                # Stairs/jetways 1 and 2 connected, stairs 3 and 4 not connected
                    if ((getprop("services/payload/economy-request-nr") > getprop("services/payload/economy-onboard-nr"))) {
                        if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {
                            setprop("services/payload/boardingtime_remaining", math.round((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        } else {
                            setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        }
                    } else {
                        setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    }
                } elsif (((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) and ((getprop("services/stairs/stairs2_enable") != 1) and (getprop("services/payload/jetway2_enable") != 1)) and (getprop("services/stairs/stairs3_enable") == 1)) {
                
                # Stairs/jetways 1 and 3 and/or 4 connected, stairs/jetway 2 not connected
                    if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {
                        if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {						
                            setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / (1 + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        } else {
                            setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        }
                    } else {
                        setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    }
                } elsif (((getprop("services/stairs/stairs1_enable") != 1) and (getprop("services/payload/jetway1_enable") != 1)) and ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) and (getprop("services/stairs/stairs3_enable") == 1)) {
                
                # Stairs/jetways 2 and 3 and/or 4 connected, stairs/jetway 1 not connected
                    if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {
                        if ((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) > (getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr"))) {						
                            setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / (1 + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        } else {
                            setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                        }
                    } else {
                        setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/business-request-nr") - getprop("services/payload/business-onboard-nr") + getprop("services/payload/first-request-nr") - getprop("services/payload/first-onboard-nr")) / 2) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    }
                } elsif (((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) or ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) and (getprop("services/stairs/stairs3_enable") != 1) and (getprop("services/stairs/stairs4_enable") != 1)) {
                
                # Only 1 of stair/jetway 1 or 2 connected, stairs 3, 4 and the other one not connected
                    setprop("services/payload/boardingtime_remaining", math.round((getprop("services/payload/pax-request-nr") - getprop("services/payload/pax-onboard-nr")) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                } elsif (((getprop("services/stairs/stairs1_enable") != 1) and (getprop("services/payload/jetway1_enable") != 1)) and ((getprop("services/stairs/stairs2_enable") != 1) or (getprop("services/payload/jetway2_enable") != 1)) and (getprop("services/stairs/stairs3_enable") == 1)) {
                
                # Only stairs 3 and/or 4 connected, stairs/jetways 1 and 2 not connected. This means that first and business are unable to board the plane.
                    setprop("services/payload/boardingtime_remaining", math.round(((getprop("services/payload/economy-request-nr") - getprop("services/payload/economy-onboard-nr")) / (getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
                    screen.log.write("Captain, first and business class passengers are unable to board, Door 1L and 2L are not accessible for them. Please enable another stairs or jetway before we continue boarding.", 1, 0, 0);
                    setprop("services/payload/boardingcomplete", 1);
                    setprop("services/payload/pax-boarding", 0);
                }
                setprop("services/payload/pax-onboard-nr", (getprop("services/payload/first-onboard-nr") + getprop("services/payload/business-onboard-nr") + getprop("services/payload/economy-onboard-nr")));
                setprop("services/payload/pax-onboard-lbs", (getprop("services/payload/first-onboard-lbs") + getprop("services/payload/business-onboard-lbs") + getprop("services/payload/economy-onboard-lbs")));
            } else {
                setprop("services/payload/pax-boarding", 0);
                setprop("services/payload/boardingtime_remaining", " ");
                setprop("services/payload/boardingcomplete", 1);
                screen.log.write("Boarding complete. " ~ getprop("services/payload/pax-onboard-nr") ~ " pax on board, weighing " ~ getprop("services/payload/pax-onboard-lbs") ~ " Lbs.", 0, 0.584, 1);
                if (getprop("aircraft/settings/gnd_autodisconnect") == 1) {
                    setprop("services/payload/jetway1_enable", 0);
                    setprop("services/payload/jetway2_enable", 0);
                    setprop("services/stairs/stairs1_enable", 0);
                    setprop("services/stairs/stairs2_enable", 0);
                    setprop("services/stairs/stairs3_enable", 0);
                    setprop("services/stairs/stairs4_enable", 0);
                }
            }
            
        #Deboarding
        
        } elsif (getprop("services/payload/pax-boarding") == 2) {
            setprop("services/payload/weight-total-lbs", getprop("services/payload/pax-onboard-lbs") + getprop("services/payload/belly-onboard-lbs"));
            setprop("services/payload/boardingtime_remaining", math.round(getprop("services/payload/pax-onboard-nr") / (getprop("services/stairs/stairs1_enable") + getprop("services/stairs/stairs2_enable") + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable") + getprop("services/payload/jetway1_enable") + getprop("services/payload/jetway2_enable")) / 60 * getprop("services/payload/speed")) ~ "min Remaining.");
            
            if (getprop("services/stairs/stairs1_enable") + getprop("services/stairs/stairs2_enable") + getprop("services/stairs/stairs3_enable") + getprop("services/stairs/stairs4_enable") + getprop("services/payload/jetway1_enable") + getprop("services/payload/jetway2_enable") == 0) {
                setprop("services/payload/pax-boarding", 0);
                screen.log.write("Captain, we cannot continue deboarding, the stairs or jetways have been disconnected.", 1, 0, 0);
            }
            
            if ((getprop("services/payload/weight-total-lbs") <= getprop("sim/weight[1]/max-lb")) or (getprop("services/payload/pax-force-deboard") == 1))  {
                
                # Door 1L deboarding
                
                if ((getprop("services/stairs/stairs1_enable") == 1) or (getprop("services/payload/jetway1_enable") == 1)) {
                    if (getprop("services/payload/first-onboard-nr") > 0) {
                        setprop("services/payload/first-onboard-lbs", math.round((getprop("services/payload/first-onboard-lbs") - (getprop("services/payload/first-onboard-lbs") / getprop("services/payload/first-onboard-nr")))));
                        setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") - 1.0);
                        setprop("services/payload/passenger-removed", 1);
                    } elsif ((getprop("services/payload/business-onboard-nr") > 0) and (getprop("services/payload/passenger-removed") != 1)) {
                        setprop("services/payload/business-onboard-lbs", math.round((getprop("services/payload/business-onboard-lbs") - (getprop("services/payload/business-onboard-lbs") / getprop("services/payload/business-onboard-nr")))));
                        setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") - 1.0);
                        setprop("services/payload/passenger-removed", 1);
                    # Economy passengers will only deboard here if no other stairs or jetways are connected.
                    } elsif ((getprop("services/payload/economy-onboard-nr") > 0) and (getprop("services/payload/passenger-removed") != 1) and (getprop("services/stairs/stairs2_enable") == 0) and (getprop("services/stairs/stairs3_enable") == 0) and (getprop("services/stairs/stairs4_enable") == 0) and (getprop("services/payload/jetway2_enable") == 0)) {
                        setprop("services/payload/economy-onboard-lbs", math.round((getprop("services/payload/economy-onboard-lbs") - (getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")))));
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
                    }
                }
                
                # if door 2L staircase or jetway is enabled, an extra first (only if Door 1L stairs or jetways are not connected), business or economy passenger is removed every cycle because they can deboard faster.
                
                setprop("services/payload/passenger-removed", 0);
                
                #First class passengers only deboard here if Door 1L stairs/jetways are not connected.	
                
                if ((getprop("services/stairs/stairs2_enable") == 1) or (getprop("services/payload/jetway2_enable") == 1)) {
                    if ((getprop("services/stairs/stairs1_enable") == 0) and (getprop("services/payload/jetway1_enable") == 0)) {
                        if (getprop("services/payload/first-onboard-nr") > 0) {
                            setprop("services/payload/first-onboard-lbs", math.round((getprop("services/payload/first-onboard-lbs") - (getprop("services/payload/first-onboard-lbs") / getprop("services/payload/first-onboard-nr")))));
                            setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") - 1.0);
                            setprop("services/payload/passenger-removed", 1);
                        }
                    }
                    if (getprop("services/payload/passenger-removed") == 0) {
                        if (getprop("services/payload/business-onboard-nr") > 0) {
                            setprop("services/payload/business-onboard-lbs", math.round((getprop("services/payload/business-onboard-lbs") - (getprop("services/payload/business-onboard-lbs") / getprop("services/payload/business-onboard-nr")))));
                            setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") - 1.0);
                        } elsif (getprop("services/payload/economy-onboard-nr") > 0) {
                            setprop("services/payload/economy-onboard-lbs", math.round((getprop("services/payload/economy-onboard-lbs") - (getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")))));
                            setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
                        }
                    }
                }
                
                # if Door 3L stairs are enabled, an extra economy passenger is removed every cycle because they can deboard faster.
                
                if (getprop("services/stairs/stairs3_enable") == 1) {
                    if (getprop("services/payload/economy-onboard-nr") > 0) {
                        setprop("services/payload/economy-onboard-lbs", math.round((getprop("services/payload/economy-onboard-lbs") - (getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")))));
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
                    }
                }
                
                # if Door 4L stairs are enabled, an extra economy passenger is removed every cycle because they can deboard faster.
                
                if (getprop("services/stairs/stairs4_enable") == 1) {
                    if (getprop("services/payload/economy-onboard-nr") > 0) {
                        setprop("services/payload/economy-onboard-lbs", math.round((getprop("services/payload/economy-onboard-lbs") - (getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")))));
                        setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
                    }
                }
            
            } else {
                setprop("services/payload/pax-boarding", 3);
            }
            setprop("services/payload/passenger-removed", 0);
            setprop("services/payload/pax-onboard-nr", (getprop("services/payload/first-onboard-nr") + getprop("services/payload/business-onboard-nr") + getprop("services/payload/economy-onboard-nr")));
            setprop("services/payload/pax-onboard-lbs", (getprop("services/payload/first-onboard-lbs") + getprop("services/payload/business-onboard-lbs") + getprop("services/payload/economy-onboard-lbs")));
            
            # Stop deboarding if all passengers have left the airplane.
            if (getprop("services/payload/pax-onboard-nr") < 1) {
                setprop("services/payload/pax-boarding", 0);
                setprop("services/payload/pax-force-deboard", 0);
                setprop("services/payload/boardingtime_remaining", " ");
                screen.log.write("Deboarding complete.", 0, 0.584, 1);
                setprop("services/payload/boardingcomplete", 1);
            }
            
        
        #Deboarding a few passengers when over the maximum loading weight. This enables the user to choose which passengers he wants to remove.
        
        } elsif (getprop("services/payload/pax-boarding") == 3) {			
            if (getprop("services/payload/first-request-nr") < getprop("services/payload/first-onboard-nr")) {
                setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-onboard-lbs") - getprop("services/payload/first-onboard-lbs") / getprop("services/payload/first-onboard-nr")));
                setprop("services/payload/first-onboard-nr", getprop("services/payload/first-onboard-nr") - 1.0);
            } elsif (getprop("services/payload/business-request-nr") < getprop("services/payload/business-onboard-nr")) {
                setprop("services/payload/business-onboard-lbs", math.round(getprop("services/payload/business-onboard-lbs") - getprop("services/payload/business-onboard-lbs") / getprop("services/payload/business-onboard-nr")));
                setprop("services/payload/business-onboard-nr", getprop("services/payload/business-onboard-nr") - 1.0);
            } elsif (getprop("services/payload/economy-request-nr") < getprop("services/payload/economy-onboard-nr")) {
                setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-onboard-lbs") - getprop("services/payload/economy-onboard-lbs") / getprop("services/payload/economy-onboard-nr")));
                setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-onboard-nr") - 1.0);
            } else {
                if (getprop("services/payload/weight-total-lbs") < (getprop("sim/weight[1]/max-lb") + getprop("sim/weight[0]/max-lb"))) {
                    setprop("services/payload/pax-boarding", 0);
                    setprop("services/payload/pax-force-deboard", 0);
                    screen.log.write("Captain, a few passengers have deboarded. We can safely travel now.", 0, 0.584, 1);
                } else {
                    setprop("services/payload/pax-boarding", 2);
                    setprop("services/payload/pax-force-deboard", 1);
                    screen.log.write("Captain, we still are not light enough, we will continue deboarding, please stop the deboarding process manually.", 1, 0, 0);
                }
            }
            
            setprop("services/payload/passenger-removed", 0);
            setprop("services/payload/pax-onboard-nr", (getprop("services/payload/first-onboard-nr") + getprop("services/payload/business-onboard-nr") + getprop("services/payload/economy-onboard-nr")));
            setprop("services/payload/pax-onboard-lbs", (getprop("services/payload/first-onboard-lbs") + getprop("services/payload/business-onboard-lbs") + getprop("services/payload/economy-onboard-lbs")));
        }
        
        #Baggage Loading
        
        #This works easier than boarding passengers. Between 50 and 250 Lbs is loaded/unloaded per baggage truck per cycle, averaging around 150 Lbs per cycle.
        
        if (getprop("services/payload/baggage-loading") == 1) {
            
            # Baggage Loading
            # Define loading speed based on the number of baggage trucks connected.
            setprop("services/payload/baggage-speed", math.round((getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable")) * (50 + rand() * 200)));
            setprop("services/payload/loadingtime_remaining", math.round((getprop("services/payload/belly-request-lbs") - getprop("services/payload/belly-onboard-lbs")) / (150 * (getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
            if (getprop("services/payload/belly-onboard-lbs") < getprop("services/payload/belly-request-lbs")) {
                setprop("services/payload/belly-onboard-lbs", getprop("services/payload/belly-onboard-lbs") + getprop("/services/payload/baggage-speed"));
                if (getprop("services/payload/belly-onboard-lbs") >= getprop("services/payload/belly-request-lbs")) {
                    setprop("services/payload/belly-onboard-lbs", getprop("services/payload/belly-request-lbs"));
                    setprop("services/payload/baggage-loading", 0);
                    screen.log.write("Baggage loading complete.", 0, 0.584, 1);
                    setprop("services/payload/loadingtime_remaining", " ");
                    setprop("services/payload/loadingcomplete", 1);
                    if (getprop("aircraft/settings/gnd_autodisconnect") == 1) {
                        setprop("services/payload/baggage-truck1-enable", 0);
                        setprop("services/payload/baggage-truck2-enable", 0);
                    }
                }
            }
            
        } elsif (getprop("services/payload/baggage-loading") == 2) {
            #Define unloading speed based on the number of baggage trucks connected.
            setprop("services/payload/baggage-speed", math.round((getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable")) * (50 + rand() * 200)));
            setprop("services/payload/loadingtime_remaining", math.round(getprop("services/payload/belly-onboard-lbs") / (150 * (getprop("services/payload/baggage-truck1-enable") + getprop("services/payload/baggage-truck2-enable"))) / 60 * getprop("services/payload/speed")) ~ " min remaining");
            #unload
            if (getprop("services/payload/belly-onboard-lbs") > 0) {
                if (getprop("services/payload/belly-onboard-lbs") <= getprop("services/payload/baggage-speed")) {
                    setprop("services/payload/belly-onboard-lbs", 0);
                    setprop("services/payload/baggage-loading", 0);
                    setprop("services/payload/loadingtime_remaining", " ");
                    screen.log.write("Baggage unloading complete.", 0, 0.584, 1);
                    setprop("services/payload/loadingcomplete", 1);
                } else {
                    setprop("services/payload/belly-onboard-lbs", getprop("services/payload/belly-onboard-lbs") - getprop("services/payload/baggage-speed"))
                }
            }
        }
        
        
        # Catering Loading
        # Every cycle 1 catering truck loads 1 catering trolley of 60 to 100 lbs into the aircraft.
        # Unconnected trucks (with their associated galleys) are automatically skipped
        # Trucks that have full galleys are automatically disconnected.
        
        catloadstatus = getprop("services/catering/loading");
        if (catloadstatus == 1) {
            if ((getprop("services/catering/total-trolley-nr") < getprop("services/catering/max-trolley-nr")) and (getprop("services/catering/weight-lbs") < getprop("services/catering/request-lbs"))) {
                #Load another trolley
                var truckcomplete = getprop("services/catering/truck[" ~ activetruck ~ "]/complete");
                while (truckcomplete == 1) {
                    if ((getprop("services/catering/truck[0]/complete") == 1) and (getprop("services/catering/truck[1]/complete") == 1) and (getprop("services/catering/truck[2]/complete") == 1) and (getprop("services/catering/truck[3]/complete") == 1)) {
                        # if all trucks are disconnected: stop loading and throw a message
                        if (getprop("services/catering/max-trolley-nr") - getprop("services/catering/total-trolley-nr") > 0) {
                            screen.log.write("No more catering trucks connected. Please reconnect them to resume catering loading.", 1, 0, 0);
                            setprop("services/catering/loading", 0);
                            setprop("services/catering/complete", 1); # trigger sound
                            setprop("services/catering/complete", 0);
                            setprop("services/catering/time_remaining", "Reconnect!");
                            break;
                        }
                    }
                    activetruck += 1;
                    if (activetruck > 3) {
                        activetruck = 0;
                    }
                    truckcomplete = getprop("services/catering/truck[" ~ activetruck ~ "]/complete");
                }
                
                if (truckcomplete == 0) { # make sure the active truck is enabled (so this code is skipped if all trucks are disconnected and the while loop has broken.
                    var newtrolleyweight = math.round(60 + rand() * 40); # define the weight of the new trolley. Add some randomness
                    var trucktrolleys = getprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr");
                    var truckmaxtrolleys = getprop("services/catering/truck[" ~ activetruck ~ "]/max-trolley-nr");
                    var truckweight = getprop("services/catering/truck[" ~ activetruck ~ "]/weight-lbs");
                    var truckmaxweight = getprop("services/catering/truck[" ~ activetruck ~ "]/max-weight-lbs");
                    activetrolley = getprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr");

                    if ((activetrolley <= truckmaxtrolleys - 1) and (truckweight < truckmaxweight)) { # a 99 lbs weight overshoot is possible in theory, but this is no big deal and keeps the code much simpler.
                        setprop("services/catering/truck[" ~ activetruck ~ "]/trolley[" ~ activetrolley ~ "]/weight-lbs", newtrolleyweight);
                        setprop("services/catering/truck[" ~ activetruck ~ "]/weight-lbs", truckweight + newtrolleyweight);
                        setprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr", getprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr") + 1);
                        setprop("services/catering/weight-lbs", getprop("services/catering/weight-lbs") + newtrolleyweight);
                        setprop("services/catering/total-trolley-nr", getprop("services/catering/total-trolley-nr") + 1);
                    } elsif (getprop("services/catering/truck[" ~ activetruck ~ "]/complete") == 0) {
                        # truck ready, its galley is full. Throw a message
                        screen.log.write("Catering truck " ~ (int(activetruck) + 1) ~ " ready.", 0, 0.584, 1);
                        if (getprop("aircraft/settings/gnd_autodisconnect") == 1) {
                            setprop("services/catering/truck[" ~ activetruck ~ "]/connect", 0);
                        }
                        setprop("services/catering/truck[" ~ activetruck ~ "]/complete", 1);
                    }
                    # end of loading cycle
                    if (activetruck == 3) {
                        activetruck = 0;
                    } else {
                        activetruck += 1;
                    }
                }
            } else {
                # Catering finished
                var trolleytotal = getprop("services/catering/total-trolley-nr");
                var weighttotal = sprintf("%i", getprop("services/catering/weight-lbs"));
                var msg = "";
                setprop("services/catering/loading", 0);
                setprop("services/catering/complete", 1);
                setprop("services/catering/time_remaining", " ");
                if (getprop("aircraft/settings/gnd_autodisconnect") == 1) {
                    setprop("services/catering/truck[0]/connect", 0);
                    setprop("services/catering/truck[0]/complete", 1);
                    setprop("services/catering/truck[1]/connect", 0);
                    setprop("services/catering/truck[1]/complete", 1);
                    setprop("services/catering/truck[2]/connect", 0);
                    setprop("services/catering/truck[2]/complete", 1);
                    setprop("services/catering/truck[3]/connect", 0);
                    setprop("services/catering/truck[3]/complete", 1);
                    msg = " Catering trucks disconnected.";
                }
                activetruck = 0;
                activetrolley = 0;
                catloadstatus = 0;
                screen.log.write("Catering loading complete. " ~ weighttotal ~ "Lbs. loaded in " ~ trolleytotal ~ " trolleys." ~ msg, 0, 0.584, 1);
            }
            
            # Calculate time remaining

            if (catloadstatus == 1) {
            weightremaining = getprop("services/catering/request-lbs") - getprop("services/catering/weight-lbs");
            setprop("services/catering/time_remaining", math.floor(weightremaining / 80 / 60 * getprop("services/payload/speed")) ~ " min remaining");
            } else {
            setprop("services/catering/time_remaining", " ");
            }
        
        #Catering unloading
        } elsif (catloadstatus == 2) {
            if (getprop("services/catering/weight-lbs") > 0) {
                #Unload another trolley
                var truckcomplete = getprop("services/catering/truck[" ~ activetruck ~ "]/complete");
                while (truckcomplete == 1) {
                    if ((getprop("services/catering/truck[0]/complete") == 1) and (getprop("services/catering/truck[1]/complete") == 1) and (getprop("services/catering/truck[2]/complete") == 1) and (getprop("services/catering/truck[3]/complete") == 1)) {
                        # if all trucks are disconnected: stop loading and throw a message
                        screen.log.write("No more catering trucks connected. Please reconnect them to resume unloading.", 1, 0, 0);
                        setprop("services/catering/loading", 0);
                        setprop("services/catering/complete", 1); # trigger sound
                        setprop("services/catering/complete", 0);
                        setprop("services/catering/time_remaining", "Reconnect!");
                        break;
                    }
                    activetruck += 1;
                    if (activetruck > 3) {
                        activetruck = 0;
                    }
                    truckcomplete = getprop("services/catering/truck[" ~ activetruck ~ "]/complete");
                }
                
                if (truckcomplete == 0) { # Make sure there still is something to unload from this catering galley.
                    
                    activetrolley = getprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr") - 1;
                    if (activetrolley < 0) {
                        setprop("services/catering/weight-lbs", getprop("services/catering/weight-lbs") - getprop("services/catering/truck[" ~ activetruck ~ "]/weight-lbs"));
                        setprop("services/catering/truck[" ~ activetruck ~ "]/weight-lbs", 0);
                        setprop("services/catering/total-trolley-nr", getprop("services/catering/total-trolley-nr") - getprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr"));
                        setprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr", 0);
                        for (var i = 0; i <= getprop("services/catering/truck[" ~ activetruck ~ "]/max-trolley-nr") - 1; i += 1) {
                            setprop("services/catering/truck[" ~ activetruck ~ "]/trolley[" ~ i ~ "]/weight-lbs", 0);
                        }
                        setprop("services/catering/truck[" ~ activetruck ~ "]/complete", 1);
                    } else {
                        
                        var truckweight = getprop("services/catering/truck[" ~ activetruck ~ "]/weight-lbs");
                        var trolleyweight = getprop("services/catering/truck[" ~ activetruck ~ "]/trolley[" ~ activetrolley ~ "]/weight-lbs");
                        
                        if (trolleyweight == nil) {
                            trolleyweight = 0;
                        }
                        
                        if (trolleyweight > 0) {
                            setprop("services/catering/truck[" ~ activetruck ~ "]/trolley[" ~ activetrolley ~ "]/weight-lbs", 0);
                            truckweight -= trolleyweight;
                            setprop("services/catering/truck[" ~ activetruck ~ "]/weight-lbs", truckweight);
                            setprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr", getprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr") - 1);
                            setprop("services/catering/weight-lbs", getprop("services/catering/weight-lbs") - trolleyweight);
                            setprop("services/catering/total-trolley-nr", getprop("services/catering/total-trolley-nr") - 1);
                        } elsif ((truckweight == 0) and (getprop("services/catering/truck[" ~ activetruck ~ "]/complete") == 0)) { # disconnect catering truck
                                screen.log.write("Catering truck " ~ (int(activetruck) + 1) ~ " is ready. Its galley is empty.", 0, 0.584, 1);
                                setprop("services/catering/truck[" ~ activetruck ~ "]/complete", 1);
                        } elsif (truckweight < 0) { # failsafe
                            setprop("services/catering/truck[" ~ activetruck ~ "]/weight-lbs", 0);
                            setprop("services/catering/truck[" ~ activetruck ~ "]/trolley-nr", 0);
                            for (var i = 0; i <= getprop("services/catering/truck[" ~ activetruck ~ "]/max-trolley-nr") - 1; i += 1) {
                                setprop("services/catering/truck[" ~ activetruck ~ "]/trolley[" ~ i ~ "]/weight-lbs", 0);
                            }
                            setprop("services/catering/truck[" ~ activetruck ~ "]/complete", 1);
                        }
                    }
                    
                    # end of unloading cycle
                    if (activetruck == 3) {
                        activetruck = 0;
                    } else {
                        activetruck += 1;
                    }
                }
            } else {
                # Catering finished
                setprop("services/catering/loading", 0);
                setprop("services/catering/complete", 1);            
                activetruck = 0;
                catloadstatus = 0;
                screen.log.write("Catering unloading complete.", 0, 0.584, 1);
            }
            
            # Calculate time remaining
            
            if (catloadstatus == 2) {
                weightremaining = getprop("services/catering/weight-lbs");
                setprop("services/catering/time_remaining", math.floor(weightremaining / 80 / 60 * getprop("services/payload/speed")) ~ " min remaining");
            } else {
            setprop("services/catering/time_remaining", " ");
            }
        } else {
            activetruck = 0;
        }
        
        # Update Model properties and check if a new truck is connected to the aircraft.
        
        if (getprop("services/catering/truck[0]/enabled") == 1) {
            call( func {movetruck(0, getprop("services/catering/truck[0]/connect"))});
                if ((catconnect0 < catcargo0.getpos()) and (catcargo0.getpos() == 1) and (getprop("services/catering/truck[0]/connect") == 1)) {
                    setprop("services/catering/truck[0]/complete", 0);
                }
                catconnect0 = catcargo0.getpos();
        }
        if (getprop("services/catering/truck[1]/enabled") == 1) {
            call( func {movetruck(1, getprop("services/catering/truck[1]/connect"))});
                if ((catconnect1 < catcargo1.getpos()) and (catcargo1.getpos() == 1) and (getprop("services/catering/truck[1]/connect") == 1)) {
                    setprop("services/catering/truck[1]/complete", 0);
                }
                catconnect1 = catcargo1.getpos();
        }
        if (getprop("services/catering/truck[2]/enabled") == 1) {
            call( func {movetruck(2, getprop("services/catering/truck[2]/connect"))});
                if ((catconnect2 < catcargo2.getpos()) and (catcargo2.getpos() == 1) and (getprop("services/catering/truck[2]/connect") == 1)) {
                    setprop("services/catering/truck[2]/complete", 0);
                }
                catconnect2 = catcargo2.getpos();
        }
        if (getprop("services/catering/truck[3]/enabled") == 1) {
            call( func {movetruck(3, getprop("services/catering/truck[3]/connect"))});
                if ((catconnect3 < catcargo3.getpos()) and (catcargo3.getpos() == 1) and (getprop("services/catering/truck[3]/connect") == 1)) {
                    setprop("services/catering/truck[3]/complete", 0);
                }
                catconnect3 = catcargo3.getpos();
        }
        
        #Crew
        
        #We're assuming an average crew member weighs 137 Lbs, as does the average human, and has 13 lbs of luggage with him/her.
        #Changes are applied immediatly because doing this via a procedure is overkill.
        
        if (getprop("services/payload/crew-onboard-nr") != getprop("services/payload/crew-request-nr")) {
            setprop("services/payload/crew-onboard-nr", getprop("services/payload/crew-request-nr"));
            setprop("services/payload/crew-onboard-lbs", getprop("services/payload/crew-onboard-nr") * 150);
        }
        
        # Write to weight properties, but check if we are not overloading first.
        
        setprop("services/payload/weight-total-lbs", getprop("services/payload/pax-onboard-lbs") + getprop("services/payload/belly-onboard-lbs") + getprop("services/payload/crew-onboard-lbs") + getprop("services/catering/weight-lbs"));
        if ((getprop("services/payload/weight-total-lbs") >= getprop("sim/weight[1]/max-lb")) and ((getprop("services/payload/baggage-loading") == 1) or (getprop("services/payload/pax-boarding") == 1))) {
            setprop("services/payload/baggage-loading", 0);
            setprop("services/payload/pax-boarding", 0);
            screen.log.write("Captain, we are overloading the aircraft. Please reduce the number of passengers or cargo on board. Boarding & loading stopped.", 1, 0, 0);
        }
        
        setprop("sim/weight[1]/weight-lb", getprop("services/payload/pax-onboard-lbs") + getprop("services/payload/belly-onboard-lbs"));
        setprop("sim/weight/weight-lb", getprop("services/payload/crew-onboard-lbs"));
        setprop("services/payload/SOB-nr", (getprop("services/payload/pax-onboard-nr") + getprop("services/payload/crew-onboard-nr")));
        setprop("services/payload/expected-weight-lbs", getprop("services/payload/belly-request-lbs") + getprop("services/catering/request-lbs") + getprop("services/payload/first-request-nr") * 247 + getprop("services/payload/business-request-nr") * 225 + getprop("services/payload/economy-request-nr") * 170 + getprop("services/payload/crew-request-nr") * 150);
    },
};

var movetruck = func(trucknr, connect) {
    var truckobj = "";
    if (trucknr == 0) {
        truckobj = cattruck0;
        cargoobj = catcargo0;
    } elsif (trucknr == 1) {
        truckobj = cattruck1;
        cargoobj = catcargo1;
    } elsif (trucknr == 2) {
        truckobj = cattruck2;
        cargoobj = catcargo2;
    } elsif (trucknr == 3) {
        truckobj = cattruck3;
        cargoobj = catcargo3;
    }
    
    var truckpos = truckobj.getpos();
    var cargopos = cargoobj.getpos();
    
    if ((truckpos != 0) and (truckpos != 1)) {
        if (connect == 0) {
            truckobj.open();
            setprop("services/catering/truck[" ~ trucknr ~ "]/direction", -1);
        } else {
            truckobj.close();
            setprop("services/catering/truck[" ~ trucknr ~ "]/direction", 1);
        }
    } elsif ((cargopos != 0) and (cargopos != 1)) {
        if (connect == 1) {
            cargoobj.open();
        } else {
            cargoobj.close();
            setprop("services/catering/truck[" ~ trucknr ~ "]/complete", 1);
        }
    } elsif ((connect == 1) and (truckpos == 1.0)) {
        setprop("services/catering/truck[" ~ trucknr ~ "]/direction", 1);
        truckobj.close();
    } elsif ((connect == 1) and (truckpos == 0.0) and (cargopos == 0.0)) {
        cargoobj.open();
    } elsif ((connect == 0) and (cargopos == 1.0)) {
        setprop("services/catering/truck[" ~ trucknr ~ "]/complete", 1);
        cargoobj.close();
    } elsif ((connect == 0) and (cargoobj.getpos() == 0.0) and (truckobj.getpos() == 0.0)) {
        setprop("services/catering/truck[" ~ trucknr ~ "]/direction", -1);
        truckobj.open();
    }
}

var _timer = maketimer(6.0, func{payload_boarding.update()});

var _startstop = func() {
    if (getprop("gear/gear[0]/wow") == 1) {
        _timer.start();
    } else {
        _timer.stop();
    }
}

var _adjustspeed = func() {
    if (_timer.isRunning) {
        if (getprop("services/payload/speed") == 0) {
            setprop("services/payload/first-onboard-nr", getprop("services/payload/first-request-nr"));
            setprop("services/payload/first-onboard-lbs", math.round(getprop("services/payload/first-request-nr") * 247));
            setprop("services/payload/business-onboard-nr", getprop("services/payload/business-request-nr"));
            setprop("services/payload/business-onboard-lbs", math.round(getprop("services/payload/business-request-nr") * 225));
            setprop("services/payload/economy-onboard-nr", getprop("services/payload/economy-request-nr"));
            setprop("services/payload/economy-onboard-lbs", math.round(getprop("services/payload/economy-request-nr") * 170));
            setprop("services/payload/pax-onboard-lbs", getprop("services/payload/first-onboard-lbs") + getprop("services/payload/business-onboard-lbs") + getprop("services/payload/economy-onboard-lbs"));
            setprop("services/payload/pax-onboard-nr", getprop("services/payload/first-onboard-nr") + getprop("services/payload/business-onboard-nr") + getprop("services/payload/economy-onboard-nr"));
            
            
            setprop("services/payload/belly-onboard-lbs", getprop("services/payload/belly-request-lbs") * 1);

            if (getprop("services/catering/request-lbs") > getprop("services/catering/weight-lbs")) {
                # clean out the galleys before filling them to the right amount
                for (var i = 0; i <= 3; i += 1) {
                    for (var j = 0; j <= getprop("services/catering/truck[" ~ i ~ "]/max-trolley-nr") - 1; j += 1) {
                        setprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", 0);
                    }
                    setprop("services/catering/truck[" ~ i ~ "]/weight-lbs", 0);
                    setprop("services/catering/truck[" ~ i ~ "]/trolley-nr", 0);
                }
                setprop("services/catering/weight-lbs", 0);
                setprop("services/catering/total-trolley-nr", 0);
                
                for (var i = 0; i <= 3; i += 1) {
                    for (var j = 0; j <= getprop("services/catering/truck[" ~ i ~ "]/max-trolley-nr") - 1; j += 1) {
                        var lasttrolley = getprop("services/catering/request-lbs") - getprop("services/catering/weight-lbs");
                        if (lasttrolley <= 0) {
                            break;
                        }
                        if (lasttrolley <= 100) {
                            setprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", lasttrolley);
                            setprop("services/catering/truck[" ~ i ~ "]/weight-lbs", getprop("services/catering/truck[" ~ i ~ "]/weight-lbs") + lasttrolley);
                            setprop("services/catering/truck[" ~ i ~ "]/trolley-nr", getprop("services/catering/truck[" ~ i ~ "]/trolley-nr") + 1);
                            setprop("services/catering/weight-lbs", getprop("services/catering/weight-lbs") + lasttrolley);
                            setprop("services/catering/total-trolley-nr", getprop("services/catering/total-trolley-nr") + 1);
                            break;
                        }
                        setprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", 100);
                        setprop("services/catering/truck[" ~ i ~ "]/weight-lbs", getprop("services/catering/truck[" ~ i ~ "]/weight-lbs") + 100);
                        setprop("services/catering/truck[" ~ i ~ "]/trolley-nr", getprop("services/catering/truck[" ~ i ~ "]/trolley-nr") + 1);
                        setprop("services/catering/weight-lbs", getprop("services/catering/weight-lbs") + 100);
                        setprop("services/catering/total-trolley-nr", getprop("services/catering/total-trolley-nr") + 1);
                    }
                }
            } elsif (getprop("services/catering/request-lbs") < getprop("services/catering/weight-lbs")) {
                for (var i = 0; i <= 3; i += 1) {
                    for (var j = getprop("services/catering/truck[" ~ i ~ "]/trolley-nr") - 1; j >= 0; j -= 1) {
                        var k = getprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs");
                        var l = getprop("services/catering/weight-lbs") - getprop("services/catering/request-lbs");
                        if (l == 0) {
                            break;
                        } elsif ((l > 0) and (l <= 100)) {
                            if (l < k) {
                                setprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", k - l);
                                setprop("services/catering/truck[" ~ i ~ "]/weight-lbs", getprop("services/catering/truck[" ~ i ~ "]/weight-lbs") - l);
                                setprop("services/catering/weight-lbs", getprop("services/catering/weight-lbs") - l);
                                break;
                            } elsif (l == k) {
                                setprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", 0);
                                setprop("services/catering/truck[" ~ i ~ "]/weight-lbs", getprop("services/catering/truck[" ~ i ~ "]/weight-lbs") - k);
                                setprop("services/catering/truck[" ~ i ~ "]/trolley-nr", getprop("services/catering/truck[" ~ i ~ "]/trolley-nr") - 1);
                                setprop("services/catering/weight-lbs", getprop("services/catering/weight-lbs") - k);
                                setprop("services/catering/total-trolley-nr", getprop("services/catering/total-trolley-nr") - 1);
                                break;
                            }
                        } 
                        setprop("services/catering/truck[" ~ i ~ "]/trolley[" ~ j ~ "]/weight-lbs", 0);
                        setprop("services/catering/truck[" ~ i ~ "]/weight-lbs", getprop("services/catering/truck[" ~ i ~ "]/weight-lbs") - k);
                        setprop("services/catering/truck[" ~ i ~ "]/trolley-nr", getprop("services/catering/truck[" ~ i ~ "]/trolley-nr") - 1);
                        setprop("services/catering/weight-lbs", getprop("services/catering/weight-lbs") - k);
                        setprop("services/catering/total-trolley-nr", getprop("services/catering/total-trolley-nr") - 1);
                    }
                }
            }
            setprop("services/payload/speed", 6.0); #Reset the speed to normal.
            setprop("services/payload/speed-text", "Normal");
        } else {
            _timer.restart(getprop("services/payload/speed"));
        }
    } elsif (getprop("services/payload/speed") == 0) {
        setprop("services/payload/speed", 6.0);
        setprop("services/payload/speed-text", "Normal");
        screen.log.write("Captain, unable to modify the payload in flight.", 1, 0, 0);
    }
}

setlistener("sim/signals/fdm-initialized", func {
    payload_boarding.init();
    print("Payload system ..... Initialized");
});

setlistener("gear/gear[0]/wow", func {_startstop()});

setlistener("services/payload/speed", func{_adjustspeed()});

setlistener("services/catering/truck[0]/connect", func{movetruck(0, getprop("services/catering/truck[0]/connect"))});
setlistener("services/catering/truck[1]/connect", func{movetruck(1, getprop("services/catering/truck[1]/connect"))});
setlistener("services/catering/truck[2]/connect", func{movetruck(2, getprop("services/catering/truck[2]/connect"))});
setlistener("services/catering/truck[3]/connect", func{movetruck(3, getprop("services/catering/truck[3]/connect"))});
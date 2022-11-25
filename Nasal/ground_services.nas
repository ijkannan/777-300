#Ground Services added by Isaak Dieleman - 20190405

var icecrane = aircraft.door.new("services/deicing_truck/crane", 20);
var icecrane1 = aircraft.door.new("services/deicing_truck/crane[1]", 20);
var icecrane2 = aircraft.door.new("services/deicing_truck/crane[2]", 20);
var icecrane3 = aircraft.door.new("services/deicing_truck/crane[3]", 20);
var icecrane4 = aircraft.door.new("services/deicing_truck/crane[4]", 20);
var icetruck = aircraft.door.new("services/deicing_truck/truck[0]", 100);
var icetruck1 = aircraft.door.new("services/deicing_truck/truck[1]", 100);
var icetruck2 = aircraft.door.new("services/deicing_truck/truck[2]", 100);
var icetruck3 = aircraft.door.new("services/deicing_truck/truck[3]", 100);
var icetruck4 = aircraft.door.new("services/deicing_truck/truck[4]", 100);
var icedeicing = aircraft.door.new("services/deicing_truck/deicing", 70);
var icedeicing1 = aircraft.door.new("services/deicing_truck/deicing[1]", 80);
var icedeicing2 = aircraft.door.new("services/deicing_truck/deicing[2]", 75);
var icedeicing3 = aircraft.door.new("services/deicing_truck/deicing[3]", 78);
var icedeicing4 = aircraft.door.new("services/deicing_truck/deicing[4]", 77);
var StartTimeText = "";

var ground_services = {
    init : func {
    
    # Fuel Truck
    
    setprop("services/fuel-truck/enable", 0);
    setprop("services/fuel-truck/connect", 0);
    setprop("services/fuel-truck/transfer", 0);
    setprop("services/fuel-truck/clean", 0);
    setprop("services/fuel-truck/request-lbs", getprop("consumables/fuel/total-fuel-lbs"));
    setprop("services/fuel-truck/extra-lbs", 0);
    setprop("services/fuel-truck/speed-text", " ");
    setprop("services/fuel-truck/finished", 0);
    
    # Payload System
    
    if (getprop("sim/aero") != "777-200F") {
        # The 777-200F has its own payload dialog. For the other types, the max number of first/business/economy pax and catering has to be defined, so we
        # overwrite the dialog with the values specified in their respective -set files.
        var payload = gui.Dialog.new("sim/gui/dialogs/payload/dialog", "gui/dialogs/payload-dlg.xml");
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider/max", getprop("services/payload/first-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[1]/max", getprop("services/payload/business-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[2]/max", getprop("services/payload/economy-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/slider[3]/max", getprop("services/catering/weight-max-lbs"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[1]/binding/max", getprop("services/payload/first-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[3]/binding/max", getprop("services/payload/business-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[5]/binding/max", getprop("services/payload/economy-max-nr"));
        setprop("sim/gui/dialogs/payload/dialog/group[1]/button[7]/binding/max", getprop("services/catering/weight-max-lbs"));
    }
    setprop("services/stairs/flaps-jammed", 0);
        
    # External Power
    
    setprop("services/ext-pwr/enable", 0);
    setprop("services/ext-pwr/was_enabled", 0);
    setprop("services/ext-pwr/primary", 0);
    setprop("services/ext-pwr/secondary", 0);
    
    # Chocks
    
    setprop("services/chocks/nose", 0);
    setprop("services/chocks/left", 0);
    setprop("services/chocks/right", 0);
    
    # De-Icing
    setprop("services/deicing_truck/truck/position-norm", 0);
    setprop("services/deicing_truck/crane/position-norm", 0);
    setprop("services/deicing_truck/deicing/position-norm", 0);
    setprop("services/deicing_truck/enable", 0);
    setprop("services/deicing_truck/de-ice", 0);
    setprop("services/deicing_truck/truck/direction", 0);    

    _startstop_gsv();
    
    },
    update : func {
    
        # Fuel Truck Controls
        # Fuel Transfer Rate is based on a 1000 US Gal flow per minute, which is at the fast side of real life operations, but not unrealistic.
        
        if (getprop("services/fuel-truck/enable") and getprop("services/fuel-truck/connect")) {
        
            if (getprop("services/fuel-truck/transfer")) {
            
                if (getprop("consumables/fuel/total-fuel-lbs") < getprop("services/fuel-truck/request-lbs")) {
                    if (getprop("consumables/fuel/tank/level-gal_us") < getprop("consumables/fuel/tank[2]/capacity-gal_us")) {
                        if (getprop("consumables/fuel/tank/level-lbs") + 6 > getprop("services/fuel-truck/request-lbs") - getprop("consumables/fuel/tank[2]/level-lbs") - getprop("consumables/fuel/tank[1]/level-lbs")) {
                            setprop("consumables/fuel/tank/level-lbs", getprop("consumables/fuel/tank/level-lbs") + 0.1);
                        } else {
                            setprop("consumables/fuel/tank/level-lbs", getprop("consumables/fuel/tank/level-lbs") + 5.55);
                        }
                    }
                    if (getprop("consumables/fuel/tank[2]/level-gal_us") < getprop("consumables/fuel/tank[2]/capacity-gal_us")) {
                        if (getprop("consumables/fuel/tank[2]/level-lbs") + 6 > getprop("services/fuel-truck/request-lbs") - getprop("consumables/fuel/tank/level-lbs") - getprop("consumables/fuel/tank[1]/level-lbs")) {
                            setprop("consumables/fuel/tank[2]/level-lbs", getprop("consumables/fuel/tank[2]/level-lbs") + 0.1);
                        } else {
                            setprop("consumables/fuel/tank[2]/level-lbs", getprop("consumables/fuel/tank[2]/level-lbs") + 5.55);
                        }
                    }
                    if ((getprop("consumables/fuel/tank/capacity-gal_us") <= getprop("consumables/fuel/tank/level-gal_us")) and (getprop("consumables/fuel/tank[2]/capacity-gal_us") <= getprop("consumables/fuel/tank[2]/level-gal_us"))) {
                        if (getprop("consumables/fuel/tank/level-gal_us") > getprop("consumables/fuel/tank/capacity-gal_us")) {
                            setprop("consumables/fuel/tank[1]/level-gal_us", (getprop("consumables/fuel/tank[1]/level-gal_us") + getprop("consumables/fuel/tank/level-gal_us") - getprop("consumables/fuel/tank/capacity-gal_us")));
                            setprop("consumables/fuel/tank/level-gal_us", getprop("consumables/fuel/tank/capacity-gal_us"));
                        }
                        if (getprop("consumables/fuel/tank[2]/level-gal_us") > getprop("consumables/fuel/tank[2]/capacity-gal_us")) {
                            setprop("consumables/fuel/tank[1]/level-gal_us", (getprop("consumables/fuel/tank[1]/level-gal_us") + getprop("consumables/fuel/tank[2]/level-gal_us") - getprop("consumables/fuel/tank[2]/capacity-gal_us")));
                            setprop("consumables/fuel/tank[2]/level-gal_us", getprop("consumables/fuel/tank[2]/capacity-gal_us"));
                        }
                        if (getprop("consumables/fuel/tank[1]/level-lbs") + 12 > getprop("services/fuel-truck/request-lbs") - getprop("consumables/fuel/tank/level-lbs") - getprop("consumables/fuel/tank[2]/level-lbs")) {
                            setprop("consumables/fuel/tank[1]/level-lbs", getprop("consumables/fuel/tank[1]/level-lbs") + 0.1);
                        } else {
                            setprop("consumables/fuel/tank[1]/level-lbs", getprop("consumables/fuel/tank[1]/level-lbs") + 11.1);
                        }
                    }
                setprop("services/fuel-truck/speed-text", math.round((getprop("services/fuel-truck/request-lbs")-getprop("consumables/fuel/total-fuel-lbs")) / 6660) ~ " min remaining");
                } else {
                    setprop("services/fuel-truck/transfer", 0);
                    setprop("services/fuel-truck/speed-text", " ");
                    setprop("services/fuel-truck/finished", 1);
                    screen.log.write("Refueling complete. " ~ math.round(getprop("consumables/fuel/total-fuel-lbs")) ~" Lbs. of fuel loaded.", 0, 0.584, 1);
                    if (getprop("aircraft/settings/gnd_autodisconnect") == 1) {
                        setprop("services/fuel-truck/connect", 0);
                        setprop("services/fuel-truck/enable", 0);
                    }
                }
            }
            
            if (getprop("services/fuel-truck/clean")) {
            
                if (getprop("consumables/fuel/total-fuel-lbs") > 200) {
                
                    setprop("consumables/fuel/tank/level-lbs", getprop("consumables/fuel/tank/level-lbs") - 3.7);
                    setprop("consumables/fuel/tank[1]/level-lbs", getprop("consumables/fuel/tank[1]/level-lbs") - 3.7);
                    setprop("consumables/fuel/tank[2]/level-lbs", getprop("consumables/fuel/tank[2]/level-lbs") - 3.7);
                    setprop("services/fuel-truck/speed-text", math.round(getprop("consumables/fuel/total-fuel-lbs") / 6660) ~ " min remaining");
                } else {
                    setprop("services/fuel-truck/clean", 0);
                    setprop("services/fuel-truck/speed-text", " ");
                    screen.log.write("Fuel tanks drained.", 0, 0.584, 1);
                    if (getprop("aircraft/settings/gnd_autodisconnect") == 1) {
                        setprop("services/fuel-truck/connect", 0);
                        setprop("services/fuel-truck/enable", 0);
                    }
                }	
            
            }
        } elsif (!(getprop("services/fuel-truck/enable")) and (getprop("services/fuel-truck/connect"))) {
            setprop("services/fuel-truck/connect", 0);
        }
        
        #External Ground Power controls
        
        if (getprop("services/ext-pwr/enable") == 1) {
            if (getprop("services/ext-pwr/primary") == 1) {
                setprop("controls/electric/external-power", 1);
            } else {
                setprop("controls/electric/external-power", 0);
            }
            if (getprop("services/ext-pwr/secondary") == 1) {
                setprop("controls/electric/external-power[1]", 1);
            } else {
                setprop("controls/electric/external-power[1]", 0);
            }
            setprop("services/ext-pwr/was_enabled", 1);
        } else {
            if (getprop("services/ext-pwr/primary") == 1) {
                if (getprop("services/ext-pwr/was_enabled") != 1) {
                    screen.log.write("Can't connect primary ground power without a powerbox!", 1, 0 ,0);
                }
                setprop("services/ext-pwr/primary", 0);
                setprop("controls/electric/external-power", 0);
            }
            if (getprop("services/ext-pwr/secondary") == 1) {
                if (getprop("services/ext-pwr/was_enabled") != 1) {
                    screen.log.write("Can't connect secondary ground power without a powerbox!", 1, 0 ,0);
                }
                setprop("services/ext-pwr/secondary", 0);
                setprop("controls/electric/external-power[1]", 0);
            }
            setprop("services/ext-pwr/was_enabled", 0);
        }
        
        # Chocks
        # This uses the left and right brakes for the moment, to avoid the parking brake from being active.
        
        if ((getprop("services/chocks/nose") == 1) or (getprop("services/chocks/left") == 1)) {
            setprop("controls/gear/brake-left", 1);
            setprop("services/chocks/left-was-enabled", 1);
        } else {
            if (getprop("services/chocks/left-was-enabled") == 1) {
                setprop("controls/gear/brake-left", 0);
                setprop("services/chocks/left-was-enabled", 0);
            }
        }
        
        if ((getprop("services/chocks/nose") == 1) or (getprop("services/chocks/right") == 1)) {
            setprop("controls/gear/brake-right", 1);
            setprop("services/chocks/right-was-enabled", 1);
        } else {
            if (getprop("services/chocks/right-was-enabled") == 1) {
                setprop("controls/gear/brake-right", 0);
                setprop("services/chocks/right-was-enabled", 0);
            }
        }
        
        # Pax and baggage
        
        # Gui update for the weight & payload dialog (code is in payload.nas, but Gui update needs the faster timer of the ground services system)
        setprop("services/payload/expected-weight-lbs", getprop("services/payload/belly-request-lbs") + getprop("services/catering/request-lbs") + getprop("services/payload/first-request-nr") * 247 + getprop("services/payload/business-request-nr") * 225 + getprop("services/payload/economy-request-nr") * 170 + getprop("services/payload/crew-request-nr") * 150);
        setprop("services/payload/pax-request-nr", getprop("services/payload/first-request-nr") + getprop("services/payload/business-request-nr") + getprop("services/payload/economy-request-nr"));
        
        # Make sure a Jetway and Stair cannot be connected to the same door at the same time.
        
        if (getprop("services/payload/jetway1_enable") == 1) {
            if (getprop("services/stairs/stairs1_enable") == 1) {
                setprop("services/stairs/stairs1_enable", 0);
                screen.log.write("Can't connect a Stair and a Jetway to the same door!", 1, 0 ,0);
            }
        }
        if (getprop("services/payload/jetway2_enable") == 1) {
            if (getprop("services/stairs/stairs2_enable") == 1) {
                setprop("services/stairs/stairs2_enable", 0);
                screen.log.write("Can't connect a Stair and a Jetway to the same door!", 1, 0 ,0);
            }
        }

        # De-icing Truck
		
		if (getprop("/services/deicing_truck/enable") and getprop("/services/deicing_truck/de-ice"))
		{		
			if (me.ice_time == 2){
				StartTimeText = getprop("sim/time/gmt");
                setprop("services/deicing_truck/truck/direction", 1);
                setprop("services/deicing_truck/truck[1]/direction", 1);
                setprop("services/deicing_truck/truck[2]/direction", 1);
                setprop("services/deicing_truck/truck[3]/direction", 1);
                setprop("services/deicing_truck/truck[4]/direction", 1);
                icetruck.move(1);
                icetruck1.move(1);
                icetruck2.move(1);
                icetruck3.move(1);
                icetruck4.move(1);
                icecrane1.move(1);
			}
            
            if (me.ice_time == 22){
                icecrane3.move(1);
            }
            
            if (me.ice_time == 32){
                icecrane4.move(1);
            }
            
            if (me.ice_time == 52) {
                icecrane2.move(1);
            }
            
            if (me.ice_time == 102) {
                icecrane.move(1);
            }
            
            if (me.ice_time == 202) {
                icedeicing.move(1);
                icedeicing1.move(1);
                icedeicing4.move(1);
            }
            
            if (me.ice_time == 222) {
                icedeicing3.move(1);
            }
            
            if (me.ice_time == 252) {
                icedeicing2.move(1);
            }
            
            if (me.ice_time == 1002){
                
                
                setprop("services/deicing_truck/truck/direction", -1);                
				icedeicing.move(0);
                icetruck.move(0);
                
                setprop("services/deicing_truck/truck[1]/direction", -1);
                icedeicing1.move(0);
                icetruck1.move(0);
                
                setprop("services/deicing_truck/truck[2]/direction", -1);
                icedeicing2.move(0);
                icetruck2.move(0);
                
                setprop("services/deicing_truck/truck[3]/direction", -1);
                icedeicing3.move(0);
                icetruck3.move(0);
                
                setprop("services/deicing_truck/truck[4]/direction", -1);
                icedeicing4.move(0);
                icetruck4.move(0);
			}
            
            if (me.ice_time == 1702){
				icecrane.move(0);
			}
				
			if (me.ice_time == 1752){
                icecrane2.move(0);
                icecrane1.move(0);
			}
            
            if (me.ice_time == 1772){
                icecrane4.move(0);
			}
            
            if (me.ice_time == 1782){
                icecrane3.move(0);
			}

			if (me.ice_time == 2002) {
				screen.log.write("De-icing on aircraft complete. Prpylene glycol, type IV fluid applied at 75%.", 0.5, 0.9, 1.0);
                screen.log.write("De-icing started at " ~ StartTimeText ~ "UTC. Holdover time is 0 hours 45 minutes.", 0.5, 0.9, 1.0);
				setprop("services/deicing_truck/de-ice", 0);
                setprop("services/deicing_truck/truck/direction", 0);
                setprop("services/deicing_truck/truck[1]/direction", 0);
                setprop("services/deicing_truck/truck[2]/direction", 0);
                setprop("services/deicing_truck/truck[3]/direction", 0);
                setprop("services/deicing_truck/truck[4]/direction", 0);
                if (getprop("aircraft/settings/gnd_autodisconnect") == 1) {
                    setprop("services/deicing_truck/enable", 0);
                }
                #Enter true icing props here
			}
		
		} else {
			me.ice_time = 0;
		}
		
	me.ice_time += 1;
        
    }

};

var _timer_gsv = maketimer(0.1, func{ground_services.update()});

var _startstop_gsv = func() {
    if (getprop("gear/gear[0]/wow") == 1) {
        _timer_gsv.start();
    } else {
        _timer_gsv.stop();
    }
}

setlistener("sim/signals/fdm-initialized", func {
    ground_services.init();
    print("Ground Services ..... Initialized");
});

setlistener("gear/gear[0]/wow", func {_startstop_gsv()});

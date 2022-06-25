#Engine control class
# ie: var Eng = Engine.new(engine number);
var Engine = {
    new : func(eng_num){
        var m = { parents : [Engine]};
        m.OperatingOilTemp = 120;
        m.eng_num = eng_num;
        m.eng = props.globals.getNode("engines/engine["~eng_num~"]",1);
        m.n1 = m.eng.getNode("n1",1);
        m.n2 = m.eng.getNode("n2",1);
        m.rpm = m.eng.getNode("rpm",1);
        m.rpm.setDoubleValue(0);
        m.n2rpm = m.eng.getNode("n2rpm",1);
        m.n2rpm.setDoubleValue(0);
        m.egt_degf = m.eng.getNode("egt-degf",1);
        m.egt = m.eng.getNode("egt",1);
        m.egt.setDoubleValue(0);
        m.reverser_cmd = props.globals.getNode("controls/engines/engine["~eng_num~"]/reverser",1);
        m.reverser_cmd.setBoolValue(0);
        m.reverser = props.globals.getNode("controls/engines/engine["~eng_num~"]/reverser-act",1);
        m.throttle = props.globals.getNode("controls/engines/engine["~eng_num~"]/throttle-act",1);
        m.throttle.setDoubleValue(0);
        m.cutoff = props.globals.getNode("controls/engines/engine["~eng_num~"]/cutoff",1);
        m.cutoff.setBoolValue(1);
        m.cutoffSwitch = props.globals.getNode("controls/engines/engine["~eng_num~"]/cutoff-switch",1);
        m.cutoffSwitch.setBoolValue(0);
        m.fuel_out = props.globals.getNode("engines/engine["~eng_num~"]/no-fuel",1);
        m.fuel_out.setBoolValue(0);
        m.autostart = props.globals.getNode("controls/engines/autostart",1);
        m.autostart.setBoolValue(1);
        m.starterSwitch = props.globals.getNode("controls/engines/StartIgnition-knob["~eng_num~"]",1);
        m.starter = props.globals.getNode("controls/engines/engine["~eng_num~"]/starter",1);
        m.starterSystem = props.globals.getNode("systems/electrical/outputs/starter["~eng_num~"]",1);
        m.shutdownSound = props.globals.getNode("engines/engine["~eng_num~"]/shutdown-sound",1);
        m.generator = props.globals.getNode("controls/electric/engine["~eng_num~"]/generator",1);
        m.fuel_pph=m.eng.getNode("fuel-flow_pph",1);
        m.fuel_pph.setDoubleValue(0);
        m.fuel_gph=m.eng.getNode("fuel-flow-gph",1);
        m.hpump=props.globals.getNode("systems/hydraulics/pump-psi["~eng_num~"]",1);
        m.running = props.globals.getNode("engines/engine["~eng_num~"]/run",1);
        m.running.setBoolValue(0);
        m.hpump.setDoubleValue(0);
        m.apu = props.globals.getNode("controls/APU", 1);
        m.apu_knob = m.apu.getNode("off-start-run", 1);
        m.apu_status = m.apu.getNode("apu_status", 1);
        m.apu_fuel_valve0 = m.apu.getNode("valve[0]/opened",1);
        m.apu_fuel_valve1 = m.apu.getNode("valve[1]/opened",1);
        m.apu_fuel_valve0.setBoolValue(0);
        m.apu_fuel_valve1.setBoolValue(0);
        m.apu_status.setValue(0);
        m.apu_gen_switch = m.apu.getNode("apu-gen-switch", 1);
        m.apu_gen_switch.setBoolValue(0);
        m.apu_run = m.apu.getNode("run", 1);
        m.apu_run.setBoolValue(0);
                m.apu_running = m.apu.getNode("running",1);
                m.apu_running.setBoolValue(0);
        m.oilTemperatureDegc=m.eng.getNode("oil-temperature-degc",1);
        m.fuelTemperatureDegc=m.eng.getNode("fuel-temperature-degc", 1);
        var envirT = getprop("environment/temperature-degc") or 0.00;
        m.oilTemperatureDegc.setDoubleValue(envirT);
        m.fuelTemperatureDegc.setDoubleValue(envirT);
        m.oilPressurePsi=m.eng.getNode("oil-pressure-psi",1);
        m.oilPressurePsi.setDoubleValue(0);
        m.oilQuantity=m.eng.getNode("oil-quantity",1);
        m.oilQuantity.setDoubleValue(17);
        m.wasRunning = 0;

        m.last_update_time = getprop("sim/time/elapsed-sec");
        return m;
    },
    updateOilTemp : func {
        var oilHeatFactor=0.2;
        var oilCoolFactor=0.1;
        # Fuel Cooling/Heating values are much lower as the large fuel volume takes a long time to change temperature
        var fuelHeatFactor=0.001; #used for Fuel heating via the Fuel Oil Heat Exchanger, in relation to deltaTemp
        var fuelCoolFactor=0.005; #used for Fuel cooling by environment temperature, in relation to deltaTemp
        var fuelWarmFactor=0.002; #used for Fuel warming by environment temperature, in relation to deltaTemp
        var envirT = getprop("environment/temperature-degc") or 0.00;
        var currentElapseTime = getprop("sim/time/elapsed-sec");
        var deltaTime = currentElapseTime - me.last_update_time;
        var currentFuelFlow = me.fuel_pph.getValue();
        if (currentFuelFlow > 0 and me.oilTemperatureDegc.getValue() < me.OperatingOilTemp) {
            me.oilTemperatureDegc.setDoubleValue(me.oilTemperatureDegc.getValue() + oilHeatFactor*currentFuelFlow*(deltaTime));
        }
        else {
            if (me.oilTemperatureDegc.getValue() > envirT) {
                me.oilTemperatureDegc.setDoubleValue(me.oilTemperatureDegc.getValue() - oilCoolFactor*(deltaTime));
            }
            else {
                me.oilTemperatureDegc.setDoubleValue(me.oilTemperatureDegc.getValue() + oilCoolFactor*(deltaTime));
            }
        }
        
        # Fuel Oil Heat Exchanger
        if (currentElapseTime < 3) {
            #Reset temperatures to reasonable values while weather engine is initialising.
            me.fuelTemperatureDegc.setDoubleValue(envirT);
            me.oilTemperatureDegc.setDoubleValue(envirT);
        }
        var oilfueldeltaTemperatureDegc = me.oilTemperatureDegc.getValue() - me.fuelTemperatureDegc.getValue(); 
        var envirfueldeltaTemperatureDegc = abs(me.fuelTemperatureDegc.getValue() - envirT);
        if (me.fuelTemperatureDegc.getValue() > envirT) {
            me.fuelTemperatureDegc.setDoubleValue(me.fuelTemperatureDegc.getValue() - fuelCoolFactor * (deltaTime) * (envirfueldeltaTemperatureDegc));
            
            if ((me.fuelTemperatureDegc.getValue() < me.oilTemperatureDegc.getValue()) and (me.fuelTemperatureDegc.getValue() < -5)) {
                me.fuelTemperatureDegc.setDoubleValue(me.fuelTemperatureDegc.getValue() + fuelHeatFactor * (deltaTime) * (oilfueldeltaTemperatureDegc));
            }
        } elsif (me.fuelTemperatureDegc.getValue() < envirT) {
            me.fuelTemperatureDegc.setDoubleValue(me.fuelTemperatureDegc.getValue() + fuelWarmFactor * (deltaTime) * (envirfueldeltaTemperatureDegc));
            if ((me.fuelTemperatureDegc.getValue() < me.oilTemperatureDegc.getValue()) and (me.fuelTemperatureDegc.getValue() < -5)) {
                me.fuelTemperatureDegc.setDoubleValue(me.fuelTemperatureDegc.getValue() + fuelHeatFactor * (deltaTime) * (oilfueldeltaTemperatureDegc));
            }
        } else {
            if ((me.fuelTemperatureDegc.getValue() < me.oilTemperatureDegc.getValue()) and (me.fuelTemperatureDegc.getValue() < -5)) {
                me.fuelTemperatureDegc.setDoubleValue(me.fuelTemperatureDegc.getValue() + fuelHeatFactor * (deltaTime));
            }
        }
        
        me.last_update_time = currentElapseTime;
    },
    updateOilPressure : func(n2rpm) {
        if (n2rpm < 20) {
            me.oilPressurePsi.setDoubleValue(5.6*math.sqrt(n2rpm));
        }
        else
        {
            me.oilPressurePsi.setDoubleValue(0.3*n2rpm+19);
        }
    },
    updateOilQuantity : func(oilPressure) {
        me.oilQuantity.setDoubleValue(17 - (oilPressure/60)*2);
    },
#### update ####
    update : func {
        me.cutoffSwitch.setBoolValue(!me.cutoff.getBoolValue());
        me.updateOilTemp();
        me.updateOilPressure(me.n2rpm.getValue());
        me.updateOilQuantity(me.oilPressurePsi.getValue());
        if(getprop("sim/flight-model") == "yasim")
        {
            if(me.fuel_out.getBoolValue() or me.cutoff.getBoolValue())
            {
                me.fuel_pph.setDoubleValue(0);
                me.running.setBoolValue(0);
                me.egt.setDoubleValue(me.egt_degf.getValue());
            }
            if(me.running.getBoolValue())
            {
                me.wasRunning = 1;
                if(me.starterSwitch.getValue() == -1)
                {
                    settimer(func { me.starterSwitch.setValue(0);}, 0.3);
                }
                me.rpm.setValue(me.n1.getValue());
                me.n2rpm.setValue(me.n2.getValue());
                #Thrust reverser is inhibitted in air
                if((getprop("gear/gear[1]/wow") == 0) and (getprop("gear/gear[2]/wow") == 0))
                {
                    me.reverser_cmd.setValue(0);
                }
                else
                {
                    if(me.throttle.getValue() == 0)
                    {
                        var reverser_cmd = me.reverser_cmd.getValue();
                        if(reverser_cmd != me.reverser.getValue())
                        {
                            me.reverser.setValue(reverser_cmd);
                        }
                    }
                }
                me.egt.setDoubleValue(me.egt_degf.getValue());
                var v_pph = (me.fuel_gph.getValue() * getprop("consumables/fuel/tank/density-ppg") / 1000);
                if(v_pph < 1.2)
                {
                    me.idle_ff();
                    v_pph=1.2;
                }
                else
                    v_pph = v_pph + 1.2 / (1 + v_pph);
                me.fuel_pph.setValue(v_pph);
                var v_egt = me.egt_degf.getValue() - 64;
                if(v_egt > 0)
                {
                    v_egt = 270 - v_egt/4;
                }
                else
                {
                    v_egt = 270;
                }
                   me.egt.setDoubleValue(me.egt_degf.getValue() + v_egt);
            }
            else
            {
                if(me.starterSwitch.getValue() == -1)
                {
                    if(getprop("controls/electric/APU-generator")
                            or getprop("engines/engine[0]/run")
                            or getprop("engines/engine[1]/run")
                            or getprop("controls/electric/external-power")
                            or getprop("controls/electric/external-power[1]")
                    )
                    {
                        me.spool_up();
                    }
                    else
                    {
                        settimer(func { me.starterSwitch.setValue(0);}, 0.3);
                    }
                }else{
                    if (!me.shutdownSound.getBoolValue() and me.wasRunning) {
                        me.shutdownSound.setBoolValue(1);
                        settimer(func() {
                            me.shutdownSound.setBoolValue(1);
                        }, 40);
                    }
                    var tmprpm = me.rpm.getValue();
                    tmprpm -= getprop("sim/time/delta-realtime-sec") * 1.2;
                    if(tmprpm < 0.0) tmprpm = 0;
                    me.rpm.setValue(tmprpm);
                    me.n2rpm.setValue(1.3*math.sqrt(tmprpm) * 12.65);
                }
                me.wasRunning = 0;
            }
            var hpsi =me.rpm.getValue();
            if(hpsi>60)
                hpsi = 60;
            me.hpump.setValue(hpsi);
        }
        if(getprop("sim/flight-model") == "jsb")
        {
            me.egt.setValue((me.egt_degf.getValue()-32)/1.8);
            if(me.starterSwitch.getValue() == -1)
            {
                if(getprop("controls/electric/APU-generator")
                        or getprop("engines/engine[0]/run")
                        or getprop("engines/engine[1]/run")
                        or getprop("controls/electric/external-power")
                        or getprop("controls/electric/external-power[1]")
                )
                {
                    me.starter.setValue(1);
                    if(me.n1.getValue() > 25)
                    {
                        controls.click(1);
                        me.starterSwitch.setValue(0);
                    }
                }
                else
                {
                    settimer(func { me.starterSwitch.setValue(0);}, 0.3);
                }
            }
        }

        if(aux_tanks)
        {
            setprop("consumables/fuel/tank[3]/selected",
                !getprop("consumables/fuel/tank[3]/empty")
                and ((getprop("controls/fuel/tank[1]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[1]/boost-pump[1]") == 1)));
            setprop("consumables/fuel/tank[4]/selected",
                !getprop("consumables/fuel/tank[4]/empty")
                and ((getprop("controls/fuel/tank[1]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[1]/boost-pump[1]") ==1)));
            setprop("consumables/fuel/tank[5]/selected",
                !getprop("consumables/fuel/tank[5]/empty")
                and ((getprop("controls/fuel/tank[1]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[1]/boost-pump[1]") ==1)));
            setprop("consumables/fuel/tank[1]/selected", (((getprop("consumables/fuel/tank[3]/level-gal_us") < 30)
                and (getprop("consumables/fuel/tank[4]/level-gal_us") < 30)
                and (getprop("consumables/fuel/tank[5]/level-gal_us") < 30)
                and !getprop("consumables/fuel/tank[1]/empty")
                    or (!getprop("consumables/fuel/tank[3]/selected")
                        and !getprop("consumables/fuel/tank[4]/selected")
                        and !getprop("consumables/fuel/tank[5]/selected")))
                and ((getprop("controls/fuel/tank[1]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[1]/boost-pump[1]") ==1))));
            setprop("consumables/fuel/tank[0]/selected", (!getprop("controls/fuel/tank[1]/boost-pump[0]")
                and (getprop("consumables/fuel/tank[0]/empty") !=1)
                and ((getprop("controls/fuel/tank[0]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[0]/boost-pump[1]") ==1))));
            setprop("consumables/fuel/tank[2]/selected", ((getprop("controls/fuel/tank[1]/boost-pump[1]") !=1)
                and (getprop("consumables/fuel/tank[2]/empty") !=1)
                and ((getprop("controls/fuel/tank[2]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[2]/boost-pump[1]") ==1))));
        }
        else
        {
            setprop("consumables/fuel/tank[1]/selected", (!getprop("consumables/fuel/tank[1]/empty")
                and ((getprop("controls/fuel/tank[1]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[1]/boost-pump[1]") ==1))));
            setprop("consumables/fuel/tank[0]/selected", (((getprop("consumables/fuel/tank[1]/level-gal_us") < 50)
                    or (!getprop("consumables/fuel/tank[1]/selected")))
                and !getprop("consumables/fuel/tank[0]/empty")
                and ((getprop("controls/fuel/tank[0]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[0]/boost-pump[1]") ==1))));
            setprop("consumables/fuel/tank[2]/selected", (((getprop("consumables/fuel/tank[1]/level-gal_us") < 50)
                    or (!getprop("consumables/fuel/tank[1]/selected")))
                and !getprop("consumables/fuel/tank[2]/empty")
                and ((getprop("controls/fuel/tank[2]/boost-pump[0]") ==1) or (getprop("controls/fuel/tank[2]/boost-pump[1]") ==1))));
        }
        if(me.eng_num == 0)
        { #set fuel on if correct combination of tanks not empty and pumps on
            if(     ((!getprop("consumables/fuel/tank[0]/empty") and ((getprop("controls/fuel/tank[0]/boost-pump[0]") == 1) or  (getprop("controls/fuel/tank[0]/boost-pump[1]") == 1)))
                or  (!getprop("consumables/fuel/tank[1]/empty") and (getprop("controls/fuel/tank[1]/boost-pump[0]") == 1))
                or  (!getprop("consumables/fuel/tank[2]/empty") and ((getprop("controls/fuel/tank[2]/boost-pump[0]") == 1) or (getprop("controls/fuel/tank[2]/boost-pump[1]") == 1)) and ((getprop("controls/fuel/xfeedaft-valve/opened") == 1) or (getprop("controls/fuel/xfeedfwd-valve/opened") == 1))))
                or getprop("sim/autostart"))
            {
                me.fuel_out.setBoolValue(0);
            }
            else
            {
                me.fuel_out.setBoolValue(1);
            }
        }
        else
        {
            if(         ((!getprop("consumables/fuel/tank[2]/empty")
                    and     ((getprop("controls/fuel/tank[2]/boost-pump[0]") == 1)
                        or  (getprop("controls/fuel/tank[2]/boost-pump[1]") == 1)))
                or
                        (!getprop("consumables/fuel/tank[1]/empty")
                    and (getprop("controls/fuel/tank[1]/boost-pump[1]") == 1))
                or 
                    (!getprop("consumables/fuel/tank[0]/empty")
                    and     ((getprop("controls/fuel/tank[0]/boost-pump[0]") == 1)
                        or  (getprop("controls/fuel/tank[0]/boost-pump[1]") == 1))
                    and ((getprop("controls/fuel/xfeedaft-valve/opened") == 1)
                    or (getprop("controls/fuel/xfeedfwd-valve/opened") == 1))))
                or getprop("sim/autostart"))
            {
                me.fuel_out.setBoolValue(0);
            }
            else
            {
                me.fuel_out.setBoolValue(1);
            }
        }
        if(me.apu_knob.getValue() == 0)
        {
            me.apu_fuel_valve0.setValue(0);
            me.apu_fuel_valve1.setValue(0);
            me.apu_status.setValue(0);            # OFF
            me.apu_run.setValue(0);
            me.apu_running.setValue(0);
            if (getprop("controls/electric/APU-generator") != 0)
                setprop("controls/electric/APU-generator", 0);
                setprop("systems/electrical/APB", 0);
        } elsif (!getprop("consumables/fuel/tank[0]/empty") or (!getprop("consumables/fuel/tank[1]/empty") and (getprop("controls/fuel/tank[1]/boost-pump") == 1))) {
            if(me.apu_knob.getValue() == 1)
            {
                if((me.apu_run.getBoolValue() == 0)
                    and (me.apu_status.getValue() == 0))
                {
                    me.apu_status.setValue(1);        # ARM
                }
            }
            else
            {
                if(me.apu_status.getValue() == 1)    # ARM
                {
                    me.apu_running.setValue(1);
                    me.apu_status.setValue(2);        # START
                    settimer(func { me.apu_status.setValue(3);}, 15);
                }
                settimer(func { me.apu_knob.setValue(1);}, 0.3);
            }
            if(me.apu_status.getValue() == 3)
            {
                me.apu_run.setBoolValue(1);
                if (getprop("controls/electric/APU-generator") != 1)
                    setprop("controls/electric/APU-generator", 1);
                    setprop("systems/electrical/APB", 1);
            }
            else
            {
                me.apu_run.setBoolValue(0);
                if (getprop("controls/electric/APU-generator") != 0)
                    setprop("controls/electric/APU-generator", 0);
                    setprop("systems/electrical/APB", 0);
            }
        } else {
            me.apu_run.setBoolValue(0);
            if (getprop("controls/electric/APU-generator") != 0)
            {
                setprop("controls/electric/APU-generator", 0);
                setprop("systems/electrical/APB", 0);
            }
            me.apu_fuel_valve0.setValue(0);
            me.apu_fuel_valve1.setValue(0);
        }
        

        #APU fuel: if L CTR Boost Pump is on and CTR Tank is not empty: fuel is pumped from the CTR tank
        if(me.apu_run.getBoolValue() and (getprop("consumables/fuel/tank[1]/level-lbs") > 0) and (getprop("controls/fuel/tank[1]/boost-pump[0]") == 1))
        {
            setprop("consumables/fuel/tank[1]/level-gal_us", getprop("consumables/fuel/tank[1]/level-gal_us")-0.0006);
        }
        # If L CTR Boost Pump is off, fuel is automatically pumped from the left main tank, regardless of boost pump switch position.
        elsif(me.apu_run.getBoolValue() and (getprop("consumables/fuel/tank[0]/level-lbs") > 0))
        {
            setprop("consumables/fuel/tank[0]/level-gal_us", getprop("consumables/fuel/tank[0]/level-gal_us")-0.0006);
        }
        #Need to check code below. No reason for shutdown tied to cabin lights?
        # if(getprop("controls/lighting/cabin-lights") == 1
            # and getprop("controls/electric/APU-generator") == 0
            # and getprop("controls/electric/engine[0]/generator") == 0
            # and getprop("controls/electric/engine[1]/generator") == 0
            # and getprop("controls/electric/battery-switch") == 0)
        # {
            # Shutdown();
        # }
    },

    spool_up : func {
        var rpminc = 0;
        var tmprpm = me.rpm.getValue();
        var v_pph = 0;
        if(!me.fuel_out.getBoolValue() and !me.cutoff.getBoolValue())
        {
            v_pph = 1.2;
            me.idle_ff();
            if(tmprpm <10)
            {
                rpminc = 0.5;
            }
            else
            {
                rpminc = 0.8;
            }
            if(tmprpm >= me.n1.getValue())
            {
                controls.click(1);
                me.starterSwitch.setValue(0);
                me.running.setBoolValue(1);
            }
            if(tmprpm > 0)
            {
                var v_egt = tmprpm * 270 / 18.5 + me.egt_degf.getValue();
                me.egt.setDoubleValue(v_egt);
            }
        }
        else
        {
            if(tmprpm <= 5)
            {
                rpminc = 0.1;
            }
        }
        tmprpm += getprop("sim/time/delta-realtime-sec") * rpminc;
        me.rpm.setValue(tmprpm);
        me.n2rpm.setValue(1.2*math.sqrt(tmprpm) * 12.65);
        me.fuel_pph.setValue(v_pph);
    },
# This function could be removed if FG fuel flow program is fixed to consume fuel when engine idle.
    idle_ff : func{
        var v_consume = 0.001;
        if(me.eng_num == 0 and !me.cutoff.getBoolValue())
        {
            if(getprop("consumables/fuel/tank[0]/selected"))
            {
                setprop("consumables/fuel/tank[0]/level-gal_us", getprop("consumables/fuel/tank[0]/level-gal_us")- v_consume);
            }
            elsif(getprop("consumables/fuel/tank[1]/selected"))
            {
                setprop("consumables/fuel/tank[1]/level-gal_us", getprop("consumables/fuel/tank[1]/level-gal_us")- v_consume);
            }
            elsif(  getprop("consumables/fuel/tank[2]/selected") and
                    ((getprop("controls/fuel/xfeedfwd-valve/opened") == 1) or
                    (getprop("controls/fuel/xfeedaft-valve/opened") == 1)))
            {
                setprop("consumables/fuel/tank[2]/level-gal_us", getprop("consumables/fuel/tank[2]/level-gal_us") - v_consume);
            }
            if( getprop("consumables/fuel/tank[0]/selected") or
                getprop("consumables/fuel/tank[1]/selected") or
                (getprop("consumables/fuel/tank[2]/selected")
                and    ((getprop("controls/fuel/xfeedaft-valve/opened") == 1)
                    or (getprop("controls/fuel/xfeedfwd-valve/opened") == 1)))
                )
            {
                me.fuel_out.setBoolValue(0);
            }
            else
            {
                me.fuel_out.setBoolValue(1);
            }
        }
        elsif (me.eng_num == 1 and !me.cutoff.getBoolValue())
        {
            if(getprop("consumables/fuel/tank[2]/selected"))
            {
                setprop("consumables/fuel/tank[2]/level-gal_us", getprop("consumables/fuel/tank[2]/level-gal_us")- v_consume);
            }
            elsif(getprop("consumables/fuel/tank[1]/selected"))
            {
                setprop("consumables/fuel/tank[1]/level-gal_us", getprop("consumables/fuel/tank[1]/level-gal_us")- v_consume);
            }
            elsif(  getprop("consumables/fuel/tank[0]/selected") and
                    ((getprop("controls/fuel/xfeedfwd-valve/opened") == 1) or
                    (getprop("controls/fuel/xfeedaft-valve/opened") == 1)))
            {
                setprop("consumables/fuel/tank[0]/level-gal_us", getprop("consumables/fuel/tank[0]/level-gal_us") - v_consume);
            }
            if( getprop("consumables/fuel/tank[2]/selected") or
                getprop("consumables/fuel/tank[1]/selected") or
                (getprop("consumables/fuel/tank[0]/selected")
                and    ((getprop("controls/fuel/xfeedaft-valve/opened") == 1)
                    or (getprop("controls/fuel/xfeedfwd-valve/opened") == 1)))
                )
            {
                me.fuel_out.setBoolValue(0);
            }
            else
            {
                me.fuel_out.setBoolValue(1);
            }
        }
    },

};

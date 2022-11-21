#
# Fuel Synoptic panel
# jylebleu
# Isaak Dieleman (Jettison portion)
#
var Label = {
        new : func(elt,format,ratio) {
            var m = { parents: [Label]};
            m.svgelt = elt;
            m.format = format;
            m.ratio = ratio;
            return m;
        },
        update : func(value) {
            me.svgelt.setText(sprintf(me.format,value*me.ratio));
        }
};

var JetText = {
        MLWcolor:"rgba(255,255,255,1)",
        MANcolor:"rgba(255,215,87,1)",
        new : func(txt) {
            var m = { parents: [JetText]};
            m.svgtxt = txt;
            return m;
        },
        update : func(value) {
            if (getprop("controls/fuel/jettison-arm-switch")) {
                me.svgtxt.show();
                me.svgtxt.setText(value);
                if (getprop("controls/fuel/jettison-FTR-manual")) {
                    me.svgtxt.setColor(me.MANcolor);
                } else {
                    me.svgtxt.setColor(me.MLWcolor);
                }
            } else {
                me.svgtxt.hide();
            }
        }
};

var Jett = {
        new : func(elt) {
            var m = { parents: [Jett]};
            m.jettelt = elt;
            return m;
        },
        update : func() {
            
            if (getprop("controls/fuel/jettison-arm-switch")) {
                me.jettelt.show();
            } else {
                me.jettelt.hide();
            }
        }
};

var Apu = {
        new : func(elt) {
            var m = { parents: [Apu]};
            m.apuelt = elt;
            return m;
        },
        update : func() {
            if (getprop("controls/APU/off-start-run") != 0) {
                me.apuelt.show();
            } else {
                me.apuelt.hide();
            }
        }
};

var Pipe = {
        feeder : [],
        fillColor:"rgba(0,255,0,1)",
        emptyColor:"rgba(255,255,255,1)",
        new : func(elt) {
            var m = {parents : [Pipe]};
            m.feeder=[];
            m.overridePump = nil;
            m.elt = elt;
            m.valves = [];
            return m;
        },
        feededBy : func(feeder) {
            append(me.feeder,feeder);
        },
        overridedBy : func(overridePump) {
            me.overridePump = overridePump;
        },
        openedBy : func(valve) {
            append(me.valves,valve);
        },
        oneValveOpened : func {
            if (size(me.valves) == 0) {
                return 1;
            }
            var valveStatus = 0;
            for(var i=0; i<size(me.valves); i+=1) {
                valveStatus = valveStatus or getprop(me.valves[i]);
            }
            return valveStatus;
        },
        opened : func() {
            var feederStatus = 0;
            for(var i=0; i<size(me.feeder); i+=1) {
                feederStatus = feederStatus or getprop(me.feeder[i]);
            }
            if (me.overridePump != nil and getprop(me.overridePump) == 1) {
                feederStatus = 0;
            }
            if (me.oneValveOpened() == 1 and feederStatus == 1) {
                return 1;
            }
            else return 0;
        },
        update : func() {
            if (me.opened()) {
                me.elt.show();
            }
            else {
                me.elt.hide();
            }
        }
};
var Valve = {
        new : func(symbClosed,symbOpened,symbBlocked) {
            var m = { parents: [Valve]};
            m.symbClosed = symbClosed;
            m.symbOpened = symbOpened;
            m.symbBlocked = symbBlocked;
            return m;
        },
        update : func(value) {
            if(value == 0) {
                me.symbClosed.show();
                me.symbOpened.hide();
                me.symbBlocked.hide();
            }
            elsif (value == 1) {
                me.symbClosed.hide();
                me.symbOpened.show();
                me.symbBlocked.hide();
            } else {
                print("valves should block");
                me.symbClosed.hide();
                me.symbOpened.hide();
                me.symbBlocked.show();
            }
        }
};

var JettValve = {
        new : func(symbClosed,symbOpened,symbBlocked) {
            var m = { parents: [JettValve]};
            m.symbOpened = symbOpened;
            m.symbClosed = symbClosed;
            m.symbBlocked = symbBlocked;
            return m;
        },
        update : func(value) {
            var Armed = getprop("controls/fuel/jettison-arm-switch");
            if (Armed) {
                if (value == 0) {
                    me.symbClosed.show();
                    me.symbOpened.hide();
                    me.symbBlocked.hide();
                } elsif (value == 1) {
                    me.symbClosed.hide();
                    me.symbOpened.show();
                    me.symbBlocked.hide();
                } else {
                    me.symbClosed.hide();
                    me.symbOpened.hide();
                    me.symbBlocked.show();
                }
            } else {
                me.symbClosed.hide();
                me.symbOpened.hide();
                me.symbBlocked.hide();
            }
        }
};

var BlockPump = {
        new : func(elt) {
            var m = { parents: [BlockPump]};
            m.elt = elt;
            return m;
        },
        update : func(value) {
            if (value == 2) {
                me.elt.show();
            } else {
                me.elt.hide();
            }
        }
};

var Pump = {
        stopColor:"rgba(255,255,255,1)",
        startColor:"rgba(0,255,0,1)",
        blockColor:"rgba(255,215,87,1)",
        new : func(elt) {
            var m = { parents: [Pump]};
            m.elt = elt;
            return m;
        },
        started : func() {
            me.elt.setStroke(me.startColor);
        },
        stopped : func() {
            me.elt.setStroke(me.stopColor);
        },
        blocked : func() {
            me.elt.setStroke(me.blockColor);
        },
        update : func(value) {
            if(value == 1) {
                me.started();
            } elsif (value == 0) {
                me.stopped();
            } else {
                me.blocked();
            }
        }
};

    var FuelPanel = {
        new : func(canvas_group)
        {
            var m = { parents: [FuelPanel, MfDPanel.new("fuel",canvas_group,"Aircraft/777-300/Models/Instruments/MFD/fuel.svg",FuelPanel.update)] };
            m.context = m;
            m.initJett(m.group);
            m.initJettText(m.group);
            m.initSvgIds(m.group);
            m.initAPU(m.group);
            return m;
        },
        initSvgIds: func(group)
        {
                              
            var lbl = Label.new(group.getElementById("totalfuel"),"%3.1f",0.001);
            me.registry.add("consumables/fuel/total-fuel-lbs",lbl);
            lbl = Label.new(group.getElementById("tank0level"),"%3.1f",0.001);
            me.registry.add("consumables/fuel/tank[0]/level-lbs",lbl);
            lbl = Label.new(group.getElementById("tank1level"),"%3.1f",0.001);
            me.registry.add("consumables/fuel/tank[1]/level-lbs",lbl);
            lbl = Label.new(group.getElementById("tank2level"),"%3.1f",0.001);
            me.registry.add("consumables/fuel/tank[2]/level-lbs",lbl);
            lbl = Label.new(group.getElementById("fueltemp"),"%+2.0f",1);
            me.registry.add("engines/engine[0]/fuel-temperature-degc",lbl);
            lbl = Label.new(group.getElementById("JettFTRlbsTxt"),"%3.1f",0.001);
            me.registry.add("controls/fuel/FuelToRemain-lbs", lbl);
            lbl = Label.new(group.getElementById("JettTimeMinTxt"),"%2.1f",1.0);
            me.registry.add("controls/fuel/jettison-timeremain-min", lbl);
            me.initPumps();
            me.initBlockPumps();
            me.initValves();
            me.initJettValves();
            me.buildCircuit(0,0,"left");
            me.buildCircuit(1,2,"right");
            me.buildApuCircuit();
            me.buildJettisonOnCircuit();
        },
        
        initAPU : func(group) {
            var ApuSwitch = "controls/APU/off-start-run";
            var aputxt = Apu.new(group.getElementById("APUtxt"));
            me.registry.add(ApuSwitch, aputxt);
            aputxt = Apu.new(group.getElementById("APU"));
            me.registry.add(ApuSwitch, aputxt);
            aputxt = Apu.new(group.getElementById("APU_DCpump"));
            me.registry.add(ApuSwitch, aputxt);
            aputxt = Apu.new(group.getElementById("APU_DCpumpTxt"));
            me.registry.add(ApuSwitch, aputxt);
            aputxt = Apu.new(group.getElementById("apupipesoff"));
            me.registry.add(ApuSwitch, aputxt);
            aputxt = Apu.new(group.getElementById("apupipesoff1"));
            me.registry.add(ApuSwitch, aputxt);
        },
        
        initJettText : func(group) {
            var txt = JetText.new(group.getElementById("JettManMLWTxt")); 
            me.registry.add("controls/fuel/JettManMLW", txt);
        },
        
        initJett : func(group) {
        #Objects that are only visible when the jettison system is armed
            var Armed = "controls/fuel/jettison-arm-switch";
            
            
        # Text Labels
            var txt = Jett.new(group.getElementById("JettLNOZZLEtxt"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettRNOZZLEtxt"));
            me.registry.add(Armed, txt); 
            txt = Jett.new(group.getElementById("JettTOREMAINtxt"));
            me.registry.add(Armed, txt);       
            txt = Jett.new(group.getElementById("JettJETTTIMEtxt"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettFTRlbsTxt"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettTimeMinTxt"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettMINTxt"));
            me.registry.add(Armed, txt);
            
        # Jettison Pumps
            txt = Jett.new(group.getElementById("JettPumpL"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettPumpR"));
            me.registry.add(Armed, txt);
            
        # Jettison Valves (open valves can only show when the system is armed, so they are omitted here)
            txt = Jett.new(group.getElementById("JettValveLclosed"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettValveRclosed"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("CtrValveLclosed"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("CtrValveRclosed"));
            me.registry.add(Armed, txt);
            
        # Jettison pipes (same principle as valves)
            txt = Jett.new(group.getElementById("JettMainPipe0"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettMainPipeL0"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettMainPipeR0"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettNozzlePipeLH0"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettNozzlePipeLV0"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettNozzleL0"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettNozzlePipeRH0"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettNozzlePipeRV0"));
            me.registry.add(Armed, txt);
            txt = Jett.new(group.getElementById("JettNozzleR0"));
            me.registry.add(Armed, txt);
        },
        
        initPumps : func() {
            var pumps = {"leftfwdpump":[0,0],"leftaftpump":[0,1],
                    "leftcenterpump":[1,0],"rightcenterpump":[1,1],
                    "rightfwdpump":[2,0],"rightaftpump":[2,1],
                    "JettPumpL":[0,2],"JettPumpR":[2,2],
                    "APU_DCpump":[0,3]};
            foreach(var pumpId;keys(pumps)) {
                var (tankNb,pumpNb) = pumps[pumpId];
                var pump = Pump.new(me.group.getElementById(pumpId));
                me.registry.add("controls/fuel/tank["~tankNb~"]/m-boost-pump["~pumpNb~"]",pump);
            }
        },
        
        initBlockPumps : func() {
            var pumps = {"leftfwdpumpblocked":[0,0],"leftaftpumpblocked":[0,1],
                    "CtrPumpLblocked":[1,0],"CtrPumpRblocked":[1,1],
                    "rightfwdpumpblocked":[2,0],"rightaftpumpblocked":[2,1],
                    "JettPumpLblocked":[0,2],"JettPumpRblocked":[2,2],
                    "APU_DCpumpblocked":[0,3]};
            foreach(var pumpId;keys(pumps)) {
                var (tankNb,pumpNb) = pumps[pumpId];
                var pump = BlockPump.new(me.group.getElementById(pumpId));
                me.registry.add("controls/fuel/tank["~tankNb~"]/m-boost-pump["~pumpNb~"]",pump);
            }
        },
        
        initValves : func() {
            var valves = {  "eng0valve0":"engines/engine[0]/valve[0]/opened",
                            "eng0valve1":"engines/engine[0]/valve[1]/opened",
                            "eng1valve0":"engines/engine[1]/valve[0]/opened",
                            "eng1valve1":"engines/engine[1]/valve[1]/opened",
                            "aftxfeed":"controls/fuel/xfeedaft-valve/opened",
                            "fwdxfeed":"controls/fuel/xfeedfwd-valve/opened"};
            foreach(var rootId;keys(valves)) {
                var valve = Valve.new(me.group.getElementById(rootId~"closed"),me.group.getElementById(rootId~"opened"),me.group.getElementById(rootId~"blocked"));
                me.registry.add(valves[rootId],valve);
            }
        },
        initJettValves: func() {
            var jettvalves = {  "JettValveL":"controls/fuel/tank[0]/nozzle-valve",
                                "JettValveR":"controls/fuel/tank[2]/nozzle-valve",
                                "CtrValveL":"controls/fuel/tank[1]/nozzle-valve[0]",
                                "CtrValveR":"controls/fuel/tank[1]/nozzle-valve[1]"};
            foreach(var rootId;keys(jettvalves)) {
                var jettvalve = JettValve.new(me.group.getElementById(rootId~"closed"),me.group.getElementById(rootId~"opened"),me.group.getElementById(rootId~"blocked"));
                me.registry.add(jettvalves[rootId],jettvalve);
            }
        },
        
        buildJettisonOnCircuit : func() {
            var JettPumpL = "controls/fuel/tank[0]/boost-pump[2]";
            var JettPumpR = "controls/fuel/tank[2]/boost-pump[2]";
            var leftcenterpump = "controls/fuel/tank[1]/boost-pump[0]";
            var rightcenterpump = "controls/fuel/tank[1]/boost-pump[1]";
            var JettvalveL = "controls/fuel/tank[0]/nozzle-valve";
            var JettvalveR = "controls/fuel/tank[2]/nozzle-valve";
            var CtrValveL = "controls/fuel/tank[1]/nozzle-valve[0]";
            var CtrValveR = "controls/fuel/tank[1]/nozzle-valve[1]";
            
            var addPipe = func(valve,pipe) {
                me.registry.add(valve,pipe);
            }
            
        #Active Pipes: visible when respective fuel nozzle valve is opened.
        #Main Pipes
            pipe = Pipe.new(me.group.getElementById("JettMainPipe1"));
            pipe.feededBy(JettPumpL);
            pipe.feededBy(JettPumpR);
            pipe.feededBy(leftcenterpump);
            pipe.feededBy(rightcenterpump);
            pipe.openedBy(JettvalveL);
            pipe.openedBy(JettvalveR);
            addPipe(JettvalveL,pipe);
            
            pipe = Pipe.new(me.group.getElementById("JettMainPipe2"));
            pipe.feededBy(leftcenterpump);
            pipe.openedBy(CtrValveL);
            addPipe(CtrValveL,pipe);
            
            pipe = Pipe.new(me.group.getElementById("JettMainPipe3"));
            pipe.feededBy(rightcenterpump);
            pipe.openedBy(CtrValveR);
            addPipe(CtrValveR,pipe);
            
        # Left Fuel Nozzle Valve
            pipe = Pipe.new(me.group.getElementById("JettNozzlePipeLH1"));
            pipe.feededBy(JettPumpL);
            pipe.feededBy(JettPumpR);
            pipe.feededBy(leftcenterpump);
            pipe.feededBy(rightcenterpump);
            pipe.openedBy(JettvalveL);
            addPipe(JettvalveL,pipe);
            
            pipe = Pipe.new(me.group.getElementById("JettNozzlePipeLV1"));
            pipe.feededBy(JettPumpL);
            pipe.feededBy(JettPumpR);
            pipe.feededBy(leftcenterpump);
            pipe.feededBy(rightcenterpump);
            pipe.openedBy(JettvalveL);
            addPipe(JettvalveL, pipe);
            
            pipe = Pipe.new(me.group.getElementById("JettNozzleL1"));
            pipe.feededBy(JettPumpL);
            pipe.feededBy(JettPumpR);
            pipe.feededBy(leftcenterpump);
            pipe.feededBy(rightcenterpump);
            pipe.openedBy(JettvalveL);
            addPipe(JettvalveL,pipe);
            
        # Right Fuel Nozzle Valve
            pipe = Pipe.new(me.group.getElementById("JettNozzlePipeRH1"));
            pipe.feededBy(JettPumpL);
            pipe.feededBy(JettPumpR);
            pipe.feededBy(leftcenterpump);
            pipe.feededBy(rightcenterpump);
            pipe.openedBy(JettvalveR);
            addPipe(JettvalveR,pipe);
            
            pipe = Pipe.new(me.group.getElementById("JettNozzlePipeRV1"));
            pipe.feededBy(JettPumpL);
            pipe.feededBy(JettPumpR);
            pipe.feededBy(leftcenterpump);
            pipe.feededBy(rightcenterpump);
            pipe.openedBy(JettvalveR);
            addPipe(JettvalveR,pipe);
            
            pipe = Pipe.new(me.group.getElementById("JettNozzleR1"));
            pipe.feededBy(JettPumpL);
            pipe.feededBy(JettPumpR);
            pipe.feededBy(leftcenterpump);
            pipe.feededBy(rightcenterpump);
            pipe.openedBy(JettvalveR);
            addPipe(JettvalveR,pipe);
        },
        
        # Build APU pipes
        buildApuCircuit : func() {

            #APU valves and pumps
            var apuValve0 = "controls/APU/valve[0]/opened";
            var apuValve1 = "controls/APU/valve[1]/opened";
            var apuPump0 = "controls/fuel/tank[0]/boost-pump[0]";
            var apuPump1 = "controls/fuel/tank[0]/boost-pump[3]";
            var centerPump = "controls/fuel/tank[1]/boost-pump[0]";
            
            var pipe = Pipe.new(me.group.getElementById("apupipe1"));
            pipe.openedBy(apuValve0);
            pipe.feededBy(apuPump0);
            pipe.feededBy(centerPump);
            me.registry.add(apuValve0,pipe);

            pipe = Pipe.new(me.group.getElementById("apupipe2"));
            pipe.openedBy(apuValve0);
            pipe.openedBy(apuValve1);
            pipe.feededBy(apuPump0);
            pipe.feededBy(apuPump1);
            pipe.feededBy(centerPump);
            me.registry.add(apuValve0,pipe);

            pipe = Pipe.new(me.group.getElementById("apupipe3"));
            pipe.openedBy(apuValve0);
            pipe.openedBy(apuValve1);
            pipe.feededBy(apuPump0);
            pipe.feededBy(apuPump1);
            pipe.feededBy(centerPump);
            me.registry.add(apuValve0,pipe);

            pipe = Pipe.new(me.group.getElementById("APU_DCpipe"));
            pipe.openedBy(apuValve1);
            pipe.feededBy(apuPump1);
            me.registry.add(apuValve1,pipe);

        },
        
        buildCircuit : func(engineNb,mainTank,side) {
            var mainTank2 = abs(mainTank - 2);
            var fwdMainPump = "controls/fuel/tank["~mainTank~"]/boost-pump[0]";
            var aftMainPump = "controls/fuel/tank["~mainTank~"]/boost-pump[1]";
            var fwdMainPump2 = string.replace(fwdMainPump, "tank[" ~ mainTank, "tank[" ~ mainTank2);
            var aftMainPump2 = string.replace(aftMainPump, "tank[" ~ mainTank, "tank[" ~ mainTank2);
            var centerPump = "controls/fuel/tank[1]/boost-pump["~engineNb~"]";
            var valve = "engines/engine["~engineNb~"]/valve[0]/opened";
            var apuValve = "controls/APU/valve[0]/opened";
            var aftxfeed = "controls/fuel/xfeedaft-valve/opened";
            var fwdxfeed = "controls/fuel/xfeedfwd-valve/opened";
            var lxfdblock = "controls/fuel/xfd-off-l";
            var rxfdblock = "controls/fuel/xfd-off-r";

            var addPipe = func(pipe) {
                pipe.openedBy(valve);
                me.registry.add(valve,pipe);
            }
            
            var pipe = Pipe.new(me.group.getElementById(side~"Pipe"));
            pipe.feededBy(centerPump);
            pipe.openedBy(centerPump);
            addPipe(pipe);
            pipe = Pipe.new(me.group.getElementById(side~"AftPipe"));
            pipe.feededBy(aftMainPump);
            pipe.feededBy(centerPump);
            pipe.openedBy(centerPump);
            addPipe(pipe);
            pipe = Pipe.new(me.group.getElementById(side~"FwdPipe"));
            pipe.feededBy(aftMainPump);
            pipe.feededBy(centerPump);
            pipe.feededBy(fwdMainPump2);
            pipe.feededBy(aftMainPump2);
            pipe.openedBy(centerPump);
            pipe.openedBy(aftxfeed);
            pipe.openedBy(fwdxfeed);
            if (side == "left") {
                pipe.overridedBy(lxfdblock);
            } else {
                pipe.overridedBy(rxfdblock);
            }
            addPipe(pipe);
            #eng0Pipe0 eng0Pipe1 eng1Pipe1 eng1Pipe0
            pipe = Pipe.new(me.group.getElementById("eng"~engineNb~"Pipe0"));
            pipe.feededBy(fwdMainPump);
            pipe.feededBy(aftMainPump);
            pipe.feededBy(fwdMainPump2);
            pipe.feededBy(aftMainPump2);
            pipe.feededBy(centerPump);
            pipe.openedBy(aftxfeed);
            pipe.openedBy(fwdxfeed);
            if (side == "left") {
                pipe.openedBy(apuValve);
                pipe.overridedBy(lxfdblock);
            } else {
                pipe.overridedBy(rxfdblock);
            }
            addPipe(pipe);
            pipe = Pipe.new(me.group.getElementById("eng"~engineNb~"Pipe1"));
            pipe.feededBy(fwdMainPump);
            pipe.feededBy(aftMainPump);
            pipe.feededBy(fwdMainPump2);
            pipe.feededBy(aftMainPump2);
            pipe.feededBy(centerPump);
            pipe.openedBy(aftxfeed);
            pipe.openedBy(fwdxfeed);
            if (side == "left") {
                pipe.overridedBy(lxfdblock);
            } else {
                pipe.overridedBy(rxfdblock);
            }
            addPipe(pipe);
            #leftfwdpumppipe leftaftpumppipe
            pipe = Pipe.new(me.group.getElementById(side~"fwdpumppipe"));
            pipe.feededBy(fwdMainPump);
            pipe.overridedBy(centerPump);
            if (side == "left") {
                pipe.openedBy(apuValve);
            }
            addPipe(pipe);
            pipe = Pipe.new(me.group.getElementById(side~"aftpumppipe"));
            pipe.feededBy(aftMainPump);
            pipe.overridedBy(centerPump);
            addPipe(pipe);
            
            #only init the x-feed pipes once
            if (side =="left") {
                
                #Left & Right x-feed pumps
                pipe = Pipe.new(me.group.getElementById("xfeedpipeleft"));
                pipe.feededBy(fwdMainPump);
                pipe.feededBy(aftMainPump);
                pipe.feededBy(fwdMainPump2);
                pipe.feededBy(aftMainPump2);
                pipe.openedBy(fwdxfeed);
                pipe.openedBy(aftxfeed);
                me.registry.add(aftxfeed,pipe);
                
                pipe = Pipe.new(me.group.getElementById("xfeedpiperight"));
                pipe.feededBy(fwdMainPump);
                pipe.feededBy(aftMainPump);
                pipe.feededBy(fwdMainPump2);
                pipe.feededBy(aftMainPump2);
                pipe.openedBy(fwdxfeed);
                pipe.openedBy(aftxfeed);
                me.registry.add(aftxfeed,pipe);
                
                # fwd xfeed pipe
                pipe = Pipe.new(me.group.getElementById("xfeedpipefwd"));
                pipe.feededBy(fwdMainPump);
                pipe.feededBy(aftMainPump);
                pipe.feededBy(fwdMainPump2);
                pipe.feededBy(aftMainPump2);
                pipe.openedBy(fwdxfeed);
                me.registry.add(fwdxfeed,pipe);
                
                # aft xfeed pipe
                pipe = Pipe.new(me.group.getElementById("xfeedpipeaft"));
                pipe.feededBy(fwdMainPump);
                pipe.feededBy(aftMainPump);
                pipe.feededBy(fwdMainPump2);
                pipe.feededBy(aftMainPump2);
                pipe.openedBy(aftxfeed);
                me.registry.add(aftxfeed,pipe);
            }
            
        },
        update: func()
        {
            me.updateAll();
        }
    };
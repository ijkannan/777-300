var seatbeltNode = props.getNode("/controls/cabin/SeatBelt-status", 1);
var nosmokingNode = props.getNode("/controls/cabin/NoSmoking-status", 1);
var seatbeltKnobNode = props.getNode("/controls/cabin/SeatBelt-knob", 1);
var nosmokingKnobNode = props.getNode("/controls/cabin/NoSmoking-knob", 1);

#//Initialize with seatbelts sign off, no smoking sign on
seatbeltKnobNode.setValue(-1);
seatbeltNode.setValue(-1);
nosmokingKnobNode.setValue(1);
nosmokingNode.setValue(1);

props.getNode("/controls/cabin/altitude-limit-ft", 1).setValue(10300); #//Depends on airline, default to be 10300 ft for now - Sidi Liang

var cabinAlertUpdate = func(){
    var indAltFt = props.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1).getValue();
    var flapStatus = props.getNode("/controls/flight/flaps", 1).getValue(); 
    var gearStatus = props.getNode("/controls/gear/gear-down", 1).getValue();
    var altLimit = props.getNode("/controls/cabin/altitude-limit-ft", 1).getValue();
    #//To do: turn on both cabin alerts when cabin altitude is greater then 10000ft or passinger oxygen is on, according to FCOM - Sidi Liang

    if(seatbeltKnobNode.getValue() == 0){ #//Knob in Auto Position 
        if((indAltFt < altLimit) or (!flapStatus==0) or (gearStatus == 1)){
            seatbeltNode.setValue(1);
        }else{
            seatbeltNode.setValue(-1);
        }
    }
    if(nosmokingKnobNode.getValue() == 0){ #//Knob in Auto Position
        if(gearStatus == 1){
            nosmokingNode.setValue(1);
        }else{
           nosmokingNode.setValue(-1);
        }
    }
}

var cabinAlertTimer = maketimer(1, cabinAlertUpdate);

var cabinAlertStartup = func{
    cabinAlertTimer.start();
}

var seatbeltTrigger = func(){
    if(seatbeltKnobNode.getValue() == 0){ #//Knob in Auto Position 
        cabinAlertTimer.start();
    }else{
        if(cabinAlertTimer.isRunning) cabinAlertTimer.stop();
        seatbeltNode.setValue(seatbeltKnobNode.getValue());
    }
}

var nosmokingTrigger = func(){
    if(nosmokingKnobNode.getValue() == 0){ #//Knob in Auto Position 
        cabinAlertTimer.start();
    }else{
        if(cabinAlertTimer.isRunning) cabinAlertTimer.stop();
        nosmokingNode.setValue(nosmokingKnobNode.getValue());
    }
}

var seatbeltListener = setlistener("/controls/cabin/SeatBelt-knob", seatbeltTrigger, 1, 0);
var nosmokingListener = setlistener("/controls/cabin/NoSmoking-knob", nosmokingTrigger, 1, 0);

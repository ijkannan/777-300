#############################################################################
# 777 Autopilot Holding Pattern
# Walter York
# Version 2.0.23
#
#
#############################################################################
print("Holding Pattern v 2.0.23 .... Initialized");
var pi = 3.1415926535897932384626433832795;
var nm = 6076.12;
var M2N = 0.86897559626867145480997741980079;
var K = 0.01831523736400619484037935629362;
var htree = "/holding/";
var afds = "/instrumentation/afds/";
var inst = "/instrumentation/";
var gps = inst~"gps/";
var auto = "/autopilot/";
var rm = auto~"route-manager/";
var inp = afds~"inputs/";
var altitude_prop = "/instrumentation/altimeter/mode-s-alt-ft";
var true = 1;
var false = 0;

var debug = true;

var sin = func(a) { math.sin(a * D2R) }
var cos = func(a) { math.cos(a * D2R) }
var atan2 = func(a,b) { math.atan2(a * D2R, b * D2R) / D2R }
var tan = func(a) { math.tan(a * D2R) }
var deltaLat = func(lat2,lat1) { (lat2 - lat1) * D2R }
var deltaLong = func(long2,long1) { (long2 - long1) * D2R }
var sqrt = func (a) { math.sqrt(a) }
var round = func(a,b) { math.round(a,b) }
var abs = func(a) { math.abs(a) }
var pow = func(a,b) { math.pow(a,b) }

var altitude_org = nil;
var AFDS_altitude = nil;
var AFDS_direction = nil;
var FD = nil;
var at1 = nil;
var at2 = nil;
var alt_knob = nil;
var autothrottle_mode = nil;
var lateral_mode = nil;
var vertical_mode = nil;
var gs_armed = nil;
var loc_armed = nil;
var vor_armed = nil;
var lnav_armed = nil;
var vnav_armed = nil;
var rollout_armed = nil;
var flare_armed = nil;
var ias_mach_selected = nil;
var vs_fpa_selected = nil;
var bank_switch = nil;
var vnav_path_mode = nil;
var vnav_mcp_reset = nil;
var vnav_descent = nil;
var climb_continuous = nil;
var indicated_vs_fpm = nil;
var estimated_time_arrival = nil;
var reference_deg = nil;
var FMC_active = nil;
var FMC_current_wp = nil;
var hdg_trk_selected = nil;
var heading_reference = nil;
var crab_angle = nil;
var crab_angle_total = nil;
var rwy_align_limit = nil;
var AP = nil;
var AP_disengaged = nil;
var AP_passive = nil;
var AP_pitch_engaged = nil;
var AP_roll_engaged = nil;
var bank_min = nil;
var bank_max = nil;
var actual_target_altitude_ft = nil;
var target_altitude_ft = nil;
var last_WP = nil;
var pattern_timer = nil;
var start_pattern_timer = nil;
var closure_timer = nil;
var origin_timer = nil;
var altitude_timer = nil;
var parallel_timer = nil;
var teardrop_timer = nil;
var speed_timer = nil;
var turn_timer = nil;
var eTIMER = nil;
var turn30_timer = nil;
var match_timer = nil;

var target_heading = 0;
var direct = false;
var parallel = false;
var teardrop = true;
var lnav = false;
var turntime = 0;
var bank_angle = 15;
var turn_pattern = "";
var dir = 0.0;
var ready = false;
var adjust = 0.0;
var current_dir = 0.0;
var actual_distance = 0.0;
var lat_orig = nil;
var lon_orig = nil;
var speed_orig = nil;
var altitude_orig = nil;
var at_nav = false;
var last_distance = 9999.99;
var close_distance = 0.0;
var vnav = false;
var leg = 0.0;
var lat3 = 0.0;
var lon3 = 0.0;
var leg = 0;
var oval_leg = true;
var wait = 0;
var last_dir = 0;
var flip_flop = false;
var heading_lock = false;
var hold_speed = 0;
var speed_flag = false;
var speed_brake = false;
var cur_speed = 0;
var flaps = false;
var hold_altitude_process = false;
var reduce_alt_change = 0;
var vsp = 0;
var last_speed = 0;
var up_down = 0;
var buffer = 0;
var radial = 0;
var tracking = false;
var turn2radial = false;
var lockradial = false;
var angle = 0;
var last_adj = 0;
var approach = 0;
var bank = 0;
var bank_setpt = 0;
var lock_heading = false;
var wait_turn = false;
var leg_distance = 0.0;
var term_distance = 0;
var radial_TD = 0;
var aid = "";
var fp = nil;
var flaps_1 = 0.033;
var td_leg = 0;
var reset = false;
var wp = nil;
var current_WP = 0;
var turn_30 = false;
var TURN_30 = false;
var done = false;
var target = 0;
var turn = "";
var AOA = -10;
var SECS = 0;
var HR = 0;
var MIN = 0;
var SEC = 0;
var ELAPSED = 0;

var coords = {downsLat: 0, downsLon: 0, downsHead: 0, upsLat: 0, upsLon: 0, upsHaed: 0, downfLat: 0, downfLon: 0, downfHead: 0, upfLat: 0, upfLon: 0, upfHead: 0};

var dist_na = {FL1: 2.05, FL2: 2.3, FL3: 4.3};
var aoa_na = {FL1: -10, FL2: -10, FL3: -22};
var speed_na = {FL1: 200, FL2: 230, FL3: 265};
var alt_na = {FL1:6000, FL2: 14000};
var leg_td = {FL1: 1.25, FL3: 1.5, FL3: 2.0};

var lon = func(lon, dist) {
    return lon;
}

var lat = func( lat, dist) {
    return lat;
}

#----------------------------------------------------------------------
# ************** QUESTIONABLE ******************
#Here I explain how to convert latitude and longitude to x and y 
#coordinates in a flat-earth approximation:

#  x = R*(a2-a1)*(pi/180)*cos(b1)  
#  y = R*(b2-b1)*pi/180

#You want to do the reverse. First find the (x,y) coordinates of a 
#bunch of points on the circle using the usual Cartesian equation of a 
#circle centered at the origin:

# x^2 + y^2 = r^2

#Then you have to convert these (x,y) coordinates to the latitude and 
#longitude of each point. I don't give this transformation in the page 
#above, but it's easy enough to solve the equations for x and y to get 
#a2 and b2:
 
#  a2 = a1 + (x*180)/(R*pi*cos(b1))    
#  b2 = b1 + (y*180)/(R*pi)

#KENZY  lat = 39.22085           long = -94.564622222       

#CFPOW  lat = 39.2406766667      long = -94.63456518562523
#dDistance = 3.47064421984329

#x = r cos(lat) cos(long)

#y = r cos(lat) sin(long)

#----------------------------------------------------------------------



#Formula to find Bearing, when two different points latitude, longitude is given:
#Bearing from point A to B, can be calculated as,

#β = atan2(X,Y),

#where, X and Y are two quantities and can be calculated as:

#X = cos θb * sin ∆L
#Y = cos θa * sin θb – sin θa * cos θb * cos ∆L

#Lets us take an example to calculate bearing between the two different points with the formula:

#Kansas City: 39.099912, -94.581213
#St Louis: 38.627089, -90.200203
#So X and Y can be calculated as,

#X =  cos(38.627089) * sin(4.38101)
#X  = 0.05967668696

#And

#Y = cos(39.099912) * sin(38.627089) – sin(39.099912) * cos(38.627089) * cos(4.38101)
#Y = 0.77604737571 * 0.62424902378 – 0.6306746155 * 0.78122541965 * 0.99707812506
#Y = -0.00681261948

#So as, β = atan2(X,Y) = atan2(0.05967668696, -0.00681261948)
#           β = 96.51°
# 1 radian = 57.2958 deg       deg * pi / 180 = radians    1 nM = 1.852 km


var calc_heading = func(x2, y2) {

    var distance = getprop(htree~"distance");	
    var x1 = getprop("position/latitude-deg");
    var y1 = getprop("position/longitude-deg");
    var x = 0.0;
    var y = 0.0;
    var heading = 0.0;

#if(debug) print("Current Pos Lat = ", x1, "  Lon = ", y1);
#if(debug) print("Destination Lat = " , x2 , " Lon = " , y2);

        x = cos(x2) * sin(y2 - y1);
        y = (cos(x1) * sin(x2)) - (sin(x1) * cos(x2) * cos(y2 - y1));

#if(debug) print("results X = " , x ,"  Y = " , y);

    var	heading = atan2(x,y);
if(debug) print("Heading to Hold = ", heading, "   Bank Angle = ", getprop("orientation/roll-deg"));
    if(heading < 0) {
        heading += 360;
if(debug) print("Corrected heading = ", heading);
    }
    return heading;
}
    
#Distance and Time
#This uses the ‘haversine’ formula to calculate the great-circle distance between two points – that is, the shortest distance over #the earth’s surface – giving an ‘as-the-crow-flies’ distance between the points (ignoring any hills they fly over, of course!).

#Haversine
#formula:	
#			a = sin²(Δφ/2) + cos φ1 * cos φ2 * sin²(Δλ/2)
#			c = 2 * atan2( √a, √(1−a) )
#			d = R * c
#where	φ is latitude, λ is longitude, R is earth’s radius (mean radius = 6,371km, 3,963m);
#note that angles need to be in radians to pass to trig functions!
# 			d = 238.1992258915154

var calc_distance = func(lat1, lon1, lat2, lon2, speed = 0) {

# if(debug) print( "lat1 ", lat1, " lon1 ", lon1, " lat2 ", lat2, " lon2 ", lon2, " speed ", speed);
    var Er = 3963.0; 
    var dLat = deltaLat(lat2, lat1);
    var dLon = deltaLong(lon2,lon1); 
    var minutes = 0;
    
# if(debug) print("dLat ", dLat," dLon ", dLon);
    var a = pow(sin(dLat/2.0),2) + (cos(lat1) * cos(lat2) * pow(sin(dLon/2.0),2)); 
    var c = 2.0 * atan2(sqrt(a), sqrt(1.0-a)); 
    var d = Er * c * M2N;
# if(debug) print("a ", a , " c ", c," d ", d);
    if(speed > 0 ) {
        minutes = d / speed * 60.;
        if(debug) print("Distance = ", d, " Min = " , minutes, " Secs = ", minutes * 60.0, " at current speed = ", speed);
    }
    else {
        minutes = 0;
        if(debug) print("Distance = ", d);
    }

    return {distance: d, minutes: minutes, speed: speed};
}


#r = speed / (( deg / time ) * 20 * pi)

#R = V * V / (11.26 * tan(bank ang))
#ω = 1091 * tan(bank ang) / V
#T = A / ω 
#bank_angle = tan-1(deg_sec /1091 * speed)

#The variables used are:

#T = time is seconds
#A = Angle of the turn
#V = true airspeed in knots
#R = turning radius in feet
#θ = bank angle in degrees
#ω = rate of turn in degrees per second
#For example, at 120 knots and a 30° bank angle, the turn radius and rate of turn are:
#
#R = 120 * 120 / (11.26 * tan(30)) = 14,400 / (11.26 × 0.5773) = 2,215 feet ≈ 1/3 nautical mile
#ω = 1091 * tan(30) / 120 = (1,091 × 0.5773 * tan(30) / 120 = 5.25 °/sec
#T = 45 / 5.25 = 8.57 sec
#
#The "magic constants" in these formulas (11.26 and 1,091) are conversion factors for the units 
#involved (knots, feet, and degrees). 
#1 nM = 6076.12 ft


var calc_turn_at_distance = func(speed, ba) {

    var turn_radius = 0.0;
    var deg_sec = 0.0;
    
    turn_radius = speed * speed / (11.26 * tan(ba) * nm);
    
if(debug) print("Turn radius = ", turn_radius, " @ ", ba, " Bank Angle");
    return turn_radius;
}


var calc_turn = func(spd, radius, distance) {

    var turn_radius = 0.0;
    var deg_sec = 0.0;
    var dps = 0.0;
    var speed = 0.0;
    
    var ba = getprop("orientation/roll-deg");
    
    if(abs(ba) > 0 ){
        turn_radius = spd * spd / (11.26 * tan(abs(ba)) * nm);
        speed = sqrt(radius * M2N * (11.26 * tan(abs(ba)) * nm));
        dps = 1091.0 * tan(abs(ba)) / speed;
    }
    var turn = turn_degrees_sec(spd, radius, distance);
    turn_radius = 0.0;
    deg_sec = turn.dps/2.0;
    if(debug) print("Turn radius = ", turn_radius, " degs/secs = ", deg_sec, " Cur Bank Angle = ", ba, " DPS2 = ",dps, " Speed = ", round(speed,1));
    return { radius: turn_radius, dps: deg_sec, speed: speed};
}

# K = 0.01831523736400619484037935629362
# Cm = 2 * pi * r 
# Cn = Cm * M2N
# nph = Cn / V
# nps = nph * 3600
# dps = 360 / nps
# dps = 360 / ((((2 * pi * r) * M2N) / V) * 3600)
# dps = K / (r / V)


var turn_degrees_sec = func(speed, radius, distance) {

    var degrees_per_sec = 0.0;
    var current_ba = getprop("orientation/roll-deg");
    var ba1 = speed * speed / (11.26 * nm * radius);
    var ba = atan2(ba1,(1.0 - ba1));
    
    degrees_per_sec = K / (radius / 2.0 / speed);

    if(turn_pattern == "right")  {
        setprop("autopilot/internal/holding-pattern-roll",ba);
    }	
    else {
        degrees_per_sec *= -1.0;
        setprop("autopilot/internal/holding-pattern-roll",-ba);
    }
    
    if(debug) print("DPS = ", degrees_per_sec, " Requires a B/A = ", ba, " Cur B/A = ", current_ba);
    return {dps: degrees_per_sec, angle : ba, bank_angle: current_ba};
}

var monitor_turns = func () {

    var cur = round(getprop(gps~"indicated-track-magnetic-deg"),1);
    var delta = 0;
    
    if(bank == 0) {
        if( turn == "right" ) {
            bank_setpt = -10;
            bank = 15;
        }
        else {
            bank_setpt = 10;
            bank = -15;
        }
        #if(TURN_30) bank_setpt *= 2;
        done = false;
        target = new_heading(dir, bank_setpt);
    if(debug) print("Bank Monitor STARTING -- Set Point @ ", bank_setpt, "     Target Dir = ", target);
    }

    
    if (round(cur,1) == round(target,1)) {
        setprop("autopilot/internal/holding-pattern-roll", bank);
        if(turn == "right")
            bank -= 2.5;
        else
            bank += 2.5;
        if(abs(bank) < 2) {
            if(turn == "right" )
                bank = 2;
            else
                bank = -2;
        }
    }
    if (cur == round(dir,1)) {
        turn_timer.stop();
        turn_timer = nil;
        bank = 0;
        TURN_30 = false;
        #setprop("autopilot/internal/holding-pattern-roll", bank);
        setprop(auto~"settings/heading-bug-deg", cur);
    if(debug) print("Bank Monitor SHUTDOWN .....");
    }
}

var monitor_speed = func () {

    cur_speed = getprop("instrumentation/airspeed-indicator/indicator-speed-kt"); 
    var delta = round((getprop(auto~"settings/target-speed-kt") - cur_speed),1);
    var hold = false;
    
    if((cur_speed - last_speed) < 0) {
        hold = true;
    } else
        hold = false;

    if(abs(delta) > 8 and !hold_altitude_process) {
        hold_altitude_process = true;
        
    } else if(abs(delta) > 3 and !hold_altitude_process and !hold) {
        setprop("controls/flight/speedbrake",1);
        speed_brake = true;
        if(reduce_alt_change < .71) reduce_alt_change += .05;
    } else if(abs(delta) <= .5 ){
        hold_altitude_process = false;
    }
    if(speed_brake and vsp == 0 and !hold_altitude_process and !hold) {
        setprop("controls/flight/speedbrake",0);
        speed_brake = false;
    }
    last_speed = cur_speed;
}

var altitude_hold = func () {

    if(getprop(altitude_prop) == getprop(auto~"settings/counter-set-altitude-ft")) {
        vnav = false;
        hold_altitude_process = false;
        reduce_alt_change = 0;
        return;
    }
    
    var delta = getprop(altitude_prop) - getprop(auto~"settings/counter-set-altitude-ft");
    var vsp = 0; 
    var up_down = 1;
    
    if(!vnav) {
        setprop(afds~"inputs/vertical-index", 2); 
        vnav = true;
    }
        
    if(delta > 0 ) {
        up_down = -1;
        buffer += .05;
        if(buffer > 1.0) buffer = 1;
    }
    else {
        reduce_alt_change = 0;
        hold_altitude_progress = false;
        buffer = 1;
    }
    

    if(!hold_altitude_process) {
        if(abs(delta) > 5000)
            vsp = (2800 * buffer) - (2800 * reduce_alt_change);
        else if(abs(delta) > 2500)
            vsp = (2500 * buffer) - (2500 * reduce_alt_change);
        else if(abs(delta) > 1000)
            vsp = (2000 * buffer) - (2000 * reduce_alt_change);
        else if(abs(delta) > 500)
            vsp = (1800 * buffer) - (1800 * reduce_alt_change);
        else if(abs(delta) <= 500)
            vsp = 900 - (900 * reduce_alt_change);
    } else  {
        vsp = 0;
        setprop(auto~"settings/vertical-speed-fpm", 0);
        reduce_alt_change = 0;
        buffer = 0;
        return;
        }
        
    if(vsp == 0) { 
        vnav = false;
        reduce_alt_change = 0;
        buffer = 0;
        return;
        }
    setprop(auto~"settings/vertical-speed-fpm", vsp * up_down);
}

var diff_heading = func (head1, head2) {

    var val = head1 - head2;
    
    if(abs(val) < 180) return val;
    if( val < 0 ) val += 360;
    if( val > 0 ) val -= 360;
    return val;
}

var new_heading = func (head, offset) {

    head += offset;
    if(head > 360)
        head -= 360;
    else if(head <= 0)
        head += 360;
    return head;
}

var startTimer = func () {

    SECS = 0;
    ELASPSED = 0;
    HR = 0;
    MIN = 0;
    SEC = 0;
    eTIMER = maketimer(1,time);
    eTIMER.simulatedTime = 1;
    eTIMER.start();
}

var resetTimer = func() {

    SECS = 0;
}

var resetETimer = func() {

    ELAPSED = 0;
}


var endTimer = func() {

    eTIMER.stop();
    eTIMER = nil;
}

var time = func () {

    SECS += 1;
    ELAPSED += 1;
    HR = int(ELAPSED / 3600);
    MIN = int((ELAPSED - (HR * 3600)) / 60);
    if(MIN > 59) {
        HR += 1;
        MIN -= 60;
    }
    SEC = int(ELAPSED - (HR * 3600) - (MIN * 60));
    
    if(debug) print("Seconds = ", SECS,"   Elapsed Time = ", HR, ":", (MIN < 10) ? "0" : "", MIN, ":", (SEC < 10) ? "0" : "", SEC);
    return SECS;
}


var track_radial = func (head, Radial) {


    var reciprical = 0;
    var delta = 0;
    var Dir = getprop(gps~"indicated-track-magnetic-deg");

    reciprical = (approach == 0) ? new_heading(head, 180) : head;
    delta = diff_heading(reciprical, Radial);
    
    if(debug) print("Dir = ", Dir, "   Heading to Navaid = ", head, "  Reciprical = ", reciprical, "   Radial = ", Radial, "   Current delta = ", delta);

    if( round(abs(delta),1) == 0 and heading_lock) 
        return true;
        
    if(!tracking) {
        if( abs(delta) == 1 and wait != -1) {
            delta = 3;
            angle = 0;
        }
        else if( abs(delta) <= 5  and wait != -1) {
            delta = 6;
            angle = 1;
        }			
        else if( abs(delta) <= 8) {
            delta = 10;
            angle = 2;
        }			
        else if( abs(delta) <= 15 ) {
            delta = 15;
            angle = 7;
        }			
        else if(delta <= 30) {
            delta = 30;
            angle = 10;
        }
        else if(delta <= 40) {
            delta = 30;
            angle = 15;
        }
        else {
            delta = 45;
            angle = 25;
        }
        heading_lock = false;
        if(abs(delta) > 20)
            turn_30 = true;
        else
            turn_30 = false;
        wait = true;

        if(reciprical < Radial) {
            make_turn("left", delta);
            if(debug) print("Turning Left -- ", delta);
            turn = "right"
        }
        else {
            make_turn("right", delta);
            turn = "left";
            if(debug) print("Turning Right -- ", delta);
        }
        tracking = true;
        if(debug) print("Offest Angle -- ", angle);
    }
    
    if(heading_lock) return true;
    
    delta = round(diff_heading (reciprical, Radial),1);
    if(debug) print("Degrees from Path -- ", delta); 

    if( !wait and abs(delta) <= 10 and getprop(afds~"ap-modes/roll-mode") == "HDG HOLD" and delta != 0) {
            tracking = false;
    if(debug) print("Re-enable Tracking .....");
            return false;
        }
        
    if(abs(delta) <= angle and wait and turn_30) {
            if( !wait_turn and wait) {  
                if(debug)print("Clear Wait Flag ....");
                wait = false;
            }
            dir = head;
            TURN_30 = true;
            turn30((reciprical > Radial) ? "left" : "right", head);
            turn_timer = maketimer(.1, monitor_turns);
            turn_timer.simulatedTime = 1;
            turn_timer.start();
            turn_30 = false;
            gui.popupTip("Turning back to Navaid");
            if(debug) print("Turning towards Radial [", delta, "] -- " , round(head,1), " Degrees", "   Curr Heading to Navaid = " , head);
        } else if(abs(delta) <= angle and wait) {
            setprop(auto~"settings/heading-bug-deg", round(head,1));
            if(!turn2radial) {
                gui.popupTip("Turning onto Radial");
                turn2radial = true;
            }
            if(debug) print("Turning towards Radial [", delta, "] -- " , round(head,1), " Degrees", "   Curr Heading to Navaid = " , head);
        }
        
        if(getprop(afds~"ap-modes/roll-mode") == "HDG HOLD" and wait and abs(delta) <= angle) {
                if(debug)print("Clear Wait Flag ....");
                wait = false;
            }
        
    if (reciprical == Radial and getprop(afds~"ap-modes/roll-mode") == "HDG HOLD") {
        if(!heading_lock) setprop(auto~"settings/heading-bug-deg", round(head,1));
        heading_lock = true;
        wait = false;
        if(debug) print("Radial Locked ......");
        if(!lockradial) {
            lockradial = true;
            gui.popupTip("Radial Locked");
        }
        return true;
        }

    return false;
}

var close_on_navaid = func (){

    var na = {};
    var heading = 0;
    var fly2na = {};
    var lat1 = getprop("position/latitude-deg");
    var lon1 = getprop("position/longitude-deg");
    var lat2 = getprop(htree~"latitude-deg");
    var lon2 = getprop(htree~"longitude-deg");
    var navaid_dis = getprop(htree~"distance");
    var leg = getprop(htree~"leg");
    var speed = getprop("instrumentation/airspeed-indicator/indicator-speed-kt"); 
    var alt = getprop(altitude_prop);
    

    na = calc_distance(lat1, lon1, lat2, lon2, speed);
#	heading = round((calc_heading(lat2, lon2) + 0),1);
    heading = round(calc_heading(lat2, lon2),1);

    if(approach == 1) {
        heading =  round(new_heading(heading, AOA) -.5,1);
        if(debug) print("Parallel approach Heading = ", heading);
    }
#	if(!heading_lock and (!lnav or approach == 1)) setprop(auto~"settings/heading-bug-deg", round(heading,1));

    if(!heading_lock and !lnav and approach == 0) {
        setprop(auto~"settings/heading-bug-deg", round(heading,1));
        if(getprop(afds~"ap-modes/roll-mode") == "HDG HOLD") target_heading = heading;
        if(round(getprop(gps~"indicated-track-magnetic-deg"),1) != round(heading,1) and target_heading != 0 ) {
            if(!match_heading(heading)) return;
        }
    } else if(!heading_lock and !lnav and approach == 1) {
        setprop(auto~"settings/heading-bug-deg", round(heading,1));
    }

    if(getprop(afds~"ap-modes/roll-mode") == "HDG HOLD" and !lnav) {
        lnav = true;
        tracking = false;
        target_heading = 0;
        wait = -1;
        close_distance = na.distance;
        last_distance = na.distance;
        if(approach == 0) {
            gui.popupTip("Locked on "~aid~"  Distance = "~sprintf("%6.2f", close_distance)~" Nm "~getprop(inst~"clock/indicated-string")~" Zulu");
            print("Locked on "~aid~"  Distance = "~sprintf("%6.2f", close_distance), " Nm " , getprop(inst~"clock/indicated-string"), " Zulu");
        }
        if(alt <= alt_na.FL1) {
            term_distance = dist_na.FL1;
            AOA = aoa_na.FL1;
        } else if(alt <= alt_na.FL2) {
            term_distance = dist_na.FL2;
            AOA = aoa_na.FL2
        } else {
            term_distance = dist_na.FL3;
            AOA = aoa_na.FL3;
        }
        heading_lock = false;
        reset = false;
        if(na.distance > 15.0) reset = true;
        if(debug) print("Setting to Track .... Close Distance = ", close_distance, "Last Distance = ", last_distance, "   Dist to navaid = ", na.distance);
        if(approach == 2) term_distance = .65173;
        return;
        }
        
        
    if(lnav) {
        close_distance -= abs(last_distance - na.distance);
        if(heading_lock and lnav and reset and na.distance < 9.01 and na.distance > 7.5) {
            lnav = false;
            heading_lock = false;
            reset = false;
            tracking = false;
            return;
        }
        if(na.distance < term_distance and !reset) {
            if(debug) print("Final Turn onto Radial ... ", (approach == 0) ? new_heading(radial, 180) : radial, "   Term Distance = ", term_distance, "  Cur Dist = ", na.distance);
            if( approach != 1 and getprop(auto~"settings/heading-bug-deg") != ((approach == 0) ? new_heading(radial, 180) : radial)) {
                heading = (approach == 0) ? new_heading(radial, 180) : radial;
                setprop(auto~"settings/heading-bug-deg", round(heading,1));
                if(debug)print("Taking option 1 ...... ", approach);
            }
            else if(approach == 1 and getprop(auto~"settings/heading-bug-deg") != radial) {
                dir = radial;
                turn = turn_pattern;
                turn30(turn_pattern, radial);
                turn_timer = maketimer(.1, monitor_turns);
                turn_timer.simulatedTime = 1;
                turn_timer.start();
                gui.popupTip("Turning onto Radial");
                if(debug) print("Make 30 Deg turn onto Radial -- ", radial);
            } else
                if(debug) print("None of the Above were choosen ....");
            heading_lock = true;
            reset = true;
        }
        
        if(debug) print("New CLOSE Dist = ", close_distance);
        flip_flop = false;
    } else {
        close_distance = 9999;
        heading_lock = false;
        speed_flag = false;
        }
        
    if(!heading_lock and lnav and approach == 0) track_radial(round(heading,1), radial);
        
    if(hold_speed == 0 and close_distance <= 5.0){
        if(alt <= alt_na.FL1) {
            hold_speed = speed_na.FL1;
            flaps = true;
            setprop("controls/flight/flaps",flaps_1);
        } else if(alt <= alt_na.FL2) {
            hold_speed = speed_na.FL2;
        } else {
            hold_speed = speed_na.FL3;
        }
        if(debug) print("Set Approach Speed = ", hold_speed);
        setprop(auto~"settings/target-speed-kt",hold_speed);
    } 
        
    if(close_distance <= 0 ) {

        closure_timer.stop();
        closure_timer = nil;
        lnav = false;
        ready = false;
        heading_lock = false;
        TURN_30 = false;
        if(parallel)
            approach = 1;
        else if (teardrop)
            approach = 2;

        if(direct) {
            if(debug) print ("DIRECT approach");
            if(approach != 0) radial = new_heading(radial,180);
            pattern_timer = maketimer(.25, fly_pattern);
            pattern_timer.simulatedTime = 1;
            pattern_timer.start();
        } else if(parallel) {
            if(debug) print("PARALLEL approach");
            parallel_timer = maketimer(.25, parallel_approach);
            parallel_timer.simulatedTime = 1;
            parallel_timer.start();
        }
        return;
    } 

    if(debug) print("Avg Distance = ", na.distance - last_distance, "  Closure = ", close_distance, "  Dir = ", getprop(gps~"indicated-track-magnetic-deg"));

    last_distance = na.distance;
}

var match_heading = func (target) {

    dir = getprop(gps~"indicated-track-magnetic-deg");
    
    var x = diff_heading(dir,target) * -1;
    if ((abs(x) - .25) < 1) return true;
    var y = new_heading(getprop(auto~"settings/heading-bug-deg"),round(x,1));
    if(debug) print("Heading = ", dir, "  Target = ", target, "  Bug = ", getprop(auto~"settings/heading-bug-deg"), "  Diff = " , x, "  New Head = " , y);
    setprop(auto~"settings/heading-bug-deg", round(y,1));
    return false;
}


var close_on_navaid_TD = func (){

    var na = {};
    var heading = 0;
    var fly2na = {};
    var lat1 = getprop("position/latitude-deg");
    var lon1 = getprop("position/longitude-deg");
    var lat2 = getprop(htree~"latitude-deg");
    var lon2 = getprop(htree~"longitude-deg");
    var navaid_dis = getprop(htree~"distance");
    var leg = getprop(htree~"leg");
    var speed = getprop("instrumentation/airspeed-indicator/indicator-speed-kt"); 

    na = calc_distance(lat1, lon1, lat2, lon2, speed);
    heading = round(calc_heading(lat2, lon2),1);
    
    if(!heading_lock and !lnav) {
        setprop(auto~"settings/heading-bug-deg", round(heading,1));
        if(getprop(afds~"ap-modes/roll-mode") == "HDG HOLD") target_heading = heading;
        if(round(getprop(gps~"indicated-track-magnetic-deg"),1) != round(heading,1) and target_heading != 0 ) {
            if(!match_heading(heading)) return;
        }
    } 
        
    if(getprop(afds~"ap-modes/roll-mode") == "HDG HOLD" and !lnav) { #and getprop(auto~"settings/heading-bug-deg") == round(getprop(gps~"indicated-track-magnetic-deg"),1)
        lnav = true;
        target_heading = 0;
        heading_lock = false;
        close_distance = na.distance;
        last_distance = na.distance;
        wait = -1;
        gui.popupTip("Locked on "~aid~"  Distance = "~sprintf("%6.2f", close_distance)~" Nm "~getprop(inst~"clock/indicated-string")~" Zulu");
        print("Locked on "~aid~"  Distance = "~sprintf("%6.2f", close_distance), " Nm " , getprop(inst~"clock/indicated-string"), " Zulu");
        if(debug) print("Setting to Track .... Close Distance = ", close_distance, "  Last Distance = ", last_distance, "   Dist to navaid = ", na.distance);
        return;
        }
        
        
    if(lnav) {
        close_distance -= abs(last_distance - na.distance);
        if(na.distance < 1.6) {
            if(getprop(auto~"settings/heading-bug-deg") != radial_TD) {
                heading = radial_TD;
                if(debug) print("TD Lock Radial -- ", heading, "   Dist to NA = ", na.distance);
                setprop(auto~"settings/heading-bug-deg", round(heading,1));
                gui.popupTip("Radial Locked");
            }
            heading_lock = true;
        } 
        if(debug) print("New TD CLOSE Dist = ", close_distance);
        flip_flop = false;
    } else {
        close_distance = 9999;
        heading_lock = false;
        speed_flag = false;
        }
        
    if(!heading_lock and lnav) 
        track_radial(round(heading,1), radial_TD);

        
    if(hold_speed == 0 and close_distance <= 5.0){
        var alt = getprop(altitude_prop);
        if(alt <= alt_na.FL1) {
            term_distance = dist_na.FL1;
            hold_speed = speed_na.FL1;
            flaps = true;
            setprop("controls/flight/flaps",flaps_1);
        } else if(alt <= alt_na.FL2) {
            hold_speed = speed_na.FL2;
            term_distance = dist_na.FL2;
        } else {
            hold_speed = speed_na.FL3;
            term_distance = dist_na.FL3;
        }
        setprop(auto~"settings/target-speed-kt",hold_speed);
    } 
        
    if(close_distance <= 0 ) {

        closure_timer.stop();
        closure_timer = nil;
        lnav = false;
        heading_lock = false;
        ready = false;
        TURN_30 = false;
        approach = 2;

        if(debug) print("TEARDROP approach");
        teardrop_timer = maketimer(.25, teardrop_approach);
        teardrop_timer.simulatedTime = 1;
        teardrop_timer.start();
        return;
    } 

    if(debug) print("Avg Distance = ", na.distance - last_distance, "  Closure = ", close_distance, "  Dir = ", getprop(gps~"indicated-track-magnetic-deg"));

    last_distance = na.distance;
}


var turn_at_navaid = func () {

    setprop(afds~"inputs/lateral-index", 1);
    make_turn(((turn_pattern == "right") ? "left" : "right"), 45);
    var current_ba = getprop(auto~"internal/target-roll-deg");
    if(debug) print("Turning onto the Teardtop....." , dir, "   Start approach for Teardrop entry");
    teardrop_timer = maketimer(.25, teardrop_approach);
    teardrop_timer.simulatedTime = 1;
    teardrop_timer.start();
}

var qtr_turn_next_leg = func (pattern,angle=25) {

    if(debug) print("Turning ", pattern, "  at an angle of ", angle, " degrees");	

    if(angle != 25) {
        if(pattern == "right")  {
        setprop("autopilot/internal/holding-pattern-roll",angle);
        }	
        else {
            setprop("autopilot/internal/holding-pattern-roll",-angle);
        }
    } else {
        if(pattern == "right" )
            dir += 90;
        else 
            dir -= 90;
        if (dir < 0)
            dir +=  360;
        else if (dir > 360)
            dir -= 360; 
        setprop(auto~"settings/heading-bug-deg", round(abs(dir),1));
    }
}

var turn30 = func (pattern, head) {

    var offset = 0;
    var bank_angle = 0;
    if(debug) print("Turning ", pattern, "  to ", head, " degrees");	

    setprop(inp~"FD", false);
    setprop(afds~"inputs/lateral-index", 0);
    setprop("instrumentation/afds/ap-modes/lnav-is-pattern", "1");
    setprop(afds~"inputs/lnav-armed", true);
    wait_turn = true;
    if(pattern == "right")  {
        setprop("autopilot/internal/holding-pattern-roll",30);
        offset = -10;
        bank_angle = 30;
    }	
    else {
        setprop("autopilot/internal/holding-pattern-roll",-30);
        offset = 10;
        bank_angle = -30;
    }
    var heading = new_heading(head, offset);
    turn30_timer = maketimer(.1,func(){
    if(round(getprop(gps~"indicated-track-magnetic-deg"),1) == round(head,1)){
        turn30_timer.stop();
        turn30_timer = nil;
        setprop("autopilot/internal/holding-pattern-roll",0);
        setprop(afds~"inputs/lateral-index", 1);
        setprop("instrumentation/afds/ap-modes/lnav-is-pattern", " ");
        setprop(afds~"inputs/lnav-armed", false);
        setprop(auto~"settings/heading-bug-deg", round(head,1));
        wait_turn = false;
    }
    else if(round(getprop(gps~"indicated-track-magnetic-deg"),1) < round(heading,1)) {
        setprop("autopilot/internal/holding-pattern-roll", bank_angle);
        if(debug) print("Target = ", head, "   Heading -- " , getprop(gps~"indicated-track-magnetic-deg"), "    Bank Angle = ", getprop("autopilot/internal/holding-pattern-roll"));
    }
});
    turn30_timer.simulatedTime = 1;
    turn30_timer.start();

}



var make_turn = func (pattern, degrees) {
    
    var d = round(getprop(gps~"indicated-track-magnetic-deg") - .5,1);
    if(pattern == "right" )
        d = new_heading(d,degrees);
    else 
        d = new_heading(d,-degrees);
    if(debug) print("Make Turn .... ", pattern, "  ", ((pattern == "left") ? "-" :""), degrees, "  Degrees -- New Dir = ", round(abs(d),1));
    setprop(auto~"settings/heading-bug-deg", round(d,1));
}


var parallel_approach = func () {

    var test_dir = 0;
    var na = {};
    var speed = getprop("instrumentation/airspeed-indicator/indicator-speed-kt"); 
    var speed = getprop("velocities/groundspeed-kt");
    var lat1 = getprop("position/latitude-deg");
    var lon1 = getprop("position/longitude-deg");
    var lat2 = getprop(htree~"latitude-deg");
    var lon2 = getprop(htree~"longitude-deg");

    if(ready == false) {	

        gui.popupTip("Executing a Parallel Approcah at "~aid~" "~getprop(inst~"clock/indicated-string")~" Zulu");
        print("Executing a Parallel Approcah at "~aid, " " , getprop(inst~"clock/indicated-string"), " Zulu");
        current_dir = getprop(gps~"indicated-track-magnetic-deg");
        var heading = calc_heading(lat2, lon2);
        turn = turn_pattern;
        ready = true;
        oval_leg = true;
        flip_flop = false;
        leg = getprop(htree~"parallel-leg") * 60 * .85; #76.5
        startTimer();
        return;
    }

    if( oval_leg ) {
        if(debug) print("Time left on this leg = " , leg - SECS);
        if(SECS >= leg) {
            oval_leg = false;
            if(debug) print("Leg completed ...... Turning ", (turn_pattern == "right") ? "left" : "right");
            setprop(inp~"FD", false);
            setprop(afds~"inputs/lateral-index", 0);
            setprop("instrumentation/afds/ap-modes/lnav-is-pattern", "1");
            setprop(afds~"inputs/lnav-armed", true);
            dir = getprop(gps~"indicated-track-magnetic-deg");
            dir = new_heading(dir, 180);
            qtr_turn_next_leg(((turn_pattern == "right") ? "left" : "right"),30);
            turn_timer = maketimer(.1, monitor_turns);
            turn_timer.simulatedTime = 1;
            turn_timer.start();
            resetTimer();
            return;
        }
    } else if (round(getprop(gps~"indicated-track-magnetic-deg"),1) == round(dir,1)) {
    
        parallel_timer.stop();
        parallel_time = nil;
        endTimer();
        lnav = false;
        ready = false;
        parallel = false;
        current_WP = fp.indexOfWP(wp);
        if(fp.current != current_WP) fp.current = current_WP;
        dir = getprop(gps~"indicated-track-magnetic-deg");
        direct = true;
        setprop(afds~"inputs/lateral-index", 1);
        setprop("instrumentation/afds/ap-modes/lnav-is-pattern", " ");
        setprop(afds~"inputs/lnav-armed", false);
#		setprop(auto~"settings/heading-bug-deg", round(dir,1));
        closure_timer = maketimer(.25, close_on_navaid);
        closure_timer.simulatedTime = 1;
        closure_timer.start();
        return;
    } else {
        if(debug) print( "Waiting on turn to Complete .... Secs = ", SECS, "   Bank Angle = ", getprop("orientation/roll-deg"), "   Heading = " , round(getprop(gps~"indicated-track-magnetic-deg"),1), " <> Target = " , round(dir,1));
    }


}
var teardrop_approach = func () {

    var test_dir = 0;
    var na = {};
    var speed = getprop("instrumentation/airspeed-indicator/indicator-speed-kt"); 
    var speed = getprop("velocities/groundspeed-kt");
    var lat1 = getprop("position/latitude-deg");
    var lon1 = getprop("position/longitude-deg");
    var lat2 = getprop(htree~"latitude-deg");
    var lon2 = getprop(htree~"longitude-deg");

    if(ready == false) {	

        gui.popupTip("Executing a TEARDROP Approach at "~aid~" "~getprop(inst~"clock/indicated-string")~" Zulu");
        print("Executing a TEARDROP Approach at "~aid, " " , getprop(inst~"clock/indicated-string"), " Zulu");
        ready = true;
        oval_leg = true;
        flip_flop = false;
        turn = turn_pattern;
        dir = getprop(gps~"indicated-track-magnetic-deg");
        var alt = getprop(altitude_prop);
        if(alt <= alt_na.FL1) {
            td_leg = leg_td.FL1;
        } else if(alt <= alt_na.FL2) {
            td_leg = leg_td.FL2;
        } else {
            td_leg = leg_td.FL3;
        }

        td_leg *= 60;
        if(debug) print("TD Leg = ", td_leg);
        startTimer();
    }
    
    if( oval_leg ) {
        if(debug) print("Time left on this leg = " , td_leg - SECS);
        if(SECS >=  td_leg) {
            oval_leg = false;
            if(debug) print("Leg completed ...... Making Turning ", turn_pattern );
            setprop(inp~"FD", false);
            setprop(afds~"inputs/lateral-index", 0);
            setprop("instrumentation/afds/ap-modes/lnav-is-pattern", "1");
            setprop(afds~"inputs/lnav-armed", true);
            resetTimer();
            dir = new_heading(radial, 5);
            qtr_turn_next_leg(turn_pattern, 30);
            turn_timer = maketimer(.1, monitor_turns);
            turn_timer.simulatedTime = 1;
            turn_timer.start();
            return;
        }
    } else if (round(getprop(gps~"indicated-track-magnetic-deg"),1) == round(dir,1)) {
        teardrop_timer.stop();
        teardrop_time = nil;
        lnav = false;
        ready = false;
        current_WP = fp.indexOfWP(wp);
        if(fp.current != current_WP) fp.current = current_WP;
        setprop(afds~"inputs/lateral-index", 1);
        setprop("instrumentation/afds/ap-modes/lnav-is-pattern", " ");
        setprop(afds~"inputs/lnav-armed", false);
#		setprop(auto~"settings/heading-bug-deg", round(dir,1));
        endTimer();
        teardrop = false;
        direct = true;
        lnav = false;
        approach = 3;
        closure_timer = maketimer(.25, close_on_navaid);
        closure_timer.simulatedTime = 1;
        closure_timer.start();
        return;
    } else {
        if(debug) print( "Waiting on turn to Complete .... Secs = ", SECS, "   Bank Angle = ", getprop("orientation/roll-deg"), "   Heading = " , round(getprop(gps~"indicated-track-magnetic-deg"),1), " <> Target = " , round(dir,1));
    }
}
        
## Reference ->> https://en.wikipedia.org/wiki/Holding_(aeronautics)
## 				 https://www.skybrary.aero/index.php/Holding_Pattern
##				 https://www.cfinotebook.net/notebook/maneuvers-and-procedures/instrument/aircraft-holding-procedures
##				 https://cdn.shopify.com/s/files/1/0556/5101/files/Holding.pdf
##				 https://www.faa.gov/air_traffic/publications/atpubs/aip_html/part2_enr_section_1.5.html
##				 https://demonstrations.wolfram.com/PracticingAircraftHoldingPatternEntries/
##				 http://www.pilotfriend.com/training/flight_training/nav/ifr_hold.htm
##
var fly_pattern = func () {

    var na = {};
    var lat1 = getprop("position/latitude-deg");
    var lon1 = getprop("position/longitude-deg");
    var lat2 = getprop(htree~"latitude-deg");
    var lon2 = getprop(htree~"longitude-deg");

    if(wait_turn) return;
    
    if(ready == false) {	
            ready = true;
            turn = turn_pattern;
            gui.popupTip("Establishing the Holding Pattern at "~aid~" "~getprop(inst~"clock/indicated-string")~" Zulu");
            print("Establishing the Holding Pattern at "~aid, " " , getprop(inst~"clock/indicated-string"), " Zulu");
            if(debug) print("Pattern INIT .... turns = ", turn_pattern);
            setprop(inp~"FD", false);
            setprop(afds~"inputs/lateral-index", 0);
            setprop("instrumentation/afds/ap-modes/lnav-is-pattern", "1");
            setprop(afds~"inputs/lnav-armed", true);
            setprop(auto~"settings/target-altiude-ft",getprop(htree~"altitude"));
            setprop(auto~"settings/actual-target-altiude-ft",getprop(htree~"altitude"));
            oval_leg = false;
            flip_flop = false;
            dir = getprop(gps~"indicated-track-magnetic-deg");
            coords.upfLat = lat2;
            coords.upfLon = lon2;
            dir = new_heading(radial,180);
            coords.upfHead = dir; 
            if(debug) print("Inbound Final Dir -- ", coords.upfHead);			
            coords.downsHead = radial;
            dir = coords.downsHead;
            if(debug) print("Outbound Starting Dir -- ", coords.downsHead);
            startTimer();
            qtr_turn_next_leg(turn_pattern, 30);
            turn_timer = maketimer(.1, monitor_turns);
            turn_timer.simulatedTime = 1;
            turn_timer.start();
            leg = getprop(htree~"leg");
    }
    if( oval_leg ) {
        na = calc_distance(lat1, lon1, lat3, lon3,0);
        if(!flip_flop and (leg - SECS) > int(leg / 2)) {
            dir = calc_heading(coords.upfLat, coords.upfLon);
            setprop(auto~"settings/heading-bug-deg", round(dir,1));
        } else if(flip_flop and (leg - SECS) > 10 and coords.downfLat != 0) {
            dir = coords.downsHead; 
            setprop(auto~"settings/heading-bug-deg", round(dir,1));
        }
        if(debug) print("Time left on this leg = " , leg - SECS, "   Cur Value Dir = ", dir, "   Act Dir = " , getprop(gps~"indicated-track-magnetic-deg"));
        if((flip_flop and (SECS >= leg)) or (!flip_flop and abs(na.distance) >= leg_distance)) {
            oval_leg = false;
            
            if(flip_flop and coords.downfLat == 0) {
                coords.downfLat = lat1;
                coords.downfLon = lon1;
                coords.downfHead = dir;
            }
            
            if(debug) print("Leg completed ...... Turning " , turn_pattern);
            dir = getprop(gps~"indicated-track-magnetic-deg");
            if(flip_flop) {
                dir = coords.upfHead;
                if(debug) print("Inbound Start Dir = ", dir);
            } else {
                dir = coords.downsHead;
                if(debug) print("Outbound Start Dir = ", dir);
                }
            setprop(afds~"inputs/lateral-index", 0);
            setprop("instrumentation/afds/ap-modes/lnav-is-pattern", "1");
            setprop(afds~"inputs/lnav-armed", true);
            resetTimer();
            qtr_turn_next_leg(turn_pattern, 30);
            turn_timer = maketimer(.2, monitor_turns);
            turn_timer.simulatedTime = 1;
            turn_timer.start();
            if(debug) print((flip_flop) ? "Outbound" : "Inbound", " Leg completed ...... Turning " , turn_pattern, "  to Heading = ", dir);
            return;
        }
    }
    else if (round(getprop(gps~"indicated-track-magnetic-deg"),1) == round(dir,1)) {
        setprop(afds~"inputs/lateral-index", 1);
        setprop("instrumentation/afds/ap-modes/lnav-is-pattern", "");
        setprop(afds~"inputs/lnav-armed", false);
        setprop(auto~"settings/heading-bug-deg", round(dir,1));
        if(debug) print("Now on Heading = ", dir);
        current_WP = fp.indexOfWP(wp);
        setprop(auto~"route-manager/current-wp", current_WP);

        flip_flop = (flip_flop) ? false: true;

        if(flip_flop and coords.downsLat == 0) {
            coords.downsLat = lat1;
            coords.downsLon = lon1;
            if(debug) print("Outbound Leg Starting Dir = ", coords.downsHead);
        } else if(!flip_flop and coords.upsLat == 0) {
            coords.upsLat = lat1;
            coords.upsLon = lon1;
            if(debug) print("Inbound leg Starting Dir = ", coords.upsHead);
        }
        if(!flip_flop){
            var na = calc_distance(lat1, lon1, coords.upfLat, coords.upfLon, 0);
            leg_distance = na.distance;
            if(debug) print("Calculated Distance for Inbound Leg = ", leg);
        } else {
            leg_distance = 999;
        }
            leg = getprop(htree~"leg") * 60;
        

        if(flip_flop) {
            lat3 = coords.downsLat;
            lon3 = coords.downsLon;
        } else {
            lat3 = coords.upsLat;
            lon3 = coords.upsLon;
        }
        
        if(debug) print("Starting ", (flip_flop) ? "Inbound" : "Outbound", " Leg .......");			
        oval_leg = true;
        resetTimer();
    }
    else {
        if(debug) print( "Waiting on turn to Complete .... Secs = ", SECS, "   Bank Angle = ", getprop("orientation/roll-deg"), "   Heading = " , round(getprop(gps~"indicated-track-magnetic-deg"),1), " <> Target = " , round(dir,1));
    } 
}


var fly_to_navaid = func () {

    var na = {};
    var heading = 0;
    var fly2na = {};
    var lat1 = getprop("position/latitude-deg");
    var lon1 = getprop("position/longitude-deg");
    var lat2 = getprop(htree~"latitude-deg");
    var lon2 = getprop(htree~"longitude-deg");
    var speed = getprop("instrumentation/airspeed-indicator/indicator-speed-kt");
    
    speed_orig = speed;
    altitude_orig = getprop(auto~"settings/counter-set-altitude-ft"); 

    heading = calc_heading(lat2, lon2);
    
    na = calc_distance(lat1, lon1, lat2, lon2, speed);

    if(getprop(afds~"inputs/AP") != true) setprop(afds~"inputs/AP", true);
    if(debug) print("engage A/P = ", getprop(afds~"inputs/AP")); 
    setprop(auto~"settings/counter-set-altitude-ft",getprop(htree~"altitude")); 
    if(debug) print("set altitude dial = ", getprop(htree~"altitude"));

    setprop(afds~"inputs/lateral-index", 2);
    if(debug) print("Set Lateral Index [2] = ", getprop(afds~"inputs/lateral-index"));
    setprop(afds~"inputs/vnav-armed", 0);
    if(debug) print("set vnav to [1] = ", getprop(afds~"inputs/vnav-armed"));
    setprop(afds~"inputs/vnav", false);
    setprop(afds~"inputs/vertical-decent", false);
    setprop(afds~"inputs/vertical-index", 0);

    if(debug) print("set vertical index [4] = ", getprop(afds~"inputs/vertical-index"));
    setprop(auto~"settings/heading-bug-deg", abs(heading));
    if(debug) print("set heading bug = ", abs(heading));

    if(getprop(afds~"inputs/at-armed") != true) setprop(afds~"inputs/at-armed",true);
    if(getprop(afds~"inputs/at-armed[1]") != true) setprop(afds~"inputs/at-armed[1]", true);
    setprop(auto~"settings/target-speed-kt",speed);
    setprop(afds~"inputs/autothrottle-index",5);
    setprop(auto~"settings/target-altiude-ft",getprop(htree~"altitude"));
    setprop(auto~"settings/actual-target-altiude-ft",getprop(htree~"altitude"));

    if(debug) print("set A/T to speed = ", na.speed, " A/T index [5] = ", getprop(afds~"inputs/autothrottle-index"));

    lnav = false;
    setprop(afds~"inputs/lnav-armed", false);
    
    if(!teardrop) {
        approach = 0;
        closure_timer = maketimer(.25, close_on_navaid);
    }
    else {
        closure_timer = maketimer(.25, close_on_navaid_TD);
        approach = 2;
    }
    closure_timer.simulatedTime = 1;
    closure_timer.start();
    
    last_speed = getprop("instrumentation/airspeed-indicator/indicator-speed-kt"); 
    buffer = 0;
    reduce_alt_change = 0;
    
    altitude_timer = maketimer(1, altitude_hold);
    altitude_timer.simulatedTime = 1;
    altitude_timer.start();

    speed_timer = maketimer(2, monitor_speed);
    speed_timer.simulatedTime = 1;
    speed_timer.start();
}

var enable_hold = func() {

    gui.popupTip("Holding Pattern ENABLED ..... "~getprop(inst~"clock/indicated-string")~" Zulu");
    print("Holding Pattern ENABLED .....",getprop(inst~"clock/indicated-string"), " Zulu");
    if (origin_timer != nil) {
        var value = call(func origin_timer.stop(), nil, var err = []);       
        origin_timer = nil;
    }
    
    turntime = 0;
    bank_angle = 15;
    dir = 0.0;
    ready = false;
    adjust = 0.0;
    current_dir = 0.0;
    at_nav = false;
    last_distance = 9999;
    lnav = false;
    vnav = false;
    tracking = false;
    angle = 0;
    last_adj = 0;
    bank = 0;
    approach = 0;
    speed_brake = false;
    hold_speed = 0;
    flaps = false;
    turn2radial = false;
    lockradial = false;
    wait_turn = false;
    bank = 0;
    target = 0;
    
    close_distance = 0;
    coords.upsLat = 0;
    coords.upsLon = 0;
    coords.upsHead = 0;
    coords.downsLat = 0;
    coords.downaLon = 0;
    coords.downsHead = 0;
    coords.upfLat = 0;
    coords.upfLon = 0;
    coords.upfHead = 0;
    coords.downfLat = 0;
    coords.downfLon = 0;
    coords.downfHead = 0;
    
    parallel = getprop(htree~"parallel");
    direct = getprop(htree~"direct");
    teardrop = getprop(htree~"teardrop");
    if(getprop(htree~"radial") < 181) { radial = getprop(htree~"radial") + 180} else {radial = getprop(htree~"radial") - 180};
    radial_TD = getprop(htree~"radial-teardrop");
    turn_pattern = getprop(htree~"pattern");
    dist_na.FL1 = getprop(htree~"dist-FL1");
    dist_na.FL2 = getprop(htree~"dist-FL2");
    dist_na.FL3 = getprop(htree~"dist-FL3");
    aoa_FL1 = getprop(htree~"aoa-FL1");
    aoa_FL2 = getprop(htree~"aoa-FL2");
    aoa_FL3 = getprop(htree~"aoa-FL3");
    alt_na.FL1 = getprop(htree~"alt-FL1");
    alt_na.FL2 = getprop(htree~"alt-FL2");
    speed_na.FL1 = getprop(htree~"speed-FL1");
    speed_na.FL2 = getprop(htree~"speed-FL2");
    speed_na.FL3 = getprop(htree~"speed-FL3");
    leg_td.FL1 = getprop(htree~"TD-leg-FL1");
    leg_td.FL2 = getprop(htree~"TD-leg-FL2");
    leg_td.FL3 = getprop(htree~"TD-leg-FL3");
    flaps_1 = getprop(htree~"flaps-1");
    debug = getprop(htree~"debug");
    altitude_prop = getprop(htree~"altitude-prop");
    
    if(debug) print("Holding Pattern is ENABLED ......");
    lat_orig = getprop("position/latitude-deg");
    lon_orig = getprop("position/longitude-deg");
    get_AFDS();
    fly_to_navaid();
}

var go_last_pos = func () {

    var na = {};
    var heading = 0;
    var lat1 = getprop("position/latitude-deg");
    var lon1 = getprop("position/longitude-deg");
    var lat2 = lat_orig;
    var lon2 = lon_orig;

    var speed = getprop("velocities/groundspeed-kt");
    heading = calc_heading(lat2, lon2);
    if(debug) print("Heading to Original point = ", heading );
    setprop(auto~"settings/heading-bug-deg", round(heading,1));

    na = calc_distance(lat1, lon1, lat2, lon2, speed);
    if(debug) print("Distance = ", na.distance, "  Time left = ", na.minutes);
    if(na.distance <= 0.5 or getprop(htree~"return-orig-pos") == false ) {
        if(debug) print("Clean up and Reset A/P .....");
        setprop(auto~"settings/counter-set-altitude-ft",altitude_orig); 
        if(debug) print("Resuming established Flight Plan");	
        origin_timer.stop();
        origin_timer = nil;
        reset_AFDS();
        setprop(auto~"route-manager/current-wp", last_WP);
        fp = flightplan();
        curremt_WP = fp.indexOfWP(wp);
        if(debug) print("Delete WP .... FP Size = ", fp.getPlanSize(), "  Current WP = ", current_WP, "    Object = ", wp.wp_name, " - ", wp.lat, " - ", wp.lon, " - ", wp.wp_role);
        fp.deleteWP(current_WP);
        wp = nil;
        wpc = nil;
        fp = nil;
    }
}

var reset_AFDS = func () {

     setprop("instrumentation/afds/ap-modes/lnav-is-pattern", "");
     setprop(auto~"settings/counter-set-altitude-ft", AFDS_altitude); 
     setprop(inp~"FD", FD);
     setprop(inp~"at-armed[0]", at1);
     setprop(inp~"at-armed[1]", at2);
     setprop(inp~"alt-knob", alt_knob);
     setprop(inp~"autothrottle-index" , autothrottle_mode);#i
     setprop(inp~"lateral-index" , lateral_mode);#i
     setprop(inp~"vertical-index" , vertical_mode);#i
     setprop(inp~"gs-armed", gs_armed);
     setprop(inp~"loc-armed", loc_armed);
     setprop(inp~"vor-armed", vor_armed);
     setprop(inp~"lnav-armed", lnav_armed);
     setprop(inp~"vnav-armed", vnav_armed);
     setprop(inp~"rollout-armed", rollout_armed);
     setprop(inp~"flare-armed", flare_armed);
     setprop(inp~"ias-mach-selected", ias_mach_selected);
     setprop(inp~"vs-fpa-selected", vs_fpa_selected);
     setprop(inp~"bank-limit-switch" , bank_switch);#i
     setprop(inp~"vnav-path-mode" , vnav_path_mode);#i
     setprop(inp~"vnav-mcp-reset", vnav_mcp_reset);
     setprop(inp~"vnav-descent", vnav_descent);
     setprop(inp~"climb-continuous", climb_continuous);
     setprop(inp~"indicated-vs-fpm" , indicated_vs_fpm);#d
     setprop(rm~"current-wp" , FMC_current_wp);#i
     setprop("instrumentation/efis/hdg-trk-selected", hdg_trk_selected);
     setprop("systems/navigation/hdgref/reference", heading_reference);


     setprop(inp~"AP", AP);
     setprop(inp~"AP-disengage", AP_disengaged);
     setprop("autopilot/locks/passive-mode", AP_passive);
     setprop("autopilot/locks/pitch-engaged", AP_pitch_engaged);
     setprop("autopilot/locks/roll-engaged", AP_roll_engaged);
     
     var value = call(func setprop(auto~"settings/target-altiude-ft",target_altitude_ft), nil, var err = []);       
     if(size(err)) setprop(auto~"settings/target-altiude-ft", 10000);
     value = call(func setprop(auto~"settings/actual-target-altiude-ft",actual_target_altitude_ft), nil, var err = []);       
     if(size(err)) setprop(auto~"settings/actual-target-altiude-ft", 10000);}

var get_AFDS = func() {

     altitude_org = getprop("position/altitude-ft");
     AFDS_altitude = getprop(auto~"settings/counter-set-altitude-ft"); 
     AFDS_direction = getprop(gps~"indicated-track-magnetic-deg");
     FD = getprop(inp~"FD");
     at1 = getprop(inp~"at-armed[0]");
     at2 = getprop(inp~"at-armed[1]");
     alt_knob = getprop(inp~"alt-knob");
     autothrottle_mode = getprop(inp~"autothrottle-index"); #i
     lateral_mode = getprop(inp~"lateral-index"); #i
     vertical_mode = getprop(inp~"vertical-index"); #i
     gs_armed = getprop(inp~"gs-armed");
     loc_armed = getprop(inp~"loc-armed");
     vor_armed = getprop(inp~"vor-armed");
     lnav_armed = getprop(inp~"lnav-armed");
     vnav_armed = getprop(inp~"vnav-armed");
     rollout_armed = getprop(inp~"rollout-armed");
     flare_armed = getprop(inp~"flare-armed");
     ias_mach_selected = getprop(inp~"ias-mach-selected");
     vs_fpa_selected = getprop(inp~"vs-fpa-selected");
     bank_switch = getprop(inp~"bank-limit-switch"); #i
     vnav_path_mode = getprop(inp~"vnav-path-mode"); #i
     vnav_mcp_reset = getprop(inp~"vnav-mcp-reset");
     vnav_descent = getprop(inp~"vnav-descent");
     climb_continuous = getprop(inp~"climb-continuous");
     indicated_vs_fpm = getprop(inp~"indicated-vs-fpm"); #d
     FMC_current_wp = getprop(rm~"current-wp"); #i
     hdg_trk_selected = getprop("instrumentation/efis/hdg-trk-selected");
     heading_reference = getprop("systems/navigation/hdgref/reference");
     bank_min = getprop(afds~"settings/bank-min");
     bank_max = getprop(afds~"settings/bank-max");

     target_altitude_ft = getprop(auto~"settings/target-altiude-ft");
     actual_target_altitude_ft = getprop(auto~"settings/actual-target-altiude-ft");

     
     AP = getprop(inp~"AP");
     AP_disengaged = getprop(inp~"AP-disengage");
     AP_passive = getprop("autopilot/locks/passive-mode");
     AP_pitch_engaged = getprop("autopilot/locks/pitch-engaged");
     AP_roll_engaged = getprop("autopilot/locks/roll-engaged");
} 

var disable_hold = func() {

    var lat1 = getprop("position/latitude-deg");
    var lon1 = getprop("position/longitude-deg");
    var lat2 = lat_orig;
    var lon2 = lon_orig;
    var na = {};
    var value = nil;
    var tim = HR~":"~((MIN < 10) ? "0" : ""~MIN)~":"~((SEC < 10) ? "0" : ""~SEC);
    
    print("Holding Pattern is DISABLED ..... ", getprop(inst~"clock/indicated-string"), " Zulu", "  Total Hold Time = ", tim);
    gui.popupTip("Holding Pattern is DISABLED ..... "~getprop(inst~"clock/indicated-string")~" Zulu"~"  Total Hold Time "~tim);
    if( pattern_timer != nil ) {
        value = call(func pattern_timer.stop(), nil, var err = []);       
        pattern_timer = nil;
    }
    if( start_pattern_timer != nil ) {
        value = call(func start_pattern_timer.stop(), nil, var err = []);       
        start_pattern_timer = nil;
    }
    if( closure_timer != nil ) {
        value = call(func closure_timer.stop(), nil, var err = []);       
        closure_timer = nil;
    }
    if(	turn30_timer != nil ) {
        value = call(func turn30_timer.stop(), nil, var err = []);       
        turn30_timer = nil;
    }
    if(altitude_timer != nil) {
        value = call(func altitude_timer.stop(), nil, var err = []);       
        altitude_timer = nil;
    }
    value = call(func endTimer(), nil, var err = []);
    
    last_vps = 0;
    hold_alt_process = false;
    reduce_alt_change = 0;
    
    if(parallel_timer != nil) {
        value = call(func parallel_timer.stop(), nil, var err = []);       
        parallel_timer = nil;
    }
    if(teardrop_timer != nil) {
        value = call(func teardrop_timer.stop(), nil, var err = []);       
        teardrop_timer = nil;
    }
    
    if(speed_timer != nil) {
        value = call(func speed_timer.stop(), nil, var err = []);       
        speed_timer = nil;
    }

    if(turn_timer != nil) {
        value = call(func turn_timer.stop(), nil, var err = []);       
        turn_timer = nil;
    }

    if(match_timer != nil) {
        value = call(func match_timer.stop(), nil, var err = []);       
        match_timer = nil;
    }

    if(speed_brake) {
        setprop("controls/flight/speedbrake",0);
        speed_brake = false;
    }

    if(flaps) setprop("controls/flight/flaps",0.0);

    na = calc_distance(lat1, lon1, lat2, lon2, speed_orig);
    if(debug) print("Distance - ", na.distance, "  return to Org Pos = ", getprop(htree~"return-orig-pos"));
    if(na.distance > 0.5 and getprop(htree~"return-orig-pos") == true) {
    if(debug) print("Return to Origin");
        wp = createWP(lat2,lon2,"LastPos");
        fp.insertWP(wp,current_WP);
        fp.current = indexOfWP(wp);
        origin_timer = maketimer(1, go_last_pos);
        origin_timer.simulatedTime = 1;
        origin_timer.start();
    }
    else {
        if(debug) print("Clean up and Reset A/P .....");
        setprop(auto~"settings/counter-set-altitude-ft",altitude_orig); 
        reset_AFDS();
        setprop(auto~"route-manager/current-wp", last_WP);
        wp = nil;
        fp = nil;
    }
    value = call(func setprop(auto~"settings/target-speed-kt",speed_orig), nil, var err = []);       

}

var input = func() {
    
    if(getprop(htree~"enable") == true) {
        fp = flightplan();
        var wpc = nil;
        wp = nil;
        aid = string.uc(getprop(htree~"navaid"));
        var value = findNavaidsByID(aid);       

        if(debug) print("Value = " , value, "  Size Value = ", size(value));
        if(size(value) != 0) {
            var navaid = findNavaidsByID(aid);
            if(size(navaid) == 0) {
                setprop(htree~"enable", false);
                gui.popupTip("ERROR No such NAVAID -- "~aid);
                die("ERROR No such NAVAID -- "~aid);
            }
            navaid = navaid[0];
            setprop(htree~"latitude-deg", navaid.lat);
            setprop(htree~"longitude-deg", navaid.lon);
            if(debug) print("ID: ", navaid.id); 
            if(debug) print("Name: ", navaid.name);
            if(debug) print("Latitude: ", navaid.lat);
            if(debug) print("Longitude: ", navaid.lon);
            if(debug) print("Elevation (AMSL): ", navaid.elevation, " m");
            if(debug) print("Type: ", navaid.type);
            if(debug) print("Frequency: ", sprintf("%.3f", navaid.frequency / 1000), " Mhz");
            if(debug) print("Range: ", navaid.range_nm, " nm");
            wp = createWP(navaid.lat,navaid.lon,aid);
        }
        else {
            var fixes = findFixesByID(aid);
            if(size(fixes) == 0) {
                setprop(htree~"enable", false);
                gui.popupTip("ERROR No such FIX -- "~aid);
                die("ERROR No such FIX -- "~aid);
            }
            setprop(htree~"latitude-deg", fixes[0].lat);
            setprop(htree~"longitude-deg", fixes[0].lon);
            wp = createWP(fixes[0].lat,fixes[0].lon,aid);
            foreach(var fix; fixes){
                if(debug) print(fix.id, " - lat: ", fix.lat, " | lon: ", fix.lon); 
            }
        }
        last_WP = getprop(auto~"route-manager/current-wp");
        current_WP = last_WP;
        wpc = fp.currentWP();
        if(debug) print("Cur WP ..... FP Size = ", fp.getPlanSize(), "  Current WP = ", current_WP, "    Object = ", wpc.wp_name, " - ", wpc.lat, " - ", wpc.lon, " - ", wpc.wp_role);
        fp.insertWP(wp,current_WP);
        fp.current = current_WP;
        if(debug) print("New WP .... FP Size = ", fp.getPlanSize(), "  Current WP = ", current_WP, "    Object = ", wp.wp_name, " - ", wp.lat, " - ", wp.lon, " - ", wp.wp_role);
        enable_hold();
    }
    else {
        fp = flightplan();
        current_WP = fp.indexOfWP(wp);
        wpc = fp.getWP(current_WP);
        if(debug) print("Delete WP .... FP Size = ", fp.getPlanSize(), "  Current WP = ", current_WP, "    Object = ", wpc.wp_name, " - ", wpc.lat, " - ", wpc.lon, " - ", wpc.wp_role);
        fp.deleteWP(current_WP);
        disable_hold();
        if(getprop(htree~"return-orig-pos") == false) {
            setprop(auto~"route-manager/current-wp", last_WP);
            wp = nil;
            fp = nil;
        }
    }
}
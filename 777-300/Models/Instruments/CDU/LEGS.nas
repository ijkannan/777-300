#BY FGPRC, WIP

points = getprop("/autopilot/route-manager/route/num");

var crtPageNum = getprop("/autopilot/route-manager/route/crtPageNum");

var pageNum = 1;

setlistener("/autopilot/route-manager/route/num", func {
    pageNum = int(1 + ((getprop("/autopilot/route-manager/route/num") + 1) / 5));
});

setlistener("/autopilot/route-manager/current-wp", func {
    var n = getprop("/autopilot/route-manager/current-wp");

    crtPageNum = n < 0 ? 1 : int(n / 5) + 1;
    setprop("/autopilot/route-manager/route/crtPageNum", crtPageNum)
});

var turnLEGS = func(move)
{
    if(move == 1 and crtPageNum < pageNum){crtPageNum = crtPageNum + 1;}
    else if(move == 0 and crtPageNum != 1){crtPageNum = crtPageNum - 1;}

    setprop("/autopilot/route-manager/route/crtPageNum",crtPageNum);
}
#Display phase

var getLEGS = {	
    angle2Point : func(line) 
        {
            if(getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) *5)+line)~"]/leg-bearing-true-deg") != nil)
            {
                return sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) *5)+line)~"]/leg-bearing-true-deg"));
                }
            else
            {return "";}
        },
    id : func(line)
        {
            if(getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) *5)+line)~"]/id") != nil)
            {
                return getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) *5)+line)~"]/id");
                }
            else
            {return "";}
        },
    distance : func(line)
        {
            if(getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) *5)+line)~"]/leg-distance-nm") != nil)
            {
                return sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) *5)+line)~"]/leg-distance-nm"))~" NM";
                }
            else
            {return "";}
        },
    altSpdLimit : func(line)
        {
            var speed_prop = "/autopilot/route-manager/route/wp["~(((crtPageNum -1) *5)+line)~"]/speed-kts";
            var alt_prop = "/autopilot/route-manager/route/wp["~(((crtPageNum -1) *5)+line)~"]/altitude-ft";
            var speed_str = "---";
            var alt_str = "-----";

            if(getprop(speed_prop) == nil and getprop(alt_prop) == nil)
            {
                return "";
            }
            else
            {
                if (getprop(alt_prop) != nil)
                {
                    var alt_ft = getprop(alt_prop);

                    alt_str = alt_ft < 0 ? alt_str : sprintf("%d", alt_ft);
                }

                if (getprop(speed_prop) != nil)
                {
                    var speed_kts = getprop(speed_prop);

                    speed_str = speed_kts < 0 ? speed_str : sprintf("%d", speed_kts);
                }

                return speed_str~"/"~alt_str;
            }
        },
};

# var pageNum = math.ceil(points / 5);
# if(pageNum == nil)
    # {
        # page = "";
    # }
    # else
    # {page = crtPageNum ~ "/" ~ pageNum;}

    #if (actName != nil)
    #{
    #	line1lt = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) /5)+1)~"]/leg-bearing-true-deg"));
    #	line1l = getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) /5)+1)~"]/id");
    #	line2ct = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) /5)+1)~"]/leg-distance-nm"))~" NM";
    #	line1r = sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) /5)+1)~"]/altitude-ft"));
    #	if (getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) /5)+1)~"]/speed-kts") != nil)
    #	{
    #		line1r = getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) /5)+1)~"]/speed-kts")~"/"~sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp["~(((crtPageNum -1) /5)+1)~"]/altitude-ft"));
    #	}
    #}
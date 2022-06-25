# Copyright (C) 2022 ValKmjolnir (Haokun Li), Sidi Liang
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

####    Boeing 777 Air Systems    ####
#### Based on the logic from original code by Hyde Yamakawa ####

var AirSystems = {
	new: func(pneumaticProp){
		var m = {parents: [AirSystems]};
		m.equip_cool_sw = props.globals.initNode("controls/air/equip-cool-switch", 1, "BOOL");
		m.air = props.globals.initNode(pneumaticProp);
		m.pneumaticNode = props.getNode("controls/air", 1);
		m.lPackSwitch = m.pneumaticNode.getNode("lpack-switch", 1);
		m.rPackSwitch = m.pneumaticNode.getNode("rpack-switch", 1);
		m.lTrimSwitch = m.pneumaticNode.getNode("ltrim-switch", 1);
		m.rTrimSwitch = m.pneumaticNode.getNode("rtrim-switch", 1);
		m.ofvfwdSwitch = m.pneumaticNode.getNode("ofvfwd-switch", 1);
		m.ofvaftSwitch = m.pneumaticNode.getNode("ofvaft-switch", 1);
		m.lIsolationSwitch = m.pneumaticNode.getNode("islationl-switch", 1);
		m.cIsolationSwitch = m.pneumaticNode.getNode("islationc-switch", 1);
		m.rIsolationSwitch = m.pneumaticNode.getNode("islationr-switch", 1);
		m.bleedApuSwitch = m.pneumaticNode.getNode("bleedapu-switch", 1);
		m.bleedLEngSwitch = m.pneumaticNode.getNode("bleedengl-switch", 1);
		m.bleedREngSwitch = m.pneumaticNode.getNode("bleedengr-switch", 1);
		m.lEngineNode = props.getNode("engines/engine/run");
		m.rEngineNode = props.getNode("engines/engine[1]/run");
		return m;
	},
	update: func{
		var cond = (cpt_flt_inst.getValue() < 24);
		var isLEngineRunning = me.lEngineNode.getValue();
		var isREngineRunning = me.rEngineNode.getValue();
		var hash = {
			"controls/air/equip-cool": cond or me.equip_cool_sw.getValue(),
			"controls/air/lpack": cond or (isLEngineRunning and me.lPackSwitch.getValue()),
			"controls/air/rpack": cond or (isREngineRunning and me.rPackSwitch.getValue()),
			"controls/air/ltrim": cond or me.lTrimSwitch.getValue(),
			"controls/air/rtrim": cond or me.rTrimSwitch.getValue(),
			"controls/air/ofvfwd": cond or me.ofvfwdSwitch.getValue(),
			"controls/air/ofvaft": cond or me.ofvaftSwitch.getValue(),
			"controls/air/islationl": cond or me.lIsolationSwitch.getValue(),
			"controls/air/islationc": cond or me.cIsolationSwitch.getValue(),
			"controls/air/islationr": cond or me.rIsolationSwitch.getValue(),
			"controls/air/bleedapu": cond or me.bleedApuSwitch.getValue(),
			"controls/air/bleedengl": cond or (isLEngineRunning and me.bleedLEngSwitch.getValue()),
			"controls/air/bleedengr": cond or (isREngineRunning and me.bleedREngSwitch.getValue())
		};
		foreach(var key; keys(hash)){
			setprop(key, hash[key] ? 1 : 0);
		}
	}
};

var airSystems= AirSystems.new("systems/air");

var airSystemsTimer = maketimer(0.25, func airSystems.update());
airSystemsTimer.simulatedTime = 1; #//Use simulated time


################ Initialization #####################
setlistener("sim/signals/fdm-initialized", func {
	airSystems.equip_cool_sw.setValue(1);
	setprop("controls/air/gasper-switch", 1);
	setprop("controls/air/recircup-switch", 1);
	setprop("controls/air/recirclo-switch", 1);
	setprop("controls/air/fltdeck_temp", 0.5);
	setprop("controls/air/cabin_temp", 0.5);
	setprop("controls/air/lpack-switch", 1);
	setprop("controls/air/rpack-switch", 1);
	setprop("controls/air/ltrim-switch", 1);
	setprop("controls/air/rtrim-switch", 1);
	setprop("controls/air/ofvfwd-switch", 1);
	setprop("controls/air/ofvaft-switch", 1);
	setprop("controls/air/islationl-switch", 1);
	setprop("controls/air/islationc-switch", 1);
	setprop("controls/air/islationr-switch", 1);
	setprop("controls/air/bleedapu-switch", 1);
	setprop("controls/air/bleedengl-switch", 1);
	setprop("controls/air/bleedengr-switch", 1);
	setprop("controls/anti-ice/wing-antiice-knob", 1);
	setprop("controls/anti-ice/engin/antiice-knob", 1);
	setprop("controls/anti-ice/engin[1]/antiice-knob", 1);
    settimer(func{airSystemsTimer.start();}, 5);
});

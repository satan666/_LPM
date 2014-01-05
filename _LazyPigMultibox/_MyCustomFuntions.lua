--EXPERT MODE MACROS--
--These are the functions I use personally to control my characters if you want tou use it by yourself remember to change names in the functions parameters(always 1st parameter in every function)




function LPM_EXPERT_AOE() -- my bind is 1 key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	--Ally Team - warlocks hellfire
	LazyPigMultibox_SCS("Nightx", "Hellfire", 1, 975); --cast hellfire on selected warlock
	LazyPigMultibox_SCS("Solekj", "Hellfire", 1, 975);
	LazyPigMultibox_SCS("Maloves", "Hellfire", 1, 975); 


end


function LPM_EXPERT_3() -- my bind is R key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
		--Ally Team
	LazyPigMultibox_SPA( "Nightx", 4); --pet attack
	LazyPigMultibox_SFL( "Nightx", "LazyPigMultibox_SmartSS()", 0.5);  --cast ss on rezer if no enemy target and ooc
	LazyPigMultibox_SFL( "Nightf", "LazyPigMultibox_HammerOnAggro()", 0.5);  --stuns if enemy targeting player - good for pulling with warlock pet
	
end

function LPM_EXPERT_2() -- my bind is E key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	
	--Ally Team
	LazyPigMultibox_SPA( "Solekj", 3); --pet attack
	LazyPigMultibox_SFL( "Solekj", "LazyPigMultibox_SmartSS()", 0.5);  --cast ss on rezer if no enemy target and ooc
	LazyPigMultibox_SFL( "Nighte", "LazyPigMultibox_HammerOnAggro()", 0.5);  --stuns if enemy targeting player - good for pulling with warlock pet
end

function LPM_EXPERT_1() -- my bind is Q key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	
	--Ally Team
	LazyPigMultibox_SPA( "Maloves", 2); --pet attack 
	LazyPigMultibox_SFL( "Maloves", "LazyPigMultibox_SmartSS()", 0.5);  --cast ss on rezer if no enemy target and ooc
	LazyPigMultibox_SFL( "Shadlo", "LazyPigMultibox_HammerOnAggro()", 0.5);  --stuns if enemy targeting player - good for pulling with warlock pet
end



--[[---===  Horde Alternative Part   ====----



--EXPERT MODE MACROS--
--These are the functions I use personally to control my characters if you want tou use it by yourself remember to change names in the functions parameters(always 1st parameter in every function)


function LPM_EXPERT_AOE() -- my bind is R key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	--Horde Team - warlocks hellfire;
	LazyPigMultibox_SCS("Nogcsh", "Hellfire", 1, 645, true); --cast hellfire on selected warlock if modifier is pressed
	LazyPigMultibox_SCS("Nogfsh", "Hellfire", 1, 645, true);
	LazyPigMultibox_SCS("Nogash", "Hellfire", 1, 645, true); 
	
	--Horde Team - shamans buff(we have to cast totmes manually - not supported by SmartBuff)
	LazyPigMultibox_SFL( "Buttlink", "LazyPigMultibox_ShamanTotems(\"Mana Spring Totem\", \"Strength of Earth Totem\")", 2); --cast totems on selected shaman
	LazyPigMultibox_SFL( "Zvz", "LazyPigMultibox_ShamanTotems(\"Stoneskin Totem\", \"Healing Stream Totem\")", 2);  
	
end


function LPM_EXPERT_3() -- my bind is R key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
end

function LPM_EXPERT_2() -- my bind is E key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end

	--Horde Team
	LazyPigMultibox_SPA( "Nogfsh", 2); --pet attack
	LazyPigMultibox_SFL( "Nogfsh", "LazyPigMultibox_SmartSS()", 0.5, true);  --cast ss on rezer if modifier pressed
	LazyPigMultibox_SFL( "Nogfsh", "LazyPigMultibox_CoilOnAggro()", 0.5); --cast death coil if enemy targeting player - good for pulling with warlock pet
	
	
end

function LPM_EXPERT_1() -- my bind is Q key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	--Horde Team
	LazyPigMultibox_SPA( "Nogcsh", 3); --pet attack
	LazyPigMultibox_SFL( "Nogcsh", "LazyPigMultibox_SmartSS()", 0.5, true);  --cast ss on rezer if modifier pressed
	LazyPigMultibox_SFL( "Nogcsh", "LazyPigMultibox_CoilOnAggro()", 0.5); --cast death coil if enemy targeting player - good for pulling with warlock pet


end


--]]

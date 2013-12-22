--EXPERT MODE MACROS--
--These are the functions I use personally to control my characters if you want tou use it by yourself remember to change names in the functions parameters(always 1st parameter in every function)

function LPM_EXPERT_3() -- my bind is R key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	--Ally Team - warlocks hellfire
	LazyPigMultibox_SCS("Nightx", "Hellfire", 1, 645, true); --cast hellfire on selected warlock when modifier is pressed
	LazyPigMultibox_SCS("Nighta", "Hellfire", 1, 645, true);
	LazyPigMultibox_SCS("Nightb", "Hellfire", 1, 645, true); 
	

	
	
	--Horde Team - warlocks hellfire;
	LazyPigMultibox_SCS("Nogcsh", "Hellfire", 1, 645, true); --cast hellfire on selected warlock
	LazyPigMultibox_SCS("Nogfsh", "Hellfire", 1, 645, true);
	LazyPigMultibox_SCS("Nogash", "Hellfire", 1, 645, true); 
	
	--Horde Team - shamans buff(we have to cast totmes manually - not supported by SmartBuff)
	LazyPigMultibox_SFL( "Buttlink", "LazyPigMultibox_ShamanTotems(\"Mana Spring Totem\", \"Strength of Earth Totem\")", 2); --cast totems on selected shaman
	LazyPigMultibox_SFL( "Zvz", "LazyPigMultibox_ShamanTotems(\"Stoneskin Totem\", \"Healing Stream Totem\")", 2);  

end

function LPM_EXPERT_2() -- my bind is E key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	
	--Ally Team
	LazyPigMultibox_SPA( "Nightb", 2); --pet attack
	LazyPigMultibox_SFL( "Nightb", "LazyPigMultibox_SmartSS()", 0.5, true);  --cast ss on rezer
	LazyPigMultibox_SFL( "Nightc", "LazyPigMultibox_HammerOnAggro()", 0.5);  --stuns if enemy targeting player - good for pulling with warlock pet
	
	
	
	--Horde Team
	LazyPigMultibox_SPA( "Nogfsh", 2); --pet attack
	LazyPigMultibox_SFL( "Nogfsh", "LazyPigMultibox_SmartSS()", 0.5, true);  --cast ss on rezer
	LazyPigMultibox_SFL( "Nogfsh", "LazyPigMultibox_CoilOnAggro()", 0.5); --cast death coil if enemy targeting player - good for pulling with warlock pet
	
	
end

function LPM_EXPERT_1() -- my bind is Q key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	
	--Ally Team
	LazyPigMultibox_SPA( "Nighta", 3); --pet attack 
	LazyPigMultibox_SFL( "Nighta", "LazyPigMultibox_SmartSS()", 0.5, true);  --cast ss on rezer
	LazyPigMultibox_SFL( "Nightd", "LazyPigMultibox_HammerOnAggro()", 0.5);  --stuns if enemy targeting player - good for pulling with warlock pet

	
	
	--Horde Team
	LazyPigMultibox_SPA( "Nogcsh", 3); --pet attack
	LazyPigMultibox_SFL( "Nogcsh", "LazyPigMultibox_SmartSS()", 0.5, true);  --cast ss on rezer
	LazyPigMultibox_SFL( "Nogcsh", "LazyPigMultibox_CoilOnAggro()", 0.5); --cast death coil if enemy targeting player - good for pulling with warlock pet


end


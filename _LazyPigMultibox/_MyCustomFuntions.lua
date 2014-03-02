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
	LazyPigMultibox_SCS( "Nightx", "Death Coil", 1, 565, true); --cast coil if modifier is pressed
	LazyPigMultibox_SFL( "Shadlo", "LazyPigMultibox_HammerOnAggro()", 0.5);  --stuns if enemy targeting player - good for pulling with warlock pet

	
end

function LPM_EXPERT_2() -- my bind is E key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	
	--Ally Team
	LazyPigMultibox_SPA( "Maloves", 3); --pet attack
	LazyPigMultibox_SFL( "Maloves", "LazyPigMultibox_SmartSS()", 0.5);  --cast ss on rezer if no enemy target and ooc
	LazyPigMultibox_SCS( "Maloves", "Death Coil", 1, 565, true); --cast coil if modifier is pressed
	LazyPigMultibox_SFL( "Schi", "LazyPigMultibox_HammerOnAggro()", 0.5);  --stuns if enemy targeting player - good for pulling with warlock pet
end

function LPM_EXPERT_1() -- my bind is Q key
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Message("Only Group Leader Can Use it");
		return
	end
	
	
	--Ally Team
	LazyPigMultibox_SPA( "Solekj", 2); --pet attack 
	LazyPigMultibox_SFL( "Solekj", "LazyPigMultibox_SmartSS()", 0.5);  --cast ss on rezer if no enemy target and ooc
	LazyPigMultibox_SCS( "Solekj", "Death Coil", 1, 565, true); --cast coil if modifier is pressed
	LazyPigMultibox_SFL( "Shadlo", "LazyPigMultibox_HammerOnAggro()", 0.5);  --stuns if enemy targeting player - good for pulling with warlock pet
end



--[[---===  Shamans Totem    ====----



	LazyPigMultibox_SFL( "Character1", "LazyPigMultibox_ShamanTotems(\"Mana Spring Totem\", \"Strength of Earth Totem\")", 2); --cast totems on selected shaman
	LazyPigMultibox_SFL( "Character2", "LazyPigMultibox_ShamanTotems(\"Stoneskin Totem\", \"Healing Stream Totem\")", 2); 


--]]

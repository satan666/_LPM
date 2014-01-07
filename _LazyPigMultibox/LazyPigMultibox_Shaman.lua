local totem1_timer = 0
local totem2_timer = 0
local totem3_timer = 0

function LazyPigMultibox_Shaman(dps, dps_pet, heal, rez, buff)
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()

	if locked  then
		return true
	end

	if Zorlen_checkBuffByName("Mana Spring", "player") or Zorlen_checkBuffByName("Mana Tide", "player") or not Zorlen_checkCooldownByName("Mana Tide Totem") then
		Zorlen_SetTimer(1, "Tide_Idle")
	end
	
	if rez then
		if LazyPigMultibox_Rez() then
			return
		end
	end
	
	if heal then
		if not Zorlen_checkBuffByName("Nature's Swiftness", "player") then
			if Zorlen_ManaPercent("player") < 60 and Zorlen_IsSpellKnown("Mana Tide Totem") and not Zorlen_IsTimer("Tide_Idle") and UnitAffectingCombat("player") and Zorlen_GiveContainerItemCountByName("Water Totem") > 0 and Zorlen_castSpellByName("Mana Tide Totem") then
				LazyPigMultibox_Annouce("lpm_slaveannouce","Mana Tide")
				return
			elseif (Zorlen_ManaPercent("player") < 40 and not dps) and UnitAffectingCombat("player") and Zorlen_IsSpellKnown("Nature's Swiftness") and Zorlen_castSpellByName("Nature's Swiftness") then
				LazyPigMultibox_Annouce("lpm_slaveannouce","Nature's Swiftness")
				return
			else
				QuickHeal()
			end	
		end
	end

	
	if dps then
		if (Zorlen_ManaPercent("player") > 30  or not heal) and Zorlen_HealthPercent("target") > 30 and Zorlen_HealthPercent("target") < 75 and Zorlen_IsSpellKnown("Nature's Swiftness") and Zorlen_checkCooldownByName("Nature's Swiftness") and Zorlen_castSpellByName("Nature's Swiftness") then
			return
			
		elseif UnitExists("targettarget") and Zorlen_checkBuffByName("Nature's Swiftness", "player") and Zorlen_castSpellByName("Chain Lightning") then
			LazyPigMultibox_Annouce("lpm_slaveannouce", "Chain Lightning")
			return
			
		elseif (Zorlen_HealthPercent("target") < 30 or not heal) and (Zorlen_castSpellByName("Earth Shock") or Zorlen_castSpellByName("Flame Shock")) then
			return
				
		elseif not heal or heal and Zorlen_ManaPercent("player") > 30 then
			if Zorlen_castSpellByName("Lightning Bolt") then
				return
			end
		end	
	end
	
	if buff then
		LazyPigMultibox_UnitBuff();
	end
end


-- true if not casting spell
function LazyPigMultibox_ShamanTotems(name1, name2, name3)
	local cast_complete = nil
	local time = GetTime()
	
	function stopcast()
		if Zorlen_isCasting() or Zorlen_isChanneling() then
			SpellStopCasting()
		end
	end

	local m1 = name1 and name1 ~= "" and not Zorlen_IsSpellKnown(name1)
	local m2 = name2 and name2 ~= "" and not Zorlen_IsSpellKnown(name2)
	local m3 = name3 and name3 ~= "" and not Zorlen_IsSpellKnown(name3)
	
	if m1 then
		LazyPigMultibox_Annouce("lpm_slaveannouce", "Invalid Spell - "..name1)
	elseif m2 then
		LazyPigMultibox_Annouce("lpm_slaveannouce", "Invalid Spell - "..name2)
	elseif m3 then
		LazyPigMultibox_Annouce("lpm_slaveannouce", "Invalid Spell - "..name3)
	end
	
	
	local t1 = name1 and Zorlen_checkBuffByName(string.gsub(name1," Totem",""), "player")
	local t2 = name2 and Zorlen_checkBuffByName(string.gsub(name2," Totem",""), "player")
	local t3 = name3 and Zorlen_checkBuffByName(string.gsub(name3," Totem",""), "player")
		
	if totem1_timer < time and name1 and not t1 then
		stopcast()
		--DEFAULT_CHAT_FRAME:AddMessage("xx1"..name1)
		if Zorlen_castSpellByName(name1) then	
			totem1_timer = time + 0.5
			return cast_complete
		end	
	elseif totem2_timer < time and name2 and not t2 and Zorlen_castSpellByName(name2) then
		stopcast()
		--DEFAULT_CHAT_FRAME:AddMessage("xx2"..name2)
		if Zorlen_castSpellByName(name2) then	
			totem2_timer = time + 0.5
			return cast_complete
		end	
	elseif totem3_timer < time and name3 and not t3 and Zorlen_castSpellByName(name3) then
		stopcast()
		--DEFAULT_CHAT_FRAME:AddMessage("xx3"..name3)
		if Zorlen_castSpellByName(name3) then	
			totem3_timer = time + 0.5
			return cast_complete
		end	
	end
	return not cast_complete
end




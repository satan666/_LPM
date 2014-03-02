local lpm_pet = "Voidwalker"
local lpm_shard_bag = nil



function LazyPigMultibox_Warlock(dps, dps_pet, heal, rez, buff)
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()
	local manapercent = UnitMana("player") / UnitManaMax("player")
	local healthpercent = UnitHealth("player") / UnitHealthMax("player")
	local player_affected = UnitAffectingCombat("player")
	local unique_curse = nil
	
	if LPMULTIBOX.UNIQUE_SPELL and Zorlen_IsSpellKnown("Curse of Shadow") then
		unique_curse = true
	end
	
	if dps_pet then	
		LazyPigMultibox_WarlockPet(lpm_pet);
	end	
	
	if dps_pet then
		LazyPigMultibox_PetAttack();
		Warlock_PetSuffering();	
	end
	
	if UnitAffectingCombat("player") and Zorlen_HealthPercent("player") < 15 and LazyPigMultibox_IsPetSpellKnown("Sacrifice") and not Zorlen_checkBuffByName("Sacrifice", "player") and not Zorlen_checkBuffByName("Blessing of Protection", "player") then
		zSacrifice();
		LazyPigMultibox_Annouce("lpm_slaveannouce","Sacrifice");
	end
	
	if locked then
		return true
	end

	if dps then
		if LazyPigMultibox_WarlockDPS(unique_curse) then
			return
		end	
	end
	
	if Zorlen_ManaPercent("player") <= 70 and Zorlen_HealthPercent("player") > 75 and castLifeTap() then
		return
	end	
	
	if buff then
		LazyPigMultibox_UnitBuff();
		--LazyPigMultibox_WarlockBuff();
	end
end

function LazyPigMultibox_WarlockBuff()
	if LPMULTIBOX.SCRIPT_BUFF then	
		local leader = LazyPigMultibox_ReturnLeaderUnit()
		if UnitExists(leader) and not UnitIsDead(leader) and CheckInteractDistance(leader, 4) and Zorlen_IsSpellKnown("Detect Greater Invisibility") and not Zorlen_checkBuffByName("Detect Greater Invisibility", leader) then
			TargetUnit(leader);
			return Zorlen_castSpellByName("Detect Greater Invisibility");
		else
			--
		end
	end	
	return
end

function LazyPigMultibox_WarlockPet(pet)
	function SummonMinion()
		local check = Zorlen_IsSpellKnown("Summon "..pet) and (pet == "Imp" or Zorlen_GiveSoulShardCount() > 0) 
		if check then
			if Zorlen_castSpellByName("Fel Domination") then 
				return 
			elseif (Zorlen_checkBuffByName("Shadow Trance", "player") or not (Zorlen_isEnemy("target") and UnitExists("targettarget") and UnitIsPlayer("targettarget") and UnitIsFriend("targettarget","player"))) and Zorlen_castSpellByName("Summon "..pet) then
				return
			end
		end	
	end
	
	if Zorlen_IsTimer("LockPetSummon") then
		return
	end
	
	if UnitHealth("pet") > 0 then
		if not LazyPigMultibox_IsPetSpellOnActionBar("PET_ACTION_ATTACK") then
			Zorlen_SetTimer(2, "LockPetSummon");
			SummonMinion();
			return
		elseif Zorlen_IsSpellKnown("Soul Link") and not Zorlen_checkBuffByName("Soul Link", "player") and Zorlen_castSpellByName("Soul Link") then
			return
		end	
	else
		Zorlen_SetTimer(2, "LockPetSummon");
		SummonMinion();
		return
	end
end

function Warlock_PetSuffering()
	if UnitAffectingCombat("pet") and UnitExists("pettarget") and Zorlen_isEnemy("target") and UnitAffectingCombat("target") and UnitExists("targettarget") and UnitIsPlayer("targettarget") and UnitIsFriend("targettarget","player") then
		if not Zorlen_IsTimer("LazyPigMultiboxSuffering") and zSuffering() then
			Zorlen_SetTimer(1, "LazyPigMultiboxSuffering")
			LazyPigMultibox_Annouce("lpm_slaveannouce","Suffering")
		end
	end
end

function LazyPigMultibox_WarlockFinisher()
	if not UnitAffectingCombat("player") or not UnitExists("target") then
		return
	end
	
	local player_hp_percent = (UnitHealth("player") / UnitHealthMax("player")) * 100
	
	local shard_maxcount = LazyPigMultibox_SetShardBagSize()
	local shard_count = Zorlen_GiveSoulShardCount()
	local enemy_player = Zorlen_isEnemyPlayer()
	local hard_mob = (UnitClassification("target") == "elite") or (UnitClassification("target") == "rareelite") or (UnitClassification("target") == "worldboss")
	local health_max = UnitHealthMax("target")
	local healthfraction = UnitHealth("target") / health_max 
	
	if player_hp_percent > 50 then	
		if Zorlen_IsSpellKnown("Shadowburn") and (enemy_player and (healthfraction < 0.6) and (shard_count >= 5) or hard_mob and (healthfraction < 0.1) and (shard_count >= 10)) then --
			if(Zorlen_checkCooldownByName("Shadowburn") and LazyPigMultibox_IsSpellInRangeAndActionBar("Shadowburn")) then	
				castShadowburn(nil, 1, nil)
				if(not Zorlen_checkCooldownByName("Shadowburn")) then
					--SlaveAnnouce("slave_msg", "Shadowburn !!!", GetUnitName("player"))
				end
			end	
			return
		elseif not Zorlen_isChanneling("Drain Soul") and not Zorlen_isMoving() and (shard_count < shard_maxcount) and (healthfraction <= 0.25 and hard_mob and health_max < 4*UnitHealthMax("player") or healthfraction <= 0.35 and not hard_mob or healthfraction <= 0.50 and health_max < UnitHealthMax("player") or 3*health_max < UnitHealthMax("player")) and Zorlen_GivesXP() and not isShadowburn() and not Zorlen_checkDebuffByName("Drain Soul", "target") and not Zorlen_checkBuffByName("Soul Siphon", "player") and castDrainSoul() then
			return
		end
	end	
end

function LazyPigMultibox_WarlockDPS(curse)

			local player_mana_percent = (UnitMana("player") / UnitManaMax("player")) * 100
			local player_hp_percent = (UnitHealth("player") / UnitHealthMax("player")) * 100

			--if Zorlen_isEnemy() then	--or UnitAffectingCombat("target")
				local hard_mob = (UnitClassification("target") == "elite") or (UnitClassification("target") == "rareelite")	or (UnitClassification("target") == "worldboss")	
				local dot_unit = hard_mob or player_mana_percent <= 100 or UnitIsPlayer("target")
				local drainok = Zorlen_IsSpellKnown("Drain Life") and LazyPigMultibox_IsSpellInRangeAndActionBar("Drain Life")
				
				LazyPigMultibox_WarlockFinisher();
				
				if player_mana_percent <= 25 and player_hp_percent >= 65 and castLifeTap() then
					return true
				elseif Zorlen_checkBuffByName("Shadow Trance", "player") and castShadowBolt() then
					return true	
				elseif not isCorruption() and Zorlen_castSpellByName("Corruption") then
					return true 	
				elseif player_mana_percent > 25 and (player_hp_percent > 60 or not drainok) then
					if(dot_unit or moving and UnitAffectingCombat("target")) then
						if curse and castCurseOfShadow() then
							return true
						elseif not curse and (UnitHealthMax("target") > 2*UnitHealthMax("player") or Zorlen_isEnemyPlayer("target")) and castAmplifyCurse() then
							return true
						elseif not curse and castCurseOfAgony() then
							return true
						elseif dot_unit and castSiphonLife() then
							return true
						end	
					end
					
					if not Zorlen_isMoving() and (castImmolate() or castShadowBolt()) then
						--
					end

				elseif not Zorlen_isMoving() and not Zorlen_IsTimer("DLOCK") and drainok and castDrainLife() then 
					Zorlen_SetTimer(2, "DLOCK")
					return				
				elseif not Zorlen_isMoving() and castLifeTap() then 
					return	
				end	

			--end

end

function LazyPigMultibox_SetShardBagSize()
	if not lpm_shard_bag then	
		local ShardBagSize = 0
		if NUM_BAG_FRAMES and NUM_BAG_FRAMES > 0 then
			local SoulBagitemType = LOCALIZATION_ZORLEN["Soul Bag"]
			local BagitemType = LOCALIZATION_ZORLEN.Bag
			for bag=1,NUM_BAG_FRAMES do
				local bagslots = GetContainerNumSlots(bag)
				if bagslots and bagslots > 0 then
					local itemType = Zorlen_GetItemSubType(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)))
					if itemType == SoulBagitemType then
						ShardBagSize = ShardBagSize + bagslots

					end
				end
			end
		end
		if ShardBagSize < 10 then
			ShardBagSize = 10
		end
		lpm_shard_bag = ShardBagSize
	end
	return lpm_shard_bag
end

function LazyPigMultibox_CoilOnAggro()
	if Zorlen_isEnemy("target") and UnitExists("targettarget") and UnitIsFriend("targettarget", "player") and UnitIsPlayer("targettarget") and CheckInteractDistance("target", 1) and Zorlen_checkCooldownByName("Death Coil") and (SpellStopCasting() or 1) and Zorlen_castSpellByName("Death Coil") then
		LazyPigMultibox_Annouce("lpm_slaveannouce","Death Coil")
		return true
	end	
	return false
end

function LazyPigMultibox_Summon()
	local InRaid = UnitInRaid("player")
	local PLAYER = "player"
	local group = nil
	local NumMembers = nil
	local counter = nil
	local u = nil
		
	if InRaid then
		NumMembers = GetNumRaidMembers()
		counter = 1
		group = "raid"
	else
		NumMembers = GetNumPartyMembers()
		counter = 0
		group = "party"
	end
		
	if IsAltKeyDown() and UnitHealth("target") > 0 and UnitIsConnected("target") then
		Zorlen_castSpellByName("Ritual of Summoning")
		LazyPigMultibox_Annouce("lpm_slaveannouce", "Summoning - Target: "..GetUnitName("target").." - Shards: "..Zorlen_GiveContainerItemCountByName("Soul Shard"))
		return
	else	
		while counter <= NumMembers do
			if counter == 0 then
				u = PLAYER
			else
				u = group..""..counter
			end
			
			if UnitExists(u) and not CheckInteractDistance(u, 1) and not UnitIsUnit("player", u) and UnitHealth(u) > 0  and UnitIsConnected(u) then
				TargetUnit(u)
				Zorlen_castSpellByName("Ritual of Summoning")
				LazyPigMultibox_Annouce("lpm_slaveannouce", "Summoning - Group: "..GetUnitName("target").." - Shards: "..Zorlen_GiveContainerItemCountByName("Soul Shard"))
				return
			end
			counter = counter + 1
		end
	end	
	LazyPigMultibox_Annouce("lpm_slaveannouce", "Noone to Summon - Shards: "..Zorlen_GiveContainerItemCountByName("Soul Shard"))
end

function LazyPigMultibox_SmartSS()
		if UnitAffectingCombat("player") or Zorlen_isEnemy("target") then
			return
		end	
		
		local ss_spell = nil
		local ss_item = nil
		
		if Zorlen_IsSpellKnown("Create Soulstone (Major)") then
			ss_spell = "Create Soulstone (Major)"
			ss_item = "Major Soulstone"
		elseif Zorlen_IsSpellKnown("Create Soulstone (Greater)") then
			ss_spell = "Create Soulstone (Greater)"
			ss_item = "Greater Soulstone"
		elseif Zorlen_IsSpellKnown("Create Soulstone") then
			ss_spell = "Create Soulstone"
			ss_item = "Soulstone"
		elseif Zorlen_IsSpellKnown("Create Soulstone (Lesser)") then
			ss_spell = "Create Soulstone (Lesser)"
			ss_item = "Lesser Soulstone"
		elseif Zorlen_IsSpellKnown("Create Soulstone (Minor)") then
			ss_spell = "Create Soulstone (Minor)"
			ss_item = "Minor Soulstone"	
		end
		
		if ss_spell then
			if Zorlen_isCasting() or Zorlen_isChanneling() then 
				return
			end
			
			local InRaid = UnitInRaid("player")
			local PLAYER = "player"
			local group = nil
			local NumMembers = nil
			local counter = nil
			local u = nil
					
			local primary_rez_class = nil
			local master_class = nil
				
			if InRaid then
				NumMembers = GetNumRaidMembers()
				counter = 1
				group = "raid"
			else
				NumMembers = GetNumPartyMembers()
				counter = 0
				group = "party"
			end
						
			while counter <= NumMembers do
				if counter == 0 then
					u = PLAYER
				else
					u = group..""..counter
				end
				
				if Zorlen_checkBuffByName("Soulstone Resurrection", u) then
					LazyPigMultibox_Annouce("lpm_slaveannouce","SS Already Active - "..GetUnitName(u))
					LazyPigMultibox_Message("SS Already Active - "..GetUnitName(u))
					return
				end
				
				if UnitExists(u) and not UnitIsDeadOrGhost(u) and not UnitIsUnit(u, "player") and UnitHealth(u) > 0 and UnitIsConnected(u) and (isPaladin(u) or isPriest(u) or isShaman(u)) then
					if UnitIsPartyLeader(u) then
						master_class = u
						break
							
					elseif(isPaladin(u) or isPriest(u) or isShaman(u)) then
						primary_rez_class = u
					end
				end
				counter = counter + 1
			end
				
			master_class = master_class or primary_rez_class
			
			if Zorlen_GiveContainerItemCountByName("Soul Shard") > 5 and not Zorlen_isMoving() then
				LazyPigMultibox_Annouce("lpm_slaveannouce","SS - "..GetUnitName(master_class).." - Shards: "..Zorlen_GiveContainerItemCountByName("Soul Shard"))
				LazyPigMultibox_Message("SS - "..GetUnitName(master_class).." - Shards: "..Zorlen_GiveContainerItemCountByName("Soul Shard"))			
				
				if Zorlen_GiveContainerItemCountByName(ss_item, true) == 0 then
					Zorlen_castSpellByName(ss_spell)
				else
					TargetUnit(master_class)
					Zorlen_useContainerItemByName(ss_item)
				end
			end
		else
			LazyPigMultibox_Annouce("lpm_slaveannouce","Unknown Spell - Create Soulstone")
			LazyPigMultibox_Message("Unknown Spell - Create Soulstone")
		end	
	return
end

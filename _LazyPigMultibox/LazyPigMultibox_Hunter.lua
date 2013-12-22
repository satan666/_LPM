function LazyPigMultibox_Hunter(dps, dps_pet, heal, rez, buff)
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()
	local unit = LazyPigMultibox_ReturnLeaderUnit()
	local leader = unit and UnitIsUnit(unit, "player") or GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0
	local targetexists = UnitExists("target")
	local can_attack = targetexists and Zorlen_isEnemy("target")
	local hard_mob = targetexists and (UnitClassification("target") == "rareelite" or UnitClassification("target") == "elite" or UnitClassification("target") == "boss")
	local enemy_targeting = Zorlen_isEnemyTargetingYou()
	local lpm_pet_multiple_target = nil
	
	if dps_pet then	
		LazyPigMultibox_HunterPet(40);
	end
	
	if dps_pet then
		LazyPigMultibox_PetAttack();
	end
	
	if locked  then
		return
	end
	
	if dps then
		if can_attack then
			if CheckInteractDistance("target", 3) then --Zorlen_GiveMaxTargetRange(10, 0)	
				castRaptor();
				castAttack();
				
			else	
				if LPMULTIBOX.UNIQUE_SPELL and can_attack and not enemy_targeting then
					castMark();
				end
				
				if enemy_targeting and not isConned() or not UnitIsPlayer("target") and not UnitExists("targettarget") and Zorlen_HealthPercent("target") < 25 then
					castCon();
				end
					
				if hard_mob then
					castSerpent();
				end
					
				if Zorlen_ManaPercent("player") > 50 and UnitExists("targettarget") then
					castArcane();
				end
				castAutoShot();
			end
		end

		if buff then
			LazyPigMultibox_UnitBuff();
		end
		--if not castSting() then 
			--castShotRotation()
		--end	
	end	

end


function LazyPigMultibox_HunterPet(percent)
	if UnitHealth("pet") > 0 then
		if not LazyPigMultibox_IsPetSpellOnActionBar("PET_ACTION_ATTACK") then
			Zorlen_castSpellByName(LOCALIZATION_ZORLEN.DismissPet)
		elseif Zorlen_HealthPercent("pet") <= percent and CheckInteractDistance("pet", 2) then
			castMend("maximum")
		end	
	elseif Zorlen_PetIsDead then
		if Zorlen_isMoving() then
			return false
		end
		Zorlen_castSpellByName(LOCALIZATION_ZORLEN.RevivePet)
	else
		Zorlen_castSpellByName(LOCALIZATION_ZORLEN.CallPet)
	end
end

function LazyPigMultibox_Priest(dps, dps_pet, heal, rez, buff)
	
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()
	local shadow_form = Zorlen_checkBuffByName("Shadowform", "player")
	
	if locked  then
		return
	end
	
	if rez and not shadow_form then
		if LazyPigMultibox_Rez() then
			return
		end
	end
	
	if heal and not shadow_form then
		QuickHeal();
	end
	
	if buff then
		LazyPigMultibox_UnitBuff();
	end
	
	if not heal and not shadow_form and Zorlen_castSpellByName("Shadowform") then
		return
		
	elseif castInnerFire() then
		return
		
	elseif UnitAffectingCombat("player") and (Zorlen_isEnemyTargetingYou("target") or Zorlen_HealthPercent("player") < 50) and (LazyPig_Raid() or LazyPig_Dungeon() or Zorlen_HealthPercent("player") < 75) and (Zorlen_checkCooldownByName("Fade") or Zorlen_checkCooldownByName("Power Word: Shield") or Zorlen_checkCooldownByName("Stoneform")) then 
		if Zorlen_isCasting() then 
			SpellStopCasting();
			return 
		elseif isShootActive() then
			stopShoot();
			return
		elseif (Zorlen_castSpellByName("Fade") or castPowerWordShield() or CheckInteractDistance("target", 3) and Zorlen_castSpellByName("Stoneform")) then
			return
		end
	end	
	
	if dps then
		local plague_stack = Zorlen_GetDebuffStack("Spell_Shadow_BlackPlague", "target")
		local fly_range = LazyPigMultibox_IsSpellInRangeAndActionBar("Mind Flay")
		local hi_mana = Zorlen_ManaPercent("player") > 20
		local inner_active = Zorlen_checkBuffByName("Inner Focus", "player")
		
		if isShootActive() and (not Zorlen_IsTimer("ShadowRotation") or hi_mana or plague_stack < 5) then
			stopShoot();
			return
		end
		
		if Zorlen_HealthPercent("target") < 50 and Zorlen_checkCooldownByName("Mind Blast") and Zorlen_castSpellByName("Inner Focus") then
			return

		elseif not inner_active and not Zorlen_IsTimer("ShadowWordPain") and hi_mana and castShadowWordPain() then
			Zorlen_SetTimer(1, "ShadowWordPain");
			Zorlen_SetTimer(9, "ShadowRotation");
			return
		
		elseif not inner_active and ((UnitClassification("target") == "elite" or UnitClassification("target") == "rareelite") and UnitHealth("target") > 3*UnitHealthMax("player") or UnitClassification("target") == "worldboss") and castVampiricEmbrace() then
			return
		
		elseif (inner_active or isShadowWordPain() and Zorlen_ManaPercent("player") > 40) and castMindBlast() then
			Zorlen_SetTimer(9, "ShadowRotation");
			return
		
		elseif not Zorlen_IsTimer("ShadowWordPain") and (not Zorlen_IsTimer("ShadowRotation") or plague_stack < 5) and castShadowWordPain(1) then
			Zorlen_SetTimer(1, "ShadowWordPain");
			Zorlen_SetTimer(9, "ShadowRotation");
			return
		
		elseif fly_range and Zorlen_ManaPercent("player") > 20 and castMindFlay() then 
			Zorlen_SetTimer(9, "ShadowRotation");
			return
		
		elseif fly_range and (not Zorlen_IsTimer("ShadowRotation") or plague_stack < 5) and castMindFlay(1) then
			Zorlen_SetTimer(9, "ShadowRotation");
			return
		
		elseif not shadow_form and castSmite() then
			return
			
		elseif plague_stack == 5 and not hi_mana and Zorlen_IsTimer("ShadowRotation") then
			castShoot();
		end
	end

end
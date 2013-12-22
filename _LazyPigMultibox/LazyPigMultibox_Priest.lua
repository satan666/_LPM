function LazyPigMultibox_Priest(dps, dps_pet, heal, rez, buff)
	
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()
	local shadow_form = Zorlen_checkBuffByName("Shadowform", "player")
	
	if locked  then
		return true
	end
	
	if rez then
		if not locked and LazyPigMultibox_Rez() then
			return
		end
	end
	
	if heal then
		QuickHeal()
	end
	
	
	if not shadow_form and Zorlen_castSpellByName("Shadowform") then
		return
	elseif castInnerFire() then
		return
		
	elseif (Zorlen_HealthPercent("player") < 50 or Zorlen_HealthPercent("player") < 75 and Zorlen_isEnemyTargetingYou("target")) and castPowerWordShield() then
		return
	end	

	
	if dps then
		local plague_stack = Zorlen_GetDebuffStack("Spell_Shadow_BlackPlague", "target")
		local fly_range = LazyPigMultibox_IsSpellInRangeAndActionBar("Mind Flay")

		if isShootActive() and (not Zorlen_IsTimer("ShadowRotation") or Zorlen_ManaPercent("player") > 25 or plague_stack < 5) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shoot Stop")
			stopShoot()
			return
		end	
			
		if not Zorlen_IsTimer("ShadowWordPain") and Zorlen_ManaPercent("player") > 20 and castShadowWordPain() then
			Zorlen_SetTimer(1, "ShadowWordPain")
			Zorlen_SetTimer(9, "ShadowRotation")
			---DEFAULT_CHAT_FRAME:AddMessage("1")
			return
		elseif Zorlen_ManaPercent("player") > 40 and isShadowWordPain() and castMindBlast() then
			Zorlen_SetTimer(9, "ShadowRotation")
			---DEFAULT_CHAT_FRAME:AddMessage("2")
			return
		
		elseif not Zorlen_IsTimer("ShadowWordPain") and (not Zorlen_IsTimer("ShadowRotation") or plague_stack < 5) and castShadowWordPain(1) then
			Zorlen_SetTimer(1, "ShadowWordPain")
			Zorlen_SetTimer(9, "ShadowRotation")
			---DEFAULT_CHAT_FRAME:AddMessage("3")
			return
		
		elseif fly_range and Zorlen_ManaPercent("player") > 20 and castMindFlay() then 
			Zorlen_SetTimer(9, "ShadowRotation")
			--DEFAULT_CHAT_FRAME:AddMessage("4")
			return
		
		elseif fly_range and (not Zorlen_IsTimer("ShadowRotation") or plague_stack < 5) and castMindFlay(1) then
			Zorlen_SetTimer(9, "ShadowRotation")
			--DEFAULT_CHAT_FRAME:AddMessage("5")
			return
		
		elseif not shadow_form and castSmite() then
			return
			
		elseif Zorlen_IsTimer("ShadowRotation") and plague_stack == 5 then
			--DEFAULT_CHAT_FRAME:AddMessage("Shoot Start")
			castShoot()
		end
	end
	
	if buff then
		LazyPigMultibox_UnitBuff();
	end
end
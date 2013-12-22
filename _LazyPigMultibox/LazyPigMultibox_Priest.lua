function LazyPigMultibox_Priest(dps, dps_pet, heal, rez, buff)
	
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()
	
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
	
	if buff then
		if not Zorlen_checkBuffByName("Shadowform", "player") and Zorlen_castSpellByName("Shadowform") then
			return
		elseif castInnerFire() then
			return
		end	
	end
	
	if dps then
		local plague_stack = Zorlen_GetDebuffStack("Spell_Shadow_BlackPlague", "target")
		local fly_range = LazyPigMultibox_IsSpellInRangeAndActionBar("Mind Flay")

		if isShootActive() and (not Zorlen_IsTimer("ShadowRotation") or Zorlen_ManaPercent("player") > 20 or plague_stack < 5) then
			stopShoot()
			return
		end	
			
		if not Zorlen_IsTimer("ShadowWordPain") and Zorlen_ManaPercent("player") > 20 and castShadowWordPain() then
			Zorlen_SetTimer(1, "ShadowWordPain")
			Zorlen_SetTimer(9, "ShadowRotation")
		
		elseif Zorlen_ManaPercent("player") > 40 and isShadowWordPain() and castMindBlast() then
			Zorlen_SetTimer(9, "ShadowRotation")
			return
		
		elseif fly_range and Zorlen_ManaPercent("player") > 20 and castMindFlay() then 
			Zorlen_SetTimer(9, "ShadowRotation")
			return
		
		elseif not Zorlen_IsTimer("ShadowWordPain") and (not Zorlen_IsTimer("ShadowRotation") or plague_stack < 5) and castShadowWordPain(1) then
			Zorlen_SetTimer(1, "ShadowWordPain")
			Zorlen_SetTimer(9, "ShadowRotation")
		
		elseif fly_range and (not Zorlen_IsTimer("ShadowRotation") or plague_stack < 5) and castMindFlay(1) then
			Zorlen_SetTimer(9, "ShadowRotation")
		
		elseif castSmite() then
			return
		elseif not Zorlen_IsTimer("ShadowWordPain") and plague_stack == 5 then
			castShoot()
		end
	end
	
	if buff then
		LazyPigMultibox_UnitBuff();
	end
end
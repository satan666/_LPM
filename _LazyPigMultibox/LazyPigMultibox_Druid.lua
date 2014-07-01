function LazyPigMultibox_Druid(dps, dps_pet, heal, rez, buff)
	
	local locked = Zorlen_isChanneling() or Zorlen_isCasting()
	local cat_form = isCatForm()
	local bear_form = isDireBearForm() or isBearForm()
	local caster_form = isCasterForm()
	local moonkin_form = isMoonkinForm()
	
	if locked then
		return true
	end
	
	if heal and not cat_form and not bear_form and not moonkin_form then
		QuickHeal();
	end
	
	if dps then
		if (caster_form or moonkin_form) and castWrath() then
			return true	
		elseif bear_form and LazyPigMultibox_AttackBear() then
			castAttack();
			return true	
		elseif cat_form and LazyPigMultibox_AttackCat() then
			castAttack();
			return true	
		end
	end
	
	if buff and not cat_form and not bear_form then
		LazyPigMultibox_UnitBuff();
	end
end

function LazyPigMultibox_AttackCat()
	local percent = (UnitHealth("target") / UnitHealthMax("target")) * 100
	if (isComboPoints(5) or isComboPoints(4) and percent<=25) and Zorlen_castSpellByName("Rip") then
		return true	
	else
		if not isProwlActive() and castFaerieFire() then
			return true	
		elseif Zorlen_checkDebuffByName("Rake", "target") and Zorlen_castSpellByName("Claw") then
			return true	
		elseif Zorlen_castSpellByName("Rake") then
			return true	
		end
	end
end

function LazyPigMultibox_AttackBear()
	if castFaerieFire() then
		return true	
	elseif not Zorlen_isEnemyTargetingYou() and Zorlen_checkCooldownByName("Growl") and not Zorlen_isEnemyPlayer("target") and Zorlen_castSpellByName("Growl") then 
		return true	
	elseif Zorlen_castSpellByName("Maul") then
		return true	
	end
end


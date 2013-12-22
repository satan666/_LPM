
Zorlen_Rogue_FileBuildNumber = 688

--[[
  Zorlen Library - Started by Marcus S. Zarra
  
  4.27
		Zorlen_GarroteEnergyCost() added by BigRedBrent
		castGarrote() added by BigRedBrent
  
  4.22
		castAmbush() added by charroux
		castKidneyShot(ComboPointsNumber) added by charroux
		castBladeFlurry() added by charroux
		castGouge() added by charroux
		castFeint(GroupOnly) added by charroux
		castBlind(RequiredPowderReserve) added by charroux
  
  4.21
		Added option to remove the debuff check with: castHemorrhage(1)
  
  4.20
		castHemorrhage() added by charroux
		isHemorrhage() added by charroux
		castGhostlyStrike() added by charroux
		Added hand option to all isPoisonActive(hand) functions -- Valid options are: "main", "off", 1, 2, and nil
  
  4.15
		Fixed: unStealth()
  
  4.12
		isAdrenalineRushActive() added by Nosrac
		isBladeFlurryActive() added by Nosrac
		isEvasionActive() added by Nosrac
		isSprintActive() added by Nosrac
		isCripplingPoisonActive() added by Nosrac
		isDeadlyPoisonActive() added by Nosrac
		isInstantPoisonActive() added by Nosrac
		isMindnumbingPoisonActive() added by Nosrac
		isWoundPoisonActive() added by Nosrac
		isPoisonActive() added by BigRedBrent
  
  3.92
		castStealth() added by BigRedBrent
		unStealth() added by BigRedBrent
		castVanish() added by BigRedBrent
  
  3.78
		castFeint() added by Xek
		castEviscerate() added by Xek
		castRiposte() added by Xek
		castSliceAndDice() added by Xek
		isComboPoints(number) added by BigRedBrent

  3.70.00
		castColdBlood() added by Mainline

  3.10.00
		isSliceActive() added by Mizz
		isStealthActive() added by BigRedBrent
		isComboPointsFull() added by BigRedBrent
		Zorlen_CheapShotEnergyCost() added by BigRedBrent
		Zorlen_SinisterStrikeEnergyCost() added by Mizz
		castSinisterStrike() added by Mizz
		castBackstab() added by Mizz
		castKick() added by Mizz
		castCheapShot() added by BigRedBrent

  3.00  Rewrite by Wynn (Bleeding Hollow), break units into class functions.
		  
--]]




function isComboPointsFull()
	return isComboPoints(5)
end

function isComboPoints(number)
	if number then
		if GetComboPoints() >= number then
			return true
		end
	elseif GetComboPoints() > 0 then
		return true
	end
	return false
end


--Added by charroux
function isHemorrhage(unit)
	return Zorlen_checkDebuff("Spell_Shadow_LifeDrain", unit)
end






--------   All functions below this line will only load if you are playing the corresponding class   --------
if not Zorlen_isCurrentClassRogue then return end








function isStealthActive()
	return Zorlen_checkBuff("Ability_Stealth")
end

function isSliceActive()
	return Zorlen_checkBuff("Ability_Rogue_SliceDice")
end 

--Added by Nosrac
function isAdrenalineRushActive()
	local SpellName = LOCALIZATION_ZORLEN.AdrenalineRush
	return Zorlen_checkBuffByName(SpellName)
end

--Added by Nosrac
function isBladeFlurryActive()
	local SpellName = LOCALIZATION_ZORLEN.BladeFlurry
	return Zorlen_checkBuffByName(SpellName)
end

--Added by Nosrac
function isEvasionActive()
	local SpellName = LOCALIZATION_ZORLEN.Evasion
	return Zorlen_checkBuffByName(SpellName)
end

--Added by Nosrac
function isSprintActive()
	local SpellName = LOCALIZATION_ZORLEN.Sprint
	return Zorlen_checkBuffByName(SpellName)
end


--Added by Nosrac
function isCripplingPoisonActive(hand)
	local SpellName = LOCALIZATION_ZORLEN.CripplingPoison
	return Zorlen_checkItemBuffByName(SpellName, hand)
end

--Added by Nosrac
function isDeadlyPoisonActive(hand)
	local SpellName = LOCALIZATION_ZORLEN.DeadlyPoison
	return Zorlen_checkItemBuffByName(SpellName, hand)
end

--Added by Nosrac
function isInstantPoisonActive(hand)
	local SpellName = LOCALIZATION_ZORLEN.InstantPoison
	return Zorlen_checkItemBuffByName(SpellName, hand)
end

--Added by Nosrac
function isMindnumbingPoisonActive(hand)
	local SpellName = LOCALIZATION_ZORLEN.MindnumbingPoison
	return Zorlen_checkItemBuffByName(SpellName, hand)
end

--Added by Nosrac
function isWoundPoisonActive(hand)
	local SpellName = LOCALIZATION_ZORLEN.WoundPoison
	return Zorlen_checkItemBuffByName(SpellName, hand)
end

--Added by BigRedBrent
function isPoisonActive(hand)
	if isCripplingPoisonActive(hand) or isDeadlyPoisonActive(hand) or isInstantPoisonActive(hand) or isMindnumbingPoisonActive(hand) or isWoundPoisonActive(hand) then
		return true
	end
	return false
end

-- Returns the energy cost the Cheap Shot ability will need for it to cast (even if talent points are spent on it to lower its required energy cost).
-- Will return 0 if no rank of the ability has been learned from the Rouge Trainer.
function Zorlen_CheapShotEnergyCost()
	if Zorlen_IsSpellKnown(LOCALIZATION_ZORLEN.CheapShot) then
		local t = Zorlen_GetTalentRank(LOCALIZATION_ZORLEN.DirtyDeeds)
		return (60 - (10 * t))
	end
	return 0
end

-- Returns the energy cost the Garrote ability will need for it to cast (even if talent points are spent on it to lower its required energy cost).
-- Will return 0 if no rank of the ability has been learned from the Rouge Trainer.
function Zorlen_GarroteEnergyCost()
	if Zorlen_IsSpellKnown(LOCALIZATION_ZORLEN.Garrote) then
		local t = Zorlen_GetTalentRank(LOCALIZATION_ZORLEN.DirtyDeeds)
		return (50 - (10 * t))
	end
	return 0
end



-- Returns the energy cost the Sinister Strike ability will need for it to cast (even if talent points are spent on it to lower its required energy cost).
-- Will return 0 if no rank of the ability has been learned from the Rouge Trainer.
function Zorlen_SinisterStrikeEnergyCost()
	if Zorlen_IsSpellKnown(LOCALIZATION_ZORLEN.SinisterStrike) then
		local t = Zorlen_GetTalentRank(LOCALIZATION_ZORLEN.ImprovedSinisterStrike)
		if t == 2 then
			return 40
		elseif t == 1 then
			return 42
		end
		return 45
	end
	return 0
end



function castSinisterStrike(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.SinisterStrike
	z.ManaNeeded = Zorlen_SinisterStrikeEnergyCost()
	if not Zorlen_isMainHandEquipped() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end



function castCheapShot(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.CheapShot
	z.ManaNeeded = Zorlen_CheapShotEnergyCost()
	if not isStealthActive() or not Zorlen_isMainHandEquipped() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end


function castGarrote(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Garrote
	z.ManaNeeded = Zorlen_GarroteEnergyCost()
	if not isStealthActive() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end



function castBackstab(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Backstab
	z.ManaNeeded = 60
	if not Zorlen_isMainHandDagger() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end



function castKick(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Kick
	z.ManaNeeded = 25
	z.TargetThatUsesManaNeeded = 1
	return Zorlen_CastCommonRegisteredSpell(z)
end



--Added by Mainline
function castColdBlood(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.ColdBlood
	z.EnemyTargetNotNeeded = 1
	return Zorlen_CastCommonRegisteredSpell(z)
end





--Added by Xek
function castEviscerate(ComboPointsNumber, test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Eviscerate
	z.ManaNeeded = 35
	if not isComboPoints(ComboPointsNumber) or not Zorlen_isMainHandEquipped() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by Xek
function castRiposte(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Riposte
	z.ManaNeeded = 10
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by Xek
function castSliceAndDice(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.SliceAndDice
	z.ManaNeeded = 25
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by charroux
--Edited by BigRedBrent
function castHemorrhage(RemoveDebuffCheck, test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Hemorrhage
	z.ManaNeeded = 35
	if not Zorlen_isMainHandEquipped() then
		return false 
	elseif not RemoveDebuffCheck then
		z.DebuffName = z.SpellName
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by charroux
function castGhostlyStrike(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.GhostlyStrike
	z.ManaNeeded = 40
	return Zorlen_CastCommonRegisteredSpell(z)
end

function castStealth(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Stealth
	z.EnemyTargetNotNeeded = 1
	if Zorlen_inCombat() or isStealthActive() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end

function unStealth()
	return Zorlen_CancelSelfBuff("Ability_Stealth")
end

function castVanish(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Vanish
	z.EnemyTargetNotNeeded = 1
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by charroux
function castAmbush(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Ambush
	z.ManaNeeded = 60
	if not Zorlen_isMainHandDagger() or not isStealthActive() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by charroux
function castKidneyShot(ComboPointsNumber, test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.KidneyShot
	z.ManaNeeded = 25
	if not isComboPoints(ComboPointsNumber) or not Zorlen_isMainHandEquipped() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by charroux
function castBladeFlurry(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.BladeFlurry
	z.ManaNeeded = 25
	z.EnemyTargetNotNeeded = 1
	if not Zorlen_isMainHandEquipped() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by charroux
function castGouge(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Gouge
	z.ManaNeeded = 45
	if not Zorlen_isMainHandEquipped() then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end


function castFeint(GroupOnly, test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Feint
	z.ManaNeeded = 20
	if GroupOnly then
		local raid = UnitInRaid("player")
		if (not raid and GetNumPartyMembers() == 0) or (raid and GetNumRaidMembers() <= 1) then
			return false
		end
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end

--Added by charroux
function castBlind(RequiredPowderReserve, test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_ZORLEN.Blind
	z.ManaNeeded = 30
	RequiredPowderReserve = RequiredPowderReserve or 1
	if Zorlen_GiveContainerItemCountByItemID(5530) < RequiredPowderReserve then
		return false
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end
--Smart Stealth by SML
function Smart_Stealth()

 if isStealthActive() then 
	if (IsAltKeyDown() and not Zorlen_isEnemy()) then 
		unStealth()
	end 
else 
	if (Zorlen_checkCooldownByName("Stealth") and not Zorlen_inCombat() and not IsAltKeyDown()) then 
		castStealth() 
	else 
		if (Zorlen_isEnemy("target") or Zorlen_inCombat()) then 
			castVanish() 
		end
	end
end


end
------------------------------------------------
function Smart_Slice()
	
	local percent = (UnitHealth("target") / UnitHealthMax("target")) * 100
	
	if (isComboPoints(5) or (isComboPoints(4) and percent<=35) or (percent<=25 and isComboPoints(3))) then
		
		if(Zorlen_isEnemyPlayer() and not Zorlen_checkDebuffByName("Kidney Shot", "target")) then
			Zorlen_castSpellByName("Kidney Shot")
		else
			Zorlen_castSpellByName("Slice and Dice")
		end
	end

end

--Samrt Eviscerate by SML------------------------
function Smart_Eviscerate()
	
	local percent = (UnitHealth("target") / UnitHealthMax("target")) * 100
	
	if (isComboPoints(5) or (isComboPoints(4) and percent<=35) or (percent<=25 and isComboPoints(3))) then	
		if(Zorlen_isEnemyPlayer() and not Zorlen_checkDebuffByName("Kidney Shot", "target")) then
			Zorlen_castSpellByName("Kidney Shot")
		else
			Zorlen_castSpellByName("Eviscerate")
		end
	end

end
--add by SML---------------------------
function Smart_Rupture()
	
	local percent = (UnitHealth("target") / UnitHealthMax("target")) * 100
	
	if (isComboPoints(5) or (isComboPoints(4) and percent<=35) or (percent<=25 and isComboPoints(3))) then
		
		if(Zorlen_isEnemyPlayer() and not Zorlen_checkDebuffByName("Kidney Shot", "target")) then
			Zorlen_castSpellByName("Kidney Shot")
		else
			Zorlen_castSpellByName("Rupture")
		end
	end

end
--add by SML------------------------------
function Adrenaline()

	if (UnitIsPlayer("target") or UnitClassification("target") == "worldboss" or UnitClassification("target") == "rareelite" and not UnitIsDeadOrGhost("target")) then
		if(Zorlen_checkCooldownByName("Adrenaline Rush")) then
			DoEmote("Roar","target") 
			if (Zorlen_checkCooldownByName("Adrenaline Rush")) then
				Zorlen_castSpellByName("Adrenaline Rush")
			end	
		end	
	end
end
------------------------------------------------
function Attack_Eviscerate(name)

if (Zorlen_inCombat() and not Zorlen_TargetIsDieingEnemy()) then
	Adrenaline() 
	castBladeFlurry() 
end 
castRiposte() 
Smart_Eviscerate() 
if(Zorlen_TargetIsEnemy()) then
	castSinisterStrike()
end
if ((Return_UnitId(name) == "player") and not Zorlen_TargetIsEnemy()) then
	Zorlen_TargetNearestEnemy()
end
	castAttack() 
end
--------------------------------------
function Attack_Rupture(name)

Smart_Rupture()
 
if(Zorlen_TargetIsEnemy()) then
	Zorlen_castSpellByName("Hemorrhage")
end

if ((Return_UnitId(name) == "player") and not Zorlen_TargetIsEnemy()) then
	Zorlen_TargetNearestEnemy()
end
	castAttack()

end
----------------------------------------------
function Attack_Cheap(name)


if (Return_UnitId(name) == "player") then
	Zorlen_TargetNearestEnemy()
end

if(Zorlen_TargetIsEnemy()) then
	castCheapShot()
end

end
--------------------------------------------------------

function Attack_SH(name)

Smart_Slice()
 
if(Zorlen_TargetIsEnemy()) then
	Zorlen_castSpellByName("Hemorrhage")
end

if ((Return_UnitId(name) == "player") and not Zorlen_TargetIsEnemy()) then
	Zorlen_TargetNearestEnemy()
end
	castAttack()
end
-------------------------------------------
function Attack_SS(name)

Smart_Slice()
 
if(Zorlen_TargetIsEnemy()) then
	castSinisterStrike()
end

if ((Return_UnitId(name) == "player") and not Zorlen_TargetIsEnemy()) then
	Zorlen_TargetNearestEnemy()
end
	castAttack()
end

--------------------------------------------------------
function Smart_Skill(name)

if(Zorlen_isCrowedControlled("player")) then
	Zorlen_useItemByName("Insignia of the Alliance")
	return true
end

if (Zorlen_checkDebuffByName("Hamstring", "player") or Zorlen_checkDebuffByName("Frost Nova", "player") or Zorlen_checkDebuffByName("Entangling Rootss", "player")) then
	if(Zorlen_checkCooldownByName("Escape Artist")) then
		Zorlen_castSpellByName("Escape Artist")
		return true
	end	
end

if (Zorlen_inCombat() and Zorlen_isEnemyTargetingYou() and (Zorlen_isEnemyPlayer() or UnitClassification("target") == "worldboss" or UnitClassification("target") == "rareelite")) then 
	if(Zorlen_checkCooldownByName("Evasion")) then
		Zorlen_castSpellByName("Evasion")
		return true
	end	
end

if (Zorlen_isEnemyPlayer() and not CheckInteractDistance("target", 2) and (isStealthActive() or Zorlen_inCombat())) then
	if(Zorlen_checkCooldownByName("Sprint")) then
		Zorlen_castSpellByName("Sprint")
		return true
	elseif (Zorlen_IsSpellKnown("Preparation")) then
		if(Zorlen_checkCooldownByName("Preparation")) then	
			Zorlen_castSpellByName("Preparation")
			return true
		end	
	end	
end	

if(isStealthActive()) then	
	if(UnitAffectingCombat("target") and not CheckInteractDistance("target", 2) and Zorlen_isEnemyPlayer() and not Zorlen_checkCooldownByName("Sprint") and not Zorlen_checkBuffByName("Sprint", "player")) then
		unStealth()
		return true
	end
end
	
if(isStealthActive()) then
	if(Zorlen_IsSpellKnown("Premeditation") and Zorlen_TargetIsEnemy() and CheckInteractDistance("target", 2)) then
		if(Zorlen_checkCooldownByName("Premeditation")) then
			DoEmote("laugh","target") 
			Zorlen_castSpellByName("Premeditation")
			return true
		end		
	end
end


end
------------------------------------
function Blind_Kick()
local abilty_onbar = false
if(Zorlen_IsSpellKnown("Hemorrhage")) then
	if (isActionInRangeBySpellName("Hemorrhage")) then
		abilty_onbar = true
	elseif(isActionInRangeBySpellName("Sinister Strike")) then
		abilty_onbar = true
	end
end

if(abilty_onbar) then
	--castKick()
	if(Zorlen_checkCooldownByName("Kick")) then
		Zorlen_castSpellByName("Kick")
		DoEmote("spit","target") 
		return true
	end	
--elseif(CheckInteractDistance("target", 2) and Zorlen_isEnemy() and (Zorlen_GiveContainerItemCountByItemID(5530) > 0)) then
else
	if(Zorlen_checkCooldownByName("Blind") and isActionInRangeBySpellName("Blind") and (Zorlen_GiveContainerItemCountByItemID(5530) > 0)) then
		castBlind()
		DoEmote("rude","target") 
		return true
	end	
end
	
end

function QuickHeal_Priest_GetRatioHealthyExplanation()
    if QuickHealVariables.RatioHealthyPriest >= QuickHealVariables.RatioFull then
        return QUICKHEAL_SPELL_FLASH_HEAL .. " will always be used in combat, and "  .. QUICKHEAL_SPELL_LESSER_HEAL .. ", " .. QUICKHEAL_SPELL_HEAL .. " or " .. QUICKHEAL_SPELL_GREATER_HEAL .. " will be used when out of combat. ";
    else
        if QuickHealVariables.RatioHealthyPriest > 0 then
            return QUICKHEAL_SPELL_FLASH_HEAL .. " will be used in combat if the target has less than " .. QuickHealVariables.RatioHealthyPriest*100 .. "% life, and " .. QUICKHEAL_SPELL_LESSER_HEAL .. ", " .. QUICKHEAL_SPELL_HEAL .. " or " .. QUICKHEAL_SPELL_GREATER_HEAL .. " will be used otherwise. ";
        else
            return QUICKHEAL_SPELL_FLASH_HEAL .. " will never be used. " .. QUICKHEAL_SPELL_LESSER_HEAL .. ", " .. QUICKHEAL_SPELL_HEAL .. " or " .. QUICKHEAL_SPELL_GREATER_HEAL .. " will always be used in and out of combat. ";
        end
    end
end

function QuickHeal_Priest_FindSpellToUse(Target)
    local SpellID = nil;
    local HealSize = 0;

    -- Return immediatly if no player needs healing
    if not Target then
        return SpellID,HealSize;
    end

    -- +Healing-PenaltyFactor = (1-((20-LevelLearnt)*0.0375)) for all spells learnt before level 20
    local PF1 = 0.2875;
    local PF4 = 0.4;
    local PF10 = 0.625;
    local PF18 = 0.925;

    -- Determine health and healneed of target
    local healneed;
    local Health;

    if QuickHeal_UnitHasHealthInfo(Target) then
        -- Full info available
        healneed = UnitHealthMax(Target) - UnitHealth(Target);
        Health = UnitHealth(Target) / UnitHealthMax(Target);
    else
        -- Estimate target health
        healneed = QuickHeal_EstimateUnitHealNeed(Target,true);
        Health = UnitHealth(Target)/100;
    end

    -- if BonusScanner is running, get +Healing bonus
    local Bonus = 0;
    if (BonusScanner) then
        Bonus = tonumber(BonusScanner:GetBonus("HEAL"));
        QuickHeal_debug(string.format("Equipment Healing Bonus: %d", Bonus));
    end

    -- Spiritual Guidance - Increases spell damage and healing by up to 5% (per rank) of your total Spirit.
    local _,_,_,_,talentRank,_ = GetTalentInfo(2,14);
    local _,Spirit,_,_ = UnitStat('player',5);
    local sgMod = Spirit * 5*talentRank/100;
    QuickHeal_debug(string.format("Spiritual Guidance Bonus: %f", sgMod));

    -- Calculate healing bonus
    local healMod15 = (1.5/3.5) * (sgMod + Bonus);
    local healMod20 = (2.0/3.5) * (sgMod + Bonus);
    local healMod25 = (2.5/3.5) * (sgMod + Bonus);
    local healMod30 = (3.0/3.5) * (sgMod + Bonus);
    QuickHeal_debug("Final Healing Bonus (1.5,2.0,2.5,3.0)", healMod15,healMod20,healMod25,healMod30);

    local InCombat = UnitAffectingCombat('player') or UnitAffectingCombat(Target);
  
    -- Spiritual Healing - Increases healing by 2% per rank on all spells
    local _,_,_,_,talentRank,_ = GetTalentInfo(2,15);
    local shMod = 2*talentRank/100 + 1;
    QuickHeal_debug(string.format("Spiritual Healing modifier: %f", shMod));
    
    -- Improved Healing - Decreases mana usage by 5% per rank on LH,H and GH
    local _,_,_,_,talentRank,_ = GetTalentInfo(2,10); 
    local ihMod = 1 - 5*talentRank/100;
    QuickHeal_debug(string.format("Improved Healing modifier: %f", ihMod));

    local TargetIsHealthy = Health >= QuickHealVariables.RatioHealthyPriest;
    local ManaLeft = UnitMana('player');

    if TargetIsHealthy then
        QuickHeal_debug("Target is healthy",Health);
    end

    -- Detect proc of 'Hand of Edward the Odd' mace (next spell is instant cast)
    if QuickHeal_DetectBuff('player',"Spell_Holy_SearingLight") then
        QuickHeal_debug("BUFF: Hand of Edward the Odd (out of combat healing forced)");
        InCombat = false;
    end

    -- Detect Inner Focus or Spirit of Redemption (hack ManaLeft and healneed)
    if QuickHeal_DetectBuff('player',"Spell_Frost_WindWalkOn",1) or QuickHeal_DetectBuff('player',"Spell_Holy_GreaterHeal") then
        QuickHeal_debug("Inner Focus or Spirit of Redemption active");
        ManaLeft = UnitManaMax('player'); -- Infinite mana
        healneed = 10^6; -- Deliberate overheal (mana is free)
    end

    -- Get total healing modifier (factor) caused by healing target debuffs
    local HDB = QuickHeal_GetHealModifier(Target);
    QuickHeal_debug("Target debuff healing modifier",HDB);
    healneed = healneed/HDB;

    -- Get a list of ranks available for all spells
    local SpellIDsLH = QuickHeal_GetSpellIDs(QUICKHEAL_SPELL_LESSER_HEAL);
    local SpellIDsH  = QuickHeal_GetSpellIDs(QUICKHEAL_SPELL_HEAL);
    local SpellIDsGH = QuickHeal_GetSpellIDs(QUICKHEAL_SPELL_GREATER_HEAL);
    local SpellIDsFH = QuickHeal_GetSpellIDs(QUICKHEAL_SPELL_FLASH_HEAL);

    local maxRankLH = table.getn(SpellIDsLH);
    local maxRankH  = table.getn(SpellIDsH);
    local maxRankGH = table.getn(SpellIDsGH);
	
	if LPMULTIBOX and LPMULTIBOX.SCRIPT_FASTHEAL and maxRankGH > 0 then
		maxRankGH = 1
	end
	
    local maxRankFH = table.getn(SpellIDsFH);

    QuickHeal_debug(string.format("Found LH up to rank %d, H up top rank %d, GH up to rank %d, and FH up to rank %d", maxRankLH, maxRankH, maxRankGH, maxRankFH));

    -- Compensation for health lost during combat
    local k=1.0;
    local K=1.0;
    if InCombat then
        k=0.9;
        K=0.8;
    end

    -- Find suitable SpellID based on the defined criteria
    if not InCombat or TargetIsHealthy or maxRankFH<1 then
        -- Not in combat or target is healthy so use the closest available mana efficient healing
        QuickHeal_debug(string.format("Not in combat or target healthy or no flash heal available, will use closest available LH, H or GH (not FH)"))
        if Health < QuickHealVariables.RatioFull then
            SpellID = SpellIDsLH[1]; HealSize = 53*shMod+healMod15*PF1; -- Default to LH
            if healneed > (  84*shMod+healMod20*PF4) *k and ManaLeft >=  45*ihMod and maxRankLH >=2 then SpellID = SpellIDsLH[2]; HealSize =   84*shMod+healMod20*PF4 end
            if healneed > ( 154*shMod+healMod25*PF10)*K and ManaLeft >=  75*ihMod and maxRankLH >=3 then SpellID = SpellIDsLH[3]; HealSize =  154*shMod+healMod25*PF10 end
            if healneed > ( 318*shMod+healMod30*PF18)*K and ManaLeft >= 155*ihMod and maxRankH  >=1 then SpellID = SpellIDsH[1];  HealSize =  318*shMod+healMod30*PF18 end
            if healneed > ( 460*shMod+healMod30)*K and ManaLeft >= 205*ihMod and maxRankH  >=2 then SpellID = SpellIDsH[2];  HealSize =  460*shMod+healMod30 end
            if healneed > ( 604*shMod+healMod30)*K and ManaLeft >= 255*ihMod and maxRankH  >=3 then SpellID = SpellIDsH[3];  HealSize =  604*shMod+healMod30 end
            if healneed > ( 758*shMod+healMod30)*K and ManaLeft >= 305*ihMod and maxRankH  >=4 then SpellID = SpellIDsH[4];  HealSize =  758*shMod+healMod30 end
            if healneed > ( 956*shMod+healMod30)*K and ManaLeft >= 370*ihMod and maxRankGH >=1 then SpellID = SpellIDsGH[1]; HealSize =  956*shMod+healMod30 end
            if healneed > (1219*shMod+healMod30)*K and ManaLeft >= 455*ihMod and maxRankGH >=2 then SpellID = SpellIDsGH[2]; HealSize = 1219*shMod+healMod30 end
            if healneed > (1523*shMod+healMod30)*K and ManaLeft >= 545*ihMod and maxRankGH >=3 then SpellID = SpellIDsGH[3]; HealSize = 1523*shMod+healMod30 end
            if healneed > (1902*shMod+healMod30)*K and ManaLeft >= 655*ihMod and maxRankGH >=4 then SpellID = SpellIDsGH[4]; HealSize = 1902*shMod+healMod30 end
            if healneed > (2080*shMod+healMod30)*K and ManaLeft >= 710*ihMod and maxRankGH >=5 then SpellID = SpellIDsGH[5]; HealSize = 2080*shMod+healMod30 end
        end         
    else
        -- In combat and target is unhealthy and player has flash heal
        QuickHeal_debug(string.format("In combat and target unhealthy and player has flash heal, will only use FH"));
        if Health < QuickHealVariables.RatioFull then
            SpellID = SpellIDsFH[1]; HealSize = 215*shMod+healMod15; -- Default to FH
            if healneed > (286*shMod+healMod15)*k and ManaLeft >= 155 and maxRankFH >=2 then SpellID = SpellIDsFH[2]; HealSize = 286*shMod+healMod15 end
            if healneed > (360*shMod+healMod15)*k and ManaLeft >= 185 and maxRankFH >=3 then SpellID = SpellIDsFH[3]; HealSize = 360*shMod+healMod15 end
            if healneed > (439*shMod+healMod15)*k and ManaLeft >= 215 and maxRankFH >=4 then SpellID = SpellIDsFH[4]; HealSize = 439*shMod+healMod15 end
            if healneed > (567*shMod+healMod15)*k and ManaLeft >= 265 and maxRankFH >=5 then SpellID = SpellIDsFH[5]; HealSize = 567*shMod+healMod15 end
            if healneed > (704*shMod+healMod15)*k and ManaLeft >= 315 and maxRankFH >=6 then SpellID = SpellIDsFH[6]; HealSize = 704*shMod+healMod15 end
            if healneed > (885*shMod+healMod15)*k and ManaLeft >= 380 and maxRankFH >=7 then SpellID = SpellIDsFH[7]; HealSize = 885*shMod+healMod15 end
        end
    end
    
    return SpellID,HealSize*HDB;
end

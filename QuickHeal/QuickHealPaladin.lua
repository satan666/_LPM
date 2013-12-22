
function QuickHeal_Paladin_GetRatioHealthyExplanation()
    local RatioHealthy = QuickHeal_GetRatioHealthy();
    local RatioFull = QuickHealVariables["RatioFull"];

    if RatioHealthy >= RatioFull then
        return QUICKHEAL_SPELL_HOLY_LIGHT .. " will never be used in combat. ";
    else
        if RatioHealthy > 0 then
            return QUICKHEAL_SPELL_HOLY_LIGHT .. " will only be used in combat if the target has more than " .. RatioHealthy*100 .. "% life, and only if the healing done is greater than the greatest " .. QUICKHEAL_SPELL_FLASH_OF_LIGHT .. " available. ";          
        else
            return QUICKHEAL_SPELL_HOLY_LIGHT .. " will only be used in combat if the healing done is greater than the greatest " .. QUICKHEAL_SPELL_FLASH_OF_LIGHT .. " available. ";         
        end
    end
end

function QuickHeal_Paladin_FindSpellToUse(Target)
    local SpellID = nil;
    local HealSize = 0;

    -- +Healing-PenaltyFactor = (1-((20-LevelLearnt)*0.0375)) for all spells learnt before level 20
    local PF1 = 0.2875;
    local PF6 = 0.475;
    local PF14 = 0.775;

    -- Local aliases to access main module functionality and settings
    local RatioFull = QuickHealVariables["RatioFull"];
    local RatioHealthy = QuickHeal_GetRatioHealthy();
    local UnitHasHealthInfo = QuickHeal_UnitHasHealthInfo;
    local EstimateUnitHealNeed = QuickHeal_EstimateUnitHealNeed;
    local GetSpellIDs = QuickHeal_GetSpellIDs;
    local debug = QuickHeal_debug;

    -- Return immediatly if no player needs healing
    if not Target then
        return SpellID,HealSize;
    end

    -- Determine health and healneed of target
    local healneed;
    local Health;

    if UnitHasHealthInfo(Target) then
        -- Full info available
        healneed = UnitHealthMax(Target) - UnitHealth(Target);
        Health = UnitHealth(Target) / UnitHealthMax(Target);
    else
        -- Estimate target health
        healneed = EstimateUnitHealNeed(Target,true);
        Health = UnitHealth(Target)/100;
    end

    -- if BonusScanner is running, get +Healing bonus
    local Bonus = 0;
    if (BonusScanner) then
        Bonus = tonumber(BonusScanner:GetBonus("HEAL"));
        debug(string.format("Equipment Healing Bonus: %d", Bonus));
    end

    -- Calculate healing bonus
    local healMod15 = (1.5/3.5) * Bonus;
    local healMod25 = (2.5/3.5) * Bonus;
    debug("Final Healing Bonus (1.5,2.5)", healMod15,healMod25);

    local InCombat = UnitAffectingCombat('player') or UnitAffectingCombat(Target);

    -- Healing Light Talent (increases healing by 4% per rank)
    local _,_,_,_,talentRank,_ = GetTalentInfo(1,5); 
    local hlMod = 4*talentRank/100 + 1;
    debug(string.format("Healing Light talentmodification: %f", hlMod))

    local TargetIsHealthy = Health >= RatioHealthy;
    local ManaLeft = UnitMana('player');

    if TargetIsHealthy then
        debug("Target is healthy",Health);
    end

    -- Detect proc of 'Hand of Edward the Odd' mace (next spell is instant cast)
    if QuickHeal_DetectBuff('player',"Spell_Holy_SearingLight") then
        debug("BUFF: Hand of Edward the Odd (out of combat healing forced)");
        InCombat = false;
    end
    
    -- Get total healing modifier (factor) caused by healing target debuffs
    local HDB = QuickHeal_GetHealModifier(Target);
    debug("Target debuff healing modifier",HDB);
    healneed = healneed/HDB;

    -- Get a list of ranks available of 'Lesser Healing Wave' and 'Healing Wave'
    local SpellIDsHL = GetSpellIDs(QUICKHEAL_SPELL_HOLY_LIGHT);
    local SpellIDsFL = GetSpellIDs(QUICKHEAL_SPELL_FLASH_OF_LIGHT);
    local maxRankHL = table.getn(SpellIDsHL);
	
	if LPMULTIBOX and LPMULTIBOX.SCRIPT_FASTHEAL and maxRankHL > 1 then
		maxRankHL= 1
	end
    local maxRankFL = table.getn(SpellIDsFL);
    local NoFL = maxRankFL < 1;
    debug(string.format("Found HL up to rank %d, and found FL up to rank %d", maxRankHL, maxRankFL))

    -- Find suitable SpellID based on the defined criteria
    if InCombat then
        local k = 0.9; -- In combat means that target is loosing life while casting, so compensate           
        local K = 0.8; -- k for fast spells (LHW and HW Rank 1 and 2) and K for slow spells (HW)
        if Health < RatioFull then
            if maxRankFL >=1 then SpellID = SpellIDsFL[1]; HealSize = 67*hlMod+healMod15 else SpellID = SpellIDsHL[1]; HealSize = 43*hlMod+healMod25*PF1 end -- Default to rank 1 of FL or HL
            if healneed > ( 83*hlMod+healMod25*PF6 )*K and ManaLeft >=  60 and maxRankHL >=2 and (TargetIsHealthy and maxRankFL <= 1 or NoFL) then SpellID = SpellIDsHL[2]; HealSize =  83*hlMod+healMod25*PF6 end
                if healneed > (103*hlMod+healMod15)*k and ManaLeft >= 50 and maxRankFL >=2 then SpellID = SpellIDsFL[2]; HealSize = 103*hlMod+healMod15 end
                if healneed > (154*hlMod+healMod15)*k and ManaLeft >= 70 and maxRankFL >=3 then SpellID = SpellIDsFL[3]; HealSize = 154*hlMod+healMod15 end
            if healneed > (173*hlMod+healMod25*PF14)*K and ManaLeft >= 110 and maxRankHL >=3 and (TargetIsHealthy and maxRankFL <= 3 or NoFL) then SpellID = SpellIDsHL[3]; HealSize = 173*hlMod+healMod25*PF14 end
                if healneed > (209*hlMod+healMod15)*k and ManaLeft >= 90 and maxRankFL >=4 then SpellID = SpellIDsFL[4]; HealSize = 209*hlMod+healMod15 end
                if healneed > (283*hlMod+healMod15)*k and ManaLeft >= 115 and maxRankFL >=5 then SpellID = SpellIDsFL[5]; HealSize = 283*hlMod+healMod15 end
            if healneed > (333*hlMod+healMod25)*K and ManaLeft >= 190 and maxRankHL >=4 and (TargetIsHealthy and maxRankFL <= 5 or NoFL) then SpellID = SpellIDsHL[4]; HealSize = 333*hlMod+healMod25 end
                if healneed > (363*hlMod+healMod15)*k and ManaLeft >= 140 and maxRankFL >=6 then SpellID = SpellIDsFL[6]; HealSize = 363*hlMod+healMod15 end
            if healneed > (522*hlMod+healMod25)*K and ManaLeft >= 275 and maxRankHL >=5 and (TargetIsHealthy and maxRankFL <= 6 or NoFL) then SpellID = SpellIDsHL[5]; HealSize = 522*hlMod+healMod25 end
            if healneed > (739*hlMod+healMod25)*K and ManaLeft >= 365 and maxRankHL >=6 and (TargetIsHealthy and maxRankFL <= 6 or NoFL) then SpellID = SpellIDsHL[6]; HealSize = 739*hlMod+healMod25 end
            if healneed > (999*hlMod+healMod25)*K and ManaLeft >= 465 and maxRankHL >=7 and (TargetIsHealthy and maxRankFL <= 6 or NoFL) then SpellID = SpellIDsHL[7]; HealSize = 999*hlMod+healMod25 end
            if healneed > (1317*hlMod+healMod25)*K and ManaLeft >= 580 and maxRankHL >=8 and (TargetIsHealthy and maxRankFL <= 6 or NoFL) then SpellID = SpellIDsHL[8]; HealSize = 1317*hlMod+healMod25 end
            if healneed > (1680*hlMod+healMod25)*K and ManaLeft >= 660 and maxRankHL >=9 and (TargetIsHealthy and maxRankFL <= 6 or NoFL) then SpellID = SpellIDsHL[9]; HealSize = 1680*hlMod+healMod25 end
        end
    else
        -- Not in combat
        if Health < RatioFull then
            if maxRankFL >=1 then SpellID = SpellIDsFL[1]; HealSize = 67*hlMod+healMod15 else SpellID = SpellIDsHL[1]; HealSize = 43*hlMod+healMod25*PF1 end -- Default to rank 1 of FL or HL
            if healneed > ( 83*hlMod+healMod25*PF6 ) and ManaLeft >=  60 and maxRankHL >=2 and maxRankFL <= 1 then SpellID = SpellIDsHL[2]; HealSize =  83*hlMod+healMod25*PF6 end
                if healneed > (103*hlMod+healMod15) and ManaLeft >= 50 and maxRankFL >=2 then SpellID = SpellIDsFL[2]; HealSize = 103*hlMod+healMod15 end
                if healneed > (154*hlMod+healMod15) and ManaLeft >= 70 and maxRankFL >=3 then SpellID = SpellIDsFL[3]; HealSize = 154*hlMod+healMod15 end
            if healneed > (173*hlMod+healMod25*PF14) and ManaLeft >= 110 and maxRankHL >=3 and maxRankFL <= 3 then SpellID = SpellIDsHL[3]; HealSize = 173*hlMod+healMod25*PF14 end
                if healneed > (209*hlMod+healMod15) and ManaLeft >= 90 and maxRankFL >=4 then SpellID = SpellIDsFL[4]; HealSize = 209*hlMod+healMod15 end
                if healneed > (283*hlMod+healMod15) and ManaLeft >= 115 and maxRankFL >=5 then SpellID = SpellIDsFL[5]; HealSize = 283*hlMod+healMod15 end
            if healneed > (333*hlMod+healMod25) and ManaLeft >= 190 and maxRankHL >=4 and maxRankFL <= 5 then SpellID = SpellIDsHL[4]; HealSize = 333*hlMod+healMod25 end
                if healneed > (363*hlMod+healMod15) and ManaLeft >= 140 and maxRankFL >=6 then SpellID = SpellIDsFL[6]; HealSize = 363*hlMod+healMod15 end
            if healneed > (522*hlMod+healMod25) and ManaLeft >= 275 and maxRankHL >=5 then SpellID = SpellIDsHL[5]; HealSize = 522*hlMod+healMod25 end
            if healneed > (739*hlMod+healMod25) and ManaLeft >= 365 and maxRankHL >=6 then SpellID = SpellIDsHL[6]; HealSize = 739*hlMod+healMod25 end
            if healneed > (999*hlMod+healMod25) and ManaLeft >= 465 and maxRankHL >=7 then SpellID = SpellIDsHL[7]; HealSize = 999*hlMod+healMod25 end
            if healneed > (1317*hlMod+healMod25) and ManaLeft >= 580 and maxRankHL >=8 then SpellID = SpellIDsHL[8]; HealSize = 1317*hlMod+healMod25 end
            if healneed > (1680*hlMod+healMod25) and ManaLeft >= 660 and maxRankHL >=9 then SpellID = SpellIDsHL[9]; HealSize = 1680*hlMod+healMod25 end            
        end
    end
    return SpellID,HealSize*HDB;
end
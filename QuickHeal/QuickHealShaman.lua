
function QuickHeal_Shaman_GetRatioHealthyExplanation()
    local RatioHealthy = QuickHeal_GetRatioHealthy();
    local RatioFull = QuickHealVariables["RatioFull"];

    if RatioHealthy >= RatioFull then
        return QUICKHEAL_SPELL_HEALING_WAVE .. " will never be used in combat. ";
    else
        if RatioHealthy > 0 then
            return QUICKHEAL_SPELL_HEALING_WAVE .. " will only be used in combat if the target has more than " .. RatioHealthy*100 .. "% life, and only if the healing done is greater than the greatest " .. QUICKHEAL_SPELL_LESSER_HEALING_WAVE .. " available. ";          
        else
            return QUICKHEAL_SPELL_HEALING_WAVE .. " will only be used in combat if the healing done is greater than the greatest " .. QUICKHEAL_SPELL_LESSER_HEALING_WAVE .. " available. ";         
        end
    end
end

function QuickHeal_Shaman_FindSpellToUse(Target)
    local SpellID = nil;
    local HealSize = 0;

    -- +Healing-PenaltyFactor = (1-((20-LevelLearnt)*0.0375)) for all spells learnt before level 20
    local PF1 = 0.2875;
    local PF6 = 0.475;
    local PF12 = 0.7;
    local PF18 = 0.925;

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
    local healModLHW = (1.5/3.5) * Bonus;
    local healMod15 = (1.5/3.5) * Bonus;
    local healMod20 = (2.0/3.5) * Bonus;
    local healMod25 = (2.5/3.5) * Bonus;
    local healMod30 = (3.0/3.5) * Bonus;
    debug("Final Healing Bonus (1.5,2.0,2.5,3.0,LHW)", healMod15,healMod20,healMod25,healMod30,healModLHW);

    local InCombat = UnitAffectingCombat('player') or UnitAffectingCombat(Target);

    -- Purification Talent (increases healing by 2% per rank)
    local _,_,_,_,talentRank,_ = GetTalentInfo(3,14);
    local pMod = 2*talentRank/100 + 1;
    debug(string.format("Purification modifier: %f", pMod))

    -- Tidal Focus - Decreases mana usage by 1% per rank on healing
    local _,_,_,_,talentRank,_ = GetTalentInfo(3,2);
    local tfMod = 1 - talentRank/100;
    debug(string.format("Improved Healing modifier: %f", tfMod));

    local TargetIsHealthy = Health >= RatioHealthy;
    local ManaLeft = UnitMana('player');

    if TargetIsHealthy then
        debug("Target is healthy",Health)
    end

    -- Detect Nature's Swiftness (next nature spell is instant cast)
    if QuickHeal_DetectBuff('player',"Spell_Nature_RavenForm") then
        debug("BUFF: Nature's Swiftness (out of combat healing forced)");
        InCombat = false;
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

    -- Detect healing way on target
    local hwMod = QuickHeal_DetectBuff(Target,"Spell_Nature_HealingWay");
    if hwMod then hwMod = 1+0.06*hwMod else hwMod = 1 end;
    debug("Healing Way healing modifier",hwMod);

    -- Get a list of ranks available of 'Lesser Healing Wave' and 'Healing Wave'
    local SpellIDsHW = GetSpellIDs(QUICKHEAL_SPELL_HEALING_WAVE);
    local SpellIDsLHW = GetSpellIDs(QUICKHEAL_SPELL_LESSER_HEALING_WAVE);
	local maxRankHW = table.getn(SpellIDsHW);
	
	if LPMULTIBOX and LPMULTIBOX.SCRIPT_FASTHEAL and maxRankHW > 1 then
		maxRankHW = 1
	end
	
	local maxRankHW = 1
    local maxRankLHW = table.getn(SpellIDsLHW);
    local NoLHW = maxRankLHW < 1;
    debug(string.format("Found HW up to rank %d, and found LHW up to rank %d", maxRankHW, maxRankLHW))

    -- Find suitable SpellID based on the defined criteria
    if InCombat then
        -- In combat so use LHW unless:
            -- Target is healthy (health > RatioHealthy)
            -- AND The HW in question is larger than any available LHW
            -- OR LHW is unavailable (sub level 20 characters)
        debug(string.format("In combat, will prefer LHW"))
        if Health < RatioFull then
            local k = 0.9; -- In combat means that target is losing life while casting, so compensate           
            local K = 0.8; -- k for fast spells (LHW and HW Rank 1 and 2) and K for slow spells (HW)
            if maxRankLHW >=1 then SpellID = SpellIDsLHW[1]; HealSize = 174*pMod+healModLHW else SpellID = SpellIDsHW[1]; HealSize = 39*pMod*hwMod+healMod15*PF1 end -- Default to HW or LHW
                if healneed > (  71*pMod*hwMod+healMod20*PF6 )*k and ManaLeft >= 45*tfMod and maxRankHW >=2 and NoLHW then SpellID = SpellIDsHW[2]; HealSize =  71*pMod*hwMod+healMod20*PF6 end
                if healneed > ( 142*pMod*hwMod+healMod25*PF12)*K and ManaLeft >= 80*tfMod and maxRankHW >=3 and NoLHW then SpellID = SpellIDsHW[3]; HealSize = 142*pMod*hwMod+healMod25*PF12 end
            if healneed > (174*pMod+healModLHW)*k and ManaLeft >= 105*tfMod and maxRankLHW >=1 then SpellID = SpellIDsLHW[1]; HealSize = 174*pMod+healModLHW end
            if healneed > (264*pMod+healModLHW)*k and ManaLeft >= 145*tfMod and maxRankLHW >=2 then SpellID = SpellIDsLHW[2]; HealSize = 264*pMod+healModLHW end
                if healneed > ( 292*pMod*hwMod+healMod30*PF18)*K and ManaLeft >= 155*tfMod and maxRankHW >=4 and (TargetIsHealthy and maxRankLHW <= 2 or NoLHW) then SpellID = SpellIDsHW[4]; HealSize = 292*pMod*hwMod+healMod30*PF18 end
            if healneed > (359*pMod+healModLHW)*k and ManaLeft >= 185*tfMod and maxRankLHW >=3 then SpellID = SpellIDsLHW[3]; HealSize = 359*pMod+healModLHW end
                if healneed > ( 408*pMod*hwMod+healMod30)*K and ManaLeft >= 200*tfMod and maxRankHW >=5 and (TargetIsHealthy and maxRankLHW <= 3 or NoLHW)  then SpellID = SpellIDsHW[5]; HealSize = 408*pMod*hwMod+healMod30 end
            if healneed > (486*pMod+healModLHW)*k and ManaLeft >= 235*tfMod and maxRankLHW >=4 then SpellID = SpellIDsLHW[4]; HealSize = 486*pMod+healModLHW end
                if healneed > ( 579*pMod*hwMod+healMod30)*K and ManaLeft >= 265*tfMod and maxRankHW >=6 and (TargetIsHealthy and maxRankLHW <= 4 or NoLHW) then SpellID = SpellIDsHW[6]; HealSize = 579*pMod*hwMod+healMod30 end
            if healneed > (668*pMod+healModLHW)*k and ManaLeft >= 305*tfMod and maxRankLHW >=5 then SpellID = SpellIDsLHW[5]; HealSize = 668*pMod+healModLHW end
                if healneed > ( 797*pMod*hwMod+healMod30)*K and ManaLeft >= 340*tfMod and maxRankHW >=7 and (TargetIsHealthy and maxRankLHW <= 5 or NoLHW) then SpellID = SpellIDsHW[7]; HealSize = 797*pMod*hwMod+healMod30 end
            if healneed > (880*pMod+healModLHW)*k and ManaLeft >= 380*tfMod and maxRankLHW >=6 then SpellID = SpellIDsLHW[6]; HealSize = 880*pMod+healModLHW end
                if healneed > (1092*pMod*hwMod+healMod30)*K and ManaLeft >= 440*tfMod and maxRankHW >=8 and (TargetIsHealthy and maxRankLHW <= 6 or NoLHW) then SpellID = SpellIDsHW[8]; HealSize = 1092*pMod*hwMod+healMod30 end
                if healneed > (1464*pMod*hwMod+healMod30)*K and ManaLeft >= 560*tfMod and maxRankHW >=9 and (TargetIsHealthy and maxRankLHW <= 6 or NoLHW) then SpellID = SpellIDsHW[9]; HealSize = 1464*pMod*hwMod+healMod30 end
                if healneed > (1735*pMod*hwMod+healMod30)*K and ManaLeft >= 620*tfMod and maxRankHW >=10 and (TargetIsHealthy and maxRankLHW <= 6 or NoLHW) then SpellID = SpellIDsHW[10]; HealSize = 1735*pMod*hwMod+healMod30 end
        end
    else
        -- Not in combat so use the closest available healing
        debug(string.format("Not in combat, will use closest available HW or LHW"))
        if Health < RatioFull then
            SpellID = SpellIDsHW[1]; HealSize = 39*pMod*hwMod+healMod15*PF1; 
                if healneed > ( 71*pMod*hwMod+healMod20*PF6 ) and ManaLeft >= 45*tfMod and maxRankHW >=2 then SpellID = SpellIDsHW[2]; HealSize = 71*pMod*hwMod+healMod20*PF6 end
                if healneed > (142*pMod*hwMod+healMod25*PF12) and ManaLeft >= 80*tfMod and maxRankHW >=3 then SpellID = SpellIDsHW[3]; HealSize = 142*pMod*hwMod+healMod25*PF12 end
            if healneed > (174*pMod+healModLHW) and ManaLeft >= 105*tfMod and maxRankLHW >=1 then SpellID = SpellIDsLHW[1]; HealSize = 174*pMod+healModLHW end
            if healneed > (264*pMod+healModLHW) and ManaLeft >= 145*tfMod and maxRankLHW >=2 then SpellID = SpellIDsLHW[2]; HealSize = 264*pMod+healModLHW end
                if healneed > (292*pMod*hwMod+healMod30*PF18) and ManaLeft >= 155*tfMod and maxRankHW >=4 then SpellID = SpellIDsHW[4]; HealSize = 292*pMod*hwMod+healMod30*PF18 end
            if healneed > (359*pMod+healModLHW) and ManaLeft >= 185*tfMod and maxRankLHW >=3 then SpellID = SpellIDsLHW[3]; HealSize = 359*pMod+healModLHW end
                if healneed > (408*pMod*hwMod+healMod30) and ManaLeft >= 200*tfMod and maxRankHW >=5 then SpellID = SpellIDsHW[5]; HealSize = 408*pMod*hwMod+healMod30 end
            if healneed > (486*pMod+healModLHW) and ManaLeft >= 235*tfMod and maxRankLHW >=4 then SpellID = SpellIDsLHW[4]; HealSize = 486*pMod+healModLHW end
                if healneed > (579*pMod*hwMod+healMod30) and ManaLeft >= 265*tfMod and maxRankHW >=6 then SpellID = SpellIDsHW[6]; HealSize = 579*pMod*hwMod+healMod30 end
            if healneed > (668*pMod+healModLHW) and ManaLeft >= 305*tfMod and maxRankLHW >=5 then SpellID = SpellIDsLHW[5]; HealSize = 668*pMod+healModLHW end
                if healneed > (797*pMod*hwMod+healMod30) and ManaLeft >= 340*tfMod and maxRankHW >=7 then SpellID = SpellIDsHW[7]; HealSize = 797*pMod*hwMod+healMod30 end
            if healneed > (880*pMod+healModLHW) and ManaLeft >= 380*tfMod and maxRankLHW >=6 then SpellID = SpellIDsLHW[6]; HealSize = 880*pMod+healModLHW end
                if healneed > (1092*pMod*hwMod+healMod30) and ManaLeft >= 440*tfMod and maxRankHW >=8 then SpellID = SpellIDsHW[8]; HealSize = 1092*pMod*hwMod+healMod30 end
                if healneed > (1464*pMod*hwMod+healMod30) and ManaLeft >= 560*tfMod and maxRankHW >=9 then SpellID = SpellIDsHW[9]; HealSize = 1464*pMod*hwMod+healMod30 end
                if healneed > (1735*pMod*hwMod+healMod30) and ManaLeft >= 620*tfMod and maxRankHW >=10 then SpellID = SpellIDsHW[10]; HealSize = 1735*pMod*hwMod+healMod30 end
        end         
    end
    
    return SpellID,HealSize*HDB;
end
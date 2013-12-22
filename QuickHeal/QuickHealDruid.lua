
function QuickHeal_Druid_GetRatioHealthyExplanation()
    local RatioHealthy = QuickHeal_GetRatioHealthy();
    local RatioFull = QuickHealVariables["RatioFull"];

    if RatioHealthy >= RatioFull then
        return QUICKHEAL_SPELL_REGROWTH .. " will always be used in combat, and "  .. QUICKHEAL_SPELL_HEALING_TOUCH .. " will be used when out of combat. ";
    else
        if RatioHealthy > 0 then
            return QUICKHEAL_SPELL_REGROWTH .. " will be used in combat if the target has less than " .. RatioHealthy*100 .. "% life, and " .. QUICKHEAL_SPELL_HEALING_TOUCH .. " will be used otherwise. ";
        else
            return QUICKHEAL_SPELL_REGROWTH .. " will never be used. " .. QUICKHEAL_SPELL_HEALING_TOUCH .. " will always be used in and out of combat. ";
        end
    end
end

function QuickHeal_Druid_FindSpellToUse(Target)
    local SpellID = nil;
    local HealSize = 0;

    -- +Healing-PenaltyFactor = (1-((20-LevelLearnt)*0.0375)) for all spells learnt before level 20
    local PF1 = 0.2875;
    local PF8 = 0.55;
    local PFRG1 = 0.7 * 1.042; -- Rank 1 of RG (1.041 compensates for the 0.50 factor that should be 0.48 for RG1)
    local PF14 = 0.775;
    local PFRG2 = 0.925;

    -- Local aliases to access main module functionality and settings
    local RatioFull = QuickHealVariables["RatioFull"];
    local RatioHealthy = QuickHeal_GetRatioHealthy();
    local UnitHasHealthInfo = QuickHeal_UnitHasHealthInfo;
    local EstimateUnitHealNeed = QuickHeal_EstimateUnitHealNeed;
    local GetSpellIDs = QuickHeal_GetSpellIDs;
    local debug = QuickHeal_debug;

    -- Return immediately if no player needs healing
    if not Target then
        return SpellID,HealSize;
    end

    -- Determine health and heal need of target
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
    local healMod20 = (2.0/3.5) * Bonus;
    local healMod25 = (2.5/3.5) * Bonus;
    local healMod30 = (3.0/3.5) * Bonus;
    local healMod35 = Bonus;
    local healModRG = (2.0/3.5) * Bonus * 0.5; -- The 0.5 factor is calculated as DirectHeal/(DirectHeal+HoT)
    debug("Final Healing Bonus (1.5,2.0,2.5,3.0,3.5,Regrowth)", healMod15,healMod20,healMod25,healMod30,healMod35,healModRG);

    local InCombat = UnitAffectingCombat('player') or UnitAffectingCombat(Target);

    -- Gift of Nature - Increases healing by 2% per rank
    local _,_,_,_,talentRank,_ = GetTalentInfo(3,12); 
    local gnMod = 2*talentRank/100 + 1;
    debug(string.format("Gift of Nature modifier: %f", gnMod));

    -- Tranquil Spirit - Decreases mana usage by 2% per rank on HT only
    local _,_,_,_,talentRank,_ = GetTalentInfo(3,9); 
    local tsMod = 1 - 2*talentRank/100;
    debug(string.format("Tranquil Spirit modifier: %f", tsMod));

    -- Moonglow - Decrease mana usage by 3% per rank
    local _,_,_,_,talentRank,_ = GetTalentInfo(1,14); 
    local mgMod = 1 - 3*talentRank/100;
    debug(string.format("Moonglow modifier: %f", mgMod));
   
    -- Improved Rejuvenation -- Increases Rejuvenation effects by 5% per rank
    --local _,_,_,_,talentRank,_ = GetTalentInfo(3,10); 
    --local irMod = 5*talentRank/100 + 1;
    --debug(string.format("Improved Rejuvenation modifier: %f", irMod));

    local TargetIsHealthy = Health >= RatioHealthy;
    local ManaLeft = UnitMana('player');

    if TargetIsHealthy then
        debug("Target is healthy ",Health);
    end
    
    -- Detect Clearcasting (from Omen of Clarity, talent(1,9))
    if QuickHeal_DetectBuff('player',"Spell_Shadow_ManaBurn",1) then -- Spell_Shadow_ManaBurn (1)
        ManaLeft = UnitManaMax('player');  -- set to max mana so max spell rank will be cast
        healneed = 10^6; -- deliberate overheal (mana is free)
        debug("BUFF: Clearcasting (Omen of Clarity)");
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

    -- Get a list of ranks available for all spells
    local SpellIDsHT = GetSpellIDs(QUICKHEAL_SPELL_HEALING_TOUCH);
    local SpellIDsRG = GetSpellIDs(QUICKHEAL_SPELL_REGROWTH);
    --local SpellIDsRJ = GetSpellIDs(QUICKHEAL_SPELL_REJUVENATION);

    local maxRankHT = table.getn(SpellIDsHT);
    local maxRankRG = table.getn(SpellIDsRG);
    --local maxRankRJ = table.getn(SpellIDsRJ);
	
	if LPMULTIBOX and LPMULTIBOX.SCRIPT_FASTHEAL and maxRankRG > 1 then
		maxRankRG = 1
	end
    
    debug(string.format("Found HT up to rank %d, RG up to rank %d", maxRankHT, maxRankRG));

    -- Compensation for health lost during combat
    local k=1.0;
    local K=1.0;
    if InCombat then
        k=0.9;
        K=0.8;
    end

    -- Find suitable SpellID based on the defined criteria
    if not InCombat or TargetIsHealthy or maxRankRG<1 then
        -- Not in combat or target is healthy so use the closest available mana efficient healing
        debug(string.format("Not in combat or target healthy or no Regrowth available, will use Healing Touch"))
        if Health < RatioFull then
            SpellID = SpellIDsHT[1]; HealSize = 44*gnMod+healMod15*PF1; -- Default to rank 1
            if healneed > ( 100*gnMod+healMod20*PF8 )*k and ManaLeft >=  55*tsMod*mgMod and maxRankHT >=  2 then SpellID =  SpellIDsHT[2]; HealSize =  100*gnMod+healMod20*PF8 end
            if healneed > ( 219*gnMod+healMod25*PF14)*K and ManaLeft >= 110*tsMod*mgMod and maxRankHT >=  3 then SpellID =  SpellIDsHT[3]; HealSize =  219*gnMod+healMod25*PF14 end
            if healneed > ( 404*gnMod+healMod30)*K and ManaLeft >= 185*tsMod*mgMod and maxRankHT >=  4 then SpellID =  SpellIDsHT[4]; HealSize =  404*gnMod+healMod30 end
            if healneed > ( 633*gnMod+healMod35)*K and ManaLeft >= 270*tsMod*mgMod and maxRankHT >=  5 then SpellID =  SpellIDsHT[5]; HealSize =  633*gnMod+healMod35 end
            if healneed > ( 818*gnMod+healMod35)*K and ManaLeft >= 335*tsMod*mgMod and maxRankHT >=  6 then SpellID =  SpellIDsHT[6]; HealSize =  818*gnMod+healMod35 end
            if healneed > (1028*gnMod+healMod35)*K and ManaLeft >= 405*tsMod*mgMod and maxRankHT >=  7 then SpellID =  SpellIDsHT[7]; HealSize = 1028*gnMod+healMod35 end
            if healneed > (1313*gnMod+healMod35)*K and ManaLeft >= 495*tsMod*mgMod and maxRankHT >=  8 then SpellID =  SpellIDsHT[8]; HealSize = 1313*gnMod+healMod35 end
            if healneed > (1656*gnMod+healMod35)*K and ManaLeft >= 600*tsMod*mgMod and maxRankHT >=  9 then SpellID =  SpellIDsHT[9]; HealSize = 1656*gnMod+healMod35 end
            if healneed > (2060*gnMod+healMod35)*K and ManaLeft >= 720*tsMod*mgMod and maxRankHT >= 10 then SpellID = SpellIDsHT[10]; HealSize = 2060*gnMod+healMod35 end
            if healneed > (2472*gnMod+healMod35)*K and ManaLeft >= 800*tsMod*mgMod and maxRankHT >= 11 then SpellID = SpellIDsHT[11]; HealSize = 2472*gnMod+healMod35 end
        end         
    else
        -- In combat and target is unhealthy and player has Regrowth
        debug(string.format("In combat and target unhealthy and Regrowth available, will use Regrowth"));
        if Health < RatioFull then
            SpellID = SpellIDsRG[1]; HealSize = 91*gnMod+healModRG*PFRG1; -- Default to rank 1
            if healneed > ( 176*gnMod+healModRG*PFRG2)*k and ManaLeft >= 205*mgMod and maxRankRG >= 2 then SpellID = SpellIDsRG[2]; HealSize =  176*gnMod+healModRG*PFRG2 end
            if healneed > ( 257*gnMod+healModRG)*k and ManaLeft >= 280*mgMod and maxRankRG >= 3 then SpellID = SpellIDsRG[3]; HealSize =  257*gnMod+healModRG end
            if healneed > ( 339*gnMod+healModRG)*k and ManaLeft >= 350*mgMod and maxRankRG >= 4 then SpellID = SpellIDsRG[4]; HealSize =  339*gnMod+healModRG end
            if healneed > ( 431*gnMod+healModRG)*k and ManaLeft >= 420*mgMod and maxRankRG >= 5 then SpellID = SpellIDsRG[5]; HealSize =  431*gnMod+healModRG end
            if healneed > ( 543*gnMod+healModRG)*k and ManaLeft >= 510*mgMod and maxRankRG >= 6 then SpellID = SpellIDsRG[6]; HealSize =  543*gnMod+healModRG end
            if healneed > ( 686*gnMod+healModRG)*k and ManaLeft >= 615*mgMod and maxRankRG >= 7 then SpellID = SpellIDsRG[7]; HealSize =  686*gnMod+healModRG end
            if healneed > ( 857*gnMod+healModRG)*k and ManaLeft >= 740*mgMod and maxRankRG >= 8 then SpellID = SpellIDsRG[8]; HealSize =  857*gnMod+healModRG end
            if healneed > (1061*gnMod+healModRG)*k and ManaLeft >= 880*mgMod and maxRankRG >= 9 then SpellID = SpellIDsRG[9]; HealSize = 1061*gnMod+healModRG end
        end
    end
    
    return SpellID,HealSize*HDB;
end

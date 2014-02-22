
LPMULTIBOX_UI = {
    TUI_PARTYFRAME_SHOW = true,
    TUI_PARTYSOLO_SHOW = true,
    TUI_PARTYFRAME_LOCK = false,
    TUI_PARTYFRAME_POINT = {
        LEFT = 550,
        BOTTOM = 70,
    },

    TUI_MINIFRAME_SHOW = false,
    
    TUI_PARTYPETFRAME_SHOW = true,
    TUI_PARTYPETFRAME_LOCK = true,
    TUI_PARTYPETFRAME_POINT = {
        LEFT = 550,
        BOTTOM = 70,
    },

    TUI_RAIDFRAME_SHOW = false,
    TUI_RAIDFRAME_LOCK = false,
    TUI_PARTYINRAID = false,

    TUI_BLIZZARDPLAYER_HIDE = false,
    TUI_BLIZZARDPARTY_HIDE = false,

    TUI_PADDING = 3,
    TUI_SCALE = 1.00,
    TUI_BGALPHA = 0.37,

    LF_LOCK = true,
    LF_SCALE = 1.00,

    OF_POINT = {
        LEFT = 50,
        BOTTOM = 300,
    }
}

LPM_TeamTable = {
    ['player'] = {
        name = nil,
        curr_xp = nil,
        max_xp = nil,
        rested_xp = nil,
    },

    --['party1'] = {},
    --['raid1'] = {},
    --['raid40'] = {},
}

function LPM_SendXPData()
    local name = UnitName('player')
    local curr_xp = UnitXP('player')
    local max_xp = UnitXPMax('player')
    local rested_xp = GetXPExhaustion()

    LPM_UpdateExp_Normal(name, curr_xp, max_xp)
    LPM_UpdateExp_Rested(name, rested_xp)
end

function LPM_UpdateExp_Normal(name, curr_xp, max_xp)
    for k,v in pairs(LPM_TeamTable) do
        if v.name == name then
            v.curr_xp = curr_xp
            v.max_xp = max_xp
        end
    end

    if name == UnitName('player') then
        local msg = LPM_DataStringEncode("lpm_dataexp_normal_reply", curr_xp, max_xp)
        SendAddonMessage("LPM_UI", msg, "RAID", GetUnitName('player'))
    end
end

function LPM_UpdateExp_Rested(name, rested_xp)
    for k,v in pairs(LPM_TeamTable) do
        if v.name == name then
            v.rested_xp = rested_xp
        end
    end

    if name == UnitName('player') then
        local msg = LPM_DataStringEncode("lpm_dataexp_rested_reply", rested_xp)
        SendAddonMessage("LPM_UI", msg, "RAID", GetUnitName('player'))
    end
end

-- This function is accepting "string", "number", "boolean" and nil only.
-- If you pass other data types, it may and will bug out...
-- You're warned!
function LPM_DataStringEncode(...)
    local total_lenght = 0
        
	for i = 1, table.getn(arg) do
		local e = arg[i]
		if not e then
			total_lenght = total_lenght + 3 + 1
		elseif type(e) == "boolean" then
			total_lenght = total_lenght + 5 + 1
		else
			total_lenght = total_lenght + string.len(e) + 1
		end
	end

    if total_lenght > 250 then
        LPM_STATUS(" DataStringEncode - String Limit Exceeded - Report this to the developers, please.")
        return
    end

    local data_string = ""
    for k = 1, table.getn(arg) do
        local v = arg[k]
        if k > 1 then
            data_string = data_string .. "\1"
        end
        if not v then
            data_string = data_string .. "\2" .. tostring(v)
        elseif type(v) == "number" then
            data_string = data_string .. "\3" .. v
        elseif type(v) == "string" then
            data_string = data_string .. "\4" .. v
        elseif type(v) == "boolean" then
            data_string = data_string .. "\5" .. tostring(v)
        end
    end

    return data_string
end

function LPM_DataStringDecode(str)
    local function strsplit(delimiter, text)
        local list = {}
        local pos = 1
        if string.find("", delimiter, 1) then -- this would result in endless loops
            LPM_STATUS(" DataStringDecode - Delimiter matches empty string - Report this to the developers, please.")
            return
        end
        while 1 do
            local first, last = string.find(text, delimiter, pos)
            if first then
                table.insert(list, string.sub(text, pos, first-1))
                pos = last + 1
            else
                table.insert(list, string.sub(text, pos))
                break
            end
        end
        return list
    end
   
    local vars = strsplit("\1", str)
    local count = 0

    for k,v in ipairs(vars) do
        count = count + 1
        local vartype = string.sub(v, 1, 1)
        if vartype == "\2" then
            vars[k] = nil
        elseif vartype == "\3" then
            local s = string.sub(v, 2)
            vars[k] = tonumber(s)
        elseif vartype == "\4" then
            local s = string.sub(v, 2)
            vars[k] = tostring(s)
        elseif vartype == "\5" then
            local s = string.sub(v, 2)
            if s == "true" then
                vars[k] = true
            else
                vars[k] = false
            end
        end
    end

    return count, unpack(vars)
end

local Original_PlayerFrame_Update = PlayerFrame_Update
local Original_PlayerFrame_OnEvent = PlayerFrame_OnEvent
local Original_PlayerFrame_OnUpdate = PlayerFrame_OnUpdate

function LPM_HideBlizzardPlayerFrames(hide)
    local frame = getglobal("PlayerFrame")
    if hide then
        PlayerFrame_Update = function() end
        PlayerFrame_OnEvent = function() end
        PlayerFrame_OnUpdate = function() end
        frame:Hide()
        frame:RegisterEvent("UNIT_LEVEL");
        frame:RegisterEvent("UNIT_COMBAT");
        frame:RegisterEvent("UNIT_FACTION");
        frame:RegisterEvent("UNIT_MAXMANA");
        frame:RegisterEvent("PLAYER_ENTERING_WORLD");
        frame:RegisterEvent("PLAYER_ENTER_COMBAT");
        frame:RegisterEvent("PLAYER_LEAVE_COMBAT");
        frame:RegisterEvent("PLAYER_REGEN_DISABLED");
        frame:RegisterEvent("PLAYER_REGEN_ENABLED");
        frame:RegisterEvent("PLAYER_UPDATE_RESTING");
        frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
        frame:RegisterEvent("PARTY_LEADER_CHANGED");
        frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
        frame:RegisterEvent("RAID_ROSTER_UPDATE");
    else
        PlayerFrame_Update = Original_PlayerFrame_Update
        PlayerFrame_OnEvent = Original_PlayerFrame_OnEvent
        PlayerFrame_OnUpdate = Original_PlayerFrame_OnUpdate
        frame:Show()
        frame:RegisterEvent("UNIT_LEVEL");
        frame:RegisterEvent("UNIT_COMBAT");
        frame:RegisterEvent("UNIT_FACTION");
        frame:RegisterEvent("UNIT_MAXMANA");
        frame:RegisterEvent("PLAYER_ENTERING_WORLD");
        frame:RegisterEvent("PLAYER_ENTER_COMBAT");
        frame:RegisterEvent("PLAYER_LEAVE_COMBAT");
        frame:RegisterEvent("PLAYER_REGEN_DISABLED");
        frame:RegisterEvent("PLAYER_REGEN_ENABLED");
        frame:RegisterEvent("PLAYER_UPDATE_RESTING");
        frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
        frame:RegisterEvent("PARTY_LEADER_CHANGED");
        frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
        frame:RegisterEvent("RAID_ROSTER_UPDATE");
    end
    --  Proper "hiding" should include these line as well
    --frame:UnregisterAllEvents()
    --getglobal("PartyMemberFrame" .. num .. "HealthBar"):UnregisterAllEvents()
    --getglobal("PartyMemberFrame" .. num .. "ManaBar"):UnregisterAllEvents()
    --frame:ClearAllPoints()
    --frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", 0, 50)
end

local Original_ShowPartyFrame = ShowPartyFrame
local Original_HidePartyFrame = HidePartyFrame
local Original_PartyMemberFrame_OnEvent = PartyMemberFrame_OnEvent
local Original_PartyMemberFrame_OnUpdate = PartyMemberFrame_OnUpdate

function LPM_HideBlizzardPartyFrames(hide)
    if hide then
        ShowPartyFrame = function() end  -- Hide Blizz stuff
        HidePartyFrame = function() end
        PartyMemberFrame_OnEvent = function() end
        PartyMemberFrame_OnUpdate = function() end
        for num = 1, 4 do
            if UnitInParty("party" .. num) then
                local frame = getglobal("PartyMemberFrame"..num)
                
                frame:UnregisterEvent("PARTY_MEMBERS_CHANGED");
                frame:UnregisterEvent("PARTY_LEADER_CHANGED");
                frame:UnregisterEvent("PARTY_MEMBER_ENABLE");
                frame:UnregisterEvent("PARTY_MEMBER_DISABLE");
                frame:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED");
                frame:UnregisterEvent("UNIT_FACTION");
                frame:UnregisterEvent("UNIT_AURA");
                frame:UnregisterEvent("UNIT_PET");
                frame:UnregisterEvent("VARIABLES_LOADED");
                frame:Hide()
            end
        end
    else
        ShowPartyFrame = Original_ShowPartyFrame
        HidePartyFrame = Original_HidePartyFrame
        PartyMemberFrame_OnEvent = Original_PartyMemberFrame_OnEvent
        PartyMemberFrame_OnUpdate = PartyMemberFrame_OnUpdate
        for num = 1, 4 do
            if UnitInParty("party" .. num) then
                local frame = getglobal("PartyMemberFrame"..num)
                frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
                frame:RegisterEvent("PARTY_LEADER_CHANGED");
                frame:RegisterEvent("PARTY_MEMBER_ENABLE");
                frame:RegisterEvent("PARTY_MEMBER_DISABLE");
                frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
                frame:RegisterEvent("UNIT_FACTION");
                frame:RegisterEvent("UNIT_AURA");
                frame:RegisterEvent("UNIT_PET");
                frame:RegisterEvent("VARIABLES_LOADED");
                frame:Show()
            end
        end
    end
        --  Proper "hiding" should include these line as well
        --frame:UnregisterAllEvents()
        --getglobal("PlayerFrameHealthBar"):UnregisterAllEvents()
        --getglobal("PlayerFrameManaBar"):UnregisterAllEvents()
        --frame:ClearAllPoints()
        --frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", 0, 50)
end

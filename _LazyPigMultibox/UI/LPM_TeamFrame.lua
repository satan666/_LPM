
local LPM_UI_CONSTANT = {
	-- Team Party Frame --> TPF
	TPF_UNITFRAME_PADDING = 3,
	TPF_FRAME_SCALE = 1.0,
	TPF_FRAME_BGALPHA = 0.37,

	TPF_FRAME_BGFILE = "Interface\\ChatFrame\\ChatFrameBackground",
	TPF_UNITFRAME_BGFILE = "Interface\\ChatFrame\\ChatFrameBackground",
	TPF_UNITFRAME_SBFILE = "Interface\\AddOns\\_LazyPigMultibox\\Textures\\StatusBar",

	TPF_UNITFRAME_FONT = "Fonts\\ARIALN.TTF",

	TPF_UNITFRAME_WIDTH = 100,
	TPF_UNITFRAME_HEIGHT = 42,

	TPF_FRAME_HEADER = 12,
	TPF_FRAME_FOOTER = 4,
	TPF_FRAME_WIDTH = 108,
	--TPF_FRAME_HEIGHT = ( LPM_UI_CONSTANT.TPF_UNITFRAME_HEIGHT + LPM_UI_CONSTANT.TPF_UNITFRAME_PADDING ) * 5 + LPM_UI_CONSTANT.TPF_FRAME_HEADER + LPM_UI_CONSTANT.TPF_FRAME_FOOTER, --249!
	TPF_FRAME_HEIGHT = 235
}

local ClassColor = {
	["UNKNOWN"]	= { { 0.51, 0.51, 0.51 }, "UNKNOWN" },
	["DRUID"]	= { { 1.00, 0.49, 0.04 }, "Druid"   },
	["HUNTER"]	= { { 0.67, 0.83, 0.45 }, "Hunter"  },
	["MAGE"]	= { { 0.41, 0.80, 0.94 }, "Mage"    },
	["PALADIN"]	= { { 0.96, 0.55, 0.73 }, "Paladin" },
	["PRIEST"]	= { { 1.00, 1.00, 1.00 }, "Priest"  },
	["ROGUE"]	= { { 1.00, 0.96, 0.41 }, "Rogue"   },
	["SHAMAN"]	= { { 0.96, 0.55, 0.73 }, "Shaman"  },
	--["SHAMAN"]	= { {0.00, 0.86, 0.73 }, "Shaman"  }, -- TBC Shaman Color
	["WARLOCK"]	= { { 0.58, 0.51, 0.79 }, "Warlock" },
	["WARRIOR"]	= { { 0.78, 0.61, 0.43 }, "Warrior" },
}

local PowerColor = {
	["UNKNOWN"] = { { 0.51, 0.51, 0.51 }, "UNKNOWN" },
			[0] = { { 0.19, 0.44, 0.75 }, "Mana"  	},
			[1] = { { 0.89, 0.18, 0.29 }, "Rage"   	},
			[2] = { { 1.00, 0.70, 0.0  }, "Focus"  	},
			[3] = { { 1.00, 1.00, 0.13 }, "Energy" 	},
}


local function PrintPartyUnitNames()
	local n = GetNumPartyMembers()
	local leader = GetPartyLeaderIndex()
	LPM_DEBUG(" -- Party Leader Index: " .. leader)
	for i = 1, 4 do
		if GetPartyMember(i) then
			if leader == i then
				LPM_DEBUG(" Leader [party" .. i .. "]: " .. UnitName('party' ..i))
			else
				LPM_DEBUG(" Member [party" .. i .. "]: " .. UnitName('party' ..i))
			end
		else
			LPM_DEBUG(" Null   [party" .. i .. "]")
		end
	end
end

local function PrintPartyUnitExp()
	local n = GetNumPartyMembers()
	local unit
	for i = 0, 4 do
		if i == 0 then
			unit = 'player'
		else
			unit = GetPartyMember(i)
			if unit then unit = 'party' .. unit end
		end
		if unit then
			if LPM_TeamTable[unit] and LPM_TeamTable[unit].curr_xp and LPM_TeamTable[unit].rested_xp then
				LPM_DEBUG("  '" .. unit .. "' - " .. LPM_TeamTable[unit].name .. " Exp: " .. LPM_TeamTable[unit].curr_xp .. " - Rested: " .. LPM_TeamTable[unit].rested_xp)
			elseif LPM_TeamTable[unit] and LPM_TeamTable[unit].curr_xp then
				LPM_DEBUG("  '" .. unit .. "' - " .. LPM_TeamTable[unit].name .. " Exp: " .. LPM_TeamTable[unit].curr_xp)
			else
				LPM_DEBUG("  '" .. unit .. "' - No Exp in LPM_TeamTable")
			end
		else
			LPM_DEBUG("  'party" .. i .. "' not present")
		end
	end
end

local function SlaveFollowFrame(follow, frame)
	if follow then
		frame.frame_follow:Hide()
	else
		frame.frame_follow:Show()
	end
end

local function SlaveLostFrame(lost, frame)
	if lost then
		frame.frame_lost:Hide()
	else
		frame.frame_lost:Show()
	end
end

local function SlaveCombatIcon(combat, frame)
	if combat then
		frame.icon_combat:Show()
	else
		frame.icon_combat:Hide()
	end
end

local function SlaveRestIcon(rest, frame)
	if rest then
		frame.icon_rest:Show()
	else
		frame.icon_rest:Hide()
	end
end

local function HideBlizzardPlayerFrames(hide)
	local frame = getglobal("PlayerFrame")
	if hide then
		frame:Hide()
	else
		frame:Show()
	end
	--  Proper "hiding" should include these line as well
	--frame:UnregisterAllEvents()
	--getglobal("PartyMemberFrame" .. num .. "HealthBar"):UnregisterAllEvents()
	--getglobal("PartyMemberFrame" .. num .. "ManaBar"):UnregisterAllEvents()
	--frame:ClearAllPoints()
	--frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", 0, 50)
end
LPM_HideBlizzardPlayerFrames = HideBlizzardPlayerFrames

local function HideBlizzardPartyFrames(hide)
	--ShowPartyFrame = function() end  -- Hide Blizz stuff
	--HidePartyFrame = ShowPartyFrame
	if hide then
		for num = 1, 4 do
			if UnitInParty("party" .. num) then
				local frame = getglobal("PartyMemberFrame"..num)
				frame:Hide()
			end
		end
	else
		for num = 1, 4 do
			if UnitInParty("party" .. num) then
				local frame = getglobal("PartyMemberFrame"..num)
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
LPM_HideBlizzardPartyFrames = HideBlizzardPartyFrames

local function GetPartyUnitFrame(name)
	local frame = getglobal("LPM_TeamPartyFrame")
	local unitframe = nil
	for k,v in pairs(frame.partyunitframe) do
		if UnitName(k) == name then
			unitframe = v
			break
		end
	end

	return unitframe or nil
end

local function UpdatePartyXPBar2(frame)
	if not frame or not frame.unit then return end

	local unit_curr_xp, unit_max_xp, unit_rested_xp = 0, 0, 0
	if LPM_TeamTable[frame.unit] and LPM_TeamTable[frame.unit].curr_xp and LPM_TeamTable[frame.unit].max_xp then
		unit_curr_xp = LPM_TeamTable[frame.unit].curr_xp
		unit_max_xp = LPM_TeamTable[frame.unit].max_xp
		if LPM_TeamTable[frame.unit].rested_xp then
			unit_rested_xp = LPM_TeamTable[frame.unit].rested_xp
		end
	end

	local online = UnitIsConnected(frame.unit)
	local level = UnitLevel(frame.unit)

	if online and level > 0 and level < 60 then
		if unit_curr_xp == 0 and unit_max_xp == 0 then
			frame.fs_exp:SetText("NA/NA")
		else
			frame.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp)
		end
		
		frame.sb_restbar:SetMinMaxValues(0, unit_max_xp)
		if unit_rested_xp > 0 then
			frame.sb_restbar:SetValue(unit_curr_xp + unit_rested_xp)
		else
			frame.sb_restbar:SetValue(unit_curr_xp)
		end
		frame.sb_expbar:SetMinMaxValues(0, unit_max_xp)
		frame.sb_expbar:SetValue(unit_curr_xp)
		
	elseif online and level == 60 then
		frame.fs_exp:SetText("Done")
		frame.sb_restbar:SetMinMaxValues(0, 1)
		frame.sb_restbar:SetValue(0)
		frame.sb_expbar:SetMinMaxValues(0, 1)
		frame.sb_expbar:SetValue(1)

	else
		frame.fs_exp:SetText("NA/NA")
		frame.sb_restbar:SetMinMaxValues(0, 1)
		frame.sb_restbar:SetValue(0)
		frame.sb_expbar:SetMinMaxValues(0, 1)
		frame.sb_expbar:SetValue(0)
		
	end
end

local function UpdatePartyUnitFrame2(unit, frame)
	if not LPM_TeamTable[unit].party then return end
	if not UnitExists(unit) then return end

	local class
	_, class, _ = UnitClass(unit)
	
	local power
	power, _ = UnitPowerType(unit)
	
	local tClassCol
	if class and type(class) == 'string' then
		tClassCol = ClassColor[class][1]
	else 
		tClassCol = ClassColor["UNKNOWN"][1]
	end

	local tPowerCol
	if power and type(power) == 'number' then
		tPowerCol = PowerColor[power][1]
	else
		tPowerCol = PowerColor["UNKNOWN"][1]
	end

	local lvl = UnitLevel(unit)
	
	frame:SetBackdropColor(tClassCol[1], tClassCol[2], tClassCol[3], .35)
	
	frame.fs_name:SetText(LPM_TeamTable[unit].name)

	if lvl and type(lvl) == 'number' and lvl > 0 and lvl < 63 then
		frame.fs_level:SetText("Level " .. lvl)
	else
		frame.fs_level:SetText("Level ??")
	end

	local index = GetRaidTargetIndex(unit)
	if (index) then
		SetRaidTargetIconTexture(frame.icon_raid, index)
		frame.icon_raid:Show()
	else
		frame.icon_raid:Hide()
	end
	
	if UnitIsPartyLeader(unit) then
		frame.icon_leader:Show()
		if GetLootMethod() == 'group' then
			frame.icon_loot:Show()
		end
	else
		frame.icon_leader:Hide()
		frame.icon_loot:Hide()
	end

	local faction = UnitFactionGroup(unit)
	if UnitIsPVP(unit) then
		frame.icon_PVP:SetTexture("Interface\\TargetingFrame\\UI-PVP-" ..faction)
		frame.icon_PVP:Show()
	else
		frame.icon_PVP:Hide()
	end
	
	--[[
	if not UnitExists(frame.unit) or not UnitIsConnected(frame.unit) or not UnitIsVisible(frame.unit) then
		frame.portrait:SetModelScale(4.25)
		frame.portrait:SetPosition(0, 0, -1)
		frame.portrait:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
	else
		frame.portrait:SetUnit(frame.unit)
		frame.portrait:SetCamera(0)
		frame.portrait:Show()
	end
	]]

	--[[ Should we handle this with the proper event?? ]]
	local online = UnitIsConnected(unit)
	local health = UnitHealth(unit)
	if not online then
		--frame.sb_healthbar:SetStatusBarColor(tClassCol[1], tClassCol[2], tClassCol[3])
		frame.sb_healthbar:SetStatusBarColor(.1, .1, .1)
		frame.sb_healthbar:SetMinMaxValues(0, UnitHealthMax(unit))
		frame.sb_healthbar:SetValue(0)
		--frame.fs_health:SetText("0/" .. UnitHealthMax(unit))
		frame.fs_health:SetText("0%")
		
		frame.sb_powerbar:SetMinMaxValues(0, UnitManaMax(unit))
		frame.sb_powerbar:SetValue(0)
		frame.sb_healthbar:SetStatusBarColor(tPowerCol[1], tPowerCol[2], tPowerCol[3])
		frame.fs_power:SetText("0/" .. UnitManaMax(unit))
		
		frame.frame_offline:Show()

	elseif health < 2 then
		frame.sb_healthbar:SetStatusBarColor(.1, .1, .1)
		frame.sb_healthbar:SetMinMaxValues(0, UnitHealthMax(unit))
		frame.sb_healthbar:SetValue(0)
		frame.fs_health:SetText("DEAD")
	
		frame.sb_powerbar:SetStatusBarColor(.1, .1, .1)
		frame.sb_powerbar:SetMinMaxValues(0, UnitManaMax(unit))
		frame.sb_powerbar:SetValue(0)
		frame.fs_power:SetText("0/" .. UnitManaMax(unit))

		frame.frame_offline:Hide()

	else
		frame.sb_healthbar:SetStatusBarColor(tClassCol[1], tClassCol[2], tClassCol[3])
		frame.sb_healthbar:SetMinMaxValues(0, UnitHealthMax(unit))
		frame.sb_healthbar:SetValue(UnitHealth(unit))
		frame.fs_health:SetText(math.floor(UnitHealth(unit) * 100 / UnitHealthMax(unit)) .. "%")

		if power == 0 or power == 1 or power == 3 then
			frame.sb_powerbar:SetStatusBarColor(tPowerCol[1], tPowerCol[2], tPowerCol[3])
		else
			frame.sb_powerbar:SetStatusBarColor(0, 0, 0, .25)
		end
	
		frame.sb_powerbar:SetMinMaxValues(0, UnitManaMax(unit))
		frame.sb_powerbar:SetValue(UnitMana(unit))
		frame.fs_power:SetText(UnitMana(unit) .. "/" .. UnitManaMax(unit))

		frame.frame_offline:Hide()
	end
end

local function HandleUIAddonMessage(sender, msg)
	local n, command, v1, v2, v3, v4, v5, v6, v7, v8 = LPM_DataStringDecode(msg)
		if n < 1 then
			LPM_STATUS(" Addon Message - Not enough parameters received. Report the bug to the developers, please.")
			return
		end
		local frame = GetPartyUnitFrame(sender)
		if command == "lpm_slavefollow" then
			if v1 == "follow_start" then
				SlaveFollowFrame(true, frame)
			elseif v1 == "follow_end" then
				SlaveFollowFrame(false, frame)
			end
		elseif command == "lpm_ui_status" then
			if v1 == "combat_start" then
				SlaveCombatIcon(true, frame)
			elseif v1 == "combat_end" then
				SlaveCombatIcon(false, frame)
			elseif v1 == "rest_start" then
				SlaveRestIcon(true, frame)
			elseif v1 == "rest_end" then
				SlaveRestIcon(false, frame)
			end
		elseif command == "lpm_dataexp_normal_reply" then
			if sender ~= UnitName('player') then
				LPM_UpdateExp_Normal(sender, v1, v2)
			end
			UpdatePartyXPBar2(frame)
		elseif command == "lpm_dataexp_rested_reply" then
			if sender ~= UnitName('player') then
				LPM_UpdateExp_Rested(sender, v1)
			end
			UpdatePartyXPBar2(frame)
		end
end

local function TileTeamPartyUnitFrame2(hParent, sUnit)
	local n, x, y
	_, _, n = string.find(sUnit, "(%d+)")
	x = math.floor((LPM_UI_CONSTANT.TPF_FRAME_WIDTH - LPM_UI_CONSTANT.TPF_UNITFRAME_WIDTH) / 2)
	if n then
		y = -(LPM_UI_CONSTANT.TPF_FRAME_HEADER + (LPM_UI_CONSTANT.TPF_UNITFRAME_HEIGHT + LPM_UI_CONSTANT.TPF_UNITFRAME_PADDING) * n)
	else
		y = -(LPM_UI_CONSTANT.TPF_FRAME_HEADER)
	end

	local btn = CreateFrame("Button", "LPM_TeamPartyUnitFrame_" .. sUnit, hParent)

	if sUnit == 'player' then
		btn:SetPoint("TOPLEFT", hParent, "TOPLEFT", x, -(LPM_UI_CONSTANT.TPF_FRAME_HEADER))
	elseif sUnit == 'party1' then
		btn:SetPoint("TOPLEFT", hParent.partyunitframe['player'], "BOTTOMLEFT", 0, -(LPMULTIBOX_UI.TPF_PADDING))
	else
		btn:SetPoint("TOPLEFT", hParent.partyunitframe['party' .. n-1], "BOTTOMLEFT", 0, -(LPMULTIBOX_UI.TPF_PADDING))
	end

	btn:SetWidth(LPM_UI_CONSTANT.TPF_UNITFRAME_WIDTH)
	btn:SetHeight(LPM_UI_CONSTANT.TPF_UNITFRAME_HEIGHT)
	btn:EnableMouse(true)
	btn:RegisterForClicks("LeftButtonUp")
	btn:SetBackdrop({ 
		bgFile = LPM_UI_CONSTANT.TPF_UNITFRAME_BGFILE,
	})
	btn:SetBackdropColor(.1, .1, .1, .35)

	btn.unit = sUnit

	-------------------------------------------------------
	-- Button Background (Not used. Backdrop does the job)
	-------------------------------------------------------
	--[[
	local box_bg = btn:CreateTexture(nil, "BACKGROUND")
	box_bg:SetTexture(1, 1, 1, 1)
	--box_bg:SetBlendMode("BLEND")
	box_bg:SetBlendMode("ADD")
	box_bg:SetAllPoints()
		
	btn.box_bg = box_bg
	]]
	
	-------------------
	-- Offline Overlay
	-------------------
	local frame_offline = CreateFrame("Frame", nil, btn)
	frame_offline:SetFrameLevel(7)
	frame_offline:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
	frame_offline:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
	frame_offline:Hide()

	btn.frame_offline = frame_offline

	local box_offline = frame_offline:CreateTexture(nil, "BACKGROUND")
	box_offline:SetTexture(.1, .1, .1, .71)
	box_offline:SetBlendMode("BLEND")
	box_offline:SetAllPoints()
		
	btn.box_offline = box_offline

	local fs_offline = frame_offline:CreateFontString(nil, "ARTWORK")
	fs_offline:SetAllPoints()
	fs_offline:SetShadowColor(0, 0, 0)
	fs_offline:SetShadowOffset(0.8, -0.8)
	fs_offline:SetTextColor(.91, .91, .91)
	fs_offline:SetFont(LPM_UI_CONSTANT.TPF_UNITFRAME_FONT, 20)
	fs_offline:SetText("OFFLINE")
	
	btn.fs_offline = fs_offline

	------------------
	-- Follow Overlay
	------------------
	local frame_follow = CreateFrame("Frame", nil, btn)
	frame_follow:SetFrameLevel(5)
	frame_follow:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -3)
	frame_follow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, (btn:GetHeight()/2) + 3)
	frame_follow:Hide()

	btn.frame_follow = frame_follow

	local box_follow = frame_follow:CreateTexture(nil, "OVERLAY")
	box_follow:SetTexture(0.21, 0.17, 0.1, .81)
	box_follow:SetBlendMode("BLEND")
	box_follow:SetAllPoints()
		
	btn.box_follow = box_follow

	local fs_follow = frame_follow:CreateFontString(nil, "OVERLAY")
	fs_follow:SetAllPoints()
	fs_follow:SetShadowColor(0, 0, 0)
	fs_follow:SetShadowOffset(0.8, -0.8)
	fs_follow:SetFont(LPM_UI_CONSTANT.TPF_UNITFRAME_FONT, 12)
	fs_follow:SetText("NOT FOLLOWING")
	
	btn.fs_follow = fs_follow

	----------------
	-- Lost Overlay
	----------------
	local frame_lost = CreateFrame("Frame", nil, btn)
	frame_lost:SetFrameLevel(5)
	frame_lost:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -(btn:GetHeight()/2) + 3)
	frame_lost:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
	frame_lost:Hide()

	btn.frame_lost = frame_lost

	local box_lost = frame_lost:CreateTexture(nil, "OVERLAY")
	box_lost:SetTexture(.21, .1, .1, .81)
	box_lost:SetBlendMode("BLEND")
	box_lost:SetAllPoints()
		
	btn.box_lost = box_lost

	local fs_lost = frame_lost:CreateFontString(nil, "OVERLAY")
	fs_lost:SetAllPoints()
	fs_lost:SetShadowColor(0, 0, 0)
	fs_lost:SetShadowOffset(0.8, -0.8)
	fs_lost:SetFont(LPM_UI_CONSTANT.TPF_UNITFRAME_FONT, 20)
	fs_lost:SetText("LOST!")
	
	btn.fs_lost = fs_lost

	---------
	-- ICONS
	---------
	local frame_icon = CreateFrame("Frame", nil, btn)
	frame_icon:SetFrameLevel(3)
	frame_icon:SetAllPoints(btn)

	btn.frame_icon = frame_icon

	local icon_raid = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_raid:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	icon_raid:SetPoint("CENTER", frame_icon, "TOP", 0, -5)
	icon_raid:SetHeight(15)
	icon_raid:SetWidth(15)
	icon_raid:Hide()

	btn.icon_raid = icon_raid

	local icon_leader = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	icon_leader:SetPoint("CENTER", frame_icon, "TOPLEFT", 5, -2)
	icon_leader:SetHeight(14)
	icon_leader:SetWidth(14)
	icon_leader:Hide()

	btn.icon_leader = icon_leader

	local icon_loot = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
	icon_loot:SetPoint("CENTER", frame_icon, "TOPLEFT", 15, -2)
	icon_loot:SetHeight(10)
	icon_loot:SetWidth(10)
	icon_loot:Hide()

	btn.icon_loot = icon_loot

	local icon_PVP = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_PVP:SetPoint("CENTER", frame_icon, "RIGHT", 1, -1)
	icon_PVP:SetHeight(32)
    icon_PVP:SetWidth(32)
    icon_PVP:Hide()

    btn.icon_PVP = icon_PVP

	local icon_combat = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	icon_combat:SetTexCoord(0.5, 1, 0, 0.5)
	icon_combat:SetPoint("CENTER", frame_icon, "BOTTOMRIGHT", -3, 7)
	icon_combat:SetHeight(16)
	icon_combat:SetWidth(16)
	icon_combat:Hide()

	btn.icon_combat = icon_combat

	local icon_rest = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_rest:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	icon_rest:SetTexCoord(0, 0.5, 0, 0.421875)
	icon_rest:SetPoint("CENTER", frame_icon, "BOTTOMLEFT", 4, 5)
	icon_rest:SetHeight(16)
	icon_rest:SetWidth(16)
	icon_rest:Hide()
	
	btn.icon_rest = icon_rest

	------------
	-- Portrait
	------------
	--[[
	local box_portrait = btn:CreateTexture(nil, "BACKGROUND")
	box_portrait:SetTexture(.1, .1, .1, .75)
	box_portrait:SetBlendMode("BLEND")
	box_portrait:SetPoint("TOPLEFT", 3, -3)
	box_portrait:SetWidth(38)
	box_portrait:SetHeight(36)

	btn.box_portrait = box_portrait

	local portrait = CreateFrame("PlayerModel", nil, btn)
	portrait:SetPoint("TOPLEFT", 5, -5)
	portrait:SetWidth(36)
	portrait:SetHeight(34)
	portrait.type = "3D"
	portrait.unit = unit
	portrait:SetUnit(unit)
	
	btn.portrait = portrait
	]]

	-------------
	-- HealthBar
	-------------
	local box_healthbar = btn:CreateTexture(nil, "BACKGROUND")
	box_healthbar:SetTexture(.1, .1, .1, .75)
	box_healthbar:SetBlendMode("BLEND")
	box_healthbar:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
	box_healthbar:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
	box_healthbar:SetHeight(16)

	btn.box_healthbar = box_healthbar

	local sb_healthbar = CreateFrame("StatusBar", nil, btn)
	sb_healthbar:SetStatusBarTexture(LPM_UI_CONSTANT.TPF_UNITFRAME_SBFILE)
	sb_healthbar:SetStatusBarColor(.1, .1, .1, 1)
	sb_healthbar:SetPoint("TOPLEFT", box_healthbar, "TOPLEFT", 2, -2)
	sb_healthbar:SetPoint("BOTTOMRIGHT", box_healthbar, "BOTTOMRIGHT", -2, 1)

	btn.sb_healthbar = sb_healthbar

	local fs_name = sb_healthbar:CreateFontString(nil, "ARTWORK")
	fs_name:SetPoint("LEFT", btn.sb_healthbar, "LEFT", 3, 0)
	fs_name:SetJustifyH("LEFT")
	fs_name:SetShadowColor(0, 0, 0)
	fs_name:SetShadowOffset(0.8, -0.8)
	fs_name:SetTextColor(.91, .91, .91)
	fs_name:SetFont(LPM_UI_CONSTANT.TPF_UNITFRAME_FONT, 11)
	fs_name:SetText("")

	btn.fs_name = fs_name

	local fs_health = sb_healthbar:CreateFontString(nil, "ARTWORK")
	fs_health:SetPoint("RIGHT", btn.sb_healthbar, "RIGHT", -3, 0)
	fs_health:SetJustifyH("RIGHT")
	fs_health:SetShadowColor(0, 0, 0)
	fs_health:SetShadowOffset(0.8, -0.8)
	fs_health:SetTextColor(.91, .91, .91)
	fs_health:SetFont(LPM_UI_CONSTANT.TPF_UNITFRAME_FONT, 9)
	
	btn.fs_health = fs_health

	------------
	-- Powerbar
	------------
	local box_powerbar = btn:CreateTexture(nil, "BACKGROUND")
	box_powerbar:SetTexture(.1, .1, .1, .75)
	box_powerbar:SetBlendMode("BLEND")
	box_powerbar:SetPoint("TOPLEFT", btn.box_healthbar, "BOTTOMLEFT", 0, 0)
	box_powerbar:SetPoint("TOPRIGHT", btn.box_healthbar, "BOTTOMRIGHT", 0, 0)
	box_powerbar:SetHeight(11)

	btn.box_powerbar = box_powerbar

	local sb_powerbar = CreateFrame("StatusBar", nil, btn)
	sb_powerbar:SetStatusBarTexture(LPM_UI_CONSTANT.TPF_UNITFRAME_SBFILE)
	sb_powerbar:SetStatusBarColor(.1, .1, .1, 1)
	sb_powerbar:SetPoint("TOPLEFT", box_powerbar, "TOPLEFT", 2, -1)
	sb_powerbar:SetPoint("BOTTOMRIGHT", box_powerbar, "BOTTOMRIGHT", -2, 1)

	btn.sb_powerbar = sb_powerbar

	local fs_power = sb_powerbar:CreateFontString(nil, "ARTWORK")
	fs_power:SetPoint("RIGHT", btn.sb_powerbar, "RIGHT", -3, 1)
	fs_power:SetJustifyH("RIGHT")
	fs_power:SetShadowColor(0, 0, 0)
	fs_power:SetShadowOffset(0.8, -0.8)
	fs_power:SetTextColor(.91, .91, .91)
	fs_power:SetFont(LPM_UI_CONSTANT.TPF_UNITFRAME_FONT, 6)
	
	btn.fs_power = fs_power

	-----------------
	-- ExperienceBar
	-----------------
	local box_expbar = btn:CreateTexture(nil, "BACKGROUND")
	box_expbar:SetTexture(.1, .1, .1, .75)
	box_expbar:SetBlendMode("BLEND")
	box_expbar:SetPoint("TOPLEFT", btn.box_powerbar, "BOTTOMLEFT", 0, 0)
	box_expbar:SetPoint("TOPRIGHT", btn.box_powerbar, "BOTTOMRIGHT", 0, 0)
	box_expbar:SetHeight(11)

	btn.box_expbar = box_expbar

	local sb_expbar = CreateFrame("StatusBar", nil, btn)
	sb_expbar:SetStatusBarTexture(LPM_UI_CONSTANT.TPF_UNITFRAME_SBFILE)
	sb_expbar:SetStatusBarColor(0.0, 0.63, 0.13, 1.0)
	sb_expbar:SetPoint("TOPLEFT", box_expbar, "TOPLEFT", 2, -2)
	sb_expbar:SetPoint("BOTTOMRIGHT", box_expbar, "BOTTOMRIGHT", -2, 3)
	sb_expbar:SetFrameLevel(4)

	btn.sb_expbar = sb_expbar

	local sb_restbar = CreateFrame("StatusBar", nil, btn)
	sb_restbar:SetStatusBarTexture(LPM_UI_CONSTANT.TPF_UNITFRAME_SBFILE)
	sb_restbar:SetStatusBarColor(0.37, 0.37, 0.77, 1.0)
	sb_restbar:SetPoint("TOPLEFT", box_expbar, "TOPLEFT", 2, -3)
	sb_restbar:SetPoint("BOTTOMRIGHT", box_expbar, "BOTTOMRIGHT", -2, 4)
	sb_expbar:SetFrameLevel(3)

	btn.sb_restbar = sb_restbar

	---------------------------------------
	-- Info Frame. More infos on MouseOver
	---------------------------------------
	local frame_info = CreateFrame("Frame", nil, btn)
	frame_info:SetFrameLevel(3)
	frame_info:SetAllPoints(btn)
	frame_info:EnableMouse(true)
	
	btn.frame_info = frame_info

	local fs_level = frame_info:CreateFontString(nil, "ARTWORK")
	fs_level:SetPoint("LEFT", btn.sb_powerbar, "LEFT", 3, 1)
	fs_level:SetShadowColor(0, 0, 0)
	fs_level:SetShadowOffset(0.8, -0.8)
	fs_level:SetTextColor(.91, .91, .91)
	fs_level:SetFont(LPM_UI_CONSTANT.TPF_UNITFRAME_FONT, 7)
	fs_level:Hide()

	btn.fs_level = fs_level

	local fs_exp = frame_info:CreateFontString(nil, "ARTWORK")
	fs_exp:SetPoint("CENTER", btn.sb_expbar, "CENTER", -3, 1)
	fs_exp:SetShadowColor(0, 0, 0)
	fs_exp:SetShadowOffset(0.6, -0.6)
	fs_exp:SetTextColor(.91, .91, .91)
	fs_exp:SetFont(LPM_UI_CONSTANT.TPF_UNITFRAME_FONT, 6)

	btn.fs_exp = fs_exp

	----------
	-- Events
	----------
	btn:RegisterEvent("AUTOFOLLOW_BEGIN") -- arg1   following_unit
	btn:RegisterEvent("AUTOFOLLOW_END")

	btn:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entering Combat
	btn:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Exiting Combat
	btn:RegisterEvent("PLAYER_XP_UPDATE")
	btn:RegisterEvent("PLAYER_UPDATE_RESTING")

	btn:RegisterEvent("PARTY_MEMBER_DISABLE")
	btn:RegisterEvent("PARTY_MEMBER_ENABLE")

	btn:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	btn:RegisterEvent("UNIT_MODEL_CHANGED")
	btn:RegisterEvent("UNIT_LEVEL")
	btn:RegisterEvent("UNIT_HEALTH")
	btn:RegisterEvent("UNIT_MAXHEALTH")
	btn:RegisterEvent("UNIT_MANA")
	btn:RegisterEvent("UNIT_MAXMANA")
	btn:RegisterEvent("UNIT_RAGE")
	btn:RegisterEvent("UNIT_MAXRAGE")
	btn:RegisterEvent("UNIT_ENERGY")
	btn:RegisterEvent("UNIT_MAXENERGY")
	btn:RegisterEvent("UNIT_DISPLAYPOWER")
	btn:RegisterEvent("UNIT_FACTION")

	btn:RegisterEvent("RAID_TARGET_UPDATE")

	btn:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")

	btn:SetScript("OnEvent", function()
		if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
			if this.unit == arg1 then
				-- This prevents negative health
				if (UnitIsDead(this.unit) or UnitIsGhost(this.unit)) or UnitHealth(this.unit) < 2 then
					this.sb_healthbar:SetValue(0)
					--this.fs_health:SetText("DEAD")
				else
					this.sb_healthbar:SetMinMaxValues(0, UnitHealthMax(this.unit))
					this.sb_healthbar:SetValue(UnitHealth(this.unit))
					this.fs_health:SetText(math.floor(UnitHealth(this.unit) * 100 / UnitHealthMax(this.unit)) .. "%")
				end
			end

		elseif event == "UNIT_MANA" or event == "UNIT_MAXMANA" or 
				event == "UNIT_ENERGY" or event == "UNIT_MAXENERGY" or 
				event == "UNIT_RAGE" or event == "UNIT_MAXRAGE" then
			if this.unit == arg1 then
				if (UnitIsDead(this.unit) or UnitIsGhost(this.unit)) or (UnitHealth(this.unit) < 2 or not UnitIsConnected(this.unit)) then
					this.sb_powerbar:SetValue(0)
					this.fs_power:SetText("0/" .. UnitManaMax(this.unit))
				else
					this.sb_powerbar:SetMinMaxValues(0, UnitManaMax(this.unit))
					this.sb_powerbar:SetValue(UnitMana(this.unit))
					this.fs_power:SetText(UnitMana(this.unit) .. "/" .. UnitManaMax(this.unit))
				end
			end
			
		elseif event == "UNIT_DISPLAYPOWER" then
			if this.unit == arg1 then
				local power = UnitPowerType(arg1)
				local tPowerCol = PowerColor[power]
				this.tPowerColor = tPowerCol

				if powertype == 0 or powertype == 1 or powertype == 3 then
					this.sb_powerbar:SetStatusBarColor(tPowerCol[1], tPowerCol[2], tPowerCol[3])
					this.box_powerbar:SetVertexColor(tPowerCol[1], tPowerCol[2], tPowerCol[3], .25)
				else
					this.sb_powerbar:SetStatusBarColor(0, 0, 0, .25)
					this.box_powerbar:SetVertexColor(0, 0, 0, .25)
				end

				if (UnitHealth(this.unit) < 2 or not UnitIsConnected(this.unit)) then
					this.sb_powerbar:SetValue(0)
					this.fs_power:SetText("0/" .. UnitManaMax(this.unit))
				else
					this.sb_powerbar:SetMinMaxValues(0, UnitManaMax(this.unit))
					this.sb_powerbar:SetValue(UnitMana(this.unit))
					LPM_DEBUG(" -- UNIT_DISPLAYPOWER: " .. UnitMana(this.unit) .. "/" .. UnitManaMax(this.unit))
					local str = UnitMana(this.unit) .. "/" .. UnitManaMax(this.unit)
					this.fs_power:SetText(str)
				end
			end

		--[[
		elseif event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
			if arg1 == this.unit then
				if not UnitExists(arg1) or not UnitIsConnected(arg1) or not UnitIsVisible(arg1) then
					this.portrait:SetModelScale(4.25)
					this.portrait:SetPosition(0, 0, -1)
					this.portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
				else
					this.portrait:SetUnit(arg1)
					this.portrait:SetCamera(0)
				end
			end
		]]

		elseif event == "AUTOFOLLOW_BEGIN" then
			if this.unit == 'player' then
				LPM_DEBUG("  Sending \"Follow Start\"")
				local msg = LPM_DataStringEncode("lpm_slavefollow", "follow_start")
				SendAddonMessage("LPM_UI", msg, "RAID", name)
				this.frame_follow:Hide()
			end

		elseif event == "AUTOFOLLOW_END" then
			if this.unit == 'player' then
				LPM_DEBUG("  Sending \"Follow End\"")
				local msg = LPM_DataStringEncode("lpm_slavefollow", "follow_end")
				SendAddonMessage("LPM_UI", msg, "RAID", name)
				this.frame_follow:Show()
			end

		elseif event == "PLAYER_REGEN_DISABLED" then
			if this.unit == 'player' then
				if UnitAffectingCombat(this.unit) then
					SlaveCombatIcon(true, this)
					local msg = LPM_DataStringEncode("lpm_ui_status", "combat_start")
					SendAddonMessage("LPM_UI", msg, "Raid", name)
				end
			end

		elseif event == "PLAYER_REGEN_ENABLED" then
			if this.unit == 'player' then
				if not UnitAffectingCombat(this.unit) then
					SlaveCombatIcon(false, this)
					local msg = LPM_DataStringEncode("lpm_ui_status", "combat_end")
					SendAddonMessage("LPM_UI", msg, "Raid", name)
				end
			end
		
		elseif event == "PLAYER_XP_UPDATE" then
			if this.unit == 'player' then
				LPM_SendXPData()
			end

		elseif event == "PARTY_MEMBER_DISABLE" then
			local unit = 'party' .. GetPartyMember(arg1)
			if this.unit == unit then
				this.fs_health:SetText("0%")
				this.frame_follow:Hide()
				this.frame_lost:Hide()
				this.frame_offline:Show()
			end

		elseif event == "PARTY_MEMBER_ENABLE" then
			local unit = 'party' .. GetPartyMember(arg1)
			if this.unit == unit then
				frame.fs_health:SetText(math.floor(UnitHealth(this.unit) * 100 / UnitHealthMax(this.unit)) .. "%")
				this.frame_offline:Hide()
			end

		elseif event == "UNIT_LEVEL" then
			if this.unit == arg1 then
				local lvl = UnitLevel(this.unit)
				if type(lvl) == "number" then
					if lvl < 1 or lvl > 63 then
						this.fs_level:SetText("Level ??")
					else
						this.fs_level:SetText("Level " .. lvl)
					end
				end
			end
		
		elseif event == "UNIT_FACTION" then
			local unit = arg1
			local faction = UnitFactionGroup(unit)
			if this.unit == unit then
				if UnitIsPVP(unit) then
					this.icon_PVP:SetTexture("Interface\\TargetingFrame\\UI-PVP-" ..faction)
					this.icon_PVP:Show()
				else
					this.icon_PVP:Hide()
				end
			end

		elseif event == "PLAYER_UPDATE_RESTING" then
			if this.unit == 'player' then
				if IsResting() then
					this.icon_rest:Show()
					this.icon_combat:Hide()
					local msg = LPM_DataStringEncode("lpm_ui_status", "rest_start")
					SendAddonMessage("LPM_UI", msg, "Raid", name)
				else
					this.icon_rest:Hide()
					this.icon_combat:Hide()
					local msg = LPM_DataStringEncode("lpm_ui_status", "rest_end")
					SendAddonMessage("LPM_UI", msg, "Raid", name)
				end
			end

		elseif event == "PARTY_LOOT_METHOD_CHANGED" then
			if UnitIsPartyLeader(this.unit) then
				local lootmethod = GetLootMethod()
				if lootmethod == 'group' then
					this.icon_loot:Show()
				elseif lootmethod == 'freeforall' then
					this.icon_loot:Hide()
				end
			end

		end

	end)

	---------------------------
	-- PartyUnitFrame Handlers
	---------------------------
	btn:SetScript("OnClick", function()
		--[[ Click Handlers go here ]]
	end)

	btn.tick1 = 0
	btn:SetScript("OnUpdate", function()
		local time = GetTime()
		local leader = GetPartyLeaderIndex()
		if leader == 0 then
			leader = 'player'
		else
			leader = 'party' .. leader
		end
		if this.tick1 < time then
			this.tick1 = time + 2
			if leader == 'player' then
				if not UnitIsPartyLeader(this.unit) then
					if not CheckInteractDistance(this.unit, 4) and UnitIsConnected(this.unit) then
						this.frame_lost:Show()
					else
						this.frame_lost:Hide()
					end
				end
			else
				if this.unit == 'player' then
					if not CheckInteractDistance(leader, 4) and UnitIsConnected(leader) then
						this.frame_lost:Show()
					else
						this.frame_lost:Hide()
					end
				end
			end
		end
	end)

	frame_lost:SetScript("OnUpdate", function()
		local time = GetTime()
		--local t = math.abs(1 - (time - math.floor( time / 2) * 2)) + 0.35
		--local t = (math.sin(GetTime()) + 1) / 2
		--this:GetParent().fs_follow:SetVertexColor(t, t, t)
		local cr = (0.99 - 0.35) * math.abs(1 - (time - math.floor( time / 2) * 2)) + 0.35
		local cg = (0.15 - 0.11) * math.abs(1 - (time - math.floor( time / 2) * 2)) + 0.11
		local cb = (0.15 - 0.11) * math.abs(1 - (time - math.floor( time / 2) * 2)) + 0.11
		
		this:GetParent().fs_lost:SetVertexColor(cr, cg , cb)
	end)
	
	frame_follow:SetScript("OnUpdate", function()
		local time = GetTime()
		--local t = math.abs(1 - (time - math.floor( time / 2) * 2)) + 0.35
		--local t = (math.sin(GetTime()) + 1) / 2
		--this:GetParent().fs_follow:SetVertexColor(t, t, t)
		local cr = (0.99 - 0.35) * math.abs(1 - (time - math.floor( time / 2) * 2)) + 0.35
		local cg = (0.91 - 0.31) * math.abs(1 - (time - math.floor( time / 2) * 2)) + 0.31
		local cb = (0.15 - 0.11) * math.abs(1 - (time - math.floor( time / 2) * 2)) + 0.11
		
		this:GetParent().fs_follow:SetVertexColor(cr, cg , cb)
	end)

	frame_info:SetScript("OnEnter", function()
		local parent = this:GetParent()
		local unit_curr_xp, unit_max_xp, unit_rested_xp = 0, 0, 0
		if LPM_TeamTable[parent.unit] and
				type(LPM_TeamTable[parent.unit].curr_xp) == "number" and
				type(LPM_TeamTable[parent.unit].max_xp) == "number" then
			unit_curr_xp = LPM_TeamTable[parent.unit].curr_xp
			unit_max_xp = LPM_TeamTable[parent.unit].max_xp
			if type(LPM_TeamTable[parent.unit].rested_xp) == "number" then
				unit_rested_xp = LPM_TeamTable[parent.unit].rested_xp
			end
		end
		local online = UnitIsConnected(parent.unit)
		local level = UnitLevel(parent.unit)
		if online and level > 0 and level < 60 then
			if unit_rested_xp > 0 then
				parent.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp .. " (" ..( math.floor( unit_curr_xp / unit_max_xp * 10000) / 100 ) .. "%)" .. " + " .. unit_rested_xp)
			else
				parent.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp)
			end
			parent.fs_level:Show()
			parent.fs_exp:Show()
			local r, g, b, a = parent:GetBackdropColor()
			parent:SetBackdropColor(r, g, b, a + 0.15)
		elseif online and level == 60 then
			parent.fs_exp:SetText("Nothing to see here. Go farm somethin.")
			parent.fs_level:Show()
			local r, g, b, a = parent:GetBackdropColor()
			parent:SetBackdropColor(r, g, b, a + 0.15)
		end

		GameTooltip:SetOwner(this, "ANCHOR_CURSOR", 0, 35)
		GameTooltip:SetScale(.71)
		GameTooltip:SetBackdropColor(.01, .01, .01, .91)
		GameTooltip:SetUnit(this:GetParent().unit)
	end)

	frame_info:SetScript("OnLeave", function()
		local parent = this:GetParent()
		local unit_curr_xp, unit_max_xp= "NA", "NA"
		if LPM_TeamTable[parent.unit] and
				type(LPM_TeamTable[parent.unit].curr_xp) == "number" and
				type(LPM_TeamTable[parent.unit].max_xp) == "number" then
			unit_curr_xp = LPM_TeamTable[parent.unit].curr_xp
			unit_max_xp = LPM_TeamTable[parent.unit].max_xp
		end
		local online = UnitIsConnected(parent.unit)
		local level = UnitLevel(parent.unit)
		if online and level > 0 and level < 60 then
			parent.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp)
			parent.fs_level:Hide()
			local r, g, b, a = parent:GetBackdropColor()
			parent:SetBackdropColor(r, g, b, a - 0.15)
		elseif online and level == 60 then
			parent.fs_exp:SetText("Done")
			parent.fs_level:Hide()
			local r, g, b, a = parent:GetBackdropColor()
			parent:SetBackdropColor(r, g, b, a - 0.15)
		end

		GameTooltip:Hide()
	end)

	--[[
	btn.portrait:SetScript("OnShow", function()
		this:SetCamera(0)
	end)
	]]

	btn:Hide()

	return btn
end

local function UpdateTeamPartyFrame2()
	local frame = getglobal("LPM_TeamPartyFrame")

	local partymembers = GetNumPartyMembers()

	if partymembers == 0 then
		frame:Hide()
		return frame
	else
		local teamframe_partymembers_offsetH = (LPM_UI_CONSTANT.TPF_UNITFRAME_PADDING + LPM_UI_CONSTANT.TPF_UNITFRAME_HEIGHT) * partymembers
		frame:SetHeight(LPM_UI_CONSTANT.TPF_FRAME_HEADER + LPM_UI_CONSTANT.TPF_UNITFRAME_HEIGHT + LPM_UI_CONSTANT.TPF_FRAME_FOOTER + teamframe_partymembers_offsetH)
	end

	-- Let's fill the LPM_TeamTable table with infos!
	for i = 0, 4 do
	local unit
		if i == 0 then
			unit = 'player'
		else
			unit = 'party' .. i
		end

		if not LPM_TeamTable[unit] then LPM_TeamTable[unit] = {} end

		local name, english_class = nil, nil

		if UnitExists(unit) then
			LPM_TeamTable[unit].party = true
			name = UnitName(unit)
			if name and type(name) == "string" then
				LPM_TeamTable[unit].name = name
			else
				LPM_TeamTable[unit].name = "Unknown"
			end
		else
			LPM_TeamTable[unit].party = false
		end
	end

	-- Let's tile our Party TeamFrame
	for k,v in pairs(LPM_TeamTable) do
		if v.party then
			UpdatePartyUnitFrame2(k, frame.partyunitframe[k])
			UpdatePartyXPBar2(frame.partyunitframe[k])
			frame.partyunitframe[k]:Show()
		else
			frame.partyunitframe[k]:Hide()
		end
	end

	frame:Show()

	return frame
end

function LPM_CreateTeamPartyFrame2()
	LPM_UI_CONSTANT.TPF_UNITFRAME_PADDING = LPMULTIBOX_UI.TPF_PADDING
	LPM_UI_CONSTANT.TPF_FRAME_SCALE = LPMULTIBOX_UI.TPF_SCALE
	LPM_UI_CONSTANT.TPF_FRAME_BGALPHA = LPMULTIBOX_UI.TPF_BGALPHA

	-- Option Frame
	local frame = CreateFrame("Frame", "LPM_TeamPartyFrame")
	
	frame:SetScale(LPM_UI_CONSTANT.TPF_FRAME_SCALE)
		
	frame:SetWidth(LPM_UI_CONSTANT.TPF_FRAME_WIDTH)
	frame:SetHeight(LPM_UI_CONSTANT.TPF_FRAME_HEIGHT)
	
	frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -100, 110)
	frame:SetBackdrop( {
		bgFile = LPM_UI_CONSTANT.TPF_FRAME_BGFILE,
	});
	frame:SetBackdropColor(.01, .01, .01, LPM_UI_CONSTANT.TPF_FRAME_BGALPHA)

	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetUserPlaced(true)

	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	
	if LPMULTIBOX_UI.TPF_LOCK then
		frame:SetMovable(false)
		frame:RegisterForDrag()
	else
		frame:SetMovable(true)
		frame:RegisterForDrag("LeftButton")
	end

	if LPMULTIBOX_UI.TPF_SHOW then
		frame:Show()
	else
		frame:Hide()
	end

	-- MenuTitle FontString
	local fs_title = frame:CreateFontString(nil, "ARTWORK")
	fs_title:SetPoint("CENTER", frame, "TOP", 0, -5)
	fs_title:SetFont("Fonts\\ARIALN.TTF", 10)
	fs_title:SetTextColor(1, 1, 1, .37)
	fs_title:SetText("SomeWeird Team")

	frame.fs_title = fs_title

	-- Everytime a new member joins the party, 3 events are sent.
	--	PARTY_MEMBERS_CHANGED
	--	PARTY_LEADER_CHANGED
	--	RAID_TARGET_UPDATE
	-- Anyway, only after the "RAID_TARGET_UPDATE" group_functions are returning correct values.
	-- So, just "update" the party frame upon receiving such event.
	--
	-- Wait for debugging about "Raid" groups
	--

	frame:RegisterEvent("PARTY_LEADER_CHANGED")
	frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	frame:RegisterEvent("RAID_ROSTER_UPDATE")
	frame:RegisterEvent("RAID_TARGET_UPDATE")
	frame:RegisterEvent("CHAT_MSG_ADDON")

	--frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	--frame:RegisterEvent("PARTY_MEMBER_DISABLE")
	--frame:RegisterEvent("PARTY_MEMBER_ENABLE")

	frame:SetScript("OnEvent", function()
		if event == "CHAT_MSG_ADDON" then
			local prefix, msg, channel, sender = arg1, arg2, arg3, arg4
			if prefix == "LPM_UI" then
				HandleUIAddonMessage(sender, msg)
			end

		elseif event == "PARTY_MEMBERS_CHANGED" then
			LPM_DEBUG(" -- " .. event)
		elseif event == "PARTY_LEADER_CHANGED" then
			LPM_DEBUG(" -- " .. event)
		elseif event == "RAID_TARGET_UPDATE" then
			LPM_DEBUG(" -- " .. event)
			UpdateTeamPartyFrame2()
		
		elseif event == "RAID_ROSTER_UPDATE" then
			LPM_DEBUG(" -- " .. event .. " - arg1: " .. tostring(arg1) .. " - arg2: " .. tostring(arg2))
		
		end
	end)
	frame:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" and not this.isMoving then
			if this:IsMovable() then
				--this:SetFrameStrata("TOOLTIP")
				this:SetFrameStrata("FULLSCREEN_DIALOG")
				--this:SetFrameStrata("FULLSCREEN")
				--this:SetFrameStrata("DIALOG")
				this:SetBackdropColor(.31, .31, .31, LPMULTIBOX_UI.TPF_BGALPHA)
				this.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TPF_BGALPHA)
				this:StartMoving();
				this.isMoving = true;
			end
		end
	end)
	frame:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" and this.isMoving then
			this:StopMovingOrSizing();
			this:SetFrameStrata("MEDIUM")
			this:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TPF_BGALPHA)
			this.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TPF_BGALPHA)
			this.isMoving = false;
		end
	end)
	frame:SetScript("OnHide", function()
		if this.isMoving then
			this:StopMovingOrSizing();
			this:SetFrameStrata("MEDIUM")
			this.isMoving = false;
		end
	end)

	frame.partyunitframe = {}

	frame.partyunitframe['player'] = TileTeamPartyUnitFrame2(frame, 'player')
	frame.partyunitframe['party1'] = TileTeamPartyUnitFrame2(frame, 'party1')
	frame.partyunitframe['party2'] = TileTeamPartyUnitFrame2(frame, 'party2')
	frame.partyunitframe['party3'] = TileTeamPartyUnitFrame2(frame, 'party3')
	frame.partyunitframe['party4'] = TileTeamPartyUnitFrame2(frame, 'party4')

	frame:Hide()

	if GetNumPartyMembers() > 0 then
		UpdateTeamPartyFrame2()
	end

	return frame
end

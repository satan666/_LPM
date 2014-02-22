
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

local function Member_FollowFrame(follow, frame)
	if follow then
		frame.frame_follow:Hide()
	else
		frame.frame_follow:Show()
	end
end

local function Member_LostFrame(lost, frame)
	if lost then
		frame.frame_lost:Hide()
	else
		frame.frame_lost:Show()
	end
end

local function Member_CombatIcon(combat, frame)
	if combat then
		frame.icon_combat:Show()
	else
		frame.icon_combat:Hide()
	end
end

local function Member_RestIcon(rest, frame)
	if rest then
		frame.icon_rest:Show()
	else
		frame.icon_rest:Hide()
	end
end

local function Member_UpdateXPBar(frame)
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

local function Member_UpdateUnitFrame(unit, frame)
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

local function PartyFrame_GetUnitFrame(name)
	local frame = getglobal("LPM_PartyFrame")
	local unitframe = nil
	for k,v in pairs(frame.unitframe) do
		if UnitName(k) == name then
			unitframe = v
			break
		end
	end

	return unitframe or nil
end

local function HandleUIAddonMessage(sender, msg)
	local n, command, v1, v2, v3, v4, v5, v6, v7, v8 = LPM_DataStringDecode(msg)
		if n < 1 then
			LPM_STATUS(" Addon Message - Not enough parameters received. Report the bug to the developers, please.")
			return
		end
		local frame = PartyFrame_GetUnitFrame(sender)
		if command == "lpm_slavefollow" then
			if v1 == "follow_start" then
				Member_FollowFrame(true, frame)
			elseif v1 == "follow_end" then
				Member_FollowFrame(false, frame)
			end
		elseif command == "lpm_ui_status" then
			if v1 == "combat_start" then
				Member_CombatIcon(true, frame)
			elseif v1 == "combat_end" then
				Member_CombatIcon(false, frame)
			elseif v1 == "rest_start" then
				Member_RestIcon(true, frame)
			elseif v1 == "rest_end" then
				Member_RestIcon(false, frame)
			end
		elseif command == "lpm_dataexp_normal_reply" then
			if sender ~= UnitName('player') then
				LPM_UpdateExp_Normal(sender, v1, v2)
			end
			Member_UpdateXPBar(frame)
		elseif command == "lpm_dataexp_rested_reply" then
			if sender ~= UnitName('player') then
				LPM_UpdateExp_Rested(sender, v1)
			end
			Member_UpdateXPBar(frame)
		end
end

local function PartyFrame_Update(frame)
	local partymembers = GetNumPartyMembers()

	local player_offsetH = LPM_UI_SETTINGS.UNITFRAME.HEIGHT
	local partyframe_decorationH = LPM_UI_SETTINGS.PARTYFRAME.HEADER + LPM_UI_SETTINGS.PARTYFRAME.FOOTER
	local partymembers_offsetH = (LPMULTIBOX_UI.TUI_PADDING + LPM_UI_SETTINGS.UNITFRAME.HEIGHT) * partymembers
	
	frame:SetHeight(player_offsetH + partyframe_decorationH + partymembers_offsetH)

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
			Member_UpdateUnitFrame(k, frame.unitframe[k])
			Member_UpdateXPBar(frame.unitframe[k])
			frame.unitframe[k]:Show()
		else
			frame.unitframe[k]:Hide()
		end
	end
end

local function PartyFrame_UnitFrame(hParent, sUnit)
	-- offset calculation for every party member
	local n, offset_x, offset_y
	_, _, n = string.find(sUnit, "(%d+)")
	offset_x = math.floor((LPM_UI_SETTINGS.PARTYFRAME.WIDTH - LPM_UI_SETTINGS.UNITFRAME.WIDTH) / 2)
	if n then
		offset_y = -(LPMULTIBOX_UI.TUI_PADDING)
	else
		offset_y = -(LPM_UI_SETTINGS.PARTYFRAME.HEADER)
	end

	local frame = CreateFrame("Button", "LPM_PartyUnitFrame_" .. sUnit, hParent)
	frame.unit = sUnit
	frame.parent = hParent -- frame:GetParent()

	if frame.unit == 'player' then
		frame:SetPoint("TOPLEFT", frame.parent, "TOPLEFT", offset_x, offset_y)
	elseif frame.unit == 'party1' then
		frame:SetPoint("TOPLEFT", frame.parent.unitframe['player'], "BOTTOMLEFT", 0, offset_y)
	else
		frame:SetPoint("TOPLEFT", frame.parent.unitframe['party' .. n-1], "BOTTOMLEFT", 0, offset_y)
	end

	frame:SetWidth(LPM_UI_SETTINGS.UNITFRAME.WIDTH)
	frame:SetHeight(LPM_UI_SETTINGS.UNITFRAME.HEIGHT)
	frame:EnableMouse(true)
	frame:RegisterForClicks("LeftButtonUp")
	frame:SetBackdrop({ 
		bgFile = LPM_UI_SETTINGS.BG_TEXTURE_FILE,
	})
	frame:SetBackdropColor(.1, .1, .1, .37)

	-----------------
	-- DropdDownMenu
	-----------------
	local dropdown = CreateFrame("Frame", "LPM_PartyDropDown_" .. frame.unit, frame, "UIDropDownMenuTemplate")
	
	local function DropDown_Init()
		local unit = frame.unit
		
		if unit == 'player' then
			UnitPopup_ShowMenu(dropdown, "SELF" , unit)
		else
			if dropdown then
				UnitPopup_ShowMenu(dropdown, "PARTY", unit)
			elseif UIDROPDOWNMENU_OPEN_MENU then
				UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "PARTY", getglobal(UIDROPDOWNMENU_OPEN_MENU):GetParent().unit)
			end
		end
		
	end
	
	UIDropDownMenu_Initialize(dropdown, DropDown_Init, "MENU")

	frame.dropdown = dropdown

	-------------------
	-- Offline Overlay
	-------------------
	local frame_offline = CreateFrame("Frame", nil, frame)
	frame_offline:SetFrameLevel(7)
	frame_offline:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
	frame_offline:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
	frame_offline:Hide()

	frame.frame_offline = frame_offline

	local box_offline = frame_offline:CreateTexture(nil, "BACKGROUND")
	box_offline:SetTexture(.1, .1, .1, .71)
	box_offline:SetBlendMode("BLEND")
	box_offline:SetAllPoints()
		
	frame.box_offline = box_offline

	local fs_offline = frame_offline:CreateFontString(nil, "ARTWORK")
	fs_offline:SetAllPoints()
	fs_offline:SetShadowColor(0, 0, 0)
	fs_offline:SetShadowOffset(0.8, -0.8)
	fs_offline:SetTextColor(.91, .91, .91)
	fs_offline:SetFont(LPM_UI_SETTINGS.FONT_FILE, 20)
	fs_offline:SetText("OFFLINE")
	
	frame.fs_offline = fs_offline

	------------------
	-- Follow Overlay
	------------------
	local frame_follow = CreateFrame("Frame", nil, frame)
	frame_follow:SetFrameLevel(5)
	frame_follow:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -3)
	frame_follow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, (frame:GetHeight()/2) + 3)
	frame_follow:Hide()

	frame.frame_follow = frame_follow

	local box_follow = frame_follow:CreateTexture(nil, "OVERLAY")
	box_follow:SetTexture(0.21, 0.17, 0.1, .81)
	box_follow:SetBlendMode("BLEND")
	box_follow:SetAllPoints()
		
	frame.box_follow = box_follow

	local fs_follow = frame_follow:CreateFontString(nil, "OVERLAY")
	fs_follow:SetAllPoints()
	fs_follow:SetShadowColor(0, 0, 0)
	fs_follow:SetShadowOffset(0.8, -0.8)
	fs_follow:SetFont(LPM_UI_SETTINGS.FONT_FILE, 12)
	fs_follow:SetText("NOT FOLLOWING")
	
	frame.fs_follow = fs_follow

	----------------
	-- Lost Overlay
	----------------
	local frame_lost = CreateFrame("Frame", nil, frame)
	frame_lost:SetFrameLevel(5)
	frame_lost:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -(frame:GetHeight()/2) + 3)
	frame_lost:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
	frame_lost:Hide()

	frame.frame_lost = frame_lost

	local box_lost = frame_lost:CreateTexture(nil, "OVERLAY")
	box_lost:SetTexture(.21, .1, .1, .81)
	box_lost:SetBlendMode("BLEND")
	box_lost:SetAllPoints()
		
	frame.box_lost = box_lost

	local fs_lost = frame_lost:CreateFontString(nil, "OVERLAY")
	fs_lost:SetAllPoints()
	fs_lost:SetShadowColor(0, 0, 0)
	fs_lost:SetShadowOffset(0.8, -0.8)
	fs_lost:SetFont(LPM_UI_SETTINGS.FONT_FILE, 20)
	fs_lost:SetText("LOST!")
	
	frame.fs_lost = fs_lost

	---------
	-- ICONS
	---------
	local frame_icon = CreateFrame("Frame", nil, frame)
	frame_icon:SetFrameLevel(3)
	frame_icon:SetAllPoints(frame)

	frame.frame_icon = frame_icon

	local icon_raid = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_raid:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	icon_raid:SetPoint("CENTER", frame_icon, "TOP", 0, -5)
	icon_raid:SetHeight(15)
	icon_raid:SetWidth(15)
	icon_raid:Hide()

	frame.icon_raid = icon_raid

	local icon_leader = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	icon_leader:SetPoint("CENTER", frame_icon, "TOPLEFT", 5, -2)
	icon_leader:SetHeight(14)
	icon_leader:SetWidth(14)
	icon_leader:Hide()

	frame.icon_leader = icon_leader

	local icon_loot = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
	icon_loot:SetPoint("CENTER", frame_icon, "TOPLEFT", 15, -2)
	icon_loot:SetHeight(10)
	icon_loot:SetWidth(10)
	icon_loot:Hide()

	frame.icon_loot = icon_loot

	local icon_PVP = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_PVP:SetPoint("CENTER", frame_icon, "RIGHT", 1, -1)
	icon_PVP:SetHeight(32)
    icon_PVP:SetWidth(32)
    icon_PVP:Hide()

    frame.icon_PVP = icon_PVP

	local icon_combat = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	icon_combat:SetTexCoord(0.5, 1, 0, 0.5)
	icon_combat:SetPoint("CENTER", frame_icon, "BOTTOMRIGHT", -3, 7)
	icon_combat:SetHeight(16)
	icon_combat:SetWidth(16)
	icon_combat:Hide()

	frame.icon_combat = icon_combat

	local icon_rest = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_rest:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	icon_rest:SetTexCoord(0, 0.5, 0, 0.421875)
	icon_rest:SetPoint("CENTER", frame_icon, "BOTTOMLEFT", 4, 5)
	icon_rest:SetHeight(16)
	icon_rest:SetWidth(16)
	icon_rest:Hide()
	
	frame.icon_rest = icon_rest

	-------------
	-- HealthBar
	-------------
	local box_healthbar = frame:CreateTexture(nil, "BACKGROUND")
	box_healthbar:SetTexture(.1, .1, .1, .75)
	box_healthbar:SetBlendMode("BLEND")
	box_healthbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
	box_healthbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
	box_healthbar:SetHeight(16)

	frame.box_healthbar = box_healthbar

	local sb_healthbar = CreateFrame("StatusBar", nil, frame)
	sb_healthbar:SetStatusBarTexture(LPM_UI_SETTINGS.STATUSBAR_TEXTURE_FILE)
	sb_healthbar:SetStatusBarColor(.1, .1, .1, 1)
	sb_healthbar:SetPoint("TOPLEFT", box_healthbar, "TOPLEFT", 2, -2)
	sb_healthbar:SetPoint("BOTTOMRIGHT", box_healthbar, "BOTTOMRIGHT", -2, 1)

	frame.sb_healthbar = sb_healthbar

	local fs_name = sb_healthbar:CreateFontString(nil, "ARTWORK")
	fs_name:SetPoint("LEFT", frame.sb_healthbar, "LEFT", 3, 0)
	fs_name:SetJustifyH("LEFT")
	fs_name:SetShadowColor(0, 0, 0)
	fs_name:SetShadowOffset(0.8, -0.8)
	fs_name:SetTextColor(.91, .91, .91)
	fs_name:SetFont(LPM_UI_SETTINGS.FONT_FILE, 11)
	fs_name:SetText("")

	frame.fs_name = fs_name

	local fs_health = sb_healthbar:CreateFontString(nil, "ARTWORK")
	fs_health:SetPoint("RIGHT", frame.sb_healthbar, "RIGHT", -3, 0)
	fs_health:SetJustifyH("RIGHT")
	fs_health:SetShadowColor(0, 0, 0)
	fs_health:SetShadowOffset(0.8, -0.8)
	fs_health:SetTextColor(.91, .91, .91)
	fs_health:SetFont(LPM_UI_SETTINGS.FONT_FILE, 9)
	
	frame.fs_health = fs_health

	------------
	-- Powerbar
	------------
	local box_powerbar = frame:CreateTexture(nil, "BACKGROUND")
	box_powerbar:SetTexture(.1, .1, .1, .75)
	box_powerbar:SetBlendMode("BLEND")
	box_powerbar:SetPoint("TOPLEFT", frame.box_healthbar, "BOTTOMLEFT", 0, 0)
	box_powerbar:SetPoint("TOPRIGHT", frame.box_healthbar, "BOTTOMRIGHT", 0, 0)
	box_powerbar:SetHeight(11)

	frame.box_powerbar = box_powerbar

	local sb_powerbar = CreateFrame("StatusBar", nil, frame)
	sb_powerbar:SetStatusBarTexture(LPM_UI_SETTINGS.STATUSBAR_TEXTURE_FILE)
	sb_powerbar:SetStatusBarColor(.1, .1, .1, 1)
	sb_powerbar:SetPoint("TOPLEFT", box_powerbar, "TOPLEFT", 2, -1)
	sb_powerbar:SetPoint("BOTTOMRIGHT", box_powerbar, "BOTTOMRIGHT", -2, 1)

	frame.sb_powerbar = sb_powerbar

	local fs_power = sb_powerbar:CreateFontString(nil, "ARTWORK")
	fs_power:SetPoint("RIGHT", frame.sb_powerbar, "RIGHT", -3, 1)
	fs_power:SetJustifyH("RIGHT")
	fs_power:SetShadowColor(0, 0, 0)
	fs_power:SetShadowOffset(0.8, -0.8)
	fs_power:SetTextColor(.91, .91, .91)
	fs_power:SetFont(LPM_UI_SETTINGS.FONT_FILE, 6)
	
	frame.fs_power = fs_power

	-----------------
	-- ExperienceBar
	-----------------
	local box_expbar = frame:CreateTexture(nil, "BACKGROUND")
	box_expbar:SetTexture(.1, .1, .1, .75)
	box_expbar:SetBlendMode("BLEND")
	box_expbar:SetPoint("TOPLEFT", frame.box_powerbar, "BOTTOMLEFT", 0, 0)
	box_expbar:SetPoint("TOPRIGHT", frame.box_powerbar, "BOTTOMRIGHT", 0, 0)
	box_expbar:SetHeight(11)

	frame.box_expbar = box_expbar

	local sb_expbar = CreateFrame("StatusBar", nil, frame)
	sb_expbar:SetStatusBarTexture(LPM_UI_SETTINGS.STATUSBAR_TEXTURE_FILE)
	sb_expbar:SetStatusBarColor(0.0, 0.63, 0.13, 1.0)
	sb_expbar:SetPoint("TOPLEFT", box_expbar, "TOPLEFT", 2, -2)
	sb_expbar:SetPoint("BOTTOMRIGHT", box_expbar, "BOTTOMRIGHT", -2, 3)
	sb_expbar:SetFrameLevel(4)

	frame.sb_expbar = sb_expbar

	local sb_restbar = CreateFrame("StatusBar", nil, frame)
	sb_restbar:SetStatusBarTexture(LPM_UI_SETTINGS.STATUSBAR_TEXTURE_FILE)
	sb_restbar:SetStatusBarColor(0.37, 0.37, 0.77, 1.0)
	sb_restbar:SetPoint("TOPLEFT", box_expbar, "TOPLEFT", 2, -3)
	sb_restbar:SetPoint("BOTTOMRIGHT", box_expbar, "BOTTOMRIGHT", -2, 4)
	sb_expbar:SetFrameLevel(3)

	frame.sb_restbar = sb_restbar

	---------------------------------------
	-- Info Frame. More infos on MouseOver
	---------------------------------------
	local frame_info = CreateFrame("Frame", nil, frame)
	frame_info:SetFrameLevel(3)
	frame_info:SetAllPoints(frame)
	frame_info:EnableMouse(true)
	
	frame.frame_info = frame_info

	local fs_level = frame_info:CreateFontString(nil, "ARTWORK")
	fs_level:SetPoint("LEFT", frame.sb_powerbar, "LEFT", 3, 1)
	fs_level:SetShadowColor(0, 0, 0)
	fs_level:SetShadowOffset(0.8, -0.8)
	fs_level:SetTextColor(.91, .91, .91)
	fs_level:SetFont(LPM_UI_SETTINGS.FONT_FILE, 7)
	fs_level:Hide()

	frame.fs_level = fs_level

	local fs_exp = frame_info:CreateFontString(nil, "ARTWORK")
	fs_exp:SetPoint("CENTER", frame.sb_expbar, "CENTER", -3, 1)
	fs_exp:SetShadowColor(0, 0, 0)
	fs_exp:SetShadowOffset(0.6, -0.6)
	fs_exp:SetTextColor(.91, .91, .91)
	fs_exp:SetFont(LPM_UI_SETTINGS.FONT_FILE, 6)

	frame.fs_exp = fs_exp

	----------
	-- Events
	----------
	frame:RegisterEvent("AUTOFOLLOW_BEGIN") -- arg1   following_unit
	frame:RegisterEvent("AUTOFOLLOW_END")

	frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entering Combat
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Exiting Combat
	frame:RegisterEvent("PLAYER_XP_UPDATE")
	frame:RegisterEvent("PLAYER_UPDATE_RESTING")

	frame:RegisterEvent("PARTY_MEMBER_DISABLE")
	frame:RegisterEvent("PARTY_MEMBER_ENABLE")

	frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	frame:RegisterEvent("UNIT_MODEL_CHANGED")
	frame:RegisterEvent("UNIT_LEVEL")
	frame:RegisterEvent("UNIT_HEALTH")
	frame:RegisterEvent("UNIT_MAXHEALTH")
	frame:RegisterEvent("UNIT_MANA")
	frame:RegisterEvent("UNIT_MAXMANA")
	frame:RegisterEvent("UNIT_RAGE")
	frame:RegisterEvent("UNIT_MAXRAGE")
	frame:RegisterEvent("UNIT_ENERGY")
	frame:RegisterEvent("UNIT_MAXENERGY")
	frame:RegisterEvent("UNIT_DISPLAYPOWER")
	frame:RegisterEvent("UNIT_FACTION")

	frame:RegisterEvent("RAID_TARGET_UPDATE")

	frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")

	frame:SetScript("OnEvent", function()
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
					this.fs_power:SetText(UnitMana(this.unit) .. "/" .. UnitManaMax(this.unit))
				end
			end

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
					Member_CombatIcon(true, this)
					local msg = LPM_DataStringEncode("lpm_ui_status", "combat_start")
					SendAddonMessage("LPM_UI", msg, "Raid", name)
				end
			end

		elseif event == "PLAYER_REGEN_ENABLED" then
			if this.unit == 'player' then
				if not UnitAffectingCombat(this.unit) then
					Member_CombatIcon(false, this)
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
				--Member_FollowFrame(false, this)
				this.frame_follow:Hide()
				--Member_LostFrame(false, this)
				this.frame_lost:Hide()
				this.frame_offline:Show()
			end

		elseif event == "PARTY_MEMBER_ENABLE" then
			local unit = 'party' .. GetPartyMember(arg1)
			if this.unit == unit then
				this.fs_health:SetText(math.floor(UnitHealth(this.unit) * 100 / UnitHealthMax(this.unit)) .. "%")
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
					--Member_RestIcon(true, this)
					--Member_CombatIcon(false, this)
					this.icon_rest:Show()
					this.icon_combat:Hide()
					local msg = LPM_DataStringEncode("lpm_ui_status", "rest_start")
					SendAddonMessage("LPM_UI", msg, "Raid", name)
				else
					--Member_RestIcon(false, this)
					--Member_CombatIcon(false, this)
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
	frame:SetScript("OnClick", function()
		--[[ frame_info, being on top of this, will fire a Click() function on this frame]]

		local unit = this.unit
		if SpellIsTargeting() and arg1 == "RightButton" then
			SpellStopTargeting()
			return
		end
		if arg1 == "LeftButton" then
			if SpellIsTargeting() then
				SpellTargetUnit(unit)
			elseif CursorHasItem() then
				if unit == 'player' then
					AutoEquipCursorItem()
				else
					DropItemOnUnit(unit)
				end
			else
				TargetUnit(unit)
			end
		elseif not (IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown()) then
			ToggleDropDownMenu(1, nil, this.dropdown, "cursor", 0, 0)
			if unit == 'player' and UnitIsPartyLeader("player") then
				local info = {text = "Reset Instances", func = ResetInstances, notCheckable = 1}
				UIDropDownMenu_AddButton(info, 1)
			end
		end

	end)

	frame.tick1 = 0
	frame:SetScript("OnUpdate", function()
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
						--Member_LostFrame(true, this)
						this.frame_lost:Show()

					else
						--Member_LostFrame(false, this)
						this.frame_lost:Hide()
					end
				end
			else
				if this.unit == 'player' then
					if not CheckInteractDistance(leader, 4) and UnitIsConnected(leader) then
						--Member_LostFrame(true, this)
						this.frame_lost:Show()
					else
						--Member_LostFrame(false, this)
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

		--[[
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 15, -46)
		GameTooltip:SetScale(.71)
		GameTooltip:SetBackdropColor(.01, .01, .01, .91)
		GameTooltip:SetUnit(this:GetParent().unit)
		]]
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

		--[[
		GameTooltip:Hide()
		]]
	end)

	frame_info:SetScript("OnMouseDown", function()
		-- let's transfer the click to the UnitFrame
		-- (standing lower than this frame, this should be the only way to click the UnitFrame)
		this:GetParent():Click(arg1)
	end)

	frame:Hide()

	return frame
end

local function PartyFrame_Header()
	-- PartyFrame Header
	local frame = CreateFrame("Frame", "LPM_PartyFrame")

	frame:SetScale(LPMULTIBOX_UI.TUI_SCALE)
	
	frame:SetWidth(LPM_UI_SETTINGS.PARTYFRAME.WIDTH)
	frame:SetHeight(LPM_UI_SETTINGS.PARTYFRAME.HEIGHT)
	
	--frame:SetPoint("BOTTOMLEFT", 100, -110)
	frame:SetPoint("BOTTOMLEFT", LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.LEFT, LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.BOTTOM)

	frame:SetBackdrop( {
		bgFile = LPM_UI_SETTINGS.BG_TEXTURE_FILE
	});
	frame:SetBackdropColor(.01, .01, .01, LPMULTIBOX_UI.TUI_BGALPHA)

	if LPMULTIBOX_UI.TUI_PARTYFRAME_LOCK then
		frame:SetMovable(false)
		frame:RegisterForDrag()
	else
		frame:SetMovable(true)
		frame:RegisterForDrag("LeftButton")
	end
	--frame:SetMovable(true)
	--frame:RegisterForDrag("LeftButton")

	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	--frame:SetUserPlaced(true)



	-- PartyFrame FontString
	local fs_title = frame:CreateFontString(nil, "ARTWORK")
	fs_title:SetPoint("CENTER", frame, "TOP", 0, -5)
	fs_title:SetFont(LPM_UI_SETTINGS.FONT_FILE, 7)
	fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
	fs_title:SetText("Wierd Party Frame")

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
			PartyFrame_Update(this)
		
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
				if UnitFactionGroup('player') == "Horde" then
					this:SetBackdropColor(.17, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					this.fs_title:SetTextColor(1, .71, .71, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					if LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and LPMULTIBOX_UI.TUI_PARTYPETFRAME_ATTACH then
						local partypetframe = getglobal("LPM_PartyPetFrame")
						partypetframe:SetFrameStrata("FULLSCREEN_DIALOG")
						partypetframe:SetBackdropColor(.17, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						partypetframe.fs_title:SetTextColor(1, .71, .71, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					end
				else
					this:SetBackdropColor(.17, .17, .37, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					this.fs_title:SetTextColor(.71, .71, 1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					if LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and LPMULTIBOX_UI.TUI_PARTYPETFRAME_ATTACH then
						local partypetframe = getglobal("LPM_PartyPetFrame")
						partypetframe:SetFrameStrata("FULLSCREEN_DIALOG")
						partypetframe:SetBackdropColor(.17, .17, .37, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						partypetframe.fs_title:SetTextColor(.71, .71, 1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					end
				end
				this:StartMoving()
				this.isMoving = true
			end
		end
	end)
	frame:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" and this.isMoving then
			this:StopMovingOrSizing()
			this:SetFrameStrata("MEDIUM")
			this:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
			this.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
			this.isMoving = false
			local left = this:GetLeft()
			local bottom = this:GetBottom()
			LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.LEFT = floor(left + 0.5)
			LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.BOTTOM = floor(bottom + 0.5)
			if LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and LPMULTIBOX_UI.TUI_PARTYPETFRAME_ATTACH then
				local partypetframe = getglobal("LPM_PartyPetFrame")
				partypetframe:SetFrameStrata("MEDIUM")
				partypetframe:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
				partypetframe.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
				local left = partypetframe:GetLeft()
				local bottom = partypetframe:GetBottom()
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.LEFT = floor(left + 0.5)
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.BOTTOM = floor(bottom + 0.5)
			end

		end
	end)
	frame:SetScript("OnHide", function()
		if this.isMoving then
			this:StopMovingOrSizing()
			this:SetFrameStrata("MEDIUM")
			this:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
			this.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
			this.isMoving = false
			local left = this:GetLeft()
			local bottom = this:GetBottom()
			LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.LEFT = floor(left + 0.5)
			LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.BOTTOM = floor(bottom + 0.5)
			if LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and LPMULTIBOX_UI.TUI_PARTYPETFRAME_ATTACH then
				local partypetframe = getglobal("LPM_PartyPetFrame")
				partypetframe:SetFrameStrata("MEDIUM")
				partypetframe:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
				partypetframe.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
				local left = partypetframe:GetLeft()
				local bottom = partypetframe:GetBottom()
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.LEFT = floor(left + 0.5)
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.BOTTOM = floor(bottom + 0.5)
			end

		end
	end)

	return frame
end

function LPM_PartyFrame_Init(frame)

	if frame then 
		if frame.GetFrameType then
			frame:SetParent(nil)
		end
	end
	frame = {}

	frame = PartyFrame_Header()

	frame.unitframe = {}
	frame.unitframe['player'] = PartyFrame_UnitFrame(frame, 'player')
	frame.unitframe['party1'] = PartyFrame_UnitFrame(frame, 'party1')
	frame.unitframe['party2'] = PartyFrame_UnitFrame(frame, 'party2')
	frame.unitframe['party3'] = PartyFrame_UnitFrame(frame, 'party3')
	frame.unitframe['party4'] = PartyFrame_UnitFrame(frame, 'party4')

	PartyFrame_Update(frame)

	return frame
end

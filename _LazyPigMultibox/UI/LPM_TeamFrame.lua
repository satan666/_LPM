local ClassColorName = {
	["UNKNOWN"]	= { {0.51, 	0.51, 	0.51 }, "UNKNOWN" },
	["DRUID"]	= { {1.00, 	0.49, 	0.04 }, "Druid"   },
	["HUNTER"]	= { {0.67, 	0.83, 	0.45 }, "Hunter"  },
	["MAGE"]	= { {0.41, 	0.80, 	0.94 }, "Mage"    },
	["PALADIN"]	= { {0.96, 	0.55, 	0.73 }, "Paladin" },
	["PRIEST"]	= { {1.00, 	1.00, 	1.00 }, "Priest"  },
	["ROGUE"]	= { {1.00, 	0.96, 	0.41 }, "Rogue"   },
	["SHAMAN"]	= { {0.0, 	0.44, 	0.87 }, "Shaman"  },
	["WARLOCK"]	= { {0.58, 	0.51, 	0.79 }, "Warlock" },
	["WARRIOR"]	= { {0.78, 	0.61, 	0.43 }, "Warrior" },
}

local PowerColor = {
	[0] = { { 0.19, 0.44, 0.75 }, "Mana"   },
	[1] = { { 0.89, 0.18, 0.29 }, "Rage"   },
	[2] = { { 1.00, 0.70, 0.0  }, "Focus"  },
	[3] = { { 1.00, 1.00, 0.13 }, "Energy" },
	["UNKNOWN"] = { { 0.51, 0.51, 0.51 }, "UNKNOWN" },
}

LPM_ExpTable = {
	--["PlayerName"] = {
	--	curr_xp = nil,
	--	max_xp = nil,
	--	rested_xp = nil,
	--},
}

function LazyPigMultibox_SendXPData()
	local unitName = GetUnitName("Player", false)
	local curr_xp = UnitXP("Player")
	local max_xp = UnitXPMax("Player")
	local rested_xp = GetXPExhaustion()
	LazyPigMultibox_UpdateExpTable_Normal(unitName, curr_xp, max_xp)
	LazyPigMultibox_UpdateExpTable_Rested(unitName, rested_xp)
end

function LazyPigMultibox_UpdateExpTable_Normal(unitName, curr_xp, max_xp)
	if not LazyPigMultiboxExpTable[unitName] then
		LazyPigMultiboxExpTable[unitName] = {}
	end
	LazyPigMultiboxExpTable[unitName].curr_xp = curr_xp
	LazyPigMultiboxExpTable[unitName].max_xp = max_xp

	if unitName == GetUnitName("player") then
		local msg = LazyPigMultibox_DataStringEncode(unitName, curr_xp, max_xp)
		--LPMD("    --- Sending Normal XP Data: " .. msg)
    	SendAddonMessage("lpm_dataexp_normal_reply", msg, "RAID", GetUnitName("player"))
    end
end

function LazyPigMultibox_UpdateExpTable_Rested(unitName, rested_xp)
	if not LazyPigMultiboxExpTable[unitName] then
		LazyPigMultiboxExpTable[unitName] = {}
	end
	LazyPigMultiboxExpTable[unitName].rested_xp = rested_xp

	if unitName == GetUnitName("player") then
		local msg = LazyPigMultibox_DataStringEncode(unitName, rested_xp)
		--LPMD("    --- Sending Rested XP Data: " .. msg)
    	SendAddonMessage("lpm_dataexp_rested_reply", msg, "RAID", GetUnitName("player"))
    end
end

local function TileTeamUnitFrame(hParent, sUnit, offsetX, offsetY)
	--[[
	local ClassColorName = {
		["UNKNOWN"]	= { {0.51, 	0.51, 	0.51 }, "UNKNOWN" },
		["DRUID"]	= { {1.00, 	0.49, 	0.04 }, "Druid"   },
		["HUNTER"]	= { {0.67, 	0.83, 	0.45 }, "Hunter"  },
		["MAGE"]	= { {0.41, 	0.80, 	0.94 }, "Mage"    },
		["PALADIN"]	= { {0.96, 	0.55, 	0.73 }, "Paladin" },
		["PRIEST"]	= { {1.00, 	1.00, 	1.00 }, "Priest"  },
		["ROGUE"]	= { {1.00, 	0.96, 	0.41 }, "Rogue"   },
		["SHAMAN"]	= { {0.0, 	0.44, 	0.87 }, "Shaman"  },
		["WARLOCK"]	= { {0.58, 	0.51, 	0.79 }, "Warlock" },
		["WARRIOR"]	= { {0.78, 	0.61, 	0.43 }, "Warrior" },
	}

	local PowerColor = {
		[0] = { { 0.19, 0.44, 0.75 }, "Mana"   },
		[1] = { { 0.89, 0.18, 0.29 }, "Rage"   },
		[2] = { { 1.00, 0.70, 0.0  }, "Focus"  },
		[3] = { { 1.00, 1.00, 0.13 }, "Energy" },
		["UNKNOWN"] = { { 0.51, 0.51, 0.51 }, "UNKNOWN" },
	}
	]]

	local unit = sUnit
	local name, english_class; class = nil, nil
	local tCol = {}

	if UnitExists(unit) then
		name = GetUnitName(unit, false)
		_, english_class, _ = UnitClass(unit)
		powertype, _ = UnitPowerType(unit)
		if english_class then
			tClassColor = ClassColorName[english_class][1]
			class = ClassColorName[english_class][2]
		else
			tClassColor = ClassColorName["UNKNOWN"][1]
			class = ClassColorName["UNKNOWN"][2]			
		end
		if powertype then
			tPowerColor = PowerColor[powertype][1]
			power = PowerColor[powertype][2]
		else
			tPowerColor = PowerColor["UNKNOWN"][1]
			power = PowerColor["UNKNOWN"][2]
		end
	end

	local btn = CreateFrame("Button", "LazyPigMultiboxTeamUnitFrame" .. unit, hParent)
	btn.unit = unit
	btn.name = name
	btn.class = class
	btn.powertype = powertype
	btn.power = power
	btn.tClassColor = tClassColor
	btn.tPowerColor = tPowerColor

	btn:SetPoint("TOPLEFT", hParent, "TOPLEFT", offsetX, offsetY)
	--btn:SetWidth(140)
	btn:SetWidth(100)
	--btn:SetHeight(52)
	btn:SetHeight(42)
	btn:EnableMouse(true)
	--btn:RegisterForClicks("LeftButtonUp")
		btn:SetBackdrop({ 
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	})
	btn:SetBackdropColor(btn.tClassColor[1], btn.tClassColor[2], btn.tClassColor[3], .25)
	--btn:SetBackdropBorderColor(1, 1, 1, 1)

	-------------------
	-- Offline Overlay
	-------------------
	local frame_offline = CreateFrame("Frame", nil, btn)
	frame_offline:SetFrameStrata("DIALOG")
	frame_offline:SetPoint("TOPLEFT", btn, "TOPLEFT", 5, -5)
	frame_offline:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -5, 5)
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
	fs_offline:SetFont("Fonts\\ARIALN.TTF", 20)
	fs_offline:SetText("OFFLINE")
	
	btn.fs_offline = fs_offline

	------------------
	-- Follow Overlay
	------------------
	local frame_follow = CreateFrame("Frame", nil, btn)
	frame_follow:SetFrameStrata("DIALOG")
	frame_follow:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
	frame_follow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, (btn:GetHeight()/2))
	frame_follow:Hide()

	btn.frame_follow = frame_follow

	local box_follow = frame_follow:CreateTexture(nil, "OVERLAY")
	--box_follow:SetTexture(.1, .1, .1, .71)
	box_follow:SetTexture(0.21, 0.17, 0.1, .81)
	box_follow:SetBlendMode("BLEND")
	box_follow:SetAllPoints()
		
	btn.box_follow = box_follow

	local fs_follow = frame_follow:CreateFontString(nil, "OVERLAY")
	fs_follow:SetAllPoints()
	fs_follow:SetShadowColor(0, 0, 0)
	fs_follow:SetShadowOffset(0.8, -0.8)
	--fs_follow:SetTextColor(.91, .91, .91)
	fs_follow:SetFont("Fonts\\ARIALN.TTF", 12)
	fs_follow:SetText("NOT FOLLOWING")
	
	btn.fs_follow = fs_follow

	----------------
	-- Lost Overlay
	----------------
	local frame_lost = CreateFrame("Frame", nil, btn)
	frame_lost:SetFrameStrata("DIALOG")
	frame_lost:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -(btn:GetHeight()/2))
	frame_lost:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
	frame_lost:Hide()

	btn.frame_lost = frame_lost

	local box_lost = frame_lost:CreateTexture(nil, "OVERLAY")
	--box_lost:SetTexture(.1, .1, .1, .71)
	box_lost:SetTexture(.21, .1, .1, .81)
	box_lost:SetBlendMode("BLEND")
	box_lost:SetAllPoints()
		
	btn.box_lost = box_lost

	local fs_lost = frame_lost:CreateFontString(nil, "OVERLAY")
	fs_lost:SetAllPoints()
	fs_lost:SetShadowColor(0, 0, 0)
	fs_lost:SetShadowOffset(0.8, -0.8)
	--fs_lost:SetTextColor(.91, .91, .91)
	fs_lost:SetFont("Fonts\\ARIALN.TTF", 20)
	fs_lost:SetText("LOST!")
	
	btn.fs_lost = fs_lost

	---------
	-- ICONS
	---------
	local frame_icon = CreateFrame("Frame", nil, btn)
	frame_icon:SetFrameStrata("HIGH")
	--frame_icon:EnableMouse(true)
	frame_icon:SetAllPoints(btn)

	btn.frame_icon = frame_icon

	local icon_raid = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_raid:SetPoint("CENTER", frame_icon, "TOP", 0, -5)
	icon_raid:SetHeight(15)
	icon_raid:SetWidth(15)
	icon_raid:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

	btn.icon_raid = icon_raid

	local icon_leader = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_leader:SetPoint("CENTER", frame_icon, "TOPLEFT", 5, -2)
	icon_leader:SetHeight(14)
	icon_leader:SetWidth(14)
	icon_leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

	btn.icon_leader = icon_leader

	local icon_loot = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_loot:SetPoint("CENTER", frame_icon, "TOPLEFT", 15, -2)
	icon_loot:SetHeight(10)
	icon_loot:SetWidth(10)
	icon_loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")

	btn.icon_loot = icon_loot

	local icon_PVP = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_PVP:SetPoint("CENTER", frame_icon, "RIGHT", 5, -5)
	icon_PVP:SetHeight(30)
    icon_PVP:SetWidth(30)

    btn.icon_PVP = icon_PVP

	local icon_combat = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	icon_combat:SetTexCoord(0.5, 1, 0, 0.5)
	icon_combat:SetPoint("CENTER", frame_icon, "BOTTOMRIGHT", -1, 5)
	icon_combat:SetHeight(16)
	icon_combat:SetWidth(16)
	icon_combat:Hide()

	btn.icon_combat = icon_combat

	--[[
	local icon_rest = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_rest:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	icon_rest:SetTexCoord(0, 0.5, 0, 0.421875)
	icon_rest:SetPoint("CENTER", frame_info, "BOTTOMLEFT", 4, 5)
	icon_rest:SetHeight(16)
	icon_rest:SetWidth(16)
	icon_rest:Hide()
	
	btn.icon_rest = icon_rest
	]]

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
	--box_healthbar:SetPoint("TOPLEFT", btn, "TOPLEFT", 44, -3)
	box_healthbar:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
	box_healthbar:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
	--box_healthbar:SetHeight(24)
	box_healthbar:SetHeight(16)

	btn.box_healthbar = box_healthbar

	local sb_healthbar = CreateFrame("StatusBar", nil, btn)
	sb_healthbar:SetStatusBarTexture("Interface\\AddOns\\_LazyPigMultibox\\statusbar")
	sb_healthbar:SetStatusBarColor(tClassColor[1], tClassColor[2], tClassColor[3], 1)
	sb_healthbar:SetPoint("TOPLEFT", box_healthbar, "TOPLEFT", 1, -2)
	sb_healthbar:SetPoint("BOTTOMRIGHT", box_healthbar, "BOTTOMRIGHT", -2, 1)

	btn.sb_healthbar = sb_healthbar

	local fs_name = sb_healthbar:CreateFontString(nil, "ARTWORK")
	fs_name:SetPoint("LEFT", btn.sb_healthbar, "LEFT", 3, 0)
	fs_name:SetJustifyH("LEFT")
	fs_name:SetShadowColor(0, 0, 0)
	fs_name:SetShadowOffset(0.8, -0.8)
	fs_name:SetTextColor(.91, .91, .91)
	--fs_name:SetFont("Fonts\\ARIALN.TTF", 14)
	fs_name:SetFont("Fonts\\ARIALN.TTF", 11)
	fs_name:SetText(btn.name)

	btn.fs_name = fs_name

	local fs_health = sb_healthbar:CreateFontString(nil, "ARTWORK")
	fs_health:SetPoint("RIGHT", btn.sb_healthbar, "RIGHT", -3, 0)
	fs_health:SetShadowColor(0, 0, 0)
	fs_health:SetShadowOffset(0.8, -0.8)
	fs_health:SetTextColor(.91, .91, .91)
	fs_health:SetFont("Fonts\\ARIALN.TTF", 9)
	
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
	sb_powerbar:SetStatusBarTexture("Interface\\AddOns\\_LazyPigMultibox\\statusbar")
	sb_powerbar:SetStatusBarColor(tPowerColor[1], tPowerColor[2], tPowerColor[3], 1)
	sb_powerbar:SetPoint("TOPLEFT", box_powerbar, "TOPLEFT", 1, -1)
	sb_powerbar:SetPoint("BOTTOMRIGHT", box_powerbar, "BOTTOMRIGHT", -2, 1)

	btn.sb_powerbar = sb_powerbar

	--[[
	local fs_class = sb_powerbar:CreateFontString(nil, "ARTWORK")
	fs_class:SetPoint("LEFT", btn.sb_powerbar, "LEFT", 5, 1)
	fs_class:SetJustifyH("LEFT")
	fs_class:SetShadowColor(0, 0, 0)
	fs_class:SetShadowOffset(0.8, -0.8)
	fs_class:SetTextColor(.91, .91, .91)
	fs_class:SetFont("Fonts\\ARIALN.TTF", 6)
	fs_class:SetText(btn.class)

	btn.fs_class = fs_class
	]]

	--local fs_level = sb_powerbar:CreateFontString(nil, "HIGHLIGHT")
	

	local fs_power = sb_powerbar:CreateFontString(nil, "ARTWORK")
	fs_power:SetPoint("RIGHT", btn.sb_powerbar, "RIGHT", -3, 1)
	fs_power:SetShadowColor(0, 0, 0)
	fs_power:SetShadowOffset(0.8, -0.8)
	fs_power:SetTextColor(.91, .91, .91)
	fs_power:SetFont("Fonts\\ARIALN.TTF", 6)
	
	btn.fs_power = fs_power

	-----------------
	-- ExperienceBar
	-----------------
	local box_expbar = btn:CreateTexture(nil, "BACKGROUND")
	box_expbar:SetTexture(.1, .1, .1, .75)
	box_expbar:SetBlendMode("BLEND")
	-- Long as the Frame
	--box_expbar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 3, 3)
	--box_expbar:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -3, 3)
	-- Long as the Healthbar
	box_expbar:SetPoint("TOPLEFT", btn.box_powerbar, "BOTTOMLEFT", 0, 0)
	box_expbar:SetPoint("TOPRIGHT", btn.box_powerbar, "BOTTOMRIGHT", 0, 0)
	box_expbar:SetHeight(11)

	btn.box_expbar = box_expbar

	local sb_expbar = CreateFrame("StatusBar", nil, btn)
	--sb_powerbar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
	sb_expbar:SetStatusBarTexture("Interface\\AddOns\\_LazyPigMultibox\\statusbar")
	--sb_expbar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0)
	sb_expbar:SetStatusBarColor(0.0, 0.77, 0.17, 1.0)
	sb_expbar:SetPoint("TOPLEFT", box_expbar, "TOPLEFT", 1, -2)
	sb_expbar:SetPoint("BOTTOMRIGHT", box_expbar, "BOTTOMRIGHT", -2, 3)
	--sb_expbar:SetFrameStrata("HIGH")
	sb_expbar:SetFrameLevel(3)
	btn.sb_expbar = sb_expbar

	local sb_restbar = CreateFrame("StatusBar", nil, btn)
	--sb_powerbar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
	sb_restbar:SetStatusBarTexture("Interface\\AddOns\\_LazyPigMultibox\\statusbar")
	sb_restbar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0)
	--sb_restbar:SetAllPoints(sb_expbar)
	sb_restbar:SetPoint("TOPLEFT", box_expbar, "TOPLEFT", 1, -3)
	sb_restbar:SetPoint("BOTTOMRIGHT", box_expbar, "BOTTOMRIGHT", -2, 4)
	sb_expbar:SetFrameLevel(3)

	btn.sb_restbar = sb_restbar

	---------------------------------------
	-- Info Frame. More infos on MouseOver
	---------------------------------------
	local frame_info = CreateFrame("Frame", nil, btn)
	frame_info:SetFrameStrata("HIGH")
	frame_info:EnableMouse(true)
	frame_info:SetAllPoints(btn)
	
	btn.frame_info = frame_info

	local fs_level = frame_info:CreateFontString(nil, "HIGHLIGHT")
	fs_level:SetPoint("LEFT", btn.sb_powerbar, "LEFT", 3, 0)
	fs_level:SetShadowColor(0, 0, 0)
	fs_level:SetShadowOffset(0.8, -0.8)
	fs_level:SetTextColor(.91, .91, .91)
	fs_level:SetFont("Fonts\\ARIALN.TTF", 7)

	btn.fs_level = fs_level

	local fs_exp = frame_info:CreateFontString(nil, "ARTWORK")
	fs_exp:SetPoint("CENTER", btn.sb_expbar, "CENTER", -3, 1)
	fs_exp:SetShadowColor(0, 0, 0)
	fs_exp:SetShadowOffset(0.8, -0.8)
	fs_exp:SetTextColor(.91, .91, .91)
	fs_exp:SetFont("Fonts\\ARIALN.TTF", 6)

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

	--btn:RegisterEvent("PARTY_MEMBER_DISABLE")
	--btn:RegisterEvent("PARTY_MEMBER_ENABLE")

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

	btn:RegisterEvent("RAID_TARGET_UPDATE")

	btn:SetScript("OnEvent", function()
		if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
			if this.unit == arg1 then
				this.sb_healthbar:SetMinMaxValues(0, UnitHealthMax(this.unit))
				this.sb_healthbar:SetValue(UnitHealth(this.unit))
				--this.fs_health:SetText(math.floor((UnitHealth(this.unit) * 100) / UnitHealthMax(this.unit)) .. "%")
				this.fs_health:SetText(math.floor(UnitHealth(this.unit) * 100 / UnitHealthMax(this.unit)) .. "%")

				if (UnitIsDead(this.unit) or UnitIsGhost(this.unit)) then			-- This prevents negative health
					this.sb_healthbar:SetValue(0)
				end
				--[[
				local color
				if not UnitIsConnected(this.unit) then
					color = LunaOptions.MiscColors["offline"]
					this.bars["Healthbar"].hpp:SetText("OFFLINE")
				elseif UnitHealth(this.unit) < 2 then
					color = LunaOptions.MiscColors["offline"]
					this.bars["Healthbar"].hpp:SetText("DEAD")
				else
					color = LunaOptions.ClassColors[UnitClass(this.unit)]
				end
				if color then
					this.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
					this.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
				end
				Luna_Party_Events.UNIT_LEVEL()
				]]
			end

		elseif event == "UNIT_MANA" or event == "UNIT_MAXMANA" or event == "UNIT_ENERGY" or event == "UNIT_MAXENERGY" or event == "UNIT_RAGE" or event == "UNIT_MAXRAGE" then
			if this.unit == arg1 then
				if (UnitHealth(this.unit) < 2 or not UnitIsConnected(this.unit)) then
					this.sb_powerbar:SetValue(0)
					this.fs_power:SetText("0/"..UnitManaMax(this.unit))
				else
					this.sb_powerbar:SetMinMaxValues(0, UnitManaMax(this.unit))
					this.sb_powerbar:SetValue(UnitMana(this.unit))
					this.fs_power:SetText(UnitMana(this.unit).."/"..UnitManaMax(this.unit))
				end
			end
			
		elseif event == "UNIT_DISPLAYPOWER" then
			if arg1 == this.unit then
				local power = UnitPowerType(arg1)
				local tPowerCol = PowerColor[power]
				
				if UnitManaMax(this.unit) == 0 then
					this.sb_powerbar:SetStatusBarColor(0, 0, 0, .25)
					this.box_powerbar:SetVertexColor(0, 0, 0, .25)
				elseif targetpower == 1 then
					this.sb_powerbar:SetStatusBarColor(tPowerCol[1], tPowerCol[2], tPowerCol[3])
					this.box_powerbar:SetVertexColor(tPowerCol[1], tPowerCol[2], tPowerCol[3], .25)
				elseif targetpower == 3 then
					this.sb_powerbar:SetStatusBarColor(tPowerCol[1], tPowerCol[2], tPowerCol[3])
					this.box_powerbar:SetVertexColor(tPowerCol[1], tPowerCol[2], tPowerCol[3], .25)
				elseif not UnitIsDeadOrGhost("target") then
					this.sb_powerbar:SetStatusBarColor(tPowerCol[1], tPowerCol[2], tPowerCol[3])
					this.box_powerbar:SetVertexColor(tPowerCol[1], tPowerCol[2], tPowerCol[3], .25)
				else
					this.sb_powerbar:SetStatusBarColor(0, 0, 0, .25)
					this.box_powerbar:SetVertexColor(0, 0, 0, .25)
				end
				if (UnitHealth(this.unit) < 2 or not UnitIsConnected(this.unit)) then
					this.sb_powerbar:SetValue(0)
					this.fs_power:SetText("0/"..UnitManaMax(this.unit))
				else
					this.sb_powerbar:SetMinMaxValues(0, UnitManaMax(this.unit))
					this.sb_powerbar:SetValue(UnitMana(this.unit))
					this.fs_power:SetText(UnitMana(this.unit).."/"..UnitManaMax(this.unit))
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
			if this.name == GetUnitName("Player", false) then
				LPMD("  Sending \"Follow Start\"")
				SendAddonMessage("lpm_slavefollow_begin", "", "RAID", GetUnitName("player"))
				this.frame_follow:Hide()
			end
			--this.frame_follow:Hide()

		elseif event == "AUTOFOLLOW_END" then
			if this.name == GetUnitName("Player", false) and not UnitAffectingCombat(this.unit) then
				LPMD("  Sending \"Follow End\"")
				SendAddonMessage("lpm_slavefollow_end", "", "RAID", GetUnitName("player"))
				this.frame_follow:Show()
			end

		elseif event == "PLAYER_REGEN_DISABLED" then
			if this.name ~= GetUnitName("Player", false) and UnitIsConnected(this.unit) then
				if this.frame_follow:IsVisible() then
					this.was_following = true
					this.frame_follow:Hide()
				end
			end
			if UnitAffectingCombat(this.unit) then
				this.icon_combat:Show()
				SendAddonMessage("lpm_ui_status", "combat_start", "Raid", GetUnitName(this.unit, false))
			end

		elseif event == "PLAYER_REGEN_ENABLED" then
			if this.name ~= GetUnitName("Player", false) and UnitIsConnected(this.unit) then
				if this.was_following then
					this.frame_follow:Show()
				end
			end
			if not UnitAffectingCombat(this.unit) then
				this.icon_combat:Hide()
				SendAddonMessage("lpm_ui_status", "combat_end", "Raid", GetUnitName(this.unit, false))
			end

		elseif event == "UNIT_LEVEL" then
			if arg1 == this.unit then
				local lvl = UnitLevel(this.unit)
				if lvl < 1 then
					this.fs_level:SetText("Level ??")
				else
					this.fs_level:SetText("Level " .. lvl)
				end
			end
		
		elseif event == "PLAYER_XP_UPDATE" then
			LazyPigMultibox_SendXPData()

		elseif event == "PLAYER_UPDATE_RESTING" then
			if IsResting() then
				this.icon_rest:Show()
				this.icon_combat:Hide()
				--SendAddonMessage("lpm_ui_status", "rest_start", "Raid", GetUnitName(this.unit, false))
			else
				this.icon_rest:Hide()
				this.icon_combat:Hide()
				--SendAddonMessage("lpm_ui_status", "rest_end", "Raid", GetUnitName(this.unit, false))
			end
		end
	end)

	---------------------------
	-- PartyUnitFrame Handlers
	---------------------------
	btn:SetScript("OnClick", function()
		
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
		if UnitIsConnected(parent.unit) then
			local unit_curr_xp, unit_max_xp, unit_rested_xp = "NA", "NA", "NA"
			if LazyPigMultiboxExpTable[parent.name] then
				unit_curr_xp = LazyPigMultiboxExpTable[parent.name].curr_xp
				unit_max_xp = LazyPigMultiboxExpTable[parent.name].max_xp
				unit_rested_xp = LazyPigMultiboxExpTable[parent.name].rested_xp
			end
			if type(unit_rested_xp) == "number" and unit_rested_xp > 0 then
				parent.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp .. " (" ..( math.floor( unit_curr_xp / unit_max_xp * 10000) / 100 ) .. "%)" .. " + " .. unit_rested_xp)
			elseif type(unit_curr_xp) == "number" and type(unit_max_xp) == "number" then
				parent.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp .. " (" ..( math.floor( unit_curr_xp / unit_max_xp * 10000) / 100 ) .. "%)")
			else
				parent.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp)
			end
			--this.fs_exp:SetText()
			local tCol = this:GetParent().tClassColor
			this:GetParent():SetBackdropColor(tCol[1]+.1, tCol[2]+.1, tCol[3]+.1, .25+.15)
			--this.frame_info:Show()
		end
	end)
	frame_info:SetScript("OnLeave", function()
		local parent = this:GetParent()
		if UnitIsConnected(parent.unit) then
			local unit_curr_xp, unit_max_xp= "NA", "NA"
			if LazyPigMultiboxExpTable[parent.name] then
				unit_curr_xp = LazyPigMultiboxExpTable[parent.name].curr_xp
				unit_max_xp = LazyPigMultiboxExpTable[parent.name].max_xp
			end
			--local unit_rested_xp = LazyPigMultiboxExpTable[parent.name].rested_xp
			--if unit_rested_xp > 0 then
			--	parent.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp .. " + " .. unit_rested_xp)
			--else
				parent.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp)
			--end
			--this.fs_exp:SetText()
			local tCol = this:GetParent().tClassColor
			this:GetParent():SetBackdropColor(tCol[1], tCol[2], tCol[3], .25)
			--this.frame_info:Hide()
			--GameTooltip:Hide();
		end
	end)

	--[[
	btn.portrait:SetScript("OnShow", function()
		this:SetCamera(0)
	end)
	]]
	return btn
end

function LazyPigMultibox_CreateTeamFrame()
	-- Option Frame
	local frame = CreateFrame("Frame", "LazyPigMultiboxTeamFrame")
	--frame:SetScale(.81)
		
	frame:SetWidth(120)
	frame:SetHeight(64)
	
	frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -100, 110)
	frame:SetBackdrop( {
			--bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			--edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			--tile = true, 
			--tileSize = 16, 
			--edgeSize = 16,
			--insets = { left = 4, right = 4, top = 4, bottom = 4 }
		} );
	frame:SetBackdropColor(.01, .01, .01, .37)


	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
	--frame:Hide()
	
	-- MenuTitle FontString
	local fs_title = frame:CreateFontString(nil, "ARTWORK")
	fs_title:SetPoint("CENTER", frame, "TOP", 0, -5)
	fs_title:SetFont("Fonts\\ARIALN.TTF", 10)
	fs_title:SetTextColor(1, 1, 1, 1)
	fs_title:SetText("SomeWeird Team")

	frame.fs_title = fs_title

	--[[
	local btn_close = CreateFrame("Button", "LazyPigMultiboxRollClose", frame, "UIPanelCloseButton")
	btn_close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)
	btn_close:SetWidth(32)
	btn_close:SetHeight(32)
	btn_close:SetText("Close")
	btn_close:SetText("X")
	btn_close:SetScript("OnClick", function()
		this:GetParent():Hide()
	end)
	]]

	frame:RegisterEvent("PARTY_LEADER_CHANGED")
	frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	--frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	frame:RegisterEvent("RAID_ROSTER_UPDATE")
	frame:RegisterEvent("RAID_TARGET_UPDATE")
	frame:RegisterEvent("UNIT_FACTION")

	frame:SetScript("OnEvent", function()
		if event == "PARTY_MEMBERS_CHANGED" or 
				event == "RAID_ROSTER_UPDATE" or
				event == "RAID_TARGET_UPDATE" or
				event == "PARTY_LEADER_CHANGED" or
				event == "UNIT_FACTION" then
			LazyPigMultibox_UpdateTeamFrame()
		end
	end)
	frame:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" and not this.isMoving then
			this:SetFrameStrata("TOOLTIP")
			this:StartMoving();
			this.isMoving = true;
		end
	end)
	frame:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" and this.isMoving then
			this:StopMovingOrSizing();
			this:SetFrameStrata("MEDIUM")
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

	frame.partyunitframe = {} -- frame.unitframe[1] will always be "player" frame
						-- frame.unitframe[2] should always be "party1" frame
						-- frame.unitframe[3] should always be "party2" frame
						-- frame.unitframe[4] should always be "party3" frame
						-- frame.unitframe[5] should always be "party4" frame
	
	frame = LazyPigMultibox_UpdateTeamFrame()

	--[[
	for _,v in pairs(frame.partyunitframe) do
		LazyPigMultibox_UpdateUnitFrame(v)
		LazyPigMultibox_UpdateXPBar(v)
	end
	]]

	return frame
end

local function HideBlizzardFrames()
	ShowPartyFrame = function() end  -- Hide Blizz stuff
	HidePartyFrame = ShowPartyFrame

	for num = 1, 4 do
		local frame = getglobal("PartyMemberFrame"..num)
		frame:Hide()
		frame:UnregisterAllEvents()
		getglobal("PartyMemberFrame"..num.."HealthBar"):UnregisterAllEvents()
		getglobal("PartyMemberFrame"..num.."ManaBar"):UnregisterAllEvents()
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", 0, 50)
	end
end

function LazyPigMultibox_GetUnitFrame(name)
	local frame = LazyPigMultibox_UpdateTeamFrame(getglobal("LazyPigMultiboxTeamFrame"))
	local unitframe = nil
	for k,v in pairs(frame.partyunitframe) do
		if v.name == name then
			unitframe = v
			break
		end
	end

	return unitframe or nil
end

function LazyPigMultibox_UpdateUnitFrame(frame)
	if not frame.unit then return end

	frame:Show()

	if UnitExists(frame.unit) then
		if frame.name == "Unknown" then
			frame.name = GetUnitName(unit, false)
		end

		local _, english_class, _ = UnitClass(frame.unit)
		local powertype, _ = UnitPowerType(frame.unit)

		if english_class then
			frame.tClassColor = ClassColorName[english_class][1]
			frame.class = ClassColorName[english_class][2]
		else
			frame.tClassColor = ClassColorName["UNKNOWN"][1]
			frame.class = ClassColorName["UNKNOWN"][2]			
		end
		if powertype then
			frame.tPowerColor = PowerColor[powertype][1]
			frame.power = PowerColor[powertype][2]
		else
			frame.tPowerColor = PowerColor["UNKNOWN"][1]
			frame.power = PowerColor["UNKNOWN"][2]
		end
	end

	local index = GetRaidTargetIndex(frame.unit)
	if (index) then
		SetRaidTargetIconTexture(frame.icon_raid, index)
		frame.icon_raid:Show()
	else
		frame.icon_raid:Hide()
	end
	
	if UnitIsPartyLeader(frame.unit) then
		frame.icon_leader:Show()
		frame.icon_loot:Show()
	else
		frame.icon_leader:Hide()
		frame.icon_loot:Hide()
	end

	local faction = UnitFactionGroup(frame.unit)
	if UnitIsPVP(frame.unit) then
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

	if not UnitIsConnected(frame.unit) then
		frame.sb_healthbar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
		frame.sb_healthbar:SetValue(0)
		frame.sb_healthbar:SetStatusBarColor(frame.tClassColor[1], frame.tClassColor[2], frame.tClassColor[3])
		frame.fs_health:SetText("0/"..UnitHealthMax(frame.unit))
		--frame.fs_health:SetTextColor(.31, .31, .31)

		frame.sb_powerbar:SetMinMaxValues(0, UnitManaMax(frame.unit))
		frame.sb_powerbar:SetValue(0)
		frame.sb_healthbar:SetStatusBarColor(frame.tPowerColor[1], frame.tPowerColor[2], frame.tPowerColor[3])
		frame.fs_power:SetText("0/"..UnitManaMax(frame.unit))
		--frame.fs_power:SetTextColor(.31, .31, .31)

		--frame.fs_name:SetTextColor(.31, .31, .31)
		--frame.fs_class:SetTextColor(.31, .31, .31)

		frame.frame_offline:Show()
	
	elseif UnitHealth(frame.unit) < 2 then
		frame.sb_healthbar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
		frame.sb_healthbar:SetValue(0)
		frame.fs_health:SetText("DEAD")
	
		frame.sb_powerbar:SetMinMaxValues(0, UnitManaMax(frame.unit))
		frame.sb_powerbar:SetValue(0)
		frame.fs_power:SetText("0/"..UnitManaMax(frame.unit))

	else
		frame.sb_healthbar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
		frame.sb_healthbar:SetValue(UnitHealth(frame.unit))
		--frame.fs_health:SetText(UnitHealth(frame.unit).."/"..UnitHealthMax(frame.unit))
		frame.fs_health:SetText(math.floor(UnitHealth(frame.unit) * 100 / UnitHealthMax(frame.unit)) .. "%")
	
		frame.sb_powerbar:SetMinMaxValues(0, UnitManaMax(frame.unit))
		frame.sb_powerbar:SetValue(UnitMana(frame.unit))
		frame.fs_power:SetText(UnitMana(frame.unit).."/"..UnitManaMax(frame.unit))

		frame.frame_offline:Hide()
	end
	
	--[[
	if frame.powertype == 0 then
		frame.sb_powerbar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		--frame.box_powerbar:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	elseif frame.powertype == 1 then
		frame.sb_powerbar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		--frame.box_powerbar:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
	elseif frame.powertype == 3 then
		frame.sb_powerbar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		--frame.box_powerbar:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
	else
		frame.sb_powerbar:SetStatusBarColor(0, 0, 0, .25)
		--frame.box_powerbar:SetVertexColor(0, 0, 0, .25)
	end
	]]

	frame.fs_name:SetText(frame.name)
	--[[
	frame.fs_class:SetText(frame.class)
	]]
	local lvl = UnitLevel(frame.unit)
	if lvl > 0 then
		frame.fs_level:SetText("Level " .. lvl)
	else
		frame.fs_level:SetText("Level ??")
	end
end

function LazyPigMultibox_UpdateXPBar(frame)
	if LazyPigMultiboxExpTable[frame.name] and
			type(LazyPigMultiboxExpTable[frame.name].curr_xp) == "number" and
			type(LazyPigMultiboxExpTable[frame.name].max_xp) == "number" and
			type(LazyPigMultiboxExpTable[frame.name].rested_xp) == "number" then

		local unit_curr_xp = LazyPigMultiboxExpTable[frame.name].curr_xp
		local unit_max_xp = LazyPigMultiboxExpTable[frame.name].max_xp
		local unit_rested_xp = LazyPigMultiboxExpTable[frame.name].rested_xp

		frame.sb_restbar:SetMinMaxValues(0, unit_max_xp)
		frame.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp)
		if unit_rested_xp > 0 then
		--	frame.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp .. " + " .. unit_rested_xp)
			frame.sb_restbar:SetValue(unit_curr_xp + unit_rested_xp)
		else
		--	frame.fs_exp:SetText(unit_curr_xp .. "/" .. unit_max_xp)
			frame.sb_restbar:SetValue(unit_curr_xp)
		end
		frame.sb_expbar:SetMinMaxValues(0, unit_max_xp)
		frame.sb_expbar:SetValue(unit_curr_xp)
	else
		frame.sb_restbar:SetMinMaxValues(0, 1)
		frame.sb_restbar:SetValue(0)
		frame.sb_expbar:SetMinMaxValues(0, 1)
		frame.sb_expbar:SetValue(0)
		frame.fs_exp:SetText("NA/NA")
	end
end

function LazyPigMultibox_UpdateTeamFrame()
	local PADDING = 3
	local UNITFRAME_HEIGHT = 42
	local STARTING_OFFSET = 12
	local FOOTER = 12

	local frame = getglobal("LazyPigMultiboxTeamFrame")

	local partymembers = GetNumPartyMembers()
	local teamframe_verticaloffset = (PADDING + UNITFRAME_HEIGHT) * partymembers
	--local frameverticaloffset = (2 + 42) * partymembers
	--local teamframe_height = frame:GetHeight()
	frame:SetHeight(STARTING_OFFSET + UNITFRAME_HEIGHT + FOOTER + teamframe_verticaloffset)

	local unitID = "player"
	local offsetY = -(STARTING_OFFSET)
	if not frame.partyunitframe[unitID] then
		frame.partyunitframe[unitID] = TileTeamUnitFrame(frame, unitID, 10, offsetY)
	else
		LazyPigMultibox_UpdateUnitFrame(frame.partyunitframe[unitID])
		LazyPigMultibox_UpdateXPBar(frame.partyunitframe[unitID])
	end

	for i = 1, 5 do
		unitID = "party" .. i
		offsetY = -(STARTING_OFFSET + (UNITFRAME_HEIGHT + PADDING) * i)
		if i <= partymembers then
			if not frame.partyunitframe[unitID] then
				frame.partyunitframe[unitID] = TileTeamUnitFrame(frame, unitID, 10, offsetY)
			else
				LazyPigMultibox_UpdateUnitFrame(frame.partyunitframe[unitID])
				LazyPigMultibox_UpdateXPBar(frame.partyunitframe[unitID])
			end
		else
			if frame.partyunitframe[unitID] then
				frame.partyunitframe[unitID]:Hide()
			end
		end
	end

	return frame
end

function LazyPigMultibox_SlaveFollowFrame(follow, name)
	--LPMD(" SlaveFollowFrame -  follow: " .. tostring(follow) .. "  - name: " .. name)
	local teamframe = getglobal("LazyPigMultiboxTeamFrame")

	for k,v in pairs(teamframe.partyunitframe) do
		if v.name == name then
			
			if follow then
				v.frame_follow:Hide()
				--v.frame_lost:Hide()
			else
				v.frame_follow:Show()
				--v.frame_lost:Show()
			end
		end
	end
end

function LPM_CreateTeamFrame()
	-- Option Frame
	local frame = CreateFrame("Frame", "LPM_TeamFrame")
	frame:SetScale(LPMULTIBOX_UI.TF_SCALE)
		
	frame:SetWidth(120)
	frame:SetHeight(64)
	
	frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -100, 110)
	frame:SetBackdrop( {
			--bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			--edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			--tile = true, 
			--tileSize = 16, 
			--edgeSize = 16,
			--insets = { left = 4, right = 4, top = 4, bottom = 4 }
		} );
	frame:SetBackdropColor(.01, .01, .01, LPMULTIBOX_UI.TF_BACKGROUNDALPHA)

	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetUserPlaced(true)

	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	
	if LPMULTIBOX_UI.TF_LOCK then
		frame:SetMovable(false)
		frame:RegisterForDrag()
	else
		frame:SetMovable(true)
		frame:RegisterForDrag("LeftButton")
	end

	if LPMULTIBOX_UI.TF_SHOW then
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

	--[[
	local btn_close = CreateFrame("Button", "LazyPigMultiboxRollClose", frame, "UIPanelCloseButton")
	btn_close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)
	btn_close:SetWidth(32)
	btn_close:SetHeight(32)
	btn_close:SetText("Close")
	btn_close:SetText("X")
	btn_close:SetScript("OnClick", function()
		this:GetParent():Hide()
	end)
	]]

	frame:RegisterEvent("PARTY_LEADER_CHANGED")
	frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	frame:RegisterEvent("RAID_ROSTER_UPDATE")
	frame:RegisterEvent("RAID_TARGET_UPDATE")
	frame:RegisterEvent("UNIT_FACTION")
	--frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")

	frame:SetScript("OnEvent", function()
		if event == "PARTY_MEMBERS_CHANGED" or 
				event == "RAID_ROSTER_UPDATE" or
				event == "RAID_TARGET_UPDATE" or
				event == "PARTY_LEADER_CHANGED" or
				event == "UNIT_FACTION" then
			--LazyPigMultibox_UpdateTeamFrame()
		end
	end)
	frame:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" and not this.isMoving then
			if this:IsMovable() then
				this:SetFrameStrata("TOOLTIP")
				this:StartMoving();
				this.isMoving = true;
			end
		end
	end)
	frame:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" and this.isMoving then
			this:StopMovingOrSizing();
			this:SetFrameStrata("MEDIUM")
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

	frame.partyunitframe = {} -- frame.unitframe[1] will always be "player" frame
						-- frame.unitframe[2] should always be "party1" frame
						-- frame.unitframe[3] should always be "party2" frame
						-- frame.unitframe[4] should always be "party3" frame
						-- frame.unitframe[5] should always be "party4" frame
	
	--frame = LazyPigMultibox_UpdateTeamFrame()

	--[[
	for _,v in pairs(frame.partyunitframe) do
		LazyPigMultibox_UpdateUnitFrame(v)
		LazyPigMultibox_UpdateXPBar(v)
	end
	]]

	return frame
end


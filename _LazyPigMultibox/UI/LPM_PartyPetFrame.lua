local HappinessColor = {
	  ["HAPPY"] = { { 0.20, 0.90, 0.20 }, "Happy" },
	["CONTENT"] = { { 0.93, 0.93, 0.0  }, "Content" },
	["UNHAPPY"] = { { 0.90, 0.0,  0.0  }, "Unhappy" },
}

local PowerColor = {
	["UNKNOWN"] = { { 0.51, 0.51, 0.51 }, "UNKNOWN" },
			[0] = { { 0.19, 0.44, 0.75 }, "Mana"  	},
			[1] = { { 0.89, 0.18, 0.29 }, "Rage"   	},
			[2] = { { 1.00, 0.70, 0.0  }, "Focus"  	},
			[3] = { { 1.00, 1.00, 0.13 }, "Energy" 	},
}

local function PartyPetFrame_UnitPetFrame(hParent, sUnit)
	-- offset calculation for every party member
	local n, offset_x, offset_y
	_, _, n = string.find(sUnit, "(%d+)")
	offset_x = math.floor((LPM_UI_SETTINGS.PARTYPETFRAME.WIDTH - LPM_UI_SETTINGS.UNITPETFRAME.WIDTH) / 2)
	if n then
		offset_y = -(LPMULTIBOX_UI.TUI_PADDING)
	else
		offset_y = -(LPM_UI_SETTINGS.PARTYPETFRAME.HEADER)
	end

	local frame = CreateFrame("Button", "LPM_PartyUnitPetFrame_" .. sUnit, hParent)
	frame.unit = sUnit
	frame.parent = hParent -- frame:GetParent()

	if frame.unit == 'playerpet' then
		frame:SetPoint("TOPLEFT", frame.parent, "TOPLEFT", offset_x, offset_y)
	elseif frame.unit == 'party1pet' then
		frame:SetPoint("TOPLEFT", frame.parent.unitpetframe['playerpet'], "BOTTOMLEFT", 0, offset_y)
	else
		frame:SetPoint("TOPLEFT", frame.parent.unitpetframe['party' .. n-1 .. 'pet'], "BOTTOMLEFT", 0, offset_y)
	end

	frame:SetWidth(LPM_UI_SETTINGS.UNITPETFRAME.WIDTH)
	frame:SetHeight(LPM_UI_SETTINGS.UNITPETFRAME.HEIGHT)
	frame:EnableMouse(true)
	frame:RegisterForClicks("LeftButtonUp")
	frame:SetBackdrop({ 
		bgFile = LPM_UI_SETTINGS.BG_TEXTURE_FILE,
	})
	frame:SetBackdropColor(.1, .1, .1, .37)

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

	local icon_combat = frame_icon:CreateTexture(nil, "ARTWORK")
	icon_combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	icon_combat:SetTexCoord(0.5, 1, 0, 0.5)
	icon_combat:SetPoint("CENTER", frame_icon, "BOTTOMRIGHT", -3, 7)
	icon_combat:SetHeight(16)
	icon_combat:SetWidth(16)
	icon_combat:Hide()

	frame.icon_combat = icon_combat

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

	----------
	-- Events
	----------
	frame:RegisterEvent("")

	frame:SetScript("OnEvent", function()

	end)
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

	---------------------------
	-- PartyPetUnitFrame Handlers
	---------------------------
	frame:SetScript("OnClick", function()
		--[[ frame_info, being on top of this, will handle clicks :( )]]
		local unit = this.unit
		if SpellIsTargeting() and arg1 == "RightButton" then
			SpellStopTargeting()
			return
		end
		if arg1 == "LeftButton" then
			if SpellIsTargeting() then
				SpellTargetUnit(unit)
			else
				TargetUnit(unit)
			end
		--elseif not (IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown()) then
			--dropdown for pets?
			--ToggleDropDownMenu(1, nil, this.dropdown, "cursor", 0, 0)
		end
	end)

	frame_info:SetScript("OnEnter", function()
		local parent = this:GetParent()
		local online = UnitIsConnected(parent.unit)
		if online and level > 0 and level < 61 then
			parent.fs_level:Show()
			local r, g, b, a = parent:GetBackdropColor()
			parent:SetBackdropColor(r, g, b, a + 0.15)
		end
	end)

	frame_info:SetScript("OnLeave", function()
		local parent = this:GetParent()
		local online = UnitIsConnected(parent.unit)
		local level = UnitLevel(parent.unit)
		if online and level > 0 and level < 61 then
			parent.fs_level:Hide()
			local r, g, b, a = parent:GetBackdropColor()
			parent:SetBackdropColor(r, g, b, a - 0.15)
		end
	end)

	frame_info:SetScript("OnMouseDown", function()
		this:GetParent():Click(arg1)
	end)

	frame:Hide()

	return frame
end

local function PartyPetFrame_Header()
	-- PartyFrame Header
	local partyframe = getglobal("LPM_PartyFrame")
	local frame = CreateFrame("Frame", "LPM_PartyPetFrame")

	frame:SetScale(LPMULTIBOX_UI.TUI_SCALE)
	
	frame:SetWidth(LPM_UI_SETTINGS.PARTYPETFRAME.WIDTH)
	--frame:SetHeight(LPM_UI_SETTINGS.PARTYPETFRAME.HEIGHT)
	frame:SetHeight(partyframe:GetHeight())
	
	if LPMULTIBOX_UI.TUI_PARTYPETFRAME_ATTACH then
		frame:SetPoint("BOTTOMLEFT", partyframe, "BOTTOMRIGHT", 3, 0)
	else
		frame:SetPoint("BOTTOMLEFT", LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.LEFT, LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.BOTTOM)
	end

	frame:SetBackdrop( {
		bgFile = LPM_UI_SETTINGS.BG_TEXTURE_FILE
	});
	frame:SetBackdropColor(.01, .01, .01, LPMULTIBOX_UI.TUI_BGALPHA)

	if LPMULTIBOX_UI.TUI_PARTYPETFRAME_LOCK then
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

	-- PartyPetFrame FontString
	local fs_title = frame:CreateFontString(nil, "ARTWORK")
	fs_title:SetPoint("CENTER", frame, "TOP", 0, -5)
	fs_title:SetFont(LPM_UI_SETTINGS.FONT_FILE, 7)
	fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
	fs_title:SetText("Wierd PartyPet Frame")

	frame.fs_title = fs_title


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
			--PartyPetFrame_Update(this)
		
		elseif event == "RAID_ROSTER_UPDATE" then
			LPM_DEBUG(" -- " .. event .. " - arg1: " .. tostring(arg1) .. " - arg2: " .. tostring(arg2))
		
		end
	end)
	frame:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" and not this.isMoving then
			if LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and LPMULTIBOX_UI.TUI_PARTYPETFRAME_ATTACH then
				local partyframe = getglobal("LPM_PartyFrame")
				if partyframe:IsMovable() then
					--this:SetFrameStrata("TOOLTIP")
					partyframe:SetFrameStrata("FULLSCREEN_DIALOG")
					this:SetFrameStrata("FULLSCREEN_DIALOG")
					--this:SetFrameStrata("FULLSCREEN")
					--this:SetFrameStrata("DIALOG")
					if UnitFactionGroup('player') == "Horde" then
						partyframe:SetBackdropColor(.17, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						partyframe.fs_title:SetTextColor(1, .71, .71, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						this:SetBackdropColor(.17, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						this.fs_title:SetTextColor(1, .71, .71, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					else
						partyframe:SetBackdropColor(.17, .17, .37, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						partyframe.fs_title:SetTextColor(.71, .71, 1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						this:SetBackdropColor(.17, .17, .37, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						this.fs_title:SetTextColor(.71, .71, 1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					end
					partyframe:StartMoving()
					partyframe.isMoving = true
					--this:StartMoving()
					this.isMoving = true
				end
			elseif LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and not LPMULTIBOX_UI.TUI_PARTYPETFRAME_LOCK then
				if this:IsMovable() then
					this:SetFrameStrata("FULLSCREEN_DIALOG")
					if UnitFactionGroup('player') == "Horde" then
						this:SetBackdropColor(.17, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						this.fs_title:SetTextColor(1, .71, .71, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					else
						this:SetBackdropColor(.17, .17, .37, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
						this.fs_title:SetTextColor(.71, .71, 1, LPMULTIBOX_UI.TUI_BGALPHA + 0.17)
					end
					this:StartMoving()
					this.isMoving = true
				end
			end
		end
	end)
	frame:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" and this.isMoving then
			if LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and LPMULTIBOX_UI.TUI_PARTYPETFRAME_ATTACH then
				local partyframe = getglobal("LPM_PartyFrame")
				partyframe:StopMovingOrSizing()
				this:StopMovingOrSizing()
				partyframe:SetFrameStrata("MEDIUM")
				this:SetFrameStrata("MEDIUM")
				partyframe:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
				partyframe.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
				this:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
				this.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
				partyframe.isMoving = false
				this.isMoving = false
				local left = partyframe:GetLeft()
				local bottom = partyframe:GetBottom()
				LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.LEFT = floor(left + 0.5)
				LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.BOTTOM = floor(bottom + 0.5)
				local left = this:GetLeft()
				local bottom = this:GetBottom()
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.LEFT = floor(left + 0.5)
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.BOTTOM = floor(bottom + 0.5)
			elseif LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and not LPMULTIBOX_UI.TUI_PARTYPETFRAME_LOCK then
				this:StopMovingOrSizing()
				this:SetFrameStrata("MEDIUM")
				this:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
				this.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
				this.isMoving = false
				local left = this:GetLeft()
				local bottom = this:GetBottom()
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.LEFT = floor(left + 0.5)
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.BOTTOM = floor(bottom + 0.5)
			end
		end
	end)
	frame:SetScript("OnHide", function()
		if this.isMoving then
			if LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and LPMULTIBOX_UI.TUI_PARTYPETFRAME_LOCK then
				local partyframe = getglobal("LPM_PartyFrame")
				partyframe:StopMovingOrSizing()
				this:StopMovingOrSizing()
				partyframe:SetFrameStrata("MEDIUM")
				this:SetFrameStrata("MEDIUM")
				partyframe:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
				partyframe.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
				this:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
				this.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
				partyframe.isMoving = false
				this.isMoving = false
				local left = partyframe:GetLeft()
				local bottom = partyframe:GetBottom()
				LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.LEFT = floor(left + 0.5)
				LPMULTIBOX_UI.TUI_PARTYFRAME_POINT.BOTTOM = floor(bottom + 0.5)
				local left = this:GetLeft()
				local bottom = this:GetBottom()
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.LEFT = floor(left + 0.5)
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.BOTTOM = floor(bottom + 0.5)
			elseif LPMULTIBOX_UI.TUI_PARTYPETFRAME_SHOW and not LPMULTIBOX_UI.TUI_PARTYPETFRAME_LOCK then
				this:StopMovingOrSizing()
				this:SetFrameStrata("MEDIUM")
				this:SetBackdropColor(.1, .1, .1, LPMULTIBOX_UI.TUI_BGALPHA)
				this.fs_title:SetTextColor(1, 1, 1, LPMULTIBOX_UI.TUI_BGALPHA)
				this.isMoving = false
				local left = this:GetLeft()
				local bottom = this:GetBottom()
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.LEFT = floor(left + 0.5)
				LPMULTIBOX_UI.TUI_PARTYPETFRAME_POINT.BOTTOM = floor(bottom + 0.5)
			end
		end
	end)

	return frame
end

function LPM_PartyPetFrame_Init(frame)

	if frame then 
		if frame.GetFrameType then
			frame:SetParent(nil)
		end
	end
	frame = {}

	frame = PartyPetFrame_Header()

	frame.unitpetframe = {}
	frame.unitpetframe['playerpet'] = PartyPetFrame_UnitPetFrame(frame, 'playerpet')
	frame.unitpetframe['party1pet'] = PartyPetFrame_UnitPetFrame(frame, 'party1pet')
	frame.unitpetframe['party2pet'] = PartyPetFrame_UnitPetFrame(frame, 'party2pet')
	frame.unitpetframe['party3pet'] = PartyPetFrame_UnitPetFrame(frame, 'party3pet')
	frame.unitpetframe['party4pet'] = PartyPetFrame_UnitPetFrame(frame, 'party4pet')

	--PartyPetFrame_Update(frame)

	return frame
end



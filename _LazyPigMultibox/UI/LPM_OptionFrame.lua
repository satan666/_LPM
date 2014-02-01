
LPMULTIBOX_UI = {
	TF_LOCK = false,
	TF_SHOW = true,
	TF_SCALE = 1.00,
	TF_PADDING = 3,
	TF_BACKGROUNDALPHA = 0.37,
	LF_LOCK = true,
	LF_SCALE = 1.00,
}


local CheckButtonTables = {
	["Follow Master"] = {
		[0] = "LPM_CheckButtonGroupMasterFollow",
		[1] = { "LPM_CheckButton00", "Always" ,""},
		[2] = { "LPM_CheckButton01", "No Enemy Target - Indoor", "" },
		[3] = { "LPM_CheckButton02", "No Enemy Target - Outdoor", ""},
		[4] = { "LPM_CheckButton03", "Combat End", ""},
		[5] = { "LPM_CheckButton04", "Spell Fail", ""},
		[6] = { "LPM_CheckButton05", "Master Shift Press", "" },
	},

	["Assist Master"] = {
		[0] = "LPM_CheckButtonGroupMasterAssist",
		[1] = { "LPM_CheckButton10", "Friend", "" },
		[2] = { "LPM_CheckButton12", "Enemy", "" },
		[3] = { "LPM_CheckButton13", "Active Enemy Only", "" },
		[4] = { "LPM_CheckButton14", "Active NPC Enemy Only", "" },
		[5] = { "LPM_CheckButton11", "Improved Targeting", "combined with active enemy assist mode, it allows you to enable Sniper Mode " },
	},

	["Follow Master Actions"] = {
		[0] = "LPM_CheckButtonGroupMasterAction",
		[1] = { "LPM_CheckButton20", "Release Spirit/Resurrection", "" },
		[2] = { "LPM_CheckButton21", "Taxi Pickup", "" },
		[3] = { "LPM_CheckButton22", "Dismount Control", "" },
		[4] = { "LPM_CheckButton23", "Quest Accept", "" },
		[5] = { "LPM_CheckButton24", "Trade Accept", "" },
		[6] = { "LPM_CheckButton25", "Logout/Cancel Logout", ""},
	},

	["Redirect Message --> Master"] = {
		[0] = "LPM_CheckButtonGroupMessages",
		[1] = { "LPM_CheckButton30", "Slave Lost", "" },
		[2] = { "LPM_CheckButton31", "Slave Spell Fail", "" },
		[3] = { "LPM_CheckButton32", "Whisper Redirect", "" },
	},
	
	["Use Predefined Class' Script"] = {
		[0] = "LPM_CheckButtonGroupScripts",
		[1] = { "LPM_CheckButton40", "DPS", "" },
		[2] = { "LPM_CheckButton41", "DPS + Pet", "" },
		[3] = { "LPM_CheckButton42", "Heal - Normal", "combined heals", "" },
		[4] = { "LPM_CheckButton45", "Heal - Fast", "only short cast time heals", "" },
		[5] = { "LPM_CheckButton43", "Quick Rez", "" },
		[6] = { "LPM_CheckButton46", "Smart Buff", "" },
		[7] = { "LPM_CheckButton44", "Unique Spell" , ""},
	},
	
	["Master Event-Handler"] = {
		[0] = "LPM_CheckButtonGroupEventHandler",
		[1] = { "LPM_CheckButton50", "Group Roll Manager", "" },
		[2] = { "LPM_CheckButton51", "Group Quest Share", "" },
		[3] = { "LPM_CheckButton52", "Set Free-for-All at Start", "" }
	},
}

local ButtonTables = {
	["Group Loot Management"] = {
		[0]	= "LPM_ButtonGroupLoot",
		[1] = { "LPM_LootFFA", "FFA Loot", function() SetLootMethod("freeforall") end},
		[2] = { "LPM_LootGroup", "Group Loot", function() SetLootMethod("group") end },
		[3] = { "LPM_LootMaster", "Master Loot", function() SetLootMethod("master", GetUnitName("player")) end },
	},

	["Group Action Manager"] = {
		[0]	= "LPM_ButtonGroupActions",
		[3] = { "LPM_ActionStuck", "Unstuck", Stuck },
		[2] = { "LPM_ActionReload", "Reload", ReloadUI },
		[1] = { "LPM_ActionLogout", "Logout", Logout },
	},

	["Group Management"] = {
		[0]	= "LPM_ButtonGroupManagement",
		[6] = { "LPM_GroupMakeLeader", "Make Me Leader", LazyPigMultibox_MakeMeLeader },
		[4] = { "LPM_GroupConvert", "Convert to Raid", ConvertToRaid },
		[5] = { "LPM_GroupDisband", "Disband Group", function() LazyPigMultibox_Annouce("lpm_hide_menu", "slave_only") LazyPigMultibox_DisbangGroup() end },
		[1] = { "LPM_GroupInviteAOE", "AoE Invite", function() LazyPigMultibox_AOEInvite(true) end },
		[2] = { "LPM_GroupInviteFriends", "Invite Friends", LazyPigMultibox_InviteFriends },
		[3] = { "LPM_GroupInviteGuildMates", "Invite Guildmates", LazyPigMultibox_InviteGuildMates },
	},
}

local function CheckButtonGroup(hParent, offsetX, offsetY, sTitle, tCheck)
	local frame = CreateFrame("Frame", tCheck[0], hParent)
	frame:SetPoint("TOPLEFT", hParent, "TOPLEFT", offsetX, offsetY)
	frame:SetWidth(11)
	frame:SetHeight(11)

	local fs_title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs_title:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	fs_title:SetTextColor(1, 1, 1, 1)
	fs_title:SetText(sTitle)

	frame.fs_title = fs_title

	frame.cb = {}

	for k,v in ipairs(tCheck) do
		local cb = CreateFrame("CheckButton", v[1], frame, "UICheckButtonTemplate")
		local cb_fs = getglobal(cb:GetName().."Text")
		cb:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 8, -(4+(k-1)*14))
		cb:SetWidth(16)
		cb:SetHeight(16)
		

		if v[2] then 
			cb.tooltipTitle = v[2]
			cb_fs:SetText(cb.tooltipTitle)
		end
		if v[3] then cb.tooltipText = v[3] end

		local num = tonumber(string.sub(v[1], string.find(v[1], "%d+")))

		cb:SetScript("OnShow", function()
			LazyPigMultibox_GetOption(num)
		end)
		cb:SetScript("OnClick", function()
			LazyPigMultibox_SetOption(num);
		end)
		cb:SetScript("OnEnter", function()
			if this.tooltipTitle then
				GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
				GameTooltip:SetScale(.71)
				GameTooltip:SetBackdropColor(.01, .01, .01, .91)
				GameTooltip:SetText(this.tooltipTitle)
				if this.tooltipText then
					GameTooltip:AddLine(this.tooltipText, 1, 1, 1)
				end
				GameTooltip:Show()
			end
		end)
		cb:SetScript("OnLeave", function()
			GameTooltip:Hide();
		end)

		frame.cb[k] = cb
	end

	return frame
end

local function ButtonGroup(hParent, offsetX, offsetY, sTitle, tCheck, bLongButton)
	local frame = CreateFrame("Frame", tCheck[0], hParent)
	frame:SetPoint("TOPLEFT", hParent, "TOPLEFT", offsetX, offsetY)
	frame:SetWidth(11)
	frame:SetHeight(11)

	local fs_title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	if not bLongButton then
		fs_title:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	else
		fs_title:SetPoint("TOP", frame, "TOPLEFT", 0, 0)
	end
	fs_title:SetTextColor(1, 1, 1, 1)
	fs_title:SetText(sTitle)

	frame.fs_title = fs_title

	frame.btn = {}

	for k,v in ipairs(tCheck) do
		local btn = CreateFrame("Button", v[1], frame, "GameMenuButtonTemplate")
		if not bLongButton then
			btn:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 12, -(4+(k-1)*18))
			local btnfs = btn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			btnfs:SetPoint("LEFT", btn, "RIGHT", 5, 0)
			btn:SetWidth(16)
			btn:SetHeight(16)
			btnfs:SetText(v[2])

			btn.btnfs= btn.fs
		else
			btn:SetPoint("TOP", frame, "BOTTOM", 0, -(4+(k-1)*18))
			btn:SetWidth(150)
			btn:SetHeight(16)
			btn:SetFont("Fonts\\FRIZQT__.TTF", 8)
			btn:SetText(v[2])
		end

		if v[3] then		
			btn:SetScript("OnClick", v[3])
		else
			btn:SetScript("OnClick", function()
			end)
		end

		frame.btn[k] = btn
	end

	return frame
end

local function CreateRollFrameOptionsFrame(hParent)
	-- RollFrame Options Frame
	local frame = CreateFrame("Frame", "LPM_RollFrame_OptionsFrame")
	frame:SetScale(.81)

	frame:SetWidth(200)
	frame:SetHeight(100)
	
	frame:SetPoint("TOPLEFT", hParent, "TOPRIGHT", 10, 0)
	frame:SetBackdrop( {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
			tile = true, 
			tileSize = 32, 
			edgeSize = 32, 
			insets = { left = 11, right = 12, top = 12, bottom = 11 }
		} );
	frame:SetBackdropColor(.01, .01, .01, .91)

	frame:EnableMouse(true)

	tinsert(UISpecialFrames,"LPM_RollFrame_OptionsFrame")

	--frame:Hide()

	-- MenuTitle Frame
	local texture_title = frame:CreateTexture("LPM_RollFrame_OptionsFrame_Title")
	texture_title:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header", true);
	texture_title:SetWidth(245)
	texture_title:SetHeight(58)
	texture_title:SetPoint("CENTER", frame, "TOP", 0, -20)

	frame.texture_title = texture_title

	-- MenuTitle FontString
	local fs_title = frame:CreateFontString("LPM_RollFrame_OptionsFrame_TitleText", "ARTWORK", "GameFontNormalSmall")
	fs_title:SetPoint("CENTER", frame.texture_title, "CENTER", 0, 12)
	fs_title:SetText("RollFrame Options")

	frame.fs_title = fs_title

	-- Lock the RollFrame
	local cb_lock = CreateFrame("CheckButton", "LPM_RollFrame_OptionsFrame_LockCheckButton", frame)
	cb_lock:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -25)
	local cbfs_lock = cb_lock:CreateFontString("LPM_RollFrame_OptionsFrame_LockCheckButtonText", "ARTWORK", "GameFontNormalSmall")
	cbfs_lock:SetPoint("LEFT", cb_lock, "RIGHT", 7, 0)
	cbfs_lock:SetText("Lock RollFrame")
	cb_lock:SetWidth(20)
	cb_lock:SetHeight(20)
	cb_lock:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	cb_lock:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	cb_lock:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	cb_lock:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	--cb_toggle:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	
	if LPMULTIBOX_UI.LF_LOCK then
		cb_lock:SetChecked(true)
	else
		cb_lock:SetChecked(false)
	end

	cb_lock.tooltipTitle = "RollFrame"
	cb_lock.tooltipText = "Check this to lock the RollFrame"
	
	frame.cb_lock = cb_lock
	frame.cbfs_lock = cbfs_lock

	frame.cb_lock:SetScript("OnClick", function()
		local status = this:GetChecked()
		local frame = getglobal("LPM_RollFrame")
		if status then
			frame:SetMovable(false)
			frame:RegisterForDrag()
			LPMULTIBOX_UI.LF_LOCK = true
		else
			frame:SetMovable(true)
			frame:RegisterForDrag("LeftButton")
			LPMULTIBOX_UI.LF_LOCK = false
		end
	end)
	frame.cb_lock:SetScript("OnEnter", function()
		if this.tooltipText then
			GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
			GameTooltip:SetScale(.71)
			GameTooltip:SetBackdropColor(.01, .01, .01, .91)
			GameTooltip:SetText(this.tooltipTitle)
			if this.tooltipText then
				GameTooltip:AddLine(this.tooltipText, 1, 1, 1)
				GameTooltip:Show()
			end
		end
	end)
	frame.cb_lock:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)

	--[[
	local btn_lock = CreateFrame("Button", "LPM_RollFrame_OptionsFrame_LockButton", frame, "UIPanelButtonTemplate")
	btn_lock:SetPoint("TOP", 0, -30)
	btn_lock:SetWidth(150)
	btn_lock:SetHeight(25)
	btn_lock:SetText("Lock RollFrame")
	]]
	
	local fs_scale = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs_scale:SetPoint("TOPLEFT", 30, -50)
	fs_scale:SetTextColor(1, 1, 1)
	fs_scale:SetText("Scale")
	
	local sl_scale = CreateFrame("Slider", "LPM_RollFrame_OptionsFrame_ScaleSlider", frame, "OptionsSliderTemplate")
	sl_scale:SetPoint("TOPLEFT", fs_scale, "BOTTOMLEFT", -10, 0)
	sl_scale:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
	sl_scale:SetHeight(14)
	sl_scale:SetOrientation("HORIZONTAL")
	sl_scale.tooltipText = "Set the RollFrame scale."
	getglobal(sl_scale:GetName() .. "Low"):SetText("0.25")
	getglobal(sl_scale:GetName() .. "High"):SetText("1.00")
	sl_scale:SetMinMaxValues(25, 100) 
	sl_scale:SetValueStep(1)
	-- ADD A DEFAULT SOMEWHERE!
	sl_scale:SetValue(LPMULTIBOX_UI.LF_SCALE * 100)
	getglobal(sl_scale:GetName() .. "Text"):SetText(string.format("%4.2f", tostring(sl_scale:GetValue()/100)))
	getglobal(sl_scale:GetName() .. "Text"):SetJustifyH("RIGHT")
	getglobal(sl_scale:GetName() .. "Text"):SetPoint("RIGHT", -5, 0)

	sl_scale:SetScript("OnValueChanged", function(self, value)
		local value = this:GetValue()
		getglobal(this:GetName().."Text"):SetText(string.format("%4.2f", tostring(value/100)))
		local frame = getglobal("LPM_LootFrame")
		frame:SetScale(value/100)
		LPMULTIBOX_UI.LF_SCALE = value/100
	end)

	frame:Hide()

	return frame
end

local function CreateTeamFrameOptionsFrame(hParent)
	-- RollFrame Options Frame
	local frame = CreateFrame("Frame", "LPM_TeamFrame_OptionsFrame")
	frame:SetScale(.81)

	frame:SetWidth(200)
	frame:SetHeight(200)
	
	frame:SetPoint("TOPLEFT", hParent.rollframeoption, "BOTTOMLEFT", 0, -10)
	frame:SetBackdrop( {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
			tile = true, 
			tileSize = 32, 
			edgeSize = 32, 
			insets = { left = 11, right = 12, top = 12, bottom = 11 }
		} );
	frame:SetBackdropColor(.01, .01, .01, .91)

	frame:EnableMouse(true)

	tinsert(UISpecialFrames,"LPM_TeamFrame_OptionsFrame")

	--frame:Hide()

	-- MenuTitle Frame
	local texture_title = frame:CreateTexture("LPM_TeamFrame_OptionsFrame_Title")
	texture_title:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header", true);
	texture_title:SetWidth(245)
	texture_title:SetHeight(58)
	texture_title:SetPoint("CENTER", frame, "TOP", 0, -20)

	frame.texture_title = texture_title

	-- MenuTitle FontString
	local fs_title = frame:CreateFontString("LPM_TeamFrame_OptionsFrame_TitleText", "ARTWORK", "GameFontNormalSmall")
	fs_title:SetPoint("CENTER", frame.texture_title, "CENTER", 0, 12)
	fs_title:SetText("TeamFrame Options")

	frame.fs_title = fs_title
	
	-- Lock the TeamFrame
	local cb_lock = CreateFrame("CheckButton", "LPM_TeamFrame_OptionsFrame_LockCheckButton", frame)
	cb_lock:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -25)
	local cbfs_lock = cb_lock:CreateFontString("LPM_TeamFrame_OptionsFrame_LockCheckButtonText", "ARTWORK", "GameFontNormalSmall")
	cbfs_lock:SetPoint("LEFT", cb_lock, "RIGHT", 7, 0)
	cbfs_lock:SetText("Lock TeamFrame")
	cb_lock:SetWidth(20)
	cb_lock:SetHeight(20)
	cb_lock:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	cb_lock:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	cb_lock:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	cb_lock:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	--cb_toggle:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	
	if LPMULTIBOX_UI.TF_LOCK then
		cb_lock:SetChecked(true)
	else
		cb_lock:SetChecked(false)
	end

	cb_lock.tooltipTitle = "TeamFrame"
	cb_lock.tooltipText = "Check this to lock the TeamFrame"
	
	frame.cb_lock = cb_lock
	frame.cbfs_lock = cbfs_lock

	frame.cb_lock:SetScript("OnClick", function()
		local status = this:GetChecked()
		local frame = getglobal("LPM_TeamFrame")
		if status then
			frame:SetMovable(false)
			frame:RegisterForDrag()
			LPMULTIBOX_UI.TF_LOCK = true
		else
			frame:SetMovable(true)
			frame:RegisterForDrag("LeftButton")
			LPMULTIBOX_UI.TF_LOCK = false
		end
	end)
	frame.cb_lock:SetScript("OnEnter", function()
		if this.tooltipText then
			GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
			GameTooltip:SetScale(.71)
			GameTooltip:SetBackdropColor(.01, .01, .01, .91)
			GameTooltip:SetText(this.tooltipTitle)
			if this.tooltipText then
				GameTooltip:AddLine(this.tooltipText, 1, 1, 1)
				GameTooltip:Show()
			end
		end
	end)
	frame.cb_lock:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)

	-- Show the TeamFrame
	local cb_show = CreateFrame("CheckButton", "LPM_TeamFrame_OptionsFrame_ShowCheckButton", frame)
	cb_show:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -45)
	local cbfs_show = cb_show:CreateFontString("LPM_TeamFrame_OptionsFrame_ShowCheckButtonText", "ARTWORK", "GameFontNormalSmall")
	cbfs_show:SetPoint("LEFT", cb_show, "RIGHT", 7, 0)
	cbfs_show:SetText("Show TeamFrame")
	cb_show:SetWidth(20)
	cb_show:SetHeight(20)
	cb_show:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	cb_show:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	cb_show:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	cb_show:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	--cb_toggle:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	
	if LPMULTIBOX_UI.TF_SHOW then
		cb_show:SetChecked(true)
	else
		cb_show:SetChecked(false)
	end
	
	cb_show.tooltipTitle = "TeamFrame"
	cb_show.tooltipText = "Check this to show the TeamFrame"
	
	frame.cb_show = cb_show
	frame.cbfs_show = cbfs_show

	frame.cb_show:SetScript("OnClick", function()
		local status = this:GetChecked()
		local frame = getglobal("LPM_TeamFrame")
		if status then
			frame:Show()
			LPMULTIBOX_UI.TF_SHOW = true
		else
			frame:Hide()
			LPMULTIBOX_UI.TF_FALSE = true
		end
	end)
	frame.cb_show:SetScript("OnEnter", function()
		if this.tooltipText then
			GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
			GameTooltip:SetScale(.71)
			GameTooltip:SetBackdropColor(.01, .01, .01, .91)
			GameTooltip:SetText(this.tooltipTitle)
			if this.tooltipText then
				GameTooltip:AddLine(this.tooltipText, 1, 1, 1)
				GameTooltip:Show()
			end
		end
	end)
	frame.cb_show:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)

	--[[
	local btn_lock = CreateFrame("Button", "LPM_TeamFrameOptionsFrameLockButton", frame, "UIPanelButtonTemplate")
	btn_lock:SetPoint("TOP", 0, -30)
	btn_lock:SetWidth(150)
	btn_lock:SetHeight(25)
	btn_lock:SetText("Lock TeamFrame")
	]]

	local fs_scale = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs_scale:SetPoint("TOPLEFT", 30, -70)
	fs_scale:SetTextColor(1, 1, 1)
	fs_scale:SetText("Scale")
	
	local sl_scale = CreateFrame("Slider", "LPM_TeamFrame_OptionsFrame_ScaleSlider", frame, "OptionsSliderTemplate")
	sl_scale:SetPoint("TOPLEFT", fs_scale, "BOTTOMLEFT", -10, 0)
	sl_scale:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
	sl_scale:SetHeight(15)
	sl_scale:SetOrientation("HORIZONTAL")
	sl_scale.tooltipText = "Set the TeamFrame scale."
	getglobal(sl_scale:GetName() .. "Low"):SetText("0.50")
	getglobal(sl_scale:GetName() .. "High"):SetText("1.50")
	sl_scale:SetMinMaxValues(50, 150) 
	sl_scale:SetValueStep(1)
	-- ADD A DEFAULT SOMEWHERE!
	sl_scale:SetValue(LPMULTIBOX_UI.TF_SCALE * 100)
	getglobal(sl_scale:GetName() .. "Text"):SetText(string.format("%4.2f", tostring(sl_scale:GetValue()/100)))
	getglobal(sl_scale:GetName() .. "Text"):SetJustifyH("RIGHT")
	getglobal(sl_scale:GetName() .. "Text"):SetPoint("RIGHT", -5, 0)

	sl_scale:SetScript("OnValueChanged", function()
		local value = this:GetValue()
		getglobal(this:GetName().."Text"):SetText(string.format("%4.2f", tostring(value/100)))
		local frame = getglobal("LPM_TeamFrame")
		frame:SetScale(value/100)
		LPMULTIBOX_UI.TF_SCALE = value/100
	end)

	local fs_padding = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs_padding:SetPoint("TOPLEFT", fs_scale, "BOTTOMLEFT", 0, -30)
	fs_padding:SetTextColor(1, 1, 1)
	fs_padding:SetText("Padding")
	
	local sl_padding = CreateFrame("Slider", "LPM_TeamFrame_OptionsFrame_PaddingSlider", frame, "OptionsSliderTemplate")
	sl_padding:SetPoint("TOPLEFT", fs_padding, "BOTTOMLEFT", -10, 0)
	sl_padding:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
	sl_padding:SetHeight(15)
	sl_padding:SetOrientation("HORIZONTAL")
	sl_padding.tooltipText = "Set the TeamFrame padding value."
	getglobal(sl_padding:GetName() .. "Low"):SetText("0")
	getglobal(sl_padding:GetName() .. "High"):SetText("50")
	sl_padding:SetMinMaxValues(0, 50) 
	sl_padding:SetValueStep(1)
	-- ADD A DEFAULT SOMEWHERE!
	sl_padding:SetValue(LPMULTIBOX_UI.TF_PADDING)
	getglobal(sl_padding:GetName() .. "Text"):SetText(tostring(sl_padding:GetValue()))
	getglobal(sl_padding:GetName() .. "Text"):SetJustifyH("RIGHT")
	getglobal(sl_padding:GetName() .. "Text"):SetPoint("RIGHT", -5, 0)

	sl_padding:SetScript("OnValueChanged", function()
		local value = this:GetValue()
		getglobal(this:GetName().."Text"):SetText(tostring(value))
		LPMULTIBOX_UI.TF_PADDING = value
	end)

	local fs_backgroundalpha = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs_backgroundalpha:SetPoint("TOPLEFT", fs_padding, "BOTTOMLEFT", 0, -30)
	fs_backgroundalpha:SetTextColor(1, 1, 1)
	fs_backgroundalpha:SetText("Background Alpha")
	
	local sl_backgroundalpha = CreateFrame("Slider", "LPM_TeamFrame_OptionsFrame_BackgroundSlider", frame, "OptionsSliderTemplate")
	sl_backgroundalpha:SetPoint("TOPLEFT", fs_backgroundalpha, "BOTTOMLEFT", -10, 0)
	sl_backgroundalpha:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
	sl_backgroundalpha:SetHeight(15)
	sl_backgroundalpha:SetOrientation("HORIZONTAL")
	sl_backgroundalpha.tooltipText = "Set the TeamFrame Background Alpha value."
	getglobal(sl_backgroundalpha:GetName() .. "Low"):SetText("0.00")
	getglobal(sl_backgroundalpha:GetName() .. "High"):SetText("1.00")
	sl_backgroundalpha:SetMinMaxValues(0, 100) 
	sl_backgroundalpha:SetValueStep(1)
	-- ADD A DEFAULT SOMEWHERE!
	sl_backgroundalpha:SetValue(LPMULTIBOX_UI.TF_BACKGROUNDALPHA * 100)
	getglobal(sl_backgroundalpha:GetName() .. "Text"):SetText(string.format("%4.2f", tostring(sl_backgroundalpha:GetValue()/100)))
	getglobal(sl_backgroundalpha:GetName() .. "Text"):SetJustifyH("RIGHT")
	getglobal(sl_backgroundalpha:GetName() .. "Text"):SetPoint("RIGHT", -5, 0)

	sl_backgroundalpha:SetScript("OnValueChanged", function(self, value)
		local value = this:GetValue()
		getglobal(this:GetName().."Text"):SetText(string.format("%4.2f", tostring(value/100)))
		local frame = getglobal("LPM_TeamFrame")
		frame:SetBackdropColor(.01, .01, .01, value/100)
		frame.fs_title:SetTextColor(1, 1, 1, value/100)
		LPMULTIBOX_UI.TF_BACKGROUNDALPHA = value/100
	end)

	frame:Hide()

	return frame
end

function LPM_CreateOptionsFrame()
	-- Option Frame
	local frame = CreateFrame("Frame", "LPM_OptionsFrame")
	frame:SetScale(.81)

	frame:SetWidth(570)
	frame:SetHeight(400)
	
	frame:SetPoint("TOP", nil, "CENTER", 0, 215)
	frame:SetBackdrop( {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
			tile = true, 
			tileSize = 32, 
			edgeSize = 32, 
			insets = { left = 11, right = 12, top = 12, bottom = 11 }
		} );
	frame:SetBackdropColor(.01, .01, .01, .91)

	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetUserPlaced(true)

	frame:SetClampedToScreen(false)
	frame:RegisterForDrag("LeftButton")
	
	tinsert(UISpecialFrames,"LPM_OptionsFrame")

	frame:Hide()

	frame:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" and not this.isMoving then
			this:StartMoving();
			this.isMoving = true;
		end
	end)
	frame:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" and this.isMoving then
			this:StopMovingOrSizing();
			this.isMoving = false;
		end
	end)
	frame:SetScript("OnHide", function()
		if this.isMoving then
			this:StopMovingOrSizing();
			this.isMoving = false;
		end
	end)

	-- MenuTitle Frame
	local texture_title = frame:CreateTexture("LPM_OptionsFrame_Title")
	texture_title:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header", true);
	texture_title:SetWidth(366)
	texture_title:SetHeight(58)
	texture_title:SetPoint("CENTER", frame, "TOP", 0, -20)

	frame.texture_title = texture_title

	-- MenuTitle FontString
	local fs_title = frame:CreateFontString("LPM_OptionsFrame_TitleText", "ARTWORK", "GameFontNormalSmall")
	fs_title:SetPoint("CENTER", frame.texture_title, "CENTER", 0, 12)
	fs_title:SetText("_LazyPig Multibox")

	frame.fs_title = fs_title
	--

	-- Enable Multiboxing CheckButton
	local cb_toggle = CreateFrame("CheckButton", "LPM_OptionsFrame_EnableCheckButton", frame)
	cb_toggle:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -25)
	local cbfs_toggle = cb_toggle:CreateFontString("LPM_OptionsFrame_EnableCheckButtonText", "ARTWORK", "GameFontNormalSmall")
	cbfs_toggle:SetPoint("LEFT", cb_toggle, "RIGHT", 7, 0)
	cbfs_toggle:SetText("Multibox Enabled")
	cb_toggle:SetWidth(20)
	cb_toggle:SetHeight(20)
	cb_toggle:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	cb_toggle:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	cb_toggle:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	cb_toggle:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	--cb_toggle:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	
	cb_toggle.tooltipTitle = "Multibox"
	cb_toggle.tooltipText = "Check this to enable Multibox behaviours"
	
	frame.cb_toggle = cb_toggle
	frame.cbfs_toggle = cbfs_toggle

	frame.cb_toggle:SetScript("OnClick", function()
		LazyPigMultibox_Toggle()
	end)
	frame.cb_toggle:SetScript("OnEnter", function()
		if this.tooltipText then
			GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
			GameTooltip:SetScale(.71)
			GameTooltip:SetBackdropColor(.01, .01, .01, .91)
			GameTooltip:SetText(this.tooltipTitle)
			if this.tooltipText then
				GameTooltip:AddLine(this.tooltipText, 1, 1, 1)
				GameTooltip:Show()
			end
		end
	end)
	frame.cb_toggle:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)

	-- Macro Creation Button
	local btn_macro = CreateFrame("Button", "LPM_OptionsFrame_MacroButton", frame, "GameMenuButtonTemplate")
	btn_macro:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -45)
	local btnfs_macro = btn_macro:CreateFontString("LPM_OptionsFrame_MacroButtonExtText", "ARTWORK", "GameFontNormalSmall")
	btnfs_macro:SetPoint("LEFT", btn_macro, "RIGHT", 5, 0)
	btnfs_macro:SetText("Create Macros")
	btn_macro:SetWidth(28)
	btn_macro:SetHeight(20)
	btn_macro:SetText("M")

	frame.btn_macro = btn_macro
	frame.btnfs_macro = btnfs_macro

	frame.btn_macro:SetScript("OnClick", function()
		LazyPigMultibox_CreateMacro()
	end)

	-- Sync Settings Button
	local btn_sync = CreateFrame("Button", "LPM_OptionsFrame_SyncButton", frame, "GameMenuButtonTemplate")
	btn_sync:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -65)
	local btnfs_sync = btn_sync:CreateFontString("LPM_OptionsFrame_SyncButtonExtText", "ARTWORK", "GameFontNormalSmall")
	btnfs_sync:SetPoint("LEFT", btn_sync, "RIGHT", 5, 0)
	btnfs_sync:SetText("Sync Settings")	
	btn_sync:SetWidth(28)
	btn_sync:SetHeight(20)
	btn_sync:SetText("S")

	frame.btn_sync = btn_sync
	frame.btnfs_sync = btnfs_sync

	frame.btn_sync:SetScript("OnClick", function()
		LazyPigMultibox_SettingsSync()
	end)

	-- QuickHeal Settings Button
	local btn_qhcfg = CreateFrame("Button", "LPM_OptionsFrame_QHCFGButton", frame, "GameMenuButtonTemplate")
	btn_qhcfg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -45)
	local btnfs_qhcfg = btn_qhcfg:CreateFontString("LPM_OptionsFrame_QHCFGButtonExtText", "ARTWORK", "GameFontNormalSmall")
	btnfs_qhcfg:SetPoint("RIGHT", btn_qhcfg, "LEFT", -5, 0)
	btnfs_qhcfg:SetText("QuickHeal Settings")
	btn_qhcfg:SetWidth(28)
	btn_qhcfg:SetHeight(20)
	btn_qhcfg:SetText("QH")

	frame.btn_qhcfg = btn_qhcfg
	frame.btnfs_qhcfg = btnfs_qhcfg

	frame.btn_qhcfg:SetScript("OnClick", function()
		QuickHeal_Command("cfg");
	end)

	-- SmartBuff Settings Button
	local btn_sbcfg = CreateFrame("Button", "LPM_OptionsFrame_SBCFGButton", frame, "GameMenuButtonTemplate")
	btn_sbcfg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -65)
	local btnfs_sbcfg = btn_sbcfg:CreateFontString("LPM_OptionsFrame_SBCFGButtonExtText", "ARTWORK", "GameFontNormalSmall")
	btnfs_sbcfg:SetPoint("RIGHT", btn_sbcfg, "LEFT", -5, 0)
	btnfs_sbcfg:SetText("SmartBuff Settings")
	btn_sbcfg:SetWidth(28)
	btn_sbcfg:SetHeight(20)
	btn_sbcfg:SetText("SB")

	frame.btn_sbcfg = btn_sbcfg
	frame.btnfs_sbcfg = btnfs_sbcfg

	frame.btn_sbcfg:SetScript("OnClick", function()
		SMARTBUFF_OptionsFrame_Toggle();
	end)


	-- Close Setting Window Button
	local btn_close = CreateFrame("Button", "LPM_OptionsFrame_Close", frame, "UIPanelCloseButton")
	btn_close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)
	btn_close:SetWidth(32)
	btn_close:SetHeight(32)

	frame.btn_close = btn_close

	frame.btn_close:SetScript("OnClick", function()
		this:GetParent():Hide()
		local frame = getglobal("LPM_RollFrame_OptionsFrame")
		frame:Hide()
		local frame = getglobal("LPM_TeamFrame_OptionsFrame")
		frame:Hide()
		LazyPigMultibox_Annouce("lpm_hide_menu", "")
	end)


	local btn_roll = CreateFrame("Button", "LPM_OptionsFrame_RollFrame_Button", frame, "UIPanelButtonTemplate")
	btn_roll:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -115, -20)
	btn_roll:SetWidth(72)
	btn_roll:SetHeight(16)
	btn_roll:SetFont("Fonts\\FRIZQT__.TTF", 8)
	btn_roll:SetText("RollFrame")

	frame.btn_roll = btn_roll

	frame.btn_roll:SetScript("OnClick", function()
		local frame = getglobal("LPM_RollFrame_OptionsFrame")
		if frame:IsVisible() then
			frame:Hide()
		else
			frame:Show()
		end
	end)

	
	local btn_team = CreateFrame("Button", "LPM_OptionsFrame_TeamFrame_Button", frame, "UIPanelButtonTemplate")
	btn_team:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -42, -20)
	btn_team:SetWidth(72)
	btn_team:SetHeight(16)
	btn_team:SetFont("Fonts\\FRIZQT__.TTF", 8)
	btn_team:SetText("TeamFrame")

	frame.btn_team = btn_team

	frame.btn_team:SetScript("OnClick", function()
		local frame = getglobal("LPM_TeamFrame_OptionsFrame")
		if frame:IsVisible() then
			frame:Hide()
		else
			frame:Show()
		end
	end)
	

	-- CheckButton Groups
	local str = "Follow Master"
	frame.cbgroup_masterfollow = CheckButtonGroup(frame, 30, -100, str, CheckButtonTables[str])

	local str = "Follow Master Actions"
	frame.cbgroup_masteraction = CheckButtonGroup(frame, 30, -205, str, CheckButtonTables[str])

	local str = "Master Event-Handler"
	frame.cbgroup_eventhandler = CheckButtonGroup(frame, 30, -310, str, CheckButtonTables[str])

	local str = "Assist Master"
	frame.cbgroup_masterassist = CheckButtonGroup(frame, 210, -100, str, CheckButtonTables[str])

	local str = "Redirect Message --> Master"
	frame.cbgroup_messages = CheckButtonGroup(frame, 210, -190, str, CheckButtonTables[str])

	local str = "Use Predefined Class' Script"
	frame.cbgroup_scripts = CheckButtonGroup(frame, 210, -255, str, CheckButtonTables[str])


	-- Button Groups
	local str = "Group Loot Management"
	--ButtonGroup(frame, 20, -100, str, ButtonTables[str], false)
	frame.btngroup_loot = ButtonGroup(frame, 450, -227, str, ButtonTables[str], true)

	local str = "Group Action Manager"
	--ButtonGroup(frame, 20, -170, str, ButtonTables[str], false)
	frame.btngroup_actions = ButtonGroup(frame, 450, -302, str, ButtonTables[str], true)

	local str = "Group Management"
	--ButtonGroup(frame, 20, -240, str, ButtonTables[str], false)
	frame.btngroup_management = ButtonGroup(frame, 450, -100, str, ButtonTables[str], true)

	frame.rollframeoption = CreateRollFrameOptionsFrame(frame)
	frame.teamframeoption = CreateTeamFrameOptionsFrame(frame)

	return frame

end
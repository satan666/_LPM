local CheckBoxTables = {
	["Follow Master"] = {
		[0] = "LazyPigMultiboxCheckboxGroupMasterFollow",
		[1] = { "LazyPigMultiboxCheckbox00", "Always" ,""},
		[2] = { "LazyPigMultiboxCheckbox01", "No Enemy Target - Indoor", "" },
		[3] = { "LazyPigMultiboxCheckbox02", "No Enemy Target - Outdoor", ""},
		[4] = { "LazyPigMultiboxCheckbox03", "Combat End", ""},
		[5] = { "LazyPigMultiboxCheckbox04", "Spell Fail", ""},
		[6] = { "LazyPigMultiboxCheckbox05", "Master Shift Press", "" },
	},

	["Assist Master"] = {
		[0] = "LazyPigMultiboxCheckboxGroupMasterAssist",
		[1] = { "LazyPigMultiboxCheckbox10", "Friend", "" },
		[2] = { "LazyPigMultiboxCheckbox12", "Enemy", "" },
		[3] = { "LazyPigMultiboxCheckbox13", "Active Enemy Only", "" },
		[4] = { "LazyPigMultiboxCheckbox14", "Active NPC Enemy Only", "" },
		[5] = { "LazyPigMultiboxCheckbox11", "Improved Targeting", "combined with active enemy assist mode, it allows you to enable Sniper Mode " },
	},

	["Follow Master Actions"] = {
		[0] = "LazyPigMultiboxCheckboxGroupMasterAction",
		[1] = { "LazyPigMultiboxCheckbox20", "Release Spirit/Resurrection", "" },
		[2] = { "LazyPigMultiboxCheckbox21", "Taxi Pickup", "" },
		[3] = { "LazyPigMultiboxCheckbox22", "Dismount Control", "" },
		[4] = { "LazyPigMultiboxCheckbox23", "Quest Accept", "" },
		[5] = { "LazyPigMultiboxCheckbox24", "Trade Accept", "" },
		[6] = { "LazyPigMultiboxCheckbox25", "Logout/Cancel Logout", ""},
	},

	["Redirect Message --> Master"] = {
		[0] = "LazyPigMultiboxCheckboxGroupMessages",
		[1] = { "LazyPigMultiboxCheckbox30", "Slave Lost", "" },
		[2] = { "LazyPigMultiboxCheckbox31", "Slave Spell Fail", "" },
		[3] = { "LazyPigMultiboxCheckbox32", "Whisper Redirect", "" },
	},
	
	["Use Predefined Class' Script"] = {
		[0] = "LazyPigMultiboxCheckboxGroupScripts",
		[1] = { "LazyPigMultiboxCheckbox40", "DPS", "" },
		[2] = { "LazyPigMultiboxCheckbox41", "DPS + Pet", "" },
		[3] = { "LazyPigMultiboxCheckbox42", "Heal - Normal", "combined heals", "" },
		[4] = { "LazyPigMultiboxCheckbox45", "Heal - Fast", "only short cast time heals", "" },
		[5] = { "LazyPigMultiboxCheckbox43", "Quick Rez", "" },
		[6] = { "LazyPigMultiboxCheckbox46", "Smart Buff", "" },
		[7] = { "LazyPigMultiboxCheckbox44", "Unique Spell" , ""},
	},
	
	["Master Event-Handler"] = {
		[0] = "LazyPigMultiboxCheckboxGroupEventHandler",
		[1] = { "LazyPigMultiboxCheckbox50", "Group Roll Manager", "" },
		[2] = { "LazyPigMultiboxCheckbox51", "Group Quest Share", "" },
		[3] = { "LazyPigMultiboxCheckbox52", "Set Free-for-All at Start", "" }
	},
}

local ButtonTables = {
	["Group Loot Management"] = {
		[0]	= "LazyPigMultiboxButtonGroupLoot",
		[1] = { "LazyMultiboxFFA", "FFA Loot", function() SetLootMethod("freeforall") end},
		[2] = { "LazyMultiboxGroup", "Group Loot", function() SetLootMethod("group") end },
		[3] = { "LazyMultiboxMaster", "Master Loot", function() SetLootMethod("master", GetUnitName("player")) end },
	},

	["Group Action Manager"] = {
		[0]	= "LazyPigMultiboxButtonGroupActions",
		[3] = { "LazyPigMultiboxStuck", "Unstuck", Stuck },
		[2] = { "LazyPigMultiboxReload", "Reload", ReloadUI },
		[1] = { "LazyPigMultiboxLogout", "Logout", Logout },
	},

	["Group Management"] = {
		[0]	= "LazyPigMultiboxButtonGroupManagement",
		[6] = { "LazyMultiboxMakeLeader", "Make Me Leader", LazyPigMultibox_MakeMeLeader },
		[4] = { "LazyMultiboxConvert", "Convert to Raid", ConvertToRaid },
		[5] = { "LazyPigMultiboxDisband", "Disband Group", function() LazyPigMultibox_Annouce("lpm_hide_menu", "slave_only") LazyPigMultibox_DisbangGroup() end },
		[1] = { "LazyPigMultiboxAOE", "AoE Invite", function() LazyPigMultibox_AOEInvite(true) end },
		[2] = { "LazyPigMultiboxFriends", "Invite Friends", LazyPigMultibox_InviteFriends },
		[3] = { "LazyPigMultiboxGuildMates", "Invite Guildmates", LazyPigMultibox_InviteGuildMates },
	},
}

local function CheckBoxGroup(hParent, offsetX, offsetY, sTitle, tCheck)
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
		cb:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 8, -(4+(k-1)*14))
		cb:SetWidth(16)
		cb:SetHeight(16)
		
		if v[2] then cb.tooltipTitle = v[2]; end
		if v[3] then cb.tooltipText = v[3]; end

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

function LazyPigMultibox_CreateOptionsFrame()
	-- Option Frame
	local frame = CreateFrame("Frame", "LazyPigMultiboxOptionsFrame")
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
	frame:SetClampedToScreen(false)
	frame:RegisterForDrag("LeftButton")
	--frame.showthis = false
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
	local texture_title = frame:CreateTexture("LazyPigMultiboxOptionsFrameTitle")
	texture_title:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header", true);
	texture_title:SetWidth(366)
	texture_title:SetHeight(58)
	texture_title:SetPoint("CENTER", frame, "TOP", 0, -20)

	frame.texture_title = texture_title

	-- MenuTitle FontString
	local fs_title = frame:CreateFontString("LazyPigMultiboxOptionsFrameTitleText", "ARTWORK", "GameFontNormalSmall")
	fs_title:SetPoint("CENTER", frame.texture_title, "CENTER", 0, 12)
	fs_title:SetText("_LazyPig Multibox")

	frame.fs_title = fs_title
	--

	-- Enable Multiboxing Checkbox
	local cb_toggle = CreateFrame("CheckButton", "LazyPigMultiboxEnableComboBox", frame)
	cb_toggle:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -25)
	local cbfs_toggle = cb_toggle:CreateFontString("LazyPigMultiboxEnableComboBoxText", "ARTWORK", "GameFontNormalSmall")
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
	local btn_macro = CreateFrame("Button", "LazyMultiboxMacro", frame, "GameMenuButtonTemplate")
	btn_macro:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -45)
	local btnfs_macro = btn_macro:CreateFontString("LazyPigMultiboxMacroExtText", "ARTWORK", "GameFontNormalSmall")
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
	local btn_sync = CreateFrame("Button", "LazyPigMultiboxSync", frame, "GameMenuButtonTemplate")
	btn_sync:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -65)
	local btnfs_sync = btn_sync:CreateFontString("LazyPigMultiboxSyncExtText", "ARTWORK", "GameFontNormalSmall")
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
	local btn_qhcfg = CreateFrame("Button", "LazyMultiboxQHCFG", frame, "GameMenuButtonTemplate")
	btn_qhcfg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -45)
	local btnfs_qhcfg = btn_qhcfg:CreateFontString("LazyMultiboxQHCFGExtText", "ARTWORK", "GameFontNormalSmall")
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
	local btn_sbcfg = CreateFrame("Button", "LazyMultiboxLPCFG", frame, "GameMenuButtonTemplate")
	btn_sbcfg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -65)
	local btnfs_sbcfg = btn_sbcfg:CreateFontString("LazyMultiboxLPCFGExtText", "ARTWORK", "GameFontNormalSmall")
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
	local btn_close = CreateFrame("Button", "LazyMultiboxPigClose", frame, "UIPanelCloseButton")
	btn_close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)
	btn_close:SetWidth(32)
	btn_close:SetHeight(32)

	frame.btn_close = btn_close

	frame.btn_close:SetScript("OnClick", function()
		this:GetParent():Hide()
		LazyPigMultibox_Annouce("lpm_hide_menu", "")
	end)

	-- Checkbox Groups
	local str = "Follow Master"
	frame.cbgroup_masterfollow = CheckBoxGroup(frame, 30, -100, str, CheckBoxTables[str])

	local str = "Follow Master Actions"
	frame.cbgroup_masteraction = CheckBoxGroup(frame, 30, -205, str, CheckBoxTables[str])

	local str = "Master Event-Handler"
	frame.cbgroup_eventhandler = CheckBoxGroup(frame, 30, -310, str, CheckBoxTables[str])

	local str = "Assist Master"
	frame.cbgroup_masterassist = CheckBoxGroup(frame, 210, -100, str, CheckBoxTables[str])

	local str = "Redirect Message --> Master"
	frame.cbgroup_messages = CheckBoxGroup(frame, 210, -190, str, CheckBoxTables[str])

	local str = "Use Predefined Class' Script"
	frame.cbgroup_scripts = CheckBoxGroup(frame, 210, -255, str, CheckBoxTables[str])


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

	return frame

end
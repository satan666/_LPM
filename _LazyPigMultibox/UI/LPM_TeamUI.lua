
LPM_UI_SETTINGS = {
	BG_TEXTURE_FILE = "Interface\\ChatFrame\\ChatFrameBackground",
	STATUSBAR_TEXTURE_FILE = "Interface\\AddOns\\_LazyPigMultibox\\Textures\\StatusBar",
	FONT_FILE = "Fonts\\ARIALN.TTF",
}

LPM_UI_SETTINGS.PARTYFRAME = {
	HEADER = 12,
	FOOTER = 4,
	WIDTH = 108,
	HEIGHT = 235,
}

LPM_UI_SETTINGS.PARTYPETFRAME = {
	HEADER = 12,
	FOOTER = 4,
	WIDTH = 68,
	HEIGHT = 235,
}

LPM_UI_SETTINGS.MINIFRAME = {
	HEADER = 12,
	FOOTER = 4,
	WIDTH = 80,
	HEIGHT = 235,
}

LPM_UI_SETTINGS.UNITFRAME = {
	WIDTH = 100,
	HEIGHT = 42,
}

LPM_UI_SETTINGS.UNITPETFRAME = {
	WIDTH = 60,
	HEIGHT = 18,
}
	
LPM_UI_SETTINGS.UNITMINIFRAME = {
	WIDTH = 60,
	HEIGHT = 18,
}

local TeamUI = {
	PartyFrame = nil,
	PartyPetFrame = nil,
	RaidFrame = nil,
	MiniFrame = nil,
}

local function TeamUI_Update()
	--local raidmembers = GetNumRaidMembers()
	local partymembers = GetNumPartyMembers()
	
	if partymembers > 0 or ( partymembers == 0 and LPMULTIBOX_UI.TF_PARTYSOLO_SHOW ) then
		--if LPMULTIBOX_UI.TF_MINIFRAME_SHOW then
		--	TeamUI.MiniFrame:Show()
		--elseif LPMULTIBOX_UI.TF_PARTYFRAME_SHOW then
		if LPMULTIBOX_UI.TUI_PARTYFRAME_SHOW and TeamUI.PartyFrame then
			TeamUI.PartyFrame:Show()
			if LPMULTIBOX_UI.TUI_PARTYFRAME_LOCK then
				TeamUI.PartyFrame:SetMovable(false)
				TeamUI.PartyFrame:RegisterForDrag()
			else
				TeamUI.PartyFrame:SetMovable(true)
				TeamUI.PartyFrame:RegisterForDrag("LeftButton")
			end
		end
	end

	--[[
	if raidmembers > 0 and LPMULTIBOX_UI.TF_RAIDFRAME_SHOW then
		TeamUI.RaidFrame:Show()
	end

	if not LPMULTIBOX_UI.TF_PARTYINRAID then
		if TeamUI.MiniFrame:IsVisible() then
			TeamUI.MiniFrame:Hide()
		end
		if TeamUI.PartyFrame:IsVisible() then
			TeamUI.PartyFrame:Hide()
		end
	end
	]]
	if LPMULTIBOX_UI.TF_PARTYPETFRAME_SHOW and TeamUI.PartFrame and TeamUI.PartyPetFrame then
		if TeamUI.PartFrame:IsVisible() or TeamUI.MiniFrame:IsVisible() then
			TeamUI.PartyPetFrame:Show()
		end
	end
end


function LPM_TeamUI_Init()
	if not TeamUI.PartyFrame then TeamUI.PartyFrame = LPM_PartyFrame_Init(TeamUI.PartyFrame) end
	--if not TeamUI.PartyPetFrame then TeamUI.PartyPetFrame = LPM_PartyPetFrame_Init() end
	--if not TeamUI.RaidFrame then TeamUI.RaidFrame = LPM_RaidFrame_Init() end
	--if not TeamUI.MiniFrame then TeamUI.MiniFrame = LPM_MiniFrame_Init() end

	for _,frame in pairs(TeamUI) do
		if frame then
			frame:Hide()
		end
	end

	local teamcontrol = CreateFrame("Frame")

	teamcontrol:RegisterEvent("RAID_TARGET_UPDATE")
	teamcontrol:RegisterEvent("PARTY_MEMBERS_CHANGED")
	teamcontrol:RegisterEvent("RAID_ROSTER_UPDATE")
	
	teamcontrol:SetScript("OnEvent", function()
		if event == "RAID_TARGET_UPDATE" then
			local s1 = tostring(arg1)
			local s2 = tostring(arg2)
			LPM_DEBUG(" -- " .. event .. " - arg1: " .. s1 .. " - arg2: " .. s2)
			
			TeamUI_Update()

		elseif event == "PARTY_MEMBERS_CHANGED" then
			local s1 = tostring(arg1)
			local s2 = tostring(arg2)
			LPM_DEBUG(" -- " .. event .. " - arg1: " .. s1 .. " - arg2: " .. s2)

		elseif event == "RAID_ROSTER_UPDATE" then
			local s1 = tostring(arg1)
			local s2 = tostring(arg2)
			LPM_DEBUG(" -- " .. event .. " - arg1: " .. s1 .. " - arg2: " .. s2)
	
		end
	end)

	TeamUI_Update()

	return true
end



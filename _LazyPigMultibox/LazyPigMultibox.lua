
LPMULTIBOX = {FIRSTUSE = true, STATUS = true, FM_ALWAYS = true, FM_NOENEMYINDOORS = false, FM_NOENEMYOUTDOORS = false, FM_COMABTENDS = false, FM_SPELLFAIL = false, AM_FRIEND = false, AM_KEEPTARGET = false, AM_ENEMY = true, AM_ACTIVEENEMY = false, AM_ACTIVENPCENEMY = false, SM_SLAVELOST = true, SM_SPELLFAIL = true, SM_REDIRECT = true, FA_RELEASE = true, FA_TAXIPICKUP = true, FA_DISMOUNT = true, FA_TRADE = true, FA_QUESTSHARE = true, FA_LOGOUT = true, SCRIPT_HEAL = true, SCRIPT_REZ = false, SCRIPT_DPS = true, SCRIPT_DPSPET = false, UNIQUE_SPELL = nil, SCRIPT_BUFF = true, SCRIPT_SHIFT = false, SCRIPT_FASTHEAL = false, POP_GROUPMINI = true, POP_QUESTSHARE = true, POP_FFA = true}

LPM_TARGET = {ACTIVE = nil, TOGGLE = nil}
LPM_SCHEDULE = {}
LPM_SCHEDULE_SPELL = {}
LPM_TAXI = {TIME = 0, NODE = ""}
LPM_TIMER = {TICK1 = 0, TICK2 = 0, TICK3 = 0, MASTER = 0, MODESET = 0, COMBATEND = nil, LOOTCONFIRM = nil, SPELLFAIL = 0, ASSIST = 0, SCRIPT_USE = 0, SHIFT_PRESS = 0, UTILIZE_TARGET = 0, ASSIST_MASTER = 0, MASTERATTACK = 0, SMARTBUFF = 0}
LPM_INFO = {MODE = nil, CONNECT =  {}, QSHARE = nil}
LPM_QUESTSHARE = {TITLE = nil, TIME}
LPM_QUEST = {}

BINDING_HEADER_LPM_HEADER = "_LazyPigMultibox";
BINDING_NAME_MULTIBOXMENU = "_LazyPig Multibox Menu";
BINDING_NAME_MULTIBOXTARGET = "Smart Enemy Target";
BINDING_NAME_MULTIBOXSCRIPT = "Multibox Macro";

local debug_on = 0

local Original_TakeTaxiNode = TakeTaxiNode;
local Original_RetrieveCorpse = RetrieveCorpse;
local Original_ReloadUI = ReloadUI;
local Original_Logout = Logout;
local Original_CancelLogout = CancelLogout;
local Original_Stuck = Stuck;
local Original_RepopMe = RepopMe;
local Original_AcceptTrade = AcceptTrade;
local Original_GroupLootFrame_OnShow = GroupLootFrame_OnShow;
local Original_StaticPopup_OnShow = StaticPopup_OnShow;
local Original_SMARTBUFF_AddMsgErr = SMARTBUFF_AddMsgErr;

StaticPopupDialogs["LPM_QUESTSHARE"] = {
text = "Share Quest ?",
button1 = TEXT(ACCEPT),
button2 = TEXT(CANCEL),
OnAccept = function()
	LazyPigMultibox_QuestShareConfirm();
end,
timeout = 0,
hideOnEscape = 1
};

StaticPopupDialogs["LPM_AUTO_SELF_CAST"] = {
	text = "LPM will not work properly with Blizzard's AutoSelfCast.  Please disable it.",
	button1 = TEXT(OKAY),
	OnAccept = function()
	end,
	timeout = 0,
	hideOnEscape = 1
}

local function lpm_print(...)
	local str = ""
	local lenght = table.getn(arg)
	for i = 1, table.getn(arg), 1 do
		if arg[i] then
			str = str .. tostring(arg[i])
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff9922ff[LPM]|r ".. tostring(str))
end

function LazyPigMultibox_Command(cmd)
	if cmd == "script" then
		LazyPigMultibox_UseClassScript();
	elseif cmd == "target" then	
		LazyPigMultibox_SmartEnemyTarget();
	elseif cmd == "roll" then	
		if LazyPigMultiboxRoll:IsShown() then
			LazyPigMultiboxRoll:Hide();
		else
			LazyPigMultiboxRoll:Show();
		end
	else
		--if LazyPigMultiboxOptions:IsShown() then
		if LazyPigMultiboxOptionsFrame:IsShown() then
			--LazyPigMultiboxOptions:Hide();
			LazyPigMultiboxOptionsFrame:Hide();
			LazyPigMultibox_Annouce("lpm_hide_menu", "");
		else
			--LazyPigMultiboxOptions:Show();
			LazyPigMultiboxOptionsFrame:Show();
			LazyPigMultibox_Annouce("lpm_show_menu", "");
		end
	end
end
 
function LazyPigMultibox_OnLoad()
	TakeTaxiNode = LazyPigMultibox_TakeTaxiNode;
	RetrieveCorpse = LazyPigMultibox_RetrieveCorpse;
	Logout = LazyPigMultibox_Logout;
	CancelLogout = LazyPigMultibox_CancelLogout;
	ReloadUI = LazyPigMultibox_ReloadUI;
	Stuck = LazyPigMultibox_Stuck;
	RepopMe = LazyPigMultibox_RepopMe;
	AcceptTrade = LazyPigMultibox_AcceptTrade;
	GroupLootFrame_OnShow = LazyPigMultibox_GroupLootFrame_OnShow;
	StaticPopup_OnShow = LazyPigMultibox_StaticPopup_OnShow;
	SMARTBUFF_AddMsgErr = LazyPigMultibox_SMARTBUFF_AddMsgErr
	
	SLASH_LAZYPIGMULTIBOX1 = "/lpm";
	SlashCmdList["LAZYPIGMULTIBOX"] = LazyPigMultibox_Command;
	
	this:RegisterEvent("ADDON_LOADED");
	--this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_LOGIN")
	--this:RegisterEvent("PLAYER_ENTERING_WORLD")
	--this:RegisterEvent("PLAYER_ALIVE")
end

function LazyPigMultibox_OnUpdate()
	local time = GetTime()
	
	if LPMULTIBOX.SCRIPT_SHIFT and LPM_TIMER.SHIFT_PRESS < time and IsShiftKeyDown() then
		LPM_TIMER.SHIFT_PRESS = time + 0.5
		LazyPigMultibox_Annouce("lpm_follow", "shift");
	end
	
	if LPM_TIMER.TICK1 < time then
		LPM_TIMER.TICK1 = time + 1
		if LPM_TIMER.ASSIST > 0 then
			LPM_TIMER.ASSIST = LPM_TIMER.ASSIST - 1
			--LazyPigMultibox_AssistMaster()
		end	
		
		if LPM_INFO.QSHARE then
			LazyPigMultibox_AcceptQuest()
			LPM_INFO.QSHARE = nil	
		end
		
		LazyPigMultibox_QuestShareUpdate();
		LazyPigMultibox_SetFFA();
		LazyPigMultibox_ShowMode();
	end
	
	if LPM_TIMER.TICK2 < time then
		LPM_TIMER.TICK2 = time + 4
		
		if LPMULTIBOX.FM_ALWAYS and LazyPigMultibox_SlaveCheck() then
			LazyPigMultibox_FollowMaster();
		end

	end
		
	if LPM_TIMER.TICK3 < time then
		LPM_TIMER.TICK3 = time + 8
		
		if not LazyPigMultibox_SlaveCheck() then 
			LazyPigMultibox_Annouce("lpm_tick", ""); 
		end
		
		if SMARTBUFF_Options and LPM_TIMER.SMARTBUFF and LPM_TIMER.SMARTBUFF < time then
			LPM_TIMER.SMARTBUFF = nil
			SMARTBUFF_Options.TargetSwitch = nil
			SMARTBUFF_Options.ToggleMsgNormal = true
			SMARTBUFF_Options.ToggleMsgWarning = true
		end
	end	

	if LPM_TIMER.COMBATEND and LPM_TIMER.COMBATEND < time then
		LazyPigMultibox_Annouce("lpm_follow", "combat");
		LPM_TIMER.COMBATEND = nil
	end
	
	if LPM_TIMER.LOOTCONFIRM and LPM_TIMER.LOOTCONFIRM < time then
		LazyPigMultibox_ConfirmLoot();
		LPM_TIMER.LOOTCONFIRM = nil
	end
	
	LazyPigMultibox_UtilizeTarget();
	LazyPigMultibox_Message();
end

function LazyPigMultibox_OnEvent(event)
	if (event == "ADDON_LOADED") and (arg1 == "_LazyPigMultibox") then
		local LPM_TITLE = GetAddOnMetadata("_LazyPigMultibox", "Title")
		local LPM_VERSION = GetAddOnMetadata("_LazyPigMultibox", "Version")
		local LPM_AUTHOR = GetAddOnMetadata("_LazyPigMultibox", "Author")
		DEFAULT_CHAT_FRAME:AddMessage(LPM_TITLE .. " v" .. LPM_VERSION .. " by " .."|cffFF0066".. LPM_AUTHOR .."|cffffffff".. " loaded, type |cff00eeee".." /lpm".."|cffffffff for options")
		--DEFAULT_CHAT_FRAME:AddMessage("_LazyPig Multibox v" .. LPM_VERSION .. " by Ogrisch loaded - type |cff00eeee".." /lpm".."|cffffffff for options")
	elseif (event == "PLAYER_LOGIN") then
		--this:UnregisterEvent("PLAYER_ENTERING_WORLD");
		--[[
		this:RegisterEvent("START_LOOT_ROLL");
		this:RegisterEvent("CANCEL_LOOT_ROLL");
		this:RegisterEvent("CHAT_MSG_LOOT");
		this:RegisterEvent("CONFIRM_LOOT_ROLL");
		this:RegisterEvent("LOOT_BIND_CONFIRM");
		this:RegisterEvent("LOOT_ROLLS_COMPLETE");
		this:RegisterEvent("INSTANCE_BOOT_START");
		this:RegisterEvent("INSTANCE_BOOT_STOP");
		]]

		this:RegisterEvent("PARTY_LEADER_CHANGED");
		this:RegisterEvent("RAID_ROSTER_UPDATE");
		this:RegisterEvent("PARTY_MEMBERS_CHANGED");
		this:RegisterEvent("CHAT_MSG_ADDON");
		this:RegisterEvent("PLAYER_REGEN_ENABLED");
		this:RegisterEvent("TAXIMAP_OPENED");
		this:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER");
		this:RegisterEvent("CHAT_MSG_WHISPER")
		this:RegisterEvent("AUTOFOLLOW_END")
		this:RegisterEvent("QUEST_ACCEPT_CONFIRM")
		this:RegisterEvent("QUEST_DETAIL")
		this:RegisterEvent("UI_ERROR_MESSAGE")
		this:RegisterEvent("PLAYER_TARGET_CHANGED")
		this:RegisterEvent("RESURRECT_REQUEST")
		this:RegisterEvent("QUEST_LOG_UPDATE");
		this:RegisterEvent("CHAT_MSG_SYSTEM");
		
		LazyPigMultiboxOptionsFrame = LazyPigMultibox_CreateOptionsFrame()

		LazyPigMultibox_MenuSet();
		LazyPigMultibox_ShowMode(true);
		LazyPigMultibox_SetFFA(true);
		LPM_QUEST = LazyPigMultibox_QuestLogScan();
		
		Zorlen_MakeFirstMacros = nil
		ZorlenConfig[ZORLEN_ZPN][ZORLEN_AUTOMOBIMMUNEOFF] = true
		setglobal('QUEST_DESCRIPTION_GRADIENT_CPS',600000);
		
		
		if GetCVar("AutoSelfCast") == "1" then
			StaticPopup_Show("LPM_AUTO_SELF_CAST")
			return
		end
		
		
		if SMARTBUFF_Options then
			LPM_TIMER.SMARTBUFF = GetTime() + 8
		end
		
		if LPMULTIBOX.FIRSTUSE then
			LazyPigMultiboxOptionsFrame:Show();
			--LazyPigMultiboxOptions:Show();
			LPMULTIBOX.FIRSTUSE = false
			LPCONFIG.SINV = true
		end
		
	elseif (event == "PARTY_LEADER_CHANGED" or event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED") then
		LazyPigMultibox_SetFFA(true);
		LazyPigMultibox_MenuSet();
		LazyPigMultibox_ShowMode(true);
		
	elseif(event == "CHAT_MSG_ADDON" and arg4 ~= GetUnitName("player")) then
		LazyPigMultibox_Annouce(arg1, arg2, arg4);
	
	elseif(event == "PLAYER_REGEN_ENABLED") then
		LPM_TIMER.MASTERATTACK = 0
		LPM_TIMER.COMBATEND = GetTime() + 2
		LazyPigMultibox_Annouce("lpm_follow", "combat");
		
	elseif(event == "TAXIMAP_OPENED") then
		LazyPigMultibox_Taxi();
		
	elseif(event == "AUTOFOLLOW_END") then
		LazyPigMultibox_FollowMaster("end");
		
	elseif(event == "QUEST_ACCEPT_CONFIRM" or event == "QUEST_DETAIL") then
		if LPMULTIBOX.STATUS and LazyPigMultibox_SlaveCheck() and (not UnitExists("target") or UnitIsPlayer("target")) then
			LazyPigMultibox_AcceptQuest();
		end	
		
	elseif(event == "CHAT_MSG_WHISPER" and arg1 and arg2) then		
		LazyPigMultibox_WhisperRedirect(arg1, arg2);
		
	elseif(event == "CHAT_MSG_SPELL_FAILED_LOCALPLAYER") then
		LazyPigMultibox_CheckError(arg1);
		LazyPigMultibox_FollowMaster("spell");
		
	elseif(event == "UI_ERROR_MESSAGE") then
		LazyPigMultibox_CheckError(arg1);
	
	elseif(event == "PLAYER_TARGET_CHANGED") then		
		local unit = LazyPigMultibox_ReturnLeaderUnit()
		local leader = unit and UnitIsUnit(unit, "player")
		
		if leader then		
			if UnitExists("target") and not UnitIsDeadOrGhost("target") then
				LazyPigMultibox_Annouce("lpm_target", "set");
			else
				LazyPigMultibox_Annouce("lpm_target", "reset");
			end
			LazyPigMultibox_Annouce("lpm_assist", "");
		elseif not UnitExists("target") and LPM_TARGET.ACTIVE then
			LazyPigMultibox_AssistMaster();
		end
	elseif(event == "RESURRECT_REQUEST") then
		if LPMULTIBOX.FA_RELEASE then	
			AcceptResurrect();
			StaticPopup_Hide("RESURRECT_NO_TIMER"); 
			StaticPopup_Hide("RESURRECT_NO_SICKNESS");
			StaticPopup_Hide("RESURRECT");
		end	
	elseif(event == "QUEST_LOG_UPDATE") then
		LazyPigMultibox_QuestShare();
		LPM_QUEST = LazyPigMultibox_QuestLogScan();
	
	elseif (event == "CHAT_MSG_SYSTEM" and arg1 and string.find(string.lower(arg1), "full") and UnitIsPartyLeader("player")) then
		LazyPigMultibox_Message(arg1, nil, 3.5);
	end

	--LPM_DEBUG("LazyPigMultibox_OnEvent - "..event)
end

function LazyPigMultibox_CheckError(msg)
	msg = string.gsub(msg,"([^}]-):(%s)","")
	
	if string.find(msg, "Can't do that while moving") or string.find(msg, "Can't do that while stunned") then
		return
	end
	
	if(string.find(msg, SPELL_FAILED_NOT_BEHIND) or
		string.find(msg, SPELL_FAILED_LINE_OF_SIGHT) or
		string.find(msg, SPELL_FAILED_OUT_OF_RANGE) or
		string.find(msg, SPELL_FAILED_NOT_INFRONT) or
		string.find(msg, ERR_BADATTACKFACING) or
		string.find(msg, ERR_BADATTACKPOS) or
		string.find(msg, SPELL_FAILED_UNIT_NOT_INFRONT)) then
		
		if UnitAffectingCombat("player") and LPMULTIBOX.SM_SPELLFAIL then
			LazyPigMultibox_SpellFail(msg);
		end	

	elseif(string.find(msg, ERR_INV_FULL) or 
		string.find(msg, "You do not have enough free slots") or 
		string.find(msg, SPELL_FAILED_NEED_AMMO)) then
		LazyPigMultibox_SpellFail(msg);
	
	elseif(UnitAffectingCombat("player") and string.find(msg, "Can't do that while")) then
		LazyPigMultibox_SpellFail(msg);

		--"Can't do that while polymorphed"
		--"Can't do that while asleep"
		--SPELL_FAILED_FLEEING
	
	end	
	--DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function LazyPigMultibox_Message(show, sender, duration)
	if show then
		duration = duration or 2.5
		if sender and sender ~= "" then sender = sender..": " else sender = "" end	
		LazyPigMultiboxAnnouceText:SetTextColor(0, 1, 0)
		LazyPigMultiboxAnnouceText:SetText(sender..show)
		LazyPigMultiboxAnnouceText:Show()
		Zorlen_SetTimer(duration, "LazyPigMultiboxAnnouceText")
	else
		if not Zorlen_IsTimer("LazyPigMultiboxAnnouceText") then
			LazyPigMultiboxAnnouceText:SetText()
			LazyPigMultiboxAnnouceText:Hide()
		end
	end
end

function LPM_DEBUG(text)
	if debug_on == 1 then
		DEFAULT_CHAT_FRAME:AddMessage("|cff00eeeeLPM Debug: |cffffffff"..text)
	end
end

function LPM_STATUS(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cff00eeee_LazyPig Multibox: |cffffffff"..text)
end

function LazyPigMultibox_Annouce(mode, message, sender)
	local time = GetTime()
	local leader_id = LazyPigMultibox_ReturnLeaderUnit()
	local player_name = GetUnitName("player")
	local sender_name = sender or "Player"
	local self_annouce = sender_name == "Player"
	
	--DEFAULT_CHAT_FRAME:AddMessage(mode..message..sender_name)
	
	if LPMULTIBOX.STATUS then
		if self_annouce then
			SendAddonMessage(mode, message, "RAID")
			return
		
		elseif leader_id and sender_name == GetUnitName(leader_id) and sender_name ~= player_name then
			LPM_DEBUG("LazyPigMultibox_Annouce(Slave) - "..mode.." - "..message);
			
			if(mode == "lpm_masterattack") then
				LPM_TIMER.MASTERATTACK = time + 1.5
			
			elseif(mode == "lpm_schedule") then
				local name, task, duration = LazyPigMultibox_DataStringDecode(message);

				--DEFAULT_CHAT_FRAME:AddMessage(l_name.."."..string.lower(GetUnitName("player")))
				if string.lower(name) == string.lower(GetUnitName("player")) then
					LazyPigMultibox_Schedule(task, duration);
				end
			
			elseif(mode == "lpm_schedule_spell") then
				local name, spell, duration, mana = LazyPigMultibox_DataStringDecode(message);
				
				if string.lower(name) == string.lower(GetUnitName("player")) then
					LazyPigMultibox_ScheduleSpell(spell, tonumber(duration), tonumber(mana));
					--DEFAULT_CHAT_FRAME:AddMessage(spell..tonumber(duration)..tonumber(mana))
				end

			elseif(mode == "lpm_unitbuff") then
				if string.lower(message) == string.lower(GetUnitName("player")) or string.lower(message) == "all" then
					LazyPigMultibox_Schedule("unitbuff", 10)
				end
				
			elseif(mode == "lpm_petattack") then
				if string.lower(message) == string.lower(GetUnitName("player")) then
					--DEFAULT_CHAT_FRAME:AddMessage(message)
					LazyPigMultibox_AssistMaster(true)
					LazyPigMultibox_Schedule("petattack", 0.25)
				end
			
			elseif(mode == "lpm_target") then
				if message == "set" then
					LPM_TARGET.ACTIVE = true
				elseif message == "reset" then
					LPM_TARGET.ACTIVE = nil
					LazyPigMultibox_UtilizeTarget(true)
				end	
			
			elseif(mode == "lpm_reload") then
				LazyPigMultibox_Schedule("reload");
			
			elseif(mode == "lpm_stuck") then
				LazyPigMultibox_Schedule("stuck");
				
			elseif(mode == "lpm_repopme") then
				if LPMULTIBOX.FA_RELEASE then
					Original_RepopMe();
				end
			elseif(mode == "lpm_logout") then
				if LPMULTIBOX.FA_LOGOUT then
					Original_Logout();
				end
				
			elseif(mode == "lpm_cancellogout") then
				if LPMULTIBOX.FA_LOGOUT then
					for i=1,STATICPOPUP_NUMDIALOGS do
						local frame = getglobal("StaticPopup"..i)
						if frame:IsShown() then
							if frame.which == "CAMP"  then
								getglobal("StaticPopup"..i.."Button1"):Click();
							end
						end
					end
				end	

			elseif(mode == "lpm_resurect") then
				if LPMULTIBOX.FA_RELEASE then
					Original_RetrieveCorpse();
				end
			elseif(mode == "lpm_tick") then	
				LPM_TIMER.MASTER = time + 10
				
			elseif(mode == "lpm_taxiset") then	
				LPM_TAXI.TIME = time + 30
				LPM_TAXI.NODE = message
				
			elseif(mode == "lpm_follow") then		
				LazyPigMultibox_FollowMaster(message);
			
			elseif(mode == "lpm_sync") then
				LazyPigMultibox_DataReceive(mode, message, sender)
			
			elseif(mode == "lpm_who") then	
				LazyPigMultibox_ShowMode(true);
				
			elseif(mode == "lpm_roll") then
				LazyPigMultibox_Roll(tonumber(message))
			
			elseif(mode == "lpm_assist") then
				LPM_TIMER.ASSIST = 3
			
			elseif(mode == "lpm_qaccept") then
				LPM_INFO.QSHARE = true	
			end
		
		elseif leader_id and player_name == GetUnitName(leader_id) and sender_name ~= player_name then
			if(mode == "lpm_slaveannouce" and message) then
				LazyPigMultibox_Message(message, sender)
			
			elseif(mode == "lpm_req") then
				LazyPigMultibox_DataSend()
				
			elseif(mode == "lpm_dataok") then
				LPM_STATUS(sender.." data sync complete !")
			
			elseif(mode == "lpm_enable") then
				if not LPM_INFO.CONNECT[sender] then	
					LPM_INFO.CONNECT[sender] = true
					LPM_STATUS(sender.." connected !")
				end
			
			elseif(mode == "lpm_makemeleader") then
				local sender_unit = LazyPigMultibox_ReturnUnit(sender_name)
				if sender_unit then
					PromoteToPartyLeader(sender_unit)
				end	
				
			end
		end

		if(mode == "lpm_show_menu") then
			LazyPigMultiboxOptionsFrame:Show();
		
		elseif(mode == "lpm_hide_menu" and (message == "" or message == "slave_only" and LazyPigMultibox_SlaveCheck())) then
			LazyPigMultiboxOptionsFrame:Hide();	
		
		elseif(mode == "lpm_tradeaccept") then
			if LPMULTIBOX.FA_TRADE then
				Original_AcceptTrade();
			end	
		
		elseif(mode == "lpm_unique_spell" and message == UnitClass("player") and LPMULTIBOX.UNIQUE_SPELL) then
			LPMULTIBOX.UNIQUE_SPELL = nil
			LazyPigMultibox_Message("Unique Spell - Disabled")
			LazyPigMultibox_Command();
			LazyPigMultibox_Command();
		end
	end
end

 function LazyPigMultibox_StaticPopup_OnShow()
	--DEFAULT_CHAT_FRAME:AddMessage(this.which)
	if LPMULTIBOX.STATUS and LPMULTIBOX.FA_QUESTSHARE and this.which == "QUEST_ACCEPT"  then
		for i=1,STATICPOPUP_NUMDIALOGS do
			local frame = getglobal("StaticPopup"..i)
			if frame:IsShown() then
				if frame.which == "QUEST_ACCEPT"  then
					getglobal("StaticPopup"..i.."Button1"):Click();
				end
			end
		end
	else
		Original_StaticPopup_OnShow()
	end	
 end

function LazyPigMultibox_Schedule(task, duration)
	local val = nil
	if task then
		duration = duration or 3
		local time = GetTime() + duration
		if string.lower(task) == "stuck" then
			LPM_SCHEDULE["Stuck()"] = time
		elseif string.lower(task) == "reload" then
			LPM_SCHEDULE["ReloadUI()"] = time
		elseif string.lower(task) == "petattack" then
			if not LazyPigMultibox_CheckDelayMode() or not Zorlen_isEnemy("target") then
				return
			end	
			LPM_SCHEDULE["PetAttack()"] = time
			LazyPigMultibox_Annouce("lpm_slaveannouce","Pet Attack")
		elseif string.lower(task) == "unitbuff" then
			LPM_SCHEDULE["LazyPigMultibox_UnitBuff()"] = time
			LazyPigMultibox_Annouce("lpm_slaveannouce","Smart Buff")
		elseif task then
			LPM_SCHEDULE[task] = time
		end
	else
		for blockindex,blockmatch in pairs(LPM_SCHEDULE) do
			if blockmatch > GetTime() then
				local load = assert(loadstring(blockindex))
				if load then
					load();
				end	
			end	
		end	
	end
	
	return nil  --inactive due to serious issue
end

function LazyPigMultibox_ScheduleSpell(task, duration, mana)
	local time = GetTime()
	local val = nil
	
	if task then
		mana = tonumber(mana) or 0
		duration = tonumber(duration) or 3
		
		if Zorlen_IsSpellKnown(task) then
			local spell_cd = LazyPigMultibox_GetCooldownByName(task)
			if spell_cd > duration then
				LazyPigMultibox_Annouce("lpm_slaveannouce", task.." CD "..spell_cd)
				LazyPigMultibox_Message(task.." CD "..spell_cd.."s")
			else
				local str = LazyPigMultibox_DataStringEncode(task, mana)
				LPM_SCHEDULE_SPELL[str] = time + duration
			end	
		else
			LazyPigMultibox_Annouce("lpm_slaveannouce","Invalid or Unknown Spell: "..task)
			LazyPigMultibox_Message("Invalid or Unknown Spell: "..task)
		end
	else
		for blockindex,blockmatch in pairs(LPM_SCHEDULE_SPELL) do
			if blockmatch > time then
				local task, mana = LazyPigMultibox_DataStringDecode(blockindex)
				mana = tonumber(mana)
				
				if Zorlen_isChanneling(task) or Zorlen_isCasting(task) or Zorlen_IsTimer("LazyPigMultibox"..task) then
					
					return true
				end
				if Zorlen_isCasting() or Zorlen_isChanneling() then
					if Zorlen_CastingSpellName or Zorlen_ChannelingSpellName then
						LazyPigMultibox_Annouce("lpm_slaveannouce","Preparing for Cast: "..task)
						LazyPigMultibox_Message("Preparing for Cast: "..task)
					end
					SpellStopCasting()
					val = true
				elseif UnitClass("player") == "Warlock" and Zorlen_HealthPercent("player") > 25 and UnitMana("player") < mana and castLifeTap() then
					val = true
				elseif UnitMana("player") >= mana and Zorlen_castSpellByName(task) then
					LazyPigMultibox_Annouce("lpm_slaveannouce","Casting: "..task)
					LazyPigMultibox_Message("Casting: "..task)
					Zorlen_SetTimer(1, "LazyPigMultibox"..task)
					val = true
				end	
			end	
		end
		
	end
	return val
end

function LazyPigMultibox_GetCooldownByName(SpellName)
	local B = Book or BOOKTYPE_SPELL
	local SpellID = Zorlen_GetSpellID(SpellName, 0, Book)
	
	if SpellID then
		local start, duration, enabled = GetSpellCooldown(SpellID, B)
		if enabled == 0 then
			return 0
		elseif ( start > 0 and duration > 0) then
			return math.floor(start + duration - GetTime())
		end	
	else
		return nil
	end
	return 0
end

function LazyPigMultibox_ReloadUI()
	LazyPigMultibox_Annouce("lpm_reload", "")
	Original_ReloadUI()
end

function LazyPigMultibox_Stuck()
	LazyPigMultibox_Annouce("lpm_stuck", "")
	Original_Stuck()
end

function LazyPigMultibox_RepopMe()
	LazyPigMultibox_Annouce("lpm_repopme", "")
	Original_RepopMe()
end

function LazyPigMultibox_Logout()
	LazyPigMultibox_Annouce("lpm_logout", "")
	Original_Logout()
end

function LazyPigMultibox_CancelLogout()
	if not IsShiftKeyDown() then LazyPigMultibox_Annouce("lpm_cancellogout", "") end
	Original_CancelLogout()
end

function LazyPigMultibox_TakeTaxiNode(index)
	LazyPigMultibox_Annouce("lpm_taxiset", TaxiNodeName(index))
	Original_TakeTaxiNode(index)
end

function LazyPigMultibox_RetrieveCorpse()
	LazyPigMultibox_Annouce("lpm_resurect", "")
	Original_RetrieveCorpse()
end

function LazyPigMultibox_UseAction(slot, checkCursor, onSelf)
	Original_UseAction(slot, checkCursor, onSelf)
end

function LazyPigMultibox_AcceptTrade()
	LazyPigMultibox_Annouce("lpm_tradeaccept", "")
	Original_AcceptTrade()
end

local LazyPigMultiboxMenuObjects = {}
local LazyPigMultiboxMenuStrings = {
		[00]= "Always",
		[01]= "No Enemy Target - Indoor",
		[02]= "No Enemy Target - Outdoor",
		[03]= "Combat End",
		[04]= "Spell Fail",
		[05]= "Master Shift Press",
		[10]= "Friend",
		[11]= "Improved Targeting",
		[12]= "Enemy",
		[13]= "Active Enemy Only",
		[14]= "Active NPC Enemy Only",
		[20]= "Release Spirit/Resurrection",
		[21]= "Taxi Pickup",
		[22]= "Dismount Control",
		[23]= "Quest Accept",
		[24]= "Trade Accept",
		[25]= "Logout/Cancel Logout",
		[30]= "Slave Lost",
		[31]= "Slave Spell Fail",
		[32]= "Whisper Redirect",
		[40]= "DPS"	,
		[41]= "DPS + Pet",
		[42]= "Heal - Normal",
		[43]= "Quick Rez",
		[44]= "Unique Spell",
		[45]= "Fast Heal",
		[46]= "Smart Buff",
		[50]= "Group Roll Manager",
		[51]= "Group Quest Share",
		[52]= "Set Free-for-All at Start"
		
}

function LazyPigMultibox_GetOption(num)
	local labelString = getglobal(this:GetName().."Text");
	local label = LazyPigMultiboxMenuStrings[num] or "";
	
	LazyPigMultiboxMenuObjects[num] = this

	if num == 00 and LPMULTIBOX.FM_ALWAYS
	or num == 01 and LPMULTIBOX.FM_NOENEMYINDOORS
	or num == 02 and LPMULTIBOX.FM_NOENEMYOUTDOORS
	or num == 03 and LPMULTIBOX.FM_COMABTENDS
	or num == 04 and LPMULTIBOX.FM_SPELLFAIL
	or num == 05 and LPMULTIBOX.SCRIPT_SHIFT
	or num == 10 and LPMULTIBOX.AM_FRIEND
	or num == 11 and LPMULTIBOX.AM_KEEPTARGET
	or num == 12 and LPMULTIBOX.AM_ENEMY
	or num == 13 and LPMULTIBOX.AM_ACTIVEENEMY
	or num == 14 and LPMULTIBOX.AM_ACTIVENPCENEMY
	or num == 20 and LPMULTIBOX.FA_RELEASE
	or num == 21 and LPMULTIBOX.FA_TAXIPICKUP
	or num == 22 and LPMULTIBOX.FA_DISMOUNT
	or num == 23 and LPMULTIBOX.FA_QUESTSHARE
	or num == 24 and LPMULTIBOX.FA_TRADE
	or num == 25 and LPMULTIBOX.FA_LOGOUT
	or num == 30 and LPMULTIBOX.SM_SLAVELOST
	or num == 31 and LPMULTIBOX.SM_SPELLFAIL
	or num == 32 and LPMULTIBOX.SM_REDIRECT
	or num == 40 and LPMULTIBOX.SCRIPT_DPS
	or num == 41 and LPMULTIBOX.SCRIPT_DPSPET
	or num == 42 and LPMULTIBOX.SCRIPT_HEAL
	or num == 43 and LPMULTIBOX.SCRIPT_REZ
	or num == 44 and LPMULTIBOX.UNIQUE_SPELL
	or num == 45 and LPMULTIBOX.SCRIPT_FASTHEAL
	or num == 46 and LPMULTIBOX.SCRIPT_BUFF
	or num == 50 and LPMULTIBOX.POP_GROUPMINI
	or num == 51 and LPMULTIBOX.POP_QUESTSHARE
	or num == 52 and LPMULTIBOX.POP_FFA
	or nil then
		this:SetChecked(true);
	else
		this:SetChecked(nil);
	end
	labelString:SetText(label);
end

function LazyPigMultibox_SetOption(num)
	local checked = this:GetChecked()
	
	LPM_DEBUG("LazyPigMultibox_SetOption - "..num)
	
	if num == 00 then 
		LPMULTIBOX.FM_ALWAYS = true
		LPMULTIBOX.FM_NOENEMYINDOORS = nil
		LPMULTIBOX.FM_NOENEMYOUTDOORS = nil
		LPMULTIBOX.FM_COMABTENDS = nil
		LPMULTIBOX.FM_SPELLFAIL = nil
		LPMULTIBOX.SCRIPT_SHIFT = nil
		if not checked then LPMULTIBOX.FM_ALWAYS = nil end
		LazyPigMultiboxMenuObjects[01]:SetChecked(nil);
		LazyPigMultiboxMenuObjects[02]:SetChecked(nil);
		LazyPigMultiboxMenuObjects[03]:SetChecked(nil);
		LazyPigMultiboxMenuObjects[04]:SetChecked(nil);
		LazyPigMultiboxMenuObjects[05]:SetChecked(nil);	
	
	elseif num == 01 then 
		LPMULTIBOX.FM_NOENEMYINDOORS = true
		LPMULTIBOX.FM_ALWAYS = nil
		if not checked then LPMULTIBOX.FM_NOENEMYINDOORS = nil end
		LazyPigMultiboxMenuObjects[00]:SetChecked(nil);
	
	elseif num == 02 then
		LPMULTIBOX.FM_NOENEMYOUTDOORS = true
		LPMULTIBOX.FM_ALWAYS = nil
		if not checked then LPMULTIBOX.FM_NOENEMYOUTDOORS = nil end
		LazyPigMultiboxMenuObjects[00]:SetChecked(nil);
	
	elseif num == 03 then
		LPMULTIBOX.FM_COMABTENDS = true
		LPMULTIBOX.FM_ALWAYS = nil
		if not checked then LPMULTIBOX.FM_COMABTENDS = nil end
		LazyPigMultiboxMenuObjects[00]:SetChecked(nil);
		
	elseif num == 04 then
		LPMULTIBOX.FM_SPELLFAIL = true
		LPMULTIBOX.FM_ALWAYS = nil
		if not checked then LPMULTIBOX.FM_SPELLFAIL = nil end
		LazyPigMultiboxMenuObjects[00]:SetChecked(nil);
		
	elseif num == 05 then
		LPMULTIBOX.SCRIPT_SHIFT = true
		LPMULTIBOX.FM_ALWAYS = nil
		if not checked then LPMULTIBOX.SCRIPT_SHIFT = nil end
		LazyPigMultiboxMenuObjects[00]:SetChecked(nil);	

	elseif num == 10 then 
		LPMULTIBOX.AM_FRIEND = true
		if not checked then LPMULTIBOX.AM_FRIEND = nil end


	elseif num == 11 then 
		LPMULTIBOX.AM_KEEPTARGET = true
		if not checked then LPMULTIBOX.AM_KEEPTARGET = nil end
		
		if(LPMULTIBOX.AM_ACTIVEENEMY or LPMULTIBOX.AM_ACTIVENPCENEMY) and LPMULTIBOX.AM_KEEPTARGET then
			LazyPigMultibox_Message("Sniper Mode Enabled")
		else
			LazyPigMultibox_Message("Sniper Mode Disabled")
		end

	elseif num == 12 then 
		LPMULTIBOX.AM_ENEMY = true
		LPMULTIBOX.AM_ACTIVEENEMY = nil
		LPMULTIBOX.AM_ACTIVENPCENEMY = nil
		if not checked then LPMULTIBOX.AM_ENEMY = nil end
		LazyPigMultiboxMenuObjects[13]:SetChecked(nil);
		LazyPigMultiboxMenuObjects[14]:SetChecked(nil);
		
		if LPMULTIBOX.AM_ENEMY  then
			LazyPigMultibox_Message("Sniper Mode Disabled")
		end
		
	elseif num == 13 then 
		LPMULTIBOX.AM_ENEMY = nil
		LPMULTIBOX.AM_ACTIVEENEMY = true
		LPMULTIBOX.AM_ACTIVENPCENEMY = nil
		if not checked then LPMULTIBOX.AM_ACTIVEENEMY = nil end
		LazyPigMultiboxMenuObjects[12]:SetChecked(nil);
		LazyPigMultiboxMenuObjects[14]:SetChecked(nil);

		
		if(LPMULTIBOX.AM_ACTIVEENEMY or LPMULTIBOX.AM_ACTIVENPCENEMY) and LPMULTIBOX.AM_KEEPTARGET then
			LazyPigMultibox_Message("Sniper Mode Enabled")
		end
		
	elseif num == 14 then 
		LPMULTIBOX.AM_ENEMY = nil
		LPMULTIBOX.AM_ACTIVEENEMY = nil
		LPMULTIBOX.AM_ACTIVENPCENEMY = true
		if not checked then LPMULTIBOX.AM_ACTIVENPCENEMY = nil end
		LazyPigMultiboxMenuObjects[12]:SetChecked(nil);
		LazyPigMultiboxMenuObjects[13]:SetChecked(nil);
		
		if(LPMULTIBOX.AM_ACTIVEENEMY or LPMULTIBOX.AM_ACTIVENPCENEMY) and LPMULTIBOX.AM_KEEPTARGET then
			LazyPigMultibox_Message("Sniper Mode Enabled")
		end
	
	elseif num == 20 then															
		LPMULTIBOX.FA_RELEASE = true
		if not checked then LPMULTIBOX.FA_RELEASE = nil end

	elseif num == 21 then 
		LPMULTIBOX.FA_TAXIPICKUP = true
		if not checked then LPMULTIBOX.FA_TAXIPICKUP = nil end

	elseif num == 22 then 
		LPMULTIBOX.FA_DISMOUNT = true
		if not checked then LPMULTIBOX.FA_DISMOUNT = nil end

	elseif num == 23 then 
		LPMULTIBOX.FA_QUESTSHARE = true
		if not checked then LPMULTIBOX.FA_QUESTSHARE = nil end
	
	elseif num == 24 then 
		LPMULTIBOX.FA_TRADE = true
		if not checked then LPMULTIBOX.FA_TRADE = nil end	
	
	elseif num == 25 then 
		LPMULTIBOX.FA_LOGOUT = true
		if not checked then LPMULTIBOX.FA_LOGOUT = nil end	
			
	elseif num == 30 then 								
		LPMULTIBOX.SM_SLAVELOST = true
		if not checked then LPMULTIBOX.SM_SLAVELOST = nil end
		
	elseif num == 31 then 
		LPMULTIBOX.SM_SPELLFAIL = true
		if not checked then LPMULTIBOX.SM_SPELLFAIL = nil end
		
	elseif num == 32 then 
		LPMULTIBOX.SM_REDIRECT = true
		if not checked then LPMULTIBOX.SM_REDIRECT = nil end			
	
	elseif num == 40 then 
		LPMULTIBOX.SCRIPT_DPS = true
		if not checked then LPMULTIBOX.SCRIPT_DPS = nil end	
		
	elseif num == 41 then 
		LPMULTIBOX.SCRIPT_DPSPET = true
		if not checked then LPMULTIBOX.SCRIPT_DPSPET = nil end	
		
	elseif num == 42 then 
		LPMULTIBOX.SCRIPT_HEAL = true
		LPMULTIBOX.SCRIPT_FASTHEAL = nil
		if not checked then LPMULTIBOX.SCRIPT_HEAL = nil end
		LazyPigMultiboxMenuObjects[45]:SetChecked(nil);	
	
	elseif num == 43 then 
		LPMULTIBOX.SCRIPT_REZ = true
		if not checked then LPMULTIBOX.SCRIPT_REZ = nil end	
		
		
	elseif num == 44 then 
		LPMULTIBOX.UNIQUE_SPELL = true
		if not checked then 
			LPMULTIBOX.UNIQUE_SPELL = nil 
		else	
			local player_class = UnitClass("player")
			LazyPigMultibox_Annouce("lpm_unique_spell", player_class); 
		end	
	
	elseif num == 45 then 
		LPMULTIBOX.SCRIPT_FASTHEAL = true
		LPMULTIBOX.SCRIPT_HEAL = nil
		if not checked then LPMULTIBOX.SCRIPT_FASTHEAL = nil end
		LazyPigMultiboxMenuObjects[42]:SetChecked(nil);	
	
	elseif num == 46 then 
		LPMULTIBOX.SCRIPT_BUFF = true
		if not checked then LPMULTIBOX.SCRIPT_BUFF = nil end
	
	elseif num == 50 then 
		LPMULTIBOX.POP_GROUPMINI = true
		if not checked then LPMULTIBOX.POP_GROUPMINI = nil end	
	
	elseif num == 51 then 
		LPMULTIBOX.POP_QUESTSHARE = true
		if not checked then LPMULTIBOX.POP_QUESTSHARE = nil end	
	
	elseif num == 52 then 
		LPMULTIBOX.POP_FFA = true
		if not checked then LPMULTIBOX.POP_FFA = nil end
		LazyPigMultibox_SetFFA(true);
	else
		--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: No num assigned - "..num)
	end
	--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: Num chosen - "..num)
end


function LazyPigMultibox_MenuSet()
	local unit = LazyPigMultibox_ReturnLeaderUnit()
	local leader = unit and UnitIsUnit(unit, "player") or GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0
	
	LPM_DEBUG("LazyPigMultibox_MenuSet")
	
	function process(matrix, x)
		for blockindex,blockmatch in pairs(matrix) do
			local frame = getglobal(blockmatch)
			local fs = getglobal(blockmatch.."Text")
			if frame then
				if x then
					frame:Enable()
				else
					frame:Disable()
				end
			end
			if fs then
				if x then
					fs:SetTextColor(1, .81, 0)
				else
					fs:SetTextColor(.5, .5, .5)
				end
			end
		end
	end
	
	function Buttons1(val)
		local Buttons1Matrix = {
			"LazyPigMultiboxFriends",
			"LazyPigMultiboxGuildMates",
			"LazyPigMultiboxDisband",
			"LazyMultiboxConvert",
			"LazyMultiboxFFA",
			"LazyMultiboxGroup",
			"LazyMultiboxMaster",
			"LazyPigMultiboxPass",
			"LazyPigMultiboxGreed",
			"LazyPigMultiboxNeed",
			"LazyPigMultiboxAOE",
		}
		process(Buttons1Matrix, val);
	end
	
	function Buttons2(val)
		local Buttons2Matrix = {
			"LazyPigMultiboxCheckbox00",
			"LazyPigMultiboxCheckbox01",
			"LazyPigMultiboxCheckbox02",
			"LazyPigMultiboxCheckbox03",
			"LazyPigMultiboxCheckbox04",
			"LazyPigMultiboxCheckbox05",
			"LazyPigMultiboxCheckbox10",
			"LazyPigMultiboxCheckbox11",
			"LazyPigMultiboxCheckbox12",
			"LazyPigMultiboxCheckbox13",
			"LazyPigMultiboxCheckbox14",
			"LazyPigMultiboxCheckbox20",
			"LazyPigMultiboxCheckbox21",
			"LazyPigMultiboxCheckbox22",
			"LazyPigMultiboxCheckbox23",
			"LazyPigMultiboxCheckbox24",
			"LazyPigMultiboxCheckbox25",
			"LazyPigMultiboxCheckbox30",
			"LazyPigMultiboxCheckbox31",
			"LazyPigMultiboxCheckbox32",
			"LazyPigMultiboxCheckbox40",
			"LazyPigMultiboxCheckbox41",
			"LazyPigMultiboxCheckbox42",
			"LazyPigMultiboxCheckbox43",
			"LazyPigMultiboxCheckbox44",
			"LazyPigMultiboxCheckbox45",
			"LazyPigMultiboxCheckbox46",
			"LazyPigMultiboxCheckbox50",
			"LazyPigMultiboxCheckbox51",
			"LazyPigMultiboxCheckbox52",
			--"LazyMultiboxMacro",
			"LazyPigMultiboxSync",
			"LazyPigMultiboxSyncExt", --commodity "frame" to gray out the external fontstring
			--"LazyMultiboxQHCFG",
			--"LazyMultiboxLPCFG"
		}
		process(Buttons2Matrix, val);
	end
	
	function Buttons3(val)
		local Buttons3Matrix = {
			"LazyPigMultiboxLogout",
			"LazyPigMultiboxReload",
			"LazyPigMultiboxStuck"
		}
		process(Buttons3Matrix, val);
	end
	
	if LPMULTIBOX.STATUS then
		Buttons2(true);
		Buttons3(true);
		--getglobal("LazyPigMultiboxEnable"):SetText("Disable Multiboxing");
		getglobal("LazyPigMultiboxEnableComboBox"):SetChecked(true)
		getglobal("LazyPigMultiboxEnableComboBoxText"):SetText("Multibox Enabled")
		if leader then
			Buttons1(true);
			getglobal("LazyPigMultiboxSyncExtText"):SetText("Upload Settings");
			--getglobal("LazyPigMultiboxFrameTitleText"):SetText("_LazyPig Multibox - Master");
			getglobal("LazyPigMultiboxOptionsFrameTitleText"):SetText("_LazyPig Multibox - Master");
			getglobal("LazyMultiboxMakeLeader"):Disable();

		else
			Buttons1(nil);
			getglobal("LazyPigMultiboxSyncExtText"):SetText("Request Settings");
			--getglobal("LazyPigMultiboxFrameTitleText"):SetText("_LazyPig Multibox - Slave");
			getglobal("LazyPigMultiboxOptionsFrameTitleText"):SetText("_LazyPig Multibox - Slave");
			getglobal("LazyMultiboxMakeLeader"):Enable();
		end	

	else
		Buttons1(nil);
		Buttons2(nil);
		--Buttons3(nil);	
		--getglobal("LazyPigMultiboxEnable"):SetText("Enable Multiboxing");
		getglobal("LazyPigMultiboxEnableComboBox"):SetChecked(false)
		getglobal("LazyPigMultiboxEnableComboBoxText"):SetText("Multibox Disabled")
		getglobal("LazyMultiboxMakeLeader"):Disable();
	end
	
	--getglobal("LazyPigMultiboxText4"):SetText("Use PreDefined Class Script");
	
	local class = UnitClass("player")
	if class == "Rogue" or class == "Warrior" or class == "Shaman"  or class == "Mage" or class == "Priest" or class == "Paladin" then
		LPMULTIBOX.SCRIPT_DPSPET = nil
		getglobal("LazyPigMultiboxCheckbox41"):Disable();
		getglobal("LazyPigMultiboxCheckbox41Text"):SetTextColor(.5, .5, .5)
	end
	if class == "Rogue" or class == "Warrior" or class == "Hunter" or class == "Mage" or class == "Warlock" then
		LPMULTIBOX.SCRIPT_HEAL = nil
		LPMULTIBOX.SCRIPT_FASTHEAL = nil
		LPMULTIBOX.SCRIPT_REZ = nil
		getglobal("LazyPigMultiboxCheckbox42"):Disable();
		getglobal("LazyPigMultiboxCheckbox43"):Disable();
		getglobal("LazyPigMultiboxCheckbox45"):Disable();
		getglobal("LazyPigMultiboxCheckbox42Text"):SetTextColor(.5, .5, .5)
		getglobal("LazyPigMultiboxCheckbox43Text"):SetTextColor(.5, .5, .5)
		getglobal("LazyPigMultiboxCheckbox45Text"):SetTextColor(.5, .5, .5)
		getglobal("LazyMultiboxQHCFG"):Disable();
		getglobal("LazyMultiboxQHCFGExtText"):SetTextColor(.5, .5, .5)
	end
	if class == "Druid" then
		LPMULTIBOX.SCRIPT_REZ = nil
		getglobal("LazyPigMultiboxCheckbox43"):Disable();
		getglobal("LazyPigMultiboxCheckbox43Text"):SetTextColor(.5, .5, .5)
	end
end

function LazyPigMultibox_UseClassScript()
	local time = GetTime()
	if LPM_TIMER.SCRIPT_USE < time then	
		LPM_TIMER.SCRIPT_USE = time + 0.25
		
		local rez = LPMULTIBOX.SCRIPT_REZ
		local dps = LPMULTIBOX.SCRIPT_DPS
		local dps_pet = LPMULTIBOX.SCRIPT_DPSPET
		local buff = LPMULTIBOX.SCRIPT_BUFF
		local heal = LPMULTIBOX.SCRIPT_HEAL or LPMULTIBOX.SCRIPT_FASTHEAL
		local leader = LazyPigMultibox_ReturnLeaderUnit()
		local check1 = LazyPigMultibox_SlaveCheck()
		local check2 = leader and UnitIsUnit("player", leader)
		local check3 = GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0
		
		if not LPMULTIBOX.STATUS then
			return
		end
		
		if not check2 and check1 then
			LazyPigMultibox_AssistMaster();
			LazyPigMultibox_FollowMaster();
		end	
		
		if LPMULTIBOX.FA_DISMOUNT and LazyPigMultibox_Dismount() then
			return 
		end
		
		if LazyPigMultibox_Schedule() or LazyPigMultibox_ScheduleSpell() then
			return
		end
		
		if UnitExists("target") and (not Zorlen_isEnemy("target") or UnitIsDeadOrGhost("target")) then
			ClearTarget();	
		end
			
		if dps or dps_pet or heal or rez or buff then
			
			local class = UnitClass("player")

			dps = dps and Zorlen_isEnemy("target") and (check2 or check3 or LPMULTIBOX.AM_ENEMY or Zorlen_isActiveEnemy("target") and (LPMULTIBOX.AM_ACTIVEENEMY or not UnitIsPlayer("target") and LPMULTIBOX.AM_ACTIVENPCENEMY))
			rez = rez and not UnitAffectingCombat("player")
			buff = buff and not UnitAffectingCombat("player") and not Zorlen_isEnemy("target")
			
			if dps and check2 and LazyPigMultibox_CheckDelayMode(true) then
				LazyPigMultibox_Annouce("lpm_masterattack", "")
			elseif LPM_TIMER.MASTERATTACK ~= 0 and LPM_TIMER.MASTERATTACK < time and not LPMULTIBOX.AM_ENEMY then
				dps = nil
			end
		
			LPM_DEBUG("LazyPigMultibox_UseClassScript")
			
			if class == "Paladin" then
				LazyPigMultibox_Paladin(dps, dps_pet, heal, rez, buff);
			elseif class == "Shaman" then
				LazyPigMultibox_Shaman(dps, dps_pet, heal, rez, buff);
			elseif class == "Druid" then
				LazyPigMultibox_Druid(dps, dps_pet, heal, rez, buff);		
			elseif class == "Priest" then
				LazyPigMultibox_Priest(dps, dps_pet, heal, rez, buff);
			elseif class == "Warlock" then
				LazyPigMultibox_Warlock(dps, dps_pet, heal, rez, buff);
			elseif class == "Mage" then
				LazyPigMultibox_Mage(dps, dps_pet, heal, rez, buff);
			elseif class == "Hunter" then
				LazyPigMultibox_Hunter(dps, dps_pet, heal, rez, buff);
			elseif class == "Paladin" then
				LazyPigMultibox_Paladin(dps, dps_pet, heal, rez, buff);
			elseif class == "Rogue" then
				LazyPigMultibox_Rogue(dps, dps_pet, heal, rez, buff);
			elseif class == "Warrior" then
				LazyPigMultibox_Warrior(dps, dps_pet, heal, rez, buff);
			end
			return true
		end	
		return nil
	end	
end

function LazyPigMultibox_ReturnUnit(unit_name)
	local InRaid = UnitInRaid("player")
	local PLAYER = "player"
	local PET = ""
	local group = nil
	local NumMembers = nil
	local counter = nil
	local u = nil

	if InRaid then
		NumMembers = GetNumRaidMembers()
		counter = 1
		group = "raid"
	else
		NumMembers = GetNumPartyMembers()
		counter = 0
		group = "party"
	end

	while counter <= NumMembers do
		if counter == 0 then
			u = PLAYER
		else
			u = group..""..counter
		end
		if string.lower(unit_name) == string.lower(GetUnitName(u)) then
			return u
		end
		counter = counter + 1
	end
	return false
end

function LazyPigMultibox_ReturnCCUnit(unit_name, dispelable)
	local InRaid = UnitInRaid("player")
	local PLAYER = "player"
	local PET = ""
	local group = nil
	local NumMembers = nil
	local counter = nil
	local u = nil

	if InRaid then
		NumMembers = GetNumRaidMembers()
		counter = 1
		group = "raid"
	else
		NumMembers = GetNumPartyMembers()
		counter = 0
		group = "party"
	end

	while counter <= NumMembers do
		if counter == 0 then
			u = PLAYER
		else
			u = group..""..counter
		end
		if UnitAffectingCombat(u) then
			local ccontrol = Zorlen_isCrowedControlled(u, dispelable) or Zorlen_checkDebuffByName("Seduce", u, dispelable) or Zorlen_checkDebuffByName("Polymorph", u, dispelable) or Zorlen_checkDebuffByName("Sleep", u, dispelable) or Zorlen_checkDebuffByName("Reckless Charge", u, dispelable) or Zorlen_checkDebuffByName("Blind", u, dispelable)
			if ccontrol then
				return u
			end
		end	
		counter = counter + 1
	end
	return false
end

function LazyPigMultibox_ReturnLeaderUnit()
	local InRaid = UnitInRaid("player")
	local PLAYER = "player"
	local PET = ""
	local group = nil
	local NumMembers = nil
	local counter = nil
	local u = nil

	if InRaid then
		NumMembers = GetNumRaidMembers()
		counter = 1
		group = "raid"
	else
		NumMembers = GetNumPartyMembers()
		counter = 0
		group = "party"
	end

	while counter <= NumMembers do
		if counter == 0 then
			u = PLAYER
		else
			u = group..""..counter
		end
		if UnitIsPartyLeader(u) then
			return u
		end
		counter = counter + 1
	end
	return false
end

function LazyPigMultibox_PlayerInGrp(name)
	local InRaid = UnitInRaid("player")
	local PLAYER = "player"
	local PET = ""
	local group = nil
	local NumMembers = nil
	local counter = nil
	local u = nil

	if InRaid then
		NumMembers = GetNumRaidMembers()
		counter = 1
		group = "raid"
	else
		NumMembers = GetNumPartyMembers()
		counter = 0
		group = "party"
	end

	while counter <= NumMembers do
		if counter == 0 then
			u = PLAYER
		else
			u = group..""..counter
		end
		if GetUnitName(u) == name then
			return true
		end
		counter = counter + 1
	end
	return false
end

function LazyPigMultibox_InviteGuildMates()
	SetGuildRosterShowOffline(0);
	SetGuildRosterSelection(0);
	GetGuildRosterInfo(0);
	
	local playerName = UnitName("player");
	local numGuildMembers = GetNumGuildMembers();
	for i = 1, numGuildMembers, 1 do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		if ( name ~= playerName and online ) then
			if not LazyPigMultibox_PlayerInGrp(name) then
				InviteByName(name);
			end	
		end
	end
end

function LazyPigMultibox_InviteFriends()
	for i = 1, GetNumFriends() do
		local name, level, class, area, connected, status, note = GetFriendInfo(i);
		if connected then
			if name and not LazyPigMultibox_PlayerInGrp(name) then
				InviteByName(name);
			end	
		end
	end
end

function LazyPigMultibox_AOEInvite()
	local Names = {}
	for i=0,30 do
		if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("player","target") then
			local name = GetUnitName("target")
			if not LazyPigMultibox_PlayerInGrp(name) and not Names[name] then
				Names[name] = true
				InviteByName(name);
			end	
		end
		TargetNearestFriend();
	end
	ClearTarget();
end

function LazyPigMultibox_DisbangGroup()
	if UnitInRaid("player") then
		for i = 1, 40 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i);
			if (rank ~= 2) then
				UninviteFromParty("raid"..i)
			end
		end	
	else
		for i = 1, GetNumPartyMembers() do
			UninviteFromParty("party"..i)
		end
	end
	LPM_INFO.MODE = nil
	LPM_INFO.CONNECT = {}
end	

function LazyPigMultibox_SlaveCheck()
	local time = GetTime()
	if LPMULTIBOX.STATUS and LPM_TIMER.MASTER > time then
		return true
	end
	return nil
end

function LazyPigMultibox_SlaveAssist(master, forceuse)		
	--if multibox_master_attack then
		--if not UnitExists("target") then
			--if MegaLibVar["PVEPARTY"] then SendChatMessage("Ered'nash ban galars", "YELL") end
			local InRaid = UnitInRaid("player")
			local PLAYER = "player"
			local group = nil
			local NumMembers = nil
			local counter = nil
			local u = nil
			
			local prio4 = nil
			local prio3 = nil
			local prio2 = nil
			local prio1 = nil
			local prio0 = nil
			local mastertarget = nil
	
			if InRaid then
				NumMembers = GetNumRaidMembers()
				counter = 1
				group = "raid"
			else
				NumMembers = GetNumPartyMembers()
				counter = 0
				group = "party"
			end
			while counter <= NumMembers do
				if counter == 0 then
					u = PLAYER
				else
					u = group..""..counter
				end
				
				
				local check = UnitExists(u.."target") and not UnitIsDead(u.."target") and (not Zorlen_isEnemy(u.."target") and LPMULTIBOX.AM_FRIEND or Zorlen_isEnemy(u.."target") and (forceuse or LPMULTIBOX.AM_ENEMY or UnitAffectingCombat(u.."target") and (LPMULTIBOX.AM_ACTIVEENEMY or not UnitIsPlayer(u.."target") and LPMULTIBOX.AM_ACTIVENPCENEMY))) 
				
				if check then --UnitExists(u.."target") and UnitCanAttack(u.."target", "player") and UnitAffectingCombat(u.."target") then
					if UnitExists(master) and UnitIsUnit(u, master) then
						mastertarget = u.."target"
					end
					if UnitExists(u.."targettarget") and UnitIsFriend(u.."targettarget","player") then
						prio2 = u.."target"
					end
					prio4 = u.."target"
				end
				if UnitExists(group.."pet"..counter) and UnitExists(group.."pet"..counter.."target") and UnitAffectingCombat(group.."pet"..counter.."target") then
					if UnitIsFriend(group.."pet"..counter.."targettarget","player") then
						prio1 = group.."pet"..counter.."target"
					end
					prio3 = group.."pet"..counter.."target"
				end
				counter = counter + 1
			end	
			
			prio0 = prio0 or mastertarget or prio1 or prio2 or prio3 or prio4
			return prio0
		--end
	--end
end

function LazyPigMultibox_UtilizeTarget(mode)
	if LPM_TARGET.ACTIVE then
		LPM_TIMER.UTILIZE_TARGET = nil
		
	elseif mode then
		LPM_TIMER.UTILIZE_TARGET = GetTime() + 1.5
		
	elseif LPM_TIMER.UTILIZE_TARGET and LPM_TIMER.UTILIZE_TARGET < GetTime() and LPMULTIBOX.AM_KEEPTARGET then
		LPM_TIMER.UTILIZE_TARGET = nil
		ClearTarget();	
	end
	
	if LPM_TARGET.ACTIVE or LPM_TIMER.UTILIZE_TARGET then
		return true
	end
	return nil
end


function LazyPigMultibox_AssistMaster(forceuse)
	local leader = LazyPigMultibox_ReturnLeaderUnit()
	local slaveassist = LazyPigMultibox_SlaveAssist(leader, forceuse)
	
	if forceuse then
		--local x = "SET Target - "..GetUnitName(slaveassist)
		--SendChatMessage("SET Target - ", "SAY")
	
	end
	
	--local exists = leader and UnitExists(leader.."target")
	local check1 = LazyPigMultibox_SlaveCheck()
	--local check2 = exists and (not Zorlen_isEnemy(leader.."target") and LPMULTIBOX.AM_FRIEND or Zorlen_isEnemy(leader.."target") and (forceuse or LPMULTIBOX.AM_ENEMY or UnitAffectingCombat(leader.."target") and (LPMULTIBOX.AM_ACTIVEENEMY or not UnitIsPlayer(leader.."target") and LPMULTIBOX.AM_ACTIVENPCENEMY))) 

	function checkunit(u1, u2)
		return UnitExists(u1) and UnitExists(u2) and UnitIsUnit(u1, u2)
	end
	
	if check1 then
		if LPM_TARGET.ACTIVE and LPM_TIMER.ASSIST_MASTER < GetTime() then
			if forceuse then
				LPM_TIMER.ASSIST_MASTER = GetTime() + 0.75
			end	

			--SendChatMessage("SET Target - utilize", "SAY")
			if UnitExists(slaveassist) then
				TargetUnit(slaveassist)
			end	
			
		elseif not LPMULTIBOX.AM_KEEPTARGET then
			ClearTarget();
			--SendChatMessage("Clear Target - assist", "SAY")
		end
	end	
end

function LazyPigMultibox_FollowMaster(message)
	local leader = LazyPigMultibox_ReturnLeaderUnit()
	local enemy = leader and UnitExists(leader.."target") and Zorlen_isEnemy(leader.."target")
	local indoors = LazyPig_Raid() or LazyPig_Dungeon()
	local check1 = LazyPigMultibox_SlaveCheck()
	local check2 = LPMULTIBOX.FM_ALWAYS or LPMULTIBOX.FM_NOENEMYINDOORS and indoors and not enemy or LPMULTIBOX.FM_NOENEMYOUTDOORS and not indoors and not enemy or LPMULTIBOX.FM_COMABTENDS and message == "combat" or LPMULTIBOX.FM_SPELLFAIL and message == "spell" or LPMULTIBOX.SCRIPT_SHIFT and message == "shift"
	
	if leader and check1 and check2 then	
		LPM_DEBUG("LazyPigMultibox_FollowMaster")
		if not CheckInteractDistance(leader, 4) then
			if LPMULTIBOX.SM_SLAVELOST then
				LazyPigMultibox_Annouce("lpm_slaveannouce", " Lost !")
			end	
		elseif message ~= "end" then
			FollowUnit(leader)
		end	
	end	
end

function LazyPigMultibox_Taxi()
	local time = GetTime()
	local check1 = LazyPigMultibox_SlaveCheck()
	
	if LPMULTIBOX.FA_TAXIPICKUP and LPM_TAXI.TIME > time and check1 then
		for i=1,NumTaxiNodes() do
			if(TaxiNodeName(i) == LPM_TAXI.NODE) then
				LPM_DEBUG("Taxi destination: "..TaxiNodeName(i))
				Original_TakeTaxiNode(i)
				break
			end
		end
	end	
end

function LazyPigMultibox_WhisperRedirect(val1, val2)	
	local check = LazyPigMultibox_SlaveCheck()
	local master = LazyPigMultibox_ReturnLeaderUnit()

	if check and master and LPMULTIBOX.SM_REDIRECT then
		DEFAULT_CHAT_FRAME:AddMessage("LazyPigMultibox_WhisperRedirect")
		val2 = val2.." >> "..val1
		SendChatMessage(val2, "WHISPER", nil, GetUnitName(master));
	end	
end

function LazyPigMultibox_SpellFail(msg)
	local check = LazyPigMultibox_SlaveCheck()
	local master = LazyPigMultibox_ReturnLeaderUnit()
	if check and master and LPMULTIBOX.SM_SPELLFAIL then --and UnitAffectingCombat(master)
		LazyPigMultibox_Annouce("lpm_slaveannouce", msg)
	end	
end

function LazyPigMultibox_CCAnnouce(msg)

end

function LazyPigMultibox_ShowMode(set)
	if LPMULTIBOX.STATUS then	
		local time = GetTime()
		
		if set then
			--DEFAULT_CHAT_FRAME:AddMessage("Mode Set");
			LPM_TIMER.MODESET = time + 1
			--LPM_INFO.CONNECT = {}
			--LPM_INFO.MODE = nil
		else
			local leader_id = LazyPigMultibox_ReturnLeaderUnit()
			--local player_name = GetUnitName("player")
			local leader_check = leader_id  and UnitIsUnit(leader_id , "player") or GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0
			
			if LPMULTIBOX.STATUS and LPM_TIMER.MODESET and LPM_TIMER.MODESET < time then
				if not leader_check then
					
					if LPM_INFO.MODE ~= "slave" then
						LPM_INFO.MODE = "slave"
						LPM_STATUS("Slave Mode Enabled");
						LazyPigMultibox_FollowMaster();
					end
					LazyPigMultibox_Annouce("lpm_enable", "")
				else
					if LPM_INFO.MODE ~= "master" then	
						LPM_INFO.MODE = "master"
						LPM_INFO.CONNECT = {}
						LPM_STATUS("Master Mode Enabled");
						LazyPigMultibox_SetFFA(true);
					end	
					LazyPigMultibox_Annouce("lpm_who", "");
				end
				LPM_TIMER.MODESET = nil
			end
		end
	end	
end

function LazyPigMultibox_Dismount()
	
	local check = LazyPigMultibox_SlaveCheck()
	local master = LazyPigMultibox_ReturnLeaderUnit()
	
	if (LazyPig_Raid() and GetRealZoneText() ~= "Zul'Gurub") or (LazyPig_Dungeon() and  GetRealZoneText() ~= "Zul'Farrak") or not LPMULTIBOX.FA_DISMOUNT or not check or not master then 
		return nil
	end
	
	local tooltipfind1 = "Increases speed by"
	local tooltipfind2 = "increased movement speed"
	local masterstatus = nil
	local counter = 1
	
	if master and UnitName(master) then
		if not UnitBuff(master, 1) then return end
		while UnitBuff(master, counter) do
			ZORLEN_Buff_Tooltip:SetUnitBuff(master, counter)
			local desc = ZORLEN_Buff_TooltipTextLeft2:GetText()
			if desc then 
				if string.find(desc, tooltipfind1) or string.find(desc, tooltipfind2) then
					masterstatus = true
				end	
			end
			counter = counter + 1
		end
	end
	
	if not masterstatus then
		counter = 0
		while GetPlayerBuff(counter) >= 0 do
			local index, untilCancelled = GetPlayerBuff(counter)
			ZORLEN_Buff_Tooltip:SetPlayerBuff(index)
			local desc = ZORLEN_Buff_TooltipTextLeft2:GetText()
			if desc then 
				if string.find(desc, tooltipfind1) or string.find(desc, tooltipfind2) then
					LPM_DEBUG("LazyPigMultibox_Dismount")
					CancelPlayerBuff(counter)
					return true
				end	
			end
			counter = counter + 1
		end
	else	
		return true
	end
	return nil
end

function LazyPigMultibox_SettingsSync() --Button
	if LPMULTIBOX.STATUS then
		local check = LazyPigMultibox_SlaveCheck()
		local master = LazyPigMultibox_ReturnLeaderUnit()
		local player_name = GetUnitName("player")
	
		if master and player_name == GetUnitName(master) then
			LazyPigMultibox_DataSend();
		elseif check then
			LazyPigMultibox_DataRequest();
		end
	end
end

function LazyPigMultibox_DataRequest()
	local check = LazyPigMultibox_SlaveCheck() 
	if check then
		SendAddonMessage("lpm_req", "", "RAID")
	end
end

function LazyPigMultibox_DataSend()
	local LazyPigBitPosition = {
		[0]= LPMULTIBOX.FM_ALWAYS,
		[1]= LPMULTIBOX.FM_NOENEMYINDOORS,
		[2]= LPMULTIBOX.FM_NOENEMYOUTDOORS,
		[3]= LPMULTIBOX.FM_COMABTENDS,
		[4]= LPMULTIBOX.FM_SPELLFAIL,
		[5]= LPMULTIBOX.AM_FRIEND,
		[6]= LPMULTIBOX.AM_KEEPTARGET,
		[7]= LPMULTIBOX.AM_ENEMY,
		[8]= LPMULTIBOX.AM_ACTIVEENEMY,
		[9]= LPMULTIBOX.AM_ACTIVENPCENEMY,
		[10]= LPMULTIBOX.FA_RELEASE,
		[11]= LPMULTIBOX.FA_TAXIPICKUP,
		[12]= LPMULTIBOX.FA_DISMOUNT,
		[13]= LPMULTIBOX.FA_QUESTSHARE,
		[14]= LPMULTIBOX.FA_TRADE,
		[15]= LPMULTIBOX.FA_LOGOUT,
		[16]= LPMULTIBOX.POP_GROUPMINI,
		[17]= LPMULTIBOX.POP_QUESTSHARE,
		[18]= LPMULTIBOX.SM_SLAVELOST,
		[19]= LPMULTIBOX.SM_SPELLFAIL,
		[20]= LPMULTIBOX.SM_REDIRECT,
		[21] = LPMULTIBOX.SCRIPT_SHIFT,
		[22] = LPMULTIBOX.POP_FFA
	}
	
	local senddata = "lpm"
	local bit = nil
	
	for i=0, 22 do
		if LazyPigBitPosition[i] then
			bit = 1
		else
			bit = 0
		end
		senddata = senddata..bit
	end
	SendAddonMessage("lpm_sync", senddata, "RAID")
end

function LazyPigMultibox_DataReceive(val1, val2, val3)
	
	local check = LazyPigMultibox_SlaveCheck()
	local master = LazyPigMultibox_ReturnLeaderUnit()
	
	
	if check and master and val3 == GetUnitName(master) then
		local LazyPigBitPosition = {}
		
		if val1 == "lpm_sync" then
			if string.find(val2, "lpm") then
				for i=4, 26 do
					local bit = nil
					if tonumber(string.sub(val2,i,i)) == 1 then
						bit = true
					end
					LazyPigBitPosition[i-4] = bit
				end
			end
						
			LPMULTIBOX.FM_ALWAYS = LazyPigBitPosition[0]
			LPMULTIBOX.FM_NOENEMYINDOORS = LazyPigBitPosition[1]
			LPMULTIBOX.FM_NOENEMYOUTDOORS = LazyPigBitPosition[2]
			LPMULTIBOX.FM_COMABTENDS = LazyPigBitPosition[3]
			LPMULTIBOX.FM_SPELLFAIL = LazyPigBitPosition[4]
			LPMULTIBOX.AM_FRIEND = LazyPigBitPosition[5]
			LPMULTIBOX.AM_KEEPTARGET = LazyPigBitPosition[6]
			LPMULTIBOX.AM_ENEMY = LazyPigBitPosition[7]
			LPMULTIBOX.AM_ACTIVEENEMY = LazyPigBitPosition[8]
			LPMULTIBOX.AM_ACTIVENPCENEMY = LazyPigBitPosition[9]
			LPMULTIBOX.FA_RELEASE = LazyPigBitPosition[10]
			LPMULTIBOX.FA_TAXIPICKUP = LazyPigBitPosition[11]
			LPMULTIBOX.FA_DISMOUNT = LazyPigBitPosition[12]
			LPMULTIBOX.FA_QUESTSHARE = LazyPigBitPosition[13]
			LPMULTIBOX.FA_TRADE = LazyPigBitPosition[14]
			LPMULTIBOX.FA_LOGOUT = LazyPigBitPosition[15]
			LPMULTIBOX.POP_GROUPMINI = LazyPigBitPosition[16]
			LPMULTIBOX.POP_QUESTSHARE = LazyPigBitPosition[17]
			LPMULTIBOX.SM_SLAVELOST = LazyPigBitPosition[18]
			LPMULTIBOX.SM_SPELLFAIL = LazyPigBitPosition[19]
			LPMULTIBOX.SM_REDIRECT = LazyPigBitPosition[20]
			LPMULTIBOX.SCRIPT_SHIFT = LazyPigBitPosition[21]
			LPMULTIBOX.POP_FFA = LazyPigBitPosition[22]
			LazyPigMultibox_Annouce("lpm_dataok")
			
			LazyPigMultibox_Command();
			LazyPigMultibox_Command();
		end	
	end
end

function LazyPigMultibox_Toggle() --Button
	LPMULTIBOX.STATUS = not LPMULTIBOX.STATUS
	LazyPigMultibox_MenuSet()
	LazyPigMultibox_ShowMode(true)
	if not LPMULTIBOX.STATUS then
		LPM_STATUS("Off");
	else
		LPM_STATUS("On");
	end
end

function LazyPigMultibox_Roll(val)
	local onlymasterneed = nil
	
	if val == 5 then
		val = 1
		onlymasterneed = true
	end
	
	RollReturn = function()
		local txt = ""
		if val == 1 then
			txt = "NEED"
		elseif val == 2 then
			txt = "GREED"
		elseif val == 0 then
			txt = "PASS"
		end
		return txt
	end

	if val then	
		for i=1, NUM_GROUP_LOOT_FRAMES do
			local frame = getglobal("GroupLootFrame"..i);
			if frame:IsVisible() then
				local id = frame.rollID
				local _, name, _, quality = GetLootRollItemInfo(id);
				RollOnLoot(id, val);
				local _, _, _, hex = GetItemQualityColor(quality)
				LPM_STATUS(hex..RollReturn().."|cffffffff Roll "..GetLootRollItemLink(id))
				
			end
		end
	end
	if onlymasterneed then val = 0 end
	LazyPigMultibox_Annouce("lpm_roll", val)
	LPM_TIMER.LOOTCONFIRM = GetTime() + 0.5
	LazyPigMultiboxRoll:Hide();
end

function LazyPigMultibox_ConfirmLoot()
	for i=1,STATICPOPUP_NUMDIALOGS do
		local frame = getglobal("StaticPopup"..i)
		if frame:IsShown() and (frame.which == "CONFIRM_LOOT_ROLL" or frame.which == "LOOT_BIND") then
			getglobal("StaticPopup"..i.."Button1"):Click();
		end
	end
end

function LazyPigMultibox_GroupLootFrame_OnShow()
	if LPMULTIBOX.STATUS and LPMULTIBOX.POP_GROUPMINI and UnitIsPartyLeader("player") then
		LazyPigMultiboxRoll:Show();
	end	
	Original_GroupLootFrame_OnShow();
end

function LazyPigMultibox_AcceptQuest()
	local check = LazyPigMultibox_SlaveCheck() and not LazyPig_BG()
	if LPMULTIBOX.STATUS and LPMULTIBOX.FA_QUESTSHARE and check then
		AcceptQuest();
	end	
end

function LazyPigMultibox_CreateMacro()
	Zorlen_MakeMacro(LOCALIZATION_ZORLEN.DrinkMacroName, "/zorlen drink", 0, "Spell_Misc_Drink", nil, 1, 1)
	Zorlen_MakeMacro(LOCALIZATION_ZORLEN.EatMacroName, "/zorlen eat", 0, "Spell_Misc_Food", nil, 1, 1)
	Zorlen_MakeMacro("LPM MULTIBOX", "/lpm script", 1, "Spell_Fire_SunKey", nil, 1, 1)
	Zorlen_MakeMacro("LPM TARGET", "/lpm target", 1, "Hunter_SniperShot", nil, 1, 1)
	
	Zorlen_MakeMacro("LPM EXPERT 1", "/script LPM_EXPERT_1()--Remember to Edit _MyCustomFuntions.lua file and Change Player Names to Yours", 1, "Ability_Creature_Cursed_04", nil, 1, 1)
	Zorlen_MakeMacro("LPM EXPERT 2", "/script LPM_EXPERT_2()--Remember to Edit _MyCustomFuntions.lua file and Change Player Names to Yours", 1, "Ability_Creature_Cursed_04", nil, 1, 1)
	Zorlen_MakeMacro("LPM EXPERT 3", "/script LPM_EXPERT_3()--Remember to Edit _MyCustomFuntions.lua file and Change Player Names to Yours", 1, "Ability_Creature_Cursed_04", nil, 1, 1)
	Zorlen_MakeMacro("LPM EXPERT_AOE", "/script LPM_EXPERT_AOE()--Remember to Edit _MyCustomFuntions.lua file and Change Player Names to Yours", 1, "Ability_Creature_Cursed_04", nil, 1, 1)
	
	local class = UnitClass("player")
	if class == "Warlock" then
		Zorlen_MakeMacro("LPM SUMMON", "/script LazyPigMultibox_Summon()", 1, "Spell_Shadow_Twilight", nil, 1, 1)
		Zorlen_MakeMacro("LPM SS", "/script LazyPigMultibox_SmartSS()", 1, "Spell_Shadow_SoulGem", nil, 1, 1)	
		Zorlen_MakeMacro("LPM PET ATTACK", "/script LazyPigMultibox_SPA(GetUnitName(\"player\"))", 1, "Spell_Nature_SpiritWolf", nil, 1, 1)
		Zorlen_MakeMacro("LPM HELLFIRE", "/script LazyPigMultibox_SCS(GetUnitName(\"player\"), \"Hellfire\", 1, 645)", 1, "Spell_Fire_Incinerate", nil, 1, 1)
	
	elseif class == "Paladin" then
		Zorlen_MakeMacro("LPM DI", "/script LazyPigMultibox_SmartIntervention()--CastSpellByName(\"Divine Intervention\")", 1, "Spell_Nature_TimeStop", nil, 1, 1)
		
	elseif class == "Hunter" then
		Zorlen_MakeMacro("LPM PET ATTACK", "/script LazyPigMultibox_SPA(GetUnitName(\"player\"))", 1, "Spell_Nature_SpiritWolf", nil, 1, 1)
		
	elseif class == "Priest" then
		Zorlen_MakeMacro("LPM SILENCE", "/script SpellStopCasting() stopShoot() Zorlen_castSpellByName(\"Silence\")--CastSpellByName(\"Silence\")", 1, "Spell_Shadow_ImpPhaseShift", nil, 1, 1)
		Zorlen_MakeMacro("LPM SCREAM", "/script SpellStopCasting() stopShoot() Zorlen_castSpellByName(\"Psychic Scream\")--CastSpellByName(\"Psychic Scream\")", 1, "Spell_Shadow_PsychicScream", nil, 1, 1)
	end
end

function LazyPigMultibox_Rez()
	if not UnitIsDeadOrGhost("player") and not UnitAffectingCombat("player") and not Zorlen_isEnemy("target") then
		local dead_unit = LazyPigMultibox_ReturnDeadUnit()
		local LPM_CLASS = {}
		LPM_CLASS["Priest"] = "Resurrection"
		LPM_CLASS["Shaman"] = "Ancestral Spirit"
		LPM_CLASS["Paladin"] = "Redemption"
		
		local spell = LPM_CLASS[UnitClass("player")]
		
		if dead_unit and spell and Zorlen_IsSpellKnown(spell) then
			TargetUnit(dead_unit)
			if Zorlen_castSpellByName(spell) then
				LazyPigMultibox_Annouce("lpm_slaveannouce", "Resurrection - "..GetUnitName(dead_unit))
			end
			return true
		end
	end
	return nil
end

function LazyPigMultibox_ReturnDeadUnit()
	local InRaid = UnitInRaid("player")
	local PLAYER = "player"
	local group = nil
	local NumMembers = nil
	local counter = nil
	local u = nil
	local dead_rightunit1 = nil
	local dead_rightunit2 = nil
	local dead_rightunit3 = nil
	local dead_rightunit4 = nil
	
	if InRaid then
		NumMembers = GetNumRaidMembers()
		counter = 1
		group = "raid"
	else
		NumMembers = GetNumPartyMembers()
		counter = 0
		group = "party"
	end
	
	while counter <= NumMembers do
		if counter == 0 then
			u = PLAYER
		else
			u = group..""..counter
		end
					
		if UnitIsDead(u) and not UnitIsGhost(u) and CheckInteractDistance(u, 4) then	
			if isPaladin(u) or isPriest(u) or isShaman(u) then
				dead_rightunit1 = u
				break
			elseif isDruid(u) or UnitIsPartyLeader(u) then
				dead_rightunit2 = u
			elseif not dead_rightunit3 then
				dead_rightunit3 = u
			else
				dead_rightunit4 = u
			end
		end
		counter = counter + 1		
	end

	if LPMULTIBOX.UNIQUE_SPELL then
		dead_rightunit1 = dead_rightunit4 or dead_rightunit3 or dead_rightunit2 or dead_rightunit1
	else
		dead_rightunit1 = dead_rightunit1 or dead_rightunit2 or dead_rightunit3 or dead_rightunit4
	end

	return dead_rightunit1
end

function LazyPigMultibox_IsSpellInRangeAndActionBar(SpellName)
	if SpellName and Zorlen_IsSpellKnown(SpellName) then
		local SpellButton = Zorlen_Button[SpellName..".Any"]
		if SpellButton then
			if(IsActionInRange(SpellButton) == 1) then
				return true
			else 
				return false
			end
		else
			LazyPigMultibox_Message("No Spell on Actionbar: "..SpellName)
			LazyPigMultibox_Annouce("lpm_slaveannouce", "No Spell on Actionbar: "..SpellName)
			return false
		end
	end
	return false
end

function LazyPigMultibox_IsPetSpellOnActionBar(SpellName)
	local m = nil
	if not (UnitHealth("pet") > 0) then
		return false
	end
	
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local slotspellname, slotspellsubtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		if (slotspellname and slotspellname == SpellName) then
			return true
		end
	end
	return false
end

function LazyPigMultibox_IsPetSpellKnown(SpellName)
	local m = nil
	if not (UnitHealth("pet") > 0) then
		return false
	end
	
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local slotspellname, slotspellsubtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		if (slotspellname and slotspellname == SpellName) then
			return true
		end
	end
	return false
end

function LazyPigMultibox_QuestShareUpdate(force_reset)
	if force_reset or LPM_QUESTSHARE.TIME  and LPM_QUESTSHARE.TIME < GetTime() then
		StaticPopup_Hide("LPM_QUESTSHARE");
		LPM_QUESTSHARE.TITLE = nil;
		LPM_QUESTSHARE.TIME = nil
	end
end
	
function LazyPigMultibox_QuestShare()
	if LPMULTIBOX.STATUS and LPMULTIBOX.POP_QUESTSHARE and GetNumPartyMembers() > 0 then
		local unit = LazyPigMultibox_ReturnLeaderUnit()
		local leader = unit and UnitIsUnit(unit, "player")
		if leader then
			local NEWQUEST = LazyPigMultibox_QuestLogScan();
			for blockindex1,blockmatch1 in pairs(NEWQUEST) do
				for blockindex2,blockmatch2 in pairs(LPM_QUEST) do
					if blockmatch1 == blockmatch2 then
						NEWQUEST[blockindex1] = nil
					end
				end
			end
			
			for blockindex1,blockmatch1 in pairs(NEWQUEST) do
				SelectQuestLogEntry(blockindex1);
				if (GetQuestLogPushable()) then
					StaticPopupDialogs["LPM_QUESTSHARE"]["text"] = "Share Quest: "..blockmatch1.." ?"
					StaticPopup_Show ("LPM_QUESTSHARE")
					LPM_QUESTSHARE.TITLE = blockmatch1
					LPM_QUESTSHARE.TIME = GetTime() + 8
				end
			end
		end
	end	
end

function LazyPigMultibox_QuestShareConfirm()
	local NEWQUEST = LazyPigMultibox_QuestLogScan();	
	for blockindex1,blockmatch1 in pairs(NEWQUEST) do
		if LPM_QUESTSHARE.TITLE and LPM_QUESTSHARE.TITLE == blockmatch1 then	
			SelectQuestLogEntry(blockindex1);
			QuestLogPushQuest();
			LazyPigMultibox_Annouce("lpm_qaccept", "");
		end	
	end
	LazyPigMultibox_QuestShareUpdate(true)
end

function LazyPigMultibox_QuestLogScan()
	local QUESTTABLE = {}
	local i = 0;
	while (GetQuestLogTitle(i+1) ~= nil) do
		i = i + 1;
		local title, level, tag, header = GetQuestLogTitle(i);
		if (not header) then
			QUESTTABLE[i] = title
		end
	end
	return QUESTTABLE
end

function LazyPigMultibox_MakeMeLeader()
	if not UnitIsPartyLeader("player") then
		LazyPigMultibox_Annouce("lpm_makemeleader", "");
	end
end

function LazyPigMultibox_CheckDelayMode(msg_off)
	local val = LPMULTIBOX.AM_KEEPTARGET and (LPMULTIBOX.AM_ACTIVEENEMY or LPMULTIBOX.AM_ACTIVENPCENEMY)
	if not val and not msg_off then
		LazyPigMultibox_Message("Sniper Mode Must Be Enabled")
		LazyPigMultibox_Annouce("lpm_slaveannouce","Sniper Mode Must Be Enabled")
	end
	return val
end


function LazyPigMultibox_SmartEnemyTarget()
	local indoors = LazyPig_Raid() or LazyPig_Dungeon()
	if not UnitAffectingCombat("player") or not indoors then
		LazyPigMultibox_TargetNearestEnemy(nil, true)
	else
		LazyPigMultibox_TargetNearestEnemy(true, true)
	end
end


function LazyPigMultibox_TargetNearestEnemy(active_enemy, player_aggro_first, cycles)
	
	local target_exists = Zorlen_isActiveEnemy("target")
	
	
	
	
	local number = cycles or 6
	local counter = 0
	
	local highest_health = nil
	local highest_health_aggro = nil
	local lowest_health = nil
	local lowest_health_aggro = nil
	
	local true_cycle = nil
	local health = nil
	local toggle = nil
	
	LPM_TARGET.TOGGLE = not LPM_TARGET.TOGGLE
	
	ClearTarget();
	while (counter <= number) do
		
		TargetNearestEnemy();	
				
		if not active_enemy or active_enemy and Zorlen_isActiveEnemy("target") then

			health = UnitHealth("target") / UnitHealthMax("target")
			player_aggro_first = player_aggro_first and Zorlen_isEnemy("target") and UnitExists("targettarget") and UnitIsPlayer("targettarget") and not Zorlen_isEnemy("targettarget")
			
			if LPM_TARGET.TOGGLE then
				if(not true_cycle) then
					if player_aggro_first and (not lowest_health_aggro or health < lowest_health_aggro) then
						lowest_health_aggro = health
					end
					if(not lowest_health or health < lowest_health) then
						lowest_health = health
					end

					if(counter == number) then
						ClearTarget();
						true_cycle = true
						counter = 0
					end
				else
					if(lowest_health_aggro and health <= lowest_health_aggro or not lowest_health_aggro and health <= lowest_health) then
						return
					end
				end
			else
				if(not true_cycle) then	
					if player_aggro_first and (not highest_health_aggro or health > highest_health_aggro) then
						highest_health_aggro = health
					end
					if(not highest_health or health > highest_health) then
						highest_health = health
					end
					
					if(counter == number) then
						ClearTarget();
						true_cycle = true
						counter = 0
					end
				else
					if(highest_health_aggro and health >= highest_health_aggro or not highest_health_aggro and health >= highest_health) then
						return
					end
				end
			end
			
		end
		counter = counter + 1
	end
	
	if target_exists and UnitAffectingCombat("player") and not Zorlen_isActiveEnemy("target") then
		TargetLastTarget();
		if not Zorlen_isActiveEnemy("target") then
			ClearTarget();
		end
	else
		ClearTarget();
	end	
end


function LazyPigMultibox_SetFFA(mode)
	local time = GetTime()
	if mode then
		LPM_TIMER.SETFFA = time + 1
	elseif LPM_TIMER.SETFFA and LPM_TIMER.SETFFA < time then
		local mode = "freeforall"
		local present_mode = GetLootMethod()
		LPM_TIMER.SETFFA = nil
		if LPMULTIBOX.STATUS and LPMULTIBOX.POP_FFA and present_mode ~= mode and UnitIsPartyLeader("player") then
			SetLootMethod(mode);
		end
	end	
end

function LazyPigMultibox_DataStringEncode(...)
	local str = ""
	local lenght = table.getn(arg)
	if lenght > 9 then
		DEFAULT_CHAT_FRAME:AddMessage("LazyPigMultibox_DataStringEncode - String Limit Exceeded")
		return ""
	end
	for i = 1, table.getn(arg), 1 do
		str = str.."z"..i..arg[i]
	end
	str = str.."z10"
	return str
end

function LazyPigMultibox_DataStringDecode(str)
	local data = {}
	local count = 1
	for i = 1, 10, 1 do
		local x,y = string.find(str, "z"..i)
		if x and (x - 1) > 0 then
			data[count] = x - 1;
			count = count + 1;
		end
		if y and (y + 1) < strlen(str) then
			data[count] = y + 1;
			count = count + 1;
		end
	end
	
	local data_out = {}
	local table_nr = table.getn(data)	
	local counter = 1
	
	for i = 1, table_nr, 2 do
		data_out[counter] = string.sub(str, data[i], data[i+1]) 
		counter = counter + 1
	end
		
	return data_out[1], data_out[2], data_out[3], data_out[4], data_out[5], data_out[6], data_out[7], data_out[8], data_out[9]
end

function LazyPigMultibox_UnitBuff()
	SMARTBUFF_Check(0);
end

function LazyPigMultibox_PetAttack()
	if UnitExists("target") and Zorlen_isEnemy("target") then
		if not LazyPigMultibox_CheckDelayMode(true) or not UnitExists("pettarget") or UnitIsPartyLeader("player") then
			PetAttack()
		end	
	elseif not LazyPigMultibox_UtilizeTarget() then
		PetPassiveMode()
		PetFollow()
	end
end

function LazyPigMultibox_SetIcon(index, unit)
	if index then
		unit = unit or "target"
		if not UnitExists(unit) then
			return
		end
		if not (GetRaidTargetIndex(unit) == index) then
			SetRaidTarget(unit, index)	
		end
		--1 = Yellow 4-point Star 
		--2 = Orange Circle 
		--3 = Purple Diamond 
		--4 = Green Triangle 
		--5 = White Crescent Moon 
		--6 = Blue Square 
		--7 = Red "X" Cross 
		--8 = White Skull 
	end	
end

function LazyPigMultibox_SMARTBUFF_AddMsgErr(msg, force)
	LazyPigMultibox_Annouce("lpm_slaveannouce", "SmartBuff - "..msg)
	Original_SMARTBUFF_AddMsgErr(msg, force)
end

function LazyPigMultibox_TargetUnit(u)
	if UnitExists(u) and CheckInteractDistance(u, 4) then
		TargetUnit(u)
		return true
	end
	return nil
end

function LazyPigMultibox_SFL(slave_master_name, task, duration, modifier) -- selective function launch
	local mod = IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown()
	if not (modifier and mod or not modifier and not mod) then
		return
	end
	--if not LazyPigMultibox_CheckDelayMode() then
		--return
	if not slave_master_name or not task or not duration then 
		LazyPigMultibox_Annouce("lpm_slaveannouce","Wrong or Missing Parameter")
		return
	end

	if string.lower(slave_master_name) == string.lower(GetUnitName("player")) then
		if LazyPigMultibox_SlaveCheck() then	
			LazyPigMultibox_AssistMaster(true)
		end	
		LazyPigMultibox_Schedule(task);
		LazyPigMultibox_Schedule();
	else
		LazyPigMultibox_Annouce("lpm_schedule", LazyPigMultibox_DataStringEncode(slave_master_name, task, duration))	
	end	
end

function LazyPigMultibox_SPA(slave_master_name, icon_index, modifier)--selective pet attack
	local mod = IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown()
	if not (modifier and mod or not modifier and not mod) then
		return
	end
	
	if not slave_master_name then 
		LazyPigMultibox_Annouce("lpm_slaveannouce","Wrong or Missing Parameter")
		return
	end
	
	LazyPigMultibox_SetIcon(icon_index);
	
	if string.lower(slave_master_name) == string.lower(GetUnitName("player")) then
		if LazyPigMultibox_SlaveCheck() then	
			LazyPigMultibox_AssistMaster(true);
		end	
		LazyPigMultibox_Schedule("petattack", 0.25);
		LazyPigMultibox_Schedule();
	else
		LazyPigMultibox_Annouce("lpm_petattack", slave_master_name);	
	end	
end

function LazyPigMultibox_SCS(slave_master_name, spell_name, duration, mana, modifier) -- selective cast spell
	local mod = IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown()
	if not (modifier and mod or not modifier and not mod) then
		return
	end
		
	--if not LazyPigMultibox_CheckDelayMode() then
		--return
	if not slave_master_name or not spell_name or not duration then 
		LazyPigMultibox_Annouce("lpm_slaveannouce","Wrong or Missing Parameter")
		return
	end

	if string.lower(slave_master_name) == string.lower(GetUnitName("player")) then
		if LazyPigMultibox_SlaveCheck() then
			LazyPigMultibox_AssistMaster(true)
		end	
		LazyPigMultibox_ScheduleSpell(spell_name, duration, mana);
		LazyPigMultibox_ScheduleSpell();
	else
		LazyPigMultibox_Annouce("lpm_schedule_spell", LazyPigMultibox_DataStringEncode(slave_master_name, spell_name, duration, mana))	
	end	
end

function LazyPigMultibox_SUB(slave_master_name, modifier) -- selective unit buff
	local mod = IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown()
	if not (modifier and mod or not modifier and not mod) then
		return
	end
	
	if not slave_master_name then 
		LazyPigMultibox_Annouce("lpm_slaveannouce","Wrong or Missing Parameter")
		return
	end
	
	if string.lower(slave_master_name) == string.lower(GetUnitName("player")) or string.lower(slave_master_name) == "all" then
		LazyPigMultibox_Schedule("unitbuff", 10);
		LazyPigMultibox_Schedule();	
	end	
	
	local leader_id = LazyPigMultibox_ReturnLeaderUnit();
	
	if leader_id and UnitIsUnit(leader_id , "player") then
		LazyPigMultibox_Annouce("lpm_unitbuff", slave_master_name);
	end
	
end

function abc()
				if Zorlen_isChanneling() or Zorlen_isCasting() then
					local xx = "Casting "
					local lx = Zorlen_CastingSpellName or Zorlen_ChannelingSpellName
					DEFAULT_CHAT_FRAME:AddMessage(xx..lx)
					
					return
				end
end

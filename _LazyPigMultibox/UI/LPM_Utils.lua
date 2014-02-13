
LPMULTIBOX_UI = {
    TPF_LOCK = false,
    TPF_SHOW = true,
    TPF_MINI = false,
    TPF_BLIZZPLAYER = false,
    TPF_BLIZZPARTY = false,
    TPF_SCALE = 1.00,
    TPF_PADDING = 3,
    TPF_BGALPHA = 0.37,
    LF_LOCK = true,
    LF_SCALE = 1.00,
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


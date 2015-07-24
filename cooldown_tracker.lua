local ZAF = Zed_ArenaFrames
local addon = "Zed_ArenaFrames"


local UnitExists = UnitExists
local UnitName = UnitName 
local UnitHealth, UnitHealthMax=UnitHealth, UnitHealthMax
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local UnitCastingInfo = UnitCastingInfo  
local UnitChannelInfo = UnitChannelInfo 
local UnitClass = UnitClass
local UnitGUID = UnitGUID 
local select = select 
local ipairs = ipairs  
local unpack = unpack 
local pairs = pairs 
local _G = _G 
local stringsub = string.sub 
local stringmatch = string.match
local tinsert = table.insert 
local floor = math.floor 

ZAF.Cooldowns = CreateFrame("Frame")
ZAF.Cooldowns.GUID = {}
ZAF.NameGUIDs = {}
local CooldownModule = ZAF.Cooldowns 


local latency_modifier = 0.05 -- not used currently

local CooldownByGUID = {}


-- GetSpellInfo(NUMBER) returns localized name of spell, english strings of the spells do not work on non english clients
ZAF.spell_cooldown = {	
 -- General
["Release of Light"] = 120,	-- bauble of true blood
["PvP Trinket"] = 120,
["Every Man for Himself"] = 120,
-- Mage
[GetSpellInfo(2139)] 	= 24, -- counterspell
[GetSpellInfo(44572)] = 30, -- deep freeze
[GetSpellInfo(1953)] = 15, -- blink
["Ice Barrier"] = 60,
["Frost Nova"] = 24,

-- Warlock
[GetSpellInfo(19647)] = 24, -- spell lock
[GetSpellInfo(30283)] = 20, -- Shadowfury
["Demonic Circle: Teleport"] = 28,

-- DK
[GetSpellInfo(49203)] = 60,	-- hungering cold
[GetSpellInfo(48707)] = 45, 	-- AMS
[GetSpellInfo(47528)] = 10, -- MF
[GetSpellInfo(49576)] = 25, -- grip 
[GetSpellInfo(49206)] = 180, -- Gargoyle

-- Hunter
[GetSpellInfo(19503)] = 30,	-- scatter
[GetSpellInfo(33490)] = 20,	-- silencing shot
[GetSpellInfo(19263)] = 90,	-- Deterence
["Readiness"] = 180,
-- Rogue
[GetSpellInfo(1766)] = 10, -- kick 
[GetSpellInfo(31224)] = 60, -- cloak
[GetSpellInfo(36554)] = 20, -- step
[GetSpellInfo(51713)] = 60, -- sdance
["Blind"] = 120,
["Preparation"] = 300, -- no idea what's the cd they use it only once anyways
["Dismantle"] = 60,

-- Warrior
[GetSpellInfo(72)] 	= 12,	-- shield bash
[GetSpellInfo(6552)] 	= 10 , -- pummel
[GetSpellInfo(23920)] = 10, -- reflect 23920
[GetSpellInfo(46924)] = 90, -- bstorm 
["Disarm"] = 60,

-- Paladin
[GetSpellInfo(642)] = 300,	-- bubble
["Holy Shock"] = 5,	-- holy shock 48825
[GetSpellInfo(10278)] = 300,	-- hand of protection
[GetSpellInfo(10308)] = 40,	-- hammer of justice
[GetSpellInfo(1044)] = 25,	-- freedom
[GetSpellInfo(64205)] = 120,	-- divine sac 

-- Priest
[GetSpellInfo(10890)] = 24, -- psychic scream
[GetSpellInfo(53007)]= 8, 	-- penance 53007
[GetSpellInfo(33206)] = 180, 	-- pain suppress
[GetSpellInfo(19236)] = 120, 	-- desp prayer
[GetSpellInfo(15487)] = 45,	-- silence 
[GetSpellInfo(47585)] = 75, -- dispersion	(glyphed)
[GetSpellInfo(64044)] = 120, -- psychic horror 
-- Shaman

[GetSpellInfo(57994)] = 5, -- wind shear 
[GetSpellInfo(2484)] = 10.3, -- earthbind totem (elemental)
[GetSpellInfo(8177)] = 15, -- grounding totem  seems like default is 15 
["Lava Burst"] = 6,
["Hex"] = 45,
-- Druid 
[GetSpellInfo(22812)] = 60,	-- barkskin
}

ZAF.Cooldowns.Shared_Cooldowns = {
["Shield Bash"] = {GetSpellInfo(6552)},
["Pummel"] = {GetSpellInfo(72)},
["PvP Trinket"] = { GetSpellInfo(59752)},
["Every Man For Himself"] = {"PvP Trinket", nil, "Interface\\Icons\\INV_Jewelry_TrinketPVP_02" },
}




local resetCooldowns = {
["Preparation"] = {
	["Vanish"] = true,
	["Shadowstep"] = true,
	["Kick"] = true,
	["Sprint"] = true,
 },
["Cold Snap"] = {
	["Deep Freeze"] = true,
	["Ice Block"] = true,
	["Frost Nova"] = true,
	["Ice Barrier"] = true,
},
["Readiness"] = {
	["Scatter Shot"] = true,
	["Deterrence"] = true,
	["Silencing"] = true,

}, -- readiness 23989

}

function GetCooldownByGUID(guid)
local cooldown = not CooldownModule.GUID[guid] and 0 or not CooldownModule.GUID[guid][spell] and 0 or CooldownModule.GUID[guid][spell] 
return cooldown 
end 



local exceptions = {	-- spell icon table 
["Penance"] = select(3,GetSpellInfo(53007)),
}

local guidDB = ZAF.NameGUIDs

function CooldownModule:COMBAT_LOG_EVENT_UNFILTERED(event,...)
local _ , subType, sourceGUID, sourceName = ...
if subType == "SPELL_CAST_SUCCESS" then 
	local spellID = select(9,...)
	local spell,_,icon = GetSpellInfo(spellID)

	--local sourceGUID = select(3,...)
	--local sourceName = select(4,...)
	

	if ZAF.spell_cooldown[spell] then 
	local start = GetTime()
	local currentTime = start 
	local iconTexture = exceptions[spell] or icon
	if not self.GUID[sourceGUID] then 
		self.GUID[sourceGUID] = {}
	end 
	
	if not CooldownByGUID[sourceGUID] then 
		CooldownByGUID[sourceGUID] = {}

	end 	
	if not CooldownByGUID[sourceGUID][spell]  then 
	CooldownByGUID[sourceGUID][spell] = ZAF.spell_cooldown[spell] 
	end 
	if self.GUID[sourceGUID][spell] 
	and currentTime <= self.GUID[sourceGUID][spell].finish then -- Cooldown did not expire yet and this GUID used it; it's shorter
	local differenceInOldNew = self.GUID[sourceGUID][spell].finish - currentTime 
		CooldownByGUID[sourceGUID][spell] = CooldownByGUID[sourceGUID][spell] - differenceInOldNew
	end 
	
	
	
	
		local finish = start + 	CooldownByGUID[sourceGUID][spell]	--ZAF.spell_cooldown[spell]
		local shared_cd_spell = self.Shared_Cooldowns[spell]
		
			self.GUID[sourceGUID][spell] = {
			start = start,
			finish = finish,
			icon = icon,		
			}
			
	if shared_cd_spell then 
			local finish = start + ZAF.spell_cooldown[spell]
			local icon = shared_cd_spell[3]
			self.GUID[sourceGUID][shared_cd_spell[1]] = {
			start = start,
			finish = finish,
			icon = icon,		
			}
	self:Callbacks(sourceGUID, shared_cd_spell[1], start, finish, icon)
	end 

	self:Callbacks(sourceGUID, spell, start, finish, icon)
	end 

	
end 

if sourceName and sourceGUID then 
guidDB[sourceName] = sourceGUID  -- update guid in data base for improved nameplate functionality


end 
end 

function CooldownModule:UNIT_SPELLCAST_SUCCEEDED(event,...)
local unit, spell = ...
if exceptions[spell] and  ZAF.spell_cooldown[spell] then -- bugged icon, change it 
	local sourceGUID = UnitGUID(unit)
	if not self.GUID[sourceGUID] then 
	self.GUID[sourceGUID] = {}	
	end 
	
	local start = GetTime()
	local finish = GetTime()+ ZAF.spell_cooldown[spell]
	local icon = exceptions[spell]
	ZAF.Cooldowns.GUID[sourceGUID][spell] = {
												start =start,
												finish = finish,
												icon = icon,		
											}
	self:Callbacks(sourceGUID, spell, start, finish, icon)

end 
if resetCooldowns[spell] then 
	local sourceGUID = UnitGUID(unit) 
	if ZAF.Cooldowns.GUID[sourceGUID] then 
	for cd,_ in pairs(ZAF.Cooldowns.GUID[sourceGUID]) do 

		if resetCooldowns[spell][cd] then 
		ZAF.Cooldowns.GUID[sourceGUID][cd] = nil 
		self:Callbacks(sourceGUID, cd, GetTime(), GetTime(), nil)

		end 
	end 
	end 

end 
end 
CooldownModule.Registered = {}
function CooldownModule:Callbacks(sourceGUID, spell, start, finish, icon)
for frame, val in pairs(self.Registered) do 
frame:Callback(sourceGUID, spell, start, finish, icon)
end 
end 
function CooldownModule:Register(frame,val)
self.Registered[frame] = true
end 
function CooldownModule:PLAYER_LEAVING_WORLD()
wipe(self.GUID) -- reset GUIDs 
wipe(ZAF.NameGUIDs)
end 

function CooldownModule:CHAT_MSG_SYSTEM(event,arg1)
if arg1:match("Replay") then 
wipe(self.GUID) -- reset GUIDs 
wipe(ZAF.NameGUIDs)
end 
end 


local function eventHandler(self, event,...)
self[event](self,event,...)
end 

local function DeleteExpiredCooldowns(self, elapsed)
local GUID_cooldowns = self.GUID 
for guid, GUID_table in pairs(GUID_cooldowns) do 
	for spell, spell_table in pairs(GUID_table) do 
		if GetTime() >= spell_table.finish then 
			self.GUID[guid][spell] = nil 
		end 
	end 
end 
end 


function ZAF:GetUnitCooldowns(unit)
local unitID = UnitGUID(unit)
local cds = {}
local hasCooldown 
if self.Cooldowns.GUID[unitID] then 
for spell, spellTable in pairs(self.Cooldowns.GUID[unitID]) do 
	if spell then 
	hasCooldown = true 
	cds[spell]= spellTable
	end 
end 
end 
if hasCooldown then return cds end 
end 

function ZAF:GetUnitSpellCD(unit,arg)
local unitID = UnitGUID(unit)
if self.Cooldowns.GUID[unitID] then 
for spell, spellTable in pairs(self.Cooldowns.GUID[unitID]) do 
	if spell == arg then 
	return spellTable
	end 
end 
end 
end 



function ZAF:Init_Cooldowns()
ZAF.Cooldowns:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ZAF.Cooldowns:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
ZAF.Cooldowns:RegisterEvent("PLAYER_LEAVING_WORLD")
ZAF.Cooldowns:RegisterEvent("CHAT_MSG_SYSTEM")
ZAF.Cooldowns:SetScript("OnEvent", eventHandler)
ZAF.Cooldowns:SetScript("OnUpdate", DeleteExpiredCooldowns)
 
end 

function CooldownModule:Disable()
ZAF.Cooldowns:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ZAF.Cooldowns:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
ZAF.Cooldowns:SetScript("OnUpdate", nil)
end 

function CooldownModule:Enable()
ZAF.Cooldowns:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ZAF.Cooldowns:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
ZAF.Cooldowns:SetScript("OnUpdate", DeleteExpiredCooldowns)
end 
ZAF:Init_Cooldowns()

ZAF = Zed_ArenaFrames

local MAX_ICONS = 10
local PVP_TRINKET_TEXTURE = "Interface\\Icons\\INV_Jewelry_TrinketPVP_02"


-- Some of cooldowns are already in cooldown tracker
-- you can add 		, cooldown = time  parameter just incase or overwrite existing cd 
local BAR_SETUP = {

["Warrior"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE, cooldown = 120, },
				{ name = "Pummel", icon = select(3,GetSpellInfo(6552)), cooldown = 10,},
				{ name = "Spell Reflection", icon = select(3,GetSpellInfo(23920)) },
			-- 	{ ID = 6552, cooldown=10  },		This works as well, name + texture or spell id 
},
["Death Knight"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Mind Freeze", icon = select(3,GetSpellInfo(47528)) },
				{ name = "Death Grip", icon = select(3,GetSpellInfo(49576)) },
},
["Rogue"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Kick", icon = select(3,GetSpellInfo(1766)) },
				{ name = "Shadowstep", icon = select(3,GetSpellInfo(36554)) },
				{ ID = 51713, cooldown = 60, }, -- Shadowdance
},
["Hunter"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Scatter Shot", icon = select(3,GetSpellInfo(19503)) },
				
},
["Shaman"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Wind Shear", icon = select(3,GetSpellInfo(57994)) },
				{ name = "Grounding Totem", icon = select(3,GetSpellInfo(8177)) },
},
["Druid"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Barkskin", icon = select(3,GetSpellInfo(22812)), cooldown=60 },
			
},
["Paladin"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Holy Shock", icon = select(3,GetSpellInfo(48825)) },
				{ name = "Hammer of Justice", icon = select(3,GetSpellInfo(10308)) },
				{ name = "Hand of Freedom", icon = select(3,GetSpellInfo(1044)) },
},
["Warlock"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Spell Lock", icon = select(3,GetSpellInfo(19647)) },
				{ name = "Shadowfury", icon = select(3,GetSpellInfo(30283)), },
},
["Priest"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Psychic Scream", icon = select(3,GetSpellInfo(10890)) },
				{ name = "Penance", icon = select(3,GetSpellInfo(53007)) },
},
["Mage"] = {
				{ name = "PvP Trinket", icon = PVP_TRINKET_TEXTURE },
				{ name = "Counterspell", icon = select(3,GetSpellInfo(2139)) },
				{ name = "Deep Freeze", icon = select(3,GetSpellInfo(44572)) },
				{ name = "Blink", icon = select(3,GetSpellInfo(1953)) },
},
}

-- validate bar settings 
for class, bars in pairs(BAR_SETUP) do 
	for i, bar in pairs(bars) do 
	local spellName = bar.name or GetSpellInfo(bar.ID)
	local cd = bar.cooldown 
		if cd then 
		ZAF.spell_cooldown[spellName] = cd 
		end 
		if not ZAF.spell_cooldown[spellName]  then 
		print("Zed_ArenaFrames: Missing cooldown parameter for ", spellName," in BAR_SETUP")
		end 
		if bar.ID then 
		bar.icon = select(3, GetSpellInfo(bar.ID))
		end 
	end
end 

local ZAF = Zed_ArenaFrames
ZAF.CD = {}

Zed_ArenaFrames.CooldownBars = {}

function Zed_ArenaFrames.CD:SetBarPoint(POINT)

for BAR, val in pairs(Zed_ArenaFrames.CooldownBars) do 

end
end 

function Zed_ArenaFrames.CD:SetPerRow(rows)
Zed_ArenaFramesDB.CD.PER_ROW = rows 
local ICON_SIZE = Zed_ArenaFramesDB.CD.SIZE
for BAR, val in pairs(Zed_ArenaFrames.CooldownBars) do 
 
for i=1,MAX_ICONS do 

icon = BAR[i]
icon:ClearAllPoints()
if i>1 then 
icon:SetPoint("RIGHT", BAR[i-1], "RIGHT", ICON_SIZE,0)
else 
icon:SetPoint("CENTER", BAR)
end 

if i > 1 and (i-1)%rows == 0 then 
icon:ClearAllPoints()
icon:SetPoint("BOTTOM", BAR[i-rows], "BOTTOM", 0, -ICON_SIZE)

end 
end 

end 
end 

function Zed_ArenaFrames.CD:SetIconSize(size)
 Zed_ArenaFramesDB.CD.SIZE = size
for BAR, val in pairs(Zed_ArenaFrames.CooldownBars) do 
 
for i=1,MAX_ICONS do 
icon = BAR[i]
icon:SetSize(size,size)
end 
end 
Zed_ArenaFrames.CD:SetPerRow(Zed_ArenaFramesDB.CD.PER_ROW )
end 

local PVPTRINKETS = {
["Every Man for Himself"] = true,
["PvP Trinket"] = true,

}



local function Create_CooldownBar(parent)
local PER_ROW = Zed_ArenaFramesDB.CD.PER_ROW
local ICON_SIZE = Zed_ArenaFramesDB.CD.SIZE

local BAR = CreateFrame("Frame",nil, parent)
BAR:SetSize(25,25)
BAR.spells = {}
BAR.unit = parent.unit 
ZAF.Cooldowns:Register(BAR,true)
for i=1,MAX_ICONS do 

-- ICON 
local icon = CreateFrame("Frame", nil,BAR)
BAR[i] = icon 

if i>1 then 
icon:SetPoint("RIGHT", BAR[i-1], "RIGHT", ICON_SIZE,0)
else 
icon:SetPoint("CENTER", BAR)
end 
if i > 1 and (i-1)%PER_ROW == 0 then 
icon:ClearAllPoints()
icon:SetPoint("BOTTOM", BAR[i-PER_ROW], "BOTTOM", 0, -ICON_SIZE)

end 


icon:SetSize(ICON_SIZE,ICON_SIZE)
-- TEXTURE
icon.texture = icon:CreateTexture("ARTWORK")
icon.texture:SetAllPoints(icon)
icon.texture:SetTexture( select(3,GetSpellInfo(57994)))
icon.texture:SetTexCoord(0.07,0.9,0.07,0.90) 	-- remove borders 
icon.texture:SetDrawLayer("BACKGROUND")
-- COOLDOWN
icon.cd = CreateFrame("Cooldown")
icon.cd:ClearAllPoints()
icon.cd:SetAllPoints(icon)
icon.cd:SetFrameStrata("HIGH")
icon.cd:SetAlpha(1)
-- TEXT
icon.text = icon:CreateFontString(nil,"ARTWORK")
icon.text:SetFont(STANDARD_TEXT_FONT,16,"OUTLINE")
icon.text:SetPoint("CENTER", frame,0, 0)
icon.text:SetText("")
icon.text:SetTextColor(0.8 ,0,0,1)
--icon.cd:SetReverse(true)
-- BORDER
icon.border = CreateFrame("Frame", nil, icon)
icon.border:SetPoint("CENTER", icon)
icon.border:SetBackdrop({
 bgFile=nil,	
 edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
 tile=true,
 tileSize=5,
 edgeSize= 1,	
})
icon.border:SetBackdropColor(0,0,0)
icon.border:SetBackdropBorderColor(0,0,0)
icon.border:SetAlpha(1)
icon.border:SetAllPoints(icon)
icon.border:Show()

icon:Hide()
BAR[i] = icon 
end 
local function UpdateBar(self)
local class = UnitClass(self.unit)
if not class then return end 
for i=1, MAX_ICONS do 

local IconConfig = BAR_SETUP[class][i]
local icon = self[i]
if IconConfig then 

local spell,_,iconbyID = IconConfig.name or GetSpellInfo(IconConfig.ID)
if not spell then print("Zed_ArenaFrames: Invalid CD bar config in cooldown_bar.lua")return end  
self.spells[spell] = icon 
icon:Show()
icon.texture:SetTexture(IconConfig.icon or iconbyID)
icon.cd:SetCooldown(0,0)

else 
icon:Hide()
end 
end 

end 
--[[
BAR.HideOnExpiration = {}
function BAR:HideIconAfterCD(icon, finish)
BAR.HideOnExpiration[icon] = finish
end
BAR:SetScript("OnUpdate", function(self, elapsed)
for icon, endTime in pairs(self.HideOnExpiration) do 
	if GetTime() > endTime then 
	icon:Hide()
	end 

end 
end)
]]--
function BAR:Callback(sourceguid, spell, start, finish, icon)

if self.spells[spell] and not PVPTRINKETS[spell] and UnitGUID(self.unit) == sourceguid  then 
local icon = self.spells[spell] 
local duration = finish - start 
icon.cd:SetCooldown(start, duration)

elseif PVPTRINKETS[spell] and UnitGUID(self.unit) == sourceguid then 
local icon = self[1]
local duration = finish - start 
icon.cd:SetCooldown(start, duration)
end 
end 
BAR:SetScript("OnShow", UpdateBar)
BAR:SetScript("OnEvent", UpdateBar)
BAR:RegisterEvent("PLAYER_ENTERING_WORLD")


return BAR
end 

function Zed_ArenaFrames.CD.CreateBars()
for i=1,3 do
local arenaFrame = _G["ArenaEnemyFrame"..i]
local cooldown_bar = Create_CooldownBar(arenaFrame)
cooldown_bar:SetPoint("LEFT", arenaFrame, "RIGHT", 150)
cooldown_bar:Show()
Zed_ArenaFrames.CooldownBars[cooldown_bar] = true
end 

end 




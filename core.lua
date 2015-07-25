LoadAddOn("Blizzard_ArenaUI")
UIDROPDOWNMENU_SHOW_TIME = 60 -- extent time menu is shown 

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
local tonumber = tonumber 
local stringsub = string.sub 
local stringmatch = string.match
local tinsert = table.insert 
local CreateFrame = CreateFrame 
local UnitIsPlayer = UnitIsPlayer 

Zed_ArenaFrames = CreateFrame("Frame", "Zed_ArenaFrames")

local AEF = "ArenaEnemyFrame"

Zed_ArenaFrames.frames = {
ArenaEnemyFrames:GetChildren()
}
table.remove(Zed_ArenaFrames.frames, #Zed_ArenaFrames.frames)
-- OPTIONS----------

local FrameDefaults = {
scale = 1,
instants = false,
position = nil,
}
local CooldownbarDefaults = {
PER_ROW = 10,
SIZE= 25,
}

function Zed_ArenaFrames:LoadDefaults()
Zed_ArenaFramesDB = {}
Zed_ArenaFramesDB.UnitFrames = {}
for i=1,#Zed_ArenaFrames.frames do 
Zed_ArenaFramesDB.UnitFrames[Zed_ArenaFrames.frames[i]:GetName()] = FrameDefaults 
end 
Zed_ArenaFramesDB.CD = CooldownbarDefaults
Zed_ArenaFramesDB.instant = {
size = 25,
enabled = true,

}
Zed_ArenaFramesDB.Debuffs = {
filter = "none",

}
Zed_ArenaFramesDB.classcolor = false 
Zed_ArenaFramesDB.Color = {}
end 
local options = Zed_ArenaFramesDB


local function SavePosition(self)
if not self:GetName() then return end 
Zed_ArenaFramesDB.UnitFrames[self:GetName()] = Zed_ArenaFramesDB.UnitFrames[self:GetName()] or {}
local p1,_,p2,x,y = self:GetPoint()
Zed_ArenaFramesDB.UnitFrames[self:GetName()].position = {  p1,"",p2,x,y }
end 
local function SaveScale(self)
if not self or not self:GetName() then return end 
Zed_ArenaFramesDB.UnitFrames[self:GetName()] = Zed_ArenaFramesDB.UnitFrames[self:GetName()] or {}
Zed_ArenaFramesDB.UnitFrames[self:GetName()].scale = self:GetScale()
end 

local arenaframes = {}
for i=1,5 do 
table.insert(arenaframes, AEF..i)
end 

local function round(num, idp)
  local mult = 10^(idp or 0)
  return floor(num * mult + 0.5) / mult
end

local DisableDragAndScaling
local EnableDragAndScaling 
local function frame_OnDragStart(self)
self:RegisterForDrag("LeftButton")
self:StartMoving()
end 

local function frame_OnDragStop(self)
self:StopMovingOrSizing()
DisableDragAndScaling(self)
SavePosition(self)
end 

EnableDragAndScaling = function(frame)
frame:RegisterForClicks("LeftButton")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", frame_OnDragStart)
frame:SetScript("OnDragStop", frame_OnDragStop)

frame:EnableMouseWheel(true)
frame:SetScript("OnMouseWheel", function(self, delta)
	local new_scale = frame:GetScale()+(delta/50)
     self:SetScale(new_scale)
	 self:SetAttribute("scale",new_scale)
	 SaveScale(self)
end)

--frame:SetScript("OnLeave",DisableDragAndScaling)
end 
DisableDragAndScaling= function (frame)
frame:SetScript("OnDragStart", nil)
frame:SetScript("OnDragStop", nil)	
frame:RegisterForDrag(nil)
frame:RegisterForClicks("AnyDown")
frame:SetMovable(false)
--frame:EnableMouse(false)

frame:EnableMouseWheel(false)
frame:SetScript("OnMouseWheel", nil)
SavePosition(frame)
end 

local function EnableArenaDragAndScaling()

local frame = ArenaEnemyFrame1

frame:HookScript("OnAttributeChanged", function(self,attr, val)
if attr == "scale" then 
-- arena2
ArenaEnemyFrame2:SetScale(val)
SaveScale(ArenaEnemyFrame2)
-- arena3
ArenaEnemyFrame3:SetScale(val)
SaveScale(ArenaEnemyFrame3)
-- arena1	pet
ArenaEnemyFrame1PetFrame:SetScale(val)
SaveScale(ArenaEnemyFrame1PetFrame)
-- arena2	pet
ArenaEnemyFrame2PetFrame:SetScale(val)
SaveScale(ArenaEnemyFrame2PetFrame)
-- arena3	pet
ArenaEnemyFrame3PetFrame:SetScale(val)
SaveScale(ArenaEnemyFrame3PetFrame)
end 
end )
end 
EnableArenaDragAndScaling()

local function DisableArenaDragAndScaling()
for i=1,3 do 
local frame = _G["ArenaEnemyFrame"..i]
DisableDragAndScaling(frame)
end 
end 


local function toggleArenaFrames()
local toggle = aef_shown and HideArenaFrames() or ShowArenaFrames() 
end 

local function ArenaClassHealth(boolean)
Zed_ArenaFramesDB.classcolor = boolean 
Zed_ArenaFrames:ClassColorHealth(boolean)

end 

function Zed_ArenaFrames:SetArenaFrameSpacing(spacing)
for i=1,#self.frames do 
local name = self.frames[i]:GetName()
local frame = self.frames[i]

if i > 1 then 
local p1,parent, p2, x,y = frame:GetPoint()
frame:SetPoint(p1,parent, p2, x,y+spacing)


end 
end 
end 

function Zed_ArenaFrames:SetArenaFrameScaling(increment) 
for i=1,5 do 
local arena_unit_name = AEF..i 
local arena_unit_pet = AEF..i.."PetFrame"
local frame = _G[arena_unit_name]
local petframe = _G[arena_unit_pet]
local old_scale = frame:GetScale()
local new_scale = old_scale+increment 
frame:SetScale(new_scale)
SaveScale(frame)

petframe:SetScale(new_scale)
SaveScale(petframe)
end
end 

local function SetRowOption(rows)
local t = { text = tostring(rows), func = function() Zed_ArenaFrames.CD:SetPerRow(rows) end,
			checked = function() if rows==Zed_ArenaFramesDB.CD.PER_ROW then  return true else return nil end  end,
			keepShownOnClick = 1,
		}
return t
end 
local function SetSizeOption(size)

local t = { text = tostring(size), func = function()Zed_ArenaFrames.CD:SetIconSize(size) end,
			checked = function() if size==Zed_ArenaFramesDB.CD.SIZE then  return true else return nil end  end,
			keepShownOnClick = 1,
		}
return t
end 

local function SetScaleOption(increment)

local t = { text = tostring(increment), func = function()Zed_ArenaFrames.SetArenaFrameScaling(increment) end,
			checked = function() if increment==Zed_ArenaFramesDB.UnitFrames["ArenaEnemyFrame1"].scale then  return true else return nil end  end,
			keepShownOnClick = 1,
		}
return t
end 


local function IncreaseSpace()
Zed_ArenaFrames:SetArenaFrameSpacing(-5)
end 
local function DecreaseSpace()
Zed_ArenaFrames:SetArenaFrameSpacing(5)
end 
local frame_menu= {}



function Zed_ArenaFrames:AddMenuOption(optionTable)
table.insert(Zed_ArenaFrames.menu,(#Zed_ArenaFrames.menu)+1,optionTable)
end 



Zed_ArenaFrames.menu = {
    { text = "Arena Frames", isTitle = true},
	{ text = "Unlock Dragging frame", func = function() EnableDragAndScaling(ArenaEnemyFrame1) end, keepShownOnClick = 1, },
	{ text = "Arena Frames Size", hasArrow = true, menuList = {
		{ text = "Increase", func = function() Zed_ArenaFrames:SetArenaFrameScaling(0.05)	end, keepShownOnClick = 1,},
		{ text = "Decrease", func = function() Zed_ArenaFrames:SetArenaFrameScaling(-0.05)	end,keepShownOnClick = 1,},
		
		},
		},
	{ text = "Arena Frame spacing", hasArrow = true,	menuList = {
		{ text = "Increase", func = IncreaseSpace, keepShownOnClick = 1,},
		{ text = "Decrease", func = DecreaseSpace,keepShownOnClick = 1,},
																	},},
	
	{ text = "Color Settings", hasArrow = true, menuList = {
    { text = "Class Color Healthbar", 
		func = function(...) local checked = select(4,...) ArenaClassHealth(checked) end,
		checked = function() return Zed_ArenaFramesDB.classcolor end,
		keepShownOnClick = 1, },
		
		},
	 },
	 
	{ text= "Cooldownbar", hasArrow=true, menuList = {
   { text = "Icons per Row", hasArrow = true,
	menuList = {
		SetRowOption(2),
		SetRowOption(4),
		SetRowOption(6),
		SetRowOption(8),
		SetRowOption(10),
	},
	},
	
	 { text = "Icon Size", hasArrow = true,
	menuList = {
		SetSizeOption(15),
		SetSizeOption(20),
		SetSizeOption(25),
		SetSizeOption(30),
		SetSizeOption(35),
		SetSizeOption(45),
		SetSizeOption(55),
	},
	},
	},
	},
	
}
function Zed_ArenaFrames:CreateMenu(frame, name)
frame_menu[frame] = menu 
return menu 
end 




Zed_ArenaOptionsFrame = CreateFrame("Frame", "Zed_ArenaOptionsFrame", UIParent, "UIDropDownMenuTemplate")
local menuFrame = Zed_ArenaOptionsFrame

-- Or make the menu appear at the frame:

local function ShowFrameMenu(self)
local menu = frame_menu[frame] or Zed_ArenaFrames:CreateMenu(self, "Options")
EasyMenu(Zed_ArenaFrames.menu, menuFrame, self, 0 , 0, "MENU");
end 

local function ShowArenaMenu(self)
local frame = "ArenaEnemyFrames"
local menu = frame_menu[frame] or Zed_ArenaFrames:CreateMenu(self,"Arena Frames")
EasyMenu(Zed_ArenaFrames.menu, menuFrame, "cursor", 0 , 0, "MENU");
end 

local function UpdateStatusBarColor(statusbar, unit)
if Zed_ArenaFramesDB.classcolor == false then return end 
	local _, class, c
	if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
			_, class = UnitClass(unit)
			c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			statusbar:SetStatusBarColor(c.r+0.1, c.g+0.1, c.b+0.1) 
	end
end
function Zed_ArenaFrames:ClassColorHealth(boolean)
if boolean == true then 
	local throttle = 1
	for i=1,3 do 
		local frame = _G["ArenaEnemyFrame"..i]
		local timer = 0 
		frame:SetScript("OnUpdate", function(self, elapsed)
		timer = timer + elapsed 
		if timer < throttle then return end 
		timer = 0 
		UpdateStatusBarColor(self.healthbar, self.unit)


		end)
	
	end 

hooksecurefunc("HealthBar_OnValueChanged", function(self)
 if self.unit and self.unit:match("arena%d") then UpdateStatusBarColor(self, self.unit) end 
end)	
	
	
else 

for i=1,3 do 
		local frame = _G["ArenaEnemyFrame"..i]
		local timer = 0 
		frame:SetScript("OnUpdate",nil)
		
end 
end 

end 
local TP_texture = "interface\\AddOns\\Zed_ArenaFrames\\TP_BarTexture"

local function GetFrameBorder(frame,size)
frame.border = CreateFrame("Frame", nil,frame)
frame.border:SetBackdrop({
 bgFile=nil,	
 edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
 tile=true,
 tileSize=5,
 edgeSize= size,	
})
frame.border:SetBackdropColor(0,0,0)
frame.border:SetBackdropBorderColor(0,0,0)
frame.border:SetAlpha(1)
frame.border:SetAllPoints(frame)
frame.border:Show()
return frame.border
end




function Zed_ArenaFrames:ADDON_LOADED(arg)
if not arg == self:GetName() then  return end 
self:UnregisterEvent("ADDON_LOADED")
self.DB = Zed_ArenaFramesDB or self:LoadDefaults()

local savedvariable = self.DB
if not savedvariable then Zed_ArenaFrames:LoadDefaults() end 
if savedvariable then 
for frame, options in pairs(self.DB.UnitFrames) do 
frame_ref = _G[frame] 

 
	--  Update database scale 
	frame_ref:SetScale(options.scale or 1)
	frame_ref:SetAttribute("scale",options.scale or 1)
end 
	if savedvariable.UnitFrames["ArenaEnemyFrame1"].position then 
	local p1, _, p2, x, y = unpack(savedvariable.UnitFrames["ArenaEnemyFrame1"].position)
	local arena1 = ArenaEnemyFrame1
	arena1:ClearAllPoints()
	arena1:SetPoint(p1, UIParent, p2, x, y)
	end 
end 

local commands = {
[""] = function() ShowArenaMenu(ArenaEnemyFrame1) end,
["unlock"] = function() EnableDragAndScaling(ArenaEnemyFrame1) ShowArenaMenu(ArenaEnemyFrame1)	end ,
["options"] =  function() ShowArenaMenu(ArenaEnemyFrame1) end ,
["option"] =  function() ShowArenaMenu(ArenaEnemyFrame1) end ,
["opt"] =  function() ShowArenaMenu(ArenaEnemyFrame1) end ,
--["lock"] = DisableDragAndScaling(ArenaEnemyFrame1),
}


local function ZAF_SlashCMD(cmd)
local cmd = strtrim(cmd)
if commands[cmd] then 
	commands[strtrim(cmd)]()

end 
end 

SlashCmdList["AEF"] = ZAF_SlashCMD

SLASH_AEF1 = "/ZAF"
SLASH_AEF2 = "/zaf"

self.CD:CreateBars()
self:InitializeInstantCastIcons()

Zed_ArenaFrames:InitializeDebuffs()
Zed_ArenaFrames:UpdateDebuffFrames()
Zed_ArenaFrames:InitHighlight()
Zed_ArenaFrames:InitFocusHighlight()
Zed_ArenaFrames:ClassColorHealth(self.DB.classcolor )
Zed_ArenaFrames:AddFontOptions()
Zed_ArenaFrames:AddMenuOption({text="Reset settings (reloads UI)", func=function() self.LoadDefaults() ReloadUI() end	})
end 

Zed_ArenaFrames.LoadOnInit = {}
function Zed_ArenaFrames:OnLoad(...)
for i=1,select("#",...) do 
local method = select(i,...)
self.LoadOnInit[method] = true
end 
end 

function Zed_ArenaFrames:PLAYER_ENTERING_WORLD()


end 
local eventHandler = function(self,event,...)
if self[event] then 
self[event](self,...)
end 
end

Zed_ArenaFrames:RegisterEvent("PLAYER_ENTERING_WORLD")
Zed_ArenaFrames:RegisterEvent("ADDON_LOADED")
Zed_ArenaFrames:SetScript("OnEvent", eventHandler)
do 
local timer = 0 
local throttle = 0.2
Zed_ArenaFrames:SetScript("OnUpdate", function(self, elapsed)
timer = timer + elapsed 
if timer < throttle then return end 
CombatLogClearEntries()

end)
end



function Zed_ArenaFrames:ShowArenaFrame()
SetCVar("showArenaEnemyFrames", 1)
ArenaEnemyFrames:Show()
for i=1,5 do 
local frame = _G["ArenaEnemyFrame"..i]
local petframe = _G["ArenaEnemyFrame"..i.."PetFrame"]


frame:Show()
frame.classPortrait:Show()
petframe:Show()
petframe.portrait:Show()


end 

end 
function Zed_ArenaFrames:HideArenaFrame()
ArenaEnemyFrames:Hide()
for i=1,5 do 
local frame = _G["ArenaEnemyFrame"..i]
local petframe = _G["ArenaEnemyFrame"..i.."PetFrame"]
local castbar = _G["ArenaEnemyFrame"..i.."CastingBar"]
frame:Hide()
petframe:Hide()


end 
end 

local function GetFontOption(font)
return {	text = tostring(font),
			func = function(...)Zed_ArenaFramesDB.NameFont = font Zed_ArenaFrames:SetNameFont(font) end,
			checked = function() return (Zed_ArenaFramesDB.NameFont  == font or nil)  end ,
			keepShownOnClick = 1,
	}
end 

function Zed_ArenaFrames:SetNameFont(font)
for i=1,5 do 
local frame = _G["ArenaEnemyFrame"..i]
local name = _G["ArenaEnemyFrame"..i].name 
local fontName, fontHeight, fontFlags = name:GetFont()
name:SetFont(fontName, font)
end 
end 

local function populateFontOptions()
local t = {}
for i=4,16,2 do 
tinsert(t, GetFontOption(i))
end 
return t 
end 

function Zed_ArenaFrames:AddFontOptions()
Zed_ArenaFramesDB.NameFont  = Zed_ArenaFramesDB.NameFont or select(2,ArenaEnemyFrame1.name:GetFont())
local options = { text="Arena Name Size", hasArrow=true, menuList = populateFontOptions() }
self:AddMenuOption(options)

Zed_ArenaFrames:SetNameFont(Zed_ArenaFramesDB.NameFont)
end 

local HIGHLIGHT_COLOR = {0.8,0.8,0.1, }

local PlayerTarget_Frame={}

for i=1,5 do 
local frame = _G["ArenaEnemyFrame"..i]
PlayerTarget_Frame["arena"..i] = frame
end

function Zed_ArenaFrames:InitHighlight()
Zed_ArenaFrames.Highlight = {}
Zed_ArenaFrames.Highlight.frame = CreateFrame("Frame",nil, ArenaEnemyFrames)
local highlight = Zed_ArenaFrames.Highlight.frame
highlight:SetSize(ArenaEnemyFrame1:GetSize())
highlight:SetScale(ArenaEnemyFrame1:GetScale())
highlight:SetFrameStrata("LOW")
highlight:SetAlpha(0.2)
highlight.texture = highlight:CreateTexture()
highlight.texture:SetTexture(unpack(HIGHLIGHT_COLOR))
highlight.texture:SetAllPoints(highlight)
highlight.texture:SetDrawLayer("BACKGROUND")
highlight:SetScript("OnEvent", function(self)
for i=1,5 do
local arenaUnit= "arena"..i
if UnitIsUnit("target", arenaUnit) then 
self:SetPoint("CENTER", PlayerTarget_Frame[arenaUnit])
self:Show()
break 
end 
self:Hide()
end 
end)
highlight:SetScript("OnShow", function(self)
for i=1,5 do
local arenaUnit= "arena"..i
if UnitIsUnit("target", arenaUnit) then 
self:SetPoint("CENTER", PlayerTarget_Frame[arenaUnit])
break 
end 
self:Hide()
end 
end)
highlight:Hide()

Zed_ArenaFramesDB.Highlight  = Zed_ArenaFramesDB.Highlight or false 
local options = { text="Arena Target Highlight", 
func = function(...) local bool = select(4,...) Zed_ArenaFramesDB.Highlight = bool Zed_ArenaFrames:ToggleHighlight(bool) end,
 keepShownOnClick = 1,
checked = function() return (Zed_ArenaFramesDB.Highlight  == true or nil)  end ,
}
self:AddMenuOption(options)
self:ToggleHighlight() 
end 


function Zed_ArenaFrames:ToggleHighlight(bool) 
local bool = bool or Zed_ArenaFramesDB.Highlight
local highlight = Zed_ArenaFrames.Highlight.frame
if  bool == true then 
highlight:Show()
highlight:RegisterEvent("PLAYER_TARGET_CHANGED")
else 
highlight:UnregisterEvent("PLAYER_TARGET_CHANGED")
highlight:Hide()
end 
end 


local FOCUS_HIGHLIGHT_COLOR = {0.8,0.1,0.1, }

function Zed_ArenaFrames:InitFocusHighlight()
Zed_ArenaFrames.FocusHighlight = {}
Zed_ArenaFrames.FocusHighlight.frame = CreateFrame("Frame",nil, ArenaEnemyFrames)
local focus_highlight = Zed_ArenaFrames.FocusHighlight.frame
focus_highlight:SetSize(ArenaEnemyFrame1:GetSize())
focus_highlight:SetScale(ArenaEnemyFrame1:GetScale())
focus_highlight:SetFrameStrata("LOW")
focus_highlight:SetAlpha(0.2)
focus_highlight.texture = focus_highlight:CreateTexture()
focus_highlight.texture:SetTexture(unpack(FOCUS_HIGHLIGHT_COLOR))
focus_highlight.texture:SetAllPoints(focus_highlight)
focus_highlight.texture:SetDrawLayer("BACKGROUND")
focus_highlight:SetScript("OnEvent", function(self)
for i=1,5 do
local arenaUnit= "arena"..i
if UnitIsUnit("focus", arenaUnit) then 
self:SetPoint("CENTER", PlayerTarget_Frame[arenaUnit])
break 
end 
self:Hide()
end 
end)
focus_highlight:SetScript("OnShow", function(self)
for i=1,5 do
local arenaUnit= "arena"..i
if UnitIsUnit("focus", arenaUnit) then 
self:SetPoint("CENTER", PlayerTarget_Frame[arenaUnit])
self:Show()
break 
end 
self:Hide()
end 
end)
focus_highlight:Hide()
Zed_ArenaFramesDB.FocusHighlight  = Zed_ArenaFramesDB.FocusHighlight or false 
local options = { text="Arena Focus Highlight", 
func = function(...) local bool = select(4,...) Zed_ArenaFramesDB.FocusHighlight = bool Zed_ArenaFrames:ToggleFocusHighlight(bool) end,
 keepShownOnClick = 1,
checked = function() return (Zed_ArenaFramesDB.FocusHighlight  == true or nil)  end ,
}
self:AddMenuOption(options)
self:ToggleFocusHighlight() 
end 


function Zed_ArenaFrames:ToggleFocusHighlight(bool) 
local bool = bool or Zed_ArenaFramesDB.FocusHighlight
local highlight = Zed_ArenaFrames.FocusHighlight.frame
if  bool == true then 
highlight:Show()
highlight:RegisterEvent("PLAYER_FOCUS_CHANGED")
else 
highlight:UnregisterEvent("PLAYER_FOCUS_CHANGED")
highlight:Hide()
end 
end 

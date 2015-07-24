




function Zed_ArenaFrames:DebuffAnchorTemplate(debuffFrame)
local displayIcon = CreateFrame("Frame", nil, UIParent)
displayIcon:SetAllPoints(debuffFrame)
displayIcon:SetSize(debuffFrame:GetSize())
displayIcon.texture = displayIcon:CreateTexture()
displayIcon.texture:SetAllPoints(displayIcon)
displayIcon.texture:SetTexture(select(3,GetSpellInfo(48125)))
displayIcon:Hide()
displayIcon:SetScript("OnShow", function(self)
displayIcon:SetSize(debuffFrame:GetSize())
end)

return displayIcon
end 

function Zed_ArenaFrames:ShowDebuffIconDisplay()
for debuffIcon, icon in pairs(self.Debuffs.IconDisplay) do 
icon:Show()
end 
end 
function Zed_ArenaFrames:HideDebuffIconDisplay()
for debuffIcon, icon in pairs(self.Debuffs.IconDisplay) do 
icon:Hide()
end 
end 

local function debuff_option_toggle(name, boolean)
return {	text = name,
			func = function(...)Zed_ArenaFramesDB.Debuffs.Enabled = boolean end,
			checked = function() if Zed_ArenaFramesDB.Debuffs.Enabled  == boolean then return true end end ,
			 keepShownOnClick = 1,
	}
end 
local function filterOption_player()
return {	text = "Show player debuffs only",
			func = function(...)Zed_ArenaFramesDB.Debuffs.filter="PLAYER" end,
			checked = function() if Zed_ArenaFramesDB.Debuffs.filter == "PLAYER" then return true end end ,
			 keepShownOnClick = 1,
	}
end 

local function filterOption_none()
return {	text = "Show all debuffs",
			func = function(...)Zed_ArenaFramesDB.Debuffs.filter="none" end,
			checked = function() if Zed_ArenaFramesDB.Debuffs.filter == "none" then return true end end ,
			keepShownOnClick = 1,
	}
end 

local function debuff_option_size(size)
return {	text = tostring(size),
			func = function(...) Zed_ArenaFramesDB.Debuffs.db_size=size	Zed_ArenaFrames:UpdateDebuffFrames() end,
			checked = function() if Zed_ArenaFramesDB.Debuffs.db_size == size then return true end end ,
			keepShownOnClick = 1,
	}
end 


local function debuff_option_maxdebuffs(debuffs)
return {	text = tostring(debuffs),
			func = function(...) Zed_ArenaFramesDB.Debuffs.maxDebuffs=debuffs	Zed_ArenaFrames:UpdateDebuffFrames() end,
			checked = function() if Zed_ArenaFramesDB.Debuffs.maxDebuffs == debuffs then return true end end ,
			keepShownOnClick = 1,
	}
end 
local function debuff_option_perrow(debuffs)
return {	text = tostring(debuffs),
			func = function(...) if debuffs > Zed_ArenaFramesDB.Debuffs.maxDebuffs then print("Debuffs count too low!") return end Zed_ArenaFramesDB.Debuffs.db_per_row=debuffs	Zed_ArenaFrames:UpdateDebuffFrames() end,
			checked = function() if Zed_ArenaFramesDB.Debuffs.db_per_row == debuffs then return true end end ,
			keepShownOnClick = 1,
	}
end 

local function debuff_option_setpoint(axis,increment, method)
return {	text = method,
			func = function(...) 
			local old_value = Zed_ArenaFramesDB.Debuffs[axis]
			local new_value = old_value + increment 
			Zed_ArenaFramesDB.Debuffs[axis]= new_value 
			Zed_ArenaFrames:UpdateDebuffFrames() end,
			keepShownOnClick = 1,
	}
end 

local function RefreshDebuffs(frame, unit, numDebuffs, suffix, filter) -- copied blizzard function and modified it little bit 
	local frameName = frame:GetName();

	frame.hasDispellable = nil;

	numDebuffs = numDebuffs or MAX_PARTY_DEBUFFS;
	suffix = suffix or "Debuff";

	local unitStatus, statusColor;
	local debuffTotal = 0;
	local name, rank, icon, count, debuffType, duration, expirationTime, caster;
	local isEnemy = UnitCanAttack("player", unit);	
	for i=1, numDebuffs do
		if ( unit == "party"..i ) then
			unitStatus = _G[frameName.."Status"];
		end


		name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff(unit, i, filter);

		local debuffName = frameName..suffix..i;
		if ( icon and ( SHOW_CASTABLE_DEBUFFS == "0" or not isEnemy or caster == "player" ) ) then
			-- if we have an icon to show then proceed with setting up the aura

			-- set the icon
			local debuffIcon = _G[debuffName.."Icon"];
			debuffIcon:SetTexture(icon);

			-- setup the border
			local debuffBorder = _G[debuffName.."Border"];
			local debuffColor = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
			debuffBorder:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b);

			-- record interesting data for the aura button
			statusColor = debuffColor;
			frame.hasDispellable = 1;
			debuffTotal = debuffTotal + 1;

			-- setup the cooldown
			local coolDown = _G[debuffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_SetTimer(coolDown, expirationTime - duration, duration, 1);
			end

			-- show the aura
			_G[debuffName]:Show();
		else
			-- no icon, hide the aura
			_G[debuffName]:Hide();
		end
	end

	frame.debuffTotal = debuffTotal;
	-- Reset unitStatus overlay graphic timer
	if ( frame.numDebuffs and debuffTotal >= frame.numDebuffs ) then
		frame.debuffCountdown = 30;
	end
	if ( unitStatus and statusColor ) then
		unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b);
	end
end

function Zed_ArenaFrames:InitializeDebuffs()
Zed_ArenaFrames.Debuffs = {}
Zed_ArenaFrames.Debuffs.IconDisplay = {}
Zed_ArenaFramesDB.Debuffs.maxDebuffs = Zed_ArenaFramesDB.Debuffs.maxDebuffs or 10 
Zed_ArenaFramesDB.Debuffs.db_per_row = Zed_ArenaFramesDB.Debuffs.db_per_row or 5 
Zed_ArenaFramesDB.Debuffs.db_size = Zed_ArenaFramesDB.Debuffs.db_size or 15 
Zed_ArenaFramesDB.Debuffs.X = Zed_ArenaFramesDB.Debuffs.X  or 0 
Zed_ArenaFramesDB.Debuffs.Y= Zed_ArenaFramesDB.Debuffs.Y or -15
Zed_ArenaFramesDB.Debuffs.Enabled = Zed_ArenaFramesDB.Debuffs.Enabled or true 

local size = Zed_ArenaFramesDB.Debuffs.db_size
local maxDebuffs = Zed_ArenaFramesDB.Debuffs.maxDebuffs
local debuffs_per_row = 5
for a=1,5 do
local frame = _G["ArenaEnemyFrame"..a]
for i=1,maxDebuffs do

local DebuffFrameName = "ArenaEnemyFrame"..a.."Debuff"
local DebuffFrame_name_i = "ArenaEnemyFrame"..a.."Debuff"..i 
local debuffIcon = CreateFrame("Frame",DebuffFrame_name_i,frame)		--"TargetBuffFrameTemplate")
debuffIcon:EnableMouse(false)
debuffIcon:SetSize(size,size)
self.Debuffs.IconDisplay[debuffIcon] = self:DebuffAnchorTemplate(debuffIcon)
if i == 1 then

debuffIcon:SetPoint("BOTTOMLEFT",0,-15)
else
debuffIcon:SetPoint("LEFT",_G[DebuffFrameName..(i-1)],"LEFT",-debuffIcon:GetWidth(),0)
end
if i  > 1 and (i -1)%debuffs_per_row == 0 then 
local bar_anchor = i-debuffs_per_row 
debuffIcon:ClearAllPoints()
debuffIcon:SetPoint("BOTTOM", _G[DebuffFrameName..(bar_anchor)], "BOTTOM", 0, -debuffIcon:GetHeight())

end 
-- frameName..suffix..i is blizzard style 
--
_G[DebuffFrame_name_i.."Icon"] = debuffIcon:CreateTexture() 
_G[DebuffFrame_name_i.."Icon"]:SetAllPoints(debuffIcon)

_G[DebuffFrame_name_i.."Border"]= debuffIcon:CreateTexture() 
_G[DebuffFrame_name_i.."Border"]:SetAllPoints(debuffIcon)

_G[DebuffFrame_name_i.."Cooldown"]= CreateFrame("Cooldown", nil,debuffIcon)
_G[DebuffFrame_name_i.."Cooldown"]:SetAllPoints(debuffIcon)
_G[DebuffFrame_name_i.."Cooldown"]:SetReverse(true)

end
-- update the auras 
frame:HookScript("OnEvent",function(self,event,arg1)
if arg1 == self.unit then
	Zed_ArenaFrames:UpdateDebuffs(frame,arg1,maxDebuffs,"Debuff")
	-- proxy it for filtering 
end
end)

--------------------------------
frame:HookScript("OnShow", function(self)
if Zed_ArenaFramesDB.Debuffs.Enabled == true then 
self:RegisterEvent("UNIT_AURA")
end 
end)
frame:HookScript("OnHide", function(self)
if Zed_ArenaFramesDB.Debuffs.Enabled == true then 
self:UnregisterEvent("UNIT_AURA")
end 
end)

end

local debuff_options = { text="Arena Debuffs",  hasArrow = true, menuList = {	
	debuff_option_toggle("Enabled", true),
	debuff_option_toggle("Disabled", false),
	{text ="Filter", hasArrow = true, menuList = {
	filterOption_player(),
	filterOption_none(),	},},
	
	{text ="Debuffs size", hasArrow = true, menuList = {
	debuff_option_size(15),
	debuff_option_size(20),
	debuff_option_size(25),
	debuff_option_size(30),
	
	},},
	{text ="Max debuff count", hasArrow = true, menuList = {
	debuff_option_maxdebuffs(5),
	debuff_option_maxdebuffs(6),
	debuff_option_maxdebuffs(7),
	debuff_option_maxdebuffs(8),
	debuff_option_maxdebuffs(9),
	debuff_option_maxdebuffs(10),
	debuff_option_maxdebuffs(11),
	debuff_option_maxdebuffs(12),
	debuff_option_maxdebuffs(13),
	debuff_option_maxdebuffs(14),
	debuff_option_maxdebuffs(15),
	},},
	{text ="Debuffs per row", hasArrow = true, menuList = {
	debuff_option_perrow(1),
	debuff_option_perrow(2),
	debuff_option_perrow(3),
	debuff_option_perrow(4),
	debuff_option_perrow(5),
	debuff_option_perrow(6),
	debuff_option_perrow(7),
	debuff_option_perrow(8),
	debuff_option_perrow(9),
	debuff_option_perrow(10),
	debuff_option_perrow(11),
	debuff_option_perrow(12),
	debuff_option_perrow(13),
	debuff_option_perrow(14),
	debuff_option_perrow(15),
	},},
		{text ="Debuff Positioning", hasArrow = true, menuList = {
		debuff_option_setpoint("X",5, "Move to right"),
		debuff_option_setpoint("X",-5, "Move to left"),
		debuff_option_setpoint("Y",5, "Move up"),
		debuff_option_setpoint("Y",-5, "Move down"),
		},},
},
}

Zed_ArenaFrames:AddMenuOption(debuff_options)
hooksecurefunc("UIDropDownMenu_Initialize", function(...)local frame = ...
 
local inInstance, instanceType = IsInInstance()
if instanceType=="arena" then return end 
if frame:GetName():match("Zed_Arena")  then
self:ShowArenaFrame()
if self.DB.Debuffs.Enabled == true then 
self:ShowDebuffIconDisplay() 
end 
end 
end )
hooksecurefunc("UIDropDownMenu_OnHide", function(menu) 
local inInstance, instanceType = IsInInstance()
if instanceType=="arena" or menu:GetName():match("2") then return end 
self:HideDebuffIconDisplay() 
self:HideArenaFrame()
end )
end 

local function arenaDebuffTemplate(name,frame,num)
local name_i = name..num
local debuffIcon = CreateFrame("Frame",name_i,frame)

_G[name_i.."Icon"] = debuffIcon:CreateTexture() 
_G[name_i.."Icon"]:SetAllPoints(debuffIcon)

_G[name_i.."Border"]= debuffIcon:CreateTexture() 
_G[name_i.."Border"]:SetAllPoints(debuffIcon)

_G[name_i.."Cooldown"]= CreateFrame("Cooldown", nil,debuffIcon)
_G[name_i.."Cooldown"]:SetAllPoints(debuffIcon)
_G[name_i.."Cooldown"]:SetReverse(true)
return debuffIcon
end 

function Zed_ArenaFrames:UpdateDebuffFrames()
local maxDebuffs = Zed_ArenaFramesDB.Debuffs.maxDebuffs
local debuffs_per_row = Zed_ArenaFramesDB.Debuffs.db_per_row 
local size = Zed_ArenaFramesDB.Debuffs.db_size 
local x = Zed_ArenaFramesDB.Debuffs.X 
local y = Zed_ArenaFramesDB.Debuffs.Y
for a=1,5 do
local frame = _G["ArenaEnemyFrame"..a]
for i=1,maxDebuffs do

local DebuffFrameName = "ArenaEnemyFrame"..a.."Debuff"
local DebuffFrame_name_i = "ArenaEnemyFrame"..a.."Debuff"..i 
local debuffIcon = _G[DebuffFrame_name_i] or arenaDebuffTemplate(DebuffFrameName,frame,i)
debuffIcon:EnableMouse(false)
debuffIcon:SetSize(size,size)
debuffIcon:ClearAllPoints()
if i == 1 then
debuffIcon:SetPoint("BOTTOMLEFT",x,y)
else
debuffIcon:SetPoint("LEFT",_G[DebuffFrameName..(i-1)],"LEFT",-debuffIcon:GetWidth(),0)
end
if i  > 1 and (i -1)%debuffs_per_row == 0 and debuffs_per_row~=maxDebuffs then 
local bar_anchor = i-debuffs_per_row 
debuffIcon:ClearAllPoints()
debuffIcon:SetPoint("BOTTOM", _G[DebuffFrameName..(bar_anchor)], "BOTTOM", 0, -debuffIcon:GetHeight())

end 

end 

end 


end 
--Zed_ArenaFrames:OnLoad("InitializeDebuffs","UpdateDebuffFrames")

 
function Zed_ArenaFrames:UpdateDebuffs(frame,unit, maxDebuffs, suffix)
local filterOpt = Zed_ArenaFramesDB.Debuffs.filter 
local maxDebuffs = Zed_ArenaFramesDB.Debuffs.maxDebuffs
RefreshDebuffs(frame,unit, maxDebuffs, suffixfilter, filterOpt)
end 

function Zed_ArenaFrames:EnableDebuffs()
Zed_ArenaFramesDB.Debuffs.Enabled = true 
for a=1,5 do
local frame = _G["ArenaEnemyFrame"..a]
if frame:IsVisible() then 
frame:RegisterEvent("UNIT_AURA")
end 
end 
end 

function Zed_ArenaFrames:DisableDebuffs()
Zed_ArenaFramesDB.Debuffs.Enabled = false  
for a=1,5 do
local frame = _G["ArenaEnemyFrame"..a]
frame:UnregisterEvent("UNIT_AURA")
end 
end 

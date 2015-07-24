
local UnitGUID = UnitGUID 


 
local function FadeInSeconds(frame,time)
frame.timeout = time 
frame:SetScript("OnUpdate",function(self,elapsed)
frame.timeout = frame.timeout - elapsed 
if frame.timeout <= 0 then 
self:Hide()
end 

end)
end 




function Zed_ArenaFrames:CreateInstantCastIcon()

local ICON_SIZE = Zed_ArenaFramesDB.instant.size

-- ICON 
local icon = CreateFrame("Frame")


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
icon.cd:SetAlpha(0.65)
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

icon:SetScript("OnShow", function(icon)
FadeInSeconds(icon, 3)
end)

return icon
end

local function OnInstantCast(self,event,...)
-- INSTANT CAST ICON UPDATE 
local selfUnit = self.unit or self:GetParent().unit 	
local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9 = ...
if ( event=="COMBAT_LOG_EVENT_UNFILTERED" and arg2== "SPELL_CAST_SUCCESS" )
	then 
		
		local spellID = arg9
		local name,_,icon = GetSpellInfo(spellID)
			if UnitGUID(selfUnit)==arg3	
			then 
			self.texture:SetTexture(icon)
			self:Show()
			--FadeInSeconds(self,ABILITY_SHOWN_DUR)
			end

end 

end
function Zed_ArenaFrames:InitializeInstantCastIcons()
for i=1,3 do
local arenaFrame = _G["ArenaEnemyFrame"..i]
local castbar = _G["ArenaEnemyFrame"..i.."CastingBar"]
local icon = Zed_ArenaFrames:CreateInstantCastIcon()
icon:SetParent(arenaFrame)
icon.unit = arenaFrame.unit 
local size = castbar:GetHeight()
icon:SetSize(size,size)
icon:SetPoint("RIGHT", castbar, "RIGHT", icon:GetHeight(),0)
icon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
icon:SetScript("OnEvent", OnInstantCast)


end 
end 





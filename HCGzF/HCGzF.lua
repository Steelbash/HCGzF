local frame = CreateFrame('FRAME', 'HCGzFFrame');
local popupFrame = nil

local HC_CLASS_COLORS = {
    ["WARRIOR"] = "ffc79c6e",
    ["MAGE"]    = "ff69ccf0",
    ["ROGUE"]   = "fffff569",
    ["DRUID"]   = "ffff7d0a",
    ["HUNTER"]  = "ffabd473",
    ["SHAMAN"]  = "ff0070de",
    ["PRIEST"]  = "ffffffff",
    ["WARLOCK"] = "ff9482c9",
    ["PALADIN"] = "fff58cba",
  }
  
local whoFlag = nil
local whoPlayer = nil
local whoEnemy = nil

local isPopupFrameDragging = false


local HC_RACE_TEXTURES = {
   ["Human"] = "interface/characterframe/temporaryportrait-male-human.blp",
   ["High Elf"] = "interface/characterframe/temporaryportrait-male-bloodelf.blp",
   ["Dwarf"] = "interface/characterframe/temporaryportrait-male-dwarf.blp",
   ["Gnome"] = "interface/characterframe/temporaryportrait-male-gnome.blp",
   ["Night Elf"] = "interface/characterframe/temporaryportrait-male-nightelf.blp",
   ["Orc"] = "interface/characterframe/temporaryportrait-male-orc.blp",
   ["Undead"] = "interface/characterframe/temporaryportrait-male-scourge.blp",
   ["Tauren"] = "interface/characterframe/temporaryportrait-male-tauren.blp",
   ["Troll"] = "interface/characterframe/temporaryportrait-male-troll.blp",
   ["Goblin"] = "interface/characterframe/temporaryportrait-male-goblin.blp",
}

local CLASS_BUTTONS = {
	["Hunter"] = {
		0, -- [1]
		0.25, -- [2]
		0.25, -- [3]
		0.5, -- [4]
	},
	["Warrior"] = {
		0, -- [1]
		0.25, -- [2]
		0, -- [3]
		0.25, -- [4]
	},
	["Rogue"] = {
		0.49609375, -- [1]
		0.7421875, -- [2]
		0, -- [3]
		0.25, -- [4]
	},
	["Mage"] = {
		0.25, -- [1]
		0.49609375, -- [2]
		0, -- [3]
		0.25, -- [4]
	},
	["Priest"] = {
		0.49609375, -- [1]
		0.7421875, -- [2]
		0.25, -- [3]
		0.5, -- [4]
	},
	["Warlock"] = {
		0.7421875, -- [1]
		0.98828125, -- [2]
		0.25, -- [3]
		0.5, -- [4]
	},
	["Druid"] = {
		0.7421875, -- [1]
		0.98828125, -- [2]
		0, -- [3]
		0.25, -- [4]
	},
	["Shaman"] = {
		0.25, -- [1]
		0.49609375, -- [2]
		0.25, -- [3]
		0.5, -- [4]
	},
	["Paladin"] = {
		0, -- [1]
		0.25, -- [2]
		0.5, -- [3]
		0.75, -- [4]
	},
}

function HCPlayerInfo(playerName)
    local total = GetNumGuildMembers()
    for i=1,total do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, 
              achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(i)
        if name == playerName then
            return class, zone
        end
    end
    print("Debug[player]: not found player "..playerName)
end

function HCClassColor(class)
    local clColor = nil
    if class ~= nil then
        clColor = HC_CLASS_COLORS[string.upper(class)]
    end
    if clColor == nil then
        clColor = "ffff00ff"
    end
    return clColor
end

function HCGratzPlayer(gzPlayer, gzLevel, gzRace, gzClass, gzGuild, gzZone)
	popupFrame.RaceFrame.RaceIcon:SetTexture(HC_RACE_TEXTURES[gzRace])
	popupFrame.RaceFrame.RaceIcon:SetDesaturated(nil)
	
	popupFrame.ClassFrame.ClassIcon:SetTexCoord(unpack(CLASS_BUTTONS[gzClass]))
	popupFrame.ClassFrame.ClassIcon:SetDesaturated(nil)
	
	popupFrame.GzText:SetText("Congratulations!");
	popupFrame.GzText:SetTextColor(0, 1, 0, 1)
	
	popupFrame.NameText:SetText("|c"..HCClassColor(gzClass)..gzPlayer);
	if gzGuild ~= nil and gzGuild ~= "" then
	    popupFrame.GuildText:SetText("<"..gzGuild..">");
	else
	    popupFrame.GuildText:SetText("");
	end
	popupFrame.ZoneText:SetText(gzZone);
	popupFrame.LevelText:SetTextColor(1, 1, 0, 1)
	popupFrame.LevelText:SetText(gzLevel.." lvl");
	

	popupFrame:Show();
    PlaySound("LEVELUPSOUND")
end

function HCRipPlayer(ripPlayer, ripLevel, ripRace, ripClass, ripGuild, ripZone)
    popupFrame.RaceFrame.RaceIcon:SetTexture(HC_RACE_TEXTURES[ripRace])
    popupFrame.RaceFrame.RaceIcon:SetDesaturated(1)
    
	popupFrame.ClassFrame.ClassIcon:SetTexCoord(unpack(CLASS_BUTTONS[ripClass]))
	popupFrame.ClassFrame.ClassIcon:SetDesaturated(1)
	
	popupFrame.GzText:SetText("Tragedy...");
	popupFrame.GzText:SetTextColor(1, 0, 0, 1)
	
	popupFrame.NameText:SetText("|c"..HCClassColor(ripClass)..ripPlayer);
	if ripGuild ~= nil and ripGuild ~= "" then
	    popupFrame.GuildText:SetText("<"..ripGuild..">");
	else
	    popupFrame.GuildText:SetText("");
	end
	popupFrame.ZoneText:SetText(ripZone);
	popupFrame.LevelText:SetTextColor(0.8, 0.8, 0.8, 1)
	popupFrame.LevelText:SetText(ripLevel.." lvl");
	
	popupFrame:Show();
    PlaySound("igQuestFailed")
end


frame:SetScript('OnEvent', function()
	this[event]()
end)

frame:SetScript("OnUpdate", function()

     if whoFlag ~= nil then
		 local n = GetNumWhoResults() 
		 if n ~= nil and n ~= 0 then
			FriendsFrame:Hide()
		    for i = 1,n do
				 local name, guild, level, race, class, zone, classFileName = GetWhoInfo(i)
				 if name == whoPlayer then 
					 if guild == GetGuildInfo("player") then
						 if whoFlag == "gratz" then
							HCGratzPlayer(name, level, race, class, guild, zone)
						else
							HCRipPlayer(name, level, race, class, guild, whoEnemy.."\n"..zone)
						end
					end
					whoFlag = nil
					break
				end
			end
		 end
     end
end)

frame:RegisterEvent("CHAT_MSG_SYSTEM")

function frame:CHAT_MSG_SYSTEM()
    local event = event
    local message = arg1
    
    
    if string.find(message, "You are now AFK") ~= nil then
        afkFlag = true
    end
    
    if string.find(message, "You are no longer AFK") ~= nil then
        afkFlag = false
    end

	local _, _, gzPlayer, gzLevel = string.find(message, "(%a+) has reached level (%d+)")
	if gzPlayer == nil then
		_, _, gzPlayer, gzLevel = string.find(message, "(%a+) has transcended death and reached level (%d+)")
	end
	if gzPlayer ~= nil and gzPlayer ~= UnitName("player") then
		whoFlag = "gratz"
		whoPlayer = gzPlayer
		SendWho('n-"'..gzPlayer..'"')
	end
	
	local _, _, ripPlayer, ripEnemy, ripLevel = string.find(message, "(%a+) has fallen to (.+ %(level %d+%)) at level (%d+)")
	if ripPlayer == nil then
		_, _, ripPlayer, ripEnemy, ripLevel = string.find(message, "(%a+) has fallen in PvP to (%a+) at level (%d+)")
		if ripEnemy ~= nil then
			ripEnemy = ripEnemy.." (PvP)"
		end
	end
	if ripPlayer == nil then
		_, _, ripPlayer, ripLevel = string.find(message, "(%a+) died of natural causes at level (%d+)")
		if ripPlayer ~= nil then
			ripEnemy = "Natural causes (drowned, poisoned)"
		end
	end
	
	
	if ripPlayer ~= nil and ripPlayer ~= UnitName("player") then
		whoEnemy = ripEnemy
		whoFlag = "rip"
		whoPlayer = ripPlayer
		SendWho('n-"'..ripPlayer..'"')
	end
end


function HCPopupMouseDown()
    HC_PopupFrame:Hide()
end


function frame:ADDON_LOADED()
    if popupFrame == nil then
		popupFrame = CreateFrame('Frame', 'HCGZPopupFrame')
		popupFrame:SetPoint('TOPLEFT', 'UIParent', 'TOPLEFT', 20, -40)
		popupFrame:SetWidth(300)  
		popupFrame:SetHeight(130)
		popupFrame:SetFrameStrata('BACKGROUND')
		popupFrame:SetMovable(true)
		popupFrame:EnableMouse(true)
		popupFrame:SetUserPlaced(true)
		popupFrame:SetBackdrop({
				bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], tile = true, tileSize = 32,
				edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], edgeSize = 20,
				insets = {left=5, right=6, top=6, bottom=5},
		})
		
		-- Race Frame
		
		local raceFrame = CreateFrame("Frame", nil, popupFrame)
		raceFrame:SetPoint('TOPLEFT', 60, -55)
		raceFrame:SetFrameStrata("LOW")
		raceFrame:SetWidth(80)
		raceFrame:SetHeight(80)
		popupFrame.RaceFrame = raceFrame
		
		
		local raceIcon = raceFrame:CreateTexture(nil,"BORDER")
		raceIcon:SetTexture(HC_RACE_TEXTURES["Orc"])
		raceIcon:SetWidth(65)
		raceIcon:SetHeight(65)
		raceIcon:SetPoint('CENTER', raceFrame, "TOPLEFT")
		raceFrame.RaceIcon = raceIcon
		
		local rfIcon = raceFrame:CreateTexture(nil,"ARTWORK")
		rfIcon:SetTexture("interface\\addons\\HCGzF\\playerframe")
		rfIcon:SetWidth(80)
		rfIcon:SetHeight(80)
		rfIcon:SetTexCoord(0, 0.75, 0, 0.75)
		rfIcon:SetPoint('CENTER', raceFrame, "TOPLEFT")
		raceFrame.RaceFrameIcon = rfIcon
		
		
		-- Class Frame
		
		local classFrame = CreateFrame("Frame", nil, popupFrame)
		classFrame:SetPoint('TOPLEFT', 87, -77)
		classFrame:SetFrameStrata("MEDIUM")
		classFrame:SetWidth(32)
		classFrame:SetHeight(37)
		popupFrame.ClassFrame = classFrame
		
		local classIcon = classFrame:CreateTexture(nil,"ARTWORK")
		classIcon:SetTexture("interface\\addons\\HCGzF\\UI-CLASSES-CIRCLES")
		classIcon:SetTexCoord(unpack(CLASS_BUTTONS["Warrior"]))
		classIcon:SetWidth(18)
		classIcon:SetHeight(18)
		classIcon:SetPoint('CENTER', classFrame, "TOPLEFT", 0, 0)
		classFrame.ClassIcon = classIcon
		
		
		
		local cfIcon = classFrame:CreateTexture(nil,"BORDER")
		cfIcon:SetTexture("interface\\addons\\HCGzF\\playerframe")
		cfIcon:SetWidth(32)
		cfIcon:SetHeight(37)
		cfIcon:SetTexCoord(0.75, 0.9, 0, 0.15)
		cfIcon:SetPoint('CENTER', classFrame, "TOPLEFT", 3, -3)
		classFrame.ClassFrameIcon = cfIcon
		
		
		local gzText = popupFrame:CreateFontString(nil, "OVERLAY")
		gzText:SetPoint("CENTER", popupFrame, "TOP", 50, -30)
		gzText:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
		gzText:SetTextColor(0, 1, 0, 1)
		gzText:SetText("Congratulations!")
		popupFrame.GzText = gzText
		
		local nameText = popupFrame:CreateFontString(nil, "OVERLAY")
		nameText:SetPoint("CENTER", popupFrame, "TOP", 50, -60)
		nameText:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
		nameText:SetText("Hellscream")
		popupFrame.NameText = nameText
		
		local guildText = popupFrame:CreateFontString(nil, "OVERLAY")
		guildText:SetPoint("CENTER", popupFrame, "TOP", 50, -80)
		guildText:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
		guildText:SetText("<Still Alive>")
		guildText:SetTextColor(0.8, 0.8, 0.8, 1)
		popupFrame.GuildText = guildText
		
		local zoneText = popupFrame:CreateFontString(nil, "OVERLAY")
		zoneText:SetPoint("CENTER", popupFrame, "TOP", 50, -110)
		zoneText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
		zoneText:SetTextColor(1, 0.82, 0, 1)
		zoneText:SetText("The Barrens")
		popupFrame.ZoneText = zoneText
		
		
		local levelText = popupFrame:CreateFontString(nil, "OVERLAY")
		levelText:SetPoint("CENTER", popupFrame, "BOTTOMLEFT", 60, 22)
		levelText:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
		levelText:SetTextColor(0.7, 0.7, 0.7, 1)
		levelText:SetText("10 lvl")
		popupFrame.LevelText = levelText
		

		popupFrame:SetScript('OnMouseDown', function()
		    if not IsAltKeyDown() and not IsControlKeyDown() then
			    popupFrame:Hide()
			end
		end)
		
		popupFrame:RegisterForDrag("LeftButton")
		
		popupFrame:SetScript('OnDragStart', function()
			if IsAltKeyDown() and IsControlKeyDown() then
			  popupFrame:StartMoving()
			  isPopupFrameDragging = true
			end
		end)
		
		popupFrame:SetScript('OnDragStop', function()
			if isPopupFrameDragging then
				popupFrame:StopMovingOrSizing()
				isPopupFrameDragging = false
		   end
	   end)
		
		popupFrame:Hide()
	end
end

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript('OnEvent', function()
	this[event]()
end)


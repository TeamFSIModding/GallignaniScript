--
-- BaleCounterGal
-- Specialization for baler to display a bale counter.
--
-- @author  	fcelsa (Team FSI modding)
-- @version 	1.0
-- @date  		05/2016
--
-- 
-- part of original work BaleCounterJD and RopeBreakdown of Benjamin Biot (J&B Modding)
-- 
-- a differenza dello script globale per il conteggio delle balle, fornisce in più NoRopesBalesCount e RopesRefillCount
-- che può essere utilizzato da RopeBreakdown o altri per la gestione dei consumabili (corda, rete o manutenzione)
-- ed aggiunto hud del livello di carico del pickup.
-- 
--
-- inoltre lo script è stato sistemato per lavorare con Baler.lua originale
--


BaleCounterGal = {};

function BaleCounterGal.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Baler, specializations);
end;

function BaleCounterGal:load(xmlFile)
	self.SetBaleCount = SpecializationUtil.callSpecializationsFunction("SetBaleCount");
	
	self.RopesCapacity = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.Ropes#Capacity"), 40);

	--- Hud nuovo per indicazione balle sessione / totali e % corda residua
	self.hudG = {};
	local width, height = getNormalizedScreenValues(333, 30);
	local w, h = getNormalizedScreenValues(0, 214);	
	self.hudG.xPos = 1-width;
	self.hudG.yPos = h;
	self.hudG.hudWidth = width;
	self.hudG.overlay_hud 	= Overlay:new("HUDNHBB", 	Utils.getFilename("hud/hud_block.dds", self.baseDirectory), self.hudG.xPos, self.hudG.yPos, width, height);
	self.hudG.overlay_bar 	= Overlay:new("HUDNHBB", 	Utils.getFilename("hud/hud_barY.dds", self.baseDirectory), self.hudG.xPos, self.hudG.yPos, width, height);

	self.TotalBalesCount = 0;
	self.CurrentBalesCount = 0;
	self.NoRopesBalesCount = 0;
	self.RopesRefillCount = 0;

	self.dirtyFlag = self:getNextDirtyFlag();
	self.isDirty = true;

	-- pickup load add...
	self.isBlocked = false;
	self.blockTimer = 0;
	self.blockMaxTime = 1700;
	self.blockCounter = 0;

	self.hud2 = {};
	local width, height = getNormalizedScreenValues(333, 30);
	local w, h = getNormalizedScreenValues(0, 244);	
	self.hud2.xPos = 1-width;
	self.hud2.yPos = h;
	self.hud2.hudWidth = width;	
	self.hud2.overlay_hud 	= Overlay:new("loadHUD_hud", 	Utils.getFilename("hud/hud_block.dds", self.baseDirectory), self.hud2.xPos, self.hud2.yPos, width, height);
	self.hud2.overlay_bar 	= Overlay:new("loadHUD_bar", 	Utils.getFilename("hud/hud_barY.dds", self.baseDirectory), self.hud2.xPos, self.hud2.yPos, width, height);
	self.loadedMaxLoad = 360;  -- volendo si può impostare nell'xml... getXMLFloat(xmlFile, "vehicle.pickup#maxload") 
	self.maxLoad = self.loadedMaxLoad;
	self.fillLevelDeltas = {};
	self.currentActLoad = 0;
	self.showActLoad = 0;
	self.lastFillLevelDelta = 0;
	self.currentStep = 1;
	self.timeSinceLastLoad = 0;
	self.calcShownActLoad = SpecializationUtil.callSpecializationsFunction("calcShownActLoad");	
	self.setShownActLoad = SpecializationUtil.callSpecializationsFunction("setShownActLoad");
	self.HUDG = true;
end;

function BaleCounterGal:delete()
end;

function BaleCounterGal:readStream(streamId, connection)
	self.TotalBalesCount = streamReadInt32(streamId);
	self.NoRopesBalesCount = streamReadInt32(streamId);
	self.CurrentBalesCount = streamReadInt32(streamId);
	self.RopesRefillCount = streamReadInt32(streamId);
	self:setShownActLoad(streamReadFloat32(streamId), true);
end;

function BaleCounterGal:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.TotalBalesCount);
	streamWriteInt32(streamId, self.NoRopesBalesCount);
	streamWriteInt32(streamId, self.CurrentBalesCount);
	streamWriteInt32(streamId, self.RopesRefillCount);
	streamWriteFloat32(streamId, self.showActLoad);	
end;


function BaleCounterGal:readUpdateStream(streamId, timestamp, connection)
	if connection:getIsServer() then
        if streamReadBool(streamId) then
        	self.TotalBalesCount = streamReadFloat32(streamId);
        	self.NoRopesBalesCount = streamReadFloat32(streamId);
			self.CurrentBalesCount = streamReadFloat32(streamId);
			self.RopesRefillCount = streamReadFloat32(streamId);
        end;
    end;
end;

function BaleCounterGal:writeUpdateStream(streamId, connection, dirtyMask)
	if not connection:getIsServer() then
        if streamWriteBool(streamId, bitAND(dirtyMask, self.dirtyFlag) ~= 0) then
			streamWriteFloat32(streamId, self.TotalBalesCount);
			streamWriteFloat32(streamId, self.NoRopesBalesCount);
			streamWriteFloat32(streamId, self.CurrentBalesCount);
			streamWriteFloat32(streamId, self.RopesRefillCount);
        end;
    end;
end;



function BaleCounterGal:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	if not resetVehicles then
		local tmpTotBalCnt = getXMLInt(xmlFile, key.."#TotalBalesCount");
		local tmpNrbc = getXMLInt(xmlFile, key.."#NoRopesBalesCount");
		local tmpRrc = getXMLInt(xmlFile, key.."#RopesRefillCount");

		if tmpTotBalCnt ~= nil then 
			self.TotalBalesCount = tmpTotBalCnt;
		end;
		if tmpNrbc ~= nil then 
			self.NoRopesBalesCount = tmpNrbc;
		end;
		if tmpRrc ~= nil then
			self.RopesRefillCount = tmpRrc;
		end;
		--self.TotalBalesCount = Utils.getNoNil(getXMLInt(xmlFile, key.."#TotalBalesCount"),0);
		--self.NoRopesBalesCount = Utils.getNoNil(getXMLInt(xmlFile, key.."#NoRopesBalesCount"),0);
		--self.RopesRefillCount = Utils.getNoNil(getXMLInt(xmlFile, key.."#RopesRefillCount"),0);
		print("debug: load attributes ok "..tostring(self.TotalBalesCount).."  "..tostring(self.NoRopesBalesCount).."  "..tostring(self.RopesRefillCount));
	end;
	return BaseMission.VEHICLE_LOAD_OK;
end;

function BaleCounterGal:getSaveAttributesAndNodes(nodeIdent)
	local TotalBalesCount = Utils.getNoNil(self.TotalBalesCount, 0);
	local NoRopesBalesCount = Utils.getNoNil(self.NoRopesBalesCount, 0);
	local RopesRefillCount = Utils.getNoNil(self.RopesRefillCount, 0);
	local attributes = 'TotalBalesCount="'..string.format("%.1f",TotalBalesCount)..'" NoRopesBalesCount="'..string.format("%.1f",NoRopesBalesCount)..'" RopesRefillCount="'..string.format("%.1f",RopesRefillCount)..'"';
	return attributes, nil;
end;

function BaleCounterGal:mouseEvent(posX, posY, isDown, isUp, button)
end;

function BaleCounterGal:keyEvent(unicode, sym, modifier, isDown)
end;

function BaleCounterGal:update(dt)
	if self:getIsActiveForInput() then
		if InputBinding.hasEvent(InputBinding.ACTIVATE_OBJECT) then
			self.HUDG = not self.HUDG;
		end;
	end;
end;

function BaleCounterGal:updateTick(dt)
	if self.isDirty then
		self:raiseDirtyFlags(self.dirtyFlag);
		self.isDirty = false;
	end;

	if self.isServer then
		local delta = self.fillLevel - self.lastFillLevelDelta;
		
		if delta > 0 then
			self.timeSinceLastLoad = 0;
			table.insert(self.fillLevelDeltas, {fillLevel = self.fillLevel, t = self.time});
			
			if table.getn(self.fillLevelDeltas) == 6 then
				local newDelta = self.fillLevelDeltas[6].fillLevel - self.fillLevelDeltas[1].fillLevel;
				local newTime = self.fillLevelDeltas[6].t - self.fillLevelDeltas[1].t;

				normalizedDelta = newDelta/newTime*1000;
				self.currentActLoad = normalizedDelta;
				
				self.fillLevelDeltas = {};
			end;
		else
			self.timeSinceLastLoad = self.timeSinceLastLoad + dt;
		end;

		if (self.timeSinceLastLoad > 1000 and self.currentActLoad > 0) then
			self.currentActLoad = 0;
		end;
		
		self.time = self.time + dt;
		
		self.lastFillLevelDelta = self.fillLevel;
		
		self:calcShownActLoad(self.currentActLoad);
			
		if self.showActLoad == self.maxLoad and self.lastSpeed*3600 > 5 then 
			self.blockTimer = self.blockTimer + dt;
			if self.blockTimer > self.blockMaxTime then
				if not self.isBlocked then
					self.blockTimer = 0;
					--self:setIsBlocked(true);
					--self.isFirstRun2 = true;
					self.isBlocked = true;
				end
			end;
		else
			self.blockTimer = math.max(0, self.blockTimer - dt);
		end;
	end;	

end;

function BaleCounterGal:draw()
	setTextBold(true);
	setTextColor(0.98, 0.98, 0.98, 0.9);
	if self.HUDG then
		
		self.hudG.overlay_bar:render();
		self.hudG.overlay_hud:render();	

		local x, y = getNormalizedScreenValues(333/12, 16);
		renderText(self.hudG.xPos+x, self.hudG.yPos+y, 0.012, "bale count.: session / total / rope % / refill");
		g_currentMission:addHelpButtonText(string.format(g_i18n:getText("HUD_OFF"), self.typeDesc), InputBinding.ACTIVATE_OBJECT);

		if self.CurrentBalesCount~= nil then
			local x, y = getNormalizedScreenValues(333/3, 0.1);
			renderText(self.hudG.xPos+x, self.hudG.yPos+y, 0.014, string.format("  %u ", self.CurrentBalesCount));
		end;
		if self.TotalBalesCount~= nil then
			--renderText(0.92, 0.775, 0.040, string.format(self.TotalBalesCount));

			local cordaResidua = math.floor((100-(self.NoRopesBalesCount/self.RopesCapacity)*100));
			-- renderText(0.92, 0.74, 0.024, string.format(cordaResidua));
			local refillStatus = self.RopesRefillCount;

			local x, y = getNormalizedScreenValues(333/2, 0.1);
			renderText(self.hudG.xPos+x, self.hudG.yPos+y, 0.014, "   "..self.TotalBalesCount.."      "..cordaResidua.."%".."       "..self.RopesRefillCount);

			setTextAlignment(RenderText.ALIGN_LEFT);

		end;
		
		-- pickup load %
		local percentage = math.min(self.showActLoad/self.maxLoad, 1);
		if percentage > 0.92 then
			setOverlayColor(self.hud2.overlay_bar.overlayId, 1, 0, 0, 1)	
		else
			setOverlayColor(self.hud2.overlay_bar.overlayId, 0, 1, 0, 1)
		end;
	
		self.hud2.overlay_bar.width = self.hud2.hudWidth * percentage;	
		setOverlayUVs(self.hud2.overlay_bar.overlayId, 0, 0.05, 0, 1, percentage, 0.05, percentage, 1);
		self.hud2.overlay_bar:render();	
		self.hud2.overlay_hud:render();	
		setTextColor(1.0, 1.0, 1.0, 1.0);
		setTextBold(false);
		setTextAlignment(RenderText.ALIGN_CENTER);
		local x, y = getNormalizedScreenValues(333/2, 10.5);
		renderText(self.hud2.xPos+x, self.hud2.yPos+y, 0.012, "pickup:"..string.format("%5.1f %%", 100*percentage));

		if self.isBlocked then
			g_currentMission:showBlinkingWarning(g_i18n:getText("SLOW_DOWN"), 2000);
			self.blockCounter = self.blockCounter + 1;
			if self.blockCounter >= 3 then 
				self:setPickupState(false, true);
				self.blockCounter = 0;
			end;
			self.isBlocked = false;
		end;

	else
		g_currentMission:addHelpButtonText(string.format(g_i18n:getText("HUD_ON"), self.typeDesc), InputBinding.ACTIVATE_OBJECT);
	end;

	-- reimposto i settaggi di default per il testo, a maggior sicurezza di compatibilità con altre mod...
	setTextAlignment(RenderText.ALIGN_LEFT);
	setTextColor(1, 1, 1, 1);
	setTextBold(false);
end;


function BaleCounterGal.dropBale(self, baleIndex)
	if self.CurrentBalesCount ~= nil and self.TotalBalesCount ~= nil and self.NoRopesBalesCount ~= nil then
		self.CurrentBalesCount = self.CurrentBalesCount +1;
		self.TotalBalesCount = self.TotalBalesCount +1;
		self.NoRopesBalesCount = self.NoRopesBalesCount +1;
		self.isDirty = true;
	end;
end;

function BaleCounterGal:calcShownActLoad(target)
	if target == self.showActLoad then
		return;
	end;
	
	local step = self.currentStep * math.abs(self.showActLoad-target)/6;
	
	if self.timeSinceLastLoad > 1000 then
		step = step * 10;
	end;
	
	if target > self.showActLoad then
		self:setShownActLoad(math.min(self.showActLoad + step, target));
	else
		self:setShownActLoad(math.max(self.showActLoad - step, target));
	end;
end;

function BaleCounterGal:setShownActLoad(act, noEventSend)	
	self.showActLoad = math.max(math.min(act, self.maxLoad), 0);
	SetShownActLoadEvent.sendEvent(self, act, noEventSend);
end;



Baler.dropBale = Utils.appendedFunction(BaleCounterGal.dropBale, Baler.dropBale);
--Baler.loadFromAttributesAndNodes = Utils.overwrittenFunction(Baler.loadFromAttributesAndNodes, BaleCounterGal.loadFromAttributesAndNodes);
--Baler.loadFromAttributesAndNodes = Utils.prependedFunction(BaleCounterGal.loadFromAttributesAndNodes, Baler.loadFromAttributesAndNodes);

---
---
---
---

SetShownActLoadEvent = {};
SetShownActLoadEvent_mt = Class(SetShownActLoadEvent, Event);

InitEventClass(SetShownActLoadEvent, "SetShownActLoadEvent");

function SetShownActLoadEvent:emptyNew()
    local self = Event:new(SetShownActLoadEvent_mt);
    self.className="SetShownActLoadEvent";
    return self;
end;

function SetShownActLoadEvent:new(vehicle, showActLoad)
    local self = SetShownActLoadEvent:emptyNew()
    self.vehicle = vehicle;
	self.showActLoad = showActLoad;
    return self;
end;

function SetShownActLoadEvent:readStream(streamId, connection)
    local id = streamReadInt32(streamId);
    self.vehicle = networkGetObject(id);

	self.showActLoad = streamReadFloat32(streamId);
	if self.vehicle ~= nil then
		self.vehicle:setShownActLoad(self.showActLoad, true);
	end;
	if not connection:getIsServer() then
        g_server:broadcastEvent(SetShownActLoadEvent:new(self.vehicle, self.showActLoad), nil, connection, self.vehicle);
    end;
end;

function SetShownActLoadEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
	streamWriteFloat32(streamId, self.showActLoad);
end;

function SetShownActLoadEvent.sendEvent(vehicle, showActLoad, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetShownActLoadEvent:new(vehicle, showActLoad), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(SetShownActLoadEvent:new(vehicle, showActLoad));
		end;
	end;
end;

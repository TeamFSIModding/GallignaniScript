--
-- RopeBreakdown
--
-- @author  	Benjamin Biot (J&B Modding)
-- @version 	v1.0
-- @date  		30/11/10
--
-- adattamenti specifici per Gallignani e BaleCounterGal by fcelsa 05/2016 più aggiunta ricarica filo 07/2016
-- 10/2016 fix per possibile vx = nil (da riga 242)

RopeBreakdown = {};

function RopeBreakdown.prerequisitesPresent(specializations)
	-- return SpecializationUtil.hasSpecialization(Gallignani, specializations) and SpecializationUtil.hasSpecialization(BaleCounterGal, specializations);
	return true;
end;

function RopeBreakdown:load(xmlFile)
	self.SetCoverEdgeDoorPanel= SpecializationUtil.callSpecializationsFunction("SetCoverEdgeDoorPanel");
	self.SetSideDoorPanel= SpecializationUtil.callSpecializationsFunction("SetSideDoorPanel");
	self.SetSideDoorPanelDX= SpecializationUtil.callSpecializationsFunction("SetSideDoorPanelDX");
	self.SetHasRopes= SpecializationUtil.callSpecializationsFunction("SetHasRopes");
	self.SetHasRefill= SpecializationUtil.callSpecializationsFunction("SetHasRefill");

	-- Animation --
	self.CoverEdgeDoorPanelAnimation = getXMLString(xmlFile, "vehicle.CoverEdgeDoorPanel#animationName");
	self.CoverEdgeDoorPanel = true;
	self.SideDoorPanelAnimation = getXMLString(xmlFile, "vehicle.SideDoorPanel#animationName");
	self.SideDoorPanel = true;
	self.SideDoorPanelAnimationDX = getXMLString(xmlFile, "vehicle.SideDoorPanelDX#animationName");
	self.SideDoorPanelDX = true;

	-- Ropes management --
	self.Ropes = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.Ropes#index"));
	self.RopesCapacity = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.Ropes#Capacity"), 40);
	self.RopesRefilling = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.Ropes#Refilling"), 4);
	self.RopesRun1 = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.RopesRun1#index"));
	self.RopesRun2 = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.RopesRun2#index"));
	self.RopesRun3 = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.RopesRun3#index"));
	self.RopesRun4 = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.RopesRun4#index"));
	self.numRopesRefill = Utils.getNoNil(getXMLInt(xmlFile, "vehicle.RopesRefill#count"), 0);
	self.RopesRefill = {};
	for i=1, self.numRopesRefill do
		local RopeRefillnumi = string.format("vehicle.RopesRefill.RopesRefill" .. "%d", i);
		self.RopesRefill[i] = Utils.indexToObject(self.components, getXMLString(xmlFile, RopeRefillnumi .. "#index"));
	end;

	self.hasRopes = true;
	self.isLoaded = true;
	self.isRefilled = true;
	self.ropeRefillRange = false;
	self.onePassRefillWarning = true;

	-- Sound for "no Ropes " --
	if self.isClient then
		local NoRopeSoundFile = Utils.getFilename("Sounds/NoRope.ogg", self.baseDirectory);
		self.NoRopeSoundId = createSample("NoRopeSound");
		loadSample(self.NoRopeSoundId, NoRopeSoundFile, false);
		self.NoRopePlaying = false;
		-- suoni per gli sportelloni laterali --
		local AprePortSoundFile = Utils.getFilename("Sounds/open01.wav", self.baseDirectory);
		self.AprePortSoundId = createSample("AprePortSound");
		loadSample(self.AprePortSoundId, AprePortSoundFile, false);
		self.AprePortPlay = false;
		local ChiudePortSoundFile = Utils.getFilename("Sounds/close01.wav", self.baseDirectory);
		self.ChiudePortSoundId = createSample("ChiudePortSound");
		loadSample(self.ChiudePortSoundId, ChiudePortSoundFile, false);
		self.ChiudePortPlay = false;
		-- suoni per il portello superiore (contenitore filo)
		local ApreSupSoundFile = Utils.getFilename("Sounds/supopen.wav", self.baseDirectory);
		self.ApreSupSoundId = createSample("ApreSupSound");
		loadSample(self.ApreSupSoundId, ApreSupSoundFile, false);
		self.ApreSupPlay = false;
		local ChiudeSupSoundFile = Utils.getFilename("Sounds/supclose.wav", self.baseDirectory);
		self.ChiudeSupSoundId = createSample("ChiudeSupSound");
		loadSample(self.ChiudeSupSoundId, ChiudeSupSoundFile, false);
		self.ChiudeSupPlay = false;
		-- suono caricamento nuovi rotoli
		local LoadRopeSoundFile = Utils.getFilename("Sounds/effect1.wav", self.baseDirectory);
		self.LoadRopeSoundId = createSample("LoadRopeSound");
		loadSample(self.LoadRopeSoundId, LoadRopeSoundFile, false);
		self.LoadRopePlay = false;
	end;

	-- da togliere se poi BaleCounterGal funziona
	--self.TotalBalesCount = 0;
	--self.CurrentBalesCount = 0;
	--self.NoRopesBalesCount = 0;
	--self.RopesRefillCount = 0;
	---------------------------------------------

end;

function RopeBreakdown:delete()
	if self.isClient then 
		if self.NoRopeSound ~= nil then
			Utils.deleteSample(self.NoRopeSound);
		end;
		if self.AprePortSound ~= nil then
			Utils.deleteSample(self.AprePortSound);
		end;
		if self.ChiudePortSound ~= nil then
			Utils.deleteSample(self.ChiudePortSound);
		end;
		if self.ApreSupSound ~= nil then
			Utils.deleteSample(self.AprePortSound);
		end;
		if self.ChiudeSupSound ~= nil then
			Utils.deleteSample(self.ChiudePortSound);
		end;
		if self.LoadRopeSound ~= nil then
			Utils.deleteSample(self.LoadRopeSound);
		end;
	end;
end;

function RopeBreakdown:readStream(streamId, connection)
	self:SetCoverEdgeDoorPanel(streamReadBool(streamId), true);
	self:SetSideDoorPanel(streamReadBool(streamId), true);
	self:SetSideDoorPanelDX(streamReadBool(streamId), true);
	self:SetHasRopes(streamReadBool(streamId), true);
	self:SetHasRefill(streamReadBool(streamId), true);
end;

function RopeBreakdown:writeStream(streamId, connection)
	streamWriteBool(streamId, self.CoverEdgeDoorPanel);
	streamWriteBool(streamId, self.SideDoorPanel);
	streamWriteBool(streamId, self.SideDoorPanelDX);
	streamWriteBool(streamId, self.isLoaded);
	streamWriteBool(streamId, self.isRefilled);
end;

function RopeBreakdown:readUpdateStream(streamId, timestamp, connection)
end;

function RopeBreakdown:writeUpdateStream(streamId, connection, dirtyMask)
end;

function RopeBreakdown:mouseEvent(posX, posY, isDown, isUp, button)
end;

function RopeBreakdown:keyEvent(unicode, sym, modifier, isDown)
end;

function RopeBreakdown:update(dt)
	-- Manage key events --
	if self.inrange then
		if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA3) then
			self:SetSideDoorPanel(not self.SideDoorPanel);
		end;
		if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA2) then
			self:SetSideDoorPanelDX(not self.SideDoorPanelDX);
		end;
		if InputBinding.hasEvent(InputBinding.ACTIVATE_OBJECT) then
			self:SetCoverEdgeDoorPanel(not self.CoverEdgeDoorPanel);
		end;


		-- quando è in trigger ed i rotoli di scorta sono meno di quelli massimi, si può riempire.
		if self.ropeRefillRange and self.RopesRefillCount < self.numRopesRefill then
			if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA) then
				-- controlla se sono sufficienti i soldi
				local calcolaMoney = math.floor((10*(self.numRopesRefill-self.RopesRefillCount)) * g_currentMission.missionStats.difficulty)
				if g_currentMission.missionStats.money > calcolaMoney then
					print(self.RopesRefillCount);
					print(self.numRopesRefill);
					self:SetHasRefill(true);		
				else
					g_currentMission:showBlinkingWarning(g_i18n:getText("NO_MONEY_FOR_ROPE"), 3000);
				end;
			end;
		end;

		if not self.isLoaded and not self.SideDoorPanel and not self.isTurnedOn and self.RopesRefillCount >= 4 then
			if InputBinding.hasEvent(InputBinding.IMPLEMENT_EXTRA) then
				self:SetHasRopes(true);
			end;
		end;

	end;

	-- trigger the breakdown --
	if self.NoRopesBalesCount >= self.RopesCapacity then
		self:SetHasRopes(false);
	end;

	-- check filo di scorta
	if self.RopesRefillCount == 0 then
		self:SetHasRefill(false);
	end;

	-- Display key when in range --
	if self.inrange then
		if self.SideDoorPanel then
			g_currentMission:addHelpButtonText(string.format(g_i18n:getText("OPEN_SIDE_DOOR_SX"), self.typeDesc), InputBinding.IMPLEMENT_EXTRA3);
		else
			g_currentMission:addHelpButtonText(string.format(g_i18n:getText("CLOSE_SIDE_DOOR_SX"), self.typeDesc), InputBinding.IMPLEMENT_EXTRA3);
		end;
		if self.SideDoorPanelDX then
			g_currentMission:addHelpButtonText(string.format(g_i18n:getText("OPEN_SIDE_DOOR_DX"), self.typeDesc), InputBinding.IMPLEMENT_EXTRA2);
		else
			g_currentMission:addHelpButtonText(string.format(g_i18n:getText("CLOSE_SIDE_DOOR_DX"), self.typeDesc), InputBinding.IMPLEMENT_EXTRA2);
		end;
		if self.CoverEdgeDoorPanel then
			g_currentMission:addHelpButtonText(string.format(g_i18n:getText("OPEN_COVEREDGE_DOOR"), self.typeDesc), InputBinding.ACTIVATE_OBJECT);
		else
			g_currentMission:addHelpButtonText(string.format(g_i18n:getText("CLOSE_COVEREDGE_DOOR"), self.typeDesc), InputBinding.ACTIVATE_OBJECT);
			if not self.isLoaded and not self.SideDoorPanel and not self.isTurnedOn and self.RopesRefillCount ~= 0 then
				g_currentMission:addHelpButtonText(string.format(g_i18n:getText("RELOAD_ROPES"), addmoney), InputBinding.IMPLEMENT_EXTRA);
			end;
			if self.ropeRefillRange and self.RopesRefillCount < self.numRopesRefill then
				local addmoney = (' %s '):format(g_i18n:formatMoney(math.floor((10*(self.numRopesRefill-self.RopesRefillCount)) * g_currentMission.missionStats.difficulty)));
				g_currentMission:addHelpButtonText(string.format(g_i18n:getText("REFILL_ROPES"), addmoney), InputBinding.IMPLEMENT_EXTRA);
			end;
		end;
	end;
end;

function RopeBreakdown:updateTick(dt)

	if self.attacherVehicle and g_currentMission.player ~= nil then
		-- Getting the distance between the player and the implement
		local nearestDistance = 4.0; --max distance allowed
		local px, py, pz = getWorldTranslation(self.rootNode);
		local vx, vy, vz = getWorldTranslation(g_currentMission.player.rootNode);
		local distance = Utils.vector3Length(px-vx, py-vy, pz-vz);
		if distance < nearestDistance then
			self.inrange = true;
		else
			self.inrange = false;
			self.ropeRefillRange = false;
		end;

		if self.inrange then
			for k,v in pairs(g_currentMission.nonUpdateables) do
				if g_currentMission.nonUpdateables[k] ~= nil then
					local trigger = g_currentMission.nonUpdateables[k];
					local triggerId = trigger.triggerId;
					if triggerId ~= nil and trigger.isEnabled then
						local nearestDistance = 8.0; --max distance allowed
						local px, py, pz = getWorldTranslation(self.rootNode);
						local vx, vy, vz = getWorldTranslation(triggerId);
						if vx == nil then vx = 0; end;
						if vy == nil then vy = 0; end;
						if vz == nil then vz = 0; end;
						local distance = Utils.vector3Length(px-vx, py-vy, pz-vz);
						if distance < nearestDistance then
							if trigger.fillType then
								if trigger.fillType == Fillable.FILLTYPE_FERTILIZER or trigger.fillType == Fillable.FILLTYPE_SEEDS then
									self.ropeRefillRange = true;
								else
									self.ropeRefillRange = false;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

function RopeBreakdown:SetCoverEdgeDoorPanel(isCoverEdgeDoorPanel,noEventSend)
	SetCoverEdgeDoorPanelEvent.sendEvent(self, isCoverEdgeDoorPanel, noEventSend);
	-- Play doorPanel animation if inRange --
		if isCoverEdgeDoorPanel then
			if self.CoverEdgeDoorPanelAnimation ~= nil and self.playAnimation ~= nil then
				self:playAnimation(self.CoverEdgeDoorPanelAnimation, -1, nil, true);
				self.CoverEdgeDoorPanel = true;
				playSample(self.ChiudeSupSoundId, 1, 1, 0);
			end;
		else
			if self.CoverEdgeDoorPanelAnimation ~= nil and self.playAnimation ~= nil then
				self:playAnimation(self.CoverEdgeDoorPanelAnimation, 1, nil, true);
				self.CoverEdgeDoorPanel = false;
				playSample(self.ApreSupSoundId, 1, 1, 0);
			end;
		end;
end;


function RopeBreakdown:SetSideDoorPanel(isSideDoorPanel,noEventSend)
	SetSideDoorPanelEvent.sendEvent(self, isSideDoorPanel, noEventSend);
	-- Play doorPanel animation if inRange --
		if isSideDoorPanel then
			if self.SideDoorPanelAnimation ~= nil and self.playAnimation ~= nil then
				self:playAnimation(self.SideDoorPanelAnimation, -1, nil, true);
				self.SideDoorPanel = true;
				playSample(self.ChiudePortSoundId, 1, 1, 0);
			end;
		else
			if self.SideDoorPanelAnimation ~= nil and self.playAnimation ~= nil then
				self:playAnimation(self.SideDoorPanelAnimation, 1, nil, true);
				self.SideDoorPanel = false;
				playSample(self.AprePortSoundId, 1, 1, 0);
			end;
		end;
end;


function RopeBreakdown:SetSideDoorPanelDX(isSideDoorPanelDX,noEventSend)
	SetSideDoorPanelEvent.sendEvent(self, isSideDoorPanelDX, noEventSend);
	-- Play doorPanel animation if inRange --
		if isSideDoorPanelDX then
			if self.SideDoorPanelAnimationDX ~= nil and self.playAnimation ~= nil then
				self:playAnimation(self.SideDoorPanelAnimationDX, -1, nil, true);
				self.SideDoorPanelDX = true;
				playSample(self.ChiudePortSoundId, 1, 1, 0);
			end;
		else
			if self.SideDoorPanelAnimationDX ~= nil and self.playAnimation ~= nil then
				self:playAnimation(self.SideDoorPanelAnimationDX, 1, nil, true);
				self.SideDoorPanelDX = false;
				playSample(self.AprePortSoundId, 1, 1, 0);
			end;
		end;
end;


function RopeBreakdown:SetHasRopes(isLoaded,noEventSend)
	self.isLoaded = isLoaded;
	SetHasRopesEvent.sendEvent(self, self.isLoaded, noEventSend);

	if self.isLoaded then
		self.NoRopesBalesCount = 0;
		setVisibility(self.Ropes, true);
		if self.NoRopePlaying then
			stopSample(self.NoRopeSoundId);
			self.NoRopePlaying = false;
		end;

		self.RopesRefillCount = self.RopesRefillCount - 4;
		self.onePassRefillWarning = true;
		playSample(self.LoadRopeSoundId, 1, 1, 0);
	
		if self.RopesRefillCount ~= 0 then
			self:SetHasRefill(false);
		end;
	else
		setVisibility(self.Ropes, false);
		self:setPickupState(false, true);
		if self:getIsActiveForSound() then
			if not self.NoRopePlaying then
				playSample(self.NoRopeSoundId, 1, 1, 0);
				self.NoRopePlaying = true;
			end;
		end;
	end;
end;

function RopeBreakdown:SetHasRefill(isRefilled,noEventSend)
	self.isRefilled = isRefilled;
	SetHasRefillEvent.sendEvent(self, self.isRefilled, noEventSend);

	if self.isRefilled then
		local calcolaMoney = math.floor((10*(self.numRopesRefill-self.RopesRefillCount)) * g_currentMission.missionStats.difficulty)
		if g_currentMission:getIsServer() then
			playSample(g_currentMission.cashRegistrySound, 1, 1, 0);
			g_currentMission:addSharedMoney(-calcolaMoney, "vehicleRunningCost");
			g_currentMission:addMoneyChange(-calcolaMoney, FSBaseMission.MONEY_TYPE_SINGLE, true);
		end;
		self.RopesRefillCount = self.numRopesRefill;
		-- set visibility dei rotoli di corda di scorta...
		for i=1, self.RopesRefillCount do
			setVisibility(self.RopesRefill[i], true);
		end;

	else

		for i=1, self.numRopesRefill do
			setVisibility(self.RopesRefill[i], false);
		end;

		if self.RopesRefillCount > 0 then
			for i=1, self.RopesRefillCount do
				setVisibility(self.RopesRefill[i], true);
			end;			
		end;
	end;

end;


function RopeBreakdown:draw()

	-- scalo la dimensione dei rocchetti di spago...
	local cordaResidua = 1-(self.NoRopesBalesCount/self.RopesCapacity);
	local sx = cordaResidua;
	local sz = cordaResidua;
	if cordaResidua ~= 0 then 
		setScale(self.RopesRun1,sx,1,sz);
		setScale(self.RopesRun2,sx,1,sz);
		setScale(self.RopesRun3,sx,1,sz);
		setScale(self.RopesRun4,sx,1,sz);
	else
		setScale(self.RopesRun1,1,1,1);
		setScale(self.RopesRun2,1,1,1);
		setScale(self.RopesRun3,1,1,1);
		setScale(self.RopesRun4,1,1,1);
	end;

	for i=1, self.numRopesRefill do
		if i <= self.RopesRefillCount then
			setVisibility(self.RopesRefill[i], true);
		else
			setVisibility(self.RopesRefill[i], false);
		end;
	end;		
	
	-- è finito spago!
	if not self.isLoaded and self.isTurnedOn then
		g_currentMission:addWarning(g_i18n:getText("OUT_OF_NET_1"));
	end;

	-- scarseggia la scorta di spago!!
	if self.RopesRefillCount <= 4 and self.onePassRefillWarning then
		g_currentMission.inGameMessage:showMessage("Info:", string.format(g_i18n:getText("OUT_OF_NET_2"), self.RopesRefillCount), 0, false);
		self.onePassRefillWarning = false;
	end;

end;


--- event ---

SetHasRopesEvent = {};
SetHasRopesEvent_mt = Class(SetHasRopesEvent, Event);

InitEventClass(SetHasRopesEvent, "SetHasRopesEvent");

function SetHasRopesEvent:emptyNew()
	local self = Event:new(SetHasRopesEvent_mt);
	self.className="SetHasRopesEvent";
	return self;
end;

function SetHasRopesEvent:new(vehicle, isLoadedWithRopes)
	local self = SetHasRopesEvent:emptyNew()
	self.vehicle = vehicle;
	self.isLoadedWithRopes = isLoadedWithRopes;
	return self;
end;

function SetHasRopesEvent:readStream(streamId, connection)
	local id = streamReadInt32(streamId);
	self.isLoadedWithRopes = streamReadBool(streamId);
	self.vehicle = networkGetObject(id);
	self:run(connection);
end;

function SetHasRopesEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
	streamWriteBool(streamId, self.isLoadedWithRopes);
end;

function SetHasRopesEvent:run(connection)   
	self.vehicle:SetHasRopes(self.isLoadedWithRopes, true);
	if not connection:getIsServer() then
		g_server:broadcastEvent(SetHasRopesEvent:new(self.vehicle, self.isLoadedWithRopes), nil, connection, self.vehicle);
	end;
end;

function SetHasRopesEvent.sendEvent(vehicle, isLoadedWithRopes, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetHasRopesEvent:new(vehicle, isLoadedWithRopes), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(SetHasRopesEvent:new(vehicle, isLoadedWithRopes));
		end;
	end;
end;



SetHasRefillEvent = {};
SetHasRefillEvent_mt = Class(SetHasRefillEvent, Event);

InitEventClass(SetHasRefillEvent, "SetHasRefillEvent");

function SetHasRefillEvent:emptyNew()
	local self = Event:new(SetHasRefillEvent_mt);
	self.className="SetHasRefillEvent";
	return self;
end;

function SetHasRefillEvent:new(vehicle, isLoadedWithRefill)
	local self = SetHasRefillEvent:emptyNew()
	self.vehicle = vehicle;
	self.isLoadedWithRefill = isLoadedWithRefill;
	return self;
end;

function SetHasRefillEvent:readStream(streamId, connection)
	local id = streamReadInt32(streamId);
	self.isLoadedWithRefill = streamReadBool(streamId);
	self.vehicle = networkGetObject(id);
	self:run(connection);
end;

function SetHasRefillEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
	streamWriteBool(streamId, self.isLoadedWithRefill);
end;

function SetHasRefillEvent:run(connection)   
	self.vehicle:SetHasRefill(self.isLoadedWithRefill, true);
	if not connection:getIsServer() then
		g_server:broadcastEvent(SetHasRefillEvent:new(self.vehicle, self.isLoadedWithRefill), nil, connection, self.vehicle);
	end;
end;

function SetHasRefillEvent.sendEvent(vehicle, isLoadedWithRefill, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetHasRefillEvent:new(vehicle, isLoadedWithRefill), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(SetHasRefillEvent:new(vehicle, isLoadedWithRefill));
		end;
	end;
end;

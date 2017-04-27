--
-- HydraulicCoupling
--
-- @author:    	Xentro (Marcus@Xentro.se)
-- @website:	www.Xentro.se
-- @history:	v1.0  - 2015-02-22 - Initial implementation
-- 				v1.01 - 2015-09-09 - Minor update
-- 				v1.1  - 2016-04-09 - Print movingPartIndices in log
-- 

HydraulicCoupling = {};

HydraulicCoupling.hoseTypes = {};
HydraulicCoupling.hoseTypes["hydraulic"] = true;
HydraulicCoupling.hoseTypes["electric"] = true;
HydraulicCoupling.hoseTypes["air"] = true;

function HydraulicCoupling.prerequisitesPresent(specializations)
	if not SpecializationUtil.hasSpecialization(Cylindered, specializations) then print("Warning: Specialization HydraulicCoupling needs the specialization Cylindered."); end;
	
	return SpecializationUtil.hasSpecialization(Cylindered, specializations);
end;

function HydraulicCoupling:load(xmlFile)
	self.attachHydraulicCoupling = SpecializationUtil.callSpecializationsFunction("attachHydraulicCoupling");
	self.detachHydraulicCoupling = SpecializationUtil.callSpecializationsFunction("detachHydraulicCoupling");
	self.isHoseTypeAttached = HydraulicCoupling.isHoseTypeAttached;
	
	local i, gotHydraulic, gotElectric, gotAir = 0, false, false, false;
	while true do
		local key = string.format("vehicle.inputAttacherJoints.inputAttacherJoint(%d)", i);
		if not hasXMLProperty(xmlFile, key) then break; end;
		local joint = self.inputAttacherJoints[i + 1];
		
		if joint ~= nil then
			joint.hydraulicCouplings = {};
			
			for t in pairs(HydraulicCoupling.hoseTypes) do
				joint.hydraulicCouplings[t] = {};
			end;
			
			local subi = 0;
			while true do
				local key2 = string.format(key .. ".HydraulicCoupling(%d)", subi);
				if not hasXMLProperty(xmlFile, key2) then break; end;
		
				local movingPartIndice = getXMLInt(xmlFile, key2 .. "#movingPartIndice");
				local hoseType = Utils.getNoNil(getXMLString(xmlFile, key2 .. "#hoseType"), "hydraulic");
				
				if hoseType ~= nil and HydraulicCoupling.hoseTypes[string.lower(hoseType)] then
					if movingPartIndice ~= nil and self.movingParts[movingPartIndice] ~= nil then
						local ai = Utils.indexToObject(self.components, getXMLString(xmlFile, key2 .. "#attached"));
						local di = Utils.indexToObject(self.components, getXMLString(xmlFile, key2 .. "#detached"));
						
						if ai ~= nil and di ~= nil then
							if string.lower(hoseType) == "hydraulic" then
								gotHydraulic = true;
							elseif string.lower(hoseType) == "electric" then
								gotElectric = true;
							elseif string.lower(hoseType) == "air" then
								gotAir = true;
							end;
							
							local entry = {};
							entry.movingPartIndice = movingPartIndice;
							entry.attachedCoupling = ai;
							entry.detachedCoupling = di;
							
							setVisibility(entry.attachedCoupling, false);
							setVisibility(entry.detachedCoupling, true);
							
							table.insert(joint.hydraulicCouplings[string.lower(hoseType)], entry);
							subi = subi + 1;
						else
							print("HydraulicCoupling - Error: attached or detached is nil in " .. self.configFileName);
							break;
						end;
					else
						print("HydraulicCoupling - Error: Invalid movingPartIndice (" .. tostring(movingPartIndice) .. ") in " .. self.configFileName);
						break;
					end;
				else
					print("HydraulicCoupling - Error: hoseType is invalid " .. self.configFileName);
					break;
				end;
			end;
		else
			print("HydraulicCoupling - Error: Invalid attacherJointIndice (" .. tostring(JointIndice) .. ") in " .. self.configFileName);
			break;
		end;
		
		i = i + 1;
	end;
	
	self.enableHydraulics = gotHydraulic;
	self.enableElectrics = gotElectric;
	self.enableAirBrakes = gotAir;
	
	-- hydraulic override stuff
	if self.enableHydraulics then
		if self.getIsFoldAllowed ~= nil then
			self.getIsFoldAllowed = Utils.overwrittenFunction(self.getIsFoldAllowed, HydraulicCoupling.getIsFoldAllowed);
		end;
		
		self.setJointMoveDown = Utils.overwrittenFunction(self.setJointMoveDown, HydraulicCoupling.setJointMoveDown);
	end;
	
	-- electric override stuff
	if self.enableElectrics then
		self.setLightsTypesMask = Utils.overwrittenFunction(self.setLightsTypesMask, HydraulicCoupling.setLightsTypesMask);
		self.setTurnSignalState = Utils.overwrittenFunction(self.setTurnSignalState, HydraulicCoupling.setLightsTypesMask);
		self.setBrakeLightsVisibility = Utils.overwrittenFunction(self.setBrakeLightsVisibility, HydraulicCoupling.setBrakeLightsVisibility);
		self.setBeaconLightsVisibility = Utils.overwrittenFunction(self.setBeaconLightsVisibility, HydraulicCoupling.setBeaconLightsVisibility);
		self.setReverseLightsVisibility = Utils.overwrittenFunction(self.setReverseLightsVisibility, HydraulicCoupling.setBeaconLightsVisibility);
	end;
	
	self.airBrakeActive = false;
	
	self.movingToolCouplings = {};
	local toolIds = Utils.getVectorNFromString(getXMLString(xmlFile, "vehicle.movingToolCouplings#toolIds"))
	if toolIds ~= nil then
		for _, i in pairs(toolIds) do
			if self.movingTools[i + 1] ~= nil then
				table.insert(self.movingToolCouplings, i + 1);
			end;
		end;
	end;
	
	self.hydraulicCouplingIsAttached = {};
	for hoseType in pairs(HydraulicCoupling.hoseTypes) do
		self.hydraulicCouplingIsAttached[hoseType] = false;
	end;
	
	self.lastValueUpdates = {};
	
	-- self.hydraulicPlayerAttached = false;
	-- self.hydraulicPlayerDetached = false;
end;

function HydraulicCoupling:postLoad(xmlFile)
	if Utils.getNoNil(getXMLBool(xmlFile, "vehicle.movingToolCouplings#debugPartIndice"), false) then
		print("");
		print("-- MovingPart Indices --");
		local componentName = getName(self.components[1].node);
		for i, v in ipairs(self.movingParts) do
			if componentName == getName(v.referenceFrame) then
				print("Node: " .. getName(v.node) .. " is indice: " .. i);
			end;
		end;
		print("");
	end;
end;

function HydraulicCoupling:delete()
end;

function HydraulicCoupling:readStream(streamId, connection)
end;

function HydraulicCoupling:writeStream(streamId, connection)
end;

function HydraulicCoupling:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	if not resetVehicles then
		local HydraulicCouplingIsAttached = getXMLBool(xmlFile, key .. "#HydraulicCouplingIsAttached");
		
		if HydraulicCouplingIsAttached ~= nil and not HydraulicCouplingIsAttached then
			self.couplingPendingDetach = true;
		end;
	end;
	
	return BaseMission.VEHICLE_LOAD_OK;
end;

function HydraulicCoupling:getSaveAttributesAndNodes(nodeIdent)
	local attributes;
	
	local isAttached = false;
	
	for hoseType, attached in pairs(self.hydraulicCouplingIsAttached) do
		if attached then
			isAttached = true;
			break;
		end;
	end;
	
	attributes = 'HydraulicCouplingIsAttached="' .. tostring(isAttached) ..'"';
	
	return attributes;
end;

function HydraulicCoupling:mouseEvent(posX, posY, isDown, isUp, button)
end;

function HydraulicCoupling:keyEvent(unicode, sym, modifier, isDown)
end;

function HydraulicCoupling:update(dt)
	if self.enableAirBrakes and self.isServer and self:getIsActive() then
		if self.onBrake ~= nil and self.onReleaseBrake ~= nil then
			if not self:isHoseTypeAttached("air") and not self.airBrakeActive then
				self:onBrake(1, true);
				self.airBrakeActive = true;
			elseif self:isHoseTypeAttached("air") and self.airBrakeActive then
				self:onReleaseBrake();
				self.airBrakeActive = false;
			end;
		end;
	end;
end;

function HydraulicCoupling:updateTick(dt)
	if self.enableElectrics and self.isServer then
		if self:isHoseTypeAttached("electric") and (self.lastValueUpdates["updateLights"] or self.lastValueUpdates["updateBeacons"]) then
			HydraulicCoupling.updateLightCouplings(self, true);
			self.lastValueUpdates["updateLights"] = false;
			self.lastValueUpdates["updateBeacons"] = false;
		end;
	end;
	
	if self.couplingPendingDetach ~= nil and self.couplingPendingDetach then
		self.couplingPendingDetach = nil;
		self:detachHydraulicCoupling(true);
	end;
end;

function HydraulicCoupling:draw()
end;

function HydraulicCoupling:onAttach(vehicle, jointDescIndex)
	if not self.hydraulicPlayerAttached then
		self:attachHydraulicCoupling(vehicle, jointDescIndex, true);
	else
		if vehicle.HydraulicRefs ~= nil then
			HydraulicCoupling.updateMovingToolCouplings(self, false);
		end;
	end;
end;

function HydraulicCoupling:onDetach(vehicle)
	if not self.hydraulicPlayerDetached then
		self:detachHydraulicCoupling(true);
	end;
	
	HydraulicCoupling.updateMovingToolCouplings(self, true);
end;

function HydraulicCoupling:attachHydraulicCoupling(vehicle, jointDescIndex, noEventSend)
	local hydRef = vehicle.attacherJoints[jointDescIndex].HydraulicRefs;
	
	if hydRef ~= nil then
		local joint = self.attacherJoint;
		
		if joint ~= nil then
			if joint.hydraulicCouplings ~= nil then
				joint.attachedCouplings = true;
				joint.HydraulicRefs = hydRef;
				
				for hoseType, allowed in pairs(HydraulicCoupling.hoseTypes) do
					local refTable = hydRef[hoseType];
					
					if allowed and table.getn(refTable) > 0 then
						for i, v in pairs(joint.hydraulicCouplings[hoseType]) do
							if refTable[i] ~= nil then
								local part = self.movingParts[v.movingPartIndice];
								
								if v.oldRefFrame == nil then
									v.oldRefFrame = part.referenceFrame;
								end;
								
								part.referenceFrame = hydRef[hoseType][i];
								part.referenceFrameOffset = {0, 0, 0};
								
								setVisibility(v.attachedCoupling, true);
								setVisibility(v.detachedCoupling, false);
								
								self.hydraulicCouplingIsAttached[hoseType] = true;
								
								if self.hydraulicPlayerAttached then
									Cylindered.setDirty(self, part);
								end;
							else
								break;
							end;
						end;
					end;
				end;
				
				HydraulicCoupling.updateLightCouplings(self, true, true);
				HydraulicCoupling.updateMovingToolCouplings(self, true);
			end;
			
			CouplingEvent.sendEvent(self, 0, vehicle, jointDescIndex, noEventSend);
		end;
	end;
end;

function HydraulicCoupling:detachHydraulicCoupling(noEventSend)
	local joint = self.attacherJoint;
	
	if joint ~= nil then
		if joint.attachedCouplings ~= nil then
			joint.attachedCouplings = nil;
			HydraulicCoupling.updateLightCouplings(self, false, true);
			
			for hoseType in pairs(HydraulicCoupling.hoseTypes) do
				for i, v in pairs(joint.hydraulicCouplings[hoseType]) do
					setVisibility(v.attachedCoupling, false);
					setVisibility(v.detachedCoupling, true);
					
					self.hydraulicCouplingIsAttached[hoseType] = false;
					
					if v.oldRefFrame ~= nil then
						self.movingParts[v.movingPartIndice].referenceFrame = v.oldRefFrame;
					end;
				end;
			end;
			
			HydraulicCoupling.updateMovingToolCouplings(self, false);
		end;
		
		CouplingEvent.sendEvent(self, 1, nil, nil, noEventSend);
	end;
end;

function HydraulicCoupling.updateLightCouplings(self, synch, event)
	if self.enableElectrics then
		local rootAttacherVehicle = self.attacherVehicle; -- self:getRootAttacherVehicle();
		
		if synch and self:isHoseTypeAttached("electric") and rootAttacherVehicle ~= nil then
			self:setLightsTypesMask(rootAttacherVehicle.lightsTypesMask, event);
			self:setTurnSignalState(rootAttacherVehicle.turnSignalState, event);
			self:setBeaconLightsVisibility(rootAttacherVehicle.beaconLightsActive, event);
			self:setReverseLightsVisibility(rootAttacherVehicle.reverseLightsActive, event);
		else
			self:setLightsTypesMask(0, event);
			self:setTurnSignalState(0, event);
			self:setBrakeLightsVisibility(false, event);
			self:setBeaconLightsVisibility(false, event);
			self:setReverseLightsVisibility(false, event);
		end;
	end;
end;

function HydraulicCoupling.updateMovingToolCouplings(self, attaching)
	for id, v in ipairs(self.movingToolCouplings) do
		local tool = self.movingTools[v];
		if tool.axisActionIndex ~= nil then
			tool.isActive = attaching;
			
			if not attaching then
				tool.lastRotSpeed = 0;
				tool.lastTransSpeed = 0;
			end;
		end;
	end;
end;

function HydraulicCoupling:isHoseTypeAttached(hoseType)
	if self.hydraulicCouplingIsAttached[hoseType] ~= nil then
		if self.attacherVehicle ~= nil then
			if self.attacherVehicle.hydraulicSupport ~= nil and self.attacherVehicle.hydraulicSupport then
				if self.attacherVehicle.isHoseTypeAttached ~= nil then
					return self.hydraulicCouplingIsAttached[hoseType] and self.attacherVehicle:isHoseTypeAttached(hoseType);
				else
					return self.hydraulicCouplingIsAttached[hoseType];
				end;
			else
				return true; -- attacherVehicle don't support hoses, make it work anyhow
			end;
		end;
	end;
	
	return false;
end;


-- Override
function HydraulicCoupling:getIsFoldAllowed(oldFunc)
	if self:isHoseTypeAttached("hydraulic") then
		if oldFunc ~= nil then
			return oldFunc(self);
		end;
	end;
	
	return false
end;

function HydraulicCoupling:setJointMoveDown(oldFunc, jointDescIndex, moveDown, noEventSend)
	if self:isHoseTypeAttached("hydraulic") then
		if oldFunc ~= nil then
			oldFunc(self, jointDescIndex, moveDown, noEventSend)
		end;
	else
		if g_i18n:hasText("COUPLING_ERROR") and self:getIsActiveForInput() then
			g_currentMission:showBlinkingWarning(g_i18n:getText("COUPLING_ERROR"), 1000);
		end;
	end;
end;

function HydraulicCoupling:setLightsTypesMask(oldFunc, lightsTypesMask, noEventSend)
	if self:isHoseTypeAttached("electric") then
		if oldFunc ~= nil and type(oldFunc) == "function" then
			oldFunc(self, lightsTypesMask, noEventSend);
		end;
	else
		if lightsTypesMask ~= nil and type(lightsTypesMask) == "number" then
			self.lastValueUpdates["updateLights"] = lightsTypesMask > 0;
		end;
	end;
end;

function HydraulicCoupling:setBrakeLightsVisibility(oldFunc, isActive, noEventSend)
	if self:isHoseTypeAttached("electric") then
		if oldFunc ~= nil and type(oldFunc) == "function" then
			oldFunc(self, isActive, noEventSend);
		end;
	end;
end

function HydraulicCoupling:setBeaconLightsVisibility(oldFunc, isActive, noEventSend)
	if self:isHoseTypeAttached("electric") then
		if oldFunc ~= nil and type(oldFunc) == "function" then
			oldFunc(self, isActive, noEventSend);
		end;
	else
		if isActive ~= nil then
			self.lastValueUpdates["updateBeacons"] = isActive;
		end;
	end;
end;



-- Event
CouplingEvent = {};

CouplingEvent.ATTACH_HOSE = 0;
CouplingEvent.DETACH_HOSE = 1;
CouplingEvent.NUM_BITS = 1;

CouplingEvent_mt = Class(CouplingEvent, Event);

InitEventClass(CouplingEvent, "CouplingEvent");

function CouplingEvent:emptyNew()
    local self = Event:new(CouplingEvent_mt);
    self.className = "CouplingEvent";
	
    return self;
end;

function CouplingEvent:new(object, eventType, vehicle, jointDescIndex)
    local self = CouplingEvent:emptyNew();
    self.object = object;
    self.eventType = eventType;
    self.vehicle = vehicle;
	self.jointDescIndex = jointDescIndex;
	
    return self;
end;

function CouplingEvent:readStream(streamId, connection)
	local id = streamReadInt32(streamId);
	self.object = networkGetObject(id);
	self.eventType = streamReadUIntN(streamId, CouplingEvent.NUM_BITS);
	
	if self.eventType == CouplingEvent.ATTACH_HOSE then
		local vehicleId = streamReadInt32(streamId);
		self.vehicle = networkGetObject(vehicleId);
		self.jointDescIndex = streamReadInt8(streamId);
	end;
	
    self:run(connection);
end;

function CouplingEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, networkGetObjectId(self.object));
	streamWriteUIntN(streamId, self.eventType, CouplingEvent.NUM_BITS);
	
	if self.eventType == CouplingEvent.ATTACH_HOSE then
		streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
		streamWriteInt8(streamId, self.jointDescIndex);
	end;
end;

function CouplingEvent:run(connection)
	if self.eventType == CouplingEvent.ATTACH_HOSE then
		self.object:attachHydraulicCoupling(self.vehicle, self.jointDescIndex, true);
	elseif self.eventType == CouplingEvent.DETACH_HOSE then
		self.object:detachHydraulicCoupling(true);
	end;
	
	if not connection:getIsServer() then
		g_server:broadcastEvent(CouplingEvent:new(self.object, self.eventType, self.vehicle, self.jointDescIndex), nil, connection, self.object);
	end;
end;

function CouplingEvent.sendEvent(object, eventType, vehicle, jointDescIndex, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(CouplingEvent:new(object, eventType, vehicle, jointDescIndex), nil, nil, object);
		else
			g_client:getServerConnection():sendEvent(CouplingEvent:new(object, eventType, vehicle, jointDescIndex));
		end;
	end;
end;
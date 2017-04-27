--
-- SetCoverEdgeDoorPanelEvent
--
-- @author:    	Fcelsa - Peppe978
-- @history:	v1.0  - 01.08.2016

-- 

SetCoverEdgeDoorPanelEvent = {};
SetCoverEdgeDoorPanelEvent_mt = Class(SetCoverEdgeDoorPanelEvent, Event);

InitEventClass(SetCoverEdgeDoorPanelEvent, "SetCoverEdgeDoorPanelEvent");

function SetCoverEdgeDoorPanelEvent:emptyNew()
	local self = Event:new(SetCoverEdgeDoorPanelEvent_mt);
	self.className="SetCoverEdgeDoorPanelEvent";
	return self;
end;

function SetCoverEdgeDoorPanelEvent:new(vehicle, isCoverEdgeDoorState)
	local self = SetCoverEdgeDoorPanelEvent:emptyNew()
	self.vehicle = vehicle;
	self.isCoverEdgeDoorPanelState = isCoverEdgeDoorState;
	return self;
end;

function SetCoverEdgeDoorPanelEvent:readStream(streamId, connection)
	local id = streamReadInt32(streamId);
	self.isCoverEdgeDoorPanelState = streamReadBool(streamId);
	self.vehicle = networkGetObject(id);
	self:run(connection);
end;

function SetCoverEdgeDoorPanelEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
	streamWriteBool(streamId, self.isCoverEdgeDoorPanelState);
end;

function SetCoverEdgeDoorPanelEvent:run(connection)
	self.vehicle:SetCoverEdgeDoorPanel(self.isCoverEdgeDoorPanelState, true);
	if not connection:getIsServer() then
		g_server:broadcastEvent(SetCoverEdgeDoorPanelEvent:new(self.vehicle, self.isCoverEdgeDoorPanelState), nil, connection, self.vehicle);
	end;
end;

function SetCoverEdgeDoorPanelEvent.sendEvent(vehicle, isCoverEdgeDoorState, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetCoverEdgeDoorPanelEvent:new(vehicle, isCoverEdgeDoorState), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(SetCoverEdgeDoorPanelEvent:new(vehicle, isCoverEdgeDoorState));
		end;
	end;
end;

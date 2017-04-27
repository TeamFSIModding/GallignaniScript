--
-- SetIncreaseBaleSizeEvent
--
-- @author:    	Fcelsa - Peppe978
-- @history:	v1.0  - 01.08.2016

-- 



SetSideDoorPanelEvent = {};
SetSideDoorPanelEvent_mt = Class(SetSideDoorPanelEvent, Event);

InitEventClass(SetSideDoorPanelEvent, "SetSideDoorPanelEvent");

function SetSideDoorPanelEvent:emptyNew()
	local self = Event:new(SetSideDoorPanelEvent_mt);
	self.className="SetSideDoorPanelEvent";
	return self;
end;

function SetSideDoorPanelEvent:new(vehicle, isSideDoorState)
	local self = SetSideDoorPanelEvent:emptyNew()
	self.vehicle = vehicle;
	self.isSideDoorPanelState = isSideDoorState;
	return self;
end;

function SetSideDoorPanelEvent:readStream(streamId, connection)
	local id = streamReadInt32(streamId);
	self.isSideDoorPanelState = streamReadBool(streamId);
	self.vehicle = networkGetObject(id);
	self:run(connection);
end;

function SetSideDoorPanelEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
	streamWriteBool(streamId, self.isSideDoorPanelState);
end;

function SetSideDoorPanelEvent:run(connection)
	self.vehicle:SetSideDoorPanel(self.isSideDoorPanelState, true);
	if not connection:getIsServer() then
		g_server:broadcastEvent(SetSideDoorPanelEvent:new(self.vehicle, self.isSideDoorPanelState), nil, connection, self.vehicle);
	end;
end;

function SetSideDoorPanelEvent.sendEvent(vehicle, isSideDoorState, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetSideDoorPanelEvent:new(vehicle, isSideDoorState), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(SetSideDoorPanelEvent:new(vehicle, isSideDoorState));
		end;
	end;
end;

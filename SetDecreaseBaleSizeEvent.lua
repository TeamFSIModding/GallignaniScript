--
-- SetDecreaseBaleSizeEvent
--
-- @author:    	Fcelsa - Peppe978
-- @history:	v1.0  - 01.08.2016

-- 


SetDecreaseBaleSizeEvent = {};
SetDecreaseBaleSizeEvent_mt = Class(SetDecreaseBaleSizeEvent, Event);

InitEventClass(SetDecreaseBaleSizeEvent, "SetDecreaseBaleSizeEvent");

function SetDecreaseBaleSizeEvent:emptyNew()
	local self = Event:new(SetDecreaseBaleSizeEvent_mt);
	self.className="SetDecreaseBaleSizeEvent";
	return self;
end;

function SetDecreaseBaleSizeEvent:new(vehicle, decreaseBaleSize)
	local self = SetDecreaseBaleSizeEvent:emptyNew()
	self.vehicle = vehicle;
	self.decreaseBaleSize = decreaseBaleSize;
	return self;
end;

function SetDecreaseBaleSizeEvent:readStream(streamId, connection)
	local id = streamReadInt32(streamId);
	self.decreaseBaleSize = streamReadBool(streamId);
	self.vehicle = networkGetObject(id);
	self:run(connection);
end;

function SetDecreaseBaleSizeEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
	streamWriteBool(streamId, self.decreaseBaleSize);
end;

function SetDecreaseBaleSizeEvent:run(connection)
	self.vehicle:setDecreaseBaleSize(self.decreaseBaleSize, true);
	if not connection:getIsServer() then
		g_server:broadcastEvent(SetDecreaseBaleSizeEvent:new(self.vehicle, self.decreaseBaleSize), nil, connection, self.vehicle);
	end;
end;

function SetDecreaseBaleSizeEvent.sendEvent(vehicle, decreaseBaleSize, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetDecreaseBaleSizeEvent:new(vehicle, decreaseBaleSize), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(SetDecreaseBaleSizeEvent:new(vehicle, decreaseBaleSize));
		end;
	end;
end;

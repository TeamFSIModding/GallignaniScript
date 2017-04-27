--
-- SetIncreaseBaleSizeEvent
--
-- @author:    	Fcelsa - Peppe978
-- @history:	v1.0  - 01.08.2016

-- 


SetIncreaseBaleSizeEvent = {};
SetIncreaseBaleSizeEvent_mt = Class(SetIncreaseBaleSizeEvent, Event);

InitEventClass(SetIncreaseBaleSizeEvent, "SetIncreaseBaleSizeEvent");

function SetIncreaseBaleSizeEvent:emptyNew()
	local self = Event:new(SetIncreaseBaleSizeEvent_mt);
	self.className="SetIncreaseBaleSizeEvent";
	return self;
end;

function SetIncreaseBaleSizeEvent:new(vehicle, increaseBaleSize)
	local self = SetIncreaseBaleSizeEvent:emptyNew()
	self.vehicle = vehicle;
	self.increaseBaleSize = increaseBaleSize;
	return self;
end;

function SetIncreaseBaleSizeEvent:readStream(streamId, connection)
	local id = streamReadInt32(streamId);
	self.increaseBaleSize = streamReadBool(streamId);
	self.vehicle = networkGetObject(id);
	self:run(connection);
end;

function SetIncreaseBaleSizeEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, networkGetObjectId(self.vehicle));
	streamWriteBool(streamId, self.increaseBaleSize);
end;

function SetIncreaseBaleSizeEvent:run(connection)
	self.vehicle:setIncreaseBaleSize(self.increaseBaleSize, true);
	if not connection:getIsServer() then
		g_server:broadcastEvent(SetIncreaseBaleSizeEvent:new(self.vehicle, self.increaseBaleSize), nil, connection, self.vehicle);
	end;
end;

function SetIncreaseBaleSizeEvent.sendEvent(vehicle, increaseBaleSize, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetIncreaseBaleSizeEvent:new(vehicle, increaseBaleSize), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(SetIncreaseBaleSizeEvent:new(vehicle, increaseBaleSize));
		end;
	end;
end;

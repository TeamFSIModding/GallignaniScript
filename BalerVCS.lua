--
-- BalerVCS
-- Class for Baler Variable Chambers Semplified - work with default FS15 Baler.lua
--
-- @author  fcelsa
-- @date  28/05/2016
--

BalerVCS = {};

function BalerVCS.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Baler, specializations);
end;

function BalerVCS.supportedBales(thesize)
	-- per il momento specificare qui le dimensioni delle balle fattibili dall'imballatrice.
	if thesize == 80 or thesize == 100 or thesize == 120 or thesize == 140 or thesize == 160 then
		return true
	else
		return false
	end;
end;

function BalerVCS:load(xmlFile)
	-- debug check type of bales 
	--local numberOfBT = table.getn(self.baleTypes);
	--if numberOfBT >= 1 then
	--	print("BalerVCS debug: numero di balle registrate "..tostring(numberOfBT));
	--	for k, v in pairs(self.baleTypes) do
	--		print("BalerVCS debug: bale "..k.."  "..v.diameter);
	--	end;
	--end;

	self.setIncreaseBaleSize = SpecializationUtil.callSpecializationsFunction("setIncreaseBaleSize");
	self.setDecreaseBaleSize = SpecializationUtil.callSpecializationsFunction("setDecreaseBaleSize");
	--self.setNetBale = SpecializationUtil.callSpecializationsFunction("setNetBale");
	--self.setNetBaleSize = SpecializationUtil.callSpecializationsFunction("setNetBaleSize");

	self.BALE_60CM = 60;
	self.BALE_80CM = 80;
	self.BALE_100CM = 100;
	self.BALE_120CM = 120;
	self.BALE_140CM = 140;
	self.BALE_160CM = 160;
	self.BALE_ORIGINAL = 180;

	self.currentBaleSize = self.BALE_ORIGINAL;
	
	self.originalBaleCapacity = self.capacity;
	self.baleCapacities = {}
	self.baleCapacities[1] = (self.originalBaleCapacity*0.33);
	self.baleCapacities[2] = (self.originalBaleCapacity*0.44);
	self.baleCapacities[3] = (self.originalBaleCapacity*0.56);
	self.baleCapacities[4] = (self.originalBaleCapacity*0.67);
	self.baleCapacities[5] = (self.originalBaleCapacity*0.80);
	self.baleCapacities[6] = (self.originalBaleCapacity*0.90);
	self.baleCapacities[7] = self.originalBaleCapacity;

	self.isUnloadingPlaying = false;
	self.unloadingAnimTime = 0;

	self.netBale = false;
	self.currentBaleSizeSaved = nil;
	self.capacitySaved = nil;

	self.lastUsedFruitType = nil;

	-- determina la prima dimensione possibile supportata
	local supported = BalerVCS.supportedBales(self.currentBaleSize);
	if supported == false then 
		if table.getn(self.bales) == 0 then
			self:setDecreaseBaleSize(not decreaseBaleSize);
		end;
	end;
end;


function BalerVCS:delete()
end;

function BalerVCS:readStream(streamId, connection)
	--self.canNet = streamReadBool(streamId);
	local increaseBaleSize = streamReadBool(streamId);
	self:setIncreaseBaleSize(increaseBaleSize, true);
	local decreaseBaleSize = streamReadBool(streamId);
	self:setDecreaseBaleSize(decreaseBaleSize, true);
	--local netBale = streamReadBool(streamId);
	--self:setNetBale(netBale, true);
	self.currentBaleSize = streamReadInt16(streamId);
end;

function BalerVCS:writeStream(streamId, connection)
	--streamWriteBool(streamId, self.canNet);
	streamWriteBool(streamId, self.increaseBaleSize);
	streamWriteBool(streamId, self.decreaseBaleSize);
	--streamWriteBool(streamId, self.netBale);
	streamWriteInt16(streamId, self.currentBaleSize);
	-- forse ci serve come esempio...
	--streamWriteInt16(streamId, table.getn(self.bales));
	--for i=1, table.getn(self.bales) do
	--	local bale = self.bales[i];
	--	streamWriteInt8(streamId, bale.fruitType);
	--	if self.baleAnimCurve ~= nil then
	--		streamWriteFloat32(streamId, bale.time);
	--	end;
	--end;

end;

function BalerVCS:readUpdateStream(streamId, timestamp, connection)
end;

function BalerVCS:writeUpdateStream(streamId, connection, dirtyMask)
end;

function BalerVCS:mouseEvent(posX, posY, isDown, isUp, button)
end;

function BalerVCS:keyEvent(unicode, sym, modifier, isDown)
end;

function BalerVCS:update(dt)

	if self:getIsActiveForInput() then
		
		if InputBinding.hasEvent(InputBinding.INCREASE_BALESIZE) then
			if self.currentBaleSize < self.BALE_ORIGINAL then
				if table.getn(self.bales) == 0 then
					self:setIncreaseBaleSize(not self.increaseBaleSize);
				end;
			end;
		end;

		if InputBinding.hasEvent(InputBinding.DECREASE_BALESIZE) then
			if self.currentBaleSize > self.BALE_60CM then
				if table.getn(self.bales) == 0 then
					self:setDecreaseBaleSize(not decreaseBaleSize);
				end;
			end;
		end;
	end;
end;

function BalerVCS:updateTick(dt)
end;

function BalerVCS:draw()
	
	if table.getn(self.bales) == 0 then
		if self.currentBaleSize ~= nil then
			local decrease = InputBinding.getKeyNamesOfDigitalAction(InputBinding.DECREASE_BALESIZE);
			local increase = InputBinding.getKeyNamesOfDigitalAction(InputBinding.INCREASE_BALESIZE);
			g_currentMission:addExtraPrintText(string.format(g_i18n:getText("CURRENT_BALESIZE"), self.currentBaleSize, decrease, increase));
		end;
	end;

	local supported = BalerVCS.supportedBales(self.currentBaleSize);
	if supported == false then 
		g_currentMission:addWarning(g_i18n:getText("DIA_NOT_SUPPORTED"));
		self:setPickupState(false, true);
	end;

end;

function BalerVCS:onAttach(attacherVehicle)
end;

function BalerVCS:onDetach()
end;


function BalerVCS:setIncreaseBaleSize(increaseBaleSize, noEventSend)
	SetIncreaseBaleSizeEvent.sendEvent(self, increaseBaleSize, noEventSend);
	self.increaseBaleSize = increaseBaleSize;

	if self.increaseBaleSize == true then
		self.currentBaleSize = self.currentBaleSize+20;
		self.increaseBaleSize = false;
	end;
	if self.currentBaleSize == self.BALE_60CM then
		self.capacity = self.baleCapacities[1];
		self.currentBaleTypeId = 7;
	elseif self.currentBaleSize == self.BALE_80CM then
		self.capacity = self.baleCapacities[2];
		self.currentBaleTypeId = 6;
	elseif self.currentBaleSize == self.BALE_100CM then
		self.capacity = self.baleCapacities[3];
		self.currentBaleTypeId = 5;
	elseif self.currentBaleSize == self.BALE_120CM then
		self.capacity = self.baleCapacities[4];
		self.currentBaleTypeId = 4;
	elseif self.currentBaleSize == self.BALE_140CM then
		self.capacity = self.baleCapacities[5];
		self.currentBaleTypeId = 3;
	elseif self.currentBaleSize == self.BALE_160CM then
		self.capacity = self.baleCapacities[6];
		self.currentBaleTypeId = 2;
	elseif self.currentBaleSize == self.BALE_ORIGINAL then
		self.capacity = self.baleCapacities[7];
		self.currentBaleTypeId = 1;
	else
		print("No baleSize aquired!");
	end;
	-- print("BalerVCS debug: increase event - baleTypeID = "..tostring(self.currentBaleTypeId).."  "..tostring(self.capacity));

end;

function BalerVCS:setDecreaseBaleSize(decreaseBaleSize, noEventSend)
	SetDecreaseBaleSizeEvent.sendEvent(self, decreaseBaleSize, noEventSend);
	self.decreaseBaleSize = decreaseBaleSize;

	local i = 1;
	for i=1, 7 do
		if self.baleCapacities[i] == self.capacity then
			self.currentArrayPlace = i;
		end;
		i = i+1;
	end;

	if self.decreaseBaleSize == true then
		if self.fillLevel > self.baleCapacities[self.currentArrayPlace-1] then
			print("Cannot lower baleSize");
			--TO-DO: Implement warningtext
			-- la camera è più piena di quanto è il fillLevel della balla selezionata.
		else
			self.currentBaleSize = self.currentBaleSize-20;
		end;
		self.decreaseBaleSize = false;
	end;

	if self.currentBaleSize == self.BALE_60CM then
		self.capacity = self.baleCapacities[1];
		self.currentBaleTypeId = 7;
	elseif self.currentBaleSize == self.BALE_80CM then
		self.capacity = self.baleCapacities[2];
		self.currentBaleTypeId = 6;
	elseif self.currentBaleSize == self.BALE_100CM then
		self.capacity = self.baleCapacities[3];
		self.currentBaleTypeId = 5;
	elseif self.currentBaleSize == self.BALE_120CM then
		self.capacity = self.baleCapacities[4];
		self.currentBaleTypeId = 4;
	elseif self.currentBaleSize == self.BALE_140CM then
		self.capacity = self.baleCapacities[5];
		self.currentBaleTypeId = 3;
	elseif self.currentBaleSize == self.BALE_160CM then
		self.capacity = self.baleCapacities[6];
		self.currentBaleTypeId = 2;
	elseif self.currentBaleSize == self.BALE_ORIGINAL then
		self.capacity = self.baleCapacities[7];
		self.currentBaleTypeId = 1;
	else
		print("No baleSize aquired!");
	end;

	-- print("BalerVCS debug: decrease event - baleTypeID = "..tostring(self.currentBaleTypeId).."  "..tostring(self.capacity));
	
end;


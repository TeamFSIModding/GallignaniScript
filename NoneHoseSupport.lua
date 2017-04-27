--
-- NoneHoseSupport
--
-- @author:    	Xentro (Marcus@Xentro.se)
-- @website:	www.Xentro.se
-- @history:	v1.0 - 2016-08-27 - Initial implementation
-- 

NoneHoseSupport = {};

function NoneHoseSupport.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(HydraulicCoupling, specializations);
end;

function NoneHoseSupport:load(xmlFile)

end;

function NoneHoseSupport:delete()
end;

function NoneHoseSupport:readStream(streamId, connection)
end;

function NoneHoseSupport:writeStream(streamId, connection)
end;

function NoneHoseSupport:mouseEvent(posX, posY, isDown, isUp, button)
end;

function NoneHoseSupport:keyEvent(unicode, sym, modifier, isDown)
end;

function NoneHoseSupport:update(dt)
end;

function NoneHoseSupport:updateTick(dt)
end;

function NoneHoseSupport:draw()
end;

function NoneHoseSupport:onAttach(vehicle)
	if vehicle.HydraulicRefs == nil then
		NoneHoseSupport.setHoseVisibility(self, false);
	end;
end;

function NoneHoseSupport:onDetach(vehicle)
	if vehicle.HydraulicRefs == nil then
		NoneHoseSupport.setHoseVisibility(self, true);
	end;
end;


function NoneHoseSupport:setHoseVisibility(state)
	for hoseType, allowed in pairs(HydraulicCoupling.hoseTypes) do
		local joint = self.attacherJoint;
		
		for i, v in pairs(joint.hydraulicCouplings[hoseType]) do
			setVisibility(v.detachedCoupling, state);
		end;
	end;
end;
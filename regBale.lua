--
-- regBale
--
-- @author:    	Fcelsa - Peppe978
-- @history:	v1.0  - 01.08.2016

-- 

regBale = {};
addModEventListener(regBale);
local baleregpath = g_currentModDirectory;
function regBale.prerequisitesPresent(specializations)
    return true;
end;

function regBale:loadMap(name)
	local key18w = BaleUtil.getBaleKey("wheat_windrow", 1.2, nil, nil, 1.8, true);
	local key18b = BaleUtil.getBaleKey("barley_windrow", 1.2, nil, nil, 1.8, true);
	local key18h = BaleUtil.getBaleKey("dryGrass_windrow", 1.2, nil, nil, 1.8, true);
	local key18g = BaleUtil.getBaleKey("grass_windrow", 1.2, nil, nil, 1.8, true);
	local key16w = BaleUtil.getBaleKey("wheat_windrow", 1.2, nil, nil, 1.6, true);
	local key16b = BaleUtil.getBaleKey("barley_windrow", 1.2, nil, nil, 1.6, true);
	local key16h = BaleUtil.getBaleKey("dryGrass_windrow", 1.2, nil, nil, 1.6, true);
	local key16g = BaleUtil.getBaleKey("grass_windrow", 1.2, nil, nil, 1.6, true);
	local key14w = BaleUtil.getBaleKey("wheat_windrow", 1.2, nil, nil, 1.4, true);
	local key14b = BaleUtil.getBaleKey("barley_windrow", 1.2, nil, nil, 1.4, true);
	local key14h = BaleUtil.getBaleKey("dryGrass_windrow", 1.2, nil, nil, 1.4, true);
	local key14g = BaleUtil.getBaleKey("grass_windrow", 1.2, nil, nil, 1.4, true);
	local key12w = BaleUtil.getBaleKey("wheat_windrow", 1.2, nil, nil, 1.2, true);
	local key12b = BaleUtil.getBaleKey("barley_windrow", 1.2, nil, nil, 1.2, true);
	local key12h = BaleUtil.getBaleKey("dryGrass_windrow", 1.2, nil, nil, 1.2, true);
	local key12g = BaleUtil.getBaleKey("grass_windrow", 1.2, nil, nil, 1.2, true);
	local key10w = BaleUtil.getBaleKey("wheat_windrow", 1.2, nil, nil, 1.0, true);
	local key10b = BaleUtil.getBaleKey("barley_windrow", 1.2, nil, nil, 1.0, true);
	local key10h = BaleUtil.getBaleKey("dryGrass_windrow", 1.2, nil, nil, 1.0, true);
	local key10g = BaleUtil.getBaleKey("grass_windrow", 1.2, nil, nil, 1.0, true);
	local key08w = BaleUtil.getBaleKey("wheat_windrow", 1.2, nil, nil, 0.8, true);
	local key08b = BaleUtil.getBaleKey("barley_windrow", 1.2, nil, nil, 0.8, true);
	local key08h = BaleUtil.getBaleKey("dryGrass_windrow", 1.2, nil, nil, 0.8, true);
	local key08g = BaleUtil.getBaleKey("grass_windrow", 1.2, nil, nil, 0.8, true);
	--local key06w = BaleUtil.getBaleKey("wheat_windrow", 1.2, nil, nil, 0.6, true);
	--local key06b = BaleUtil.getBaleKey("barley_windrow", 1.2, nil, nil, 0.6, true);
	--local key06h = BaleUtil.getBaleKey("dryGrass_windrow", 1.2, nil, nil, 0.6, true);
	--local key06g = BaleUtil.getBaleKey("grass_windrow", 1.2, nil, nil, 0.6, true);


	if BaleUtil[key18w] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw180.i3d"), "wheat_windrow", 1.2, nil, nil, 1.8, true)
		print(">>> round 120x180cm wheat_windrow bales registered")
	else
		print("<<< round 120x180cm wheat_windrow bales already exist")
	end;

	if BaleUtil[key18b] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw180.i3d"), "barley_windrow", 1.2, nil, nil, 1.8, true)
		print(">>> round 120x180cm barley_windrow bales registered")
	else
		print("<<< round 120x180cm barley_windrow bales already exist")
	end;

	if BaleUtil[key18h] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Hay/roundBaleHay180.i3d"), "dryGrass_windrow", 1.2, nil, nil, 1.8, true)
		print(">>> round 120x180cm dryGrass_windrow bales registered")
	else
		print("<<< round 120x180cm dryGrass_windrow bales already exist")
	end;

	if BaleUtil[key18g] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Silage/roundBaleSilage180.i3d"), "grass_windrow", 1.2, nil, nil, 1.8, true)
		print(">>> round 120x180cm grass_windrow bales registered")
	else
		print("<<< round 120x180cm grass_windrow bales already exist")
	end;

	if BaleUtil[key16w] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw160.i3d"), "wheat_windrow", 1.2, nil, nil, 1.6, true)
		print(">>> round 120x160cm wheat_windrow bales registered")
	else
		print("<<< round 120x160cm wheat_windrow bales already exist")
	end;

	if BaleUtil[key16b] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw160.i3d"), "barley_windrow", 1.2, nil, nil, 1.6, true)
		print(">>> round 120x160cm barley_windrow bales registered")
	else
		print("<<< round 120x160cm barley_windrow bales already exist")
	end;

	if BaleUtil[key16h] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Hay/roundBaleSilage160.i3d"), "dryGrass_windrow", 1.2, nil, nil, 1.6, true)
		print(">>> round 120x160cm dryGrass_windrow bales registered")
	else
		print("<<< round 120x160cm dryGrass_windrow bales already exist")
	end;

	if BaleUtil[key16g] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Silage/roundBaleHay160.i3d"), "grass_windrow", 1.2, nil, nil, 1.6, true)
		print(">>> round 120x160cm grass_windrow bales registered")
	else
		print("<<< round 120x160cm grass_windrow bales already exist")
	end;

	if BaleUtil[key14w] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw140.i3d"), "wheat_windrow", 1.2, nil, nil, 1.4, true)
		print(">>> round 120x140cm wheat_windrow bales registered")
	else
		print("<<< round 120x140cm wheat_windrow bales already exist")
	end;

	if BaleUtil[key14b] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw140.i3d"), "barley_windrow", 1.2, nil, nil, 1.4, true)
		print(">>> round 120x140cm barley_windrow bales registered")
	else
		print("<<< round 120x140cm barley_windrow bales already exist")
	end;

	if BaleUtil[key14h] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Hay/roundBaleHay140.i3d"), "dryGrass_windrow", 1.2, nil, nil, 1.4, true)
		print(">>> round 120x140cm dryGrass_windrow bales registered")
	else
		print("<<< round 120x140cm dryGrass_windrow bales already exist")
	end;

	if BaleUtil[key14g] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Silage/roundBaleSilage140.i3d"), "grass_windrow", 1.2, nil, nil, 1.4, true)
		print(">>> round 120x140cm grass_windrow bales registered")
	else
		print("<<< round 120x140cm grass_windrow bales already exist")
	end;

	if BaleUtil[key12w] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw120.i3d"), "wheat_windrow", 1.2, nil, nil, 1.2, true)
		print(">>> round 120x120cm wheat_windrow bales registered")
	else
		print("<<< round 120x120cm wheat_windrow bales already exist")
	end;

	if BaleUtil[key12b] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw120.i3d"), "barley_windrow", 1.2, nil, nil, 1.2, true)
		print(">>> round 120x120cm barley_windrow bales registered")
	else
		print("<<< round 120x120cm barley_windrow bales already exist")
	end;

	if BaleUtil[key12h] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Hay/roundBaleHay120.i3d"), "dryGrass_windrow", 1.2, nil, nil, 1.2, true)
		print(">>> round 120x120cm dryGrass_windrow bales registered")
	else
		print("<<< round 120x120cm dryGrass_windrow bales already exist")
	end;

	if BaleUtil[key12g] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Silage/roundBaleSilage120.i3d"), "grass_windrow", 1.2, nil, nil, 1.2, true)
		print(">>> round 120x120cm grass_windrow bales registered")
	else
		print("<<< round 120x120cm grass_windrow bales already exist")
	end;

	if BaleUtil[key10w] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw100.i3d"), "wheat_windrow", 1.2, nil, nil, 1.0, true)
		print(">>> round 120x100cm wheat_windrow bales registered")
	else
		print("<<< round 120x100cm wheat_windrow bales already exist")
	end;

	if BaleUtil[key10b] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw100.i3d"), "barley_windrow", 1.2, nil, nil, 1.0, true)
		print(">>> round 120x100cm barley_windrow bales registered")
	else
		print("<<< round 120x100cm barley_windrow bales already exist")
	end;

	if BaleUtil[key10h] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Hay/roundBaleHay100.i3d"), "dryGrass_windrow", 1.2, nil, nil, 1.0, true)
		print(">>> round 120x100cm dryGrass_windrow bales registered")
	else
		print("<<< round 120x100cm dryGrass_windrow bales already exist")
	end;

	if BaleUtil[key10g] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Silage/roundBaleSilage100.i3d"), "grass_windrow", 1.2, nil, nil, 1.0, true)
		print(">>> round 120x100cm grass_windrow bales registered")
	else
		print("<<< round 120x100cm grass_windrow bales already exist")
	end;

	if BaleUtil[key08w] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw80.i3d"), "wheat_windrow", 1.2, nil, nil, 0.8, true)
		print(">>> round 120x80cm wheat_windrow bales registered")
	else
		print("<<< round 120x80cm wheat_windrow bales already exist")
	end;

	if BaleUtil[key08b] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw80.i3d"), "barley_windrow", 1.2, nil, nil, 0.8, true)
		print(">>> round 120x80cm barley_windrow bales registered")
	else
		print("<<< round 120x80cm barley_windrow bales already exist")
	end;

	if BaleUtil[key08h] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Hay/roundBaleHay80.i3d"), "dryGrass_windrow", 1.2, nil, nil, 0.8, true)
		print(">>> round 120x80cm dryGrass_windrow bales registered")
	else
		print("<<< round 120x80cm dryGrass_windrow bales already exist")
	end;

	if BaleUtil[key08g] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Silage/roundBaleSilage80.i3d"), "grass_windrow", 1.2, nil, nil, 0.8, true)
		print(">>> round 120x80cm grass_windrow bales registered")
	else
		print("<<< round 120x80cm grass_windrow bales already exist")
	end;

	--[[ 
	if BaleUtil[key06w] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw80.i3d"), "wheat_windrow", 1.2, nil, nil, 0.6, true)
		print(">>> round 120x60cm wheat_windrow bales registered")
	else
		print("<<< round 120x60cm wheat_windrow bales already exist")
	end;

	if BaleUtil[key06b] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Straw/roundBaleStraw80.i3d"), "barley_windrow", 1.2, nil, nil, 0.6, true)
		print(">>> round 120x60cm barley_windrow bales registered")
	else
		print("<<< round 120x60cm barley_windrow bales already exist")
	end;

	if BaleUtil[key06h] == nil then
		BaleUtil.registerBaleType(("BalesGallignani/Hay/roundBaleHay80.i3d"), "dryGrass_windrow", 1.2, nil, nil, 0.6, true)
		print(">>> round 120x60cm dryGrass_windrow bales registered")
	else
		print("<<< round 120x60cm dryGrass_windrow bales already exist")
	end;

	if BaleUtil[key06g] == nil then
		BaleUtil.registerBaleType(("Silage/roundBaleSilage80.i3d"), "grass_windrow", 1.2, nil, nil, 0.6, true)
		print(">>> round 120x60cm grass_windrow bales registered")
	else
		print("<<< round 120x60cm grass_windrow bales already exist")
	end;
	--]]

end;

function regBale:deleteMap()
end;

function regBale:mouseEvent(posX, posY, isDown, isUp, button)
end;

function regBale:keyEvent(unicode, sym, modifier, isDown)
end;

function regBale:update(dt)
end;

function regBale:draw()
end;

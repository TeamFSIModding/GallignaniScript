--
-- Gallignani.lua
--
-- fcelsa 05/2016
--
-- oltre alle modifiche specifiche non sono in grado di stabilire con esattezza l'origine dello script anche se
-- gran parte deriva dalla versione del 2013 di KronePickupParticleSystem.lua di Ifko[nator].
--
Gallignani = {};

function Gallignani.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Fillable, specializations);
end;

function Gallignani:load(xmlFile)
    self.GallignaniBaler = SpecializationUtil.callSpecializationsFunction("GallignaniBaler");
    
    self.wheatParticleSystems = {};
    local i = 0;
    while true do
        local key = string.format("vehicle.Gallignani.Straw(%d)", i);
        local node = getXMLString(xmlFile, key .. "#node");
        if node == nil then
            break;
        end;
        node = Utils.indexToObject(self.components, node);
        if node ~= nil then
            local psFile = getXMLString(xmlFile, key .. "#file");
            local wheatParticleSystem = {};
            wheatParticleSystem.particleSystem = {};
            StaticParticleSystem.loadParticleSystem(xmlFile, wheatParticleSystem.particleSystem, key, self.components, false, nil, self.baseDirectory);
            table.insert(self.wheatParticleSystems, wheatParticleSystem);
        end;
        i = i + 1;
    end;
    
    self.dryGrassParticleSystems = {};
    local i = 0;
    while true do
        local key = string.format("vehicle.Gallignani.dryGrass(%d)", i);
        local node = getXMLString(xmlFile, key .. "#node");
        if node == nil then
            break;
        end;
        node = Utils.indexToObject(self.components, node);
        if node ~= nil then
            local psFile = getXMLString(xmlFile, key .. "#file");
            local dryGrassParticleSystem = {};
            dryGrassParticleSystem.particleSystem = {};
            StaticParticleSystem.loadParticleSystem(xmlFile, dryGrassParticleSystem.particleSystem, key, self.components, false, nil, self.baseDirectory);
            table.insert(self.dryGrassParticleSystems, dryGrassParticleSystem);
        end;
        i = i + 1;
    end;
    
    self.grassParticleSystems = {};
    local i = 0;
    while true do
        local key = string.format("vehicle.Gallignani.Grass(%d)", i);
        local node = getXMLString(xmlFile, key .. "#node");
        if node == nil then
            break;
        end;
        node = Utils.indexToObject(self.components, node);
        if node ~= nil then
            local psFile = getXMLString(xmlFile, key .. "#file");
            local grassParticleSystem = {};
            grassParticleSystem.particleSystem = {};
            StaticParticleSystem.loadParticleSystem(xmlFile, grassParticleSystem.particleSystem, key, self.components, false, nil, self.baseDirectory);
            table.insert(self.grassParticleSystems, grassParticleSystem);
        end;
        i = i + 1;
    end;
    
    self.extraParticleSystems = {};
    local i = 0;
    while true do
        local key = string.format("vehicle.Gallignani.extraParticleSystem(%d)", i);
        local node = getXMLString(xmlFile, key .. "#node");
        if node == nil then
            break;
        end;
        node = Utils.indexToObject(self.components, node);
        if node ~= nil then
            local psFile = getXMLString(xmlFile, key .. "#file");
            local extraParticleSystem = {};
            extraParticleSystem.particleSystem = {};
            Utils.loadParticleSystem(xmlFile, extraParticleSystem.particleSystem, key, self.components, false, nil, self.baseDirectory);
            table.insert(self.extraParticleSystems, extraParticleSystem);
        end;
        i = i + 1;
    end;
    
    -- Animated objects --
    self.numRotParts = Utils.getNoNil(getXMLInt(xmlFile, "vehicle.RotParts#count"), 0);
    self.RotParts = {};
    for i = 1, self.numRotParts do
        local RotPartsnamei = string.format("vehicle.RotParts.RotPart" .. "%d", i);
        self.RotParts[i] = Utils.indexToObject(self.components, getXMLString(xmlFile, RotPartsnamei .. "#index"));
    end;
    self.PickupWheel1 = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.PickupWheel1#index"));
    self.PickupWheel2 = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.PickupWheel2#index"));
    self.FeederRoll = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.FeederRoll#index"));
    
    -- Transport Objects --
    self.wheelsInTransportPosition = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.wheelsInTransportPosition#index"));
    self.wheelsInFieldPosition = Utils.indexToObject(self.components, getXMLString(xmlFile, "vehicle.wheelsInFieldPosition#index"));
    
    -- Particles --
    self.PickUpParticleSystems = {};
    local i = 0;
    while true do
        local namei = string.format("vehicle.PickUpParticleSystems.PickUpParticleSystems(%d)", i);
        local nodei = Utils.indexToObject(self.components, getXMLString(xmlFile, namei .. "#index"));
        if nodei == nil then
            break;
        end;
        Utils.loadParticleSystem(xmlFile, self.PickUpParticleSystems, namei, nodei, false, nil, self.baseDirectory)
        i = i + 1;
    end;

end;

function Gallignani:delete()
    for k, wheatParticleSystem in pairs(self.wheatParticleSystems) do
        Utils.setEmittingState(wheatParticleSystem.particleSystem, false);
    end;
    for k, dryGrassParticleSystem in pairs(self.dryGrassParticleSystems) do
        Utils.setEmittingState(dryGrassParticleSystem.particleSystem, false);
    end;
    for k, grassParticleSystem in pairs(self.grassParticleSystems) do
        Utils.setEmittingState(grassParticleSystem.particleSystem, false);
    end;
    for _, extraParticleSystem in pairs(self.extraParticleSystems) do
        Utils.deleteParticleSystem(extraParticleSystem.particleSystem);
    end;
    Utils.deleteParticleSystem(self.PickUpParticleSystems);

end;

function Gallignani:mouseEvent(posX, posY, isDown, isUp, button)
end;

function Gallignani:keyEvent(unicode, sym, modifier, isDown)
end;

function Gallignani:update(dt)
end;

function Gallignani:updateTick(dt)
    
    -- parte aggiunta
    if self:getIsActive() then
        -- Animating the pickup elements --
        if self.isTurnedOn then
            if self.isPickupLowered then
                rotate(self.FeederRoll, 2.5 * self.lastSpeedReal * self.movingDirection * dt, 0, 0);
                self.isBalerSpeedLimitActive = true;
            end;
        end;
        if self.isPickupLowered then
            rotate(self.PickupWheel1, 2.5 * self.lastSpeedReal * self.movingDirection * dt, 0, 0);
            rotate(self.PickupWheel2, 2.5 * self.lastSpeedReal * self.movingDirection * dt, 0, 0);
        end;
        -- Activate particles --
        if self.isTurnedOn and self.movingDirection ~= 0 and self.isPickupLowered then
            Utils.setEmittingState(self.PickUpParticleSystems, true);
        else
            Utils.setEmittingState(self.PickUpParticleSystems, false);
        end;
    end;
    
    -- parte originale
    if self.previousLevel ~= self.fillLevel then
        self.previousLevel = self.fillLevel;
        self:GallignaniBaler(3, true);
    else
        self:GallignaniBaler(3, false);
    end;
end;

function Gallignani:draw()
end;

function Gallignani:GallignaniBaler(mode, state, noEventSend)
    if mode == 3 and self.isTurnedOn then
        if state then
            for _, extraParticleSystem in pairs(self.extraParticleSystems) do
                Utils.setEmittingState(extraParticleSystem.particleSystem, true);
            end;
            if FruitUtil.fillTypeToFruitType[self.currentFillType] == FruitUtil.FRUITTYPE_WHEAT or FruitUtil.fillTypeToFruitType[self.currentFillType] == FruitUtil.FRUITTYPE_BARLEY then
                for k, wheatParticleSystem in pairs(self.wheatParticleSystems) do
                    Utils.setEmittingState(wheatParticleSystem.particleSystem, true);
                end;
            elseif FruitUtil.fillTypeToFruitType[self.currentFillType] == FruitUtil.FRUITTYPE_DRYGRASS then
                for k, dryGrassParticleSystem in pairs(self.dryGrassParticleSystems) do
                    Utils.setEmittingState(dryGrassParticleSystem.particleSystem, true);
                end;
            elseif FruitUtil.fillTypeToFruitType[self.currentFillType] == FruitUtil.FRUITTYPE_GRASS then
                for k, grassParticleSystem in pairs(self.grassParticleSystems) do
                    Utils.setEmittingState(grassParticleSystem.particleSystem, true);
                end;
            end;
        else
            for k, wheatParticleSystem in pairs(self.wheatParticleSystems) do
                Utils.setEmittingState(wheatParticleSystem.particleSystem, false);
            end;
            for k, dryGrassParticleSystem in pairs(self.dryGrassParticleSystems) do
                Utils.setEmittingState(dryGrassParticleSystem.particleSystem, false);
            end;
            for k, grassParticleSystem in pairs(self.grassParticleSystems) do
                Utils.setEmittingState(grassParticleSystem.particleSystem, false);
            end;
            for _, extraParticleSystem in pairs(self.extraParticleSystems) do
                Utils.setEmittingState(extraParticleSystem.particleSystem, false);
            end;
        end;
    else
        for k, wheatParticleSystem in pairs(self.wheatParticleSystems) do
            Utils.setEmittingState(wheatParticleSystem.particleSystem, false);
        end;
        for k, dryGrassParticleSystem in pairs(self.dryGrassParticleSystems) do
            Utils.setEmittingState(dryGrassParticleSystem.particleSystem, false);
        end;
        for k, grassParticleSystem in pairs(self.grassParticleSystems) do
            Utils.setEmittingState(grassParticleSystem.particleSystem, false);
        end;
        for _, extraParticleSystem in pairs(self.extraParticleSystems) do
            Utils.setEmittingState(extraParticleSystem.particleSystem, false);
        end;
    end;
end;


-- StaticParticleSystem ------------------------------------------------------
StaticParticleSystem = {};

function StaticParticleSystem.loadParticleSystem(xmlFile, particleSystemTable, baseString, component, currentEmittingState, defaultParticleSystem, directory)
    local defaultLinkNode = component;
    local isStatic = Utils.getNoNil(isStaticParticle, false);
    local posStr = getXMLString(xmlFile, baseString .. "#position");
    local rotStr = getXMLString(xmlFile, baseString .. "#rotation");
    if type(component) == "table" then
        defaultLinkNode = component[1].node;
    end;
    local linkNode = Utils.getNoNil(Utils.indexToObject(component, getXMLString(xmlFile, baseString .. "#node")), defaultLinkNode);
    local psFile = getXMLString(xmlFile, baseString .. "#file");
    if psFile == nil then
        psFile = defaultParticleSystem;
    end
    if psFile == nil then
        return;
    end
    psFile = Utils.getFilename(psFile, directory);
    local rootNode = loadI3DFile(psFile);
    if rootNode == 0 then
        print("Gallignani.lua : ParticleSystem '" .. psFile .. "' non caricabile - disattivato!");
        return;
    end
    link(linkNode, rootNode);
    if posStr ~= nil and rotStr ~= nil then
        local posX, posY, posZ = Utils.getVectorFromString(posStr);
        local rotX, rotY, rotZ = Utils.getVectorFromString(rotStr);
        if posStr ~= nil and rotStr ~= nil then
            rotX = Utils.degToRad(rotX);
            rotY = Utils.degToRad(rotY);
            rotZ = Utils.degToRad(rotZ);
            setTranslation(rootNode, posX, posY, posZ);
            setRotation(rootNode, rotX, rotY, rotZ);
        end;
    end;
    for i = 0, getNumOfChildren(rootNode) - 1 do
        local child = getChildAt(rootNode, i);
        if getClassName(child) == "Shape" then
            local geometry = getGeometry(child);
            if geometry ~= 0 then
                if getClassName(geometry) == "ParticleSystem" then
                    table.insert(particleSystemTable, {geometry = geometry, shape = child});
                    if currentEmittingState ~= nil then
                        setEmittingState(geometry, currentEmittingState);
                    end;
                end;
            end;
        end;
    end;
    return rootNode;
end;

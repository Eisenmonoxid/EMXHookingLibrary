BigNum = {RADIX = 10^7, RADIX_LEN = math.floor(math.log10(10^7)), mt = {}};
-- ************************************************************************************************************************************************************ --
-- Here starts the main hook lib code
-- ************************************************************************************************************************************************************ --
EMXHookLibrary = {
	IsHistoryEdition = false,
	OverriddenUpgradeCosts = false,
	
	Internal = {
		CurrentGameVariant = 0,
		
		GlobalAdressEntity = 0, -- Helper entity used for pointer dereference
		GlobalHeapStart = 0,
		GlobalOVOffset = 4128768,
		
		AllocatedMemoryStart = 0,
		AllocatedMemorySize = 0,
		AllocatedMemoryMaxSize = 1000,
		
		ASCIIStringCache = {},
		InstanceCache = {},	
		ColorSetCache = {},	
		
		CurrentVersion = "2.0.7 - 16.12.2024 02:00 - Eisenmonoxid",
	},
	
	Helpers = {},
	Bugfixes = {},
};

EMXHookLibrary.GameVariant = {
	Original = 0,
	OriginalWithOffset = 1,
	HistoryEditionUbi = 2,
	HistoryEditionSteam = 3,
};

EMXHookLibrary.RawPointer = {
	__index = function(_rawPointer, _index)
		local Object = EMXHookLibrary.RawPointer.New(_rawPointer.Pointer)
		Object.Pointer = BigNum.mt.add(Object.Pointer, _index)
		Object.Pointer = BigNum.new(EMXHookLibrary.Internal.GetValueAtPointer(Object))
		return Object
	end,
	__newindex = function(_rawPointer, _index)
		assert(false, "EMXHookLibrary: ERROR - RawPointer: __newindex not implemented!")
	end,
	__call = function(_rawPointer, _index, _value, _isFloat) 
		local Object = EMXHookLibrary.RawPointer.New(_rawPointer.Pointer)
		Object.Pointer = BigNum.mt.add(Object.Pointer, _index)
		local Value = (_isFloat and EMXHookLibrary.Helpers.Float2Int(_value)) or _value
		EMXHookLibrary.Internal.SetValueAtPointer(Object, Value)
		return _rawPointer
	end,
	__tostring = function(_rawPointer)
		return BigNum.mt.tostring(_rawPointer.Pointer)
	end,
	__add = function(_rawPointer, _summand)
		local Object = EMXHookLibrary.RawPointer.New(_rawPointer.Pointer)
		Object.Pointer = BigNum.mt.add(Object.Pointer, _summand)
		return Object
	end,
	__sub = function(_rawPointer, _subtrahend)
		local Object = EMXHookLibrary.RawPointer.New(_rawPointer.Pointer)
		Object.Pointer = BigNum.mt.sub(Object.Pointer, _subtrahend)
		return Object
	end,
	__metatable = "Hidden",
	
	New = function(_pointer)
		local Object = {Pointer = BigNum.new(_pointer)};
		setmetatable(Object, EMXHookLibrary.RawPointer)
		return Object
	end,
};

-- ************************************************************************************************************************************************************ --
-- **************************************************** -> These methods are exported into userspace <- -- **************************************************** --
-- ************************************************************************************************************************************************************ --

EMXHookLibrary.ModifyTerrainHeightWithoutTextureUpdate = function(_posX, _posY, _height)
	local xPos = EMXHookLibrary.Internal.Convert2DPlanePositionToSingle(_posX)
	local yPos = EMXHookLibrary.Internal.Convert2DPlanePositionToSingle(_posY)
	yPos = yPos + 1
	
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "36", "4"}) or {"32", "44", "8"}
	local Pointer = EMXHookLibrary.Internal.GetEGLCGameLogic()["48"][Offsets[1]]
	
	local CTerrainHiRes = Pointer[Offsets[2]]
	CTerrainHiRes.Pointer = BigNum.mt.mul(CTerrainHiRes.Pointer, BigNum.new(yPos))
	CTerrainHiRes = CTerrainHiRes + xPos
	CTerrainHiRes.Pointer = BigNum.mt.mul(CTerrainHiRes.Pointer, BigNum.new("2"))
	
	local TerrainHeightArray = Pointer[Offsets[3]]
	CTerrainHiRes = CTerrainHiRes + tonumber(tostring(TerrainHeightArray))
	CTerrainHiRes = CTerrainHiRes + 2

	CTerrainHiRes("0", _height); -- This is a ushort (2 byte), but we can only write 4 byte, so the next index is also changed 
end

EMXHookLibrary.SetAndReloadModelSpecificShader = function(_modelID, _shaderName)
	-- E.G. "Object_Aligned_Additive", "ShipMovementEx", "WealthLightObject", "IceCliff", "Waterfall", "StaticBanner"
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"80", "4", "8"}) or {"92", "8", "12"}
	local ModelArray = EMXHookLibrary.Internal.GetCDisplay()[Offsets[1]]["16"][Offsets[2]]
	local ResourceManager = EMXHookLibrary.Internal.GetCGlobalsBaseEx()["124"][Offsets[3]]

	local ModelEntry = ModelArray + (_modelID * 108)
	local OriginalValue = tonumber(tostring(ModelEntry[0]))
	
	local Pointer = EMXHookLibrary.Internal.CreatePureASCIITextInMemory(_shaderName)
	ModelEntry(0, Pointer)
	ResourceManager(_modelID * 4, 0) -- Yep, if the model was already loaded, then this is a memory leak (148 Byte) :(
	
	return OriginalValue
end

EMXHookLibrary.ModifyModelPropertiesByReferenceType = function(_modelID, _referenceModelID, _entryIndex)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"80", "4", "8"}) or {"92", "8", "12"}
	local ModelArray = EMXHookLibrary.Internal.GetCDisplay()[Offsets[1]]["16"][Offsets[2]]
	local ResourceManager = EMXHookLibrary.Internal.GetCGlobalsBaseEx()["124"][Offsets[3]]

	local ModelEntry = ModelArray + (_modelID * 108)
	local ReferenceEntry = ModelArray + (_referenceModelID * 108)
	local OriginalValue = tonumber(tostring(ModelEntry[_entryIndex]))
	
	ModelEntry(_entryIndex, tonumber(tostring(ReferenceEntry[_entryIndex])))
	ResourceManager(_modelID * 4, 0) -- Yep, if the model was already loaded, then this is a memory leak (148 Byte) :(

	return OriginalValue
end

EMXHookLibrary.ChangeModelFilePath = function(_modelID, _filePath, _pathLength) -- _pathLength max 64 characters!
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"80", "16"}) or {"92", "20"}
	local CModelsProps = EMXHookLibrary.Internal.GetCDisplay()[Offsets[1]]["16"]
	local ModelEntry = CModelsProps[Offsets[2]]["12"]["0"]
	local Pointer = EMXHookLibrary.Internal.CreatePureASCIITextInMemory(_filePath)
	
	ModelEntry[_modelID * 4]("0", Pointer)("4", 64)("8", _pathLength)
end

EMXHookLibrary.SetEntityDisplayModelParameters = function(_entityIDOrType, _paramType, _params, _model)
	local Mapping = {{"Models", 124, 116}, {"UpgradeSite", 140, 132}, {"Destroyed", 160, 152}, {"Lights", 180, 172}}
	
	for Key, Value in pairs(Mapping) do
		if Value[1] == _paramType then
			EMXHookLibrary.Internal.ModifyEntityDisplay(_entityIDOrType, Value[2], Value[3], _params)
			break;
		end
	end
	
	if _model ~= nil then
		EMXHookLibrary.Internal.ModifyEntityDisplay(_entityIDOrType, 8, 8, _model)
	end
end

EMXHookLibrary.SetBuildingDisplayModelParameters = function(_entityIDOrType, _paramType, _params, _model)
	local Mapping = {{"Yards", 124, 116}, {"Roofs", 136, 128}, {"RoofDestroyed", 148, 140}, {"UpgradeSite", 160, 152}, 
					 {"Floors", 204, 196}, {"Gables", 216, 108}, {"Lights", 324, 316}, {"FireCounts", 188, 180}}

	for Key, Value in pairs(Mapping) do
		if Value[1] == _paramType then
			EMXHookLibrary.Internal.ModifyEntityDisplay(_entityIDOrType, Value[2], Value[3], _params)
			break;
		end
	end
	
	if _model ~= nil then
		EMXHookLibrary.Internal.ModifyEntityDisplay(_entityIDOrType, 8, 8, _model)
	end
end

EMXHookLibrary.SetEntityDisplayProperties = function(_entityIDOrType, _property, _value)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"84", "4"}) or {"88", "8"}	
	local Properties = {
		{"ShowDestroyedModelAt", "220", "212"}, {"MaxDarknessFactor", "216", "208"}, {"ExplodeOnDestroyedModel", "224", "216"}, 
		{"SnowFactor", "76", "72"}, {"SeasonColorSet", "68", "64"}, {"LODDistance", "80", "76"}, {"ConstructionSite", "104", "96"}, {"Decal", "108", "100"}};
	local BitProperties = {{"HighQualityOnly", "39", "39"}, {"RenderInFow", "38", "38"}, {"CastShadow", "37", "37"}, {"DrawPlayerColor", "36", "36"}};

	local Pointer = 0
	if math.ceil(math.log10(_entityIDOrType)) <= 4 then
		Pointer = EMXHookLibrary.Internal.GetCGlobalsLogicEx()["100"]["12"][Offsets[2]][_entityIDOrType * 4]
	else
		Pointer = EMXHookLibrary.Internal.CalculateEntityIDToDisplayObject(_entityIDOrType)[Offsets[1]]
	end

	for i = 1, #Properties do
		if Properties[i][1] == _property then
			Pointer((EMXHookLibrary.IsHistoryEdition and Properties[i][3]) or Properties[i][2], _value)
		end
	end
end

EMXHookLibrary.SetColorSetColorRGB = function(_colorSetName, _season, _rgb, _wetFactor)
	local SeasonIndizes = {0, 16, 32, 48}
	local OriginalValues = {0, 0, 0, 0, 0}
	
	local Pointer = 0
	local ColorSetEntryIndex = EMXHookLibrary.Internal.GetColorSetEntryIndexByName(_colorSetName)
	if ColorSetEntryIndex == -1 then
		return;
	end
	
	if EMXHookLibrary.Internal.ColorSetCache[ColorSetEntryIndex] == nil then
		Pointer = EMXHookLibrary.Internal.FindColorSetEntryPointer(ColorSetEntryIndex)
		if Pointer == nil then
			return;
		end
	else
		Pointer = EMXHookLibrary.Internal.ColorSetCache[ColorSetEntryIndex]
	end
	
	local CurrentIndex = SeasonIndizes[_season]
	for i = 1, 4 do
		OriginalValues[i] = EMXHookLibrary.Helpers.Int2Float(tonumber(tostring(Pointer[CurrentIndex])))
		Pointer(CurrentIndex, _rgb[i], true)
		CurrentIndex = CurrentIndex + 4
	end
	
	if _wetFactor then
		OriginalValues[5] = EMXHookLibrary.Helpers.Int2Float(tonumber(tostring(Pointer["64"])))
		Pointer("64", _wetFactor, true)
	end
	
	return OriginalValues
end

EMXHookLibrary.EditStringTableText = function(_IDManagerEntryIndex, _newString, _useAlternativePointer)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"20", 24, 0}) or {"24", 28, 4}
	local Index = _IDManagerEntryIndex * Offsets[2]
	local WideCharAsMultiByte = EMXHookLibrary.Helpers.ConvertWideCharToMultiByte(_newString)
	local TextSegment = EMXHookLibrary.Internal.GetCTextSet()["4"][Offsets[1]]

	if not _useAlternativePointer then
		for i = 1, #WideCharAsMultiByte do TextSegment(Index + Offsets[3], WideCharAsMultiByte[i]) Offsets[3] = Offsets[3] + 4 end
	else
		TextSegment = TextSegment[Index + Offsets[3]]
		local Iterator = 0
		for i = 1, #WideCharAsMultiByte do TextSegment(Iterator, WideCharAsMultiByte[i]) Iterator = Iterator + 4 end
	end
end

EMXHookLibrary.SetPlayerColorRGB = function(_playerColorEntryIndex, _rgb)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"328", "172"}) or {"332", "176"}
	local Index = _playerColorEntryIndex * 4
	local ColorStringHex = "";
	
	for i = 1, #_rgb, 1 do
		ColorStringHex = ColorStringHex .. string.format("%0x", _rgb[i]);
	end
	ColorStringHex = tonumber("0x" .. ColorStringHex)
	
	local Pointer = EMXHookLibrary.Internal.GetCGlobalsBaseEx()
	Pointer["108"](Index, ColorStringHex)[Offsets[1]](Index, ColorStringHex)
	Pointer["20"][Offsets[2]](Index, ColorStringHex)

	Logic.ExecuteInLuaLocalState([[
		Display.UpdatePlayerColors();
		GUI.RebuildMinimapTerrain();
		GUI.RebuildMinimapTerritory();
    ]]);
end

EMXHookLibrary.ToggleDEBUGMode = function(_magicWord, _setNewMagicWord)
	local Text = "EMXHookLibrary: Debug Word value is: ";
	
	if not EMXHookLibrary.IsHistoryEdition then 
		local Value = 11190056;
		local Pointer = (EMXHookLibrary.Internal.CurrentGameVariant == EMXHookLibrary.GameVariant.OriginalWithOffset and (Value - EMXHookLibrary.Internal.GlobalOVOffset)) or Value;
		local Word = EMXHookLibrary.Internal.GetValueAtPointer(EMXHookLibrary.RawPointer.New(Pointer))
		Logic.DEBUG_AddNote(Text .. Word)
		Framework.WriteToLog(Text .. Word)
		
		if _setNewMagicWord ~= nil then
			EMXHookLibrary.Internal.SetValueAtPointer(EMXHookLibrary.RawPointer.New(Pointer), _magicWord)
		end
		return Word;
	end
	
	if EMXHookLibrary.Internal.CurrentGameVariant ~= EMXHookLibrary.GameVariant.HistoryEditionSteam then
		local Error = "EMXHookLibrary: ERROR -> Can't set Debug mode in Ubisoft-HE, use the S6Patcher for that!"
		Framework.WriteToLog(Error)
		assert(false, Error)
		return "";
	end

	local Pointer = EMXHookLibrary.RawPointer.New(Logic.GetEntityScriptingValue(EMXHookLibrary.Internal.GlobalAdressEntity, -78))["0"]
	Pointer = (Pointer - "2100263")["0"]

	local Word = tostring(Pointer["0"])
	Logic.DEBUG_AddNote(Text .. Word)
	Framework.WriteToLog(Text .. Word)

	if _setNewMagicWord ~= nil then Pointer("0", _magicWord) end
	
	return Word;
end

EMXHookLibrary.EditFestivalProperties = function(_festivalDuration, _promotionDuration, _promotionParticipantLimit, _festivalParticipantLimit)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"496", "8", "144", "52", "176", "84"}) or {"504", "12", "188", "72", "224", "108"}
	
	local Pointer = EMXHookLibrary.Internal.GetFrameworkCMain()[Offsets[1]]["44"][Offsets[2]]
	if _promotionParticipantLimit ~= nil then
		for i = 0, 12, 4 do Pointer[Offsets[3]](i, _promotionParticipantLimit) end
	end
	
	if _festivalParticipantLimit ~= nil then
		for i = 0, 12, 4 do Pointer[Offsets[4]](i, _festivalParticipantLimit) end
	end
	
	if _promotionDuration ~= nil then Pointer(Offsets[5], _promotionDuration) end
	if _festivalDuration ~= nil then Pointer(Offsets[6], _festivalDuration) end
end

EMXHookLibrary.SetBuildingTypeOutStockGood = function(_buildingID, _newGood, _setEntityTypeProduct)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"352", "20", "20", "560", "16"}) or {"368", "16", "24", "612", "12"}
	local SharedIdentifier = BigNum.new("-1035359747")
	local Good = Logic.GetGoodTypeOnOutStockByIndex(_buildingID, 0) -- If behavior does not exist, create it
	
	if _setEntityTypeProduct ~= nil then EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_buildingID)["128"](Offsets[4], _newGood) end
	
	local Pointer = EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_buildingID)[Offsets[1]]["4"]
	local CurrentIdentifier = Pointer[Offsets[5]].Pointer
	while BigNum.compareAbs(CurrentIdentifier, SharedIdentifier) ~= 0 do
		Pointer = Pointer["0"]
		CurrentIdentifier = Pointer[Offsets[5]].Pointer
	end
	
	Pointer[Offsets[2]][Offsets[3]]("0", _newGood)
	
	if Logic.GetGoodTypeOnOutStockByIndex(_buildingID, 0) ~= _newGood then
		assert(false, "EMXHookLibrary: ERROR setting the building OutStock good!")
	end
end

EMXHookLibrary.CreateBuildingInStockGoods = function(_buildingID, _newGoods)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"352", "20", 20, "16"}) or {"368", "16", 24, "12"}
	local SharedIdentifier = BigNum.new("1501117341")

	local Pointer = EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_buildingID)[Offsets[1]]["4"]
	local CurrentIdentifier = Pointer[Offsets[4]].Pointer
	while BigNum.compareAbs(SharedIdentifier, CurrentIdentifier) ~= 0 do
		Pointer = Pointer["8"]
		CurrentIdentifier = Pointer[Offsets[4]].Pointer
	end

	assert(type(_newGoods) == "table")
	local NeededMemorySize = (#_newGoods * 2) * 4
	local MemoryPointer = EMXHookLibrary.Internal.MemoryAllocator(NeededMemorySize)
	
	if MemoryPointer == nil then
		return;
	end
	
	local Counter = 0
	for Key, Value in pairs(_newGoods) do
		MemoryPointer(Counter, Value)(Counter + 4, 0)
		Counter = Counter + 8
	end
	
	local StartPointer = tonumber(tostring(MemoryPointer))
	local EndPointer = tonumber(tostring(MemoryPointer + Counter))
	
	local OriginalValues = {tostring(Pointer[Offsets[2]][Offsets[3]]), 
							tostring(Pointer[Offsets[2]][Offsets[3] + 4]), 
							tostring(Pointer[Offsets[2]][Offsets[3] + 8])};
	
	Pointer[Offsets[2]](Offsets[3], StartPointer)(Offsets[3] + 4, EndPointer)(Offsets[3] + 8, EndPointer)
	
	return OriginalValues
end

EMXHookLibrary.SetBuildingInStockGood = function(_buildingID, _newGood)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"352", "20", "20", "16"}) or {"368", "16", "24", "12"}
	local SharedIdentifier = BigNum.new("1501117341")
	local Good = Logic.GetGoodTypeOnInStockByIndex(_buildingID, 0) -- If behavior does not exist, create it

	local Pointer = EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_buildingID)[Offsets[1]]["4"]
	local CurrentIdentifier = Pointer[Offsets[4]].Pointer
	while BigNum.compareAbs(SharedIdentifier, CurrentIdentifier) ~= 0 do
		Pointer = Pointer["8"]
		CurrentIdentifier = Pointer[Offsets[4]].Pointer
	end

	Pointer[Offsets[2]][Offsets[3]]("0", _newGood)
	
	if Logic.GetGoodTypeOnInStockByIndex(_buildingID, 0) ~= _newGood then
		assert(false, "EMXHookLibrary: ERROR setting the building InStock good!")
	end
end

EMXHookLibrary.SetMaxBuildingStockSize = function(_buildingID, _maxStockSize)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"352", "20", "44", "16"}) or {"368", "16", "52", "12"}
	local SharedIdentifier = BigNum.new("-1035359747")
	local Stock = Logic.GetMaxAmountOnStock(_buildingID) -- If behavior does not exist, create it
	
	local Pointer = EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_buildingID)[Offsets[1]]["4"]
	local CurrentIdentifier = Pointer[Offsets[4]].Pointer
	while BigNum.compareAbs(SharedIdentifier, CurrentIdentifier) ~= 0 do
		Pointer = Pointer["0"]
		CurrentIdentifier = Pointer[Offsets[4]].Pointer
	end
	
	Pointer[Offsets[2]](Offsets[3], _maxStockSize)
	
	if Logic.GetMaxAmountOnStock(_buildingID) ~= _maxStockSize then
		assert(false, "EMXHookLibrary: ERROR setting the building stock limit!")
	end
end

EMXHookLibrary.SetMaxStorehouseStockSize = function(_storehouseID, _maxStockSize)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"352", "20", "68", "16"}) or {"368", "16", "76", "12"}
	local SharedIdentifier = BigNum.new("625443837")
	local Stock = Logic.GetMaxAmountOnStock(_storehouseID) -- If behavior does not exist, create it
	
	local Pointer = EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_storehouseID)[Offsets[1]]["4"]
	local CurrentIdentifier = Pointer[Offsets[4]].Pointer
	while BigNum.compareAbs(SharedIdentifier, CurrentIdentifier) ~= 0 do
		Pointer = Pointer["8"]
		CurrentIdentifier = Pointer[Offsets[4]].Pointer
	end
	
	Pointer[Offsets[2]](Offsets[3], _maxStockSize)
	
	if Logic.GetMaxAmountOnStock(_storehouseID) ~= _maxStockSize then
		assert(false, "EMXHookLibrary: ERROR setting the storehouse stock limit!")
	end
end

EMXHookLibrary.SetGoodTypeParameters = function(_goodType, _requiredResource, _amount, _goodCategory, _animationParameters)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"4", "36"}) or {"8", "40"}
	local Pointer = EMXHookLibrary.Internal.GetCGoodProps()[Offsets[1]][_goodType * 4]
	
	if _requiredResource ~= nil then Pointer[Offsets[2]]("0", _requiredResource) end
	if _amount ~= nil then Pointer[Offsets[2]]("4", _amount) end
	if _goodCategory ~= nil then Pointer("4", _goodCategory) end
	if _animationParameters ~= nil then Pointer("8", _animationParameters[1])("12", _animationParameters[2]) end
end

EMXHookLibrary.CreateGoodTypeRequiredResources = function(_goodType, _requiredResources)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"4", "36", "40", "44"}) or {"8", "40", "44", "48"}
	local GoodPointer = EMXHookLibrary.Internal.GetCGoodProps()[Offsets[1]][_goodType * 4]
	local OriginalValues = {0, 0, 0}

	assert(type(_requiredResources) == "table")
	local NeededMemorySize = (#_requiredResources * 3) * 4
	local Pointer = EMXHookLibrary.Internal.MemoryAllocator(NeededMemorySize)
	
	if Pointer == nil then
		return;
	end
	
	local Counter = 0
	for Key, Value in pairs(_requiredResources) do
		Pointer(Counter, Value[1])(Counter + 4, Value[2])(Counter + 8, Value[3])
		Counter = Counter + 12
	end

	local StartPointer = tonumber(tostring(Pointer))
	local EndPointer = tonumber(tostring(Pointer + Counter))
	
	for i = 2, 4, 1 do
		OriginalValues[i - 1] = tonumber(tostring(GoodPointer[Offsets[i]]))
	end

	GoodPointer(Offsets[2], StartPointer)
	GoodPointer(Offsets[3], EndPointer)
	GoodPointer(Offsets[4], EndPointer)
	
	return OriginalValues
end

EMXHookLibrary.CopyGoodTypePointer = function(_good, _copyGood)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"4", "36", "40", "44"}) or {"8", "40", "44", "48"}
	local CopyGoodPointer = EMXHookLibrary.Internal.GetCGoodProps()[Offsets[1]][_copyGood * 4]
	local GoodPointer = EMXHookLibrary.Internal.GetCGoodProps()[Offsets[1]][_good * 4]
	local OriginalValues = {0, 0, 0}
	
	for i = 2, 4, 1 do
		OriginalValues[i - 1] = tonumber(tostring(GoodPointer[Offsets[i]]))
		GoodPointer(Offsets[i], tonumber(tostring(CopyGoodPointer[Offsets[i]])))
	end
	
	return OriginalValues
end

EMXHookLibrary.ReplaceUpgradeCategoryEntityType = function(_upgradeCategory, _newEntityType)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"364", "40", "552", "12", "4", "16", "24", "0"}) or {"412", "40", "648", "16", "4", "12", "20", "4"}	
	local Pointer = (EMXHookLibrary.Internal.GetEGLCGameLogic()[Offsets[1]][Offsets[2]][Offsets[3]] + Offsets[4])[Offsets[8]][Offsets[5]]
	local SharedIdentifier = BigNum.new(_upgradeCategory)
	local CurrentIdentifier = Pointer[Offsets[6]].Pointer
	
	while BigNum.compareAbs(SharedIdentifier, CurrentIdentifier) ~= 0 do
		if tonumber(tostring(CurrentIdentifier)) < _upgradeCategory then
			Pointer = Pointer["8"]
		else
			Pointer = Pointer["0"]
		end
	
		CurrentIdentifier = Pointer[Offsets[6]].Pointer
	end

	Pointer(Offsets[7], _newEntityType)
end

EMXHookLibrary.AddBehaviorToEntityType = function(_entityType, _behaviorName)
	local Mapping = {{"CInteractiveObjectBehavior", Entities.I_X_Well_Destroyed, "-313534907"}, {"CMountableBehavior", Entities.B_Outpost_ME, "-504538299"},
					 {"CFarmAnimalBehavior", Entities.A_X_Sheep01, "1234712196"}, {"CAnimalMovementBehavior", Entities.A_X_Sheep01, "-870260891"},
					 {"CAmmunitionFillerBehavior", Entities.B_Outpost_ME, "1689179045"}};

	for Key, Value in pairs(Mapping) do
		if Value[1] == _behaviorName then
			local Index = EMXHookLibrary.Internal.GetObjectBehaviorIndexByID(Value[2], Value[3]);
			if Index ~= -1 then
				return EMXHookLibrary.Internal.ModifyEntityBehaviors(_entityType, Value[2], Index);
			end
		end
	end
end

EMXHookLibrary.SetSettlerIllnessCount = function(_newCount) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_newCount, "760", "700") end
EMXHookLibrary.SetCarnivoreHealingSeconds = function(_newTime) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_newTime, "680", "624") end
EMXHookLibrary.SetKnightResurrectionTime = function(_newTime) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_newTime, "184", "164") end
EMXHookLibrary.SetMaxBuildingTaxAmount = function(_newTaxAmount) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_newTaxAmount, "624", "580") end
EMXHookLibrary.SetAmountOfTaxCollectors = function(_newAmount) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_newAmount, "808", "744") end
EMXHookLibrary.SetFogOfWarVisibilityFactor = function(_newFactor) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(EMXHookLibrary.Helpers.Float2Int(_newFactor), "620", "576") end
EMXHookLibrary.SetBuildingKnockDownCompensation = function(_percent) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_percent, "4", "4") end
-- These three get set correctly but don't seem to do anything ingame. Might need further testing however.
--EMXHookLibrary.SetTrailSpeedModifier = function(_newFactor) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(EMXHookLibrary.Helpers.Float2Int(_newFactor), "496", "464") end
--EMXHookLibrary.SetRoadSpeedModifier = function(_newFactor) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(EMXHookLibrary.Helpers.Float2Int(_newFactor), "320", "300") end
--EMXHookLibrary.SetWaterDepthBlockingThreshold = function(_threshold) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_threshold, "456", "424") end
EMXHookLibrary.SetTerritoryCombatBonus = function(_newFactor) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(EMXHookLibrary.Helpers.Float2Int(_newFactor), "604", "560") end
EMXHookLibrary.SetCathedralCollectAmount = function(_newAmount) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_newAmount, "436", "404") end
EMXHookLibrary.SetFireHealthDecreasePerSecond = function(_newAmount) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_newAmount, "260", "240") end
EMXHookLibrary.SetWealthGoodDecayPerSecond = function(_decay) EMXHookLibrary.Internal.ModifyLogicPropertiesEx(_decay, "492", "460") end
EMXHookLibrary.GetModel = function(_entityID) return tostring(EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_entityID)["28"]) end

EMXHookLibrary.SetTerritoryGoldCostByIndex = function(_arrayIndex, _price)
	local Offset = (EMXHookLibrary.IsHistoryEdition and 628) or 684	
	EMXHookLibrary.Internal.GetLogicPropertiesEx()((_arrayIndex * 4) + Offset, _price)
end

EMXHookLibrary.SetSettlerLimit = function(_cathedralIndex, _limit)	
	local Offset = (EMXHookLibrary.IsHistoryEdition and "376") or "408"
	EMXHookLibrary.Internal.GetLogicPropertiesEx()[Offset](_cathedralIndex * 4, _limit)
end

EMXHookLibrary.SetSermonSettlerLimit = function(_cathedralEntityType, _upgradeLevel, _newLimit) 
	EMXHookLibrary.Internal.SetLimitByEntityType(_cathedralEntityType, _upgradeLevel, _newLimit, {"756", "680"})
end

EMXHookLibrary.SetSoldierLimit = function(_castleEntityType, _upgradeLevel, _newLimit)	
	EMXHookLibrary.Internal.SetLimitByEntityType(_castleEntityType, _upgradeLevel, _newLimit, {"788", "704"})
end

EMXHookLibrary.SetEntityTypeOutStockCapacity = function(_entityType, _upgradeLevel, _newLimit)	
	EMXHookLibrary.Internal.SetLimitByEntityType(_entityType, _upgradeLevel, _newLimit, {"676", "612"})
end

EMXHookLibrary.SetEntityTypeSpouseProbabilityFactor = function(_entityType, _factor)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "596"}) or {"28", "648"}
	EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4](Offsets[2], _factor, true)
end

EMXHookLibrary.SetTypeAndMaxNumberOfWorkersForBuilding = function(_entityType, _maxWorkers, _workerType)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "256", "260"}) or {"28", "288", "292"}
	EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4](Offsets[2], _maxWorkers)(Offsets[3], _workerType)
end

EMXHookLibrary.SetSettlersWorkBuilding = function(_settlerID, _buildingID)
	EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_settlerID)["84"]["0"]("0", _buildingID)
end

EMXHookLibrary.SetEntityTypeMinimapIcon = function(_entityType, _iconIndex)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "88"}) or {"28", "92"}
	EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4](Offsets[2], _iconIndex)
end

EMXHookLibrary.SetEntityTypeMaxHealth = function(_entityType, _newMaxHealth)
	local Offset = (EMXHookLibrary.IsHistoryEdition and "24") or "28"
	EMXHookLibrary.Internal.GetCEntityProps()[Offset][_entityType * 4]("36", _newMaxHealth)
end

EMXHookLibrary.SetBallistaAmmunitionAmount = function(_amount)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "152"}) or {"28", "164"}
	EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][Entities.U_MilitaryBallista * 4][Offsets[2]]["8"]("20", _amount)
end

-- _costs = {_good, _amount, _secondGood, _secondAmount}
EMXHookLibrary.SetEntityTypeFullCost = function(_entityType, _costs, _overrideSecondGoodPointer)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "136", "140", "144"}) or {"28", "144", "148", "152"}
	local Pointer = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4]
	local ValuePointer = Pointer[Offsets[2]]
	local OriginalValues = {0, 0, 0}
	
	assert(type(_costs) == "table" and #_costs >= 2, "Error: Invalid Costtable!")
	
	for i = 2, 4, 1 do
		OriginalValues[i - 1] = tonumber(tostring(Pointer[Offsets[i]]))
	end

	if tonumber(tostring(ValuePointer)) == 0 then
		local Size = (_costs[3] ~= nil and 16) or 8
		local MemoryPointer = EMXHookLibrary.Internal.MemoryAllocator(Size)
		
		MemoryPointer("0", _costs[1])("4", _costs[2])	
		if _costs[3] ~= nil then
			MemoryPointer("8", _costs[3])("12", _costs[4])
		end
			
		Pointer(Offsets[2], tonumber(tostring(MemoryPointer)))(Offsets[3], tonumber(tostring(MemoryPointer + Size)))(Offsets[4], tonumber(tostring(MemoryPointer + Size)))
	else
		ValuePointer("0", _costs[1])("4", _costs[2])	
		if _costs[3] ~= nil then
			ValuePointer("8", _costs[3])("12", _costs[4])
		
			if _overrideSecondGoodPointer then 
				local EndPointer = Pointer[Offsets[3]]
				Pointer(Offsets[3], tonumber(tostring(EndPointer + 8)))(Offsets[4], tonumber(tostring(EndPointer + 8)))
			end
		end
	end
	
	return OriginalValues
end

-- _costs = {_good, _amount, _secondGood, _secondAmount}
EMXHookLibrary.SetEntityTypeUpgradeCost = function(_entityType, _upgradeLevel, _costs, _overrideSecondGoodPointer, _overrideUpgradeCostHandling)	
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "600", 0, 12}) or {"28", "660", 4, 16}
	local UpgradeLevelOffset = Offsets[3] + (_upgradeLevel * Offsets[4])
	local Pointer = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4][Offsets[2]]
	local ValuePointer = Pointer[UpgradeLevelOffset]
	local OriginalValues = {0, 0}
	
	assert(type(_costs) == "table" and #_costs >= 2, "Error: Invalid Costtable!")
	
	for i = 4, 8, 4 do
		OriginalValues[i / 4] = tonumber(tostring(Pointer[UpgradeLevelOffset + i]))
	end

	ValuePointer("0", _costs[1])("4", _costs[2])
	if _costs[3] ~= nil then
		ValuePointer("8", _costs[3])("12", _costs[4])
		
		if _overrideSecondGoodPointer then 
			local EndPointer = Pointer[UpgradeLevelOffset + 4]
			Pointer(UpgradeLevelOffset + 4, tonumber(tostring(EndPointer + 8)))(UpgradeLevelOffset + 8, tonumber(tostring(EndPointer + 8)))
		end
	end
	
	if not EMXHookLibrary.OverriddenUpgradeCosts and _overrideUpgradeCostHandling then
		Logic.ExecuteInLuaLocalState([[
			function GUI_BuildingButtons.GetUpgradeCosts()
				local EntityID = GUI.GetSelectedEntity()
				local Costs = {}
				local CurrentGoodCost = 0
				for Key, Value in pairs(Goods) do
					CurrentGoodCost = Logic.GetBuildingUpgradeCostByGoodType(EntityID, Value, 0)
					if CurrentGoodCost ~= 0 then
						table.insert(Costs, Value)
						table.insert(Costs, CurrentGoodCost)
					end
					if #Costs >= 4 then
						break;
					end
				end
				return Costs
			end
		]]);
		
		EMXHookLibrary.OverriddenUpgradeCosts = true
	end
	
	return OriginalValues
end

EMXHookLibrary.SetEntityTypeBlocking = function(_entityType, _blocking, _isBuildBlocking)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "168", "240"}) or {"28", "184", "276"}
	local Pointer = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4]
	Pointer = Pointer[(_isBuildBlocking and Offsets[3]) or Offsets[2]]
	
	local Iterator = 1
	for i = 0, (#_blocking * 3), 4 do
		Pointer(i, _blocking[Iterator], true)
		Iterator = Iterator + 1
	end
end

-- _distances = {_rowDistance, _colDistance, _cartRowDistance, _cartColDistance, _engineRowDistance, _engineColDistance}
EMXHookLibrary.SetMilitaryMetaFormationParameters = function(_distances) 
	assert(type(_distances) == "table")
	local Offset = (EMXHookLibrary.IsHistoryEdition and 652) or 708	
	local Counter = 0
	
	for Key, Value in pairs(_distances) do
		if Value ~= nil then
			EMXHookLibrary.Internal.GetLogicPropertiesEx()(Offset + Counter, Value, true)
		end
		Counter = Counter + 4
	end
end

EMXHookLibrary.SetTerritoryAcquiringBuildingID = function(_territoryID, _buildingID)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"332", "4", 168}) or {"372", "8", 180}
	local Pointer = EMXHookLibrary.Internal.GetEGLCGameLogic()[Offsets[1]][Offsets[2]]
	Pointer = Pointer + (_territoryID * Offsets[3])
	
	Pointer("24", _buildingID)
end

EMXHookLibrary.SetEGLEffectDuration = function(_effect, _duration)
	local Offset = (EMXHookLibrary.IsHistoryEdition and "8") or "12"
	EMXHookLibrary.Internal.GetCEffectProps()[Offset][_effect * 4]("16", _duration, true)
end

EMXHookLibrary.ToggleRTSCameraMouseRotation = function(_enableMouseRotation, _optionalRotationSpeed)
	local Speed = _optionalRotationSpeed or 2500
	EMXHookLibrary.Internal.GetCCameraBehaviorRTS()("40", (_enableMouseRotation and Speed) or 0, true)
end
-- ************************************************************************************************************************************************************ --
-- Internal library functions
-- ************************************************************************************************************************************************************ --
EMXHookLibrary.Internal.ModifyEntityDisplay = function(_entityIDOrType, _vanillaOffset, _heOffset, _params)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"84", "4"}) or {"88", "8"}	
	
	local Pointer = 0
	if math.ceil(math.log10(_entityIDOrType)) <= 4 then
		Pointer = EMXHookLibrary.Internal.GetCGlobalsLogicEx()["100"]["12"][Offsets[2]][_entityIDOrType * 4]
	else
		Pointer = EMXHookLibrary.Internal.CalculateEntityIDToDisplayObject(_entityIDOrType)[Offsets[1]]
	end

	local StartOffset = (EMXHookLibrary.IsHistoryEdition and _heOffset) or _vanillaOffset
	for i = 1, #_params do
		if _params[i] ~= nil then
			Pointer(StartOffset, _params[i])
		end
		StartOffset = StartOffset + 4
	end
end
EMXHookLibrary.Internal.FindColorSetEntryPointer = function(_colorSetEntryIndex)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"0", "16", "20"}) or {"4", "12", "16"}
	local OriginalPointer = EMXHookLibrary.Internal.GetCGlobalsBaseEx()["128"][Offsets[1]]
	
	local Pointer, CurrentEntry = 0, 0;
	for i = 0, 8, 4 do
		Pointer = OriginalPointer[i]

		repeat
			CurrentEntry = tonumber(tostring(Pointer[Offsets[2]]))
			if CurrentEntry == _colorSetEntryIndex then
				Pointer = Pointer[Offsets[3]]
				EMXHookLibrary.Internal.ColorSetCache[_colorSetEntryIndex] = Pointer
		
				return Pointer;
			end
			if CurrentEntry < _colorSetEntryIndex then
				Pointer = Pointer["8"]
			else
				Pointer = Pointer["0"]
			end
		until tonumber(tostring(Pointer["0"])) == tonumber(tostring(Pointer["8"]))
	end

	Framework.WriteToLog("EMXHookLibrary: No ColorSet entry found for index ".._colorSetEntryIndex.."! Aborting ...")
	return;
end
EMXHookLibrary.Internal.GetColorSetEntryIndexByName = function(_colorSetName)
	local Input = string.lower(_colorSetName)
	local Pointer = EMXHookLibrary.Internal.GetColorSetIDManager()["12"]["0"]
	
	local Counter = 0
	while true do
		if tonumber(tostring(Pointer[Counter * 4])) == 0 then
			break;
		end
		
		local String = EMXHookLibrary.Internal.GetLuaASCIIStringFromPointer(Pointer[Counter * 4]["0"])
		if string.find(String, Input) then
			return Counter;
		end
		
		Counter = Counter + 1
	end
	
	return -1;
end
EMXHookLibrary.Internal.ModifyEntityBehaviors = function(_entityTypeToAdd, _entityTypeToReference, _behaviorIndex)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", 152}) or {"28", 164}

	local Pointer = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityTypeToAdd * 4]
	local AmountOfBehaviors = tonumber(tostring(Pointer[Offsets[2] + 12]))
	
	local OriginalPointers = {0, 0, 0, 0}
	local MemorySize = (AmountOfBehaviors + 1) * 4
	local MemoryPointer = EMXHookLibrary.Internal.MemoryAllocator(MemorySize)
	
	if MemoryPointer == nil then
		return;
	end
	
	local CurrentValue = 0
	for i = 0, AmountOfBehaviors - 1 do
		CurrentValue = tonumber(tostring(Pointer[Offsets[2]][i * 4]))
		MemoryPointer(i * 4, CurrentValue)
	end
	
	local ReferenceEntity = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityTypeToReference * 4]
	MemoryPointer(MemorySize - 4, tonumber(tostring(ReferenceEntity[Offsets[2]][_behaviorIndex])))
	
	for i = 0, 3, 1 do
		OriginalPointers[i + 1] = tonumber(tostring(Pointer[Offsets[2] + (i * 4)]))
	end

	local EndPointer = tonumber(tostring(MemoryPointer + MemorySize))
	Pointer(Offsets[2], tonumber(tostring(MemoryPointer)))(Offsets[2] + 4, EndPointer)(Offsets[2] + 8, EndPointer)(Offsets[2] + 12, AmountOfBehaviors + 1)

	return OriginalPointers
end
EMXHookLibrary.Internal.GetObjectBehaviorIndexByID = function(_entityType, _behaviorID)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", 152}) or {"28", 164}
	local Pointer = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4]
	local AmountOfBehaviors = tonumber(tostring(Pointer[Offsets[2] + 12]))
	Pointer = Pointer[Offsets[2]]
	
	local SharedIdentifier = BigNum.new(_behaviorID);
	local CurrentIdentifier = 0;
	for i = 0, AmountOfBehaviors - 1, 1 do
		CurrentIdentifier = Pointer[i * 4]["12"].Pointer
		if BigNum.compareAbs(SharedIdentifier, CurrentIdentifier) == 0 then
			return i * 4;
		end
	end
	
	return -1;
end
EMXHookLibrary.Internal.ModifyLogicPropertiesEx = function(_newValue, _vanillaValue, _heValue)
	EMXHookLibrary.Internal.GetLogicPropertiesEx()((EMXHookLibrary.IsHistoryEdition and _heValue) or _vanillaValue, _newValue)
end
EMXHookLibrary.Internal.SetLimitByEntityType = function(_entityType, _upgradeLevel, _newLimit, _pointerValues)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", _pointerValues[2]}) or {"28", _pointerValues[1]}
	EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4][Offsets[2]](_upgradeLevel * 4, _newLimit)
end
EMXHookLibrary.Internal.Convert2DPlanePositionToSingle = function(_position)
	return math.ceil(math.floor(((_position * 0.01) + (_position * 0.01)) + 0.5) * 0.5);
end
-- ************************************************************************************************************************************************************ --
-- Reset Functions
-- ************************************************************************************************************************************************************ --
EMXHookLibrary.ResetModelProperties = function(_modelID, _entryIndex, _resetValue)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"80", "4", "8"}) or {"92", "8", "12"}
	local ModelArray = EMXHookLibrary.Internal.GetCDisplay()[Offsets[1]]["16"][Offsets[2]]
	local ResourceManager = EMXHookLibrary.Internal.GetCGlobalsBaseEx()["124"][Offsets[3]]
	
	local ModelEntry = ModelArray + (_modelID * 108)

	ModelEntry(_entryIndex, _resetValue)
	ResourceManager(_modelID * 4, 0)
end
EMXHookLibrary.ResetGoodTypePointer = function(_goodType, _resetPointers)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"4", "36", "40", "44"}) or {"8", "40", "44", "48"}
	local GoodPointer = EMXHookLibrary.Internal.GetCGoodProps()[Offsets[1]][_goodType * 4]
	
	for i = 2, 4, 1 do
		GoodPointer(Offsets[i], _resetPointers[i - 1])
	end
end
EMXHookLibrary.ResetEntityBehaviors = function(_entityType, _resetPointers)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", 152}) or {"28", 164}
	local Pointer = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4]
	
	for i = 0, 3, 1 do
		Pointer(Offsets[2] + (i * 4), _resetPointers[i + 1])
	end
end
EMXHookLibrary.ResetEntityTypeFullCost = function(_entityType, _resetPointers)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "136", "140", "144"}) or {"28", "144", "148", "152"}
	local Pointer = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4]

	for i = 2, 4, 1 do
		Pointer(Offsets[i], _resetPointers[i - 1])
	end
end
EMXHookLibrary.ResetEntityTypeUpgradeCost = function(_entityType, _upgradeLevel, _resetPointers)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "600", 0, 12}) or {"28", "660", 4, 16}
	local UpgradeLevelOffset = Offsets[3] + (_upgradeLevel * Offsets[4])
	local Pointer = EMXHookLibrary.Internal.GetCEntityProps()[Offsets[1]][_entityType * 4][Offsets[2]]

	Pointer(UpgradeLevelOffset + 4, _resetPointers[1])(UpgradeLevelOffset + 8, _resetPointers[2])
end
-- ************************************************************************************************************************************************************ --
-- Hooking Utility Methods
-- ************************************************************************************************************************************************************ --
EMXHookLibrary.Internal.GetObjectInstance = function(_ovPointer, _steamHEChars, _ubiHEChars, _subtract)
	if not EMXHookLibrary.IsHistoryEdition then
		if EMXHookLibrary.Internal.CurrentGameVariant == EMXHookLibrary.GameVariant.OriginalWithOffset then
			_ovPointer = (_ovPointer - EMXHookLibrary.Internal.GlobalOVOffset)
		end
		return EMXHookLibrary.RawPointer.New(_ovPointer);
	end
	
	if EMXHookLibrary.Internal.InstanceCache[_ovPointer] ~= nil then
		return EMXHookLibrary.RawPointer.New(tonumber("0x" .. EMXHookLibrary.Internal.InstanceCache[_ovPointer]));
	end
	
	local _hexSplitChars = {};
	local _lowestDigit = 0;
	local HexString01, HexString02;
	
	if EMXHookLibrary.Internal.CurrentGameVariant == EMXHookLibrary.GameVariant.HistoryEditionSteam then
		_lowestDigit = _steamHEChars[1]
		_hexSplitChars = {_steamHEChars[2], _steamHEChars[3], _steamHEChars[4], _steamHEChars[5]}
	else
		_lowestDigit = _ubiHEChars[1]
		_hexSplitChars = {_ubiHEChars[2], _ubiHEChars[3], _ubiHEChars[4], _ubiHEChars[5]}
	end
	
	local Pointer = EMXHookLibrary.RawPointer.New(Logic.GetEntityScriptingValue(EMXHookLibrary.Internal.GlobalAdressEntity, -78))["0"]
	if _subtract ~= nil then
		HexString01 = string.format("%x", tostring((Pointer - (_lowestDigit))["0"]))
		HexString02 = string.format("%x", tostring((Pointer - (_lowestDigit - 1))["0"]))
	else
		HexString01 = string.format("%x", tostring((Pointer + (_lowestDigit))["0"]))
		HexString02 = string.format("%x", tostring((Pointer + (_lowestDigit + 1))["0"]))
	end
	
	-- Both strings need to consist of 8 digits, otherwise trailing zeroes got lost, so we need to re-add them
	while (string.len(HexString01) < 8) do HexString01 = "0" .. HexString01 end
	while (string.len(HexString02) < 8) do HexString02 = "0" .. HexString02 end
	
	HexString01 = string.sub(HexString01, _hexSplitChars[1], _hexSplitChars[2])
	HexString02 = string.sub(HexString02, _hexSplitChars[3], _hexSplitChars[4])

	local DereferenceString = HexString02 .. HexString01	
	Framework.WriteToLog("EMXHookLibrary: Going to dereference HEPointer: 0x"..DereferenceString..". OVPointer: ".._ovPointer)
	
	EMXHookLibrary.Internal.InstanceCache[_ovPointer] = DereferenceString	
	return EMXHookLibrary.RawPointer.New(tonumber("0x" .. DereferenceString));
end
-- ************************************************************************************************************************************************************ --
-- Get global instances of classes in memory, static value in OV, and offset in both HEs
-- ************************************************************************************************************************************************************ --
EMXHookLibrary.Internal.GetCEntityManager = function() return EMXHookLibrary.Internal.GetObjectInstance(11199488, {85, 1, 4, 5, 8}, {293, 0, 0, 1, 8})["0"] end
EMXHookLibrary.Internal.GetLogicPropertiesEx = function() return EMXHookLibrary.Internal.GetObjectInstance(11198716, {1601, 1, 2, 3, 8}, {28002, 0, 0, 1, 8})["0"] end
EMXHookLibrary.Internal.GetCEntityProps = function() return EMXHookLibrary.Internal.GetObjectInstance(11198560, {2593, 1, 6, 7, 8}, {2358, 0, 0, 1, 8})["0"] end
EMXHookLibrary.Internal.GetCEffectProps = function() return EMXHookLibrary.Internal.GetObjectInstance(11198564, {69981, 1, 4, 5, 8}, {189755, 0, 0, 1, 8})["0"] end
EMXHookLibrary.Internal.GetCGoodProps = function() return EMXHookLibrary.Internal.GetObjectInstance(11198636, {16529, 0, 0, 1, 8}, {30412, 1, 6, 7, 8})["0"] end
EMXHookLibrary.Internal.GetEGLCGameLogic = function() return EMXHookLibrary.Internal.GetObjectInstance(11198552, {39, 0, 0, 1, 8}, {104, 1, 2, 3, 8})["0"] end
EMXHookLibrary.Internal.GetCGlobalsBaseEx = function() return EMXHookLibrary.Internal.GetObjectInstance(11674352, {774921, 1, 4, 5, 8}, {1803892, 1, 2, 3, 8})["0"] end
EMXHookLibrary.Internal.GetCGlobalsLogicEx = function() return EMXHookLibrary.Internal.GetObjectInstance(11674344, {1136615, 1, 6, 7, 8}, {108296, 1, 2, 3, 8}, true)["0"] end
EMXHookLibrary.Internal.GetFrameworkCMain = function() return EMXHookLibrary.Internal.GetObjectInstance(11158232, {2250717, 0, 0, 1, 8}, {1338624, 1, 4, 5, 8}, true)["0"] end
EMXHookLibrary.Internal.GetCTextSet = function() return EMXHookLibrary.Internal.GetObjectInstance(11469188, {475209, 1, 4, 4, 8}, {1504636, 1, 6, 7, 8})["0"] end
EMXHookLibrary.Internal.GetCDisplay = function() return EMXHookLibrary.Internal.GetObjectInstance(11674360, {1617395, 1, 6, 7, 8}, {589264, 1, 2, 3, 8}, true)["0"] end
EMXHookLibrary.Internal.GetCCameraBehaviorRTS = function() return EMXHookLibrary.Internal.GetObjectInstance(11568248, {1766975, 1, 6, 7, 8}, {738468, 1, 4, 5, 8}, true) end
EMXHookLibrary.Internal.GetFPPrecisionObject = function() return EMXHookLibrary.Internal.GetObjectInstance(11795144, {6275025, 1, 4, 5, 8}, {7303684, 1, 4, 5, 8}) end
EMXHookLibrary.Internal.GetCFileSystemManager = function() return EMXHookLibrary.Internal.GetObjectInstance(11188828, {424694, 1, 8, 0, 0}, {5752, 1, 4, 5, 8})["0"] end
EMXHookLibrary.Internal.GetColorSetIDManager = function() return EMXHookLibrary.Internal.GetObjectInstance(11678212, {1351584, 7, 8, 1, 6}, {323476, 1, 6, 7, 8}, true) end

EMXHookLibrary.Internal.CalculateEntityIDToDisplayObject = function(_entityID)
	local Result = EMXHookLibrary.Helpers.BitAnd(_entityID, 65535)
	return EMXHookLibrary.Internal.GetCGlobalsLogicEx()["100"][(Result * 4) + 20];
end
EMXHookLibrary.Internal.CalculateEntityIDToLogicObject = function(_entityID)
	local Result = EMXHookLibrary.Helpers.BitAnd(_entityID, 65535)
	return EMXHookLibrary.Internal.GetCEntityManager()[(Result * 8) + 20];
end
-- ************************************************************************************************************************************************************ --
-- Dereference RawPointers
-- ************************************************************************************************************************************************************ --
EMXHookLibrary.Internal.GetValueAtPointer = function(_rawPointer)
	if not Logic.IsEntityAlive(EMXHookLibrary.Internal.GlobalAdressEntity) then
		local Error = "EMXHookLibrary: ERROR! Tried to get value at address "..tostring(_rawPointer).." without existing AdressEntity!"
		Framework.WriteToLog(Error)
		assert(false, Error)
		return;
	end
	
	local Offset = (EMXHookLibrary.IsHistoryEdition and "-78") or "-81"
	local Index = BigNum.mt.sub(_rawPointer.Pointer, EMXHookLibrary.Internal.GlobalHeapStart)
	Index = BigNum.mt.div(Index, "4")
	Index = BigNum.mt.add(Offset, Index)

	return Logic.GetEntityScriptingValue(EMXHookLibrary.Internal.GlobalAdressEntity, tonumber(BigNum.mt.tostring(Index)))
end

EMXHookLibrary.Internal.SetValueAtPointer = function(_rawPointer, _Value)
	if not Logic.IsEntityAlive(EMXHookLibrary.Internal.GlobalAdressEntity) then
		local Error = "EMXHookLibrary: ERROR! Tried to set value at address "..tostring(_rawPointer).." without existing AdressEntity!"
		Framework.WriteToLog(Error)
		assert(false, Error)
		return;
	end
	
	--if _Value >= 2147483648 then
	--	EMXHookLibrary.Internal.GetFPPrecisionObject()("0", 0) -- Only works in OV currently, not HE!
	--end
	
	local Offset = (EMXHookLibrary.IsHistoryEdition and "-78") or "-81"
	local Index = BigNum.mt.sub(_rawPointer.Pointer, EMXHookLibrary.Internal.GlobalHeapStart)
	Index = BigNum.mt.div(Index, "4")
	Index = BigNum.mt.add(Offset, Index)
	
	Logic.SetEntityScriptingValue(EMXHookLibrary.Internal.GlobalAdressEntity, tonumber(BigNum.mt.tostring(Index)), _Value)
end
-- ************************************************************************************************************************************************************ --
-- Initialization of the library
-- ************************************************************************************************************************************************************ --
EMXHookLibrary.Internal.FindOffsetValue = function(_offset)
	if EMXHookLibrary.Internal.GlobalAdressEntity ~= 0 and Logic.IsEntityAlive(EMXHookLibrary.Internal.GlobalAdressEntity) then
		Logic.DestroyEntity(EMXHookLibrary.Internal.GlobalAdressEntity);
	end

	local Position = 3000;
	local AddressEntity = Logic.CreateEntity(Entities.D_X_TradeShip, Position, Position, 0, 0);
	local PointerEntity = Logic.CreateEntity(Entities.D_X_TradeShip, Position, Position, 0, 0);
	local VTableValue = BigNum.new(Logic.GetEntityScriptingValue(PointerEntity, _offset));
	
	Logic.DestroyEntity(PointerEntity);
	Logic.SetVisible(AddressEntity, false);

	EMXHookLibrary.Internal.GlobalAdressEntity = AddressEntity;
	EMXHookLibrary.Internal.GlobalHeapStart = VTableValue;
end

EMXHookLibrary.Initialize = function(_useLoadGameOverride, _maxMemorySizeToAllocate, _useGeneralGameBugfixes) -- Entry Point
	EMXHookLibrary.OverriddenUpgradeCosts = false
	
	if (string.find(Framework.GetProgramVersion(), "1.71") == nil) then
		local Text = "EMXHookLibrary: Patch 1.71 was NOT found! Aborting ...";
		Framework.WriteToLog(Text);
		return false;
	end
	
	for Key, Value in pairs(EMXHookLibrary.Internal.InstanceCache) do
		EMXHookLibrary.Internal.InstanceCache[Key] = nil;
	end	
	for Key, Value in pairs(EMXHookLibrary.Internal.ColorSetCache) do
		EMXHookLibrary.Internal.ColorSetCache[Key] = nil;
	end
	for Key, Value in pairs(EMXHookLibrary.Internal.ASCIIStringCache) do
		EMXHookLibrary.Internal.ASCIIStringCache[Key] = nil;
	end
	
	if (Network.IsNATReady == nil) then
		EMXHookLibrary.Internal.FindOffsetValue(36)
		EMXHookLibrary.IsHistoryEdition = false
		EMXHookLibrary.Internal.CurrentGameVariant = EMXHookLibrary.Internal.GetOriginalGameVariant()
	else
		EMXHookLibrary.Internal.FindOffsetValue(34)
		EMXHookLibrary.IsHistoryEdition = true
		EMXHookLibrary.Internal.CurrentGameVariant = EMXHookLibrary.Internal.GetHistoryEditionVariant()
	end
	
	Framework.WriteToLog("EMXHookLibrary: Initialization successful! Version: " .. EMXHookLibrary.Internal.CurrentVersion .. 
						 ". CurrentGameVariant: " .. tostring(EMXHookLibrary.Internal.CurrentGameVariant) .. ".");
	Framework.WriteToLog("EMXHookLibrary: Heap Object starts at 0x" .. string.format("%0x", BigNum.mt.tostring(EMXHookLibrary.Internal.GlobalHeapStart)) .. 
						 ". AddressEntity ID: " .. tostring(EMXHookLibrary.Internal.GlobalAdressEntity) .. ".");

	if _useLoadGameOverride == true then
		EMXHookLibrary.Internal.OverrideLoadGameHandling();
		Framework.WriteToLog("EMXHookLibrary: OverrideLoadGameHandling!");
	end
	if _useGeneralGameBugfixes == true then
		EMXHookLibrary.Bugfixes.Initialize();
		Framework.WriteToLog("EMXHookLibrary: UseGeneralGameBugfixes!");
	end
	if _maxMemorySizeToAllocate ~= nil and type(_maxMemorySizeToAllocate) == "number" then
		EMXHookLibrary.Internal.AllocatedMemoryMaxSize = _maxMemorySizeToAllocate;
		Framework.WriteToLog("EMXHookLibrary: Max memory size to allocate: " .. tostring(_maxMemorySizeToAllocate));
	end
	EMXHookLibrary.Internal.AllocateDynamicMemory(EMXHookLibrary.Internal.AllocatedMemoryMaxSize);
	
	return true;
end
EMXHookLibrary.InitAdressEntity = EMXHookLibrary.Initialize; -- Compatibility with versions prior to 1.9.9 

EMXHookLibrary.Internal.AllocateDynamicMemory = function(_maxSize)
	local Offset = (EMXHookLibrary.IsHistoryEdition and 268) or 280
	local Allocater = {}
	local Counter = 0
	repeat
		table.insert(Allocater, 1)
		Counter = Counter + 1
	until Counter == (_maxSize)
	Logic.SetEntityName(EMXHookLibrary.Internal.GlobalAdressEntity, table.concat(Allocater))
	
	local Pointer = EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(EMXHookLibrary.Internal.GlobalAdressEntity)[Offset]
	EMXHookLibrary.Internal.AllocatedMemoryStart = Pointer
	EMXHookLibrary.Internal.AllocatedMemorySize = 0
	
	Framework.WriteToLog("EMXHookLibrary: Dynamic Memory with size " .. _maxSize .. " allocated: 0x" .. string.format("%0x", tostring(Pointer)))
end

EMXHookLibrary.Internal.MemoryAllocator = function(_size)
	local Size = EMXHookLibrary.Internal.AllocatedMemorySize + _size
	if Size > (EMXHookLibrary.Internal.AllocatedMemoryMaxSize / 4) then
		local Text = "EMXHookLibrary: Out of Memory ERROR!"
		Framework.WriteToLog(Text)
		assert(false, Text)
		return;
	end
	
	local Pointer = EMXHookLibrary.Internal.AllocatedMemoryStart + EMXHookLibrary.Internal.AllocatedMemorySize
	EMXHookLibrary.Internal.AllocatedMemorySize = Size

	Framework.WriteToLog("EMXHookLibrary: Requested Memory: Size: " .. tostring(Size) .. ". Pointer: 0x" .. string.format("%0x", tostring(Pointer)))

	return Pointer
end

EMXHookLibrary.Internal.CreatePureASCIITextInMemory = function(_string)
	if _string == nil then
		Framework.SetOnGameStartLuaCommand("")
		return;
	end
	
	if EMXHookLibrary.Internal.ASCIIStringCache[_string] ~= nil then
		Framework.WriteToLog("EMXHookLibrary: ASCII String Pointer loaded from StringCache: " .. _string .. " - " .. tostring(EMXHookLibrary.Internal.ASCIIStringCache[_string]))
		return EMXHookLibrary.Internal.ASCIIStringCache[_string];
	end
	
	local Offset = (EMXHookLibrary.IsHistoryEdition and 404) or 412
	Framework.SetOnGameStartLuaCommand(_string)
	
	local Pointer = tonumber(tostring(EMXHookLibrary.Internal.GetFrameworkCMain()[Offset]))
	EMXHookLibrary.Internal.GetFrameworkCMain()(Offset, 0)(Offset + 4, 0)
	
	EMXHookLibrary.Internal.ASCIIStringCache[_string] = Pointer
	Framework.WriteToLog("EMXHookLibrary: ASCII String Pointer CREATED! " .. _string .. " - " .. tostring(Pointer))
	
	return Pointer
end

EMXHookLibrary.Internal.GetLuaASCIIStringFromPointer = function(_pointer)
	local CMain = EMXHookLibrary.Internal.GetFrameworkCMain()
	local SavedPointer = tonumber(tostring(CMain["20"]))
	
	CMain("20", tonumber(tostring(_pointer)))
	local String = Framework.GetCurrentMapName();
	CMain("20", SavedPointer)
	
	return String
end

EMXHookLibrary.Internal.GetHistoryEditionVariant = function()
	local Pointer = EMXHookLibrary.RawPointer.New(Logic.GetEntityScriptingValue(EMXHookLibrary.Internal.GlobalAdressEntity, -78))["0"]["105"];
	local Identifier = string.sub(string.format("%x", tostring(Pointer)), 3, 8);
	local Variant = ((Identifier == "92ff") and EMXHookLibrary.GameVariant.HistoryEditionSteam) or EMXHookLibrary.GameVariant.HistoryEditionUbi;
	Framework.WriteToLog("EMXHookLibrary: Game Variant is " .. tostring(Variant) .. " -> Found ".. tostring(Identifier));
	return Variant;
end

EMXHookLibrary.Internal.GetOriginalGameVariant = function()
	local Pointer = Logic.GetEntityScriptingValue(EMXHookLibrary.Internal.GlobalAdressEntity, -81);
	local Variant = ((Pointer ~= 9560772) and EMXHookLibrary.GameVariant.OriginalWithOffset) or EMXHookLibrary.GameVariant.Original;
	Framework.WriteToLog("EMXHookLibrary: Game Variant is " .. tostring(Variant) .. " -> Found ".. tostring(Pointer));
	return Variant;
end

EMXHookLibrary.Internal.ResetHookedValues = function(_source, _stringParam)
	if EMXHookLibrary_ResetValues and type(EMXHookLibrary_ResetValues) == "function" then
		EMXHookLibrary_ResetValues(_source, _stringParam)
	end

	if _source == 0 then
		Framework.CloseGame()
	elseif _source == 1 then
		Framework.RestartMap(_stringParam)
	elseif _source == 2 then
		Framework.LoadGameAndExitCurrentGame(_stringParam)
	elseif _source == 3 then
		Framework.LoadGame(_stringParam)
	else -- This should never happen!
		local Command = "EMXHookLibrary: No valid reset source ERROR! " .. tostring(_source) .. " - " .. tostring(_stringParam) .. "."
		Framework.WriteToLog(Command)
		assert(false, Command)
		return;
	end
end

EMXHookLibrary.Internal.OverrideLoadGameHandling = function()
	Logic.ExecuteInLuaLocalState([[	
		EMXHookLibrary = EMXHookLibrary or {}
		EMXHookLibrary.LoadGameAndExitCurrentGame = Framework.LoadGameAndExitCurrentGame;
		Framework.LoadGameAndExitCurrentGame = function(_savegameName)
			Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)
			GUI.SendScriptCommand("EMXHookLibrary.Internal.ResetHookedValues(2, \"".._savegameName.."\")")
		end
		
		EMXHookLibrary.LoadGame = Framework.LoadGame;
		Framework.LoadGame = function(_savegameName)
			Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)
			GUI.SendScriptCommand("EMXHookLibrary.Internal.ResetHookedValues(3, \"".._savegameName.."\")")
		end
		
		EMXHookLibrary.CloseGame = Framework.CloseGame;
		Framework.CloseGame = function()
			Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)
			GUI.SendScriptCommand("EMXHookLibrary.Internal.ResetHookedValues(0)")
		end
		
		EMXHookLibrary.RestartMap = Framework.RestartMap;
		Framework.RestartMap = function(_knightType)
			Game.GameTimeSetFactor(GUI.GetPlayerID(), 1)
			GUI.SendScriptCommand("EMXHookLibrary.Internal.ResetHookedValues(1, \"".._knightType.."\")")
		end
	]]);
end

EMXHookLibrary.Bugfixes.Initialize = function()
	-- Fix Crash when dismissing entertainer
	Logic.ExecuteInLuaLocalState([[	
		EMXHookLibrary = EMXHookLibrary or {}
		EMXHookLibrary.Bugfixes = EMXHookLibrary.Bugfixes or {}
		
		if EMXHookLibrary.Bugfixes.GUI_Merchant_SendBackClicked == nil then
			EMXHookLibrary.Bugfixes.GUI_Merchant_SendBackClicked = GUI_Merchant.SendBackClicked;
		end
		GUI_Merchant.SendBackClicked = function()
			local EntityID = GUI.GetSelectedEntity();
			if Logic.IsEntertainer(EntityID) == true then
				Sound.FXPlay2DSound("ui\\menu_click");
				GUI.SendScriptCommand("EMXHookLibrary.Bugfixes.FixEntertainerCrash(" .. tostring(EntityID) .. ");");
			else
				EMXHookLibrary.Bugfixes.GUI_Merchant_SendBackClicked();
			end
		end
	]]);
end

EMXHookLibrary.Bugfixes.FixEntertainerCrash = function(_entityID)
	-- In theory, you could also do this solely via Logic.SetEntityScriptingValue ...
	-- But i leave it up to the interested reader to do that ;)
	EMXHookLibrary.Internal.CalculateEntityIDToLogicObject(_entityID)("48", _entityID);
	Logic.ExecuteInLuaLocalState([[
		GUI.CommandMerchantToLeaveMarketplace(]] .. tostring(_entityID) .. [[);
	]]);
end

-- ************************************************************************************************************************************************************ --
-- Some Helpers
-- ************************************************************************************************************************************************************ --
function EMXHookLibrary.Helpers.qmod(a, b) return a - math.floor(a / b) * b end
function EMXHookLibrary.Helpers.Int2Float(num)
	if (num == 0) then
		return 0;
	end

	local sign = 1
	if (num < 0) then
		num = 2147483648 + num
		sign = -1
	end

	local frac = EMXHookLibrary.Helpers.qmod(num, 8388608)
	local headPart = (num - frac) / 8388608
	local expNoSign = EMXHookLibrary.Helpers.qmod(headPart, 256)
	local exp = expNoSign - 127
	local fraction = 1
	local fp = 0.5
	local check = 4194304
	for i = 23, 0, -1 do
		if (frac - check) > 0 then
			fraction = fraction + fp
			frac = frac - check
		end
		check = check / 2
		fp = fp / 2
	end
	
	return fraction * math.pow(2, exp) * sign
end

function EMXHookLibrary.Helpers.bitsInt(num)
	local t = {}
	while num > 0 do
		rest = EMXHookLibrary.Helpers.qmod(num, 2)
		table.insert(t, 1, rest)
		num = (num - rest) / 2
	end
	table.remove(t, 1)
	return t
end

function EMXHookLibrary.Helpers.bitsFrac(num, t)
	for i = 1, 48 do
		num = num * 2
		if(num >= 1) then
			table.insert(t, 1)
			num = num - 1
		else
			table.insert(t, 0)
		end
		if(num == 0) then
			return t
		end
	end
	return t
end

function EMXHookLibrary.Helpers.Float2Int(fval)
	if (fval == 0) then
		return 0;
	end

	local signed = false
	if (fval < 0) then
		signed = true
		fval = fval * -1
	end
	
	local outval = 0
	local bits
	local exp = 0
	if fval >= 1 then
		local intPart = math.floor(fval)
		local fracPart = fval - intPart
		bits = EMXHookLibrary.Helpers.bitsInt(intPart)
		exp = table.getn(bits)
		EMXHookLibrary.Helpers.bitsFrac(fracPart, bits)
	else
		bits = {}
		EMXHookLibrary.Helpers.bitsFrac(fval, bits)
		while (bits[1] == 0) do
			exp = exp - 1
			table.remove(bits, 1)
		end
		exp = exp - 1
		table.remove(bits, 1)
	end

	local bitVal = 4194304
	local start = 1
	for bpos = start, 23 do
		local bit = bits[bpos]
		if (not bit) then
			break;
		end

		if (bit == 1) then
			outval = outval + bitVal
		end
		bitVal = bitVal / 2
	end

	outval = outval + (exp + 127) * 8388608

	if (signed) then
		outval = outval - 2147483648
	end

	return outval;
end

function EMXHookLibrary.Helpers.BitAnd(a, b)
	local result = 0
	local bitval = 1
	while a > 0 and b > 0 do
		if a % 2 == 1 and b % 2 == 1 then
			result = result + bitval
		end
		bitval = bitval * 2 
		a = math.floor(a / 2)
		b = math.floor(b / 2)
	end
	return result;
end

function EMXHookLibrary.Helpers.ConvertWideCharToMultiByte(_string)
	local HexString = "";
	local Numbers = {};
	
	local CurrentCharacter = 0;
	for i = 1, #_string, 1 do
		CurrentCharacter = _string:sub(i, i);
		HexString = "00" .. string.format("%0x", string.byte(CurrentCharacter)) .. HexString
		
		if math.fmod(i, 2) == 0 or i == #_string then
			Numbers[#Numbers + 1] = tonumber("0x" .. HexString);
			HexString = "";
		end
	end

	Numbers[#Numbers + 1] = 0;
	return Numbers;
end
-- ************************************************************************************************************************************************************ --
-- Here starts the BigNum - Code (minified, since it does not change)
-- ************************************************************************************************************************************************************ --
function BigNum.new(QDnlt)local LmcA2auZ={}setmetatable(LmcA2auZ,BigNum.mt)
BigNum.change(LmcA2auZ,QDnlt)return LmcA2auZ end;function BigNum.mt.sub(Q,ZA)
local _IQQ=BigNum.new()
BigNum.sub(BigNum.new(Q),BigNum.new(ZA),_IQQ)return _IQQ end
function BigNum.mt.add(XpkjA,pVRj)
local fuZ3z86=BigNum.new()
BigNum.add(BigNum.new(XpkjA),BigNum.new(pVRj),fuZ3z86)return fuZ3z86 end;function BigNum.mt.mul(er,DFb100j)local XL_=BigNum.new()
BigNum.mul(BigNum.new(er),BigNum.new(DFb100j),XL_)return XL_ end
function BigNum.mt.div(WYdR,QKKks_zt)
local Are7xU=BigNum.new()local yxjl=BigNum.new()
BigNum.div(BigNum.new(WYdR),BigNum.new(QKKks_zt),Are7xU,yxjl)return Are7xU,yxjl end
function BigNum.mt.tostring(ZG)local Vu0cCAf=""local q=""
if ZG==nil then return"nil"elseif ZG.len>0 then
for kP7O5=ZG.len-2,0,-1 do for lqT=0,
BigNum.RADIX_LEN-string.len(ZG[kP7O5])-1 do
q=q..'0'end;q=q..ZG[kP7O5]end;q=ZG[ZG.len-1]..q
if ZG.signal=='-'then q=ZG.signal..q end;return q else return""end end
function BigNum.mt.eq(mP3mlD,PrPyxMK)return
BigNum.eq(BigNum.new(mP3mlD),BigNum.new(PrPyxMK))end;function BigNum.mt.lt(tczrIB,a)return
BigNum.lt(BigNum.new(tczrIB),BigNum.new(a))end;function BigNum.mt.le(wqU76o,LB1Z)return
BigNum.le(BigNum.new(wqU76o),BigNum.new(LB1Z))end
function BigNum.mt.unm(N9L)
local hDc_M=BigNum.new(N9L)
if hDc_M.signal=='+'then hDc_M.signal='-'else hDc_M.signal='+'end;return hDc_M end;BigNum.mt.__metatable="hidden"
BigNum.mt.__tostring=BigNum.mt.tostring;BigNum.mt.__add=BigNum.mt.add
BigNum.mt.__sub=BigNum.mt.sub;BigNum.mt.__mul=BigNum.mt.mul
BigNum.mt.__div=BigNum.mt.div;BigNum.mt.__unm=BigNum.mt.unm
BigNum.mt.__eq=BigNum.mt.eq;BigNum.mt.__le=BigNum.mt.le
BigNum.mt.__lt=BigNum.mt.lt
setmetatable(BigNum.mt,{__index="inexistent field",__newindex="not available",__metatable="hidden"})
function BigNum.add(qW0lRiD1,iD1IUx,JLCOx_ak)local hPQ=0;local R1FIoQI=0;local NsoTwDs=0;local HGli='+'local iy=0
if qW0lRiD1 ==nil or iD1IUx==nil or JLCOx_ak==nil then
assert(false,"Function BigNum.add: parameter nil")elseif qW0lRiD1.signal=='-'and iD1IUx.signal=='+'then
qW0lRiD1.signal='+'BigNum.sub(iD1IUx,qW0lRiD1,JLCOx_ak)if not
rawequal(qW0lRiD1,JLCOx_ak)then qW0lRiD1.signal='-'end;return 0 elseif
qW0lRiD1.signal=='+'and iD1IUx.signal=='-'then iD1IUx.signal='+'
BigNum.sub(qW0lRiD1,iD1IUx,JLCOx_ak)
if not rawequal(iD1IUx,JLCOx_ak)then iD1IUx.signal='-'end;return 0 elseif qW0lRiD1.signal=='-'and iD1IUx.signal=='-'then
HGli='-'end;iy=JLCOx_ak.len
if qW0lRiD1.len>iD1IUx.len then hPQ=qW0lRiD1.len else
hPQ=iD1IUx.len;qW0lRiD1,iD1IUx=iD1IUx,qW0lRiD1 end
for R1FIoQI=0,hPQ-1 do
if iD1IUx[R1FIoQI]~=nil then JLCOx_ak[R1FIoQI]=qW0lRiD1[R1FIoQI]+
iD1IUx[R1FIoQI]+NsoTwDs else JLCOx_ak[R1FIoQI]=
qW0lRiD1[R1FIoQI]+NsoTwDs end
if JLCOx_ak[R1FIoQI]>=BigNum.RADIX then JLCOx_ak[R1FIoQI]=JLCOx_ak[R1FIoQI]-
BigNum.RADIX;NsoTwDs=1 else NsoTwDs=0 end end;if NsoTwDs==1 then JLCOx_ak[hPQ]=1 end
JLCOx_ak.len=hPQ+NsoTwDs;JLCOx_ak.signal=HGli
for R1FIoQI=JLCOx_ak.len,iy do JLCOx_ak[R1FIoQI]=nil end;return 0 end
function BigNum.sub(m6SCS0,NUhYw6R4,Hv)local Ch=0;local urkh=0;local zhzpBSx=0;local rHSjalVy=0
if m6SCS0 ==nil or NUhYw6R4 ==nil or
Hv==nil then assert(false,"Function BigNum.sub: parameter nil")elseif m6SCS0.signal=='-'and NUhYw6R4.signal=='+'then
m6SCS0.signal='+'BigNum.add(m6SCS0,NUhYw6R4,Hv)Hv.signal='-'if not
rawequal(m6SCS0,Hv)then m6SCS0.signal='-'end;return 0 elseif
m6SCS0.signal=='-'and NUhYw6R4.signal=='-'then m6SCS0.signal='+'
NUhYw6R4.signal='+'BigNum.sub(NUhYw6R4,m6SCS0,Hv)if not rawequal(m6SCS0,Hv)then
m6SCS0.signal='-'end;if not rawequal(NUhYw6R4,Hv)then
NUhYw6R4.signal='-'end;return 0 elseif
m6SCS0.signal=='+'and NUhYw6R4.signal=='-'then NUhYw6R4.signal='+'BigNum.add(m6SCS0,NUhYw6R4,Hv)if not
rawequal(NUhYw6R4,Hv)then NUhYw6R4.signal='-'end;return 0 end
if BigNum.compareAbs(m6SCS0,NUhYw6R4)==2 then
BigNum.sub(NUhYw6R4,m6SCS0,Hv)Hv.signal='-'return 0 else Ch=m6SCS0.len end;rHSjalVy=Hv.len;Hv.len=0
for urkh=0,Ch-1 do
if NUhYw6R4[urkh]~=nil then Hv[urkh]=m6SCS0[urkh]-
NUhYw6R4[urkh]-zhzpBSx else Hv[urkh]=
m6SCS0[urkh]-zhzpBSx end;if Hv[urkh]<0 then Hv[urkh]=BigNum.RADIX+Hv[urkh]zhzpBSx=1 else
zhzpBSx=0 end
if Hv[urkh]~=0 then Hv.len=urkh+1 end end;Hv.signal='+'if Hv.len==0 then Hv.len=1;Hv[0]=0 end;if zhzpBSx==1 then
assert(false,"Error in function sub")end;for urkh=Hv.len,BigNum.max(rHSjalVy,Ch-1)do
Hv[urkh]=nil end;return 0 end
function BigNum.mul(TjhsnP,t5jzEd9,JZAU2)local zPXTTg=0;j=0;local seMLr=BigNum.new()local qX=0;local h_8=0;local xL7OTb=JZAU2.len
if TjhsnP==nil or t5jzEd9 ==nil or JZAU2 ==nil then
assert(false,"Function BigNum.mul: parameter nil")elseif TjhsnP.signal~=t5jzEd9.signal then
BigNum.mul(TjhsnP,-t5jzEd9,JZAU2)JZAU2.signal='-'return 0 end;JZAU2.len=(TjhsnP.len)+ (t5jzEd9.len)for zPXTTg=1,JZAU2.len
do JZAU2[zPXTTg-1]=0 end;for zPXTTg=JZAU2.len,xL7OTb do
JZAU2[zPXTTg]=nil end
for zPXTTg=0,TjhsnP.len-1 do
for w8T3f=0,t5jzEd9.len-1 do h_8=(TjhsnP[zPXTTg]*
t5jzEd9[w8T3f]+h_8)h_8=h_8+JZAU2[
zPXTTg+w8T3f]
JZAU2[zPXTTg+w8T3f]=math.mod(h_8,BigNum.RADIX)qX=JZAU2[zPXTTg+w8T3f]
h_8=math.floor(h_8/BigNum.RADIX)end
if h_8 ~=0 then JZAU2[zPXTTg+t5jzEd9.len]=h_8 end;h_8=0 end
for zPXTTg=JZAU2.len-1,1,-1 do if
JZAU2[zPXTTg]~=nil and JZAU2[zPXTTg]~=0 then break else JZAU2[zPXTTg]=nil end;JZAU2.len=
JZAU2.len-1 end;return 0 end
function BigNum.div(K,qL,vfIyB,quNsijN)local QUh2tc=BigNum.new()local qboV=BigNum.new()
local nSBOx7=BigNum.new("1")local u=BigNum.new("0")if BigNum.compareAbs(qL,u)==0 then
assert(false,"Function BigNum.div: Division by zero")end
if K==nil or qL==nil or vfIyB==nil or quNsijN==nil then
assert(false,"Function BigNum.div: parameter nil")elseif K.signal=="+"and qL.signal=="-"then qL.signal="+"
BigNum.div(K,qL,vfIyB,quNsijN)qL.signal="-"vfIyB.signal="-"return 0 elseif
K.signal=="-"and qL.signal=="+"then K.signal="+"BigNum.div(K,qL,vfIyB,quNsijN)K.signal="-"if
quNsijN<u then BigNum.add(vfIyB,nSBOx7,vfIyB)
BigNum.sub(qL,quNsijN,quNsijN)end;vfIyB.signal="-"return 0 elseif
K.signal=="-"and qL.signal=="-"then K.signal="+"qL.signal="+"
BigNum.div(K,qL,vfIyB,quNsijN)K.signal="-"if quNsijN<u then BigNum.add(vfIyB,nSBOx7,vfIyB)
BigNum.sub(qL,quNsijN,quNsijN)end;qL.signal="-"return 0 end;QUh2tc.len=K.len-qL.len-1
BigNum.change(vfIyB,"0")BigNum.change(quNsijN,"0")BigNum.copy(K,quNsijN)
while(BigNum.compareAbs(quNsijN,qL)~=2)do
if quNsijN[quNsijN.len-1]>=qL[qL.len-1]then
BigNum.put(QUh2tc,math.floor(quNsijN[quNsijN.len-1]/
qL[qL.len-1]),quNsijN.len-qL.len)QUh2tc.len=quNsijN.len-qL.len+1 else
BigNum.put(QUh2tc,math.floor((quNsijN[
quNsijN.len-1]*BigNum.RADIX+
quNsijN[quNsijN.len-2])/
qL[qL.len-1]),
quNsijN.len-qL.len-1)QUh2tc.len=quNsijN.len-qL.len end
if quNsijN.signal~=qL.signal then QUh2tc.signal="-"else QUh2tc.signal="+"end;BigNum.add(QUh2tc,vfIyB,vfIyB)QUh2tc=QUh2tc*qL
BigNum.sub(quNsijN,QUh2tc,quNsijN)end;if quNsijN.signal=='-'then BigNum.decr(vfIyB)
BigNum.add(qL,quNsijN,quNsijN)end;return 0 end;function BigNum.eq(K,i1)
if BigNum.compare(K,i1)==0 then return true else return false end end
function BigNum.lt(zz1QI,kFTAh)if
BigNum.compare(zz1QI,kFTAh)==2 then return true else return false end end
function BigNum.le(LBf,dijn4Ph)local CO1=-1;CO1=BigNum.compare(LBf,dijn4Ph)if
CO1 ==0 or CO1 ==2 then return true else return false end end
function BigNum.compareAbs(RlZo,SUn)
if RlZo==nil or SUn==nil then
assert(false,"Function compare: parameter nil")elseif RlZo.len>SUn.len then return 1 elseif RlZo.len<SUn.len then return 2 else local Ib4;for Ib4=RlZo.len-1,0,-1 do
if RlZo[Ib4]>
SUn[Ib4]then return 1 elseif RlZo[Ib4]<SUn[Ib4]then return 2 end end end;return 0 end
function BigNum.compare(fjV1G2,Do)local _=0
if fjV1G2 ==nil or Do==nil then
assert(false,"Funtion BigNum.compare: parameter nil")elseif fjV1G2.signal=='+'and Do.signal=='-'then return 1 elseif
fjV1G2.signal=='-'and Do.signal=='+'then return 2 elseif
fjV1G2.signal=='-'and Do.signal=='-'then _=1 end
if fjV1G2.len>Do.len then return 1+_ elseif fjV1G2.len<Do.len then return 2-_ else local TqYJ4
for TqYJ4=fjV1G2.len-1,0,
-1 do if fjV1G2[TqYJ4]>Do[TqYJ4]then return 1+_ elseif fjV1G2[TqYJ4]<Do[TqYJ4]then
return 2-_ end end end;return 0 end
function BigNum.copy(DI,b)
if DI~=nil and b~=nil then local E;for E=0,DI.len-1 do b[E]=DI[E]end
b.len=DI.len else assert(false,"Function BigNum.copy: parameter nil")end end
function BigNum.change(KMw7_i1s,CQi)local nHlJ=0;local lw4Q7kbl=0;local CQi=CQi;local IN;local QYf1=0
if KMw7_i1s==nil then
assert(false,"BigNum.change: parameter nil")elseif type(KMw7_i1s)~="table"then
assert(false,"BigNum.change: parameter error, type unexpected")elseif CQi==nil then KMw7_i1s.len=1;KMw7_i1s[0]=0;KMw7_i1s.signal="+"elseif type(CQi)==
"table"and CQi.len~=nil then for RfsnisO=0,CQi.len do
KMw7_i1s[RfsnisO]=CQi[RfsnisO]end
if
CQi.signal~='-'and CQi.signal~='+'then KMw7_i1s.signal='+'else KMw7_i1s.signal=CQi.signal end;QYf1=KMw7_i1s.len;KMw7_i1s.len=CQi.len elseif type(CQi)=="string"or type(CQi)==
"number"then
if string.sub(CQi,1,1)=='+'or
string.sub(CQi,1,1)=='-'then
KMw7_i1s.signal=string.sub(CQi,1,1)CQi=string.sub(CQi,2)else KMw7_i1s.signal='+'end;CQi=string.gsub(CQi," ","")
local lvW2ga=string.find(CQi,"e")
if lvW2ga~=nil then CQi=string.gsub(CQi,"%.","")
local T7RKP=string.sub(CQi,lvW2ga+1)T7RKP=tonumber(T7RKP)if T7RKP~=nil and T7RKP>0 then
T7RKP=tonumber(T7RKP)else
assert(false,"Function BigNum.change: string is not a valid number")end;CQi=string.sub(CQi,1,
lvW2ga-2)
for _L6Bs=string.len(CQi),T7RKP do CQi=CQi.."0"end else lvW2ga=string.find(CQi,"%.")if lvW2ga~=nil then
CQi=string.sub(CQi,1,lvW2ga-1)end end;IN=string.len(CQi)QYf1=KMw7_i1s.len
if(IN>BigNum.RADIX_LEN)then local SH=IN-(math.floor(IN/BigNum.RADIX_LEN)*BigNum.RADIX_LEN)
for wU4wYbA9=1,IN-SH,BigNum.RADIX_LEN do
KMw7_i1s[nHlJ]=tonumber(string.sub(CQi,- (wU4wYbA9+BigNum.RADIX_LEN-1),-wU4wYbA9))
if KMw7_i1s[nHlJ]==nil then
assert(false,"Function BigNum.change: string is not a valid number")KMw7_i1s.len=0;return 1 end;nHlJ=nHlJ+1;lw4Q7kbl=lw4Q7kbl+1 end
if(SH~=0)then KMw7_i1s[nHlJ]=tonumber(string.sub(CQi,1,SH))KMw7_i1s.len=lw4Q7kbl+1 else KMw7_i1s.len=lw4Q7kbl end
for fFeQcIM=KMw7_i1s.len-1,1,-1 do if KMw7_i1s[fFeQcIM]==0 then KMw7_i1s[fFeQcIM]=nil;KMw7_i1s.len=
KMw7_i1s.len-1 else break end end else KMw7_i1s[nHlJ]=tonumber(CQi)KMw7_i1s.len=1 end else
assert(false,"Function BigNum.change: parameter error, type unexpected")end;if QYf1 ~=nil then
for JEHSHPh3=KMw7_i1s.len,QYf1 do KMw7_i1s[JEHSHPh3]=nil end end;return 0 end
function BigNum.put(bb,o5e6fP,iq7ol)for eMV=0,iq7ol-1 do bb[eMV]=0 end;bb[iq7ol]=o5e6fP;for WDTNkTD=iq7ol+1,bb.len do bb[WDTNkTD]=
nil end;bb.len=iq7ol;return 0 end
function BigNum.max(Oejsws,CkD73N0)if Oejsws>CkD73N0 then return Oejsws else return CkD73N0 end end;function BigNum.decr(PlwhaRKJ)
BigNum.sub(PlwhaRKJ,BigNum.new("1"),PlwhaRKJ)return 0 end
-- #EOF
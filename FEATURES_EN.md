# Features
All functions reside in the global **"EMXHookLibrary"** table and must be called accordingly. (e.g. SetPlayerColorRGB() -> EMXHookLibrary.SetPlayerColorRGB())

---

## Entity Logic
These functions influence the game logic of entities and entity types.
### SetEntityTypeFullCost(_entityType, _costs, _overrideSecondGoodPointer)
Sets new costs for an entity type. Two goods can also be set if the type in the original game only had one good entry.
If the second entry is a production good (e.g. Goods.G_Cheese), the **building cost system BCS** should be used.
If the type in the original game only had one cost entry (e.g. city buildings), **_overrideSecondGoodPointer == true** must be set. 
For entities with two entries (e.g. decorative buildings), this is not necessary.
This function can also add costs to entity types that previously had no entries (e.g. village buildings).
**Note:** This also works with units, e.g., ammunition carts/thieves/wall catapults.
A table containing the original pointers is returned, allowing you to reset the values.

### ResetEntityTypeFullCost(_entityType, _resetPointers)
Resets the values set by `EMXHookLibrary.SetEntityTypeFullCost`.

### SetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _costs, _overrideSecondGoodPointer, _overrideUpgradeCostHandling)
Analogous to `EMXHookLibrary.SetEntityTypeFullCost`, the upgrade costs of an entity type can be changed here. 
If the type in the original game only had one cost entry (e.g., city buildings), **_overrideSecondGoodPointer == true** must be set. 
For entities with two entries (e.g. Storehouse), this is not necessary. 
**_overrideUpgradeCostHandling** is necessary if goods other than wood, stone, or iron are to be used, or if two goods instead of one are to be set as costs.
A table containing the original pointers is returned, allowing you to reset the values.

### ResetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _resetPointers)
Resets the values set by `EMXHookLibrary.SetEntityTypeUpgradeCost`.

### SetEntityTypeMaxHealth(_entityType, _newMaxHealth)
Sets the maximum health points (HP) of an entity type.

### SetSermonSettlerLimit(_cathedralEntityType, _upgradeLevel, _newLimit)
Sets the limit of settlers attending a sermon per cathedral upgrade level. (Default: **10, 15, 30, 60**)

### SetSoldierLimit(_castleEntityType, _upgradeLevel, _newLimit)
Sets the soldier limit per castle upgrade level. (Default: **25, 43, 61, 91**)

### SetEntityTypeSpouseProbabilityFactor(_entityType, _factor)
Sets the probability that settlers will find a spouse during a festival. (Default: **0.3**)
This can, for example, enable the bathhouse to employ spouses.

### SetTerritoryAcquiringBuildingID(_territoryID, _buildingID)
Sets the acquiring building for a territory. Normally this is the outpost.

### SetEntityTypeBlocking(_entityType, _blocking, _isBuildBlocking)
Sets blocking or build-blocking for an entity type. _blocking must always be a table with the values.
Example: `EMXHookLibrary.SetEntityTypeBlocking(Entities.B_Cathedral_Big, {0, 0, 0, 0}, false) -- Removes the blocking of the cathedral`.

### SetEntityTypeOutStockCapacity(_entityType, _upgradeLevel, _newLimit)
Sets the maximum outstock of an entity type based on its upgrade level. (Default: **3, 6, 9 or just 9**).
Works also for storehouses (or anything with an outstock capacity).
**Note:** Unlike `EMXHookLibrary.SetMaxBuildingStockSize`, this applies to newly constructed buildings of a type.

### SetMaxStorehouseStockSize(_storehouseID, _maxStockSize)
Sets the maximum outstock for a specific storehouse.
**Note:** Unlike `EMXHookLibrary.SetEntityTypeOutStockCapacity`, this applies only to individual storehouses!

### SetMaxBuildingStockSize(_buildingID, _maxStockSize)
Sets the maximum outstock for a specific building.
**Note:** Unlike `EMXHookLibrary.SetEntityTypeOutStockCapacity`, this applies only to individual buildings!

### SetBuildingInStockGood(_buildingID, _newGood)
Sets a new good as instock for a building.

### CreateBuildingInStockGoods(_buildingID, _newGoods)
Allocates memory and sets new instock goods for a building.
_newGoods must look like this: **{Goods.G_Grain, Goods.G_Wool}**.
A table containing the original pointers is returned, allowing you to reset the values.

### SetBuildingTypeOutStockGood(_buildingID, _newGood, _setEntityTypeProduct)
Sets a new good as outstock for a building. If **_setEntityTypeProduct ~= nil**, the product of the entity type will also be set; otherwise, only the outstock of a building is affected.

### AddBehaviorToEntityType(_entityType, _behaviorName)
Copies a behavior reference from one entity type to another. All subsequently created entities will have this behavior. Possible behaviors are:
**"CInteractiveObjectBehavior", "CMountableBehavior", "CFarmAnimalBehavior", "CAnimalMovementBehavior", "CAmmunitionFillerBehavior"**.
This can be reset using `EMXHookLibrary.ResetEntityBehaviors`.
Example:`EMXHookLibrary.AddBehaviorToEntityType(Entities.B_Bakery, "CInteractiveObjectBehavior") -- Makes bakeries interactive objects`.

### ResetEntityBehaviors(_entityType, _resetPointers)
Resets the behavior of an entity type. _resetPointers is a table returned by `EMXHookLibrary.AddBehaviorToEntityType`.

### SetSettlersWorkBuilding(_settlerID, _buildingID)
Sets the workplace of a settler. This allows more than 3 settlers to work in one building.
**Note:** The settler must already be assigned to a building before switching!
(For more than 3 settlers, `EMXHookLibrary.SetTypeAndMaxNumberOfWorkersForBuilding` should be adjusted beforehand.)

### SetTypeAndMaxNumberOfWorkersForBuilding(_entityType, _maxWorkers, _workerType)
Sets a new maximum number and type of workers for a building type.

---

## Display and Representation of Entities
These functions influence the display of entities and their models.
### GetModel(_entityID)
Returns the current model of an entity. (Analogous to `Logic.SetModel`)

### SetEntityTypeMinimapIcon(_entityType, _iconIndex)
Sets a minimap icon for an entity type. Icons from the icon table are possible. 0 removes the icon.
For entities already on the map, the function should be called in the FMA; otherwise, it only affects newly created entities.

### SetEntityDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
Allows setting various models for buildings. _params must be a table with models.
_paramType must be a string with the type. Possible types: **"Models", "UpgradeSite", "Destroyed", "Lights"**.
_model sets the current model, which can also be nil.
Before changing, it is best to check in the entity's definition XML. Both an (existing) entity ID and an entity type can be specified.
Example: `EMXHookLibrary.SetEntityDisplayModelParameters(Entities.B_StoreHouse, "Models", {Models.Buildings_B_Jewelry_Buildingsite_1,
Models.Buildings_B_Jewelry_Buildingsite_1, Models.Buildings_B_Jewelry_Buildingsite_1,
Models.Buildings_B_Jewelry_Buildingsite_1}, {Models.Buildings_B_Jewelry_Buildingsite_1})`.

### SetBuildingDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
Analogous to `EMXHookLibrary.SetEntityDisplayModelParameters`, the models of (production) buildings can be changed here.
Possible types: **"Yards", "Roofs", "RoofDestroyed", "UpgradeSite", "Floors", "Gables", "Lights", "FireCounts"**.

### SetEntityDisplayProperties(_entityIDOrType, _property, _value)
Allows adjusting various display parameters of an entity or entity type. Possible properties are:
**"ShowDestroyedModelAt", "MaxDarknessFactor", "ExplodeOnDestroyedModel", "SnowFactor", "SeasonColorSet", "LODDistance", "ConstructionSite", "Decal"**.
Some parameters must be set as float. It is best to ask or check in the entity's definition XML.

### SetAndReloadModelSpecificShader(_modelID, _shaderName)
Changes the shader of a model type. Possible shaders can be found in the "Effects" folder. Examples:
**"Object_Aligned_Additive", "ShipMovementEx", "WealthLightObject", "IceCliff", "Waterfall", "StaticBanner"**.
Returns the original value for resetting.
**Caution:** This may cause a small memory leak (148 bytes); so use sparingly.

### ModifyModelPropertiesByReferenceType(_modelID, _referenceModelID, _entryIndex)
Changes parameters of a model type by copying values from a reference type. Returns the original value for resetting.
Example: `EMXHookLibrary.ModifyModelProperties(Models.Doodads_D_NA_Cliff_Set01_Deco01, Models.Doodads_D_NE_Cliff_Set03_Sheet01, 0)`.
This sets the shader effect of the second model for the first model.
**Caution:** This may cause a small memory leak (148 bytes); so use sparingly.

### ResetModelProperties(_modelID, _entryIndex, _resetValue)
Resets changed parameters of a model type.

### ChangeModelFilePath(_modelID, _filePath, _pathLength)
Changes the file path of a model.
Example:`ChangeModelFilePath(Models.Buildings_B_Barracks, "Doodads\\D_NA_ExcavationSite_3\0\0", 29)`.
If the model has not yet been loaded, it will be replaced in the ID manager by **D_NA_ExcavationSite_3**.

---

## Global Logic
These functions influence the global game logic of the world.
### SetTerritoryGoldCostByIndex(_arrayIndex, _price)
Sets new gold costs for territories, ranging from index 1 to 5 (**1 = Low, 5 = Very Expensive**).

### SetSettlerIllnessCount(_newCount)
Sets the number of settlers after which diseases can break out. (Default: **151**)

### SetWealthGoodDecayPerSecond(_decay)
Sets the value by which wealth goods in buildings need to be replenished. (Default: **0**)

### SetCarnivoreHealingSeconds(_newTime)
Sets the time predators need to regenerate their health.

### SetKnightResurrectionTime(_newTime)
Sets the time the knight needs to recover in the castle. (Default: **60000**)

### SetMaxBuildingTaxAmount(_newTaxAmount)
Sets the maximum tax income that city buildings can hold.

### SetSettlerLimit(_cathedralIndex, _limit)
Sets a new settler limit depending on the cathedral/church upgrade level. (From **0 - 6**)

### SetAmountOfTaxCollectors(_newAmount)
Sets the maximum number of tax collectors that can be generated. (Default: **6**)

### SetBuildingKnockDownCompensation(_percent)
Sets the refund factor when demolishing a building. (Default: **50**)

### SetTerritoryCombatBonus(_newFactor)
Sets the factor by which troops are stronger in their own territories. (Default: **0.2**)

### SetCathedralCollectAmount(_newAmount)
Sets the amount of gold a settler donates when attending a sermon. (Default: **5**)

### SetFireHealthDecreasePerSecond(_newAmount)
Sets the damage caused by fire per second. (Default: **5**)

### SetBallistaAmmunitionAmount(_amount)
Sets the maximum ammunition amount for ballistae (wall-mounted catapults) per type.

### SetMilitaryMetaFormationParameters(_distances)
Sets parameters for troop formations. The parameter _distances must be a table in the following format:
`-- {_rowDistance, _colDistance, _cartRowDistance, _cartColDistance, _engineRowDistance, _engineColDistance}`. 
Unnecessary values can be nil.

### ReplaceUpgradeCategoryEntityType(_upgradeCategory, _newEntityType)
Changes the EntityType of an upgrade category. This can, for example, allow village buildings to be placed by players.

### SetGoodTypeParameters(_goodType, _requiredResource, _amount, _goodCategory, _animationParameters)
Sets the required production material for a good and/or its required amount. (e.g., Goods.G_Carcass -> Goods.G_Sausage)
Unnecessary parameters can be nil. 
The ratio is 1:1 by default but can be freely modified. (e.g., 3 wheat for 1 bread, 2 stone for 1 broom, etc.)

### CopyGoodTypePointer(_good, _copyGood)
Allows parameters of one GoodType (e.g., **RequiredResource**) to be referenced by other Goods that lack these entries. 
A table containing the original pointers is returned so values can be reset.

### CreateGoodTypeRequiredResources(_goodType, _requiredResources)
Allows parameters of one GoodType (e.g., RequiredResource) to be used by other Goods that lack these entries. 
Unlike `EMXHookLibrary.CopyGoodTypePointer`, a new array is created in allocated memory. _requiredResources must look like this: 
**{{_resource, _amount, _supplier}, {_resource, _amount, _supplier}, ...}** 
Example: `EMXHookLibrary.CreateGoodTypeRequiredResources(Goods.G_Soap, {{Goods.G_Wool, 3, EntityCategories.GC_Food_Supplier}, {Goods.G_Stone, 2, EntityCategories.GC_Food_Supplier}})`
A table containing the original pointers is returned so values can be reset.

### ResetGoodTypePointer(_goodType, _resetPointers)
Resets the values of `EMXHookLibrary.CreateGoodTypeRequiredResources` and `EMXHookLibrary.CopyGoodTypePointer`.

### ToggleDEBUGMode(_magicWord, _setNewMagicWord)
Allows activating Development Mode in the History Edition. 
_magicWord must first be extracted from the OV and can then be set PC-specifically in the HE. 
Works **ONLY** in the Steam HE. For the Ubisoft HE, the [S6Patcher](https://github.com/Eisenmonoxid/S6Patcher) should be used!

### ModifyTerrainHeightWithoutTextureUpdate(_posX, _posY, _height)
Changes the terrain height at a position without immediately updating the textures underneath. This enables "floating" entities, for instance. 
Example: `EMXHookLibrary.ModifyTerrainHeightWithoutTextureUpdate(5000, 5000, 5000)`.

### EditFestivalProperties(_festivalDuration, _promotionDuration, _promotionParticipantLimit, _festivalParticipantLimit)
Changes one or more parameters of festivals (promotion or regular festivals). 
Unnecessary parameters can be nil. 
Editable parameters include duration and participant limits.

---

## Global Display and Visualization
These functions influence the global display of the world.
### EditStringTableText(_IDManagerEntryIndex, _newString, _useAlternativePointer)
Modifies a StringTable entry. The EntryIndex must first be extracted, and the character limit must be observed. 
Details on usage are available upon request. 
Example: "Saraya" -> "Testknight": `EMXHookLibrary.EditStringTableText(2100, "Testknight")`.

### SetColorSetColorRGB(_colorSetName, _season, _rgb, _wetFactor)
Sets the colors of a ColorSet per season. A table containing the original values is returned so the ColorSet can be reset. 
The name of the set can be found in the game directory folder. 
Example: `EMXHookLibrary.SetColorSetColorRGB("ME_FOW", 1, {0.32, 0.135, 0.4, 1}); -- FoW color for season spring in climate zone ME`

### SetPlayerColorRGB(_playerColorEntryIndex, _rgb)
Sets the player color of a player. _rgb must be a table with color values (from **0 - 255**). 
The alpha channel must always be **127**, and the first entry in the table. **0** and single-digit values must be represented with two digits [e.g., **9 -> 09**].
```
EMXHookLibrary.SetPlayerColorRGB(1, {127, 0, 0, 255, 255}) -- Yellow 
EMXHookLibrary.SetPlayerColorRGB(1, {127, 253, 112, 0, 0}) -- Dark Blue 
EMXHookLibrary.SetPlayerColorRGB(1, {127, 255, 255, 255}) -- White
```

### SetEGLEffectDuration(_effect, _duration)
Changes the display duration of an EGL_Effect. 
Example: `EMXHookLibrary.SetEGLEffectDuration(EGL_Effects.FXLightning, 2)`.

### ToggleRTSCameraMouseRotation(_enableMouseRotation, _optionalRotationSpeed)
Enables RTS camera rotation with CTRL + mouse wheel. Optionally, the rotation speed can also be set. (Default: **2500**)

### SetFogOfWarVisibilityFactor(_newFactor)
Sets the factor by which the Fog of War is applied in already revealed areas. (Default: **0.75**)

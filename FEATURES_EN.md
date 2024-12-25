# Features
All functions reside in the global **"EMXHookLibrary"** table and must be called accordingly. (e.g. SetPlayerColorRGB(_params) -> EMXHookLibrary.SetPlayerColorRGB(_params)).

---

## Entity Logic
These functions influence the game logic of entities and entity types.
### SetEntityTypeFullCost(_entityType, _costs, _overrideSecondGoodPointer)
- Sets new goods costs for an entity type. The cost table **_costs** must be structured as follows: `{Good, Amount, ...}`.
A maximum of 2 goods is possible.
- If the entity type in the game only has one cost entry (e.g., city buildings) and two new goods are to be set, it is necessary to set the parameter **_overrideSecondGoodPointer == true**. For entities that already have two entries by default (e.g., decoration buildings), this is not necessary.
- Both raw materials and gold can be used as goods. However, if the second entry is meant to be a production good (e.g., Goods.G_Cheese), the [Baukostensystem BCS](https://github.com/Eisenmonoxid/S6CostSystem) should be used.
- Can add costs to entity types that previously had no costs in the game (e.g., village buildings). For this, a new array is created in allocated memory.
- Can also change and add costs to units, e.g., ammunition carts/thieves/wall catapults.
- Returns a table containing the original pointers so the values can be reset. Reset function: `ResetEntityTypeFullCost(_entityType, _resetPointers)`.

### ResetEntityTypeFullCost(_entityType, _resetPointers)
- Resets the values of `EMXHookLibrary.SetEntityTypeFullCost`.

### SetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _costs, _overrideSecondGoodPointer, _overrideUpgradeCostHandling)
- Similar to `EMXHookLibrary.SetEntityTypeFullCost`, this can change the upgrade costs of an entity type.
- If the entity type in the game only has one cost entry (e.g., city buildings) and two are to be set, it is necessary to set the parameter **_overrideSecondGoodPointer == true**. For entities that already have two entries by default (e.g., the storehouse), this is not necessary.
- **_overrideUpgradeCostHandling** is required if goods other than wood, stone, or iron are used or if two goods instead of one are to be used as costs.
- Returns a table containing the original pointers so the values can be reset. Reset function: `ResetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _resetPointers)`.

### ResetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _resetPointers)
- Resets the values of `EMXHookLibrary.SetEntityTypeUpgradeCost`.

### SetEntityTypeMaxHealth(_entityType, _newMaxHealth)
- Sets the maximum health points (HP) of an entity type.
- This also affects all existing entities of this type.

### SetSermonSettlerLimit(_cathedralEntityType, _upgradeLevel, _newLimit) 
- Sets the settler limit for sermons per church or cathedral upgrade level.
- Default: **10, 15, 30, 60**.
- **_upgradeLevel** starts at 0 for the first level.

### SetSoldierLimit(_castleEntityType, _upgradeLevel, _newLimit)
- Sets the soldier limit per castle upgrade level.
- Default: **25, 43, 61, 91**.
- **_upgradeLevel** starts at 0 for the first level.

### SetEntityTypeSpouseProbabilityFactor(_entityType, _factor)
- Sets the probability that settlers at a festival find a spouse.
- Default: **0.3**.
- This allows, for example, bathhouses or resource buildings to employ spouses.

### SetTerritoryAcquiringBuildingID(_territoryID, _buildingID)
- Sets the acquiring building of a territory.
- Usually the outpost.

### SetEntityTypeBlocking(_entityType, _blocking, _isBuildBlocking)
- Sets the blocking or build-blocking of an entity type.
- **_blocking** must always be a table with the values.
- For example: `EMXHookLibrary.SetEntityTypeBlocking(Entities.B_Cathedral_Big, {0, 0, 0, 0}, false) -- Removes blocking of the cathedral`.
- If unclear, refer to the .xml of the entity type.

### SetEntityTypeOutStockCapacity(_entityType, _upgradeLevel, _newLimit)
- Sets the maximum outstock of an entity type based on its upgrade level.
- Default: **3, 6, 9 or only 9**.
- Works for anything with an outstock (e.g., storehouses).
- **WARNING:** Unlike `EMXHookLibrary.SetMaxBuildingStockSize`, this only affects newly created types.

### SetMaxStorehouseStockSize(_storehouseID, _maxStockSize)
- Sets the maximum outstock of a storehouse type.
- **WARNING:** Unlike `EMXHookLibrary.SetEntityTypeOutStockCapacity`, this affects individual storehouses!

### SetMaxBuildingStockSize(_buildingID, _maxStockSize)
- Sets the maximum outstock of an existing building.
- **WARNING:** Unlike `EMXHookLibrary.SetEntityTypeOutStockCapacity`, this affects individual buildings!

### SetBuildingInStockGood(_buildingID, _newGood)
- Sets a new instock good for a building.

### CreateBuildingInStockGoods(_buildingID, _newGoods)
- Allocates memory and sets new instock goods for a building.
- **_newGoods** must be structured as follows: **{Good, Good}**.
- Returns a table containing the original pointers so the values can be reset.
- **WARNING:** The same can be achieved using the function `Logic.AddGoodToStock(ID, Good, 0, true, true, true)`, making this function (more or less) obsolete.

### SetBuildingTypeOutStockGood(_buildingID, _newGood, _setEntityTypeProduct)
- Sets a new good as outstock for a building.
- If **_setEntityTypeProduct ~= nil**, the product of the entity type is also set; otherwise, only the outstock for a building.

### AddBehaviorToEntityType(_entityType, _behaviorName)
- Copies a reference of a behavior from one entity type to another. All subsequently created entities will possess the behavior.
- The possible behaviors are:  
**"CInteractiveObjectBehavior", "CMountableBehavior", "CFarmAnimalBehavior", "CAnimalMovementBehavior", "CAmmunitionFillerBehavior"**.
- Can be reset using `EMXHookLibrary.ResetEntityBehaviors`.
- For example: `EMXHookLibrary.AddBehaviorToEntityType(Entities.B_Bakery, "CInteractiveObjectBehavior") -- Makes bakeries interactive objects`.

### ResetEntityBehaviors(_entityType, _resetPointers)
- Resets the behavior of an entity type. _resetPointers is a table returned by `EMXHookLibrary.AddBehaviorToEntityType`.

### SetSettlersWorkBuilding(_settlerID, _buildingID)
- Sets the workplace of a settler. This allows more than 3 settlers to be employed at a building.
- **WARNING:** The settler must already be assigned to a building before it can be switched!
- For more than 3 settlers, `EMXHookLibrary.SetTypeAndMaxNumberOfWorkersForBuilding` should be set accordingly beforehand.

### SetTypeAndMaxNumberOfWorkersForBuilding(_entityType, _maxWorkers, _workerType)
- Sets a new maximum number and a new type of workers for a building type.

---

## Display and Visualization of Entities
These functions affect the visual representation of entities and their models.
### GetModel(_entityID)
- Returns the current model of an entity if one has been set.
- Analogous to `Logic.SetModel`.

### SetEntityTypeMinimapIcon(_entityType, _iconIndex)
- Sets a minimap icon for an entity type. Icons from the icon table can be used.
- **_iconIndex** 0 removes the icon.
- For entities already present on the map, this function should be called in the FMA; otherwise, only newly created entities are affected.

### SetEntityDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
- Allows setting various models for buildings.
- **_params** must be a table of models.
- **_paramType** must be a string specifying the type. Possible types include: **"Models", "UpgradeSite", "Destroyed", "Lights"**.
- _model sets the current model and can also be **nil**.
- Before making changes, it’s best to consult the entity’s definition XML file. Both an existing entity ID and a type can be provided.
- Example: 
  ```lua
  EMXHookLibrary.SetEntityDisplayModelParameters(Entities.B_StoreHouse, "Models", 
  {Models.Buildings_B_NPC_Cloister_ME, Models.Buildings_B_NPC_Storehouse_NE, Models.Buildings_B_NPC_Cloister_NE}, 
  {Models.Buildings_B_NPC_Storehouse_ME})
  -- Sets new models for the various upgrade levels of the storehouse.
  ```

### SetBuildingDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
- Similar to `EMXHookLibrary.SetEntityDisplayModelParameters`, but specifically for (production) buildings.
- Possible types: **"Yards", "Roofs", "RoofDestroyed", "UpgradeSite", "Floors", "Gables", "Lights", "FireCounts"**.

### SetEntityDisplayProperties(_entityIDOrType, _property, _value)
- Allows customization of various display parameters for an entity or entity type.
- Possible properties: **"ShowDestroyedModelAt", "MaxDarknessFactor", "ExplodeOnDestroyedModel", "SnowFactor", "SeasonColorSet", "LODDistance", "ConstructionSite", "Decal"**.
- Some parameters need to be set as floats; consult the entity type’s definition XML file.

### SetAndReloadModelSpecificShader(_modelID, _shaderName)
- Changes the shader of a model type. Possible shaders can be found in the "Effects" folder.
- Examples: **"Object_Aligned_Additive", "ShipMovementEx", "WealthLightObject", "IceCliff", "Waterfall", "StaticBanner"**.
- Returns the original value for resetting purposes.
- **NOTE:** This may cause a slight memory leak (148 bytes) if the model was already loaded by the game.

### ModifyModelPropertiesByReferenceType(_modelID, _referenceModelID, _entryIndex)
- Modifies parameters of a model type by copying values from a reference type.
- Returns the original value for resetting purposes.
- Example: 
  ```lua
  EMXHookLibrary.ModifyModelProperties(Models.Doodads_D_NA_Cliff_Set01_Deco01, Models.Doodads_D_NE_Cliff_Set03_Sheet01, 0)
  ```
  This sets the shader effect of the first model to match the second model.
- **NOTE:** This may cause a slight memory leak (148 bytes) if the model was already loaded by the game.

### ResetModelProperties(_modelID, _entryIndex, _resetValue)
- Resets modified parameters of a model type.

### ChangeModelFilePath(_modelID, _filePath, _pathLength)
- Changes the internal file path of a model.
- Example: 
  ```lua
  ChangeModelFilePath(Models.Buildings_B_Barracks, "Doodads\\D_NA_ExcavationSite_3\0\0", 29)
  ```
- If the model has not yet been loaded, it will be replaced in the ID manager by **D_NA_ExcavationSite_3**.

---

## Global Logic
These functions affect the global game logic of the world.
### SetTerritoryGoldCostByIndex(_arrayIndex, _price)
- Sets new gold costs for territories.
- Index ranges from **1 (Low) to 5 (Very Expensive)**.

### SetSettlerIllnessCount(_newCount)
- Sets the number of settlers required before diseases can break out.
- Default: **151**.

### SetWealthGoodDecayPerSecond(_decay)
- Sets the value by which wealth goods need to be replenished in buildings.
- Default: **0**.

### SetCarnivoreHealingSeconds(_newTime)
- Sets the time it takes for carnivores to regenerate their health.

### SetKnightResurrectionTime(_newTime)
- Sets the time a knight must recover in the castle.
- Default: **60000**.

### SetMaxBuildingTaxAmount(_newTaxAmount)
- Sets the maximum tax revenue that town buildings can hold.
- Default: **100**.

### SetSettlerLimit(_cathedralIndex, _limit)
- Sets a new settler limit depending on the cathedral/church upgrade level.
- The index ranges from **0 to 5**.
- Default: **50, 50, 100, 150, 200, 200**.

### SetAmountOfTaxCollectors(_newAmount)
- Sets the maximum number of tax collectors that can be generated.
- Default: **6**.

### SetBuildingKnockDownCompensation(_percent)
- Sets the refund factor for demolishing a building.
- Default: **50**.
- **50** equals 50%, meaning half the construction cost is refunded upon demolition.

### SetTerritoryCombatBonus(_newFactor)
- Sets the factor by which troops are stronger in their own territories.
- Default: **0.2**.
- This is added to the total combat strength.

### SetCathedralCollectAmount(_newAmount)
- Sets the amount of gold a settler donates during a sermon visit.
- Default: **5**.

### SetFireHealthDecreasePerSecond(_newAmount)
- Sets the damage caused by fire per second.
- Default: **5**.

### SetBallistaAmmunitionAmount(_amount)
- Sets the maximum ammunition for ballistas (wall catapult) per type.
- Default: **10**.

### SetMilitaryMetaFormationParameters(_distances)
- Sets certain parameters for troop formations.
- The **_distances** parameter must be a table in the following format:
  ```lua
  -- {_rowDistance, _colDistance, _cartRowDistance, _cartColDistance, _engineRowDistance, _engineColDistance}
  ```
- Unnecessary values can be **nil**.

### ReplaceUpgradeCategoryEntityType(_upgradeCategory, _newEntityType)
- Changes the entity type of an upgrade category.
- For example, this allows players to construct village buildings.

### SetGoodTypeParameters(_goodType, _requiredResource, _amount, _goodCategory, _animationParameters)
- Sets the required production goods for a resource and/or their quantities (e.g., Goods.G_Carcass -> Goods.G_Sausage).
- Unnecessary parameters can be **nil**.
- The default ratio is 1:1 but can be adjusted (e.g., 3 wheat for 1 bread, 2 stone for 1 broom, etc.).

### CopyGoodTypePointer(_good, _copyGood)
- Allows the use of certain parameters of a good type (e.g., **RequiredResource**) with goods that lack entries for these features.
- Creates a reference to another good type.
- Returns a table containing the original pointers for resetting purposes.

### CreateGoodTypeRequiredResources(_goodType, _requiredResources)
- Similar to `EMXHookLibrary.CopyGoodTypePointer`, but allocates new memory for an array.
- **_requiredResources** must look like: **{{_resource, _amount, _supplier}, {_resource, _amount, _supplier}, ...}**.
- Example: 
  ```lua
  EMXHookLibrary.CreateGoodTypeRequiredResources(Goods.G_Soap, {{Goods.G_Wool, 3, EntityCategories.GC_Food_Supplier}, 
  {Goods.G_Stone, 2, EntityCategories.GC_Food_Supplier}})
  ```
- Returns a table containing the original pointers for resetting purposes.

### ResetGoodTypePointer(_goodType, _resetPointers)
- Resets the values set by `EMXHookLibrary.CreateGoodTypeRequiredResources` and `EMXHookLibrary.CopyGoodTypePointer`.

### ToggleDEBUGMode(_magicWord, _setNewMagicWord)
- Enables or disables Development Mode in the original game (OV) and the Steam History Edition.
- **_magicWord** is either *256* or *257*, depending on the mode’s status.
- Only works in the Steam HE and the original game.
- For the Ubisoft HE, the [S6Patcher](https://github.com/Eisenmonoxid/S6Patcher) should be used!

### ModifyTerrainHeightWithoutTextureUpdate(_posX, _posY, _height)
- Changes the terrain height at a position without immediately updating the textures below it.
- This allows for "floating" entities, but only until the next blocking update.
- Example: 
  ```lua
  EMXHookLibrary.ModifyTerrainHeightWithoutTextureUpdate(5000, 5000, 5000)
  ```

### EditFestivalProperties(_festivalDuration, _promotionDuration, _promotionParticipantLimit, _festivalParticipantLimit)
- Adjusts one or more parameters of festivals (both promotion and normal festivals).
- Adjustable parameters include duration and participant limits.
- Unnecessary parameters can be **nil**.

---

## Global Display and Visualization
These functions affect the global display of the world.
### EditStringTableText(_IDManagerEntryIndex, _newString, _useAlternativePointer)
- Modifies a StringTable entry. The EntryIndex must first be retrieved, and the character limit must be respected.
- More details on usage upon request.
- Example: "Saraya" -> "Test Knight": `EMXHookLibrary.EditStringTableText(5037, "Test Knight")`.

### SetColorSetColorRGB(_colorSetName, _season, _rgb, _wetFactor)
- Sets the colors of a ColorSet per season.
- A table containing the original values is returned so that the ColorSet can be reset later.
- The name of the set can be found in the folder in the game directory.
- Example: `EMXHookLibrary.SetColorSetColorRGB("ME_FOW", 1, {0.32, 0.135, 0.4, 1}); -- FoW color for season spring in climate zone ME`.

### SetPlayerColorRGB(_playerColorEntryIndex, _rgb)
- Changes a player's color.
- **_rgb** must be a table containing the color values (from **0 - 255**).
- The alpha channel must always be **127** and the first entry in the table.
- **0** and **single-digit values** must be represented as two digits [e.g., **9 -> 09**].
```
EMXHookLibrary.SetPlayerColorRGB(1, {127, 0, 0, 255, 255}) -- Yellow
EMXHookLibrary.SetPlayerColorRGB(1, {127, 253, 112, 0, 0}) -- Dark Blue
EMXHookLibrary.SetPlayerColorRGB(1, {127, 255, 255, 255}) -- White
```

### SetEGLEffectDuration(_effect, _duration)
- Changes the display duration of an EGL_Effect.
- Example: `EMXHookLibrary.SetEGLEffectDuration(EGL_Effects.FXLightning, 2)`.

### ToggleRTSCameraMouseRotation(_enableMouseRotation, _optionalRotationSpeed)
- Enables or disables RTS camera rotation with CTRL + mouse wheel.
- Optionally, the speed can also be adjusted.
- Default: **2500**.

### SetFogOfWarVisibilityFactor(_newFactor)
- Sets the factor by which the Fog of War is applied in already revealed areas.
- Default: **0.75**.
- At **0**, areas remain covered unless a player's unit is present; at **1**, they remain permanently revealed.

---
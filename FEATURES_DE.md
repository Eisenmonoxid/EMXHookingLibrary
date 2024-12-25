# Features
Alle Funktionen befinden sich in der globalen **"EMXHookLibrary"** - Tabelle und müssen dementsprechend aufgerufen werden. (z.B SetPlayerColorRGB(_params) -> EMXHookLibrary.SetPlayerColorRGB(_params)).

---

## Entitätenlogik
Diese Funktionen beeinflussen die Spiellogik von Entitäten und Entitätentypen.
### SetEntityTypeFullCost(_entityType, _costs, _overrideSecondGoodPointer)
- Setzt neue Warenkosten für einen Entitätentyp. Die Kostentabelle **_costs** muss nach folgendem Vorbild aufgebaut sein: `{Good, Amount, ...}`.
Es sind maximal 2 Waren möglich. 
- Sollte der Entitätentyp im Spiel nur einen Kosteneintrag haben (zB Stadtgebäude), und es sollen zwei gesetzt werden, ist es notwendig, den
Parameter **_overrideSecondGoodPointer == true** zu setzen. Bei Entitäten, welche bereits standardmäßíg zwei Einträge besitzen (zB Ziergebäude), ist dies nicht notwendig.
- Es sind Rohstoffe und Gold als Waren möglich. Wenn der zweite Eintrag hingegen ein Produktionsgut sein soll (zB Goods.G_Cheese),
sollte das [Baukostensystem BCS](https://github.com/Eisenmonoxid/S6CostSystem) verwendet werden.
- Kann Kosten zu Entitätentypen hinzuzufügen, welche zuvor keine Kosten im Spiel besaßen (zB Dorfgebäude). Dafür wird in allokiertem Speicher ein
neues Array angelegt.
- Kann Kosten auch zu Einheiten, zB Munitionskarren/Dieben/Mauerkatapulten, ändern und hinzufügen.
- Es wird eine Tabelle zurückgegeben, welche die originalen Pointer enthält, damit man die Werte wieder zurücksetzen kann. Rücksetzfunktion: 
`ResetEntityTypeFullCost(_entityType, _resetPointers)`.

### ResetEntityTypeFullCost(_entityType, _resetPointers)
- Setzt die Werte von `EMXHookLibrary.SetEntityTypeFullCost` wieder zurück.

### SetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _costs, _overrideSecondGoodPointer, _overrideUpgradeCostHandling)
- Analog zu `EMXHookLibrary.SetEntityTypeFullCost` können hier die Ausbaukosten eines Entitätentyps geändert werden. 
- Sollte der Entitätentyp im Spiel nur einen Kosteneintrag haben (zB Stadtgebäude), und es sollen zwei gesetzt werden, ist es notwendig, den
Parameter **_overrideSecondGoodPointer == true** zu setzen. Bei Entitäten, welche bereits standardmäßíg zwei Einträge besitzen (zB das Lagerhaus), ist dies nicht notwendig. 
- **_overrideUpgradeCostHandling** ist notwendig, wenn Güter verwendet werden sollen, die nicht Holz, Stein oder Eisen sind oder zwei Güter anstatt einem
als Kosten vorgesehen sind.
- Es wird eine Tabelle zurückgegeben, welche die originalen Pointer enthält, damit man die Werte wieder zurücksetzen kann. Rücksetzfunktion: 
`ResetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _resetPointers)`.

### ResetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _resetPointers)
- Setzt die Werte von `EMXHookLibrary.SetEntityTypeUpgradeCost` wieder zurück.

### SetEntityTypeMaxHealth(_entityType, _newMaxHealth)
- Setzt die maximalen Lebenspunkte (HP) eines Entitätentyps.
- Dies wirkt sich auch auf alle bereits bestehenden Entitäten dieses Typs aus.

### SetSermonSettlerLimit(_cathedralEntityType, _upgradeLevel, _newLimit) 
- Setzt das Limit an Siedlern in der Predigt per Kirchen- oder Kathedralenausbaulevel. 
- Standard: **10, 15, 30, 60**.
- **_upgradeLevel** startet bei 0 für die erste Stufe.

### SetSoldierLimit(_castleEntityType, _upgradeLevel, _newLimit)	
- Setzt das Limit an Soldaten per Burgausbaulevel. 
- Standard: **25, 43, 61, 91**.
- **_upgradeLevel** startet bei 0 für die erste Stufe.

### SetEntityTypeSpouseProbabilityFactor(_entityType, _factor)
- Setzt die Wahrscheinlichkeit, dass Siedler auf dem Fest eine Ehefrau finden. 
- Standard: **0.3**.
- Damit können bspw. Badehäuser oder Rohstoffgebäude auch Ehefrauen beschäftigen.

### SetTerritoryAcquiringBuildingID(_territoryID, _buildingID)
- Setzt das Acquiring Building eines Territoriums. 
- Normalerweise der Außenposten.

### SetEntityTypeBlocking(_entityType, _blocking, _isBuildBlocking)
- Setzt Blocking oder BuildBlocking eines Entitätentyps. 
- **_blocking** muss immer eine Tabelle mit den Werten sein.
- Bspw. `EMXHookLibrary.SetEntityTypeBlocking(Entities.B_Cathedral_Big, {0, 0, 0, 0}, false) -- Entfernt das Blocking der Kathedrale`.
- Bei Unklarheiten in der .xml des Entitätentyps nachschauen.

### SetEntityTypeOutStockCapacity(_entityType, _upgradeLevel, _newLimit)	
- Setzt den maximalen Outstock eines Entitätentyps basierend auf dessen Ausbaulevel. 
- Standard: **3, 6, 9 oder nur 9**.
- Funktioniert bei allem, was einen Outstock besitzt (zB auch bei Lagerhäusern).
- **ACHTUNG:** Im Gegensatz zu `EMXHookLibrary.SetMaxBuildingStockSize` betrifft dies hier neu erstellte Typen.

### SetMaxStorehouseStockSize(_storehouseID, _maxStockSize)
- Setzt den maximalen Outstock eines Storehouse-Typs.
- **ACHTUNG:** Im Gegensatz zu `EMXHookLibrary.SetEntityTypeOutStockCapacity` betrifft dies hier einzelne Lagerhäuser!

### SetMaxBuildingStockSize(_buildingID, _maxStockSize)
- Setzt den maximalen Outstock eines bestehenden Gebäudes.
- **ACHTUNG:** Im Gegensatz zu `EMXHookLibrary.SetEntityTypeOutStockCapacity` betrifft dies hier einzelne Gebäude!

### SetBuildingInStockGood(_buildingID, _newGood)
- Setzt eine neue Ware als Instock eines Gebäudes.

### CreateBuildingInStockGoods(_buildingID, _newGoods)
- Allokiert Speicher und setzt neue Instock Goods eines Gebäudes.
- **_newGoods** muss nach folgendem Vorbild aussehen: **{Good, Good}**.
- Es wird eine Tabelle zurückgegeben, welche die originalen Pointer enthält, damit man die Werte wieder zurücksetzen kann.
- **ACHTUNG:** Mittels der Funktion `Logic.AddGoodToStock(ID, Good, 0, true, true, true)` kann dasselbe erreicht werden, von daher
ist diese Funktion (mehr oder weniger) obsolet.

### SetBuildingTypeOutStockGood(_buildingID, _newGood, _setEntityTypeProduct)
- Setzt eine neue Ware als Outstock eines Gebäudes. 
- Wenn **_setEntityTypeProduct ~= nil**, wird auch das Product des Entitätentyps gesetzt, 
ansonsten nur der Outstock für ein Gebäude.

### AddBehaviorToEntityType(_entityType, _behaviorName)
- Kopiert eine Referenz eines Behaviors von einem Entitätentyp zu einem anderen. Alle danach erstellten Entitäten besitzen
das Behavior. 
- Die möglichen Behavior sind:
**"CInteractiveObjectBehavior", "CMountableBehavior", "CFarmAnimalBehavior", "CAnimalMovementBehavior", "CAmmunitionFillerBehavior"**.
- Kann mittels `EMXHookLibrary.ResetEntityBehaviors zurückgesetzt` werden.
- Bspw. `EMXHookLibrary.AddBehaviorToEntityType(Entities.B_Bakery, "CInteractiveObjectBehavior") -- Macht aus Bäckereien ein interaktives Objekt`.

### ResetEntityBehaviors(_entityType, _resetPointers)
- Setzt Behavior eines Entitätentyps zurück. _resetPointers ist ein table, welcher von `EMXHookLibrary.AddBehaviorToEntityType` zurückgegeben wird.

### SetSettlersWorkBuilding(_settlerID, _buildingID)
- Setzt das Arbeitsgebäude eines Siedlers. Dadurch ist es möglich, mehr als 3 Siedler an einem Gebäude beschäftigt zu haben.
- **ACHTUNG:** Der Siedler muss bereits einem Gebäude zugeordnet sein, bevor gewechselt werden kann!
- Bei mehr als 3 Siedlern sollte zuvor `EMXHookLibrary.SetTypeAndMaxNumberOfWorkersForBuilding` entsprechend gesetzt werden.

### SetTypeAndMaxNumberOfWorkersForBuilding(_entityType, _maxWorkers, _workerType)
- Setzt eine neue Maximalanzahl und einen neuen Typ an Arbeitern eines Gebäudetyps.

---

## Darstellung und Anzeige von Entitäten
Diese Funktionen beeinflussen die Darstellung von Entitäten und deren Modellen.
### GetModel(_entityID)
- Gibt das aktuelle Model einer Entität zurück, sofern eines gesetzt wurde.
- Analog zu `Logic.SetModel`.

### SetEntityTypeMinimapIcon(_entityType, _iconIndex)
- Setzt ein Minimap-Icon für einen Entitätentyp. Es sind Icons aus der Icontabelle möglich. 
- 0 entfernt das Icon wieder.
- Für bereits auf der Map existierende Entitäten sollte die Funktion in der FMA aufgerufen werden, ansonsten sind nur neu erstellte Entitäten betroffen.

### SetEntityDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
- Ermöglicht es, verschiedene Modelle von Gebäuden zu setzen. 
- **_params** muss eine Tabelle mit den Modellen sein.
- **_paramType** muss ein String mit dem Typ sein. Mögliche Typen: **"Models", "UpgradeSite", "Destroyed", "Lights"**.
- _model setzt das derzeitige Model, kann auch **nil** sein.
- Vor dem Ändern am Besten in der Definitions-xml der Entität nachschauen. Es kann sowohl eine (existierende) Entity-ID als auch ein Entitätentyp angegeben werden.
- Bspw. `EMXHookLibrary.SetEntityDisplayModelParameters(Entities.B_StoreHouse, "Models", {Models.Buildings_B_NPC_Cloister_ME, 
Models.Buildings_B_NPC_Storehouse_NE, Models.Buildings_B_NPC_Cloister_NE}, {Models.Buildings_B_NPC_Storehouse_ME}) -- Setzt neue Modelle
für die verschiedenen Ausbaustufen des Lagerhauses.`.

### SetBuildingDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
- Analog zu `EMXHookLibrary.SetEntityDisplayModelParameters` können hier die Modelle von (Produktions-)Gebäuden geändert werden.
- Mögliche Typen: **"Yards", "Roofs", "RoofDestroyed", "UpgradeSite", "Floors", "Gables", "Lights", "FireCounts"**.

### SetEntityDisplayProperties(_entityIDOrType, _property, _value)
- Ermöglicht es, verschiedene Display-Parameter einer Entität bzw. eines Entitätentyps anzupassen. 
- Die möglichen Properties sind: **"ShowDestroyedModelAt", "MaxDarknessFactor", "ExplodeOnDestroyedModel", "SnowFactor", "SeasonColorSet", "LODDistance", "ConstructionSite", "Decal"**.
- Einige Parameter müssen als Float gesetzt werden, dazu in der Definitions-xml des Entitätentyps nachsehen.

### SetAndReloadModelSpecificShader(_modelID, _shaderName)
- Ändert den Shader eines Modeltyps. Mögliche Shader im Ordner "Effects" nachschauen. 
- Bspw. **"Object_Aligned_Additive", "ShipMovementEx", "WealthLightObject", "IceCliff", "Waterfall", "StaticBanner"**.
- Gibt für die Rücksetzfunktion den Originalwert zurück.
- **ACHTUNG:** Dies kann etwas Memory leaken (148 Byte) im Fall, dass das Model bereits vom Spiel geladen wurde.

### ModifyModelPropertiesByReferenceType(_modelID, _referenceModelID, _entryIndex)
- Ändert Parameter eines Modeltyps durch Kopieren von Werten eines Referenztyps. 
- Gibt für die Rücksetzfunktion den Originalwert zurück.
- Bspw. `EMXHookLibrary.ModifyModelProperties(Models.Doodads_D_NA_Cliff_Set01_Deco01, Models.Doodads_D_NE_Cliff_Set03_Sheet01, 0)`.
Dies setzt für das erste Model den Shader-Effect vom zweiten Model.
- **ACHTUNG:** Dies kann etwas Memory leaken (148 Byte) im Fall, dass das Model bereits vom Spiel geladen wurde.

### ResetModelProperties(_modelID, _entryIndex, _resetValue)
- Setzt geänderte Parameter eines Modeltyps wieder zurück.

### ChangeModelFilePath(_modelID, _filePath, _pathLength)
- Ändert den internen Dateipfad eines Models.
- Bspw. `ChangeModelFilePath(Models.Buildings_B_Barracks, "Doodads\\D_NA_ExcavationSite_3\0\0", 29)`.
- Wenn das Model noch nicht geladen wurde, wird es im ID-Manager durch **D_NA_ExcavationSite_3** ersetzt.

---

## Globale Logik
Diese Funktionen beeinflussen die globale Spiellogik der Welt.
### SetTerritoryGoldCostByIndex(_arrayIndex, _price)
- Setzt neue Goldkosten für Territorien
- Von Index 1 - 5 (**1 = Low, 5 = Very Expensive**).

### SetSettlerIllnessCount(_newCount)
- Setzt die Anzahl an Siedlern, ab derer Krankheiten ausbrechen können. 
- Standard: **151**.

### SetWealthGoodDecayPerSecond(_decay)
- Setzt den Wert, um den Wealth-Güter in Gebäuden wiederaufgefüllt werden müssen.
- Standard: **0**.

### SetCarnivoreHealingSeconds(_newTime)
- Setzt die Zeit, die Raubtiere benötigen, um ihre Gesundheit zu regenerieren.

### SetKnightResurrectionTime(_newTime)
- Setzt die Zeit, die sich der Ritter in der Burg erholen muss. 
- Standard: **60000**.

### SetMaxBuildingTaxAmount(_newTaxAmount)
- Setzt die maximale Anzahl an Steuereinnahmen, die Stadtgebäude besitzen können.
- Standard: **100**.

### SetSettlerLimit(_cathedralIndex, _limit)
- Setzt ein neues Siedlerlimit abhängig von der Ausbaustufe der Kathedrale/Kirche. 
- Der Index läuft von **0 - 5**.
- Standard: **50, 50, 100, 150, 200, 200**.

### SetAmountOfTaxCollectors(_newAmount)
- Setzt die Menge an Steuereintreibern, die maximal erzeugt werden. 
- Standard: **6**.

### SetBuildingKnockDownCompensation(_percent)
- Setzt den Rückerstattungsfaktor beim Abriss eines Gebäudes. 
- Standard: **50**.
- **50** sind hierbei 50%, also die Hälfte der benötigten Güter zum Bau wird erstattet beim Abriss.

### SetTerritoryCombatBonus(_newFactor)
- Setzt den Faktor, um welchen Truppen in eigenen Territorien stärker sind. 
- Standard: **0.2**.
- Wird zur Gesamtkampfkraft hinzuaddiert.

### SetCathedralCollectAmount(_newAmount)
- Setzt die Menge, die ein Siedler beim Besuch der Predigt an Gold spendet. 
- Standard: **5**.

### SetFireHealthDecreasePerSecond(_newAmount)
- Setzt den Schaden, welches Feuer in der Sekunde anrichtet. 
- Standard: **5**.

### SetBallistaAmmunitionAmount(_amount)
- Setzt die Maximalanzahl an Munition von Ballisten (Mauerkatapult) per Typ.
- Standard: **10**.

### SetMilitaryMetaFormationParameters(_distances)
- Setzt einige Parameter zur Truppenanordnung. 
- Der Parameter **_distances** muss eine Tabelle nach folgendem Vorbild sein:
`-- {_rowDistance, _colDistance, _cartRowDistance, _cartColDistance, _engineRowDistance, _engineColDistance}`.
- Nicht benötigte Werte sind **nil**.

### ReplaceUpgradeCategoryEntityType(_upgradeCategory, _newEntityType)
- Ändert den Entitätentyp einer UpgradeCategory. 
- Damit kann man bspw. Dorfgebäude vom Spieler setzen lassen.

### SetGoodTypeParameters(_goodType, _requiredResource, _amount, _goodCategory, _animationParameters)
- Setzt das benötigte Produktionsgut einer Ware und/oder deren benötigte Menge. (zB Goods.G_Carcass -> Goods.G_Sausage)
- Nicht benötigte Parameter sind **nil**.
- Die Menge ist standardmäßig 1:1, kann aber beliebig verändert werden. (zB 3 Weizen für 1 Brot, 2 Stein für 1 Besen usw.)

### CopyGoodTypePointer(_good, _copyGood)
- Ermöglicht es, einige Parameter eines GoodTypes (bspw. **RequiredResource**) auch bei Goods zu verwenden, welche keine Einträge
für diese Dinge haben. Diese Einträge werden als Referenz auf einen anderen GoodType angelegt.
- Es wird eine Tabelle zurückgegeben, welche die originalen Pointer enthält, damit man die Werte wieder zurücksetzen kann.

### CreateGoodTypeRequiredResources(_goodType, _requiredResources)
- Ermöglicht es, einige Parameter eines GoodTypes (bspw. **RequiredResource**) auch bei Goods zu verwenden, welche keine Einträge
für diese Dinge haben. 
- Im Gegensatz zu `EMXHookLibrary.CopyGoodTypePointer` wird hier in allokiertem Speicher ein neues Array
angelegt. 
- **_requiredResources** muss so aussehen: **{{_resource, _amount, _supplier}, {_resource, _amount, _supplier}, ...}**
- Bspw. `EMXHookLibrary.CreateGoodTypeRequiredResources(Goods.G_Soap, {{Goods.G_Wool, 3, EntityCategories.GC_Food_Supplier}, {Goods.G_Stone, 2, EntityCategories.GC_Food_Supplier}})`.
- Es wird eine Tabelle zurückgegeben, welche die originalen Pointer enthält, damit man die Werte wieder zurücksetzen kann.

### ResetGoodTypePointer(_goodType, _resetPointers)
- Setzt die Werte von `EMXHookLibrary.CreateGoodTypeRequiredResources` und `EMXHookLibrary.CopyGoodTypePointer` wieder zurück.

### ToggleDEBUGMode(_magicWord, _setNewMagicWord)
- Ermöglicht es, im Originalspiel (OV) und der History Edition von Steam den Development-Mode an- bzw. auszuschalten.
- **_magicWord** ist entweder *256* oder *257*, je nach Status des Modes.
- Funktioniert **NUR** in der Steam - HE und im Originalspiel. 
- Für die Ubisoft - HE sollte der [S6Patcher](https://github.com/Eisenmonoxid/S6Patcher) verwendet werden!

### ModifyTerrainHeightWithoutTextureUpdate(_posX, _posY, _height)
- Ändert die Terrainhöhe an einer Position, ohne die Texturen darunter sofort upzudaten. 
- Damit sind bspw. "schwebende" Entitäten möglich, allerdings nur bis zum nächsten Blockingupdate.
- Bspw. `EMXHookLibrary.ModifyTerrainHeightWithoutTextureUpdate(5000, 5000, 5000)`.

### EditFestivalProperties(_festivalDuration, _promotionDuration, _promotionParticipantLimit, _festivalParticipantLimit)
- Verändert einen oder mehrere Parameter der Feste (Aufstiegs- sowie normales Fest). 
Geändert werden können Dauer sowie das Limit der möglichen Partizipierenden.
- Nicht benötigte Parameter sind **nil**.

---

## Globale Darstellung und Anzeige
Diese Funktionen beeinflussen die globale Darstellung der Welt.
### EditStringTableText(_IDManagerEntryIndex, _newString, _useAlternativePointer)
- Verändert einen StringTable-Eintrag. Der EntryIndex muss zuerst ausgelesen werden und das Zeichenlimit muss beachtet werden.
- Genaueres zur Verwendung auf Anfrage.
- Bspw. "Saraya" -> "Testritter": `EMXHookLibrary.EditStringTableText(5037, "Testritter")`.

### SetColorSetColorRGB(_colorSetName, _season, _rgb, _wetFactor)
- Setzt die Farben eines ColorSets per Jahreszeit. 
- Es wird eine Tabelle zurückgegeben, welche die originalen Werte enthält, damit man
das ColorSet wieder zurücksetzen kann. 
- Der Name des Sets kann im Ordner im Spielverzeichnis nachgesehen werden.
- Bspw. `EMXHookLibrary.SetColorSetColorRGB("ME_FOW", 1, {0.32, 0.135, 0.4, 1}); -- FoW color for season spring in climate zone ME`.

### SetPlayerColorRGB(_playerColorEntryIndex, _rgb)
- Setzt die Spielerfarbe eines Spielers neu. 
- **_rgb** muss ein table mit den Farbwerten (von **0 - 255**) sein.
- Der Alphakanal muss immer **127** betragen und der erste Eintrag in der Tabelle sein. 
- **0** und **einstellige Werte** müssen durch zwei Ziffern [bspw. **9 -> 09**] repräsentiert werden.
```
EMXHookLibrary.SetPlayerColorRGB(1, {127, 0, 0, 255, 255}) -- Yellow
EMXHookLibrary.SetPlayerColorRGB(1, {127, 253, 112, 0, 0}) -- Dark Blue
EMXHookLibrary.SetPlayerColorRGB(1, {127, 255, 255, 255}) -- White
```

### SetEGLEffectDuration(_effect, _duration)
- Ändert die Anzeigedauer eines EGL_Effects.
- Bspw. `EMXHookLibrary.SetEGLEffectDuration(EGL_Effects.FXLightning, 2)`.

### ToggleRTSCameraMouseRotation(_enableMouseRotation, _optionalRotationSpeed)
- Setzt die Rotation der RTS - Camera mit STRG/CTRL + Mausrad. 
- Optional kann auch die Geschwindigkeit davon eingestellt werden. 
- Standard: **2500**.

### SetFogOfWarVisibilityFactor(_newFactor)
- Setzt den Faktor, um den der Fog of War in bereits aufgedeckten Gebieten angewandt wird. 
- Standard: **0.75**.
- Bei **0** bleiben Gebiete zugedeckt, sofern sich keine eigene Einheit darin befindet, bei **1** bleiben sie dauerhaft aufgedeckt.

---
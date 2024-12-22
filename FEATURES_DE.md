# Features
Alle Funktionen befinden sich in der globalen **"EMXHookLibrary"** - Tabelle und m�ssen dementsprechend aufgerufen werden. (z.B SetPlayerColorRGB() -> EMXHookLibrary.SetPlayerColorRGB(}))

---

## Entit�tenlogik
Diese Funktionen beeinflussen die Spiellogik von Entit�ten und Entit�tentypen.
### SetEntityTypeFullCost(_entityType, _costs, _overrideSecondGoodPointer)
Setzt neue Kosten f�r einen Entit�tentyp. Es k�nnen auch dann zwei Waren gesetzt werden, wenn der Typ im Originalspiel nur einen Eintrag hat.
Wenn der zweite Eintrag ein Produktionsgut sein soll (zB Goods.G_Cheese) sollte das **Baukostensystem BCS** verwendet werden.
Wenn der Typ im Originalspiel nur einen Kosteneintrag hatte (zB Stadtgeb�ude),
muss **_overrideSecondGoodPointer == true** sein. Bei Entit�ten mit zwei Eintr�gen (zB Ziergeb�ude) ist dies nicht notwendig.
Kann auch Kosten zu Entit�tentypen hinzuf�gen, welche zuvor keine Eintr�ge daf�r hatten. (zB Dorfgeb�ude)
Hinweis: Funktioniert auch bei Einheiten, zB Munitionskarren/Dieben/Mauerkatapulten.
Es wird eine Tabelle zur�ckgegeben, welche die originalen Pointer enth�lt, damit man die Werte wieder zur�cksetzen kann.

### ResetEntityTypeFullCost(_entityType, _resetPointers)
Setzt die Werte von `EMXHookLibrary.SetEntityTypeFullCost` wieder zur�ck.

### SetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _costs, _overrideSecondGoodPointer, _overrideUpgradeCostHandling)
Analog zu `EMXHookLibrary.SetEntityTypeFullCost` k�nnen hier die Ausbaukosten eines Entit�tentyps ge�ndert werden. Wenn der Typ im Originalspiel nur einen
Kosteneintrag hatte (zB Stadtgeb�ude), muss **_overrideSecondGoodPointer == true** sein. Bei Entit�ten mit zwei Eintr�gen (zB Lagerhaus) ist dies
nicht notwendig. **_overrideUpgradeCostHandling** ist notwendig, wenn G�ter verwendet werden sollen, die nicht Holz, Stein oder Eisen sind oder zwei G�ter anstatt einem
als Kosten vorgesehen sind.
Es wird eine Tabelle zur�ckgegeben, welche die originalen Pointer enth�lt, damit man die Werte wieder zur�cksetzen kann.

### ResetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _resetPointers)
Setzt die Werte von `EMXHookLibrary.SetEntityTypeUpgradeCost` wieder zur�ck.

### SetEntityTypeMaxHealth(_entityType, _newMaxHealth)
Setzt die maximalen Lebenspunkte (HP) eines Entit�tentyps.

### SetSermonSettlerLimit(_cathedralEntityType, _upgradeLevel, _newLimit) 
Setzt das Limit an Siedlern in der Predigt per Kathedralenausbaulevel. (Normal: **10, 15, 30, 60**)    

### SetSoldierLimit(_castleEntityType, _upgradeLevel, _newLimit)	
Setzt das Limit an Soldaten per Burgausbaulevel. (Normal: **25, 43, 61, 91**)

### SetEntityTypeSpouseProbabilityFactor(_entityType, _factor)
Setzt die Wahrscheinlichkeit, dass Siedler auf dem Fest eine Ehefrau finden. (Normal: **0.3**)
Damit kann bspw. das Badehaus auch Ehefrauen besch�ftigen.

### SetTerritoryAcquiringBuildingID(_territoryID, _buildingID)
Setzt das Acquiring Building eines Territoriums. Normalerweise der Au�enposten.

### SetEntityTypeBlocking(_entityType, _blocking, _isBuildBlocking)
Setzt Blocking oder BuildBlocking eines Entit�tentyps. _blocking muss immer ein table mit den Werten sein.
Bspw. `EMXHookLibrary.SetEntityTypeBlocking(Entities.B_Cathedral_Big, {0, 0, 0, 0}, false) - Entfernt das Blocking der Kathedrale`.

### SetEntityTypeOutStockCapacity(_entityType, _upgradeLevel, _newLimit)	
Setzt den maximalen OutStock eines Entit�tentyps basierend auf dessen Ausbaulevel. (Normal: **3, 6, 9 oder nur 9**).
Funktioniert auch bei Lagerh�usern (bzw. bei allem, was einen OutStock besitzt).
ACHTUNG: Im Gegensatz zu `EMXHookLibrary.SetMaxBuildingStockSize` betrifft dies hier neu errichtete Geb�ude eines Typs!

### SetMaxStorehouseStockSize(_storehouseID, _maxStockSize)
Setzt den maximalen OutStock des Lagerhauses.
ACHTUNG: Im Gegensatz zu `EMXHookLibrary.SetEntityTypeOutStockCapacity` betrifft dies hier einzelne Lagerh�user!

### SetMaxBuildingStockSize(_buildingID, _maxStockSize)
Setzt den maximalen OutStock eines Geb�udes.
ACHTUNG: Im Gegensatz zu `EMXHookLibrary.SetEntityTypeOutStockCapacity` betrifft dies hier einzelne Geb�ude!

### SetBuildingInStockGood(_buildingID, _newGood)
Setzt eine neue Ware als InStock eines Geb�udes.

### CreateBuildingInStockGoods(_buildingID, _newGoods)
Allokiert Speicher und setzt neue InStock Goods eines Geb�udes.
_newGoods muss zB folgenderma�en aussehen: **{Goods.G_Grain, Goods.G_Wool}**.
Es wird ein Table mit den originalen Pointern zur�ckgegeben, damit man die Werte wieder zur�cksetzen kann.

### SetBuildingTypeOutStockGood(_buildingID, _newGood, _setEntityTypeProduct)
Setzt eine neue Ware als OutStock eines Geb�udes. Wenn **_setEntityTypeProduct ~= nil**, wird auch das Product
des Entit�tentyps gesetzt, ansonsten nur der OutStock f�r ein Geb�ude.

### AddBehaviorToEntityType(_entityType, _behaviorName)
Kopiert eine Referenz eines Behaviors von einem Entit�tentyp zu einem anderen. Alle danach erstellten Entit�ten besitzen
das Behavior. Die m�glichen Behavior sind:
**"CInteractiveObjectBehavior", "CMountableBehavior", "CFarmAnimalBehavior", "CAnimalMovementBehavior", "CAmmunitionFillerBehavior"**.
Kann mittels `EMXHookLibrary.ResetEntityBehaviors zur�ckgesetzt` werden.
Bspw. `EMXHookLibrary.AddBehaviorToEntityType(Entities.B_Bakery, "CInteractiveObjectBehavior") -- Macht aus B�ckereien ein interaktives Objekt`.

### ResetEntityBehaviors(_entityType, _resetPointers)
Setzt Behavior eines Entit�tentyps zur�ck. _resetPointers ist ein table, welcher von `EMXHookLibrary.AddBehaviorToEntityType` zur�ckgegeben wird.

### SetSettlersWorkBuilding(_settlerID, _buildingID)
Setzt das Arbeitsgeb�ude eines Siedlers. Dadurch ist es m�glich, mehr als 3 Siedler an einem Geb�ude besch�ftigt zu haben.
ACHTUNG: Der Siedler muss bereits einem Geb�ude zugeordnet sein, bevor gewechselt werden kann!
(Bei mehr als 3 Siedlern sollte zuvor `EMXHookLibrary.SetTypeAndMaxNumberOfWorkersForBuilding` entsprechend gesetzt werden)

### SetTypeAndMaxNumberOfWorkersForBuilding(_entityType, _maxWorkers, _workerType)
Setzt eine neue Maximalanzahl und einen neuen Typ an Arbeitern eines Geb�udetyps.

---

## Darstellung und Anzeige von Entit�ten
Diese Funktionen beeinflussen die Darstellung von Entit�ten und deren Modellen.
### GetModel(_entityID)
Gibt das aktuelle Model einer Entit�t zur�ck. (Analog zu `Logic.SetModel`)

### SetEntityTypeMinimapIcon(_entityType, _iconIndex)
Setzt ein Minimap-Icon f�r einen Entit�tentyp. Es sind Icons aus der Icontabelle m�glich. 0 entfernt das Icon wieder.
F�r bereits auf der Map existierende Entit�ten sollte die Funktion in der FMA aufgerufen werden, ansonsten sind nur neu erstellte Entit�ten betroffen.

### SetEntityDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
Erm�glicht es, verschiedene Modelle von Geb�uden zu setzen. _params muss ein Table mit den Modellen sein.
_paramType muss ein String mit dem Typ sein. M�gliche Typen: **"Models", "UpgradeSite", "Destroyed", "Lights"**.
_model setzt das derzeitige Model, kann auch nil sein.
Vor dem �ndern am Besten in der Definitions-xml der Entit�t nachschauen. Es kann sowohl eine (existierende) Entity-ID als auch ein Entit�tentyp angegeben werden.
Bspw. `EMXHookLibrary.SetEntityDisplayModelParameters(Entities.B_StoreHouse, "Models", {Models.Buildings_B_Jewelry_Buildingsite_1,
Models.Buildings_B_Jewelry_Buildingsite_1, Models.Buildings_B_Jewelry_Buildingsite_1,
Models.Buildings_B_Jewelry_Buildingsite_1}, {Models.Buildings_B_Jewelry_Buildingsite_1})`

### SetBuildingDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
Analog zu EMXHookLibrary.SetEntityDisplayModelParameters k�nnen hier die Modelle von (Produktions-)Geb�uden ge�ndert werden.
M�gliche Typen: **"Yards", "Roofs", "RoofDestroyed", "UpgradeSite", "Floors", "Gables", "Lights", "FireCounts"**.

### SetEntityDisplayProperties(_entityIDOrType, _property, _value)
Erm�glicht es, verschiedene Display-Parameter einer Entit�t bzw. eines Entit�tentyps anzupassen. Die m�glichen Properties sind:
**"ShowDestroyedModelAt", "MaxDarknessFactor", "ExplodeOnDestroyedModel", "SnowFactor", "SeasonColorSet", "LODDistance", "ConstructionSite", "Decal"**.
Einige Parameter m�ssen als Float gesetzt werden, dazu am Besten anfragen bzw. in der Definitions-xml nachsehen.

### SetAndReloadModelSpecificShader(_modelID, _shaderName)
�ndert den Shader eines Modeltyps. M�gliche Shader im Ordner "Effects" nachschauen. Bspw.
**"Object_Aligned_Additive", "ShipMovementEx", "WealthLightObject", "IceCliff", "Waterfall", "StaticBanner"**.
Gibt f�r die R�cksetzfunktion den Originalwert zur�ck.
ACHTUNG: Dies kann etwas Memory leaken (148 Byte), von daher nicht �berm��ig verwenden!

### ModifyModelPropertiesByReferenceType(_modelID, _referenceModelID, _entryIndex)
�ndert Parameter eines Modeltyps durch Kopieren von Werten eines Referenztyps. Gibt f�r die R�cksetzfunktion den Originalwert zur�ck.
Bspw. `EMXHookLibrary.ModifyModelProperties(Models.Doodads_D_NA_Cliff_Set01_Deco01, Models.Doodads_D_NE_Cliff_Set03_Sheet01, 0)`
Dies setzt f�r das erste Model den Shader-Effect vom zweiten Model.
ACHTUNG: Dies kann etwas Memory leaken (148 Byte), von daher nicht �berm��ig verwenden!

### ResetModelProperties(_modelID, _entryIndex, _resetValue)
Setzt ge�nderte Parameter eines Modeltyps wieder zur�ck.

### ChangeModelFilePath(_modelID, _filePath, _pathLength)
�ndert den Dateipfad eines Models.
Bspw. `ChangeModelFilePath(Models.Buildings_B_Barracks, "Doodads\\D_NA_ExcavationSite_3\0\0", 29)`
Wenn das Model noch nicht geladen wurde, wird es im ID-Manager durch **D_NA_ExcavationSite_3** ersetzt.

---

## Globale Logik
Diese Funktionen beeinflussen die globale Spiellogik der Welt.
### SetTerritoryGoldCostByIndex(_arrayIndex, _price)
Setzt neue Goldkosten f�r Territorien, von Index 1 - 5 (**1 = Low, 5 = Very Expensive**).

### SetSettlerIllnessCount(_newCount)
Setzt die Siedlermenge, ab derer Krankheiten ausbrechen k�nnen. (Normal: **151**)

### SetWealthGoodDecayPerSecond(_decay)
Setzt den Wert, um den Wealth-G�ter in Geb�uden wiederaufgef�llt werden m�ssen. (Normal: **0**)

### SetCarnivoreHealingSeconds(_newTime)
Setzt die Zeit, die Raubtiere ben�tigen, um ihre Gesundheit zu regenerieren.

### SetKnightResurrectionTime(_newTime)
Setzt die Zeit, die sich der Ritter in der Burg erholen muss. (Normal: **60000**)

### SetMaxBuildingTaxAmount(_newTaxAmount)
Setzt die maximale Anzahl an Steuereinnahmen, die Stadtgeb�ude besitzen k�nnen.

### SetSettlerLimit(_cathedralIndex, _limit)
Setzt ein neues Siedlerlimit abh�ngig von der Ausbaustufe der Kathedrale/Kirche. (Von **0 - 6**)

### SetAmountOfTaxCollectors(_newAmount)
Setzt die Menge an Steuereintreibern, die maximal erzeugt werden. (Normal: **6)**

### SetBuildingKnockDownCompensation(_percent)
Setzt den R�ckerstattungsfaktor beim Abriss eines Geb�udes. (Normal: **50**)

### SetTerritoryCombatBonus(_newFactor)
Setzt den Faktor, um welchen Truppen in eigenen Territorien st�rker sind. (Normal: **0.2**)

### SetCathedralCollectAmount(_newAmount)
Setzt die Menge, die ein Siedler beim Besuch der Predigt an Gold spendet. (Normal: **5**)

### SetFireHealthDecreasePerSecond(_newAmount)
Setzt den Schaden, welches Feuer in der Sekunde anrichtet. (Normal: **5**)

### SetBallistaAmmunitionAmount(_amount)
Setzt die Maximalanzahl an Munition von Ballisten (Mauerkatapult) per Typ.

### SetMilitaryMetaFormationParameters(_distances)
Setzt einige Parameter zur Truppenanordnung. Der Parameter _distances muss ein table sein nach folgendem Vorbild:
`-- {_rowDistance, _colDistance, _cartRowDistance, _cartColDistance, _engineRowDistance, _engineColDistance}`.
Nicht ben�tigte Werte sind nil.

### ReplaceUpgradeCategoryEntityType(_upgradeCategory, _newEntityType)
�ndert den EntityType einer UpgradeCategory. Damit kann man bspw. Dorfgeb�ude vom Spieler setzen lassen.

### SetGoodTypeParameters(_goodType, _requiredResource, _amount, _goodCategory, _animationParameters)
Setzt das ben�tigte Produktionsgut einer Ware und/oder deren ben�tigte Menge. (zB Goods.G_Carcass -> Goods.G_Sausage)
(Nicht ben�tigte Parameter sind nil).
Die Menge ist standardm��ig 1:1, kann aber beliebig ver�ndert werden. (zB 3 Weizen f�r 1 Brot, 2 Stein f�r 1 Besen usw.)

### CopyGoodTypePointer(_good, _copyGood)
Erm�glicht es, einige Parameter eines GoodTypes (bspw. **RequiredResource**) auch bei Goods zu verwenden, welche keine Eintr�ge
f�r diese Dinge haben. Diese Eintr�ge werden als Referenz auf einen anderen GoodType angelegt.
Es wird eine Tabelle zur�ckgegeben, welche die originalen Pointer enth�lt, damit man die Werte wieder zur�cksetzen kann.

### CreateGoodTypeRequiredResources(_goodType, _requiredResources)
Erm�glicht es, einige Parameter eines GoodTypes (bspw. RequiredResource) auch bei Goods zu verwenden, welche keine Eintr�ge
f�r diese Dinge haben. Im Gegensatz zu `EMXHookLibrary.CopyGoodTypePointer` wird hier in allokiertem Speicher ein neues Array
angelegt. _requiredResources muss so aussehen: **{{_resource, _amount, _supplier}, {_resource, _amount, _supplier}, ...}**
Bspw. `EMXHookLibrary.CreateGoodTypeRequiredResources(Goods.G_Soap, {{Goods.G_Wool, 3, EntityCategories.GC_Food_Supplier}, {Goods.G_Stone, 2, EntityCategories.GC_Food_Supplier}})`
Es wird eine Tabelle zur�ckgegeben, welche die originalen Pointer enth�lt, damit man die Werte wieder zur�cksetzen kann.

### ResetGoodTypePointer(_goodType, _resetPointers)
Setzt die Werte von `EMXHookLibrary.CreateGoodTypeRequiredResources` und `EMXHookLibrary.CopyGoodTypePointer` wieder zur�ck.

### ToggleDEBUGMode(_magicWord, _setNewMagicWord)
Erm�glicht es, auch in der History Edition den Development-Mode zu aktivieren.
_magicWord muss zuerst aus der OV ausgelesen werden und kann danach PC - spezifisch auch in der HE gesetzt werden.
Funktioniert **NUR** in der Steam - HE. F�r die Ubisoft - HE sollte der [S6Patcher](https://github.com/Eisenmonoxid/S6Patcher) verwendet werden!

### ModifyTerrainHeightWithoutTextureUpdate(_posX, _posY, _height)
�ndert die Terrainh�he an einer Position, ohne die Texturen darunter sofort upzudaten. Damit sind bspw. "schwebende" Entit�ten m�glich.
Bspw. `EMXHookLibrary.ModifyTerrainHeightWithoutTextureUpdate(5000, 5000, 5000)`.

### EditFestivalProperties(_festivalDuration, _promotionDuration, _promotionParticipantLimit, _festivalParticipantLimit)
Ver�ndert einen oder mehrere Parameter der Feste (Aufstiegs- sowie normales Fest). 
Nicht ben�tigte Parameter sind nil.
Ge�ndert werden k�nnen Dauer sowie das Limit der m�glichen Partizipierenden.

---

## Globale Darstellung und Anzeige
Diese Funktionen beeinflussen die globale Darstellung der Welt.
### EditStringTableText(_IDManagerEntryIndex, _newString, _useAlternativePointer)
Ver�ndert einen StringTable-Eintrag. Der EntryIndex muss zuerst ausgelesen werden und das Zeichenlimit muss beachtet werden.
Genaueres zur Verwendung auf Anfrage.
Bspw. "Saraya" -> "Testritter": `EMXHookLibrary.EditStringTableText(5037, "Testritter")`

### SetColorSetColorRGB(_colorSetName, _season, _rgb, _wetFactor)
Setzt die Farben eines ColorSets per Jahreszeit. Es wird eine Tabelle zur�ckgegeben, welche die originalen Werte enth�lt, damit man
das ColorSet wieder zur�cksetzen kann. Der Name des Sets kann im Ordner im Spielverzeichnis nachgesehen werden.
Bspw. `EMXHookLibrary.SetColorSetColorRGB("ME_FOW", 1, {0.32, 0.135, 0.4, 1}); -- FoW color for season spring in climate zone ME`

### SetPlayerColorRGB(_playerColorEntryIndex, _rgb)
Setzt die Spielerfarbe eines Spielers neu. _rgb muss ein table mit den Farbwerten (von **0 - 255**) sein.
Der Alphakanal muss immer **127** betragen und der erste Eintrag im table sein. **0** und einstellige Werte m�ssen durch zwei Ziffern [bspw. **9 -> 09**] repr�sentiert werden.
```
EMXHookLibrary.SetPlayerColorRGB(1, {127, 0, 0, 255, 255}) -- Yellow
EMXHookLibrary.SetPlayerColorRGB(1, {127, 253, 112, 0, 0}) -- Dark Blue
EMXHookLibrary.SetPlayerColorRGB(1, {127, 255, 255, 255}) -- White
```

### SetEGLEffectDuration(_effect, _duration)
�ndert die Anzeigedauer eines EGL_Effects.
Bspw. `EMXHookLibrary.SetEGLEffectDuration(EGL_Effects.FXLightning, 2)`.

### ToggleRTSCameraMouseRotation(_enableMouseRotation, _optionalRotationSpeed)
Setzt die Rotation der RTS - Camera mit STRG/CTRL + Mausrad. Optional kann auch die Geschwindigkeit davon eingestellt werden. (Normal: **2500**)

### SetFogOfWarVisibilityFactor(_newFactor)
Setzt den Faktor, um den der Fog of War in bereits aufgedeckten Gebieten angewandt wird. (Normal: **0.75**)

---
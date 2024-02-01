# EMXHookingLibrary
A work-in-progress Hook for the game "The Settlers 6" and "The Settlers 6: History Edition". Will very likely never be truly finished ;)

Uses the "BigNum.lua" library. Special thanks to the authors!

## Usage
Include the file "emxhooklib.bin" in your map folder and load it with Script.Load() in the global map script. Then you call the function "EMXHookLibrary.InitAdressEntity()" and after that, you can use the exported methods (listed below) however you like.
```
(If you use the function argument EMXHookLibrary.InitAdressEntity(true), you can use the savegame-override
and do not have to worry about resetting all values when the player closes the map!)
```

## Features
```
EMXHookLibrary.SetTerritoryGoldCostByIndex(_arrayIndex, _price)
-> Setzt neue Goldkosten für Territorien, von Index 1 - 5 (1 = Low, 5 = Very Expensive).

EMXHookLibrary.SetSettlerIllnessCount(_newCount)
-> Setzt die Siedlermenge, ab derer Krankheiten ausbrechen können. (Normal: 151)

EMXHookLibrary.SetWealthGoodDecayPerSecond(_decay)
-> Setzt den Wert, um den Wealth-Güter in Gebäuden wiederaufgefüllt werden müssen. (Normal: 0)

EMXHookLibrary.SetCarnivoreHealingSeconds(_newTime)
-> Setzt die Zeit, die Raubtiere benötigen, um ihre Gesundheit zu regenerieren.

EMXHookLibrary.SetKnightResurrectionTime(_newTime)
-> Setzt die Zeit, die sich der Ritter in der Burg erholen muss. (Normal: 60000)

EMXHookLibrary.SetMaxBuildingTaxAmount(_newTaxAmount)
-> Setzt die maximale Anzahl an Steuereinnahmen, die Stadtgebäude besitzen können.

EMXHookLibrary.SetSettlerLimit(_cathedralIndex, _limit)
-> Setzt ein neues Siedlerlimit abhängig von der Ausbaustufe der Kathedrale/Kirche. (Von 0 - 6)

EMXHookLibrary.SetAmountOfTaxCollectors(_newAmount)
-> Setzt die Menge an Steuereintreibern, die maximal erzeugt werden. (Normal: 6)

EMXHookLibrary.SetFogOfWarVisibilityFactor(_newFactor)
-> Setzt den Faktor, um den der Fog of War in bereits aufgedeckten Gebieten angewandt wird. (Normal: 0.75)

EMXHookLibrary.GetModel(_entityID)
-> Gibt das aktuelle Model einer Entität zurück. (Analog zu Logic.SetModel)

EMXHookLibrary.SetEntityTypeFullCost(_entityType, _good, _amount, _secondGood, _secondAmount, _overrideSecondGoodPointer)
-> Setzt neue Kosten für einen Entitätentyp. Es können auch zwei Kosten gesetzt werden, wenn der Typ im Originalspiel
nur einen Eintrag hat. Wenn der zweite Eintrag ein Produktionsgut sein soll (zB Goods.G_Cheese), dann sollte das
Baukostensystem BCS verwendet werden. Wenn der Typ im Originalspiel nur einen Kosteneintrag hatte (zB Stadtgebäude),
muss _overrideSecondGoodPointer == true sein. Bei Entitäten mit zwei Einträgen (zB Ziergebäude) ist dies nicht notwendig.
Hinweis: Funktioniert auch bei Einheiten, zB Munitionskarren/Dieben/Mauerkatapulten.

EMXHookLibrary.SetEntityTypeUpgradeCost(_entityType, _upgradeLevel, _good, _amount, _secondGood, _secondAmount, _overrideSecondGoodPointer)	
-> Analog zu SetEntityTypeFullCost können hier die Ausbaukosten eines Entitätentyps geändert werden. Wenn der Typ im Originalspiel nur einen
Kosteneintrag hatte (zB Stadtgebäude), muss _overrideSecondGoodPointer == true sein. Bei Entitäten mit zwei Einträgen (zB Lagerhaus) ist dies
nicht notwendig.

EMXHookLibrary.ReplaceUpgradeCategoryEntityType(_upgradeCategory, _newEntityType)
-> Ändert den EntityType einer UpgradeCategory. Damit kann man bspw. Dorfgebäude vom Spieler setzen lassen.

EMXHookLibrary.SetEntityTypeMaxHealth(_entityType, _newMaxHealth)
-> Setzt die maximalen Lebenspunkte (HP) eines Entitätentyps.

EMXHookLibrary.SetBuildingKnockDownCompensation(_percent)
-> Setzt den Rückerstattungsfaktor beim Abriss eines Gebäudes. (Normal: 50)

EMXHookLibrary.SetTerritoryCombatBonus(_newFactor)
-> Setzt den Faktor, um welchen Truppen in eigenen Territorien stärker sind. (Normal: 0.2)

EMXHookLibrary.SetCathedralCollectAmount(_newAmount)
-> Setzt die Menge, die ein Siedler beim Besuch der Predigt an Gold spendet. (Normal: 5)

EMXHookLibrary.SetFireHealthDecreasePerSecond(_newAmount)
-> Setzt den Schaden, welches Feuer in der Sekunde anrichtet. (Normal: 5)

EMXHookLibrary.SetSermonSettlerLimit(_cathedralEntityType, _upgradeLevel, _newLimit) 
-> Setzt das Limit an Siedlern in der Predigt per Kathedralenausbaulevel. (Normal: 10, 15, 30, 60)    

EMXHookLibrary.SetSoldierLimit(_castleEntityType, _upgradeLevel, _newLimit)	
-> Setzt das Limit an Soldaten per Burgausbaulevel. (Normal: 25, 43, 61, 91)

EMXHookLibrary.SetEntityTypeSpouseProbabilityFactor(_entityType, _factor)
-> Setzt die Wahrscheinlichkeit, dass Siedler auf dem Fest eine Ehefrau finden. (Normal: 0.3)
Damit kann bspw. das Badehaus auch Ehefrauen beschäftigen.

EMXHookLibrary.SetBallistaAmmunitionAmount(_amount)
-> Setzt die Maximalanzahl an Munition von Ballisten (Mauerkatapult) per Typ.

EMXHookLibrary.SetMilitaryMetaFormationParameters(_distances)
-> Setzt einige Parameter zur Truppenanordnung. Der Parameter _distances muss ein table sein nach folgendem Vorbild:
-- {_rowDistance, _colDistance, _cartRowDistance, _cartColDistance, _engineRowDistance, _engineColDistance}.
Nicht benötigte Werte sind nil.

EMXHookLibrary.SetEntityTypeOutStockCapacity(_entityType, _upgradeLevel, _newLimit)	
-> Setzt den maximalen OutStock eines Entitätentyps basierend auf dessen Ausbaulevel. (Normal: 3, 6, 9 oder nur 9).
Funktioniert auch bei Lagerhäusern (bzw. bei allem, was einen OutStock besitzt).
ACHTUNG: Im Gegensatz zu EMXHookLibrary.SetMaxBuildingStockSize betrifft dies hier neu errichtete Gebäude eines Typs!

EMXHookLibrary.SetMaxStorehouseStockSize(_storehouseID, _maxStockSize)
-> Setzt den maximalen OutStock des Lagerhauses.
ACHTUNG: Im Gegensatz zu EMXHookLibrary.SetEntityTypeOutStockCapacity betrifft dies hier einzelne Lagerhäuser!

EMXHookLibrary.SetMaxBuildingStockSize(_buildingID, _maxStockSize)
-> Setzt den maximalen OutStock eines Gebäudes.
ACHTUNG: Im Gegensatz zu EMXHookLibrary.SetEntityTypeOutStockCapacity betrifft dies hier einzelne Gebäude!

EMXHookLibrary.SetBuildingInStockGood(_buildingID, _newGood)
-> Setzt eine neue Ware als InStock eines Gebäudes.

EMXHookLibrary.CreateBuildingInStockGoods(_buildingID, _newGoods)
-> Allokiert Speicher und setzt neue InStock Goods eines Gebäudes.
_newGoods muss zB folgendermaßen aussehen: {Goods.G_Grain, Goods.G_Wool}.
Es wird ein Table mit den originalen Pointern zurückgegeben, damit man die Werte wieder zurücksetzen kann.

EMXHookLibrary.SetBuildingTypeOutStockGood(_buildingID, _newGood, _setEntityTypeProduct)
-> Setzt eine neue Ware als OutStock eines Gebäudes. Wenn _setEntityTypeProduct ~= nil, wird auch das Product
des Entitätentyps gesetzt, ansonsten nur der OutStock für ein Gebäude.

EMXHookLibrary.SetGoodTypeParameters(_goodType, _requiredResource, _amount, _goodCategory, _animationParameters)
-> Setzt das benötigte Produktionsgut einer Ware und/oder deren benötigte Menge. (zB Goods.G_Carcass -> Goods.G_Sausage)
(Nicht benötigte Parameter sind nil).
Die Menge ist standardmäßig 1:1, kann aber beliebig verändert werden. (zB 3 Weizen für 1 Brot, 2 Stein für 1 Besen usw.)

EMXHookLibrary.CopyGoodTypePointer(_good, _copyGood)
-> Ermöglicht es, einige Parameter eines GoodTypes (bspw. RequiredResource) auch bei Goods zu verwenden, welche keine Einträge
für diese Dinge haben. Diese Einträge werden als Referenz auf einen anderen GoodType angelegt.

EMXHookLibrary.CreateGoodTypeRequiredResources(_goodType, _requiredResources)
-> Ermöglicht es, einige Parameter eines GoodTypes (bspw. RequiredResource) auch bei Goods zu verwenden, welche keine Einträge
für diese Dinge haben. Im Gegensatz zu EMXHookLibrary.CopyGoodTypePointer wird hier in allokiertem Speicher ein neues Array
angelegt. _requiredResources muss so aussehen: {{_resource, _amount, _supplier}, {_resource, _amount, _supplier}, ...}
Bspw. EMXHookLibrary.CreateGoodTypeRequiredResources(Goods.G_Soap, {{Goods.G_Wool, 3, EntityCategories.GC_Food_Supplier}, {Goods.G_Stone, 2, EntityCategories.GC_Food_Supplier}})
Wenn _requiredResources == nil ist, werden die Einträge zur Ware wieder gelöscht.

EMXHookLibrary.ToggleDEBUGMode(_magicWord, _setNewMagicWord)
-> Ermöglicht es, auch in der History Edition den Debug-Mode zu aktivieren.
_magicWord muss zuerst aus der OV ausgelesen werden und kann danach PC - spezifisch auch in der HE gesetzt werden.
Funktioniert NUR in der Steam - HE. Für die Ubisoft - HE sollte der S6Patcher verwendet werden!

EMXHookLibrary.SetPlayerColorRGB(_playerID, _rgb)
-> Setzt die Spielerfarbe eines Spielers neu. _rgb muss ein table mit den Farbwerten (von 0 - 255) sein. Beispiele:
(Der Alphakanal muss immer 127 betragen und der erste Eintrag im table sein. 0 und einstellige Werte müssen durch zwei Ziffern [bspw. 9 -> 09] repräsentiert werden)
-- EMXHookLibrary.SetPlayerColorRGB(1, {127, 0, 0, 255, 255}) -- Yellow
-- EMXHookLibrary.SetPlayerColorRGB(1, {127, 253, 112, 0, 0}) -- Dark Blue
-- EMXHookLibrary.SetPlayerColorRGB(1, {127, 255, 255, 255}) -- White

EMXHookLibrary.SetSettlersWorkBuilding(_settlerID, _buildingID)
-> Setzt das Arbeitsgebäude eines Siedlers. Dadurch ist es möglich, mehr als 3 Siedler an einem Gebäude beschäftigt zu haben.
ACHTUNG: Der Siedler muss bereits einem Gebäude zugeordnet sein, bevor gewechselt werden kann!
(Bei mehr als 3 Siedlern sollte zuvor EMXHookLibrary.SetWorkBuildingMaxNumberOfWorkers entsprechend gesetzt werden)

EMXHookLibrary.SetTypeAndMaxNumberOfWorkersForBuilding(_entityType, _maxWorkers, _workerType)
-> Setzt eine neue Maximalanzahl und einen neuen Typ an Arbeitern eines Gebäudetyps.

EMXHookLibrary.EditFestivalProperties(_festivalDuration, _promotionDuration, _promotionParticipantLimit, _festivalParticipantLimit)
->  Verändert einen oder mehrere Parameter der Feste (Aufstiegs- sowie normales Fest). (Nicht benötigte Parameter sind nil).
Geändert werden können Dauer sowie das Limit der möglichen Partizipierenden.

EMXHookLibrary.EditStringTableText(_IDManagerEntryIndex, _newString)
->  Verändert einen StringTable-Eintrag. Der EntryIndex muss zuerst ausgelesen werden und das Zeichenlimit muss beachtet werden.
Genaueres zur Verwendung auf Anfrage.
Bspw. "Saraya" -> "Testritter": EMXHookLibrary.EditStringTableText(5037, "Testritter")

EMXHookLibrary.SetEntityTypeMinimapIcon(_entityType, _iconIndex)
-> Setzt ein Minimap-Icon für einen Entitätentyp. Es sind Icons aus der Icontabelle möglich. 0 entfernt das Icon wieder.
Für bereits auf der Map existierende Entitäten sollte die Funktion in der FMA aufgerufen werden, ansonsten sind nur neu erstellte Entitäten betroffen.

EMXHookLibrary.SetColorSetColorRGB(_colorSetEntryIndex, _season, _rgb, _wetFactor)
-> Setzt die Farben eines ColorSets per Jahreszeit. Es wird eine Tabelle zurückgegeben, welche die originalen Values enthält, damit man
das ColorSet wieder zurücksetzen kann. Für den ersten Parameter anfragen.
Bspw. EMXHookLibrary.SetColorSetColorRGB(82, 1, {0.3, 0.7, 0.4, 0.7})
--> ColorSetIndex; Season (Spring); {Red, Green, Blue, Alpha}; WetFactor

EMXHookLibrary.SetEntityDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
-> Ermöglicht es, verschiedene Modelle von Gebäuden zu setzen. _params muss ein Table mit den Modellen sein.
_paramType muss ein String mit dem Typ sein. Mögliche Typen: "Models", "UpgradeSite", "Destroyed", "Lights".
_model setzt das derzeitige Model, kann auch nil sein.
Vor dem Ändern am Besten in der Definitions-xml der Entität nachschauen. Es kann sowohl eine (existierende) Entity-ID als auch ein Entitätentyp angegeben werden.
Bsp: EMXHookLibrary.SetEntityDisplayModelParameters(Entities.B_StoreHouse, "Models", {Models.Buildings_B_Jewelry_Buildingsite_1, Models.Buildings_B_Jewelry_Buildingsite_1, Models.Buildings_B_Jewelry_Buildingsite_1, Models.Buildings_B_Jewelry_Buildingsite_1}, {Models.Buildings_B_Jewelry_Buildingsite_1})

EMXHookLibrary.SetBuildingDisplayModelParameters(_entityIDOrType, _paramType, _params, _model)
-> Analog zu EMXHookLibrary.SetEntityDisplayModelParameters können hier die Modelle von (Produktions-)Gebäuden geändert werden.
Mögliche Typen: "Yards", "Roofs", "RoofDestroyed", "UpgradeSite", "Floors", "Gables", "Lights", "FireCounts".

EMXHookLibrary.SetEGLEffectDuration(_effect, _duration)
-> Ändert die Anzeigedauer eines EGL_Effects.
Bspw. EMXHookLibrary.SetEGLEffectDuration(EGL_Effects.FXLightning, 2)

EMXHookLibrary.SetEntityDisplayProperties(_entityIDOrType, _property, _value)
-> Ermöglicht es, verschiedene Display-Parameter einer Entität bzw. eines Entitätentyps anzupassen. Die möglichen Properties sind:
"ShowDestroyedModelAt", "MaxDarknessFactor", "ExplodeOnDestroyedModel", "SnowFactor", "SeasonColorSet", "LODDistance", "ConstructionSite", "Decal"
Einige Parameter müssen als Float gesetzt werden, dazu am Besten anfragen bzw. in der Definitions-xml nachsehen.
```
When errors occur, please notify me so i can fix them! ;)

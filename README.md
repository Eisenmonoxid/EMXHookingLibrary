# EMXHookingLibrary
A work-in-progress Hook for the game "The Settlers 6" and "The Settlers 6: History Edition".

Uses the "BigNum.lua" library. Special thanks to the authors!

## Features
```
EMXHookLibrary.SetTerritoryGoldCostByIndex(_arrayIndex, _price)
-> Setzt neue Goldkosten für Territorien, von Index 0 - 5 (0 = Low, 5 = Very Expensive).

EMXHookLibrary.SetSettlerIllnessCount(_newCount)
-> Setzt die Siedlermenge, ab derer Krankheiten ausbrechen können. (Normal: 151)

EMXHookLibrary.SetCarnivoreHealingSeconds(_newTime)
-> Setzt die Zeit, die Raubtiere benötigen, um ihre Gesundheit zu regenerieren.

EMXHookLibrary.SetKnightResurrectionTime(_newTime)
-> Setzt die Zeit, die sich der Ritter in der Burg erholen muss.

EMXHookLibrary.SetMaxBuildingTaxAmount(_newTaxAmount)
-> Setzt die maximale Anzahl an Steuereinnahmen, die Stadtgebäude besitzen können.

EMXHookLibrary.SetSettlerLimit(_cathedralIndex, _limit)
-> Setzt ein neues Siedlerlimit abhängig von der Ausbaustufe der Kathedrale/Kirche. (Von 0 - 6)

EMXHookLibrary.SetAmountOfTaxCollectors(_newAmount)
-> Setzt die Menge an Steuereintreibern, die maximal erzeugt werden. (Normal: 6)

EMXHookLibrary.SetFogOfWarVisibilityFactor(_newFactor)
-> Setzt den Faktor, um den der Fog of War in bereits aufgedeckten Gebieten angewandt wird. (Normal: 0.75)

EMXHookLibrary.SetBuildingFullCost(_entityType, _good, _amount, _secondGood, _secondAmount)
-> Setzt neue Kosten für einen Entitätentyp. _secondGood und _secondAmount dürfen nur verwendet werden, wenn das Gebäude bereits zwei Kosteneinträge im Originalspiel hat. Ansonsten sollte das Baukostensystem für die zweite Ware verwendet werden.

EMXHookLibrary.SetEntityTypeMaxHealth(_entityID, _newMaxHealth)
-> Setzt die maximalen Lebenspunkte (HP) eines Entitätentyps.

EMXHookLibrary.SetBuildingKnockDownCompensation(_percent)
-> Setzt den Rückerstattungsfaktor beim Abriss eines Gebäudes. (Normal: 50)

EMXHookLibrary.SetTerritoryCombatBonus(_newFactor)
-> Setzt den Faktor, um welchen Truppen in eigenen Territorien stärker sind. (Normal: 0.2)

EMXHookLibrary.SetCathedralCollectAmount(_newAmount)
-> Setzt die Menge, die ein Siedler beim Besuch der Predigt an Gold spendet. (Normal: 5)

EMXHookLibrary.SetFireHealthDecreasePerSecond(_newAmount)
-> Setzt den Schaden, welches Feuer in der Sekunde anrichtet. (Normal: 5)

EMXHookLibrary.SetSermonSettlerLimit(_playerID, _cathedralLevel, _limit)
-> Setzt das Limit an Siedlern in der Predigt per Kathedralenausbaulevel. (Normal: 10, 15, 30, 60)    

EMXHookLibrary.SetSoldierLimit(_playerID, _castleLevel, _limit)    
-> Setzt das Limit an Soldaten per Burgausbaulevel. (Normal: 25, 43, 61, 91)

EMXHookLibrary.SetBuildingTypeOutStockCapacity(_buildingID, _upgradeLevel, _limit)	
-> Setzt den maximalen Outstock eines Gebäudetyps basierend auf dessen Ausbaulevel. (Normal: 3, 6, 9 oder nur 9).
ACHTUNG: Im Gegensatz zu EMXHookLibrary.SetMaxBuildingStockSize betrifft dies hier neu errichtete Gebäude eines Typs!

EMXHookLibrary.SetMaxStorehouseStockSize(_storehouseID, _maxStockSize)
-> Setzt den maximalen Outstock des Lagerhauses.

EMXHookLibrary.SetMaxBuildingStockSize(_buildingID, _maxStockSize)
-> Setzt den maximalen Outstock eines Gebäudes.
ACHTUNG: Im Gegensatz zu EMXHookLibrary.SetBuildingTypeOutStockCapacity betrifft dies hier einzelne Gebäude!

EMXHookLibrary.SetBuildingInStockGood(_buildingID, _newGood)
-> Setzt eine neue Ware als InStock eines Gebäudes.

EMXHookLibrary.SetBuildingTypeOutStockProduct(_buildingID, _newGood)
-> Setzt eine neue Ware als OutStock eines Gebäudes.
```

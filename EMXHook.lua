InitSystem = function()
	local AddressEntity = Logic.GetStoreHouse(1)
	local BaseValues = {9522508, 13950896} -- OV, HE (Store)
	local CurrentGameValue = 0
	
	if (Network.IsNATReady == nil) then
		CurrentGameValue = BaseValues[1]
	else
		CurrentGameValue = BaseValues[2]
	end

	local PointerValue = BigNum.new()
	if (Network.IsNATReady == nil) then
		PointerValue = BigNum.new(Logic.GetEntityScriptingValue(AddressEntity, 81))
		PointerValue = BigNum.mt.sub(PointerValue, BigNum.new("652"))
	else
		PointerValue = BigNum.new(Logic.GetEntityScriptingValue(AddressEntity, -28))
		PointerValue = BigNum.mt.sub(PointerValue, BigNum.new("12831802"))
	end
	
	local CurrentVtablePtrValue = tonumber(BigNum.mt.tostring(GetValueAtPointer(AddressEntity, BigNum.mt.tostring(PointerValue))))
	
	if CurrentGameValue ~= CurrentVtablePtrValue then
		Framework.WriteToLog("ERROR: VTable Pointer not at the expected position: " ..CurrentGameValue.." - " ..CurrentVtablePtrValue)
		Logic.DEBUG_AddNote("ERROR: VTable Pointer not at the expected position: " ..CurrentGameValue.. " - " ..CurrentVtablePtrValue)
		return;
	end
	
	--]]
	--return true
	--local NextPointer = BigNum.new(Logic.GetEntityScriptingValue(AddressEntity, -81))
	--NextPointer = BigNum.mt.add(BigNum.new("1676208"), NextPointer) -- 11198716
	
	--local FirstValue = GetValueAtPointer(AddressEntity, BigNum.mt.tostring(NextPointer))
	--Logic.DEBUG_AddNote(BigNum.mt.tostring(GetValueAtPointer(AddressEntity, BigNum.mt.tostring(BigNum.mt.add(FirstValue, BigNum.new("624"))))))
end

GetValueAtPointer = function(_AdressEntity, _Pointer, _initialize)
	local VTableOV = {"81", "-81", "652"} 
	local VTableHE = {"-28", "-78", "12831802"}

	local BigAddress = BigNum.new()	
	local HeapStartAddressObject01 = BigNum.new()
	local HeapStartAddressObject02 = BigNum.new(_Pointer)
	local PointerDifference = BigNum.new()
	local FinalIndex = BigNum.new()
	
	if (Network.IsNATReady == nil) then
		BigAddress = BigNum.new(Logic.GetEntityScriptingValue(_AdressEntity, VTableOV[1]))
		HeapStartAddressObject01 = BigNum.mt.sub(BigAddress, BigNum.new(VTableOV[3]))
	else
		BigAddress = BigNum.new(Logic.GetEntityScriptingValue(_AdressEntity, VTableHE[1]))
		HeapStartAddressObject01 = BigNum.mt.sub(BigAddress, BigNum.new(VTableHE[3]))
	end

	PointerDifference = BigNum.mt.sub(HeapStartAddressObject02, HeapStartAddressObject01)
	FinalIndex = BigNum.mt.div(PointerDifference, BigNum.new("4"))
	
	if (Network.IsNATReady == nil) then
		FinalIndex = BigNum.mt.add(BigNum.new(VTableOV[2]), FinalIndex)
	else
		FinalIndex = BigNum.mt.add(BigNum.new(VTableHE[2]), FinalIndex)
	end
		
	return BigNum.new(Logic.GetEntityScriptingValue(_AdressEntity, tonumber(BigNum.mt.tostring(FinalIndex))))
end

SetValueAtPointer = function(_AdressEntity, _Pointer, _Value)
	local VTableOV = {"81", "-81", "652"} 
	local VTableHE = {"-28", "-78", "12831802"}

	local BigAddress = BigNum.new()	
	local HeapStartAddressObject01 = BigNum.new()
	local HeapStartAddressObject02 = BigNum.new(_Pointer)
	local PointerDifference = BigNum.new()
	local FinalIndex = BigNum.new()
	
	if (Network.IsNATReady == nil) then
		BigAddress = BigNum.new(Logic.GetEntityScriptingValue(_AdressEntity, VTableOV[1]))
		HeapStartAddressObject01 = BigNum.mt.sub(BigAddress, BigNum.new(VTableOV[3]))
	else
		BigAddress = BigNum.new(Logic.GetEntityScriptingValue(_AdressEntity, VTableHE[1]))
		HeapStartAddressObject01 = BigNum.mt.sub(BigAddress, BigNum.new(VTableHE[3]))
	end

	PointerDifference = BigNum.mt.sub(HeapStartAddressObject02, HeapStartAddressObject01)
	FinalIndex = BigNum.mt.div(PointerDifference, BigNum.new("4"))
	
	if (Network.IsNATReady == nil) then
		FinalIndex = BigNum.mt.add(BigNum.new(VTableOV[2]), FinalIndex)
	else
		FinalIndex = BigNum.mt.add(BigNum.new(VTableHE[2]), FinalIndex)
	end
	
	Logic.SetEntityScriptingValue(_AdressEntity, tonumber(BigNum.mt.tostring(FinalIndex)), _Value)
end
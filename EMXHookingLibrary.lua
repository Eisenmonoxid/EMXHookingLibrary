-- BigNum - Code --
BigNum = {
	RADIX = 10^7,
	RADIX_LEN = math.floor(math.log10(10^7)),
	
	mt = {}
};

function BigNum.new(Number)
	local BNum = {};
	setmetatable(BNum, BigNum.mt);
	BigNum.change(BNum, Number);
	return BNum;
end

function BigNum.mt.sub(Number1, Number2)
	local Temp = BigNum.new();
	BigNum.sub(BigNum.new(Number1), BigNum.new(Number2), Temp);
	return Temp;
end

function BigNum.mt.add(Number1, Number2)
	local Temp = BigNum.new();
	BigNum.add(BigNum.new(Number1), BigNum.new(Number2), Temp);
	return Temp;
end

function BigNum.mt.mul(Number1, Number2)
	local Temp = BigNum.new();
	BigNum.mul(BigNum.new(Number1), BigNum.new(Number2), Temp);
	return Temp;
end

function BigNum.mt.div(Number1, Number2)
	local Quotient = BigNum.new();
	local Remainder = BigNum.new();
	BigNum.div(BigNum.new(Number1), BigNum.new(Number2), Quotient, Remainder);
	return Quotient, Remainder;
end

function BigNum.mt.tostring(BNum)
	local str = "";
	local temp = "";
	if BNum == nil then
		return "nil";
	elseif BNum.len > 0 then
		for i = BNum.len - 2, 0, -1 do
			for j = 0, BigNum.RADIX_LEN - string.len(BNum[i]) - 1 do
				temp = temp .. '0';
			end
			temp = temp .. BNum[i];
		end
		temp = BNum[BNum.len - 1] .. temp;
		if BNum.signal == '-' then
			temp = BNum.signal .. temp;
		end
		return temp;
	else
		return "";
	end
end

function BigNum.mt.eq(Number1, Number2)
	return BigNum.eq(BigNum.new(Number1), BigNum.new(Number2));
end
function BigNum.mt.lt(Number1, Number2)
	return BigNum.lt(BigNum.new(Number1), BigNum.new(Number2));
end
function BigNum.mt.le(Number1, Number2)
	return BigNum.le(BigNum.new(Number1), BigNum.new(Number2));
end

function BigNum.mt.unm(num)
	local ret = BigNum.new(num)
	if ret.signal == '+' then
		ret.signal = '-'
	else
		ret.signal = '+'
	end
	return ret
end

BigNum.mt.__metatable = "hidden";
BigNum.mt.__tostring  = BigNum.mt.tostring;
-- arithmetics
BigNum.mt.__add = BigNum.mt.add;
BigNum.mt.__sub = BigNum.mt.sub;
BigNum.mt.__mul = BigNum.mt.mul;
BigNum.mt.__div = BigNum.mt.div;
BigNum.mt.__unm = BigNum.mt.unm;
-- Comparisons
BigNum.mt.__eq = BigNum.mt.eq; 
BigNum.mt.__le = BigNum.mt.le;
BigNum.mt.__lt = BigNum.mt.lt;
--concatenation
setmetatable(BigNum.mt, {__index = "inexistent field", __newindex = "not available", __metatable = "hidden"});

function BigNum.add( bnum1 , bnum2 , bnum3 )
   local maxlen = 0 ;
   local i = 0 ;
   local carry = 0 ;
   local signal = '+' ;
   local old_len = 0 ;
   --Handle the signals
   if bnum1 == nil or bnum2 == nil or bnum3 == nil then
      assert(false, "Function BigNum.add: parameter nil") ;
   elseif bnum1.signal == '-' and bnum2.signal == '+' then
      bnum1.signal = '+' ;
      BigNum.sub( bnum2 , bnum1 , bnum3 ) ;

      if not rawequal(bnum1, bnum3) then
         bnum1.signal = '-' ;
      end
      return 0 ;
   elseif bnum1.signal == '+' and bnum2.signal == '-' then   
      bnum2.signal = '+' ;
      BigNum.sub( bnum1 , bnum2 , bnum3 ) ;
      if not rawequal(bnum2, bnum3) then
         bnum2.signal = '-' ;
      end
      return 0 ;
   elseif bnum1.signal == '-' and bnum2.signal == '-' then
      signal = '-' ;
   end
   --
   old_len = bnum3.len ;
   if bnum1.len > bnum2.len then
      maxlen = bnum1.len ;
   else
      maxlen = bnum2.len ;
      bnum1 , bnum2 = bnum2 , bnum1 ;
   end
   --School grade sum
   for i = 0 , maxlen - 1 do
      if bnum2[i] ~= nil then
         bnum3[i] = bnum1[i] + bnum2[i] + carry ;
      else
         bnum3[i] = bnum1[i] + carry ;
      end
      if bnum3[i] >= BigNum.RADIX then
         bnum3[i] = bnum3[i] - BigNum.RADIX ;
         carry = 1 ;
      else
         carry = 0 ;
      end
   end
   --Update the answer's size
   if carry == 1 then
      bnum3[maxlen] = 1 ;
   end
   bnum3.len = maxlen + carry ;
   bnum3.signal = signal ;
   for i = bnum3.len, old_len do
      bnum3[i] = nil ;
   end
   return 0 ;
end

function BigNum.sub( bnum1 , bnum2 , bnum3 )
   local maxlen = 0 ;
   local i = 0 ;
   local carry = 0 ;
   local old_len = 0 ;
   --Handle the signals
   
   if bnum1 == nil or bnum2 == nil or bnum3 == nil then
      assert(false, "Function BigNum.sub: parameter nil") ;
   elseif bnum1.signal == '-' and bnum2.signal == '+' then
      bnum1.signal = '+' ;
      BigNum.add( bnum1 , bnum2 , bnum3 ) ;
      bnum3.signal = '-' ;
      if not rawequal(bnum1, bnum3) then
         bnum1.signal = '-' ;
      end
      return 0 ;
   elseif bnum1.signal == '-' and bnum2.signal == '-' then
      bnum1.signal = '+' ;
      bnum2.signal = '+' ;
      BigNum.sub( bnum2, bnum1 , bnum3 ) ;
      if not rawequal(bnum1, bnum3) then
         bnum1.signal = '-' ;
      end
      if not rawequal(bnum2, bnum3) then
         bnum2.signal = '-' ;
      end
      return 0 ;
   elseif bnum1.signal == '+' and bnum2.signal == '-' then
      bnum2.signal = '+' ;
      BigNum.add( bnum1 , bnum2 , bnum3 ) ;
      if not rawequal(bnum2, bnum3) then
         bnum2.signal = '-' ;
      end
      return 0 ;
   end
   --Tests if bnum2 > bnum1
   if BigNum.compareAbs( bnum1 , bnum2 ) == 2 then
      BigNum.sub( bnum2 , bnum1 , bnum3 ) ;
      bnum3.signal = '-' ;
      return 0 ;
   else
      maxlen = bnum1.len ;
   end
   old_len = bnum3.len ;
   bnum3.len = 0 ;
   --School grade subtraction
   for i = 0 , maxlen - 1 do
      if bnum2[i] ~= nil then
         bnum3[i] = bnum1[i] - bnum2[i] - carry ;
      else
         bnum3[i] = bnum1[i] - carry ;
      end
      if bnum3[i] < 0 then
         bnum3[i] = BigNum.RADIX + bnum3[i] ;
         carry = 1 ;
      else
         carry = 0 ;
      end

      if bnum3[i] ~= 0 then
         bnum3.len = i + 1 ;
      end
   end
   bnum3.signal = '+' ;
   --Check if answer's size if zero
   if bnum3.len == 0 then
      bnum3.len = 1 ;
      bnum3[0]  = 0 ;
   end
   if carry == 1 then
      assert(false, "Error in function sub" ) ;
   end
   for i = bnum3.len , BigNum.max( old_len , maxlen - 1 ) do
      bnum3[i] = nil ;
   end
   return 0 ;
end

function BigNum.mul( bnum1 , bnum2 , bnum3 )
   local i = 0 ; j = 0 ;
   local temp = BigNum.new( ) ;
   local temp2 = 0 ;
   local carry = 0 ;
   local oldLen = bnum3.len ;
   if bnum1 == nil or bnum2 == nil or bnum3 == nil then
      assert(false, "Function BigNum.mul: parameter nil") ;
   --Handle the signals
   elseif bnum1.signal ~= bnum2.signal then
      BigNum.mul( bnum1 , -bnum2 , bnum3 ) ;
      bnum3.signal = '-' ;
      return 0 ;
   end
   bnum3.len =  ( bnum1.len ) + ( bnum2.len ) ;
   --Fill with zeros
   for i = 1 , bnum3.len do
      bnum3[i - 1] = 0 ;
   end
   --Places nil where passes through this
   for i = bnum3.len , oldLen do
      bnum3[i] = nil ;
   end
   --School grade multiplication
   for i = 0 , bnum1.len - 1 do
      for j = 0 , bnum2.len - 1 do
         carry =  ( bnum1[i] * bnum2[j] + carry ) ;
         carry = carry + bnum3[i + j] ;
         bnum3[i + j] = math.mod ( carry , BigNum.RADIX ) ;
         temp2 = bnum3[i + j] ;
         carry =  math.floor ( carry / BigNum.RADIX ) ;
      end
      if carry ~= 0 then
         bnum3[i + bnum2.len] = carry ;
      end
      carry = 0 ;
   end

   --Update the answer's size
   for i = bnum3.len - 1 , 1 , -1 do
      if bnum3[i] ~= nil and bnum3[i] ~= 0 then
         break ;
      else
         bnum3[i] = nil ;
      end
      bnum3.len = bnum3.len - 1 ;
   end
   return 0 ; 
end

function BigNum.div( bnum1 , bnum2 , bnum3 , bnum4 )
   local temp = BigNum.new() ;
   local temp2 = BigNum.new() ;
   local one = BigNum.new( "1" ) ;
   local zero = BigNum.new( "0" ) ;
   --Check division by zero
   if BigNum.compareAbs( bnum2 , zero ) == 0 then
      assert(false, "Function BigNum.div: Division by zero" ) ;
   end     
   --Handle the signals
   if bnum1 == nil or bnum2 == nil or bnum3 == nil or bnum4 == nil then
      assert(false, "Function BigNum.div: parameter nil" ) ;
   elseif bnum1.signal == "+" and bnum2.signal == "-" then
      bnum2.signal = "+" ;
      BigNum.div( bnum1 , bnum2 , bnum3 , bnum4 ) ;
      bnum2.signal = "-" ;
      bnum3.signal = "-" ;
      return 0 ;
   elseif bnum1.signal == "-" and bnum2.signal == "+" then
      bnum1.signal = "+" ;
      BigNum.div( bnum1 , bnum2 , bnum3 , bnum4 ) ;
      bnum1.signal = "-" ;
      if bnum4 < zero then --Check if remainder is negative
         BigNum.add( bnum3 , one , bnum3 ) ;
         BigNum.sub( bnum2 , bnum4 , bnum4 ) ;
      end
      bnum3.signal = "-" ;
      return 0 ;
   elseif bnum1.signal == "-" and bnum2.signal == "-" then
      bnum1.signal = "+" ;
      bnum2.signal = "+" ;
      BigNum.div( bnum1 , bnum2 , bnum3 , bnum4 ) ;
      bnum1.signal = "-" ;
      if bnum4 < zero then --Check if remainder is negative      
         BigNum.add( bnum3 , one , bnum3 ) ;
         BigNum.sub( bnum2 , bnum4 , bnum4 ) ;
      end
      bnum2.signal = "-" ;
      return 0 ;
   end
   temp.len = bnum1.len - bnum2.len - 1 ;

   --Reset variables
   BigNum.change( bnum3 , "0" ) ;
   BigNum.change( bnum4 , "0" ) ; 

   BigNum.copy( bnum1 , bnum4 ) ;

   --Check if can continue dividing
   while( BigNum.compareAbs( bnum4 , bnum2 ) ~= 2 ) do
      if bnum4[bnum4.len - 1] >= bnum2[bnum2.len - 1] then
         BigNum.put( temp , math.floor( bnum4[bnum4.len - 1] / bnum2[bnum2.len - 1] ) , bnum4.len - bnum2.len ) ;
         temp.len = bnum4.len - bnum2.len + 1 ;
      else
         BigNum.put( temp , math.floor( ( bnum4[bnum4.len - 1] * BigNum.RADIX + bnum4[bnum4.len - 2] ) / bnum2[bnum2.len -1] ) , bnum4.len - bnum2.len - 1 ) ;
         temp.len = bnum4.len - bnum2.len ;
      end
    
      if bnum4.signal ~= bnum2.signal then
         temp.signal = "-";
      else
         temp.signal = "+";
      end
      BigNum.add( temp , bnum3 , bnum3 )  ;
      temp = temp * bnum2 ;
      BigNum.sub( bnum4 , temp , bnum4 ) ;
   end

   --Update if the remainder is negative
   if bnum4.signal == '-' then
      BigNum.decr( bnum3 ) ;
      BigNum.add( bnum2 , bnum4 , bnum4 ) ;
   end
   return 0 ;
end

function BigNum.eq( bnum1 , bnum2 )
   if BigNum.compare( bnum1 , bnum2 ) == 0 then
      return true ;
   else
      return false ;
   end
end

function BigNum.lt( bnum1 , bnum2 )
   if BigNum.compare( bnum1 , bnum2 ) == 2 then
      return true ;
   else
      return false ;
   end
end

function BigNum.le( bnum1 , bnum2 )
   local temp = -1 ;
   temp = BigNum.compare( bnum1 , bnum2 )
   if temp == 0 or temp == 2 then
      return true ;
   else
      return false ;
   end
end

function BigNum.compareAbs( bnum1 , bnum2 )
   if bnum1 == nil or bnum2 == nil then
      assert(false, "Function compare: parameter nil") ;
   elseif bnum1.len > bnum2.len then
      return 1 ;
   elseif bnum1.len < bnum2.len then
      return 2 ;
   else
      local i ;
      for i = bnum1.len - 1 , 0 , -1 do
         if bnum1[i] > bnum2[i] then
            return 1 ;
         elseif bnum1[i] < bnum2[i] then
            return 2 ;
         end
      end
   end
   return 0 ;
end

function BigNum.compare( bnum1 , bnum2 )
   local signal = 0 ;
   
   if bnum1 == nil or bnum2 == nil then
      assert(false, "Funtion BigNum.compare: parameter nil") ;
   elseif bnum1.signal == '+' and bnum2.signal == '-' then
      return 1 ;
   elseif bnum1.signal == '-' and bnum2.signal == '+' then
      return 2 ;
   elseif bnum1.signal == '-' and bnum2.signal == '-' then
      signal = 1 ;
   end
   if bnum1.len > bnum2.len then
      return 1 + signal ;
   elseif bnum1.len < bnum2.len then
      return 2 - signal ;
   else
      local i ;
      for i = bnum1.len - 1 , 0 , -1 do
         if bnum1[i] > bnum2[i] then
            return 1 + signal ;
	 elseif bnum1[i] < bnum2[i] then
	    return 2 - signal ;
	 end
      end
   end
   return 0 ;
end         

function BigNum.copy( bnum1 , bnum2 )
   if bnum1 ~= nil and bnum2 ~= nil then
      local i ;
      for i = 0 , bnum1.len - 1 do
         bnum2[i] = bnum1[i] ;
      end
      bnum2.len = bnum1.len ;
   else
      assert(false, "Function BigNum.copy: parameter nil") ;
   end
end

function BigNum.change(bnum1, num)
	local j = 0;
	local len = 0 ;
	local num = num;
	local l;
	local oldLen = 0;
	
	if bnum1 == nil then
		assert(false, "BigNum.change: parameter nil");
	elseif type(bnum1) ~= "table" then
		assert(false, "BigNum.change: parameter error, type unexpected");
	elseif num == nil then
		bnum1.len = 1;
		bnum1[0] = 0;
		bnum1.signal = "+";
	elseif type(num) == "table" and num.len ~= nil then  --check if num is a big number
		--copy given table to the new one
		for i = 0, num.len do
			bnum1[i] = num[i];
		end
		if num.signal ~= '-' and num.signal ~= '+' then
			bnum1.signal = '+';
		else
			bnum1.signal = num.signal;
		end
		
		oldLen = bnum1.len;
		bnum1.len = num.len;
	elseif type(num) == "string" or type(num) == "number" then
		if string.sub(num, 1, 1) == '+' or string.sub(num, 1, 1) == '-' then
			bnum1.signal = string.sub(num, 1, 1);
			num = string.sub(num, 2);
		else
			bnum1.signal = '+';
		end
		num = string.gsub( num , " " , "" ) ;
		local sf = string.find( num , "e" ) ;
		--Handles if the number is in exp notation
		if sf ~= nil then
			num = string.gsub( num , "%." , "" ) ;
			local e = string.sub( num , sf + 1 ) ;
			e = tonumber(e) ;
			if e ~= nil and e > 0 then 
				e = tonumber(e) ;
			else
				assert(false, "Function BigNum.change: string is not a valid number" ) ;
			end
			num = string.sub( num , 1 , sf - 2 ) ;
			for i = string.len( num ) , e do
				num = num .. "0" ;
			end
		else
			sf = string.find( num , "%." ) ;
			if sf ~= nil then
				num = string.sub( num , 1 , sf - 1 ) ;
			end
		end

		l = string.len( num ) ;
		oldLen = bnum1.len ;
		if (l > BigNum.RADIX_LEN) then
			local mod = l-( math.floor( l / BigNum.RADIX_LEN ) * BigNum.RADIX_LEN ) ;
			for i = 1 , l-mod, BigNum.RADIX_LEN do
				bnum1[j] = tonumber( string.sub( num, -( i + BigNum.RADIX_LEN - 1 ) , -i ) );
				--Check if string dosn't represents a number
				if bnum1[j] == nil then
				assert(false, "Function BigNum.change: string is not a valid number" ) ;
				bnum1.len = 0 ;
				return 1 ;
				end
				j = j + 1 ; 
				len = len + 1 ;
			end
			if (mod ~= 0) then
				bnum1[j] = tonumber( string.sub( num , 1 , mod ) ) ;
				bnum1.len = len + 1 ;
			else
				bnum1.len = len ;            
			end
			--Eliminate trailing zeros
			for i = bnum1.len - 1 , 1 , -1 do
				if bnum1[i] == 0 then
				bnum1[i] = nil ;
				bnum1.len = bnum1.len - 1 ;
				else
				break ;
				end
			end
		 
		else     
			-- string.len(num) <= BigNum.RADIX_LEN
			bnum1[j] = tonumber( num ) ;
			bnum1.len = 1 ;
		end
	else
		assert(false, "Function BigNum.change: parameter error, type unexpected");
	end

	-- eliminates the deprecated higher order 'algarisms'
	if oldLen ~= nil then
		for i = bnum1.len, oldLen do
			bnum1[i] = nil;
		end
	end

	return 0;
end 

function BigNum.put(bnum, int, pos)
	for i = 0, pos - 1 do
		bnum[i] = 0;
	end
	
	bnum[pos] = int;
	
	for i = pos + 1, bnum.len do
		bnum[i] = nil;
	end
	
	bnum.len = pos;
	return 0
end

function BigNum.max(int1, int2)
	if int1 > int2 then
		return int1;
	else
		return int2;
	end
end

function BigNum.decr(bnum1)
   BigNum.sub(bnum1, BigNum.new("1"), bnum1);
   return 0
end

-- Here starts the main hook lib code --

EMXHookLibrary = {
	CurrentVersion = "1.3.9 - 11.11.2023 19:04 - Eisenmonoxid",
	
	GlobalAdressEntity = 0,
	GlobalHeapStart = 0,
	
	IsHistoryEdition = false,
	HistoryEditionVariant = 0, -- 0 = OV, 1 = Steam, 2 = Ubi Connect
	WasInitialized = false,

	HelperFunctions = {},
	CachedClassPointers = {}
};

-- EMXHookLibrary.SetColorSetColorRGB(82, 1, {0.3, 0.7, 0.4, 0.7}) --Red, Green, Blue, Alpha
EMXHookLibrary.SetColorSetColorRGB = function(_ColorSetIndex, _season, _rgb)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"0", "16", "20"}) or {"4", "12", "16"}
	local SeasonIndizes = {0, 16, 32, 48}
	local OriginalValues = {}
	
	local GlobalsBaseEx = EMXHookLibrary.GetCGlobalsBaseEx()
	local CurrentPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(GlobalsBaseEx, "128")))

	local Counter = 0, CurrentIdentifier, Value
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(CurrentPointer, Offsets[1])))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, "4")))

	repeat
		CurrentIdentifier = EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, Offsets[2]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, "8")))
		if (CurrentIdentifier == _ColorSetIndex) then
			break;
		end
		Counter = Counter + 1
		if Counter >= 100 then -- ERROR: Endless Loop, ColorSet not Found!
			assert(false, "EMXHookLibrary: ERROR! ColorSet ".._ColorSetIndex.." NOT found! Aborting ...")
			Framework.WriteToLog("EMXHookLibrary: ERROR! ColorSet ".._ColorSetIndex.." NOT found! Aborting ...")
			return false;
		end
	until false
	
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, Offsets[3])))

	local CurrentIndex = SeasonIndizes[_season]
	for i = 1, 4, 1 do
		OriginalValues[#OriginalValues + 1] = EMXHookLibrary.HelperFunctions.Int2Float(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, CurrentIndex)))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(Value, CurrentIndex), EMXHookLibrary.HelperFunctions.Float2Int(_rgb[i]))
		CurrentIndex = CurrentIndex + 4
	end
	
	return OriginalValues
end

-- This requires the map to be restarted (or a save to be loaded) after setting the values! 0 -> No Icon!
EMXHookLibrary.SetEntityTypeMinimapIcon = function(_entityType, _iconIndex)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "88"}) or {"28", "92"}
	
	local ObjectInstance = EMXHookLibrary.GetBuildingInformationStructure()
	ObjectInstance = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(ObjectInstance, Offsets[1])))
	ObjectInstance = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(BigNum.mt.mul(_entityType, "4"), ObjectInstance)))	

	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(ObjectInstance, Offsets[2]), _iconIndex)
end

EMXHookLibrary.EditStringTableText = function(_IDManagerEntryIndex, _newString)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"20", "24", 0}) or {"24", "28", 4}
	
	local WideCharAsMultiByte = EMXHookLibrary.HelperFunctions.ConvertCharToMultiByte(_newString)
	local CTextSet = EMXHookLibrary.GetCTextSetStructure()
	CTextSet = EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(CTextSet, "4"))
	
	local TextSegment
	TextSegment = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(CTextSet, Offsets[1])))
	TextSegment = BigNum.mt.add(TextSegment, BigNum.mt.mul(_IDManagerEntryIndex, Offsets[2]))

	for i = 1, #WideCharAsMultiByte do
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(TextSegment, Offsets[3]), WideCharAsMultiByte[i])
		Offsets[3] = Offsets[3] + 4
	end
end

EMXHookLibrary.SetWorkBuildingMaxNumberOfWorkers = function(_buildingID, _maxWorkers)
	local Offset = (EMXHookLibrary.IsHistoryEdition and "256") or "288"
	local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_buildingID), "128")))
	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, Offset), _maxWorkers)
end

EMXHookLibrary.SetSettlersWorkBuilding = function(_settlerID, _buildingID)
	local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_settlerID), "84")))
	LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(LimitPointer))		
	EMXHookLibrary.SetValueAtPointer(LimitPointer, _buildingID)
end

-- EMXHookLibrary.SetPlayerColorRGB(1, {127, 0, 0, 255, 255}) -- Yellow
-- EMXHookLibrary.SetPlayerColorRGB(1, {127, 253, 112, 0, 0}) -- Dark Blue
-- EMXHookLibrary.SetPlayerColorRGB(1, {127, 255, 255, 255}) -- White
EMXHookLibrary.SetPlayerColorRGB = function(_playerID, _rgb)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"328", "172"}) or {"332", "176"}
	local Index = _playerID * 4
	local ColorStringHex = ""
	
	for i = 1, #_rgb, 1 do
		ColorStringHex = ColorStringHex .. string.format("%0x", _rgb[i])
	end

	local GlobalsBase = EMXHookLibrary.GetCGlobalsBaseEx()
	local Main = BigNum.mt.add(GlobalsBase, "108")
	Main = BigNum.new(EMXHookLibrary.GetValueAtPointer(Main))
	
	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(Main, Index), tonumber("0x" .. ColorStringHex))
	
	Main = BigNum.mt.add(Main, Offsets[1])
	Main = BigNum.new(EMXHookLibrary.GetValueAtPointer(Main))

	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(Main, Index), tonumber("0x" .. ColorStringHex))
	
	Main = BigNum.mt.add(GlobalsBase, "20")
	Main = BigNum.new(EMXHookLibrary.GetValueAtPointer(Main))
	Main = BigNum.mt.add(Main, Offsets[2])	
	Main = BigNum.new(EMXHookLibrary.GetValueAtPointer(Main))
	
	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(Main, Index), tonumber("0x" .. ColorStringHex))

	Logic.ExecuteInLuaLocalState([[
		Display.UpdatePlayerColors()
		GUI.RebuildMinimapTerrain()
		GUI.RebuildMinimapTerritory()
    ]]);
end

EMXHookLibrary.ToggleDEBUGMode = function(_magicWord, _setNewMagicWord)
	if not EMXHookLibrary.IsHistoryEdition then 
		local Word = EMXHookLibrary.GetValueAtPointer(BigNum.new("11190056"))
		Logic.DEBUG_AddNote("EMXHookLibrary: Debug Word for this PC is: " ..Word)
		Framework.WriteToLog("EMXHookLibrary: Debug Word for this PC is: " ..Word)
		
		if _setNewMagicWord ~= nil then
			EMXHookLibrary.SetValueAtPointer(BigNum.new("11190056"), _magicWord)
		end
		return;
	end

	local Value = BigNum.new(Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAdressEntity, -78))
	local PointerValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	
	local LowestDigit, HighestDigit, DereferenceString
	if EMXHookLibrary.HistoryEditionVariant == 1 then
		DereferenceString = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.sub(PointerValue, "2100263")))
	else
		LowestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.sub(PointerValue, "1069996")))
		HighestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.sub(PointerValue, "1069995")))
		LowestDigit = string.format("%x", BigNum.mt.tostring(LowestDigit))
		HighestDigit = string.format("%x", BigNum.mt.tostring(HighestDigit))

		while (string.len(LowestDigit) < 8) do
			LowestDigit = "0" .. LowestDigit
		end
		while (string.len(HighestDigit) < 8) do
			HighestDigit = "0" .. HighestDigit
		end
	
		LowestDigit = string.sub(LowestDigit, 1, 6)
		HighestDigit = string.sub(HighestDigit, 7, 8)

		DereferenceString = HighestDigit .. LowestDigit	
		DereferenceString = BigNum.new(tonumber("0x" .. DereferenceString))
	end
	
	local Word = EMXHookLibrary.GetValueAtPointer(DereferenceString)
	Logic.DEBUG_AddNote("EMXHookLibrary: Debug Word for this PC is: " ..Word)
	Framework.WriteToLog("EMXHookLibrary: Debug Word for this PC is: " ..Word)

	if _setNewMagicWord ~= nil then
		EMXHookLibrary.SetValueAtPointer(DereferenceString, _magicWord)
	end
end

EMXHookLibrary.EditFestivalProperties = function(_festivalDuration, _promotionDuration, _promotionParticipantLimit, _festivalParticipantLimit)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"496", "8", "144", "52", "176", "84"}) or {"504", "12", "188", "72", "224", "108"}
	
	local CMain = EMXHookLibrary.GetFrameworkCMainStructure()
	local CGLUEPropsManager = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(CMain, Offsets[1])))
	local CGLUEFestivalPropsManager = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(CGLUEPropsManager, "44")))
	local EGLCFestivalProps = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(CGLUEFestivalPropsManager, Offsets[2])))

	if _promotionParticipantLimit ~= nil then
		local ParticipantLimitsPromotion = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EGLCFestivalProps, Offsets[3])))
		for i = 0, 12, 4 do
			EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(ParticipantLimitsPromotion, i), _promotionParticipantLimit)
		end
	end
	
	if _festivalParticipantLimit ~= nil then
		local ParticipantLimits = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EGLCFestivalProps, Offsets[4])))
		for i = 0, 12, 4 do
			EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(ParticipantLimits, i), _festivalParticipantLimit)
		end
	end
	
	if _promotionDuration ~= nil then
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EGLCFestivalProps, Offsets[5]), _promotionDuration)
	end
	if _festivalDuration ~= nil then
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EGLCFestivalProps, Offsets[6]), _festivalDuration)
	end
end

EMXHookLibrary.SetBuildingTypeOutStockProduct = function(_buildingID, _newGood, _forEntityType)
	local HEValues = {"352", "4", "8", "20", "20", "128", "564"}
	local OVValues = {"364", "4", "8", "16", "24", "128", "612"}
	local SharedIdentifier = "-1035359747"
	
	local CurrentGoodType = Logic.GetGoodTypeOnOutStockByIndex(_buildingID, 0)
	if CurrentGoodType == _newGood then
		return;
	end
	
	local Value, Props
	local CorrespondingValues = {}
	if not EMXHookLibrary.IsHistoryEdition then 
		CorrespondingValues = OVValues
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_buildingID), BigNum.new(CorrespondingValues[1]))	
		Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[2]))
	else
		CorrespondingValues = HEValues
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_buildingID), BigNum.new(CorrespondingValues[1]))	
	end

	if _forEntityType ~= nil then
		Props = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_buildingID), BigNum.new(CorrespondingValues[6]))))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(Props, BigNum.new(CorrespondingValues[7])), _newGood)
	end

	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[2]))	
	Value = EMXHookLibrary.CompareIdentifierToStaticValue(Value, SharedIdentifier)	
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[4]))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[5]))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))

	EMXHookLibrary.SetValueAtPointer(Value, _newGood)
	
	if Logic.GetGoodTypeOnOutStockByIndex(_buildingID, 0) ~= _newGood then
		assert(false, "EMXHookLibrary: ERROR setting the building OutStock!")
	end
end

EMXHookLibrary.SetBuildingInStockGood = function(_buildingID, _newGood)
	local HEValues = {"352", "4", "8", "20", "18", "16"}
	local OVValues = {"364", "4", "8", "16", "24", "12"}
	local SharedIdentifier = BigNum.new("1501117341")
	
	local CurrentGoodType = Logic.GetGoodTypeOnInStockByIndex(_buildingID, 0)
	if CurrentGoodType == _newGood then
		return;
	end

	local Value
	local CorrespondingValues = {}
	if not EMXHookLibrary.IsHistoryEdition then 
		CorrespondingValues = OVValues
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_buildingID), BigNum.new(CorrespondingValues[1]))	
		Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[2]))
	else
		CorrespondingValues = HEValues
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_buildingID), BigNum.new(CorrespondingValues[1]))	
	end
	
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[2]))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))

	local CurrentIdentifier = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, BigNum.new(CorrespondingValues[6]))))
	while BigNum.compareAbs(SharedIdentifier, CurrentIdentifier) ~= 0 do
		Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[3]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		CurrentIdentifier = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, BigNum.new(CorrespondingValues[6]))))
	end

	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[4]))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[5]))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))

	EMXHookLibrary.SetValueAtPointer(Value, _newGood)
	
	if Logic.GetGoodTypeOnInStockByIndex(_buildingID, 0) ~= _newGood then
		assert(false, "EMXHookLibrary: ERROR setting the building InStock!")
	end
end

EMXHookLibrary.SetMaxBuildingStockSize = function(_buildingID, _maxStockSize)
	local HEValues = {"352", "4", "8", "20", "46"}
	local OVValues = {"364", "4", "8", "16", "52"}
	local SharedIdentifier = "-1035359747"
	
	local CurrentAmount = Logic.GetMaxAmountOnStock(_buildingID)
	if CurrentAmount == _maxStockSize then
		return;
	end
	
	local Value
	local CorrespondingValues = {}
	if not EMXHookLibrary.IsHistoryEdition then 
		CorrespondingValues = OVValues
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_buildingID), BigNum.new(CorrespondingValues[1]))
		Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[2]))
	else
		CorrespondingValues = HEValues
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_buildingID), BigNum.new(CorrespondingValues[1]))
	end
	
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[2]))	
	Value = EMXHookLibrary.CompareIdentifierToStaticValue(Value, SharedIdentifier)
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[4]))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[5]))

	EMXHookLibrary.SetValueAtPointer(Value, _maxStockSize)
	
	if Logic.GetMaxAmountOnStock(_buildingID) ~= _maxStockSize then
		assert(false, "EMXHookLibrary: ERROR setting the building stock limit!")
	end
end

EMXHookLibrary.SetMaxStorehouseStockSize = function(_storehouseID, _maxStockSize)
	local HEValues = {"352", "4", "8", "20", "68", "16"}
	local OVValues = {"364", "4", "8", "16", "76", "12"}
	local SharedIdentifier = BigNum.new("625443837")
	
	local CurrentAmount = Logic.GetMaxAmountOnStock(_storehouseID)
	if CurrentAmount == _maxStockSize then
		return;
	end

	local Value
	local CorrespondingValues = {}
	if not EMXHookLibrary.IsHistoryEdition then 
		CorrespondingValues = OVValues
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_storehouseID), BigNum.new(CorrespondingValues[1]))
		Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[2]))
	else
		CorrespondingValues = HEValues
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_storehouseID), BigNum.new(CorrespondingValues[1]))
	end

	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[2]))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		
	local CurrentIdentifier = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, BigNum.new(CorrespondingValues[6]))))
	while BigNum.compareAbs(SharedIdentifier, CurrentIdentifier) ~= 0 do
		Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[3]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		CurrentIdentifier = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, BigNum.new(CorrespondingValues[6]))))
	end

	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[4]))
	Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	Value = BigNum.mt.add(Value, BigNum.new(CorrespondingValues[5]))

	EMXHookLibrary.SetValueAtPointer(Value, _maxStockSize)
	
	if Logic.GetMaxAmountOnStock(_storehouseID) ~= _maxStockSize then
		assert(false, "EMXHookLibrary: ERROR setting the storehouse stock limit!")
	end
end

EMXHookLibrary.SetGoodTypeRequiredResourceAndAmount = function(_goodType, _requiredResource, _amount)
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"4", "36"}) or {"8", "40"}
	
	local Value = EMXHookLibrary.GetGoodTypeRequirementsStructure()
	Value = EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, Offsets[1]))
	Value = BigNum.mt.add(Value, BigNum.mt.mul(_goodType, "4"))
	Value = EMXHookLibrary.GetValueAtPointer(Value)
	Value = EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, Offsets[2]))

	if _requiredResource ~= nil then
		EMXHookLibrary.SetValueAtPointer(BigNum.new(Value), _requiredResource)
	end
	
	if _amount ~= nil then
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(Value, "4"), _amount)
	end
end

EMXHookLibrary.SetEntityTypeMaxHealth = function(_entityType, _newMaxHealth)
	local Offset = (EMXHookLibrary.IsHistoryEdition and "24") or "28"
	
	local ObjectInstance = EMXHookLibrary.GetBuildingInformationStructure()
	ObjectInstance = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(ObjectInstance, Offset)))
	ObjectInstance = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(BigNum.mt.mul(_entityType, "4"), ObjectInstance)))	
	
	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(ObjectInstance, "36"), _newMaxHealth)
end

EMXHookLibrary.GetCEntityManagerStructure = function() return EMXHookLibrary.GetObjectInstance("11199488", {85, 1, 4, 5, 8}, {293, 0, 0, 1, 8}) end
EMXHookLibrary.GetPlayerInformationStructure = function() return EMXHookLibrary.GetObjectInstance("11198716", {1601, 1, 2, 3, 8}, {28002, 0, 0, 1, 8}) end
EMXHookLibrary.GetBuildingInformationStructure = function() return EMXHookLibrary.GetObjectInstance("11198560", {2593, 1, 6, 7, 8}, {2358, 0, 0, 1, 8}) end
EMXHookLibrary.GetGoodTypeRequirementsStructure = function() return EMXHookLibrary.GetObjectInstance("11198636", {16529, 0, 0, 1, 8}, {30412, 1, 6, 7, 8}) end
EMXHookLibrary.GetTSlotCGameLogicStructure = function() return EMXHookLibrary.GetObjectInstance("11198552", {39, 0, 0, 1, 8}, {104, 1, 2, 3, 8}) end
EMXHookLibrary.GetCGlobalsBaseEx = function() return EMXHookLibrary.GetObjectInstance("11674352", {774921, 1, 4, 5, 8}, {1803892, 1, 2, 3, 8}) end
EMXHookLibrary.GetFrameworkCMainStructure = function() return EMXHookLibrary.GetObjectInstance("11158232", {2250717, 0, 0, 1, 8}, {1338624, 1, 4, 5, 8}, true) end
EMXHookLibrary.GetCTextSetStructure = function() return EMXHookLibrary.GetObjectInstance("11469188", {475209, 1, 4, 4, 8}, {1504636, 1, 6, 7, 8}) end

EMXHookLibrary.SetTerritoryGoldCostByIndex = function(_arrayIndex, _price)
	local Index = _arrayIndex * 4
	local Offset = (EMXHookLibrary.IsHistoryEdition and "628") or "684"

	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), BigNum.mt.add(Offset, Index)), _price)
end

EMXHookLibrary.ModifyPlayerInformationStructure = function(_newValue, _vanillaValue, _heValue)
	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), (EMXHookLibrary.IsHistoryEdition and _heValue) or _vanillaValue), _newValue)
end

EMXHookLibrary.SetSettlerIllnessCount = function(_newCount) EMXHookLibrary.ModifyPlayerInformationStructure(_newCount, "760", "700") end
EMXHookLibrary.SetCarnivoreHealingSeconds = function(_newTime) EMXHookLibrary.ModifyPlayerInformationStructure(_newTime, "680", "624") end
EMXHookLibrary.SetKnightResurrectionTime = function(_newTime) EMXHookLibrary.ModifyPlayerInformationStructure(_newTime, "184", "164") end
EMXHookLibrary.SetMaxBuildingTaxAmount = function(_newTaxAmount) EMXHookLibrary.ModifyPlayerInformationStructure(_newTaxAmount, "624", "580") end
EMXHookLibrary.SetAmountOfTaxCollectors = function(_newAmount) EMXHookLibrary.ModifyPlayerInformationStructure(_newAmount, "808", "744") end
EMXHookLibrary.SetFogOfWarVisibilityFactor = function(_newFactor) EMXHookLibrary.ModifyPlayerInformationStructure(EMXHookLibrary.HelperFunctions.Float2Int(_newFactor), "620", "576") end
EMXHookLibrary.SetBuildingKnockDownCompensation = function(_percent) EMXHookLibrary.ModifyPlayerInformationStructure(_percent, "4", "4") end
-- These three get set correctly but don't seem to do anything ingame. Might need further testing however.
--EMXHookLibrary.SetTrailSpeedModifier = function(_newFactor) EMXHookLibrary.ModifyPlayerInformationStructure(EMXHookLibrary.HelperFunctions.Float2Int(_newFactor), "496", "464") end
--EMXHookLibrary.SetRoadSpeedModifier = function(_newFactor) EMXHookLibrary.ModifyPlayerInformationStructure(EMXHookLibrary.HelperFunctions.Float2Int(_newFactor), "320", "300") end
--EMXHookLibrary.SetWaterDepthBlockingThreshold = function(_threshold) EMXHookLibrary.ModifyPlayerInformationStructure(_threshold, "456", "424") end
EMXHookLibrary.SetTerritoryCombatBonus = function(_newFactor) EMXHookLibrary.ModifyPlayerInformationStructure(EMXHookLibrary.HelperFunctions.Float2Int(_newFactor), "604", "560") end
EMXHookLibrary.SetCathedralCollectAmount = function(_newAmount) EMXHookLibrary.ModifyPlayerInformationStructure(_newAmount, "436", "404") end
EMXHookLibrary.SetFireHealthDecreasePerSecond = function(_newAmount) EMXHookLibrary.ModifyPlayerInformationStructure(_newAmount, "260", "240") end

EMXHookLibrary.SetSettlerLimit = function(_cathedralIndex, _limit)	
	local Offset = (EMXHookLibrary.IsHistoryEdition and "376") or "408"

	local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), Offset)))			
	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(_cathedralIndex, "4")), _limit)
end

EMXHookLibrary.SetLimitByEntityObject = function(_entityID, _upgradeLevel, _newLimit, _pointerValues)
	local Offset = (EMXHookLibrary.IsHistoryEdition and _pointerValues[2]) or _pointerValues[1]
	
	local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_entityID), "128")))
	LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, Offset)))
	
	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(_upgradeLevel, "4")), _newLimit)
end

EMXHookLibrary.SetSermonSettlerLimit = function(_playerID, _upgradeLevel, _newLimit) 
	EMXHookLibrary.SetLimitByEntityObject(Logic.GetCathedral(_playerID), _upgradeLevel, _newLimit, {"756", "680"})
end

EMXHookLibrary.SetSoldierLimit = function(_playerID, _upgradeLevel, _newLimit)	
	EMXHookLibrary.SetLimitByEntityObject(Logic.GetHeadquarters(_playerID), _upgradeLevel, _newLimit, {"788", "704"})
end

EMXHookLibrary.SetBuildingTypeOutStockCapacity = function(_buildingID, _upgradeLevel, _newLimit)	
	EMXHookLibrary.SetLimitByEntityObject(_buildingID, _upgradeLevel, _newLimit, {"676", "612"})
end

EMXHookLibrary.SetStoreHouseOutStockCapacity = function(_playerID, _upgradeLevel, _newLimit)	
	EMXHookLibrary.SetLimitByEntityObject(Logic.GetStoreHouse(_playerID), _upgradeLevel, _newLimit, {"676", "612"})
end

EMXHookLibrary.SetEntityTypeFullCost = function(_entityType, _good, _amount, _secondGood, _secondAmount)	
	local Offsets = (EMXHookLibrary.IsHistoryEdition and {"24", "136"}) or {"28", "144"}
	
	local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetBuildingInformationStructure(), Offsets[1])))
	LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(_entityType, "4"))))
	LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, Offsets[2])))

	EMXHookLibrary.SetValueAtPointer(LimitPointer, _good)
	EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, "4"), _amount)
	
	if _secondGood ~= nil and _secondAmount ~= nil then
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, "8"), _secondGood)
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, "12"), _secondAmount)
	end
end

-- Hooking Utility Methods --

EMXHookLibrary.GetObjectInstance = function(_ovPointer, _steamHEChars, _ubiHEChars, _subtract)
	if not EMXHookLibrary.IsHistoryEdition then 
		return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new(_ovPointer)));
	end
	
	if EMXHookLibrary.CachedClassPointers[_ovPointer] ~= nil then
		return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new(tonumber("0x" .. EMXHookLibrary.CachedClassPointers[_ovPointer]))));
	end
	
	local _lowestDigit = 0
	local _hexSplitChars = {}
	local LowestDigit, HighestDigit
	
	if EMXHookLibrary.HistoryEditionVariant == 1 then -- Steam HE
		_lowestDigit = _steamHEChars[1]
		_hexSplitChars = {_steamHEChars[2], _steamHEChars[3], _steamHEChars[4], _steamHEChars[5]}
	else -- Ubi Connect HE
		_lowestDigit = _ubiHEChars[1]
		_hexSplitChars = {_ubiHEChars[2], _ubiHEChars[3], _ubiHEChars[4], _ubiHEChars[5]}
	end
	
	local Value = BigNum.new(Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAdressEntity, -78))
	local PointerValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
	
	if _subtract ~= nil then
		LowestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.sub(PointerValue, (_lowestDigit))))
		HighestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.sub(PointerValue, (_lowestDigit - 1))))
	else
		LowestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, (_lowestDigit))))
		HighestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, (_lowestDigit + 1))))
	end
	
	local HexString01 = string.format("%x", BigNum.mt.tostring(LowestDigit))
	local HexString02 = string.format("%x", BigNum.mt.tostring(HighestDigit))
	
	-- Both strings need to consist of 8 digits, otherwise trailing zeroes got lost, so we need to re-add them
	while (string.len(HexString01) < 8) do
		HexString01 = "0" .. HexString01
	end
	while (string.len(HexString02) < 8) do
		HexString02 = "0" .. HexString02
	end
	
	HexString01 = string.sub(HexString01, _hexSplitChars[1], _hexSplitChars[2])
	HexString02 = string.sub(HexString02, _hexSplitChars[3], _hexSplitChars[4])

	local DereferenceString = HexString02 .. HexString01	
	Framework.WriteToLog("EMXHookLibrary: Going to dereference HexString: "..DereferenceString..". OVPointer: ".._ovPointer)
	
	EMXHookLibrary.CachedClassPointers[_ovPointer] = DereferenceString
	
	return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new(tonumber("0x" .. DereferenceString))));
end

EMXHookLibrary.CompareIdentifierToStaticValue = function(Value, Identifier)
	local Offset = (EMXHookLibrary.IsHistoryEdition and "16") or "12"
	local CurrentIdentifier = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, Offset)))
	local StaticValue = BigNum.new(Identifier)
	
	while (BigNum.compareAbs(CurrentIdentifier, StaticValue) ~= 0) do
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		CurrentIdentifier = EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(Value, Offset))
	end
	
	return Value
end

EMXHookLibrary.CalculateEntityIDToObject = function(_entityID)
	local Result = BigNum.new(EMXHookLibrary.HelperFunctions.BitAnd(_entityID, 65535))
	Result = BigNum.mt.mul(Result, "8")
	Result = BigNum.mt.add(Result, "20")
	Result = BigNum.mt.add(Result, EMXHookLibrary.GetCEntityManagerStructure())
	return BigNum.new(EMXHookLibrary.GetValueAtPointer(Result));
end

EMXHookLibrary.GetValueAtPointer = function(_Pointer)
	if not Logic.IsEntityAlive(EMXHookLibrary.GlobalAdressEntity) then
		Framework.WriteToLog("EMXHookLibrary: ERROR! Tried to get value at adress "..BigNum.mt.tostring(_Pointer).." without existing AdressEntity!")
		assert(false, "EMXHookLibrary: ERROR - AdressEntity is not existing!")
		return;
	end
	
	local Offset = (EMXHookLibrary.IsHistoryEdition and "-78") or "-81"
	local Index = BigNum.mt.sub(_Pointer, EMXHookLibrary.GlobalHeapStart)
	Index = BigNum.mt.div(Index, "4")
	Index = BigNum.mt.add(Offset, Index)

	return Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAdressEntity, tonumber(BigNum.mt.tostring(Index)))
end

EMXHookLibrary.SetValueAtPointer = function(_Pointer, _Value)
	if not Logic.IsEntityAlive(EMXHookLibrary.GlobalAdressEntity) then
		Framework.WriteToLog("EMXHookLibrary: ERROR! Tried to set a value at adress "..BigNum.mt.tostring(_Pointer).." without existing AdressEntity!")
		assert(false, "EMXHookLibrary: ERROR - AdressEntity is not existing!")
		return;
	end
	
	local Offset = (EMXHookLibrary.IsHistoryEdition and "-78") or "-81"
	local Index = BigNum.mt.sub(_Pointer, EMXHookLibrary.GlobalHeapStart)
	Index = BigNum.mt.div(Index, "4")
	Index = BigNum.mt.add(Offset, Index)
	
	Logic.SetEntityScriptingValue(EMXHookLibrary.GlobalAdressEntity, tonumber(BigNum.mt.tostring(Index)), _Value)
end

-- Initialization of the Library --

EMXHookLibrary.FindOffsetValue = function(_VTableOffset, _PointerOffset)
	if EMXHookLibrary.GlobalAdressEntity ~= 0 and Logic.IsEntityAlive(EMXHookLibrary.GlobalAdressEntity) then
		Logic.DestroyEntity(EMXHookLibrary.GlobalAdressEntity)
	end

	local posX, posY = 3000, 3000
	local AdressEntity = Logic.CreateEntity(Entities.D_X_TradeShip, posX, posY, 0, 0)
	local PointerEntity = Logic.CreateEntity(Entities.D_X_TradeShip, posX, posY, 0, 0)
	
	local PointerToVTableValue = BigNum.new(Logic.GetEntityScriptingValue(PointerEntity, _PointerOffset))
	
	Logic.SetVisible(AdressEntity, false)
	Logic.DestroyEntity(PointerEntity)
	
	EMXHookLibrary.GlobalAdressEntity = AdressEntity
	EMXHookLibrary.GlobalHeapStart = PointerToVTableValue
end

EMXHookLibrary.InitAdressEntity = function(_useLoadGameOverride) -- Entry Point
	if (nil == string.find(Framework.GetProgramVersion(), "1.71")) then
		EMXHookLibrary.WasInitialized = false
		Framework.WriteToLog("EMXHookLibrary: Patch 1.71 was NOT found! Aborting ...")
		assert(false, "EMXHookLibrary: Patch 1.71 was NOT found! Aborting ...")
		return;
	end
	
	for Key, Value in pairs(EMXHookLibrary.CachedClassPointers) do
		EMXHookLibrary.CachedClassPointers[Key] = nil
	end
	
	if (Network.IsNATReady == nil) then
		EMXHookLibrary.FindOffsetValue(-81, 36)
		EMXHookLibrary.IsHistoryEdition = false
		EMXHookLibrary.HistoryEditionVariant = 0
	else
		EMXHookLibrary.FindOffsetValue(-78, 34)
		EMXHookLibrary.IsHistoryEdition = true
		EMXHookLibrary.HistoryEditionVariant = EMXHookLibrary.GetHistoryEditionVariant()
	end
	EMXHookLibrary.WasInitialized = true
	
	Framework.WriteToLog("EMXHookLibrary: Initialization successful! Version: " .. EMXHookLibrary.CurrentVersion .. ". IsHistoryEdition: "..tostring(EMXHookLibrary.IsHistoryEdition)..". HistoryEditionVariant: "..tostring(EMXHookLibrary.HistoryEditionVariant)..".")
	Framework.WriteToLog("EMXHookLibrary: Heap Object starts at "..BigNum.mt.tostring(EMXHookLibrary.GlobalHeapStart)..". AdressEntity ID: "..tostring(EMXHookLibrary.GlobalAdressEntity)..".")

	if _useLoadGameOverride then
		EMXHookLibrary.OverrideSavegameHandling()
		Framework.WriteToLog("EMXHookLibrary: LoadGame Overwritten!")
	end
end

EMXHookLibrary.GetHistoryEditionVariant = function()
	local Value = BigNum.new(Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAdressEntity, -78))
	local PointerValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))

	local Digit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, BigNum.new("105"))))
	local HexString = string.format("%x", BigNum.mt.tostring(Digit))

	HexString = string.sub(HexString, 3, 8)
	
	Framework.WriteToLog("EMXHookLibrary: History Edition Variant -> Found "..HexString.." - Expected: 92ff")
	
	if HexString == "92ff" then
		return 1
	else
		return 2
	end
end

EMXHookLibrary.OverrideSavegameHandling = function()
	-- This is necessary if you do not want to reset the hooked values at the end of the map
	Logic.ExecuteInLuaLocalState([[
		local CurrentLanguage = Network.GetDesiredLanguage()
		
		GUI_Window.MainMenuExit = function()
			Framework.ExitGame()
		end
	
		if InitBottomButtons_ORIG == nil then
			InitBottomButtons_ORIG = GUI_MissionStatistic.InitBottomButtons;
		end
		GUI_MissionStatistic.InitBottomButtons = function()
			InitBottomButtons_ORIG()
		
			local ContainerBottomWidget = "/InGame/MissionStatistic/ContainerBottom"
			if CurrentLanguage == "de" then
				XGUIEng.SetText(ContainerBottomWidget .. "/BackMenu", "{center}{@color:255,80,80,255}Spiel Beenden")
			else
				XGUIEng.SetText(ContainerBottomWidget .. "/BackMenu", "{center}{@color:255,80,80,255}Exit Game")
			end
		end

		GUI_Window.QuickLoad = function() return true end
		KeyBindings_LoadGame = function() return true end

		if ToggleInGameMenu == nil then
			ToggleInGameMenu = GUI_Window.ToggleInGameMenu;
		end
		GUI_Window.ToggleInGameMenu = function()
			ToggleInGameMenu()
		
			XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickLoad", 0)
		end
		
		OpenLoadDialog = function()
			LoadDialog.Starting = false
			LockInputForDialog()
			XGUIEng.ShowWidget(LoadDialog.Widget.Dialog,1)
			XGUIEng.PushPage(LoadDialog.Widget.Dialog,false)

			XGUIEng.ListBoxPopAll(LoadDialog.Widget.FileList)
			XGUIEng.ListBoxPopAll(LoadDialog.Widget.MapList)
			XGUIEng.ListBoxPopAll(LoadDialog.Widget.DateList)
			XGUIEng.ListBoxPopAll(LoadDialog.Widget.TimeList)
	
			local Names = Framework.GetSaveGameNamesExEx()
			local Extension = GetSaveGameExtension()
			local ID = Names[1]
			local Count = 2
			local Entries = #Names
			
			Entries = (Entries - 1) / 4
			LoadDialog.FileId = ID + 1

			for i = 1, Entries do
				local Name = Names[Count]
				local Date = Names[Count + 1]
				local Time = Names[Count + 2]
				local Map = Tool_GetLocalizedMapName(Names[Count + 3])

				if string.lower(Names[Count + 3]) == string.lower(Framework.GetCurrentMapName()) then
					local FinalName = string.gsub(Name, Extension, "")
 	
					-- make sure the listboxes are filled from right to left (against the linking order)
					XGUIEng.ListBoxPushItem(LoadDialog.Widget.TimeList, Time)
					XGUIEng.ListBoxPushItem(LoadDialog.Widget.DateList, Date)
					XGUIEng.ListBoxPushItem(LoadDialog.Widget.MapList, Map) 	
					XGUIEng.ListBoxPushItem(LoadDialog.Widget.FileList, FinalName)
				end
 		
				Count = Count + 4
			end

			if Game ~= nil then
				LoadDialog.Backup.Speed = Game.GameTimeGetFactor()
				Game.GameTimeSetFactor( GUI.GetPlayerID(), 0 )
			end

			UpdateLoadDialog()
		end
	]]);
end

-- Some Helpers --

function EMXHookLibrary.HelperFunctions.qmod(a, b)
	return a - math.floor(a / b) * b
end

function EMXHookLibrary.HelperFunctions.Int2Float(num)
	if (num == 0) then
		return 0;
	end

	local sign = 1

	if (num < 0) then
		num = 2147483648 + num
		sign = -1
	end

	local frac = EMXHookLibrary.HelperFunctions.qmod(num, 8388608)
	local headPart = (num - frac) / 8388608
	local expNoSign = EMXHookLibrary.HelperFunctions.qmod(headPart, 256)
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

function EMXHookLibrary.HelperFunctions.bitsInt(num)
	local t = {}
	while num > 0 do
		rest = EMXHookLibrary.HelperFunctions.qmod(num, 2)
		table.insert(t, 1, rest)
		num = (num - rest) / 2
	end
	table.remove(t, 1)
	return t
end

function EMXHookLibrary.HelperFunctions.bitsFrac(num, t)
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

function EMXHookLibrary.HelperFunctions.Float2Int(fval)
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
		bits = EMXHookLibrary.HelperFunctions.bitsInt(intPart)
		exp = table.getn(bits)
		EMXHookLibrary.HelperFunctions.bitsFrac(fracPart, bits)
	else
		bits = {}
		EMXHookLibrary.HelperFunctions.bitsFrac(fval, bits)
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

function EMXHookLibrary.HelperFunctions.BitAnd(a, b)
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
    return result
end

function EMXHookLibrary.HelperFunctions.ConvertCharToMultiByte(_string)
	local OutputHexString = "" 
	local OutputNumbers = {}
	
	local CurrentCharacter = 0
	for i = 1, #_string, 1 do
		CurrentCharacter = _string:sub(i, i)
		OutputHexString = "00" .. string.format("%0x", string.byte(CurrentCharacter)) .. OutputHexString
		
		if math.fmod(i, 2) == 0 then
			OutputNumbers[#OutputNumbers + 1] = tonumber("0x" .. OutputHexString)
			OutputHexString = ""
		end
	end
	
	OutputNumbers[#OutputNumbers + 1] = 0
	
	return OutputNumbers
end
--#EOF
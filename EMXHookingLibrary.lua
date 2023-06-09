--[[
	-> EMXHookLibrary uses the "Big Numbers library for Lua", maintained by ...
		fmp - Frederico Macedo Pessoa
		msm - Marco Serpa Molinaro
	-> I want to thank the authors for making this project possible.
	-> I also want to thank Kantelo and Zedeg for creating the original SCV for The Settlers: Heritage of Kings, and mcb for his help!
]]--
-- BigNum - Code --
--%%%%%%%%  Constants used in the file %%%%%%%%--{{{1
   RADIX = 10^7 ;
   RADIX_LEN = math.floor( math.log10 ( RADIX ) ) ;
--%%%%%%%%        Start of Code        %%%%%%%%--
BigNum = {} ;
BigNum.mt = {} ;

function BigNum.new( num ) --{{{2
   local bignum = {} ;
   setmetatable( bignum , BigNum.mt ) ;
   BigNum.change( bignum , num ) ;
   return bignum ;
end

function BigNum.mt.sub( num1 , num2 )
   local temp = BigNum.new() ;
   local bnum1 = BigNum.new( num1 ) ;
   local bnum2 = BigNum.new( num2 ) ;
   BigNum.sub( bnum1 , bnum2 , temp ) ;
   return temp ;
end

function BigNum.mt.add( num1 , num2 )
   local temp = BigNum.new() ;
   local bnum1 = BigNum.new( num1 ) ;
   local bnum2 = BigNum.new( num2 ) ;
   BigNum.add( bnum1 , bnum2 , temp ) ;
   return temp ;
end

function BigNum.mt.mul( num1 , num2 )
   local temp = BigNum.new() ;
   local bnum1 = BigNum.new( num1 ) ;
   local bnum2 = BigNum.new( num2 ) ;
   BigNum.mul( bnum1 , bnum2 , temp ) ;
   return temp ;
end

function BigNum.mt.div( num1 , num2 )
   local bnum1 = {} ;
   local bnum2 = {} ;
   local bnum3 = BigNum.new() ;
   local bnum4 = BigNum.new() ;
   bnum1 = BigNum.new( num1 ) ;
   bnum2 = BigNum.new( num2 ) ;
   BigNum.div( bnum1 , bnum2 , bnum3 , bnum4 ) ;
   return bnum3 , bnum4 ;
end

function BigNum.mt.tostring( bnum )
   local i = 0 ;
   local j = 0 ;
   local str = "" ;
   local temp = "" ;
   if bnum == nil then
      return "nil" ;
   elseif bnum.len > 0 then
      for i = bnum.len - 2 , 0 , -1  do
         for j = 0 , RADIX_LEN - string.len( bnum[i] ) - 1 do
            temp = temp .. '0' ;
         end
         temp = temp .. bnum[i] ;
      end
      temp = bnum[bnum.len - 1] .. temp ;
      if bnum.signal == '-' then
         temp = bnum.signal .. temp ;
      end
      return temp ;
   else
      return "" ;
   end
end

function BigNum.mt.pow( num1 , num2 )
   local bnum1 = BigNum.new( num1 ) ;
   local bnum2 = BigNum.new( num2 ) ;
   return BigNum.pow( bnum1 , bnum2 ) ;
end

function BigNum.mt.eq( num1 , num2 )
   local bnum1 = BigNum.new( num1 ) ;
   local bnum2 = BigNum.new( num2 ) ;
   return BigNum.eq( bnum1 , bnum2 ) ;
end

function BigNum.mt.lt( num1 , num2 )
   local bnum1 = BigNum.new( num1 ) ;
   local bnum2 = BigNum.new( num2 ) ;
   return BigNum.lt( bnum1 , bnum2 ) ;
end

function BigNum.mt.le( num1 , num2 )
   local bnum1 = BigNum.new( num1 ) ;
   local bnum2 = BigNum.new( num2 ) ;
   return BigNum.le( bnum1 , bnum2 ) ;
end

function BigNum.mt.unm( num )
   local ret = BigNum.new( num )
   if ret.signal == '+' then
      ret.signal = '-'
   else
      ret.signal = '+'
   end
   return ret
end

BigNum.mt.__metatable = "hidden"           ; -- answer to getmetatable(aBignum)
BigNum.mt.__tostring  = BigNum.mt.tostring ;
-- arithmetics
BigNum.mt.__add = BigNum.mt.add ;
BigNum.mt.__sub = BigNum.mt.sub ;
BigNum.mt.__mul = BigNum.mt.mul ;
BigNum.mt.__div = BigNum.mt.div ;
BigNum.mt.__pow = BigNum.mt.pow ;
BigNum.mt.__unm = BigNum.mt.unm ;
-- Comparisons
BigNum.mt.__eq = BigNum.mt.eq   ; 
BigNum.mt.__le = BigNum.mt.le   ;
BigNum.mt.__lt = BigNum.mt.lt   ;
--concatenation
setmetatable( BigNum.mt, { __index = "inexistent field", __newindex = "not available", __metatable="hidden" } ) ;

function BigNum.add( bnum1 , bnum2 , bnum3 )
   local maxlen = 0 ;
   local i = 0 ;
   local carry = 0 ;
   local signal = '+' ;
   local old_len = 0 ;
   --Handle the signals
   if bnum1 == nil or bnum2 == nil or bnum3 == nil then
      error("Function BigNum.add: parameter nil") ;
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
      if bnum3[i] >= RADIX then
         bnum3[i] = bnum3[i] - RADIX ;
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
      error("Function BigNum.sub: parameter nil") ;
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
         bnum3[i] = RADIX + bnum3[i] ;
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
      error( "Error in function sub" ) ;
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
      error("Function BigNum.mul: parameter nil") ;
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
         bnum3[i + j] = math.mod ( carry , RADIX ) ;
         temp2 = bnum3[i + j] ;
         carry =  math.floor ( carry / RADIX ) ;
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
      error( "Function BigNum.div: Division by zero" ) ;
   end     
   --Handle the signals
   if bnum1 == nil or bnum2 == nil or bnum3 == nil or bnum4 == nil then
      error( "Function BigNum.div: parameter nil" ) ;
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
         BigNum.put( temp , math.floor( ( bnum4[bnum4.len - 1] * RADIX + bnum4[bnum4.len - 2] ) / bnum2[bnum2.len -1] ) , bnum4.len - bnum2.len - 1 ) ;
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

function BigNum.pow( bnum1 , bnum2 )
   local n = BigNum.new( bnum2 ) ;
   local y = BigNum.new( 1 ) ;
   local z = BigNum.new( bnum1 ) ;
   local zero = BigNum.new( "0" ) ;
   if bnum2 < zero then
      error( "Function BigNum.exp: domain error" ) ;
   elseif bnum2 == zero then
      return y ;
   end
   while 1 do
      if math.mod( n[0] , 2 ) == 0 then
         n = n / 2 ;
      else
         n = n / 2 ;
         y = z * y  ;
         if n == zero then
            return y ;
         end
      end
      z = z * z ;
   end
end
BigNum.exp = BigNum.pow

function BigNum.gcd( bnum1 , bnum2 )
   local a = {} ;
   local b = {} ;
   local c = {} ;
   local d = {} ;
   local zero = {} ;
   zero = BigNum.new( "0" ) ;
   if bnum1 == zero or bnum2 == zero then
      return BigNum.new( "1" ) ;
   end
   a = BigNum.new( bnum1 ) ;
   b = BigNum.new( bnum2 ) ;
   a.signal = '+' ;
   b.signal = '+' ;
   c = BigNum.new() ;
   d = BigNum.new() ;
   while b > zero do
      BigNum.div( a , b , c , d ) ;
      a , b , d = b , d , a ;
   end
   return a ;
end
BigNum.mmc = BigNum.gcd

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
      error("Function compare: parameter nil") ;
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
      error("Funtion BigNum.compare: parameter nil") ;
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
      error("Function BigNum.copy: parameter nil") ;
   end
end

function BigNum.change( bnum1 , num )
   local j = 0 ;
   local len = 0  ;
   local num = num ;
   local l ;
   local oldLen = 0 ;
   if bnum1 == nil then
      error( "BigNum.change: parameter nil" ) ;
   elseif type( bnum1 ) ~= "table" then
      error( "BigNum.change: parameter error, type unexpected" ) ;
   elseif num == nil then
      bnum1.len = 1 ;
      bnum1[0] = 0 ;
      bnum1.signal = "+";
   elseif type( num ) == "table" and num.len ~= nil then  --check if num is a big number
      --copy given table to the new one
      for i = 0 , num.len do
         bnum1[i] = num[i] ;
      end
      if num.signal ~= '-' and num.signal ~= '+' then
         bnum1.signal = '+' ;
      else
         bnum1.signal = num.signal ;
      end
      oldLen = bnum1.len ;
      bnum1.len = num.len ;
   elseif type( num ) == "string" or type( num ) == "number" then
      if string.sub( num , 1 , 1 ) == '+' or string.sub( num , 1 , 1 ) == '-' then
         bnum1.signal = string.sub( num , 1 , 1 ) ;
         num = string.sub(num, 2) ;
      else
         bnum1.signal = '+' ;
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
            error( "Function BigNum.change: string is not a valid number" ) ;
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
      if (l > RADIX_LEN) then
         local mod = l-( math.floor( l / RADIX_LEN ) * RADIX_LEN ) ;
         for i = 1 , l-mod, RADIX_LEN do
            bnum1[j] = tonumber( string.sub( num, -( i + RADIX_LEN - 1 ) , -i ) );
            --Check if string dosn't represents a number
            if bnum1[j] == nil then
               error( "Function BigNum.change: string is not a valid number" ) ;
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
         -- string.len(num) <= RADIX_LEN
         bnum1[j] = tonumber( num ) ;
         bnum1.len = 1 ;
      end
   else
      error( "Function BigNum.change: parameter error, type unexpected" ) ;
   end

   --eliminates the deprecated higher order 'algarisms'
   if oldLen ~= nil then
      for i = bnum1.len , oldLen do
         bnum1[i] = nil ;
      end
   end

   return 0 ;
end 

function BigNum.put( bnum , int , pos )
   if bnum == nil then
      error("Function BigNum.put: parameter nil") ;
   end
   local i = 0 ;
   for i = 0 , pos - 1 do
      bnum[i] = 0 ;
   end
   bnum[pos] = int ;
   for i = pos + 1 , bnum.len do
      bnum[i] = nil ;
   end
   bnum.len = pos ;
   return 0 ;
end

function BigNum.max( int1 , int2 )
   if int1 > int2 then
      return int1 ;
   else
      return int2 ;
   end
end

function BigNum.decr( bnum1 )
   local temp = {} ;
   temp = BigNum.new( "1" ) ;
   BigNum.sub( bnum1 , temp , bnum1 ) ;
   return 0 ;
end

-- Here starts the main hook lib code --
EMXHookLibrary = {
	CurrentVersion = "1.0.5 - 13.07.2023 12:50 - Eisenmonoxid",
	GlobalAddressEntity = 0,
	GlobalPointerEntity = 0,
	GlobalHeapStart = 0,
	GlobalVTableValue = 0,
	IsHistoryEdition = false,
	WasInitialized = false,
	HelperFunctions = {}
};

EMXHookLibrary.SetMaxStorehouseStockSize = function(_storehouseID, _maxStockSize)
	local HEValues = {"352", "4", "8", "20", "68"}
	local OVValues = {"364", "4", "8", "16", "76"}
		
	local Value
	if not EMXHookLibrary.IsHistoryEdition then 
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_storehouseID), BigNum.new(OVValues[1]))
		Value = BigNum.mt.add(Value, BigNum.new(OVValues[2]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(OVValues[2]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(OVValues[3]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(OVValues[3]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(OVValues[4]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(OVValues[5]))
	else
		Value = BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_storehouseID), BigNum.new(HEValues[1]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(HEValues[2]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(HEValues[3]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(HEValues[3]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(HEValues[4]))
		Value = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))
		Value = BigNum.mt.add(Value, BigNum.new(HEValues[5]))
	end

	EMXHookLibrary.SetValueAtPointer(Value, _maxStockSize)
	
	if Logic.GetMaxAmountOnStock(_storehouseID) ~= _maxStockSize then
		assert(false, "EMXHookLibrary: ERROR setting the storehouse stock limit!")
	end
end

EMXHookLibrary.SetEntityTypeMaxHealth = function(_entityID, _newMaxHealth)
	local EntityObject = EMXHookLibrary.CalculateEntityIDToObject(_entityID)
	local ObjectValue = EMXHookLibrary.GetBuildingInformationStructure()
	
	if not EMXHookLibrary.IsHistoryEdition then 
		EntityObject = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EntityObject, BigNum.new("24"))))
		ObjectValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(ObjectValue, BigNum.new("28"))))

		EntityObject = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(BigNum.mt.mul(EntityObject, BigNum.new("4")), ObjectValue)))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EntityObject, BigNum.new("36")), _newMaxHealth)
	else
		EntityObject = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EntityObject, BigNum.new("24"))))
		ObjectValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(ObjectValue, BigNum.new("24"))))

		EntityObject = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(BigNum.mt.mul(EntityObject, BigNum.new("4")), ObjectValue)))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EntityObject, BigNum.new("36")), _newMaxHealth)
	end
end

EMXHookLibrary.CalculateEntityIDToObject = function(_entityID)
	local Result = BigNum.new(EMXHookLibrary.HelperFunctions.BitAnd(_entityID, 65535))
	Result = BigNum.mt.mul(Result, BigNum.new("8"))
	Result = BigNum.mt.add(Result, BigNum.new("20"))
	Result = BigNum.mt.add(Result, EMXHookLibrary.GetCEntityManagerStructure())
	return BigNum.new(EMXHookLibrary.GetValueAtPointer(Result));
end

EMXHookLibrary.GetTSlotCGameLogicStructure = function()
	if not EMXHookLibrary.IsHistoryEdition then 
		return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new("11198552")));
	end

	local Value = BigNum.new(Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAddressEntity, -78))
	local PointerValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))

	local LowestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, BigNum.new("40"))))
	local HexString01 = string.format("%x", BigNum.mt.tostring(LowestDigit))

	return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new(tonumber("0x" .. HexString01))));
end

EMXHookLibrary.GetCEntityManagerStructure = function()
	if not EMXHookLibrary.IsHistoryEdition then 
		return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new("11199488")));
	end

	local Value = BigNum.new(Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAddressEntity, -78))
	local PointerValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))

	local LowestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, BigNum.new("85"))))
	local HighestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, BigNum.new("86"))))

	local HexString01 = string.format("%x", BigNum.mt.tostring(LowestDigit))
	local HexString02 = string.format("%x", BigNum.mt.tostring(HighestDigit))
	
	HexString01 = string.sub(HexString01, 1, 4)
	HexString02 = string.sub(HexString02, 5, 8)

	local DereferenceString = HexString02 .. HexString01	
	return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new(tonumber("0x" .. DereferenceString))));
end

EMXHookLibrary.GetPlayerInformationStructure = function()
	if not EMXHookLibrary.IsHistoryEdition then 
		return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new("11198716")));
	end

	local Value = BigNum.new(Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAddressEntity, -78))
	local PointerValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))

	local LowestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, BigNum.new("1601"))))
	local HighestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, BigNum.new("1602"))))

	local HexString01 = string.format("%x", BigNum.mt.tostring(LowestDigit))
	local HexString02 = string.format("%x", BigNum.mt.tostring(HighestDigit))
	
	HexString01 = string.sub(HexString01, 1, 2)
	HexString02 = string.sub(HexString02, 3, 8)

	local DereferenceString = HexString02 .. HexString01	
	return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new(tonumber("0x" .. DereferenceString))));
end

EMXHookLibrary.GetBuildingInformationStructure = function()
	if not EMXHookLibrary.IsHistoryEdition then 
		return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new("11198560")));
	end

	local Value = BigNum.new(Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAddressEntity, -78))
	local PointerValue = BigNum.new(EMXHookLibrary.GetValueAtPointer(Value))

	local LowestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, BigNum.new("2593"))))
	local HighestDigit = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(PointerValue, BigNum.new("2594"))))
	
	local HexString01 = string.format("%x", BigNum.mt.tostring(LowestDigit))
	local HexString02 = string.format("%x", BigNum.mt.tostring(HighestDigit))
	
	HexString01 = string.sub(HexString01, 1, 6)
	HexString02 = string.sub(HexString02, 7, 8)

	local DereferenceString = HexString02 .. HexString01	
	return BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.new(tonumber("0x" .. DereferenceString))));
end

EMXHookLibrary.IsAdressEntityExisting = function()
	return Logic.IsEntityAlive(EMXHookLibrary.GlobalAddressEntity);
end

EMXHookLibrary.FindOffsetValue = function(_VTableOffset, _PointerOffset)
	if EMXHookLibrary.GlobalAddressEntity ~= 0 and Logic.IsEntityAlive(EMXHookLibrary.GlobalAddressEntity) then
		Logic.DestroyEntity(EMXHookLibrary.GlobalAddressEntity)
	end
	if EMXHookLibrary.GlobalPointerEntity ~= 0 and Logic.IsEntityAlive(EMXHookLibrary.GlobalPointerEntity) then
		Logic.DestroyEntity(EMXHookLibrary.GlobalPointerEntity)
	end

	local posX, posY = 3000, 3000
	local AddressEntity = Logic.CreateEntity(Entities.D_X_TradeShip, posX, posY, 0, 0)
	local PointerEntity = Logic.CreateEntity(Entities.D_X_TradeShip, posX, posY, 0, 0)
	
	local VTablePointerValue = Logic.GetEntityScriptingValue(AddressEntity, _VTableOffset)	
	local PointerToVTableValue = BigNum.new(Logic.GetEntityScriptingValue(PointerEntity, _PointerOffset))
	
	Logic.SetVisible(AddressEntity, false)
	Logic.SetVisible(PointerEntity, false)
	
	EMXHookLibrary.GlobalAddressEntity = AddressEntity
	EMXHookLibrary.GlobalPointerEntity = PointerEntity
	EMXHookLibrary.GlobalHeapStart = PointerToVTableValue
	EMXHookLibrary.GlobalVTableValue = VTablePointerValue
end

EMXHookLibrary.InitAddressEntity = function()
	
	if (Network.IsNATReady == nil) then
		EMXHookLibrary.FindOffsetValue(-81, 36)
		EMXHookLibrary.IsHistoryEdition = false
	else
		EMXHookLibrary.FindOffsetValue(-78, 34)
		EMXHookLibrary.IsHistoryEdition = true
	end
	EMXHookLibrary.WasInitialized = true

end

EMXHookLibrary.GetValueAtPointer = function(_Pointer)
	if not EMXHookLibrary.IsAdressEntityExisting() then
		assert(false, "EMXHookLibrary: ERROR - AdressEntity is not existing!")
	end
	local PointerDifference = BigNum.mt.sub(_Pointer, EMXHookLibrary.GlobalHeapStart)
	local FinalIndex = BigNum.mt.div(PointerDifference, BigNum.new("4"))

	if (Network.IsNATReady == nil) then
		FinalIndex = BigNum.mt.add(BigNum.new("-81"), FinalIndex)
	else
		FinalIndex = BigNum.mt.add(BigNum.new("-78"), FinalIndex)
	end
	
	return Logic.GetEntityScriptingValue(EMXHookLibrary.GlobalAddressEntity, tonumber(BigNum.mt.tostring(FinalIndex)))
end

EMXHookLibrary.SetValueAtPointer = function(_Pointer, _Value)
	if not EMXHookLibrary.IsAdressEntityExisting() then
		assert(false, "EMXHookLibrary: ERROR - AdressEntity is not existing!")
	end
	local PointerDifference = BigNum.mt.sub(_Pointer, EMXHookLibrary.GlobalHeapStart)
	local FinalIndex = BigNum.mt.div(PointerDifference, BigNum.new("4"))

	if (Network.IsNATReady == nil) then
		FinalIndex = BigNum.mt.add(BigNum.new("-81"), FinalIndex)
	else
		FinalIndex = BigNum.mt.add(BigNum.new("-78"), FinalIndex)
	end
	
	Logic.SetEntityScriptingValue(EMXHookLibrary.GlobalAddressEntity, tonumber(BigNum.mt.tostring(FinalIndex)), _Value)
end

EMXHookLibrary.SetTerritoryGoldCostByIndex = function(_arrayIndex, _price)
	local HEValues = {"632", "636", "640", "644", "648"}
	local OVValues = {"688", "692", "696", "700", "704"}
	
	if not EMXHookLibrary.IsHistoryEdition then 
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), BigNum.new(OVValues[_arrayIndex])), _price)
	else
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), BigNum.new(HEValues[_arrayIndex])), _price)
	end
end

EMXHookLibrary.ModifyPlayerInformationStructure = function(_newValue, _vanillaValue, _heValue)
	if not EMXHookLibrary.IsHistoryEdition then 
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), BigNum.new(_vanillaValue)), _newValue)
	else
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), BigNum.new(_heValue)), _newValue)
	end
end

EMXHookLibrary.SetSettlerIllnessCount = function(_newCount) EMXHookLibrary.ModifyPlayerInformationStructure(_newCount, "760", "700") end
EMXHookLibrary.SetCarnivoreHealingSeconds = function(_newTime) EMXHookLibrary.ModifyPlayerInformationStructure(_newTime, "680", "624") end
EMXHookLibrary.SetKnightResurrectionTime = function(_newTime) EMXHookLibrary.ModifyPlayerInformationStructure(_newTime, "184", "164") end
EMXHookLibrary.SetMaxBuildingTaxAmount = function(_newTaxAmount) EMXHookLibrary.ModifyPlayerInformationStructure(_newTaxAmount, "624", "580") end
EMXHookLibrary.SetAmountOfTaxCollectors = function(_newAmount) EMXHookLibrary.ModifyPlayerInformationStructure(_newAmount, "808", "744") end
EMXHookLibrary.SetFogOfWarVisibilityFactor = function(_newFactor) EMXHookLibrary.ModifyPlayerInformationStructure(EMXHookLibrary.HelperFunctions.Float2Int(_newFactor), "620", "576") end
EMXHookLibrary.SetBuildingKnockDownCompensation = function(_percent) EMXHookLibrary.ModifyPlayerInformationStructure(_percent, "4", "4") end
--EMXHookLibrary.SetTrailSpeedModifier = function(_newFactor) EMXHookLibrary.ModifyPlayerInformationStructure(EMXHookLibrary.HelperFunctions.Float2Int(_newFactor), "496", "464") end
--EMXHookLibrary.SetRoadSpeedModifier = function(_newFactor) EMXHookLibrary.ModifyPlayerInformationStructure(EMXHookLibrary.HelperFunctions.Float2Int(_newFactor), "320", "300") end
--EMXHookLibrary.SetWaterDepthBlockingThreshold = function(_threshold) EMXHookLibrary.ModifyPlayerInformationStructure(_threshold, "456", "424") end
EMXHookLibrary.SetTerritoryCombatBonus = function(_newFactor) EMXHookLibrary.ModifyPlayerInformationStructure(EMXHookLibrary.HelperFunctions.Float2Int(_newFactor), "604", "560") end
EMXHookLibrary.SetCathedralCollectAmount = function(_newAmount) EMXHookLibrary.ModifyPlayerInformationStructure(_newAmount, "436", "404") end
EMXHookLibrary.SetFireHealthDecreasePerSecond = function(_newAmount) EMXHookLibrary.ModifyPlayerInformationStructure(_newAmount, "260", "240") end

EMXHookLibrary.SetSettlerLimit = function(_cathedralIndex, _limit)	
	if not EMXHookLibrary.IsHistoryEdition then
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), BigNum.new("408"))))			
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_cathedralIndex), BigNum.new("4"))), _limit)
	else
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetPlayerInformationStructure(), BigNum.new("376"))))			
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_cathedralIndex), BigNum.new("4"))), _limit)
	end
end

EMXHookLibrary.SetSermonSettlerLimit = function(_playerID, _cathedralLevel, _limit)	
	if not EMXHookLibrary.IsHistoryEdition then
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(Logic.GetCathedral(_playerID)), BigNum.new("128"))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("756"))))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_cathedralLevel), BigNum.new("4"))), _limit)
	else
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(Logic.GetCathedral(_playerID)), BigNum.new("128"))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("680"))))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_cathedralLevel), BigNum.new("4"))), _limit)
	end
end

EMXHookLibrary.SetSoldierLimit = function(_playerID, _castleLevel, _limit)	
	if not EMXHookLibrary.IsHistoryEdition then
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(Logic.GetHeadquarters(_playerID)), BigNum.new("128"))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("788"))))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_castleLevel), BigNum.new("4"))), _limit)
	else
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(Logic.GetHeadquarters(_playerID)), BigNum.new("128"))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("704"))))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_castleLevel), BigNum.new("4"))), _limit)
	end
end

EMXHookLibrary.SetOutStockCapacitiesLimit = function(_entityID, _upgradeLevel, _limit)	
	if not EMXHookLibrary.IsHistoryEdition then
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_entityID), BigNum.new("128"))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("676"))))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_upgradeLevel), BigNum.new("4"))), _limit)
	else
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.CalculateEntityIDToObject(_entityID), BigNum.new("128"))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("612"))))
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_upgradeLevel), BigNum.new("4"))), _limit)
	end
end

EMXHookLibrary.SetBuildingFullCost = function(_entityType, _good, _amount, _secondGood, _secondAmount)	
	if not EMXHookLibrary.IsHistoryEdition then
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetBuildingInformationStructure(), BigNum.new("28"))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_entityType), BigNum.new("4")))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("144"))))
		
		EMXHookLibrary.SetValueAtPointer(LimitPointer, _good)
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("4")), _amount)
		
		if _secondGood ~= nil and _secondAmount ~= nil then
			EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("8")), _secondGood)
			EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("12")), _secondAmount)
		end
		
	else
		local LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(EMXHookLibrary.GetBuildingInformationStructure(), BigNum.new("24"))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.mt.mul(BigNum.new(_entityType), BigNum.new("4")))))
		LimitPointer = BigNum.new(EMXHookLibrary.GetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("136"))))
		
		EMXHookLibrary.SetValueAtPointer(LimitPointer, _good)
		EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("4")), _amount)
		
		if _secondGood ~= nil and _secondAmount ~= nil then
			EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("8")), _secondGood)
			EMXHookLibrary.SetValueAtPointer(BigNum.mt.add(LimitPointer, BigNum.new("12")), _secondAmount)
		end
		
	end
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
--#EOF
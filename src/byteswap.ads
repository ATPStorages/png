generic 
      type Modular_Type is mod <>;
package ByteSwap is
   procedure SwapBytes   (M : in out Modular_Type);
   procedure SwapBytesBE (M : in out Modular_Type);
   --  function SwapBytesLE (M : Modular_Type) return Modular_Type;
end ByteSwap;

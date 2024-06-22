with Ada.Text_IO;
with System; use System;

package body ByteSwap is

   procedure SwapBytes (M : in out Modular_Type) is
   begin
      Ada.Text_IO.Put_Line (M'Size'Image);
   end SwapBytes;
   
   procedure SwapBytesBE (M : in out Modular_Type) is
   begin
      if Default_Bit_Order = Low_Order_First then
         SwapBytes (M);
      end if;
   end SwapBytesBE;

end ByteSwap;

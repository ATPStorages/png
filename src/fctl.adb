with Ada.Containers; use Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;

package body fcTL is

   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector; F : Ada.Streams.Stream_IO.File_Type) is
   begin
      --  if C.ChunkSize /= 13 then
      --     raise PNG.BAD_CHUNK_SIZE_ERROR with "IHDR size of (" & C.ChunkSize'Image & " ) bytes incorrect, should be 13";
      --  elsif V.Length > 0 then
      --     raise PNG.DUPLICATE_CHUNK_ERROR with "A valid PNG stream must contain only 1 IHDR chunk";
      --  end if;
      
      Chunk_Data_Info'Read (S, Self);
      
      if Self.DisposalOperation = APNG_DISPOSE_OP_UNKNOWN then
         raise INVALID_OPERATION_ERROR with "DisposalOperation (dispose_op) of " & Self.DisposalOperation'Enum_Rep'Image & " is outside specification bounds";
      elsif Self.BlendOperation = APNG_BLEND_OP_UNKNOWN then
         raise INVALID_OPERATION_ERROR with "BlendOperation (blend_op) of " & Self.BlendOperation'Enum_Rep'Image & " is outside specification bounds";
      end if;

      PNG.Unsigned_31_ByteFlipper.FlipBytesBE (Self.FramePosition);
      PNG.Unsigned_31_ByteFlipper.FlipBytesBE (Self.FrameWidth);
      PNG.Unsigned_31_ByteFlipper.FlipBytesBE (Self.FrameHeight);
      PNG.Unsigned_31_ByteFlipper.FlipBytesBE (Self.FrameOffsetX);
      PNG.Unsigned_31_ByteFlipper.FlipBytesBE (Self.FrameOffsetY);
      PNG.Unsigned_16_ByteFlipper.FlipBytesBE (Self.DelayNumerator);
      PNG.Unsigned_16_ByteFlipper.FlipBytesBE (Self.DelayDenominator);

      Put_Line ("      fcTL Frame Position    : " & Self.FramePosition'Image);
      Put_Line ("      fcTL Frame Width       : " & Self.FrameWidth'Image);
      Put_Line ("      fcTL Frame Height      : " & Self.FrameHeight'Image);
      Put_Line ("      fcTL Frame Offset X    : " & Self.FrameOffsetX'Image);
      Put_Line ("      fcTL Frame Offset Y    : " & Self.FrameOffsetY'Image);
      Put_Line ("      fcTL Frame Delay N     : " & Self.DelayNumerator'Image);
      Put_Line ("      fcTL Frame Delay D     : " & Self.DelayDenominator'Image);
      Put_Line ("      fcTL Frame Disposal Op : " & Self.DisposalOperation'Image);
      Put_Line ("      fcTL Frame Blend    Op : " & Self.BlendOperation'Image);
   end Decode;

end fcTL;

with Ada.Containers; use Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;
package body IHDR is

   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector) is
   begin
      if C.ChunkSize /= 13 then
         raise PNG.BAD_CHUNK_SIZE_ERROR with "IHDR size of (" & C.ChunkSize'Image & " ) bytes incorrect, should be 13";
      elsif V.Length > 0 then
         raise PNG.DUPLICATE_CHUNK_ERROR with "A valid PNG stream must contain only 1 IHDR chunk";
      end if;

      Chunk_Data_Info'Read (S, Self);

      PNG.Unsigned_32_ByteFlipper.FlipBytesBE (Self.Width);
      PNG.Unsigned_32_ByteFlipper.FlipBytesBE (Self.Height);

      Put_Line ("      IHDR Width             :" & Self.Width'Image);
      Put_Line ("      IHDR Height            :" & Self.Height'Image);
      Put_Line ("      IHDR Bit Depth         :" & Self.BitDepth'Image);
      Put_Line ("      IHDR Color Type        :" & Self.ColorType'Image);
      Put_Line ("      IHDR Compression Method:" & Self.CompressionMethod'Image);
      Put_Line ("      IHDR Filter Method     :" & Self.FilterMethod'Image);
      Put_Line ("      IHDR Interlace Method  :" & Self.InterlaceMethod'Image);
   end Decode;

end IHDR;

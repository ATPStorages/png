with Ada.Containers; use Ada.Containers;
with Ada.Text_IO;
with PNG; use PNG;

package body IHDR is

   overriding procedure Decode (Self : in out Data_Definition;
                                S : Stream_Access;
                                C : in out PNG.Chunk;
                                V : PNG.Chunk_Vectors.Vector;
                                F : File_Type)
   is
      Unsigned_32_Buffer : Unsigned_32;
   begin
      if PNG.Chunk_Count (V, TypeRaw) > 0 then
         declare
            Duplicate_Error : PNG.Decoder_Error (PNG.DUPLICATE_CHUNK);
         begin
            C.Data.Errors.Append (Duplicate_Error);
         end;
      end if;

      --  Reading Data_Definition will cause invalid data to be read into
      --  Height/Width for little endian systems (Unsigned_32s bad for 31s!)

      Unsigned_32'Read (S, Unsigned_32_Buffer);
      PNG.Unsigned_32_ByteFlipper.FlipBytesBE (Unsigned_32_Buffer);
      Self.Width := PNG.Unsigned_31 (Unsigned_32_Buffer);

      Unsigned_32'Read (S, Unsigned_32_Buffer);
      PNG.Unsigned_32_ByteFlipper.FlipBytesBE (Unsigned_32_Buffer);
      Self.Height := PNG.Unsigned_31 (Unsigned_32_Buffer);

      Unsigned_8'Read (S, Self.BitDepth);
      Color_Type'Read (S, Self.ColorType);
      PNG.Compression_Method'Read (S, Self.CompressionMethod);
      Unsigned_8'Read (S, Self.FilterMethod);
      Unsigned_8'Read (S, Self.InterlaceMethod);
   end Decode;

end IHDR;

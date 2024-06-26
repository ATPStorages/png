with Ada.Text_IO; use Ada.Text_IO;
with System; use System;

package body PNG is
   function PNG_Chunk_Hash (Chunk : PNG_Chunk) return Hash_Type
   is
   begin
      return Hash_Type (Chunk.CRC32);
   end PNG_Chunk_Hash;

   function PNG_Chunk_Equal_Element (A, B : PNG_Chunk) return Boolean
   is
   begin
      return A.CRC32 = B.CRC32;
   end PNG_Chunk_Equal_Element;

   --== File Operations ==--

   --  There's a problem with the first 4 bytes of the PNG stream; they don't line up with PNG.Signature.
   BAD_SIGNATURE_ERROR : exception;

   --  There's a second chunk where only one chunk of a certain type may exist.
   DUPLICATE_CHUNK_ERROR : exception;

   --  There's a problem with the structure of the PNG stream (i.e. no IHDR at the start, no IEND at the end)
   BAD_STRUCTURE_ERROR : exception;

   --  There's a chunk with a wrong size where it is defined in the specification.
   BAD_CHUNK_SIZE_ERROR : exception;

   --  There's an unrecognized non-ancillary chunk which cannot be skipped over
   UNRECOGNIZED_CRITICAL_CHUNK_ERROR : exception;

   --  There's a chunk with the "Reserved" bit set, which isn't possible in the PNG specification this library was written for.
   RESERVED_CHUNK_ERROR : exception;

   function CheckBit5 (N : Unsigned_8) return Boolean
   is
   begin
      return (Shift_Right (N, 2) and 1) = 1;
   end CheckBit5;

   function Read (F : Ada.Streams.Stream_IO.File_Type; S : Stream_Access) return PNG_File
   is
      Stream_Signature : Unsigned_64;
      Stream_Ended     : Boolean := False;

      Chunk_Type                    : PNG_Chunk_Type;
      Chunk_Type_Info               : PNG_Chunk_Type_Info;
      Chunk_Size                    : Unsigned_32;

      Constructed_Chunk_Set : PNG_Chunk_Sets.Set;
      Constructed_PNG_File  : constant PNG_File :=
        (Chunks => Constructed_Chunk_Set);
   begin
      Unsigned_64'Read (S, Stream_Signature);
      Unsigned_64_ByteFlipper.FlipBytesBE (Stream_Signature);
      if Stream_Signature /= Signature then raise BAD_SIGNATURE_ERROR; end if;

      while True loop
         if Stream_Ended and (not End_Of_File (F)) then
            raise BAD_STRUCTURE_ERROR with "IEND must appear at the very end of a PNG stream"; end if;

         Put_Line ("Starting this chunk @ index" & Index (F)'Image);
         PNG_Chunk_Type'Read (S, Chunk_Size);
         PNG_Chunk_Type'Read (S, Chunk_Type);

         Unsigned_32_ByteFlipper.FlipBytesBE (Chunk_Size);
         Unsigned_32_ByteFlipper.FlipBytesBE (Chunk_Type);

         if CheckBit5(Unsigned_8 (Shift_Right (Chunk_Type, 16) mod 2 ** 8)) then
            raise RESERVED_CHUNK_ERROR with "Encountered a chunk type with the Reserved bit set to True @ byte" & Index (F)'Image; end if;

         Chunk_Type_Info := (Raw => Chunk_Type,
                             Ancillary => CheckBit5(Unsigned_8 (Chunk_Type rem 2 ** 8)),
                             Specification => CheckBit5(Unsigned_8 (Shift_Right (Chunk_Type, 8) rem 2 ** 8)),
                             Reserved => False,
                             SafeToCopy => CheckBit5(Unsigned_8 (Shift_Right (Chunk_Type, 24) rem 2 ** 8)));

         Put_Line (Chunk_Type'Image);
         Put_Line (Chunk_Size'Image);
         declare
            Index_Before_Array_Read            : Ada.Streams.Stream_IO.Positive_Count := Index (F);
            Computed_CRC32                     : Unsigned_32;
            Constructed_Chunk                  : PNG_Chunk (Chunk_Size);
            Constructed_Chunk_Data_Info_Access : PNG_Chunk_Data_Info_Access;
         begin
            PNG_Chunk_Data_Array'Read (S, Constructed_Chunk.Data.Raw);
            -- TODO...
            case Chunk_Type is
            when 16#49484452# => --  IHDR
               Set_Index (F, Index_Before_Array_Read);
               if Chunk_Size /= 13 then
                  raise BAD_CHUNK_SIZE_ERROR with "IHDR size of (" & Chunk_Size'Image & " ) bytes incorrect, should be 13";
               elsif Constructed_Chunk_Set.Length > 0 then
                  raise DUPLICATE_CHUNK_ERROR with "A valid PNG stream must contain only 1 IHDR chunk";
               end if;

               Constructed_Chunk_Data_Info_Access := new IHDR_Chunk_Data_Info;
               IHDR_Chunk_Data_Info'Read (S, IHDR_Chunk_Data_Info_Access (Constructed_Chunk_Data_Info_Access).all);
               Constructed_Chunk.Data.Info := Constructed_Chunk_Data_Info_Access;

               Put_Line ("IHDR Width: " & IHDR_Chunk_Data_Info_Access (Constructed_Chunk_Data_Info_Access).Width'Image);
               Put_Line ("IHDR Height: " & IHDR_Chunk_Data_Info_Access (Constructed_Chunk_Data_Info_Access).Height'Image);
               Put_Line ("IHDR Bit Depth: " & IHDR_Chunk_Data_Info_Access (Constructed_Chunk_Data_Info_Access).BitDepth'Image);
               Put_Line ("IHDR Color Type: " & IHDR_Chunk_Data_Info_Access (Constructed_Chunk_Data_Info_Access).ColorType'Image);
               Put_Line ("IHDR Compression Method: " & IHDR_Chunk_Data_Info_Access (Constructed_Chunk_Data_Info_Access).CompressionMethod'Image);
               Put_Line ("IHDR Filter Method: " & IHDR_Chunk_Data_Info_Access (Constructed_Chunk_Data_Info_Access).FilterMethod'Image);
               Put_Line ("IHDR Interlace Method: " & IHDR_Chunk_Data_Info_Access (Constructed_Chunk_Data_Info_Access).InterlaceMethod'Image);

            when others =>
               if Constructed_Chunk_Set.Length = 0 then
                  raise BAD_STRUCTURE_ERROR with "A valid PNG stream must contain the IHDR chunk first"; end if;
               --  TODO: Check if chunks are after IEND, raise BAD_STRUCTURE_ERROR

               case Chunk_Type is
                  when 16#49454E44# => --  IEND
                     Stream_Ended := True;
                  when others =>
                     Put_Line (Chunk_Type'Image);
                     null;
               end case;
            end case;

            Unsigned_32'Read (S, Constructed_Chunk.CRC32);
            Unsigned_32_ByteFlipper.FlipBytesBE (Constructed_Chunk.CRC32);

            Put_Line ("CRC32 looks like " & Constructed_Chunk.CRC32'Image);
            Put_Line (Chunk_Type'Image & " OK");

            Constructed_Chunk_Set.Insert (Constructed_Chunk);
            Put_Line ("Done reading this chunk @ index" & Index (F)'Image);
         end;
      end loop;

      return Constructed_PNG_File;
   end Read;

   procedure Write (F : PNG_File; S : Stream_Access)
   is
      pragma Unreferenced (F);
   begin
      Unsigned_64'Output (S, Signature);
      null;
   end Write;
end PNG;

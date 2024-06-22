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
   --  There's a problem with the structure of the PNG stream (i.e. no IHDR at the start, no IEND)
   BAD_STRUCTURE_ERROR : exception;
   --  There's an unrecognized chunk which cannot be skipped over (critical, not ancillary)
   UNRECOGNIZED_CRITICAL_CHUNK_ERROR : exception;
   --  There's a chunk with the "Reserved" bit set, which isn't possible in the PNG specification this library was written for.
   RESERVED_CHUNK_ERROR : exception;

   function CheckBit5 (N : Unsigned_8) return Boolean
   is
   begin
      Put_Line (N'Image);
      return (Shift_Right (N, 4) and 1) = 1;
   end CheckBit5;

   function Read (S : Stream_Access) return PNG_File
   is
      Stream_Signature : Unsigned_64;

      Stream_Type      : PNG_Chunk_Type;
      Stream_Type_Info : PNG_Chunk_Type_Info;
      Stream_Size      : Unsigned_32;

      Constructed_Chunk_Set : PNG_Chunk_Sets.Set;
      Constructed_PNG_File  : constant PNG_File :=
        (Chunks => Constructed_Chunk_Set);
   begin
      Unsigned_64'Read (S, Stream_Signature);
      Unsigned_64_ByteFlipper.FlipBytesBE (Stream_Signature);
      if Stream_Signature /= Signature then raise BAD_SIGNATURE_ERROR; end if;

      while True loop
         PNG_Chunk_Type'Read (S, Stream_Size);
         PNG_Chunk_Type'Read (S, Stream_Type);

         Unsigned_32_ByteFlipper.FlipBytesBE (Stream_Size);
         Unsigned_32_ByteFlipper.FlipBytesBE (Stream_Type);

         if CheckBit5(Unsigned_8 (Shift_Right (Stream_Type, 16) mod 2 ** 8)) then raise RESERVED_CHUNK_ERROR; end if;

         Stream_Type_Info := (Raw => Stream_Type,
                              Ancillary => CheckBit5(Unsigned_8 (Stream_Type rem 2 ** 8)),
                              Specification => CheckBit5(Unsigned_8 (Shift_Right (Stream_Type, 8) rem 2 ** 8)),
                              Reserved => False,
                              SafeToCopy => CheckBit5(Unsigned_8 (Shift_Right (Stream_Type, 24) rem 2 ** 8)));

         case Stream_Type is
            -- IHDR
            when 16#49484452# =>
               Put_Line (Stream_Type_Info.Ancillary'Image);
               Put_Line (Stream_Type_Info.Specification'Image);
               Put_Line (Stream_Type_Info.SafeToCopy'Image);
               Put_Line (Stream_Type_Info.Raw'Image);
            when others =>
               Put_Line (":<");
         end case;
      end loop;

      return Constructed_PNG_File;
   end Read;

   procedure Write (S : Stream_Access; F : PNG_File)
   is
      pragma Unreferenced (F);
   begin
      Unsigned_64'Output (S, Signature);
      null;
   end Write;
end PNG;

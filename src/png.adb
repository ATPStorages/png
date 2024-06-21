with Ada.Text_IO;

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

   --  There's an issue with the first 4 bytes of the PNG stream; they don't line up with PNG.Signature.
   BAD_SIGNATURE_ERROR   : exception;
   --  There's a second chunk where only one chunk of a certain type may exist.
   DUPLICATE_CHUNK_ERROR : exception;
   --  There's a problem with the structure of the PNG stream (i.e. no IHDR at the start, no IEND)
   BAD_STRUCTURE_ERROR   : exception;

   function Read (S : Stream_Access) return PNG_File
   is
      Stream_Signature : Unsigned_64;

      Stream_Type : PNG_Chunk_Type;
      Stream_Size : Unsigned_32;

      Constructed_Chunk_Set : PNG_Chunk_Sets.Set;
      Constructed_PNG_File  : constant PNG_File :=
        (Chunks => Constructed_Chunk_Set);
   begin
      Unsigned_64'Read (S, Stream_Signature);
      if Stream_Signature /= Signature then raise BAD_SIGNATURE_ERROR; end if;
      while True loop
         PNG_Chunk_Type'Read (S, Stream_Type);
         PNG_Chunk_Type'Read (S, Stream_Size);

         -- NOTE: This is actually Size -> Type. Also, flip the endian when you wake up.
         -- meowwwwwwwwwwww
         Ada.Text_IO.Put_Line ("Type :" & Stream_Type'Image);
         Ada.Text_IO.Put_Line ("Size :" & Stream_Size'Image);
         while True loop null; end loop;
         null;
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

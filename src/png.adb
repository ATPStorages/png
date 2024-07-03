with Ada.Characters.Latin_1;
with Ada.Text_IO;
with System; use System;
with IHDR;
with PLTE;
with IDAT;
with tIME;
with iCCP;
with bKGD;
with pHYs;
with iTXt;
with tEXt;
with eXIf;
with acTL;
with fcTL;
with fdAT;

package body PNG is
   function Chunk_Hash (C : Chunk) return Hash_Type
   is
   begin
      return Hash_Type (C.CRC32);
   end Chunk_Hash;

   function Chunk_Equal_Element (A, B : Chunk) return Boolean
   is
   begin
      return A.CRC32 = B.CRC32;
   end Chunk_Equal_Element;

   --== File Operations ==--

   function Decode_Null_String (S : Stream_Access) return Unbounded_String is
      New_String     : Unbounded_String;
      Read_Character : Character;
   begin
      while True loop
         Character'Read (S, Read_Character);

         if Read_Character = Ada.Characters.Latin_1.NUL then
            exit;
         else
            Append (New_String, Read_Character);
         end if;
      end loop;

      return New_String;
   end Decode_Null_String;

   function CheckBit5 (N : Unsigned_8) return Boolean
   is
   begin
      return (N and (2 ** 5)) > 0;
   end CheckBit5;

   procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : Chunk; V : Chunk_Vectors.Vector; F : File_Type) is
      discard : Chunk_Data_Array (1 .. C.Length);
   begin
      Ada.Text_IO.Put_Line ("Decode, unknown");
      Ada.Text_IO.Put_Line ("      - Type:" & C.TypeInfo.Raw'Image);
      Ada.Text_IO.Put_Line ("      - Size:" & C.Length'Image);
      Chunk_Data_Array'Read (S, discard);
   end Decode;

   function Read (F : File_Type; S : Stream_Access) return File
   is
      Stream_Signature : Unsigned_64;
      Stream_Ended     : Boolean := False;

      Chnk_Length : Unsigned_31;

      Constructed_Chunks   : Chunk_Vectors.Vector;
      Constructed_PNG_File : constant File :=
        (Chunks => Constructed_Chunks);
   begin
      Unsigned_64'Read (S, Stream_Signature);
      Unsigned_64_ByteFlipper.FlipBytesBE (Stream_Signature);
      if Stream_Signature /= Signature then raise BAD_SIGNATURE_ERROR; end if;

      while True loop
         if Stream_Ended then
            if End_Of_File (F) then exit;
            else raise BAD_STRUCTURE_ERROR with "IEND must appear at the very end of a PNG stream";
            end if;
         end if;

         Unsigned_31'Read (S, Chnk_Length);
         Unsigned_31_ByteFlipper.FlipBytesBE (Chnk_Length);

         declare
            Computed_CRC32          : Unsigned_32;
            Constructed_Chunk       : Chunk (Chnk_Length);
         begin
            Chunk_Type'Read (S, Constructed_Chunk.TypeInfo.Raw);
            Unsigned_32_ByteFlipper.FlipBytesBE (Constructed_Chunk.TypeInfo.Raw);

            Constructed_Chunk.TypeInfo.Ancillary     := CheckBit5(Unsigned_8 (Shift_Right (Constructed_Chunk.TypeInfo.Raw, 24) rem 2 ** 8));
            Constructed_Chunk.TypeInfo.Specification := CheckBit5(Unsigned_8 (Shift_Right (Constructed_Chunk.TypeInfo.Raw, 16) rem 2 ** 8));
            Constructed_Chunk.TypeInfo.Reserved      := CheckBit5(Unsigned_8 (Shift_Right (Constructed_Chunk.TypeInfo.Raw, 8 ) rem 2 ** 8));
            Constructed_Chunk.TypeInfo.SafeToCopy    := CheckBit5(Unsigned_8              (Constructed_Chunk.TypeInfo.Raw      rem 2 ** 8));

            case Constructed_Chunk.TypeInfo.Raw is
               when 16#49484452# =>
                  Constructed_Chunk.Data.Info := new IHDR.Chunk_Data_Info;
               when 16#504C5445# =>
                  Constructed_Chunk.Data.Info := new PLTE.Chunk_Data_Info (Chnk_Length, Chnk_Length / 3);
               when 16#49444154# =>
                  Constructed_Chunk.Data.Info := new IDAT.Chunk_Data_Info (Chnk_Length);
               when 16#49454E44# =>
                  Stream_Ended := True;
                  goto NoDecode;

               when 16#74494D45# =>
                  Constructed_Chunk.Data.Info := new tIME.Chunk_Data_Info;
               when 16#69434350# =>
                  Constructed_Chunk.Data.Info := new iCCP.Chunk_Data_Info;

               when 16#624B4744# =>
                  Constructed_Chunk.Data.Info := new bKGD.Chunk_Data_Info;
               when 16#70485973# =>
                  Constructed_Chunk.Data.Info := new pHYs.Chunk_Data_Info;
               when 16#69545874# =>
                  Constructed_Chunk.Data.Info := new iTXt.Chunk_Data_Info;
               when 16#74455874# =>
                  Constructed_Chunk.Data.Info := new tEXt.Chunk_Data_Info;
               when 16#65584966# =>
                  Constructed_Chunk.Data.Info := new eXIf.Chunk_Data_Info;

               when 16#6163544C# => --  APNG related chunks
                  Constructed_Chunk.Data.Info := new acTL.Chunk_Data_Info;
               when 16#6663544C# =>
                  Constructed_Chunk.Data.Info := new fcTL.Chunk_Data_Info;
               when 16#66644154# =>
                  Constructed_Chunk.Data.Info := new fdAT.Chunk_Data_Info (Chnk_Length - (Unsigned_31'Size / 8));

               when others =>
                  if Constructed_Chunks.Length = 0 then
                     raise BAD_STRUCTURE_ERROR with "A valid PNG stream must contain the IHDR chunk first"; end if;
                  if not Constructed_Chunk.TypeInfo.Ancillary then
                     raise UNRECOGNIZED_CRITICAL_CHUNK_ERROR; end if;

                  Constructed_Chunk.Data.Info := new Chunk_Data_Info;
            end case;

            Decode (Constructed_Chunk.Data.Info.all, S, Constructed_Chunk, Constructed_Chunks, F);
            <<NoDecode>>

            Unsigned_32'Read (S, Constructed_Chunk.CRC32);
            Unsigned_32_ByteFlipper.FlipBytesBE (Constructed_Chunk.CRC32);

            Constructed_Chunks.Append (Constructed_Chunk);
         end;
      end loop;

      return Constructed_PNG_File;
   end Read;

   procedure Write (F : File; S : Stream_Access)
   is
      pragma Unreferenced (F);
   begin
      Unsigned_64'Output (S, Signature);
      null;
   end Write;
end PNG;

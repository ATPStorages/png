with Ada.Containers; use Ada.Containers;
with Ada.Text_IO;

package body eXIf is

   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector; F : Ada.Streams.Stream_IO.File_Type) is
      ForBigEndian     : Boolean;
      Unsigned16Buffer : Unsigned_16;
      Unsigned32Buffer : Unsigned_32;
      DataStart        : Positive_Count := Index (F);
   begin
      --  if C.ChunkSize /= 13 then
      --     raise PNG.BAD_CHUNK_SIZE_ERROR with "IHDR size of (" & C.ChunkSize'Image & " ) bytes incorrect, should be 13";
      --  elsif V.Length > 0 then
      --     raise PNG.DUPLICATE_CHUNK_ERROR with "A valid PNG stream must contain only 1 IHDR chunk";
      --  end if;
      
      --  Reading endianness
      Unsigned_16'Read (S, Unsigned16Buffer);
      ForBigEndian := Unsigned16Buffer = 16#4D4D#;
      --  TIFF Marker (0x002A for EXIF)
      Unsigned_16'Read (S, Unsigned16Buffer);
      --  First IFD Pointer
      Unsigned_32'Read (S, Unsigned32Buffer);
      PNG.Unsigned_32_ByteFlipper.FlipBytesCHK (Unsigned32Buffer, ForBigEndian);
      Set_Index (F, DataStart + Positive_Count (Unsigned32Buffer));
      
      while True loop
         Unsigned_16'Read (S, Unsigned16Buffer);
         PNG.Unsigned_16_ByteFlipper.FlipBytesCHK (Unsigned16Buffer, ForBigEndian);
         
         declare
            NewImageFileDirectory : ImageFileDirectory (Unsigned16Buffer);
            EnumerationValue      : Unsigned_32;
         begin
            for TagIndex in NewImageFileDirectory.Tags'Range loop
               Tag'Read (S, NewImageFileDirectory.Tags (TagIndex));
               PNG.Unsigned_16_ByteFlipper.FlipBytesCHK (NewImageFileDirectory.Tags (TagIndex).ID, ForBigEndian);
               Ada.Text_IO.Put_Line ("      eXIf Tag ID : " & NewImageFileDirectory.Tags (TagIndex).ID'Image);
               
               --  EnumerationValue := NewImageFileDirectory.Tags (TagIndex).DataType'Enum_Rep;
               --  PNG.Unsigned_32_ByteFlipper.FlipBytesCHK (EnumerationValue, ForBigEndian);
               --  NewImageFileDirectory.Tags (TagIndex).DataType := TagDataTypes'Val (EnumerationValue);
               
               PNG.Unsigned_32_ByteFlipper.FlipBytesCHK (NewImageFileDirectory.Tags (TagIndex).ValueCount, ForBigEndian);
               PNG.Unsigned_32_ByteFlipper.FlipBytesCHK (NewImageFileDirectory.Tags (TagIndex).ValueOrPointer, ForBigEndian);
            end loop;
            Self.ImageFileDirectories.Append (NewImageFileDirectory);
         end;
         
         Unsigned_32'Read (S, Unsigned32Buffer);
         PNG.Unsigned_32_ByteFlipper.FlipBytesCHK (Unsigned32Buffer, ForBigEndian);
         
         if Unsigned32Buffer > 0 then
            Set_Index (F, DataStart + Positive_Count (Unsigned32Buffer));
         else exit; end if;
      end loop;
   end Decode;

end eXIf;

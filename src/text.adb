with Ada.Containers; use Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Characters.Latin_1;
with PNG; use PNG;

package body tEXt is

   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector) is
      ReadCharacter : Character;
      ReadingText   : Boolean := False;
      Position      : Unsigned_31 := 0;
   begin
      --  if C.ChunkSize /= 13 then
      --     raise PNG.BAD_CHUNK_SIZE_ERROR with "IHDR size of (" & C.ChunkSize'Image & " ) bytes incorrect, should be 13";
      --  elsif V.Length > 0 then
      --     raise PNG.DUPLICATE_CHUNK_ERROR with "A valid PNG stream must contain only 1 IHDR chunk";
      --  end if;
      
      while Position < C.Length loop
         Character'Read (S, ReadCharacter);
         Position := Position + 1;
         
         if ReadCharacter = Ada.Characters.Latin_1.NUL then
            ReadingText := True;
         else
            if ReadingText then Append (Self.Text, ReadCharacter);
            else Append (Self.Keyword, ReadCharacter);
            end if;
         end if;
      end loop;

      Put_Line ("      tEXt Keyword : " & To_String (Self.Keyword));
      Put_Line ("      tEXt String  : " & To_String (Self.Text));
   end Decode;

end tEXt;

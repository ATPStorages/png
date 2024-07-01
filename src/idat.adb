with Ada.Containers; use Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;

package body IDAT is

   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector; F : Ada.Streams.Stream_IO.File_Type) is
   begin
      --  if C.ChunkSize /= 13 then
      --     raise PNG.BAD_CHUNK_SIZE_ERROR with "IHDR size of (" & C.ChunkSize'Image & " ) bytes incorrect, should be 13";
      --  elsif V.Length > 0 then
      --     raise PNG.DUPLICATE_CHUNK_ERROR with "A valid PNG stream must contain only 1 IHDR chunk";
      --  end if;
      
      Chunk_Data_Info'Read (S, Self);
      
      Put_Line ("      IDAT Image Data Size :" & Self.FrameData'Size'Image);
   end Decode;

end IDAT;

with Ada.Text_IO;
package body PLTE is

   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector) is
   begin
      Ada.Text_IO.Put_Line ("Decode, PLTE");
   end Decode;

end PLTE;

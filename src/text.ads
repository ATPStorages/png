with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;
with PNG;

package tEXt is
   
   type Chunk_Data_Info is new PNG.Chunk_Data_Info with record
      Keyword : Unbounded_String;
      Text    : Unbounded_String;
   end record;
   
   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector; F : File_Type);

end tEXt;

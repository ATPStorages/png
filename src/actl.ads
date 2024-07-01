with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;
with PNG;

package acTL is
   
   type Chunk_Data_Info is new PNG.Chunk_Data_Info with record
      FrameCount  : PNG.Unsigned_31;
      RepeatCount : PNG.Unsigned_31;
   end record;
   
   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector; F : Ada.Streams.Stream_IO.File_Type);

end acTL;

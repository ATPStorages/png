with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;
with PNG;

package fdAT is
   
   type Chunk_Data_Info (DataLength: PNG.Unsigned_31) is new PNG.Chunk_Data_Info with record
      FramePosition : PNG.Unsigned_31;
      FrameData     : PNG.Chunk_Data_Array (1 .. DataLength);
   end record;
   
   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector);

end fdAT;

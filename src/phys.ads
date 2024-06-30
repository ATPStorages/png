with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;
with PNG;

package pHYs is

   type UnitTypes is (UNKNOWN, METER)
     with Size => 8;
   for UnitTypes use (UNKNOWN => 0, METER => 1);
   
   type Chunk_Data_Info is new PNG.Chunk_Data_Info with record
      PixelsPerHorizontalUnit : PNG.Unsigned_31;
      PixelsPerVerticalUnit   : PNG.Unsigned_31;
      Unit                    : UnitTypes;
   end record;
   
   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector);

end pHYs;

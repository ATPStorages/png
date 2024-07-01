with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;
with PNG;

package IHDR is
   
   type Chunk_Data_Info is new PNG.Chunk_Data_Info with record
      Width             : PNG.Unsigned_31_Positive;
      --  Width of the image.
      Height            : PNG.Unsigned_31_Positive;
      --  Height of the image.
      BitDepth          : Unsigned_8;
      --  Bit depth of the pixels within this image.
      ColorType         : Unsigned_8;
      CompressionMethod : Unsigned_8 range 0 .. 0;
      FilterMethod      : Unsigned_8 range 0 .. 0;
      InterlaceMethod   : Unsigned_8 range 0 .. 1;
   end record;

   type Chunk_Data_Info_Access is access all Chunk_Data_Info;
   
   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector; F : Ada.Streams.Stream_IO.File_Type);

end IHDR;

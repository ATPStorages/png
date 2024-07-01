with Ada.Containers.Vectors;
with Ada.Containers.Indefinite_Vectors;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;
with PNG;

package eXIf is
   
   type TagDataTypes is (UNSIGNED_BYTE, 
                         ASCII, 
                         UNSIGNED_SHORT, 
                         UNSIGNED_LONG, 
                         RATIONAL, 
                         SIGNED_BYTE,
                         UNDEFINED,
                         SIGNED_SHORT,
                         SIGNED_LONG,
                         SIGNED_RATIONAL,
                         FLOAT,
                         DOUBLE)
     with Size => 16;
   
   for TagDataTypes use (UNSIGNED_BYTE => 1,
                         ASCII => 2,
                         UNSIGNED_SHORT => 3,
                         UNSIGNED_LONG => 4,
                         RATIONAL => 5,
                         SIGNED_BYTE => 6,
                         UNDEFINED => 7,
                         SIGNED_SHORT => 8,
                         SIGNED_LONG => 9,
                         SIGNED_RATIONAL => 10,
                         FLOAT => 11,
                         DOUBLE => 12);

   type Tag is tagged record 
      ID             : Unsigned_16;
      DataType       : TagDataTypes;
      ValueCount     : Unsigned_32;
      ValueOrPointer : Unsigned_32;
   end record;
   
   type Tag_Array is array (Unsigned_16 range <>) of Tag;
   
   type ImageFileDirectory (TagCount : Unsigned_16) is record
      Tags : Tag_Array (1 .. TagCount);
   end record;
   
   package ImageFileDirectory_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Index_Type => Natural,
        Element_Type => ImageFileDirectory);
   
   type Chunk_Data_Info is new PNG.Chunk_Data_Info with record
      ImageFileDirectories : ImageFileDirectory_Vectors.Vector;
   end record;
   
   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector; F : Ada.Streams.Stream_IO.File_Type);

end eXIf;

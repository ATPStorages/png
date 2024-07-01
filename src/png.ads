with Ada.Containers; use Ada.Containers;
with Ada.Containers.Indefinite_Vectors;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;
with ByteFlip;
with System; use System;

package PNG is

   --  PNG file format signature.
   Signature : constant Unsigned_64 := 16#89504E470D0A1A0A#;

   --== Chunk Base Defintions ==--

   subtype Chunk_Type is Unsigned_32;
   type Chunk_Type_Info is record
      Raw           : Chunk_Type;
      Ancillary     : Boolean;
      Specification : Boolean;
      Reserved      : Boolean;
      SafeToCopy    : Boolean;
   end record;

   type Unsigned_31 is mod 2 ** 31
     with Size => 32;
   subtype Unsigned_31_Positive is PNG.Unsigned_31 range 1 .. PNG.Unsigned_31'Last;

   type Chunk_Data_Array is array (Unsigned_31 range <>) of Unsigned_8;

   type Chunk_Data_Info is tagged null record;
   type Chunk_Data_Info_Access is access all Chunk_Data_Info'Class;

   type Chunk_Data is record
      Info : Chunk_Data_Info_Access;
   end record;

   type Chunk (Length : Unsigned_31) is record
      TypeInfo : Chunk_Type_Info;
      Data     : Chunk_Data;
      CRC32    : Unsigned_32;
   end record;

   function Chunk_Equal_Element (A, B : Chunk) return Boolean;

   package Chunk_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Index_Type => Natural,
        Element_Type => Chunk);

   procedure Decode (Self : in out Chunk_Data_Info;
                     S : Stream_Access;
                     C : Chunk;
                     V : Chunk_Vectors.Vector;
                     F : File_Type);

   --== File Reading ==--

   --= Exceptions =--

   --  There's a chunk with a wrong size where it is defined in the specification.
   BAD_CHUNK_SIZE_ERROR : exception;

   --  There's a problem with the first 4 bytes of the PNG stream; they don't line up with PNG.Signature.
   BAD_SIGNATURE_ERROR : exception;

   --  There's a second chunk where only one chunk of a certain type may exist.
   DUPLICATE_CHUNK_ERROR : exception;

   --  There's a problem with the structure of the PNG stream (i.e. no IHDR at the start, no IEND at the end)
   BAD_STRUCTURE_ERROR : exception;

   --  There's an unrecognized non-ancillary chunk which cannot be skipped over
   UNRECOGNIZED_CRITICAL_CHUNK_ERROR : exception;

   package Unsigned_16_ByteFlipper is new
     ByteFlip (Modular_Type => Unsigned_16);

   package Unsigned_31_ByteFlipper is new
     ByteFlip (Modular_Type => Unsigned_31);

   package Unsigned_32_ByteFlipper is new
     ByteFlip (Modular_Type => Unsigned_32);

   package Unsigned_64_ByteFlipper is new
     ByteFlip (Modular_Type => Unsigned_64);

   --== PNG File Defintion ==--

   type File is record
      Chunks : Chunk_Vectors.Vector;
   end record;

   --  Reads an image from a PNG file. This will not close the provided stream after finishing.
   function  Read  (F : File_Type; S : Stream_Access) return File;
   procedure Write (F : File;  S : Stream_Access);
end PNG;

with Ada.Containers; use Ada.Containers;
with Ada.Containers.Indefinite_Hashed_Sets;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;

package PNG is

   --  PNG file format signature.
   Signature : constant Unsigned_64 := 16#0A1A0A0D474E5089#;

   --== Chunk Base Defintions ==--

   subtype PNG_Chunk_Type is Unsigned_32;
   type PNG_Chunk_Type_Info is record
      Raw           : PNG_Chunk_Type;
      Ancillary     : Boolean;
      Specification : Boolean;
      Reserved      : Boolean;
      SafeToCopy    : Boolean;
   end record;

   type PNG_Chunk_Data is
     array (Unsigned_32 range <>)
     of Unsigned_8;

   type PNG_Chunk_Data_Info
     (DataLength : Unsigned_32)
   is tagged record
      Data : PNG_Chunk_Data (1 .. DataLength);
   end record;

   type PNG_Chunk
     (DataLength : Unsigned_32)
   is record
      ChunkType     : PNG_Chunk_Type;
      ChunkTypeInfo : PNG_Chunk_Type_Info;
      Data          : PNG_Chunk_Data_Info (DataLength);
      CRC32         : Unsigned_32;
   end record;

   function PNG_Chunk_Hash (Chunk : PNG_Chunk) return Ada.Containers.Hash_Type;
   function PNG_Chunk_Equal_Element (A, B : PNG_Chunk) return Boolean;

   package PNG_Chunk_Sets is new
     Ada.Containers.Indefinite_Hashed_Sets
       (Element_Type => PNG_Chunk,
        Hash => PNG_Chunk_Hash,
        Equivalent_Elements => PNG_Chunk_Equal_Element);

   --== Critical Chunk Definitions ==--

   --  IHDR chunk-specific data.
   type IHDR_Chunk_Data_Info is new PNG_Chunk_Data_Info (56) with record
      Width             : Positive;
      --  Width of the image.
      Height            : Positive;
      --  Height of the image.
      BitDepth          : Unsigned_8;
      --  Bit depth of the pixels within this image.
      ColorType         : Unsigned_8;
      CompressionMethod : Unsigned_8 range 0 .. 0;
      FilterMethod      : Unsigned_8 range 0 .. 0;
      InterlaceMethod   : Unsigned_8 range 0 .. 1;
   end record;

   subtype PLTE_Palette_Length is Unsigned_32 range 1 .. 256;
   type PLTE_Palette_Color_Data is array (1 .. 3) of Unsigned_8;
   type PLTE_Palette_Data is
     array (PLTE_Palette_Length range <>)
     of PLTE_Palette_Color_Data;
   subtype PLTE_Palette_Data_Length
     is Unsigned_32
       range PLTE_Palette_Length'First * 3 .. PLTE_Palette_Length'Last * 3
     with Dynamic_Predicate => PLTE_Palette_Data_Length mod 3 = 0;

   --  PLTE chunk-specific data.
   type PLTE_Chunk_Data_Info
     (DataLength : PLTE_Palette_Data_Length;
      PaletteLength : PLTE_Palette_Length)
   is new PNG_Chunk_Data_Info (DataLength) with record
      Palette : PLTE_Palette_Data (1 .. PaletteLength);
   end record;

   --== PNG File Defintion ==--

   type PNG_File is record
      Chunks : PNG_Chunk_Sets.Set;
   end record;

   --  Reads an image from a PNG file. This will not close the provided stream after finishing.
   function  Read  (S : Stream_Access) return PNG_File;
   procedure Write (S : Stream_Access; F : PNG_File);
end PNG;

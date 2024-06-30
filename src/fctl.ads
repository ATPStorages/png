with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces; use Interfaces;
with PNG;

package fcTL is

   type DisposalOperations is (APNG_DISPOSE_OP_NONE, 
                              APNG_DISPOSE_OP_BACKGROUND, 
                              APNG_DISPOSE_OP_PREVIOUS,
                              APNG_DISPOSE_OP_UNKNOWN)
     with Size => 8;
   for DisposalOperations use (APNG_DISPOSE_OP_NONE => 0, 
                              APNG_DISPOSE_OP_BACKGROUND => 1,
                              APNG_DISPOSE_OP_PREVIOUS => 2,
                              APNG_DISPOSE_OP_UNKNOWN => 3);
   
   type BlendOperations is (APNG_BLEND_OP_SOURCE, 
                           APNG_BLEND_OP_OVER,
                           APNG_BLEND_OP_UNKNOWN)
     with Size => 8;
   for BlendOperations use (APNG_BLEND_OP_SOURCE => 0, 
                           APNG_BLEND_OP_OVER => 1,
                           APNG_BLEND_OP_UNKNOWN => 2);
   
   INVALID_OPERATION_ERROR : exception;
   
   type Chunk_Data_Info is new PNG.Chunk_Data_Info with record
      FramePosition     : PNG.Unsigned_31;
      FrameWidth        : PNG.Unsigned_31_Positive;
      FrameHeight       : PNG.Unsigned_31_Positive;
      FrameOffsetX      : PNG.Unsigned_31;
      FrameOffsetY      : PNG.Unsigned_31;
      DelayNumerator    : Unsigned_16;
      DelayDenominator  : Unsigned_16;
      DisposalOperation : DisposalOperations;
      BlendOperation    : BlendOperations;
   end record;
   
   overriding procedure Decode (Self : in out Chunk_Data_Info; S : Stream_Access; C : PNG.Chunk; V : PNG.Chunk_Vectors.Vector);

end fcTL;

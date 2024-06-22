generic 
      --  The type to operate on for bit flipping.
      type Modular_Type is mod <>;
package ByteFlip is
   --  Flips M's bytes (endian).
   procedure FlipBytes (M : in out Modular_Type);
   
   --  Flips M's bytes (endian) to from Big Endian to Little Endian, IF the host machine is Little Endian.
   procedure FlipBytesBE (M : in out Modular_Type);
   
   --  Flips M's bytes (endian) to from Little Endian to Big Endian, IF the host machine is Big Endian.
   procedure FlipBytesLE (M : in out Modular_Type);
end ByteFlip;

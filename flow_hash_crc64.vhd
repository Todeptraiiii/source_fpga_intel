-------------------------------------------------------------------------------
-- Copyright (C) 2009 OutputLogic.com
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
--
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
-------------------------------------------------------------------------------
-- CRC64 ECMA-182
-- 
-- Compatible with Linux kernel crc64_be() function with seed ~0 for key0 and seed 0 for key1.
-- https://github.com/torvalds/linux/blob/master/lib/crc64.c
--
-- Example: sip=0xc0a8000a, dip=0x08080808, proto=0x06, sport=0x1324, dport=0x1194
-- u64 p[] = {
--     0x00000000c0a8000aULL, // Sip
--     0x0000000000000000ULL,
--     0x0000000008080808ULL, // Dip
--     0x0000000000000000ULL,
--     0x0000000613241194ULL, // Proto | sport | dport
-- };
-- u64 p1[] = {
--     0x0000000008080808ULL, // Dip
--     0x0000000000000000ULL,
--     0x00000000c0a8000aULL, // Sip
--     0x0000000000000000ULL,
--     0x0000000611941324ULL, // Proto | dport | sport
-- };
-- crc64_be(~0, p, 37) return 0x521db290d31d82c4.
-- crc64_be(0, p1, 37) return 0x574f0b35d162ae24.
-- 
-- flow_hash_crc64(
--    sip   => x"0000_0000_0000_0000_0000_0000_c0a8_000a",
--    dip   => x"0000_0000_0000_0000_0000_0000_0808_0808",
--    proto => x"06",
--    sport => x"1324",
--    dport => x"1194",
--    key0  => key0,
--    key1  => key1)
-- key0=x"521db290d31d82c4"
-- key1=x"574f0b35d162ae24"
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity flow_hash_crc64 is
port (
    sip     : in  std_logic_vector (127 downto 0);
    dip     : in  std_logic_vector (127 downto 0);
    proto   : in  std_logic_vector (  7 downto 0);
    sport   : in  std_logic_vector ( 15 downto 0);
    dport   : in  std_logic_vector ( 15 downto 0);
    key0    : out std_logic_vector ( 63 downto 0);
    key1    : out std_logic_vector ( 63 downto 0)
    );
end flow_hash_crc64;

architecture imp_crc of flow_hash_crc64 is
    function swap(blk : std_logic_vector) return std_logic_vector is
            variable ret : std_logic_vector(blk'range);
        begin
            for i in 0 to ret'length/8-1 loop
                ret(i*8+7 downto i*8) := blk((ret'length/8-1-i)*8+7 downto (ret'length/8-1-i)*8);
            end loop;
            return ret;
    end function;

    component crc64
    port (
        data_in : in    std_logic_vector (295 downto 0);
        crc_in  : in    std_logic_vector ( 63 downto 0);
        crc_out : out   std_logic_vector ( 63 downto 0)
        );
    end component;

    signal data_in  : std_logic_vector (295 downto 0);
    signal data_in1 : std_logic_vector (295 downto 0);
    signal crc_out  : std_logic_vector (63 downto 0);
    signal crc_out1 : std_logic_vector (63 downto 0);

begin

data_in  <= swap(sip) & swap(dip) & swap(dport) & swap(sport) & proto;
data_in1 <= swap(dip) & swap(sip) & swap(sport) & swap(dport) & proto;
key0 <= crc_out;
key1 <= crc_out1;

hash_key: crc64
port map (
    data_in => data_in,
    crc_in  => (others => '1'),
    crc_out => crc_out
    );

hash_index: crc64
port map (
    data_in => data_in1,
    crc_in  => (others => '0'),
    crc_out => crc_out1
    );

end architecture imp_crc;

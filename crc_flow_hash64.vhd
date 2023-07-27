----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/08/2023 05:23:16 PM
-- Design Name: 
-- Module Name: crc_flow_hash64 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity crc_flow_hash64 is
  Generic (init_sip : std_logic_vector(127 downto 0));
  Port 
  (
  reset     : in std_logic;
  clk       : in std_logic;
  crc_en    : in std_logic;
  crc_out   : out std_logic_vector(63 downto 0)
  );
end crc_flow_hash64;

architecture Behavioral of crc_flow_hash64 is

component flow_hash_crc64 is
port (
    sip     : in  std_logic_vector (127 downto 0);
    dip     : in  std_logic_vector (127 downto 0);
    proto   : in  std_logic_vector (  7 downto 0);
    sport   : in  std_logic_vector ( 15 downto 0);
    dport   : in  std_logic_vector ( 15 downto 0);
    key0    : out std_logic_vector ( 63 downto 0);
    key1    : out std_logic_vector ( 63 downto 0)
    );
end component flow_hash_crc64;

component crc is
  port ( 
    data_in : in std_logic_vector (31 downto 0);
    crc_en, rst, clk : in std_logic;
    crc_out : out std_logic_vector (31 downto 0));
end component crc;


signal    sip     : std_logic_vector (127 downto 0) := init_sip;--x"0000_0000_0000_0000_0000_0000_c0a8_000a";
signal    dip     : std_logic_vector (127 downto 0) := x"0000_0000_0000_0000_0000_0000_0808_0808";
signal    proto   : std_logic_vector (  7 downto 0);
signal    sport   : std_logic_vector ( 15 downto 0) := x"1324";
signal    dport   : std_logic_vector ( 15 downto 0) := x"1194";
signal    key0    : std_logic_vector ( 63 downto 0);
signal    key1    : std_logic_vector ( 63 downto 0);

signal proto_32b  : std_logic_vector(31 downto 0);

begin

flow_hash_crc64_inst1: flow_hash_crc64

port map
    (
    sip     =>  sip,
    dip     =>  dip,
    proto   =>  proto,
    sport   =>  sport,
    dport   =>  dport,
    key0    =>  crc_out
    );

crc_inst1: crc
port map
    (
    clk     =>  clk,
    rst     =>  reset,
    data_in =>  x"11111111",
    crc_out =>  proto_32b,
    crc_en  =>  crc_en
    );
proto   <=  proto_32b(7 downto 0);

end Behavioral;

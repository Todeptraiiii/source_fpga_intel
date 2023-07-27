

-- Dao van to
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ddr3_controller is
	port
	(
	clk			: in	std_logic;
	clk_50m			: in	std_logic;
	ninit_done		: in	std_logic;
	resetn			: in	std_logic;
	amm_ready_0		: in	std_logic;
	amm_read_0		: out	std_logic;
	amm_write_0		: out	std_logic;
	amm_address_0		: out 	std_logic_vector(29 downto 0) ;	
	amm_readdata_0  	: in  	std_logic_vector(255 downto 0) := (others => '0');
	amm_writedata_0     	: out 	std_logic_vector(255 downto 0);       
	amm_burstcount_0    	: out 	std_logic_vector(6 downto 0)  ;         
	amm_byteenable_0    	: out 	std_logic_vector(31 downto 0) ;        
	amm_readdatavalid_0 	: in  	std_logic;
	
	local_cal_success	: in	std_logic;
	uart_tx			: out	std_logic
	);
end ddr3_controller;

architecture rtl of ddr3_controller is
--

component crc_flow_hash64 is
  Generic (init_sip : std_logic_vector(127 downto 0));
  Port 
  (
  reset     : in std_logic;
  clk       : in std_logic;
  crc_en    : in std_logic;
  crc_out   : out std_logic_vector(63 downto 0)
  );
end component crc_flow_hash64;

--
component uart IS
  GENERIC(
    clk_freq  :  INTEGER    := 50_000_000;  --frequency of system clock in Hertz
    baud_rate :  INTEGER    := 115_200;      --data link baud rate in bits/second
    os_rate   :  INTEGER    := 16;          --oversampling rate to find center of receive bits (in samples per baud period)
    d_width   :  INTEGER    := 8;           --data bus width
    parity    :  INTEGER    := 0;           --0 for no parity, 1 for parity
    parity_eo :  STD_LOGIC  := '0');        --'0' for even, '1' for odd parity
  PORT(
    clk      :  IN   STD_LOGIC;                             --system clock
    reset_n  :  IN   STD_LOGIC;                             --ascynchronous reset
    tx_ena   :  IN   STD_LOGIC;                             --initiate transmission
    tx_data  :  IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
    rx       :  IN   STD_LOGIC;                             --receive pin
    rx_busy  :  OUT  STD_LOGIC;                             --data reception in progress
    rx_error :  OUT  STD_LOGIC;                             --start, parity, or stop bit error detected
    rx_data  :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data received
    tx_busy  :  OUT  STD_LOGIC;                             --transmission in progress
    tx       :  OUT  STD_LOGIC);                            --transmit pin
end component uart;
--

signal amm_ready			:	std_logic;
signal amm_read				:	std_logic	:= '0';		
signal amm_write			:	std_logic;			
signal amm_address			:	std_logic_vector(29 downto 0) := (others => '0');		
signal amm_readdata			:	std_logic_vector(255 downto 0);  	
signal amm_writedata		:	std_logic_vector(255 downto 0) := (others => '0');     
signal amm_burstcount		:	std_logic_vector(6 downto 0);    
signal amm_byteenable   	:	std_logic_vector(31 downto 0); 
signal amm_readdatavalid	:	std_logic;
signal reset				:	std_logic;

--                  
signal tx_ena   			:    STD_LOGIC;                   
signal tx_data  			:    STD_LOGIC_VECTOR(7 DOWNTO 0);
signal rx       			:    STD_LOGIC;                   
signal rx_busy  			:    STD_LOGIC;                   
signal rx_error 			:    STD_LOGIC;                   
signal rx_data  			:    STD_LOGIC_VECTOR(7 DOWNTO 0);
signal tx_busy 				:    STD_LOGIC;                   
signal tx       			:    STD_LOGIC;
--

signal threshold			:	std_logic_vector(31 downto 0) := X"7FFFFFFF";
signal count_r 				: 	std_logic_vector(31 downto 0) := (others => '0');
signal count_w 				: 	std_logic_vector(31 downto 0) := (others => '0');

--
signal rd_state				: integer := 0;
signal wr_state				: integer := 0;
signal i                    : integer := -1;
--

type state_type is (r,w);
signal read_write_cmd		: state_type := r;
signal crc_out64			: std_logic_vector(63 downto 0) := (others => '0');
signal crc_out32			: std_logic_vector(31 downto 0) := (others => '0');
signal time_1s              : std_logic := '1';
signal data 				: std_logic_vector(63 downto 0) := (others => '0');

signal int_count_w          : integer := 0;
signal int_count_r          : integer := 0;

signal data_temp			: std_logic_vector(255 downto 0) := (others => '0');
signal switch_state			: integer := 0;


signal threshold_read		: integer := 20;
signal threshold_write		: integer := 10;


begin

--
uart_inst : uart
port map
(
    clk       => clk_50M,
    reset_n     => '1',
    tx_ena      => tx_ena,
    tx_data     => tx_data,
    rx          => rx,
    rx_busy     => rx_busy,
    rx_error    => rx_error,
    rx_data     => rx_data,
    tx_busy     => tx_busy,
    tx          => tx
);

uart_control_pr: process(clk_50M) 
    variable data_t : std_logic_vector(7 downto 0) := (others => '0');  
begin 
    if rising_edge(clk_50m) then 
        case time_1s is 
            when '0' =>
                if i >=  0 then 
                    if tx_busy = '0' then 
                        tx_ena	<= '1';                  
                        data_t	:= data(8*i+ 7 downto 8*i);
                    end if;
                    if tx_ena = '1' then
                        tx_ena	<= '0';
                        i		<= i - 1;
                    end if;
                    tx_data		<= data_t; 
                else 
                    data		<= (others => '0');
                end if;
            when others => 
               i <= 7;
              data <= count_r & count_w;
        end case;
    end if;
end process;

--


crc_flow_hash64_inst: crc_flow_hash64
generic map 
    (
    init_sip    =>  X"0000_0000_0000_0000_0000_0000_0808_0808"
    )
port map
	(
	reset		=>	reset,
	clk			=>	clk,    
	crc_en		=>	'1', 
	crc_out		=>	crc_out64
	);



reset		<=	not resetn ;
crc_out32	<=	crc_out64(31 downto 0);
uart_tx		<=	tx;

--
read_write_cmd		<=	w when crc_out32 < threshold else
						r;
--
write_valid: process(clk) 
begin
	if rising_edge(clk) then
		if reset = '1' then
			wr_state <= 0;
			count_w  <= (others => '0');
		else
			case wr_state is
				when 0 =>
					if local_cal_success = '1' then
						wr_state <= 1;
					end if;
				when 1 =>
					if count_w	< threshold_write then
						wr_state  <= 2;
						amm_write <= '1';
					else
						wr_state  <= 3;
					end if;
				when 2 =>
					if amm_ready = '1' then
						count_w  <= count_w + 1;
						wr_state <= 1;
						amm_write <= '0';
					end if;
				when 3 =>
						switch_state <= 1;
				when others =>
						wr_state <= 1;
			end case;
		end if;
	end if;
end process;

--

read_valid:	process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			rd_state	<=	0;
			count_r		<=	(others => '0');
		else
			case rd_state is
				when 0	=>
					if switch_state	= 1 then
						rd_state <= 1;
					end if;
				when 1	=>
					if count_r	< threshold_read then
						rd_state <= 2;
						amm_read <= '1';
					else
						rd_state <= 3;
					end if;
				when 2	=>
					if amm_ready = '1' then
						if count_r <= count_w then
							count_r  <= count_r + 1;
							rd_state <= 1;
							amm_read <= '0';
						else
							count_r	 <= (others => '0');
							rd_state <= 1;
							amm_read <= '0';
						end if;		
					end if;	
				when 3	=>
					
				
				when others => 
					rd_state	<=	1;
			end case;
		end if;
	end if;
end process;

--

int_count_w     <=  to_integer(unsigned(count_w));
int_count_r     <=  to_integer(unsigned(count_r));

--ghi dia chi
amm_address     <=  std_logic_vector(to_unsigned(int_count_w * 400,amm_address'length)) when amm_write = '1' else
					std_logic_vector(to_unsigned(int_count_r * 400,amm_address'length)) when amm_read  = '1' else
					(others => '0'); 

-- ghi du lieu			
amm_writedata	<=	data_temp + crc_out32 when amm_write = '1' else
					(others => '0');

--

amm_ready	  <=	amm_ready_0;
amm_readdata	  <=	amm_readdata_0;
amm_readdatavalid <=	amm_readdatavalid_0;

amm_read_0	 <=	amm_read;
amm_write_0      <=	amm_write;
amm_address_0	 <=	amm_address;
amm_writedata_0	 <=	amm_writedata;
amm_burstcount_0 <= 	"0000001";
amm_byteenable	 <=	(others => '1');

amm_byteenable_0 <= amm_byteenable;


end architecture rtl;
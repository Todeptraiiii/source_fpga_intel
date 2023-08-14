----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/28/2022 02:24:53 PM
-- Design Name: 
-- Module Name: ddr3_data_gen - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ddr3_data_gen is
Port (

    --
    S_AXI_0_araddr          : out    STD_LOGIC_VECTOR ( 29 downto 0 );
    S_AXI_0_arburst         : out    STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_arcache         : out    STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_arid            : out    STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_arlen           : out    STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_0_arlock          : out    STD_LOGIC;
    S_AXI_0_arprot          : out    STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_arqos           : out    STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_arready         : in     STD_LOGIC;
    S_AXI_0_arsize          : out    STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_arvalid         : out    STD_LOGIC;
    --  
    S_AXI_0_awaddr          : out    STD_LOGIC_VECTOR ( 29 downto 0 );
    S_AXI_0_awburst         : out    STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_awcache         : out    STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_awid            : out    STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_awlen           : out    STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_0_awlock          : out    STD_LOGIC;
    S_AXI_0_awprot          : out    STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_awqos           : out    STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_awready         : in     STD_LOGIC;
    S_AXI_0_awsize          : out    STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_awvalid         : out    STD_LOGIC;
    --
    S_AXI_0_bid             : in     STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_bready          : out    STD_LOGIC;
    S_AXI_0_bresp           : in     STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_bvalid          : in     STD_LOGIC;
    S_AXI_0_rdata           : in     STD_LOGIC_VECTOR ( 255 downto 0 );
    S_AXI_0_rid             : in     STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_rlast           : in     STD_LOGIC;
    S_AXI_0_rready          : out    STD_LOGIC;
    S_AXI_0_rresp           : in     STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_rvalid          : in     STD_LOGIC;
    S_AXI_0_wdata           : out    STD_LOGIC_VECTOR ( 255 downto 0 );
    S_AXI_0_wlast           : out    STD_LOGIC;
    S_AXI_0_wready          : in     STD_LOGIC;
    S_AXI_0_wstrb           : out    STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_wvalid          : out    STD_LOGIC;
    init_calib_complete_0   : in     STD_LOGIC;
    reset_rtl_0             : in     STD_LOGIC;
    ui_clk_0                : in     STD_LOGIC;
    
    CLK_50M                 : in     STD_LOGIC;
    UART_TX                 : out    STD_LOGIC;
    UART_RX                 : in     STD_LOGIC
);
end ddr3_data_gen;

architecture Behavioral of ddr3_data_gen is



component uart is 
   GENERIC(
    clk_freq  :  INTEGER    := 50_000_000;  --frequency of system clock in Hertz
    baud_rate :  INTEGER    := 19_200;      --data link baud rate in bits/second
    os_rate   :  INTEGER    := 16;          --oversampling rate to find center of receive bits (in samples per baud period)
    d_width   :  INTEGER    := 8;           --data bus width
    parity    :  INTEGER    := 0;           --0 for no parity, 1 for parity
    parity_eo :  STD_LOGIC  := '0');        --'0' for even, '1' for odd parity
  PORT(
    clk    :  IN   STD_LOGIC;                             --system clock
    reset_n  :  IN   STD_LOGIC;                             --ascynchronous reset
    tx_ena   :  IN   STD_LOGIC;                             --initiate transmission
    tx_data  :  IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
    rx       :  IN   STD_LOGIC;                             --receive pin
    rx_busy  :  OUT  STD_LOGIC;                             --data reception in progress
    rx_error :  OUT  STD_LOGIC;                             --start, parity, or stop bit error detected
    rx_data  :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data received
    tx_busy  :  OUT  STD_LOGIC;                             --transmission in progress
    tx       :  OUT  STD_LOGIC);  
end component;

component crc_flow_hash64 is
  Port 
  (
  reset     : in std_logic;
  clk       : in std_logic;
  crc_en    : in std_logic;
  crc_out   : out std_logic_vector(63 downto 0)
  );
end component crc_flow_hash64;


signal S_AXI_araddr          :  STD_LOGIC_VECTOR ( 29 downto 0 ) := (others => '0');
signal araddr                :  STD_LOGIC_VECTOR ( 29 downto 0 ) := (others => '0');
signal S_AXI_arburst         :  STD_LOGIC_VECTOR ( 1 downto 0 ) := (others => '0');
signal S_AXI_arcache         :  STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
signal S_AXI_arid            :  STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
signal S_AXI_arlen           :  STD_LOGIC_VECTOR ( 7 downto 0 ) := (others => '0');
signal S_AXI_arlock          :  STD_LOGIC := '0';
signal S_AXI_arprot          :  STD_LOGIC_VECTOR ( 2 downto 0 ) := (others => '0');
signal S_AXI_arqos           :  STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
signal S_AXI_arready         :  STD_LOGIC := '0';
signal S_AXI_arsize          :  STD_LOGIC_VECTOR ( 2 downto 0 ) := (others => '0');
signal S_AXI_arvalid         :  STD_LOGIC := '0';
signal arvalid               :  STD_LOGIC := '0';
signal S_AXI_awaddr          :  STD_LOGIC_VECTOR ( 29 downto 0 ) := (others => '0');
signal awaddr                :  STD_LOGIC_VECTOR ( 29 downto 0 ) := (others => '0');
signal S_AXI_awburst         :  STD_LOGIC_VECTOR ( 1 downto 0 ) := (others => '0');
signal S_AXI_awcache         :  STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
signal S_AXI_awid            :  STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
signal S_AXI_awlen           :  STD_LOGIC_VECTOR ( 7 downto 0 ) := (others => '0');
signal S_AXI_awlock          :  STD_LOGIC := '0';
signal S_AXI_awprot          :  STD_LOGIC_VECTOR ( 2 downto 0 ) := (others => '0');
signal S_AXI_awqos           :  STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
signal S_AXI_awready         :  STD_LOGIC := '0';
signal S_AXI_awsize          :  STD_LOGIC_VECTOR ( 2 downto 0 ) := (others => '0');
signal S_AXI_awvalid         :  STD_LOGIC := '0';
signal awvalid               :  STD_LOGIC := '0';
signal S_AXI_bid             :  STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
signal S_AXI_bready          :  STD_LOGIC := '0';
signal S_AXI_bresp           :  STD_LOGIC_VECTOR ( 1 downto 0 ) := (others => '0');
signal S_AXI_bvalid          :  STD_LOGIC := '0';
signal S_AXI_rdata           :  STD_LOGIC_VECTOR ( 255 downto 0 ) := (others => '0');
signal S_AXI_rid             :  STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
signal S_AXI_rlast           :  STD_LOGIC := '0';
signal S_AXI_rready          :  STD_LOGIC := '0';
signal S_AXI_rresp           :  STD_LOGIC_VECTOR ( 1 downto 0 ) := (others => '0');
signal S_AXI_rvalid          :  STD_LOGIC := '0';
signal S_AXI_wdata           :  STD_LOGIC_VECTOR ( 255 downto 0 ) := (others => '0');
signal wdata                 :  STD_LOGIC_VECTOR ( 255 downto 0 ) := (others => '0');
signal S_AXI_wlast           :  STD_LOGIC := '0';
signal wlast                 :  STD_LOGIC := '0';
signal S_AXI_wready          :  STD_LOGIC := '0';
signal S_AXI_wstrb           :  STD_LOGIC_VECTOR ( 31 downto 0 ) := (others => '0');
signal wstrb                 :  STD_LOGIC_VECTOR ( 31 downto 0 ) := (others => '0');
signal S_AXI_wvalid          :  STD_LOGIC := '0';
signal wvalid                :  STD_LOGIC := '0';
signal init_calib_complete   :  STD_LOGIC := '0';
signal reset_rtl             :  STD_LOGIC := '0';
signal ui_clk                :  STD_LOGIC := '0';
signal ui_clk_sync_rst       :  STD_LOGIC := '0';

signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal resetn : std_logic := '0';

constant simulation : std_logic := '1';

signal awlen : std_logic_vector (7 downto 0) := (others => '0');
signal bready : std_logic := '0';

signal arid : std_logic_vector (3 downto 0) := (others => '0');
signal awid : std_logic_vector (3 downto 0) := (others => '0');
signal rready : std_logic := '0';

signal state : integer := 0;
signal cnt_valid : integer := 0;

signal cnt_byte : std_logic_vector (31 downto 0) := (others => '0');
signal tkeep_conv : integer := 0;
constant number_of_block : integer := 4;
signal cnt_block : integer := 0;

signal cnt_timer : std_logic_vector (31 downto 0) := (others => '0');
constant timer_1s: integer := 30;--_000_000;

signal cnt_num_addr          : integer := 0;
signal cnt_rd_num_addr       : integer := 0;
signal awr_state             : integer := 0;
signal wr_state              : integer := 0;
signal cnt_awr_period        : integer := 0;
signal cnt_wr_period         : integer := 0;
constant increamentation_def   : integer := 400;
signal ar_state              : integer := 0;
signal cnt_ar_period         : integer := 0;

signal cnt_time              : std_logic_vector (31 downto 0) := (others => '0');
signal cnt_number_read       : std_logic_vector (31 downto 0) := (others => '0');
signal cnt_clk_delay_read    : std_logic_vector (31 downto 0) := (others => '0');
signal first_read            : std_logic := '0';

 signal   reset_n  :    STD_LOGIC;                             --ascynchronous reset
 signal   tx_ena   :    STD_LOGIC;                             --initiate transmission
 signal   tx_data  :    STD_LOGIC_VECTOR(7 DOWNTO 0);  --data to transmit
 signal   rx       :    STD_LOGIC;                             --receive pin
 signal   rx_busy  :    STD_LOGIC;                             --data reception in progress
 signal   rx_error :    STD_LOGIC;                             --start, parity, or stop bit error detected
 signal   rx_data  :    STD_LOGIC_VECTOR(7 DOWNTO 0);  --data received
 signal   tx_busy  :    STD_LOGIC;                             --transmission in progress
 signal   tx       :    STD_LOGIC; 

signal data : std_logic_vector(31 downto 0) := (others => '0');
signal time_2s : std_logic := '0';
signal i : integer := -1;

signal count_data : std_logic_vector(31 downto 0) := (others => '0');
signal clk_t : std_logic := '0';
signal threshold : std_logic_vector(31 downto 0) := x"80000000";

signal data_out : std_logic_vector(63 downto 0):= (others => '0');
signal data_out1 : std_logic_vector(63 downto 0):= (others => '0');
signal data_out2 : std_logic_vector(63 downto 0):= (others => '0');

signal count_r : std_logic_vector(31 downto 0) := (others => '0');
signal count_w : std_logic_vector(31 downto 0) := (others => '0');
signal cnt_rlast: integer := 0;

type state_t is (idle, w, r);
signal w_r : state_t := r;

signal pseudo_address : std_logic_vector(29 downto 0) := (others => '0');
signal count_w_valid : integer := 0;
signal ctr_state     : integer := 0;
signal temp          : std_logic_vector(63 downto 0) :=  (others => '0');

signal count_ar,count_aw         : integer := 0;
signal s_crc_en      : std_logic;
signal s_crc_en1     : std_logic;
signal s_crc_en2     : std_logic;
signal s_reset1      : std_logic := '0';
signal s_reset2      : std_logic := '0';
signal reset1        : std_logic := '0';
signal reset2        : std_logic := '0';
signal ctr_repeat    : std_logic := '0';

-------- Array-------
signal i_count  : integer := 0;
signal check1   : std_logic := '0';
signal check    : integer := 0;
signal cnt      : integer := 0;
signal data_zero: std_logic_vector(255 downto 0) := (others => '0');
signal count : integer := 0;
signal number_read: integer := 0;
signal one_pulse : std_logic;
signal s_check  : std_logic_vector(31 downto 0);

begin

s_check <=  conv_std_logic_vector(check,s_check'length); -- convert for uart

count_number_of_read_req: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            cnt_number_read <= (others => '0');
        elsif s_axi_arvalid = '1' and s_axi_arready = '1' then
            cnt_number_read <= cnt_number_read + 1;
        end if;
    end if;
end process;

clk     <= ui_clk;
reset   <= reset_rtl;
resetn  <= not reset;


uart_pr : uart
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

uart_tx <= tx;

crc_flow_hash64_inst1: crc_flow_hash64
port map
(
    clk     =>  clk,
    reset   =>  reset,
    crc_en  =>  s_crc_en,
    crc_out =>  data_out 
);

crc_flow_hash64_inst2: crc_flow_hash64
port map
(
    clk     =>  clk,
    reset   =>  reset1,
    crc_en  =>  s_crc_en1,
    crc_out =>  data_out1 
);

crc_flow_hash64_inst3: crc_flow_hash64
port map
(
    clk     =>  clk,
    reset   =>  reset2,
    crc_en  =>  s_crc_en2,
    crc_out =>  data_out2
);
uart_control_pr: process(clk_50M) 
    variable data_t : std_logic_vector(7 downto 0) := (others => '0');  
begin 
    if rising_edge(clk_50M) then 
        case time_2s is 
            when '0' =>
                if i >=  0 then 
                    if tx_busy = '0' then 
                        tx_ena <= '1';                  
                        data_t := data(8*i+ 7 downto 8*i);
                    end if;
                    if tx_ena = '1' then
                        tx_ena <= '0';
                        i      <= i - 1;
                    end if;
                    tx_data    <= data_t; 
                else 
                    data       <= (others => '0');
                end if;
            when others => 
               i    <= 3;
               data <= s_check;
        end case;
    end if;
end process;


time_2s_pr: process(clk_50M) 
variable count : integer := 0;
begin
    if rising_edge(clk_50M) then
--        if count = 100_000_000 then
        if count = 200_000_000 then
            time_2s <= '1';
            count := 0;
        else 
            count := count + 1;
            time_2s <= '0';
        end if;
    end if;
end process;

counter_timer_pr: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            cnt_timer <= (others => '0');
        elsif init_calib_complete = '1' then
            if cnt_timer < timer_1s then
                cnt_timer <= cnt_timer + 1;
            else
                cnt_timer <= (others => '0');
            end if;    
        end if;
    end if;
end process;


bready <= '1';
rready <= '1';

awvalid_pr: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            awr_state   <= 0;
            count_w     <= (others => '0');
        else
            case awr_state is
                when 0 =>
                    if init_calib_complete_0 = '1' then
                        awr_state <= 1;
                    end if;
                when 1 =>
                        awr_state   <= 2;
                        awvalid     <= '1';
                when 2 =>
                    if s_axi_awready = '1' then
                        awvalid     <= '0';
                        if s_axi_bvalid = '1' and s_axi_bready = '1' then 
                        awr_state   <= 1;
                        count_w     <= count_w + 1;
                        end if;
                    end if;
                when others =>
            end case;
        end if;    
    end if;
end process;

s_crc_en <=  awvalid and s_axi_awready;
awaddr   <=  data_out(29 downto 8) & X"00" when awvalid = '1' and s_axi_awready = '1' else
             (others => '0')        	   when reset = '1';

wstrb <= (others => '1');

wvalid_control: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            wr_state <= 0;
            wdata   <= (others => '0');
        else
            case wr_state is
                when 0 =>
                    if awvalid = '1' and s_axi_awready = '1' then
                        wr_state       <= 1;
                        pseudo_address <= data_out(29 downto 0);
                    end if;
                when 1 =>               
                    if s_axi_wready = '1' then
                        wvalid <= '1';
                        if cnt_block < number_of_block - 1 then
                            cnt_block      <= cnt_block + 1;
                            wdata          <= data_zero(255 downto 30) & pseudo_address + 1;
                            pseudo_address <= pseudo_address + 1;
                        else
                            wdata     <= data_zero(255 downto 30) & pseudo_address + 1;
                            cnt_block <= 0;
                            wlast     <= '1';
                            wr_state  <= 2;
                        end if;
                    end if;
                when 2 =>
                    if s_axi_wready = '1' then
                        wvalid  <= '0';
                        wlast   <= '0';
                        wr_state<= 0;
                            if cnt_num_addr < 9 then -- ghi 10 lan
--                            if cnt_num_addr < 999 then -- ghi 1,000 lan
--                            if cnt_num_addr < 999999 then -- ghi 1,000,000 lan
--                            if cnt_num_addr < 9999999 then -- ghi 10,000,000 lan
                                cnt_num_addr <= cnt_num_addr + 1;                           
                            else
                                wr_state <= 3;
                            end if;
                    end if;
                when 3 =>
                     if ctr_state = 1 then
                            wr_state    <= 0;
                     end if;                       
                when others =>
            end case;    
        end if;
    end if;
end process;


arvalid_control: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            ar_state    <= 0;
            count_r     <= (others => '0');
        else
            case ar_state is
                when 0 =>
                if init_calib_complete_0 = '1' then
                    if wr_state = 3 then
                        ar_state      <=  1;
                    end if;
                end if;
                when 1 =>
                        ar_state    <= 2;
                        arvalid     <= '1'; 
                when 2 =>
                     if s_axi_arready = '1' then
                        arvalid     <= '0';
                        ar_state    <= 3;
                     end if;
                     
                when 3 =>
                        if count_r < 9 then -- doc 10 lan
--                        if count_r < 999 then -- doc 1,000 lan
--                        if count_r < 999999 then -- doc 1,000,000 lan
--                        if count_r < 9999999 then -- doc 10,000,000 lan
                           count_r <= count_r + 1;
                           ar_state<= 0;
                        else
                           ar_state <= 4;
                           s_reset1 <= '1';
                           count_r  <= (others => '0');
                        end if;
                        
                when 4      =>
                           s_reset1 <= '0';              
                           if ctr_repeat = '1' then
                            ar_state <= 0;
                           else
                            ar_state <= 4;
                           end if;
                
                when others =>
            end case;
        end if;
    end if;
end process;

s_crc_en1   <=  arvalid and s_axi_arready;
araddr      <=  data_out1(29 downto 8) & X"00" when arvalid = '1' and s_axi_arready = '1' else
           		(others => '0')        when reset = '1';
		   


compare_value : process(clk)
begin
    if rising_edge(clk) then
        if s_axi_rvalid = '1' then
            if cnt = 0 then
                if s_axi_rdata(29 downto 0)  /= data_out2(29 downto 0) + 1 or s_axi_rdata(255 downto 30) /= 0 then
                    check1	<= '1';
                end if;
                cnt <= 1;
            elsif cnt = 1 then
                if s_axi_rdata(29 downto 0)  /= data_out2(29 downto 0) + 2 or s_axi_rdata(255 downto 30) /= 0 then
                    check1 <= '1';
                end if;
                cnt <= 2;
            elsif cnt = 2 then
                if s_axi_rdata(29 downto 0)  /= data_out2(29 downto 0) + 3 or s_axi_rdata(255 downto 30) /= 0 then
                    check1 <= '1';
                end if;
                cnt <= 3;
            elsif cnt = 3 then
                if s_axi_rdata(29 downto 0) /= data_out2(29 downto 0) + 4 or s_axi_rdata(255 downto 30) /= 0 then
                    check <= check + 1;
                end if;
				check1	  <= '0';
                cnt 	  <= 0;
            end if;
        end if;
    end if;
end process;

s_crc_en2   <= (s_axi_rvalid and s_axi_rlast); 
cnt_block_rdata_pr: process(clk)
begin
    if rising_edge(clk) then
        if cnt_rlast < 10 then  -- doc 10 - lan sau cmt vao troi
--        if cnt_rlast < 1000 then  -- doc 1,000 
--        if cnt_rlast < 1000000 then  -- doc 1,000,000 
--        if cnt_rlast < 10_000_000 then  -- doc 10,000,000 
            if s_axi_rvalid = '1' and s_axi_rlast = '1' then
            cnt_rlast <= cnt_rlast + 1;
            end if;
        else
           cnt_rlast <= 0;
        end if;
    end if;
end process;

s_reset1_pr: process(clk)
begin
    if rising_edge(clk) then
        if cnt_rlast = 10 then    -- doc 10 lan thi count 10 cai last
--        if cnt_rlast = 1000 then    -- doc 1,000
--        if cnt_rlast = 1000000 then    -- doc 1,000,000
--        if cnt_rlast = 10_000_000 then    -- doc 10,000,000
            s_reset2    <= '1';
        else
            s_reset2    <= '0';
        end if;
    end if;
 end process;
 
 number_read_pr: process(clk)
 begin
    if rising_edge(clk) then
        if s_reset2 = '1' then
            number_read <= number_read + 1;
        end if;
    end if;
 end process;
 
ctr_repeat <= s_reset2 when number_read < 4 else -- 4 lan lap lai viec doc 10 lan/ 1000 lan/1 trieu lan
--ctr_repeat <= s_reset2 when number_read < 19 else -- 19 lan lap lai viec doc 10 lan/ 1000 lan/1 trieu lan
               '0';
reset1 <= s_reset1 or reset;
reset2 <= s_reset2 or reset;
--reset2 <= reset; -- ko reset: doc dung 1 thay vi 5

S_AXI_awlock    <= '0';
S_AXI_awprot    <= (others => '0');
S_AXI_awcache   <= (others => '0');
S_AXI_awqos     <= (others => '0');
S_AXI_awburst   <= "01";
S_AXI_awsize    <= "110";
S_AXI_awid      <= x"0";
S_AXI_awvalid   <= awvalid;
S_AXI_awaddr    <= awaddr;
S_AXI_awlen     <= x"03";
S_AXI_wvalid    <= wvalid;
S_AXI_wlast     <= wlast;
S_AXI_wstrb     <= wstrb;
S_AXI_wdata     <= wdata;
S_AXI_bready    <= bready;

S_AXI_arid      <= x"0";
S_AXI_araddr    <= araddr;
S_AXI_arlen     <= x"03";
S_AXI_arsize    <= "110";
S_AXI_arburst   <= "01";
S_AXI_arlock    <= '0';
S_AXI_arcache   <= (others => '0');
S_AXI_arprot    <= (others => '0');
S_AXI_arqos     <= (others => '0');
S_AXI_arvalid   <= arvalid;
S_AXI_rready    <= rready;

S_AXI_0_araddr          <= S_AXI_araddr         ;
S_AXI_0_arburst         <= S_AXI_arburst        ;
S_AXI_0_arcache         <= S_AXI_arcache        ;
S_AXI_0_arid            <= S_AXI_arid           ;
S_AXI_0_arlen           <= S_AXI_arlen          ;
S_AXI_0_arlock          <= S_AXI_arlock         ;
S_AXI_0_arprot          <= S_AXI_arprot         ;
S_AXI_0_arqos           <= S_AXI_arqos          ;
S_AXI_arready           <= S_AXI_0_arready      ;
S_AXI_0_arsize          <= S_AXI_arsize         ;
S_AXI_0_arvalid         <= S_AXI_arvalid        ;
S_AXI_0_awaddr          <= S_AXI_awaddr         ;
S_AXI_0_awburst         <= S_AXI_awburst        ;
S_AXI_0_awcache         <= S_AXI_awcache        ;
S_AXI_0_awid            <= S_AXI_awid           ;
S_AXI_0_awlen           <= S_AXI_awlen          ;
S_AXI_0_awlock          <= S_AXI_awlock         ;
S_AXI_0_awprot          <= S_AXI_awprot         ;
S_AXI_0_awqos           <= S_AXI_awqos          ;
S_AXI_awready           <= S_AXI_0_awready      ;
S_AXI_0_awsize          <= S_AXI_awsize         ;
S_AXI_0_awvalid         <= S_AXI_awvalid        ;
S_AXI_bid               <= S_AXI_0_bid          ;
S_AXI_0_bready          <= S_AXI_bready         ;
S_AXI_bresp             <= S_AXI_0_bresp        ;
S_AXI_bvalid            <= S_AXI_0_bvalid       ;
S_AXI_rdata             <= S_AXI_0_rdata        ;
S_AXI_rid               <= S_AXI_0_rid          ;
S_AXI_rlast             <= S_AXI_0_rlast        ;
S_AXI_0_rready          <= S_AXI_rready         ;
S_AXI_rresp             <= S_AXI_0_rresp        ;
S_AXI_rvalid            <= S_AXI_0_rvalid       ;
S_AXI_0_wdata           <= S_AXI_wdata          ;
S_AXI_0_wlast           <= S_AXI_wlast          ;
S_AXI_wready            <= S_AXI_0_wready       ;
S_AXI_0_wstrb           <= S_AXI_wstrb          ;
S_AXI_0_wvalid          <= S_AXI_wvalid         ;
init_calib_complete     <= init_calib_complete_0;
reset_rtl               <= reset_rtl_0          ;
ui_clk                  <= ui_clk_0             ;



end Behavioral;

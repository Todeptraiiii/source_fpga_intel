library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ddr3 is
port 
	(
	-- Reset & Clock
	fpga_resetn			:	in STD_LOGIC; 
	c10_clk50m			:	in STD_LOGIC;  
	 
	-- User IOs
	user_pb				:	in 	STD_LOGIC_VECTOR(2 DOWNTO 0);
	user_led			:	out STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- Emif interface 
	refclk_emif_p		:	in	STD_LOGIC;
	
	ddr3_ckp			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0); 
	ddr3_ckn 			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0);
	ddr3_d   			:	inout STD_LOGIC_VECTOR(39 DOWNTO 0);
	ddr3_dm  			:	out	STD_LOGIC_VECTOR(4 DOWNTO 0);
	ddr3_dqsn			:	inout STD_LOGIC_VECTOR(4 DOWNTO 0);
	ddr3_dqsp			:	inout STD_LOGIC_VECTOR(4 DOWNTO 0);
	ddr3_ba  			:	out	STD_LOGIC_VECTOR(2 DOWNTO 0);
	ddr3_casn			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0);
	ddr3_rasn			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0);
	ddr3_a				:	out	STD_LOGIC_VECTOR(14 DOWNTO 0);
	ddr3_cke 			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0);
	ddr3_odt 			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0);
	ddr3_csn			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0); 
	ddr3_wen			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0); 
    ddr3_rstn			:	out	STD_LOGIC_VECTOR(0 DOWNTO 0);
	ddr3_rzq 			:	in	STD_LOGIC;
	
	-- uart
	
	uart_tx				:	out	STD_LOGIC;
	uart_rx				:	in	STD_LOGIC
	
	
	);

end entity ddr3;

architecture rtl of ddr3 is

component ed_synth is
	port (
	
		--
		c10_clk50m							: in	std_logic;
		uart_tx								: out	std_logic;
		uart_rx								: in	std_logic;
		--
		
		emif_c10_0_pll_ref_clk_clk          : in    std_logic                     := '0';             -- emif_c10_0_pll_ref_clk.clk
		emif_c10_0_oct_oct_rzqin            : in    std_logic                     := '0';             --         emif_c10_0_oct.oct_rzqin
		emif_c10_0_mem_mem_ck               : out   std_logic_vector(0 downto 0);                     --         emif_c10_0_mem.mem_ck
		emif_c10_0_mem_mem_ck_n             : out   std_logic_vector(0 downto 0);                     --                       .mem_ck_n
		emif_c10_0_mem_mem_a                : out   std_logic_vector(14 downto 0);                    --                       .mem_a
		emif_c10_0_mem_mem_ba               : out   std_logic_vector(2 downto 0);                     --                       .mem_ba
		emif_c10_0_mem_mem_cke              : out   std_logic_vector(0 downto 0);                     --                       .mem_cke
		emif_c10_0_mem_mem_cs_n             : out   std_logic_vector(0 downto 0);                     --                       .mem_cs_n
		emif_c10_0_mem_mem_odt              : out   std_logic_vector(0 downto 0);                     --                       .mem_odt
		emif_c10_0_mem_mem_reset_n          : out   std_logic_vector(0 downto 0);                     --                       .mem_reset_n
		emif_c10_0_mem_mem_we_n             : out   std_logic_vector(0 downto 0);                     --                       .mem_we_n
		emif_c10_0_mem_mem_ras_n            : out   std_logic_vector(0 downto 0);                     --                       .mem_ras_n
		emif_c10_0_mem_mem_cas_n            : out   std_logic_vector(0 downto 0);                     --                       .mem_cas_n
		emif_c10_0_mem_mem_dqs              : inout std_logic_vector(4 downto 0)  := (others => '0'); --                       .mem_dqs
		emif_c10_0_mem_mem_dqs_n            : inout std_logic_vector(4 downto 0)  := (others => '0'); --                       .mem_dqs_n
		emif_c10_0_mem_mem_dq               : inout std_logic_vector(39 downto 0) := (others => '0'); --                       .mem_dq
		emif_c10_0_mem_mem_dm               : out   std_logic_vector(4 downto 0);                     --                       .mem_dm
		emif_c10_0_status_local_cal_success : out   std_logic;                                        --      emif_c10_0_status.local_cal_success
		emif_c10_0_status_local_cal_fail    : out   std_logic;                                        --                       .local_cal_fail
		global_reset_reset_n                : in    std_logic                     := '0';             --           global_reset.reset_n
		emif_c10_0_tg_0_traffic_gen_pass    : out   std_logic;                                        --        emif_c10_0_tg_0.traffic_gen_pass
		emif_c10_0_tg_0_traffic_gen_fail    : out   std_logic;                                        --                       .traffic_gen_fail
		emif_c10_0_tg_0_traffic_gen_timeout : out   std_logic                                         --                       .traffic_gen_timeout
	);
end component ed_synth;

-- 
signal heart_beat_cnt : std_logic_vector(26 downto 0);

--

begin

	--

	process(c10_clk50m)
	begin
		if rising_edge(c10_clk50m) then
			if fpga_resetn = '0' then
				heart_beat_cnt <=	(others => '0');
			else
				heart_beat_cnt <= heart_beat_cnt + 1;
			end if;
		end if;
	end process;

	--
	
	
	u0_ed_synth_inst: ed_synth
	port map
		(
		uart_rx								=>	uart_rx,
		uart_tx								=>	uart_tx,
		c10_clk50m							=>	c10_clk50m,
		
		emif_c10_0_pll_ref_clk_clk          =>	refclk_emif_p,		
		emif_c10_0_oct_oct_rzqin            =>	ddr3_rzq,	
		emif_c10_0_mem_mem_ck               =>	ddr3_ckp,	
		emif_c10_0_mem_mem_ck_n             =>	ddr3_ckn,
		emif_c10_0_mem_mem_a                =>	ddr3_a,
		emif_c10_0_mem_mem_ba               =>	ddr3_ba,
		emif_c10_0_mem_mem_cke              =>	ddr3_cke,
		emif_c10_0_mem_mem_cs_n             =>	ddr3_csn,
		emif_c10_0_mem_mem_odt              =>	ddr3_odt,
		emif_c10_0_mem_mem_reset_n          =>	ddr3_rstn,
		emif_c10_0_mem_mem_we_n             =>	ddr3_wen,
		emif_c10_0_mem_mem_ras_n            =>	ddr3_rasn,
		emif_c10_0_mem_mem_cas_n            =>	ddr3_casn,
		emif_c10_0_mem_mem_dqs              =>	ddr3_dqsp,
		emif_c10_0_mem_mem_dqs_n            =>	ddr3_dqsn,
		emif_c10_0_mem_mem_dq               =>	ddr3_d,
		emif_c10_0_mem_mem_dm               =>	ddr3_dm,
		emif_c10_0_status_local_cal_success =>	open,
		emif_c10_0_status_local_cal_fail    =>	open,
		global_reset_reset_n                =>	user_pb(2),
		emif_c10_0_tg_0_traffic_gen_pass    =>	open,
		emif_c10_0_tg_0_traffic_gen_fail    =>	open,
		emif_c10_0_tg_0_traffic_gen_timeout =>	open
			
		);
		
		user_led(2)	<=	heart_beat_cnt(26);
		user_led(3)	<=	heart_beat_cnt(26);	

end architecture rtl; -- of ddr3
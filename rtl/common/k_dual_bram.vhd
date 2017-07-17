----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/11/2017 11:39:54 AM
-- Design Name: 
-- Module Name: k_dual_bram - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity k_dual_bram is
    Port ( 
    -- SYS CON
    clk_i            : in std_logic;
    rst_i            : in std_logic;
    
    -- Wishbone Slave in
    wba_adr_i            : in std_logic_vector(32-1 downto 0);
    wba_dat_i            : in std_logic_vector(64-1 downto 0);
    wba_we_i            : in std_logic;
    wba_stb_i            : in std_logic;
    wba_cyc_i            : in std_logic; 
    
    -- Wishbone Slave out
    wba_dat_o            : out std_logic_vector(64-1 downto 0);
    wba_ack_o            : out std_logic;
           
    -- Wishbone Slave in
    wbb_adr_i            : in std_logic_vector(32-1 downto 0);
    wbb_dat_i            : in std_logic_vector(64-1 downto 0);
    wbb_we_i            : in std_logic;
    wbb_stb_i            : in std_logic;
    wbb_cyc_i            : in std_logic; 
    
    -- Wishbone Slave out
    wbb_dat_o            : out std_logic_vector(64-1 downto 0);
    wbb_ack_o            : out std_logic 
           
           );
end k_dual_bram;

architecture Behavioral of k_dual_bram is
    constant BLOCK_ADDR_WIDTH_C : integer := 13;
    constant DATA_WIDTH_C : integer := 64;
    constant BLOCK_ROW_C : integer := 16;
    constant BLOCK_COL_EXP_C : integer := 3;
    constant BLOCK_COL_C : integer := 2**BLOCK_COL_EXP_C;
    constant BLOCK_DATA_WIDTH_C : integer := DATA_WIDTH_C/BLOCK_ROW_C;
    
    signal WEA_S : std_logic_vector(0 downto 0);
    signal WEB_S : std_logic_vector(0 downto 0);
    
    signal selecta_s : std_logic_vector (BLOCK_COL_EXP_C-1 downto 0);
    signal selectb_s : std_logic_vector (BLOCK_COL_EXP_C-1 downto 0);
    
    type ram_data_bus is array (BLOCK_COL_C-1 downto 0) of std_logic_vector(DATA_WIDTH_C-1 downto 0);
    signal wba_dat_a : ram_data_bus;
    signal wbb_dat_a : ram_data_bus;
    
    signal wba_cyc_s            : std_logic_vector(BLOCK_COL_C-1 downto 0);
    signal wbb_cyc_s            : std_logic_vector(BLOCK_COL_C-1 downto 0);
begin

	bram: process (clk_i, rst_i)
	begin
		if (rst_i ='1') then
			wba_ack_o <= '0';
            wbb_ack_o <= '0';
		elsif (clk_i'event and clk_i = '1') then
		    
			if (wba_stb_i = '1' and wba_cyc_i = '1') then
				wba_ack_o <= '1';
			else
				wba_ack_o <= '0';
			end if;
			
			if (wbb_stb_i = '1' and wbb_cyc_i = '1') then
                wbb_ack_o <= '1';
            else
                wbb_ack_o <= '0';
            end if;			
			
		end if;
	end process bram;
	
	process(clk_i)
    begin
       if (clk_i'event and clk_i = '1') then
           selecta_s <= wba_adr_i(BLOCK_ADDR_WIDTH_C+BLOCK_COL_EXP_C-1 downto BLOCK_ADDR_WIDTH_C);
           selectb_s <= wbb_adr_i(BLOCK_ADDR_WIDTH_C+BLOCK_COL_EXP_C-1 downto BLOCK_ADDR_WIDTH_C);
       end if;
    end process;

    WEA_S <= (others => '1') when wba_we_i = '1' else
             (others => '0');
    WEB_S <= (others => '1') when wbb_we_i = '1' else
             (others => '0');    
             
   wba_dat_o <= wba_dat_a(conv_integer(selecta_s));
   wbb_dat_o <= wbb_dat_a(conv_integer(selectb_s));
   
   -- BRAM_TDP_MACRO: True Dual Port RAM
   --                 Kintex-7
   -- Xilinx HDL Language Template, version 2016.2

   -- Note -  This Unimacro model assumes the port directions to be "downto". 
   --         Simulation of this model with "to" in the port directions could lead to erroneous results.

   --------------------------------------------------------------------------
   -- DATA_WIDTH_A/B | BRAM_SIZE | RAM Depth | ADDRA/B Width | WEA/B Width --
   -- ===============|===========|===========|===============|=============--
   --     19-36      |  "36Kb"   |    1024   |    10-bit     |    4-bit    --
   --     10-18      |  "36Kb"   |    2048   |    11-bit     |    2-bit    --
   --     10-18      |  "18Kb"   |    1024   |    10-bit     |    2-bit    --
   --      5-9       |  "36Kb"   |    4096   |    12-bit     |    1-bit    --
   --      5-9       |  "18Kb"   |    2048   |    11-bit     |    1-bit    --
   --      3-4       |  "36Kb"   |    8192   |    13-bit     |    1-bit    --
   --      3-4       |  "18Kb"   |    4096   |    12-bit     |    1-bit    --
   --        2       |  "36Kb"   |   16384   |    14-bit     |    1-bit    --
   --        2       |  "18Kb"   |    8192   |    13-bit     |    1-bit    --
   --        1       |  "36Kb"   |   32768   |    15-bit     |    1-bit    --
   --        1       |  "18Kb"   |   16384   |    14-bit     |    1-bit    --
   --------------------------------------------------------------------------
   gen_bram_col:for j in 0 to BLOCK_COL_C-1 generate
   
   	wba_cyc_s(j)       <= wba_cyc_i when wba_adr_i(BLOCK_ADDR_WIDTH_C+BLOCK_COL_EXP_C-1 downto BLOCK_ADDR_WIDTH_C) = std_logic_vector(to_unsigned(j,BLOCK_COL_EXP_C))  
                                    else '0';
   
   	wbb_cyc_s(j)       <= wbb_cyc_i when wbb_adr_i(BLOCK_ADDR_WIDTH_C+BLOCK_COL_EXP_C-1 downto BLOCK_ADDR_WIDTH_C) = std_logic_vector(to_unsigned(j,BLOCK_COL_EXP_C))  
                                    else '0';   
   
   gen_bram_row:for i in 0 to BLOCK_ROW_C-1 generate
   
   
   BRAM_TDP_MACRO_inst : BRAM_TDP_MACRO
   generic map (
      BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "7SERIES", -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES", "SPARTAN6" 
      DOA_REG => 0, -- Optional port A output register (0 or 1)
      DOB_REG => 0, -- Optional port B output register (0 or 1)
      INIT_A => X"000000000", -- Initial values on A output port
      INIT_B => X"000000000", -- Initial values on B output port
      INIT_FILE => "NONE",
      READ_WIDTH_A => BLOCK_DATA_WIDTH_C,   -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH_B => BLOCK_DATA_WIDTH_C,   -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      SIM_COLLISION_CHECK => "ALL", -- Collision check enable "ALL", "WARNING_ONLY", 
                                    -- "GENERATE_X_ONLY" or "NONE" 
      SRVAL_A => X"000000000",   -- Set/Reset value for A port output
      SRVAL_B => X"000000000",   -- Set/Reset value for B port output
      WRITE_MODE_A => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE" 
      WRITE_MODE_B => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE" 
      WRITE_WIDTH_A => BLOCK_DATA_WIDTH_C, -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      WRITE_WIDTH_B => BLOCK_DATA_WIDTH_C, -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      -- The following INIT_xx declarations specify the initial contents of the RAM
      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
      
      -- The next set of INIT_xx are valid when configured as 36Kb
      INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
      
      -- The next set of INITP_xx are for the parity bits
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      
      -- The next set of INIT_xx are valid when configured as 36Kb
      INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DOA => wba_dat_a(j)(BLOCK_DATA_WIDTH_C-1+BLOCK_DATA_WIDTH_C*i downto 0+BLOCK_DATA_WIDTH_C*i),       -- Output port-A data, width defined by READ_WIDTH_A parameter
      DOB => wbb_dat_a(j)(BLOCK_DATA_WIDTH_C-1+BLOCK_DATA_WIDTH_C*i downto 0+BLOCK_DATA_WIDTH_C*i),       -- Output port-B data, width defined by READ_WIDTH_B parameter
      ADDRA => wba_adr_i(BLOCK_ADDR_WIDTH_C-1 downto 0),   -- Input port-A address, width defined by Port A depth
      ADDRB => wbb_adr_i(BLOCK_ADDR_WIDTH_C-1 downto 0),   -- Input port-B address, width defined by Port B depth
      CLKA => clk_i,     -- 1-bit input port-A clock
      CLKB => clk_i,     -- 1-bit input port-B clock
      DIA => wba_dat_i(BLOCK_DATA_WIDTH_C-1+BLOCK_DATA_WIDTH_C*i downto 0+BLOCK_DATA_WIDTH_C*i),       -- Input port-A data, width defined by WRITE_WIDTH_A parameter
      DIB => wbb_dat_i(BLOCK_DATA_WIDTH_C-1+BLOCK_DATA_WIDTH_C*i downto 0+BLOCK_DATA_WIDTH_C*i),       -- Input port-B data, width defined by WRITE_WIDTH_B parameter
      ENA => wba_cyc_s(j),       -- 1-bit input port-A enable
      ENB => wbb_cyc_s(j),       -- 1-bit input port-B enable
      REGCEA => wba_stb_i, -- 1-bit input port-A output register enable
      REGCEB => wbb_stb_i, -- 1-bit input port-B output register enable
      RSTA => rst_i,     -- 1-bit input port-A reset
      RSTB => rst_i,     -- 1-bit input port-B reset
      WEA => WEA_S,       -- Input port-A write enable, width defined by Port A depth
      WEB => WEB_S        -- Input port-B write enable, width defined by Port B depth
   );
   
   end generate;
   end generate;
-- End of BRAM_TDP_MACRO_inst instantiation



end Behavioral;

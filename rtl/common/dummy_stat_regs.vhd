---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Dummy status registers
---------------------------------------------------------------------------------------
-- File           : ../../GN4124_core/hdl/gn4124core/design/rtl/dummy_stat_regs.vhd
-- Author         : auto-generated by wbgen2 from ../../GN4124_core/hdl/gn4124core/design/wb_gen/dummy_stat_regs_wb_slave.wb
-- Created        : Wed Nov 10 14:42:59 2010
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE ../../GN4124_core/hdl/gn4124core/design/wb_gen/dummy_stat_regs_wb_slave.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dummy_stat_regs_wb_slave is
  port (
    rst_n_i                                  : in     std_logic;
    wb_clk_i                                 : in     std_logic;
    wb_addr_i                                : in     std_logic_vector(1 downto 0);
    wb_data_i                                : in     std_logic_vector(31 downto 0);
    wb_data_o                                : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
-- Port for std_logic_vector field: 'Dummy register 1' in reg: 'DUMMY_1'
    dummy_stat_reg_1_i                       : in     std_logic_vector(31 downto 0);
-- Port for std_logic_vector field: 'Dummy register 2' in reg: 'DUMMY_2'
    dummy_stat_reg_2_i                       : in     std_logic_vector(31 downto 0);
-- Port for std_logic_vector field: 'Dummy register 3' in reg: 'DUMMY_3'
    dummy_stat_reg_3_i                       : in     std_logic_vector(31 downto 0);
-- Port for std_logic_vector field: 'Dummy register for switch status' in reg: 'DUMMY_SWITCH'
    dummy_stat_reg_switch_i                  : in     std_logic_vector(31 downto 0)
  );
end dummy_stat_regs_wb_slave;

architecture syn of dummy_stat_regs_wb_slave is

signal ack_sreg                                 : std_logic_vector(9 downto 0);
signal rddata_reg                               : std_logic_vector(31 downto 0);
signal wrdata_reg                               : std_logic_vector(31 downto 0);
signal bwsel_reg                                : std_logic_vector(3 downto 0);
signal rwaddr_reg                               : std_logic_vector(1 downto 0);
signal ack_in_progress                          : std_logic      ;
signal wr_int                                   : std_logic      ;
signal rd_int                                   : std_logic      ;
signal bus_clock_int                            : std_logic      ;
signal allones                                  : std_logic_vector(31 downto 0);
signal allzeros                                 : std_logic_vector(31 downto 0);

begin
-- Some internal signals assignments. For (foreseen) compatibility with other bus standards.
  wrdata_reg <= wb_data_i;
  bwsel_reg <= wb_sel_i;
  bus_clock_int <= wb_clk_i;
  rd_int <= wb_cyc_i and (wb_stb_i and (not wb_we_i));
  wr_int <= wb_cyc_i and (wb_stb_i and wb_we_i);
  allones <= (others => '1');
  allzeros <= (others => '0');
-- 
-- Main register bank access process.
  process (bus_clock_int, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ack_sreg <= "0000000000";
      ack_in_progress <= '0';
      rddata_reg <= "00000000000000000000000000000000";
    elsif rising_edge(bus_clock_int) then
-- advance the ACK generator shift register
      ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
      ack_sreg(9) <= '0';
      if (ack_in_progress = '1') then
        if (ack_sreg(0) = '1') then
          ack_in_progress <= '0';
        else
        end if;
      else
        if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
          case rwaddr_reg(1 downto 0) is
          when "00" => 
            if (wb_we_i = '1') then
            else
              rddata_reg(31 downto 0) <= dummy_stat_reg_1_i;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01" => 
            if (wb_we_i = '1') then
            else
              rddata_reg(31 downto 0) <= dummy_stat_reg_2_i;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "10" => 
            if (wb_we_i = '1') then
            else
              rddata_reg(31 downto 0) <= dummy_stat_reg_3_i;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "11" => 
            if (wb_we_i = '1') then
            else
              rddata_reg(31 downto 0) <= dummy_stat_reg_switch_i;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when others =>
-- prevent the slave from hanging the bus on invalid address
            ack_in_progress <= '1';
            ack_sreg(0) <= '1';
          end case;
        end if;
      end if;
    end if;
  end process;
  
  
-- Drive the data output bus
  wb_data_o <= rddata_reg;
-- Dummy register 1
-- Dummy register 2
-- Dummy register 3
-- Dummy register for switch status
  rwaddr_reg <= wb_addr_i;
-- ACK signal generation. Just pass the LSB of ACK counter.
  wb_ack_o <= ack_sreg(0);
end syn;

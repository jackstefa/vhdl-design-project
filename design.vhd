library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
        );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
    Port ( 
       i_clk : in STD_LOGIC;
       i_rst : in STD_LOGIC;
       i_data : in STD_LOGIC_VECTOR (7 downto 0);
       o_data : out STD_LOGIC_VECTOR (7 downto 0);
       rdata_load, rdigit_load, rlength_load, rcnt_load, r1_load, r2_load, r3_load, rout_load, rout_sel : in STD_LOGIC;
       rdigit_sel, rlength_sel, rcnt_sel, r1_sel, r2_sel, r3_sel, data_sel : in STD_LOGIC;
       str_done : out STD_LOGIC;
       str_cnt : out STD_LOGIC_VECTOR (15 downto 0);
       o_end : out STD_LOGIC
       );
end component;

signal rdata_load, rdigit_load, rlength_load, rcnt_load, r1_load, r2_load, r3_load, rout_load, rout_sel : STD_LOGIC;
signal rdigit_sel, rlength_sel, rcnt_sel, r1_sel, r2_sel, r3_sel, data_sel : STD_LOGIC;
signal str_done : STD_LOGIC;
signal str_cnt : STD_LOGIC_VECTOR (15 downto 0);
signal o_end : STD_LOGIC;
type S is (WAIT_START, ENABLE_MEM, INIT, CHECK_LENGTH, WAIT_READ_ADDRESS, SET_READ_ADDRESS, LOAD_DATA, CHOOSE_DIGIT, 
            LOAD_R123, CALC, WRITE_DATA1, WRITE_DATA2, DONE);
signal cur_state, next_state : S;

begin
    DATAPATH0: datapath port map(
       i_clk,
       i_rst,
       i_data, 
       o_data, 
       rdata_load, rdigit_load, rlength_load, rcnt_load, r1_load, r2_load, r3_load, rout_load, rout_sel, 
       rdigit_sel, rlength_sel, rcnt_sel, r1_sel, r2_sel, r3_sel, data_sel, 
       str_done,
       str_cnt,
       o_end
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= WAIT_START;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
-----------FUNZIONE DI STATO PROSSIMO-------------

    process(cur_state, i_start, o_end, str_done)
    begin
        next_state <= cur_state;
        case cur_state is
            when WAIT_START =>
                if i_start = '1' then
                    next_state <= ENABLE_MEM;
                end if;
            when ENABLE_MEM =>
                next_state <= INIT;
            when INIT =>
                next_state <= CHECK_LENGTH;
            when CHECK_LENGTH =>
                if o_end = '1' then
                    next_state <= DONE;
                else
                    next_state <= WAIT_READ_ADDRESS;
                end if;
            when WAIT_READ_ADDRESS =>
                next_state <= SET_READ_ADDRESS;
            when SET_READ_ADDRESS =>
                next_state <= LOAD_DATA;
            when LOAD_DATA =>
                next_state <= CHOOSE_DIGIT;
            when CHOOSE_DIGIT =>
                next_state <= LOAD_R123;
            when LOAD_R123 =>
                next_state <= CALC;
            when CALC =>
                if str_done = '1' then
                    next_state <= WRITE_DATA1;
                else
                    next_state <= CHOOSE_DIGIT;
                end if;
            when WRITE_DATA1 =>
                next_state <= WRITE_DATA2;
            when WRITE_DATA2 =>
                next_state <= CHECK_LENGTH;
            when DONE =>
                next_state <= WAIT_START;
        end case;
    end process;
    
    
------------FUNZIONE DI USCITA----------------
    
    process(cur_state, str_cnt)
    begin
        o_address <= "0000000000000000";
        rdata_load <= '0';
        rdigit_load <= '0'; 
        rlength_load <= '0';
        rcnt_load <= '0';
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        rout_load <= '0';
        rout_sel <= '0';
        rdigit_sel <= '0';
        rlength_sel <= '0';
        rcnt_sel <= '0';
        r1_sel <= '0';
        r2_sel <= '0';
        r3_sel <= '0';
        data_sel <= '0';
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        
        case cur_state is
            when WAIT_START =>
            when ENABLE_MEM =>
                o_en <= '1';
            when INIT =>
                o_en <= '1';
                o_address <= "0000000000000000";
                rcnt_sel <= '0';
                rcnt_load <= '1';
                rlength_sel <= '0';
                rlength_load <= '1';
                r1_sel <= '0';
                r1_load <= '1';
                r2_sel <= '0';
                r2_load <= '1';
                r3_sel <= '0';
                r3_load <= '1';
            when CHECK_LENGTH =>
                rdigit_sel <= '0';
                rdigit_load <= '1';
                rout_sel <= '0';
                rout_load <= '1';
            when WAIT_READ_ADDRESS =>
                rcnt_sel <= '1';
                rcnt_load <= '1'; 
            when SET_READ_ADDRESS =>
                o_en <= '1';
                o_address <= str_cnt;
            when LOAD_DATA =>
                rdata_load <= '1';
            when CHOOSE_DIGIT =>
                rdigit_sel <= '1';
                rdigit_load <= '1';
            when LOAD_R123 =>
                r1_load <= '1';
                r2_load <= '1';
                r3_load <= '1';
                r1_sel <= '1';
                r2_sel <= '1';
                r3_sel <= '1';
            when CALC =>
                rout_load <= '1';
                rout_sel <= '1';
            when WRITE_DATA1 =>
                o_en <= '1';
                o_we <= '1';
                o_address <= std_logic_vector((shift_left(unsigned(str_cnt), 1)) + 1000 - 2);
                data_sel <= '0';
            when WRITE_DATA2 =>
                o_en <= '1';
                o_we <= '1';
                o_address <= std_logic_vector((shift_left(unsigned(str_cnt), 1)) + 1000 - 1);
                data_sel <= '1';
                rlength_load <= '1';
                rlength_sel <= '1';
            when DONE =>
                o_done <= '1';
        end case;
    end process;

end Behavioral;


---------------------------DATAPATH-------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           rdata_load, rdigit_load, rlength_load, rcnt_load, r1_load, r2_load, r3_load, rout_load, rout_sel : in STD_LOGIC;
           rdigit_sel, rlength_sel, rcnt_sel, r1_sel, r2_sel, r3_sel, data_sel : in STD_LOGIC;
           str_done : out STD_LOGIC;
           str_cnt : out STD_LOGIC_VECTOR (15 downto 0);
           o_end : out STD_LOGIC
           );
end datapath;

architecture Behavioral of datapath is

signal rdata_out, rdata_and : STD_LOGIC_VECTOR (7 downto 0);
signal rdigit_mux, rdigit_out, rdigit_sub : STD_LOGIC_VECTOR (3 downto 0);
signal mux_out : STD_LOGIC_VECTOR (7 downto 0);
signal rlength_mux, rlength_out, rlength_sub : STD_LOGIC_VECTOR (7 downto 0);
signal rcnt_mux, rcnt_out, rcnt_add : STD_LOGIC_VECTOR (15 downto 0);
signal ukbit : STD_LOGIC;
signal r1_mux, r1_out, r2_mux, r2_out, r3_mux, r3_out : STD_LOGIC;
signal pk1, pk2 : STD_LOGIC;
signal pk, pk_or: STD_LOGIC_VECTOR (15 downto 0);
signal rout_mux, rout_out : STD_LOGIC_VECTOR (15 downto 0);

begin
    
----------------REGISTRO DATA----------------------- 
    
   --definisco registro rdata
   process(i_clk, i_rst) 
   begin
       if(i_rst = '1') then
           rdata_out <= "00000000";
       elsif i_clk'event and i_clk = '1' then
           if(rdata_load = '1') then
               rdata_out <= i_data;
           end if;
       end if;
   end process;
      
----------------SELEZIONE CIFRA---------------------     
      
   --definisco registro rdigit
   process(i_clk, i_rst) 
   begin
       if(i_rst = '1') then
           rdigit_out <= "XXXX";
       elsif i_clk'event and i_clk = '1' then
           if(rdigit_load = '1') then
               rdigit_out <= rdigit_mux;
           end if;
       end if;
   end process;

   --definisco multiplexer per rdigit
   with rdigit_sel select
       rdigit_mux <= "1000" when '0',
                     rdigit_sub when '1',
                     "XXXX" when others;
       
   --definisco decremento di rdigit
   rdigit_sub <= std_logic_vector(unsigned(rdigit_out) - "0001");
   
   --definisco segnale di fine stringa
   str_done <= '1' when (rdigit_out = "0000") else '0';
   
      
   --definisco multiplexer per la selezione 
   --della cifra da esaminare
   with rdigit_out select
       mux_out <= "10000000" when "0111",
                  "01000000" when "0110",
                  "00100000" when "0101",
                  "00010000" when "0100",
                  "00001000" when "0011",
                  "00000100" when "0010",
                  "00000010" when "0001",
                  "00000001" when "0000",
                  "XXXXXXXX" when others;
   
   --definisco porta AND per selezionre la cifra Uk
   rdata_and <= mux_out and rdata_out;
   
   --definisco comparatore a !=0 per trovare Uk
   ukbit <= '0' when (rdata_and = "00000000") else '1';
   
----------------CARICAMENTO DEGLI Uk-------------------- 
   
   --definisco registro r1
   process(i_clk, i_rst) 
   begin
       if(i_rst = '1') then
           r1_out <= '0';
       elsif i_clk'event and i_clk = '1' then
           if(r1_load = '1') then
               r1_out <= r1_mux;
           end if;
       end if;
   end process;
   
   --definisco multiplexer per r1
   with r1_sel select
       r1_mux <= '0' when '0',
                 ukbit when '1',
                 'X' when others;
                     
                     
   
   --definisco registro r2
    process(i_clk, i_rst) 
     begin
         if(i_rst = '1') then
             r2_out <= '0';
         elsif i_clk'event and i_clk = '1' then
             if(r2_load = '1') then
                 r2_out <= r2_mux;
             end if;
         end if;
     end process;
     
     --definisco multiplexer per r2
     with r2_sel select
        r2_mux <= '0' when '0',
                  r1_out when '1',
                  'X' when others;       
                       
                                  
 
   --definisco registro r3
    process(i_clk, i_rst) 
     begin
         if(i_rst = '1') then
             r3_out <= '0';
         elsif i_clk'event and i_clk = '1' then
             if(r3_load = '1') then
                 r3_out <= r3_mux;
             end if;
         end if;
     end process;
     
   --definisco multiplexer per r3
   with r3_sel select
     r3_mux <= '0' when '0',
               r2_out when '1',
               'X' when others;                 

----------------CALCOLO DEL RISULTATO-------------------- 

   --definisco pk1
   pk1 <= r1_out xor r3_out;
   
   --definisco pk2
   pk2 <= r1_out xor r2_out xor r3_out;
   
   --definisco pk finale 
   pk <= "00000000000000" & pk1 & pk2;
   
   --concateno per mezzo di un OR il pk precedente
   pk_or <= std_logic_vector(shift_left(unsigned(rout_out), 2)) or pk;
   
   --definisco il registro rout
    process(i_clk, i_rst) 
    begin
        if(i_rst = '1') then
            rout_out <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(rout_load = '1') then
                rout_out <= rout_mux;
            end if;
        end if;
    end process;
   
   --definisco il multiplexer per rout
     with rout_sel select
     rout_mux <= "0000000000000000" when '0',
                 pk_or when '1',
                 "XXXXXXXXXXXXXXXX" when others; 
                 
   --definisco multiplexer per o_data
     with data_sel select
     o_data <= std_logic_vector(rout_out(15 downto 8)) when '0',
               std_logic_vector(rout_out(7 downto 0)) when '1',
               "XXXXXXXX" when others;


----------------CONTEGGIO DELLE STRINGHE MANCANTI--------------------

    --definisco il registro rlength
    process(i_clk, i_rst) 
    begin
        if(i_rst = '1') then
            rlength_out <= "XXXXXXXX";
        elsif i_clk'event and i_clk = '1' then
            if(rlength_load = '1') then
               rlength_out <= rlength_mux;
            end if;
        end if;
    end process;

    --definisco multiplexer per rlength
    with rlength_sel select
    rlength_mux <= i_data when '0',
                rlength_sub when '1',
                "XXXXXXXX" when others;
                
    --definisco decremento di rlength
    rlength_sub <= std_logic_vector(unsigned(rlength_out) - "00000001");
    
    --definisco comparatore a ==0 per definire o_end
    o_end <= '1' when (rlength_out = "00000000") else '0';
 
----------------CONTEGGIO DELLE STRINGHE LETTE--------------------  


    --definisco il registro rcnt
    process(i_clk, i_rst) 
    begin
        if(i_rst = '1') then
            rcnt_out <= "XXXXXXXXXXXXXXXX";
        elsif i_clk'event and i_clk = '1' then
            if(rcnt_load = '1') then
               rcnt_out <= rcnt_mux;
            end if;
        end if;
    end process;
    
    --definisco multiplexer per rcnt
    with rcnt_sel select
    rcnt_mux <= "0000000000000000" when '0',
                rcnt_add when '1',
                "XXXXXXXXXXXXXXXX" when others;
                
                
    --definisco incremento di rcnt
    rcnt_add <= std_logic_vector(unsigned(rcnt_out) + "0000000000000001");
    
    --definisco segnale di conteggio stringhe lette
    str_cnt <= rcnt_out;
                   
end Behavioral;


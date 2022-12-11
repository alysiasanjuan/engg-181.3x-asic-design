library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alarm_clock is
port(
  clk, rst_n				: in std_logic;
  sw, pb_n					: in std_logic_vector(2 downto 0); 
  led						: out std_logic_vector(17 downto 0);       
  hex0, hex1, hex2, hex3	: out std_logic_vector(6 downto 0)
);
end;

architecture logic of alarm_clock is

----------binary to bcd decoder----------
function to_bcd ( bin : std_logic_vector(7 downto 0) ) return std_logic_vector is
variable i 		: integer:=0;
variable bcd 	: std_logic_vector(11 downto 0) := (others => '0');
variable bint 	: std_logic_vector(7 downto 0) := bin;
begin
	for i in 0 to 7 loop  -- repeating 8 times.
		bcd(11 downto 1) := bcd(10 downto 0);  --shifting the bits.
		bcd(0) := bint(7);
		bint(7 downto 1) := bint(6 downto 0);
		bint(0) :='0';
		if(i < 7 and bcd(3 downto 0) > "0100") then --add 3 if bcd digit is greater than 4.
			bcd(3 downto 0) := bcd(3 downto 0) + "0011";
		end if;
		if(i < 7 and bcd(7 downto 4) > "0100") then --add 3 if bcd digit is greater than 4.
			bcd(7 downto 4) := bcd(7 downto 4) + "0011";
		end if;
		if(i < 7 and bcd(11 downto 8) > "0100") then  --add 3 if bcd digit is greater than 4.
			bcd(11 downto 8) := bcd(11 downto 8) + "0011";
		end if;
	end loop;
	return bcd;
end to_bcd;

----------bcd to seven segment decoder----------
function bcdto7seg(bcd : std_logic_vector(3 downto 0)) 
return std_logic_vector  is        
variable seg_out : std_logic_vector (6 downto 0);
begin
	case bcd is
		when "0000" => seg_out := "1000000";  -- 0 
		when "0001" => seg_out := "1111001";  -- 1
		when "0010" => seg_out := "0100100";  -- 2
		when "0011" => seg_out := "0110000";  -- 3
		when "0100" => seg_out := "0011001";  -- 4
		when "0101" => seg_out := "0010010";  -- 5
		when "0110" => seg_out := "0000010";  -- 6
		when "0111" => seg_out := "1111000";  -- 7
		when "1000" => seg_out := "0000000";  -- 8
		when "1001" => seg_out := "0010000";  -- 9
		when others => seg_out := "1111111";  -- blank 
	end case;
	return seg_out;
end bcdto7seg;

----------binary counter component----------
component binary_counter 
generic
(
	min_count : natural := 0;
	max_count : natural := 255
);
port
(
	clk		: in std_logic;
	reset	: in std_logic;
	enable	: in std_logic;
	q		: out integer range min_count to max_count
);
end component;

signal cnt								: integer range 1 to 50000000;
signal l								: std_logic;
signal bcdh, bcdah, bcdm, bcdam, bcds	: std_logic_vector(3*4-1 downto 0);
signal h, ah, m, am, s					: std_logic_vector(7 downto 0) := (others => '0');
begin

counter50m: binary_counter
generic map (min_count => 1,max_count => 50000000) 
port map (clk, rst_n, '1', cnt  );

----------clock and alarm clock process----------
alarmclock: process (clk)
begin
	if (rising_edge(clk)) then  -- clock_50`event and clock_50='1'
		if (rst_n = '0') then  
			s <= "00000000";
			h<="00000000";
			m<="00000000";
			ah<="00000000";
			am<="00000000";
		else
			if (cnt = 50000000) then
				if sw(2)='1' then -- configure time/alarm
					if sw(1)='0' then
						if pb_n(2)='0' then h<=h+1;    end if; 
						if pb_n(1)='0' then m<=m+1;    end if;
						if pb_n(0)='0' then m<=m-1;    end if;
					else
						if pb_n(2)='0' then ah<=ah+1;    end if;
						if pb_n(1)='0' then am<=am+1;    end if;
						if pb_n(0)='0' then am<=am-1;    end if;
					end if;
				elsif sw(1)='1' then -- alarm mode
					if ah=h and am=m then    
						l<=not l;
					end if;
				else l<='0';
				end if;

				if(h="00010111") then
					h<="00000000";
					m<="00000000";
					s<="00000000";
				elsif m="00111011" then
					h<=h+1;
					m<="00000000";
				elsif (s = "00111011") then 
					m <= m + 1;
					s <= "00000000";
				elsif (m < "00000000") then
					m <= "00111011";
				elsif (h < "00000000") then
					h <= "00010111";
				else	s <= s + 1;
				end if;
			end if;
		end if;
	end if;
end process alarmclock;

led <= "111111111111111111" when l='1' else 
	"000000000000000000";

bcds <= to_bcd(s);
bcdm <= to_bcd(m);
bcdh <= to_bcd(h);
bcdam <= to_bcd(am);
bcdah <= to_bcd(ah);

hex0 <= bcdto7seg(bcds(3 downto 0)) when sw(0)='1' else bcdto7seg(bcdam(3 downto 0)) when sw(1)='1' and sw(2)='1' else bcdto7seg(bcdm(3 downto 0));
hex1 <= bcdto7seg(bcds(7 downto 4)) when sw(0)='1' else bcdto7seg(bcdam(7 downto 4)) when sw(1)='1' and sw(2)='1' else bcdto7seg(bcdm(7 downto 4));
hex2 <= bcdto7seg(bcdm(3 downto 0)) when sw(0)='1' else bcdto7seg(bcdah(3 downto 0)) when sw(1)='1' and sw(2)='1' else bcdto7seg(bcdh(3 downto 0));
hex3 <= bcdto7seg(bcdm(7 downto 4)) when sw(0)='1' else bcdto7seg(bcdah(7 downto 4)) when sw(1)='1' and sw(2)='1' else bcdto7seg(bcdh(7 downto 4));

end logic;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity final_project_simulation is
  port( 
	clk, rst_n 			     : in  std_logic;
	sw 					         : in  std_logic_vector(2 downto 0);
	pb_n 					         : in  std_logic_vector(3 downto 0);
	led 				           : out std_logic_vector(17 downto 0);
	h1, ah1, m1, am1, s1	   : out  std_logic_vector(5 downto 0);
	display1, display2	: out std_logic_vector(5 downto 0) := (others => '0')
    );
end final_project_simulation;

architecture a of final_project_simulation  is
  signal l			: std_logic;
  signal h, ah, m, am, s	   :  std_logic_vector(5 downto 0) := (others => '0');
  begin

  process(rst_n,clk)
  begin
    if rst_n='0' then -- master reset all
      h<="000000";
      m<="000000";
      s<="000000";
      ah<="000000";
      am<="000000";
    elsif clk'event and clk='1' then
      if sw(2)='1' then -- configure time/alarm
        if sw(1)='0' then
			   if pb_n(1)='0' then h<=h+1;	end if;
			   if pb_n(2)='0' then m<=m+1;	end if;
			   if pb_n(3)='0' then m<=m-1;	end if;
		    else
			   if pb_n(1)='0' then ah<=ah+1;	end if;
			   if pb_n(2)='0' then am<=am+1;	end if;
			   if pb_n(3)='0' then am<=am-1;	end if;
		    end if;
      elsif sw(1)='1' then -- alarm mode
		    if ah=h and am=m then	
			  l<=not l;
		  end if;
    else l<='0';
    end if;
      
      
    if h="11000" then
		h<="000000";
		m<="000000";
		s<="000000";
	  elsif m="111011" then
		h<=h+1;
		m<="000000";
	  elsif s="111011" then 
		m<=m+1;
		s<="000000";
	  else s<=s+1;
	  end if;
	  
	  --m<=m+1;

    end if;
  end process;
  
  led <= "111111111111111111" when l='1' else 
		 "000000000000000000";
  
  display1 <= s when sw(0)='1' else
		  am when sw(1)='1' and sw(2)='1' else
		  m;
  display2 <= m when sw(0)='1' else
		  ah when sw(1)='1' and sw(2)='1' else
		  h;
	h1 <= h;
	ah1 <= ah;
	m1 <= m;
	am1 <= am; 
	s1 <= s;
end a;




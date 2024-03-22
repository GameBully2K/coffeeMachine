library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity coffemachine is
    port (
        clk : in std_logic;
        reset : in std_logic;
        coin_inserted : in unsigned(2 downto 0); -- Assuming 3-bit input for coin type
        selected_coffee : in unsigned(2 downto 0); -- Assuming 3-bit input for coffee selection
        sugar : in std_logic; -- Input for sugar
        dispense_coffee : out std_logic; -- Output to dispense 1/3 shoot of coffee
        dispense_milk : out std_logic; -- Output to dispense 1/3 shoot of milk
        dispense_sugar : out std_logic; -- Output to dispense sugar
        displayCommande : out unsigned(2 downto 0);-- Assuming 3-bit output for coffee type
        change_given : out unsigned(2 downto 0) -- Assuming 3-bit output for coin type
    );
end coffemachine;

architecture Behavioral of coffemachine is
    signal coffee_level : integer range 0 to 100 := 100; -- Initial coffee level
    signal milk_level : integer range 0 to 100 := 100; -- Initial milk level
    signal current_state : integer range 0 to 5 := 0; -- State machine state
    signal coffee_type : unsigned(2 downto 0); -- Change to be given
    signal coffee_price : integer range 0 to 20 := 0; -- Price of coffee
    signal sum : integer range 0 to 20 := 0; -- Sum of coins inserted

begin
    process (clk, reset)
    begin
        if reset = '1' then
            current_state <= 0; -- Initialize state machine
            -- Reset other signals/variables
        elsif rising_edge(clk) then
            case current_state is
                when 0 => -- Idle state
                    case selected_coffee is
                        when "001" => -- Normal coffee
                            if coffee_level >= 10 and milk_level >= 10 then
                                coffee_price <= 6; -- Set price of coffee
                                coffee_type <= "001"; -- Set type of coffee
                                current_state <= 1; -- Transition to waiting for coins
                            else
                                displayCommande <= "001"; -- Display "Not enough ingredients"
                            end if;
                        when "010" => -- double shot
                            if coffee_level >= 10 and milk_level >= 10 then
                                coffee_price <= 10; -- Set price of coffee
                                coffee_type <= "010"; -- Set type of coffee
                                current_state <= 1; -- Transition to waiting for coins
                            else
                                displayCommande <= "001"; -- Display "Not enough ingredients"
                            end if;
                        when "011" => -- half milk half coffee
                            if coffee_level >= 10 and milk_level >= 10 then
                                coffee_price <= 7; -- Set price of coffee
                                coffee_type <= "011"; -- Set type of coffee
                                current_state <= 1; -- Transition to waiting for coins
                            else
                                displayCommande <= "001"; -- Display "Not enough ingredients"
                            end if;
                        when "100" => -- 1/3 milk 2/3 coffee
                            if coffee_level >= 10 and milk_level >= 10 then
                                coffee_price <= 8; -- Set price of coffee
                                coffee_type <= "100"; -- Set type of coffee
                                current_state <= 1; -- Transition to waiting for coins
                            else
                                displayCommande <= "001"; -- Display "Not enough ingredients"
                            end if;
                        when others =>
                            displayCommande <= "011"; -- Display "invalid selection"
                    end case;
                when 1 => -- Waiting for coins
                    case coin_inserted is
                        when "001" => -- 1 dirhams
                            sum <= sum + 1;
                        when "010" => -- 2 dirhams
                            sum <= sum + 2;
                        when "011" => -- 5 dirhams
                            sum <= sum + 5;
                        when "100" => -- 10 dirhams
                            sum <= sum + 10;
                        when others =>
                            displayCommande <= "100"; -- Display "invalid coin"
                    end case;
                    if sum >= coffee_price then
                        sum <= sum - coffee_price; -- Calculate change
                        current_state <= 2; -- Transition to giving change
                    end if;
                when 2 => -- Giving change
                    if sum >= 10 then
                        change_given <= "100";
                        change_given <= "000";
                        sum <= sum - 10;
                    elsif sum >= 5 then
                        change_given <= "011";
                        change_given <= "000";
                        sum <= sum - 5;
                    elsif sum >= 2 then
                        change_given <= "010";
                        change_given <= "000";
                        sum <= sum - 2;
                    elsif sum >= 1 then
                        change_given <= "001";
                        change_given <= "000";
                        sum <= sum - 1;
                    end if;
                    if sum = 0 then
                        current_state <= 3; -- Transition to dispensing coffee
                    end if;
                when 3 => -- Dispensing coffee
                    case coffee_type is
                        when "001" => -- Normal coffee
                            if coffee_level >= 1 and milk_level >= 1 then
                                dispense_coffee <= '1';
                                dispense_coffee <= '0';
                                coffee_level <= coffee_level - 1;
                                if sugar = '1' then
                                    dispense_sugar <= '1';
                                end if;
                            else
                                displayCommande <= "001"; -- Display "Not enough ingredients"
                            end if;
                        when "010" => -- double shot
                            if coffee_level >= 1 and milk_level >= 1 then
                                dispense_coffee <= '1';
                                dispense_coffee <= '0';
                                dispense_coffee <= '1';
                                dispense_coffee <= '0';
                                coffee_level <= coffee_level - 2;
                                if sugar = '1' then
                                    dispense_sugar <= '1';
                                    dispense_sugar <= '0';
                                end if;
                            else
                                displayCommande <= "001"; -- Display "Not enough ingredients"
                            end if;
                        when "011" => -- half milk half coffee
                            if coffee_level >= 1 and milk_level >= 1 then
                                dispense_coffee <= '1';
                                dispense_coffee <= '0';
                                dispense_milk <= '1';
                                dispense_milk <= '0';
                                dispense_coffee <= '1';
                                dispense_coffee <= '0';
                                dispense_milk <= '1';
                                dispense_milk <= '0';
                                coffee_level <= coffee_level - 2;
                                milk_level <= milk_level - 2;
                                if sugar = '1' then
                                    dispense_sugar <= '1';
                                end if;
                            else
                                displayCommande <= "001"; -- Display "Not enough ingredients"
                            end if;
                        when "100" => -- 1/3 milk 2/3 coffee
                            if coffee_level >= 1 and milk_level >= 1 then
                                dispense_coffee <= '1';
                                dispense_coffee <= '0';
                                dispense_coffee <= '1';
                                dispense_coffee <= '0';
                                dispense_milk <= '1';
                                dispense_milk <= '0';
                                if sugar = '1' then
                                    dispense_sugar <= '1';
                                end if;
                            else
                                displayCommande <= "001"; -- Display "Not enough ingredients"
                            end if;
                        when others =>
                            -- Do nothing
                    end case;
                when others =>
                    displayCommande <= "111"; -- Display "internal error"
            end case;
        end if;
    end process;
end Behavioral;

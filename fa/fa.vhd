library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fa is
    port (
        a    : in std_logic;
        b    : in std_logic;
        cin  : in std_logic;
        s    : out std_logic;
        cout : out std_logic
    );
end;

architecture behavioral of fa is
    signal axorb : std_logic;
begin
    axorb <= a xor b;
    s <= axorb xor cin;
    cout <= (a and b) or (cin and axorb);
end;

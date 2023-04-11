
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"ed",x"00",x"00",x"1f"),
     1 => (x"1e",x"00",x"00",x"1f"),
     2 => (x"c8",x"48",x"d0",x"ff"),
     3 => (x"48",x"71",x"78",x"c9"),
     4 => (x"78",x"08",x"d4",x"ff"),
     5 => (x"71",x"1e",x"4f",x"26"),
     6 => (x"87",x"eb",x"49",x"4a"),
     7 => (x"c8",x"48",x"d0",x"ff"),
     8 => (x"1e",x"4f",x"26",x"78"),
     9 => (x"4b",x"71",x"1e",x"73"),
    10 => (x"bf",x"e0",x"f7",x"c2"),
    11 => (x"c2",x"87",x"c3",x"02"),
    12 => (x"d0",x"ff",x"87",x"eb"),
    13 => (x"78",x"c9",x"c8",x"48"),
    14 => (x"e0",x"c0",x"49",x"73"),
    15 => (x"48",x"d4",x"ff",x"b1"),
    16 => (x"f7",x"c2",x"78",x"71"),
    17 => (x"78",x"c0",x"48",x"d4"),
    18 => (x"c5",x"02",x"66",x"c8"),
    19 => (x"49",x"ff",x"c3",x"87"),
    20 => (x"49",x"c0",x"87",x"c2"),
    21 => (x"59",x"dc",x"f7",x"c2"),
    22 => (x"c6",x"02",x"66",x"cc"),
    23 => (x"d5",x"d5",x"c5",x"87"),
    24 => (x"cf",x"87",x"c4",x"4a"),
    25 => (x"c2",x"4a",x"ff",x"ff"),
    26 => (x"c2",x"5a",x"e0",x"f7"),
    27 => (x"c1",x"48",x"e0",x"f7"),
    28 => (x"26",x"87",x"c4",x"78"),
    29 => (x"26",x"4c",x"26",x"4d"),
    30 => (x"0e",x"4f",x"26",x"4b"),
    31 => (x"5d",x"5c",x"5b",x"5e"),
    32 => (x"c2",x"4a",x"71",x"0e"),
    33 => (x"4c",x"bf",x"dc",x"f7"),
    34 => (x"cb",x"02",x"9a",x"72"),
    35 => (x"91",x"c8",x"49",x"87"),
    36 => (x"4b",x"d9",x"c0",x"c2"),
    37 => (x"87",x"c4",x"83",x"71"),
    38 => (x"4b",x"d9",x"c4",x"c2"),
    39 => (x"49",x"13",x"4d",x"c0"),
    40 => (x"f7",x"c2",x"99",x"74"),
    41 => (x"ff",x"b9",x"bf",x"d8"),
    42 => (x"78",x"71",x"48",x"d4"),
    43 => (x"85",x"2c",x"b7",x"c1"),
    44 => (x"04",x"ad",x"b7",x"c8"),
    45 => (x"f7",x"c2",x"87",x"e8"),
    46 => (x"c8",x"48",x"bf",x"d4"),
    47 => (x"d8",x"f7",x"c2",x"80"),
    48 => (x"87",x"ef",x"fe",x"58"),
    49 => (x"71",x"1e",x"73",x"1e"),
    50 => (x"9a",x"4a",x"13",x"4b"),
    51 => (x"72",x"87",x"cb",x"02"),
    52 => (x"87",x"e7",x"fe",x"49"),
    53 => (x"05",x"9a",x"4a",x"13"),
    54 => (x"da",x"fe",x"87",x"f5"),
    55 => (x"f7",x"c2",x"1e",x"87"),
    56 => (x"c2",x"49",x"bf",x"d4"),
    57 => (x"c1",x"48",x"d4",x"f7"),
    58 => (x"c0",x"c4",x"78",x"a1"),
    59 => (x"db",x"03",x"a9",x"b7"),
    60 => (x"48",x"d4",x"ff",x"87"),
    61 => (x"bf",x"d8",x"f7",x"c2"),
    62 => (x"d4",x"f7",x"c2",x"78"),
    63 => (x"f7",x"c2",x"49",x"bf"),
    64 => (x"a1",x"c1",x"48",x"d4"),
    65 => (x"b7",x"c0",x"c4",x"78"),
    66 => (x"87",x"e5",x"04",x"a9"),
    67 => (x"c8",x"48",x"d0",x"ff"),
    68 => (x"e0",x"f7",x"c2",x"78"),
    69 => (x"26",x"78",x"c0",x"48"),
    70 => (x"00",x"00",x"00",x"4f"),
    71 => (x"00",x"00",x"00",x"00"),
    72 => (x"00",x"00",x"00",x"00"),
    73 => (x"00",x"00",x"5f",x"5f"),
    74 => (x"03",x"03",x"00",x"00"),
    75 => (x"00",x"03",x"03",x"00"),
    76 => (x"7f",x"7f",x"14",x"00"),
    77 => (x"14",x"7f",x"7f",x"14"),
    78 => (x"2e",x"24",x"00",x"00"),
    79 => (x"12",x"3a",x"6b",x"6b"),
    80 => (x"36",x"6a",x"4c",x"00"),
    81 => (x"32",x"56",x"6c",x"18"),
    82 => (x"4f",x"7e",x"30",x"00"),
    83 => (x"68",x"3a",x"77",x"59"),
    84 => (x"04",x"00",x"00",x"40"),
    85 => (x"00",x"00",x"03",x"07"),
    86 => (x"1c",x"00",x"00",x"00"),
    87 => (x"00",x"41",x"63",x"3e"),
    88 => (x"41",x"00",x"00",x"00"),
    89 => (x"00",x"1c",x"3e",x"63"),
    90 => (x"3e",x"2a",x"08",x"00"),
    91 => (x"2a",x"3e",x"1c",x"1c"),
    92 => (x"08",x"08",x"00",x"08"),
    93 => (x"08",x"08",x"3e",x"3e"),
    94 => (x"80",x"00",x"00",x"00"),
    95 => (x"00",x"00",x"60",x"e0"),
    96 => (x"08",x"08",x"00",x"00"),
    97 => (x"08",x"08",x"08",x"08"),
    98 => (x"00",x"00",x"00",x"00"),
    99 => (x"00",x"00",x"60",x"60"),
   100 => (x"30",x"60",x"40",x"00"),
   101 => (x"03",x"06",x"0c",x"18"),
   102 => (x"7f",x"3e",x"00",x"01"),
   103 => (x"3e",x"7f",x"4d",x"59"),
   104 => (x"06",x"04",x"00",x"00"),
   105 => (x"00",x"00",x"7f",x"7f"),
   106 => (x"63",x"42",x"00",x"00"),
   107 => (x"46",x"4f",x"59",x"71"),
   108 => (x"63",x"22",x"00",x"00"),
   109 => (x"36",x"7f",x"49",x"49"),
   110 => (x"16",x"1c",x"18",x"00"),
   111 => (x"10",x"7f",x"7f",x"13"),
   112 => (x"67",x"27",x"00",x"00"),
   113 => (x"39",x"7d",x"45",x"45"),
   114 => (x"7e",x"3c",x"00",x"00"),
   115 => (x"30",x"79",x"49",x"4b"),
   116 => (x"01",x"01",x"00",x"00"),
   117 => (x"07",x"0f",x"79",x"71"),
   118 => (x"7f",x"36",x"00",x"00"),
   119 => (x"36",x"7f",x"49",x"49"),
   120 => (x"4f",x"06",x"00",x"00"),
   121 => (x"1e",x"3f",x"69",x"49"),
   122 => (x"00",x"00",x"00",x"00"),
   123 => (x"00",x"00",x"66",x"66"),
   124 => (x"80",x"00",x"00",x"00"),
   125 => (x"00",x"00",x"66",x"e6"),
   126 => (x"08",x"08",x"00",x"00"),
   127 => (x"22",x"22",x"14",x"14"),
   128 => (x"14",x"14",x"00",x"00"),
   129 => (x"14",x"14",x"14",x"14"),
   130 => (x"22",x"22",x"00",x"00"),
   131 => (x"08",x"08",x"14",x"14"),
   132 => (x"03",x"02",x"00",x"00"),
   133 => (x"06",x"0f",x"59",x"51"),
   134 => (x"41",x"7f",x"3e",x"00"),
   135 => (x"1e",x"1f",x"55",x"5d"),
   136 => (x"7f",x"7e",x"00",x"00"),
   137 => (x"7e",x"7f",x"09",x"09"),
   138 => (x"7f",x"7f",x"00",x"00"),
   139 => (x"36",x"7f",x"49",x"49"),
   140 => (x"3e",x"1c",x"00",x"00"),
   141 => (x"41",x"41",x"41",x"63"),
   142 => (x"7f",x"7f",x"00",x"00"),
   143 => (x"1c",x"3e",x"63",x"41"),
   144 => (x"7f",x"7f",x"00",x"00"),
   145 => (x"41",x"41",x"49",x"49"),
   146 => (x"7f",x"7f",x"00",x"00"),
   147 => (x"01",x"01",x"09",x"09"),
   148 => (x"7f",x"3e",x"00",x"00"),
   149 => (x"7a",x"7b",x"49",x"41"),
   150 => (x"7f",x"7f",x"00",x"00"),
   151 => (x"7f",x"7f",x"08",x"08"),
   152 => (x"41",x"00",x"00",x"00"),
   153 => (x"00",x"41",x"7f",x"7f"),
   154 => (x"60",x"20",x"00",x"00"),
   155 => (x"3f",x"7f",x"40",x"40"),
   156 => (x"08",x"7f",x"7f",x"00"),
   157 => (x"41",x"63",x"36",x"1c"),
   158 => (x"7f",x"7f",x"00",x"00"),
   159 => (x"40",x"40",x"40",x"40"),
   160 => (x"06",x"7f",x"7f",x"00"),
   161 => (x"7f",x"7f",x"06",x"0c"),
   162 => (x"06",x"7f",x"7f",x"00"),
   163 => (x"7f",x"7f",x"18",x"0c"),
   164 => (x"7f",x"3e",x"00",x"00"),
   165 => (x"3e",x"7f",x"41",x"41"),
   166 => (x"7f",x"7f",x"00",x"00"),
   167 => (x"06",x"0f",x"09",x"09"),
   168 => (x"41",x"7f",x"3e",x"00"),
   169 => (x"40",x"7e",x"7f",x"61"),
   170 => (x"7f",x"7f",x"00",x"00"),
   171 => (x"66",x"7f",x"19",x"09"),
   172 => (x"6f",x"26",x"00",x"00"),
   173 => (x"32",x"7b",x"59",x"4d"),
   174 => (x"01",x"01",x"00",x"00"),
   175 => (x"01",x"01",x"7f",x"7f"),
   176 => (x"7f",x"3f",x"00",x"00"),
   177 => (x"3f",x"7f",x"40",x"40"),
   178 => (x"3f",x"0f",x"00",x"00"),
   179 => (x"0f",x"3f",x"70",x"70"),
   180 => (x"30",x"7f",x"7f",x"00"),
   181 => (x"7f",x"7f",x"30",x"18"),
   182 => (x"36",x"63",x"41",x"00"),
   183 => (x"63",x"36",x"1c",x"1c"),
   184 => (x"06",x"03",x"01",x"41"),
   185 => (x"03",x"06",x"7c",x"7c"),
   186 => (x"59",x"71",x"61",x"01"),
   187 => (x"41",x"43",x"47",x"4d"),
   188 => (x"7f",x"00",x"00",x"00"),
   189 => (x"00",x"41",x"41",x"7f"),
   190 => (x"06",x"03",x"01",x"00"),
   191 => (x"60",x"30",x"18",x"0c"),
   192 => (x"41",x"00",x"00",x"40"),
   193 => (x"00",x"7f",x"7f",x"41"),
   194 => (x"06",x"0c",x"08",x"00"),
   195 => (x"08",x"0c",x"06",x"03"),
   196 => (x"80",x"80",x"80",x"00"),
   197 => (x"80",x"80",x"80",x"80"),
   198 => (x"00",x"00",x"00",x"00"),
   199 => (x"00",x"04",x"07",x"03"),
   200 => (x"74",x"20",x"00",x"00"),
   201 => (x"78",x"7c",x"54",x"54"),
   202 => (x"7f",x"7f",x"00",x"00"),
   203 => (x"38",x"7c",x"44",x"44"),
   204 => (x"7c",x"38",x"00",x"00"),
   205 => (x"00",x"44",x"44",x"44"),
   206 => (x"7c",x"38",x"00",x"00"),
   207 => (x"7f",x"7f",x"44",x"44"),
   208 => (x"7c",x"38",x"00",x"00"),
   209 => (x"18",x"5c",x"54",x"54"),
   210 => (x"7e",x"04",x"00",x"00"),
   211 => (x"00",x"05",x"05",x"7f"),
   212 => (x"bc",x"18",x"00",x"00"),
   213 => (x"7c",x"fc",x"a4",x"a4"),
   214 => (x"7f",x"7f",x"00",x"00"),
   215 => (x"78",x"7c",x"04",x"04"),
   216 => (x"00",x"00",x"00",x"00"),
   217 => (x"00",x"40",x"7d",x"3d"),
   218 => (x"80",x"80",x"00",x"00"),
   219 => (x"00",x"7d",x"fd",x"80"),
   220 => (x"7f",x"7f",x"00",x"00"),
   221 => (x"44",x"6c",x"38",x"10"),
   222 => (x"00",x"00",x"00",x"00"),
   223 => (x"00",x"40",x"7f",x"3f"),
   224 => (x"0c",x"7c",x"7c",x"00"),
   225 => (x"78",x"7c",x"0c",x"18"),
   226 => (x"7c",x"7c",x"00",x"00"),
   227 => (x"78",x"7c",x"04",x"04"),
   228 => (x"7c",x"38",x"00",x"00"),
   229 => (x"38",x"7c",x"44",x"44"),
   230 => (x"fc",x"fc",x"00",x"00"),
   231 => (x"18",x"3c",x"24",x"24"),
   232 => (x"3c",x"18",x"00",x"00"),
   233 => (x"fc",x"fc",x"24",x"24"),
   234 => (x"7c",x"7c",x"00",x"00"),
   235 => (x"08",x"0c",x"04",x"04"),
   236 => (x"5c",x"48",x"00",x"00"),
   237 => (x"20",x"74",x"54",x"54"),
   238 => (x"3f",x"04",x"00",x"00"),
   239 => (x"00",x"44",x"44",x"7f"),
   240 => (x"7c",x"3c",x"00",x"00"),
   241 => (x"7c",x"7c",x"40",x"40"),
   242 => (x"3c",x"1c",x"00",x"00"),
   243 => (x"1c",x"3c",x"60",x"60"),
   244 => (x"60",x"7c",x"3c",x"00"),
   245 => (x"3c",x"7c",x"60",x"30"),
   246 => (x"38",x"6c",x"44",x"00"),
   247 => (x"44",x"6c",x"38",x"10"),
   248 => (x"bc",x"1c",x"00",x"00"),
   249 => (x"1c",x"3c",x"60",x"e0"),
   250 => (x"64",x"44",x"00",x"00"),
   251 => (x"44",x"4c",x"5c",x"74"),
   252 => (x"08",x"08",x"00",x"00"),
   253 => (x"41",x"41",x"77",x"3e"),
   254 => (x"00",x"00",x"00",x"00"),
   255 => (x"00",x"00",x"7f",x"7f"),
   256 => (x"41",x"41",x"00",x"00"),
   257 => (x"08",x"08",x"3e",x"77"),
   258 => (x"01",x"01",x"02",x"00"),
   259 => (x"01",x"02",x"02",x"03"),
   260 => (x"7f",x"7f",x"7f",x"00"),
   261 => (x"7f",x"7f",x"7f",x"7f"),
   262 => (x"1c",x"08",x"08",x"00"),
   263 => (x"7f",x"3e",x"3e",x"1c"),
   264 => (x"3e",x"7f",x"7f",x"7f"),
   265 => (x"08",x"1c",x"1c",x"3e"),
   266 => (x"18",x"10",x"00",x"08"),
   267 => (x"10",x"18",x"7c",x"7c"),
   268 => (x"30",x"10",x"00",x"00"),
   269 => (x"10",x"30",x"7c",x"7c"),
   270 => (x"60",x"30",x"10",x"00"),
   271 => (x"06",x"1e",x"78",x"60"),
   272 => (x"3c",x"66",x"42",x"00"),
   273 => (x"42",x"66",x"3c",x"18"),
   274 => (x"6a",x"38",x"78",x"00"),
   275 => (x"38",x"6c",x"c6",x"c2"),
   276 => (x"00",x"00",x"60",x"00"),
   277 => (x"60",x"00",x"00",x"60"),
   278 => (x"5b",x"5e",x"0e",x"00"),
   279 => (x"1e",x"0e",x"5d",x"5c"),
   280 => (x"f7",x"c2",x"4c",x"71"),
   281 => (x"c0",x"4d",x"bf",x"f1"),
   282 => (x"74",x"1e",x"c0",x"4b"),
   283 => (x"87",x"c7",x"02",x"ab"),
   284 => (x"c0",x"48",x"a6",x"c4"),
   285 => (x"c4",x"87",x"c5",x"78"),
   286 => (x"78",x"c1",x"48",x"a6"),
   287 => (x"73",x"1e",x"66",x"c4"),
   288 => (x"87",x"df",x"ee",x"49"),
   289 => (x"e0",x"c0",x"86",x"c8"),
   290 => (x"87",x"ef",x"ef",x"49"),
   291 => (x"6a",x"4a",x"a5",x"c4"),
   292 => (x"87",x"f0",x"f0",x"49"),
   293 => (x"cb",x"87",x"c6",x"f1"),
   294 => (x"c8",x"83",x"c1",x"85"),
   295 => (x"ff",x"04",x"ab",x"b7"),
   296 => (x"26",x"26",x"87",x"c7"),
   297 => (x"26",x"4c",x"26",x"4d"),
   298 => (x"1e",x"4f",x"26",x"4b"),
   299 => (x"f7",x"c2",x"4a",x"71"),
   300 => (x"f7",x"c2",x"5a",x"f5"),
   301 => (x"78",x"c7",x"48",x"f5"),
   302 => (x"87",x"dd",x"fe",x"49"),
   303 => (x"73",x"1e",x"4f",x"26"),
   304 => (x"c0",x"4a",x"71",x"1e"),
   305 => (x"d3",x"03",x"aa",x"b7"),
   306 => (x"de",x"e0",x"c2",x"87"),
   307 => (x"87",x"c4",x"05",x"bf"),
   308 => (x"87",x"c2",x"4b",x"c1"),
   309 => (x"e0",x"c2",x"4b",x"c0"),
   310 => (x"87",x"c4",x"5b",x"e2"),
   311 => (x"5a",x"e2",x"e0",x"c2"),
   312 => (x"bf",x"de",x"e0",x"c2"),
   313 => (x"c1",x"9a",x"c1",x"4a"),
   314 => (x"ec",x"49",x"a2",x"c0"),
   315 => (x"48",x"fc",x"87",x"e8"),
   316 => (x"bf",x"de",x"e0",x"c2"),
   317 => (x"87",x"ef",x"fe",x"78"),
   318 => (x"c4",x"4a",x"71",x"1e"),
   319 => (x"49",x"72",x"1e",x"66"),
   320 => (x"87",x"e9",x"df",x"ff"),
   321 => (x"1e",x"4f",x"26",x"26"),
   322 => (x"bf",x"de",x"e0",x"c2"),
   323 => (x"d9",x"dc",x"ff",x"49"),
   324 => (x"e9",x"f7",x"c2",x"87"),
   325 => (x"78",x"bf",x"e8",x"48"),
   326 => (x"48",x"e5",x"f7",x"c2"),
   327 => (x"c2",x"78",x"bf",x"ec"),
   328 => (x"4a",x"bf",x"e9",x"f7"),
   329 => (x"99",x"ff",x"c3",x"49"),
   330 => (x"72",x"2a",x"b7",x"c8"),
   331 => (x"c2",x"b0",x"71",x"48"),
   332 => (x"26",x"58",x"f1",x"f7"),
   333 => (x"5b",x"5e",x"0e",x"4f"),
   334 => (x"71",x"0e",x"5d",x"5c"),
   335 => (x"87",x"c7",x"ff",x"4b"),
   336 => (x"48",x"e4",x"f7",x"c2"),
   337 => (x"49",x"73",x"50",x"c0"),
   338 => (x"87",x"fe",x"db",x"ff"),
   339 => (x"c2",x"4c",x"49",x"70"),
   340 => (x"49",x"ee",x"cb",x"9c"),
   341 => (x"70",x"87",x"cf",x"cb"),
   342 => (x"f7",x"c2",x"4d",x"49"),
   343 => (x"05",x"bf",x"97",x"e4"),
   344 => (x"d0",x"87",x"e4",x"c1"),
   345 => (x"f7",x"c2",x"49",x"66"),
   346 => (x"05",x"99",x"bf",x"ed"),
   347 => (x"66",x"d4",x"87",x"d7"),
   348 => (x"e5",x"f7",x"c2",x"49"),
   349 => (x"cc",x"05",x"99",x"bf"),
   350 => (x"ff",x"49",x"73",x"87"),
   351 => (x"70",x"87",x"cb",x"db"),
   352 => (x"c2",x"c1",x"02",x"98"),
   353 => (x"fd",x"4c",x"c1",x"87"),
   354 => (x"49",x"75",x"87",x"fd"),
   355 => (x"70",x"87",x"e3",x"ca"),
   356 => (x"87",x"c6",x"02",x"98"),
   357 => (x"48",x"e4",x"f7",x"c2"),
   358 => (x"f7",x"c2",x"50",x"c1"),
   359 => (x"05",x"bf",x"97",x"e4"),
   360 => (x"c2",x"87",x"e4",x"c0"),
   361 => (x"49",x"bf",x"ed",x"f7"),
   362 => (x"05",x"99",x"66",x"d0"),
   363 => (x"c2",x"87",x"d6",x"ff"),
   364 => (x"49",x"bf",x"e5",x"f7"),
   365 => (x"05",x"99",x"66",x"d4"),
   366 => (x"73",x"87",x"ca",x"ff"),
   367 => (x"c9",x"da",x"ff",x"49"),
   368 => (x"05",x"98",x"70",x"87"),
   369 => (x"74",x"87",x"fe",x"fe"),
   370 => (x"87",x"d7",x"fb",x"48"),
   371 => (x"5c",x"5b",x"5e",x"0e"),
   372 => (x"86",x"f4",x"0e",x"5d"),
   373 => (x"ec",x"4c",x"4d",x"c0"),
   374 => (x"a6",x"c4",x"7e",x"bf"),
   375 => (x"f1",x"f7",x"c2",x"48"),
   376 => (x"1e",x"c1",x"78",x"bf"),
   377 => (x"49",x"c7",x"1e",x"c0"),
   378 => (x"c8",x"87",x"ca",x"fd"),
   379 => (x"02",x"98",x"70",x"86"),
   380 => (x"49",x"ff",x"87",x"ce"),
   381 => (x"c1",x"87",x"c7",x"fb"),
   382 => (x"d9",x"ff",x"49",x"da"),
   383 => (x"4d",x"c1",x"87",x"cc"),
   384 => (x"97",x"e4",x"f7",x"c2"),
   385 => (x"87",x"c3",x"02",x"bf"),
   386 => (x"c2",x"87",x"c0",x"c9"),
   387 => (x"4b",x"bf",x"e9",x"f7"),
   388 => (x"bf",x"de",x"e0",x"c2"),
   389 => (x"87",x"eb",x"c0",x"05"),
   390 => (x"ff",x"49",x"fd",x"c3"),
   391 => (x"c3",x"87",x"eb",x"d8"),
   392 => (x"d8",x"ff",x"49",x"fa"),
   393 => (x"49",x"73",x"87",x"e4"),
   394 => (x"71",x"99",x"ff",x"c3"),
   395 => (x"fb",x"49",x"c0",x"1e"),
   396 => (x"49",x"73",x"87",x"c6"),
   397 => (x"71",x"29",x"b7",x"c8"),
   398 => (x"fa",x"49",x"c1",x"1e"),
   399 => (x"86",x"c8",x"87",x"fa"),
   400 => (x"c2",x"87",x"c1",x"c6"),
   401 => (x"4b",x"bf",x"ed",x"f7"),
   402 => (x"87",x"dd",x"02",x"9b"),
   403 => (x"bf",x"da",x"e0",x"c2"),
   404 => (x"87",x"de",x"c7",x"49"),
   405 => (x"c4",x"05",x"98",x"70"),
   406 => (x"d2",x"4b",x"c0",x"87"),
   407 => (x"49",x"e0",x"c2",x"87"),
   408 => (x"c2",x"87",x"c3",x"c7"),
   409 => (x"c6",x"58",x"de",x"e0"),
   410 => (x"da",x"e0",x"c2",x"87"),
   411 => (x"73",x"78",x"c0",x"48"),
   412 => (x"05",x"99",x"c2",x"49"),
   413 => (x"eb",x"c3",x"87",x"ce"),
   414 => (x"cd",x"d7",x"ff",x"49"),
   415 => (x"c2",x"49",x"70",x"87"),
   416 => (x"87",x"c2",x"02",x"99"),
   417 => (x"49",x"73",x"4c",x"fb"),
   418 => (x"ce",x"05",x"99",x"c1"),
   419 => (x"49",x"f4",x"c3",x"87"),
   420 => (x"87",x"f6",x"d6",x"ff"),
   421 => (x"99",x"c2",x"49",x"70"),
   422 => (x"fa",x"87",x"c2",x"02"),
   423 => (x"c8",x"49",x"73",x"4c"),
   424 => (x"87",x"ce",x"05",x"99"),
   425 => (x"ff",x"49",x"f5",x"c3"),
   426 => (x"70",x"87",x"df",x"d6"),
   427 => (x"02",x"99",x"c2",x"49"),
   428 => (x"f7",x"c2",x"87",x"d5"),
   429 => (x"ca",x"02",x"bf",x"f5"),
   430 => (x"88",x"c1",x"48",x"87"),
   431 => (x"58",x"f9",x"f7",x"c2"),
   432 => (x"ff",x"87",x"c2",x"c0"),
   433 => (x"73",x"4d",x"c1",x"4c"),
   434 => (x"05",x"99",x"c4",x"49"),
   435 => (x"f2",x"c3",x"87",x"ce"),
   436 => (x"f5",x"d5",x"ff",x"49"),
   437 => (x"c2",x"49",x"70",x"87"),
   438 => (x"87",x"dc",x"02",x"99"),
   439 => (x"bf",x"f5",x"f7",x"c2"),
   440 => (x"b7",x"c7",x"48",x"7e"),
   441 => (x"cb",x"c0",x"03",x"a8"),
   442 => (x"c1",x"48",x"6e",x"87"),
   443 => (x"f9",x"f7",x"c2",x"80"),
   444 => (x"87",x"c2",x"c0",x"58"),
   445 => (x"4d",x"c1",x"4c",x"fe"),
   446 => (x"ff",x"49",x"fd",x"c3"),
   447 => (x"70",x"87",x"cb",x"d5"),
   448 => (x"02",x"99",x"c2",x"49"),
   449 => (x"c2",x"87",x"d5",x"c0"),
   450 => (x"02",x"bf",x"f5",x"f7"),
   451 => (x"c2",x"87",x"c9",x"c0"),
   452 => (x"c0",x"48",x"f5",x"f7"),
   453 => (x"87",x"c2",x"c0",x"78"),
   454 => (x"4d",x"c1",x"4c",x"fd"),
   455 => (x"ff",x"49",x"fa",x"c3"),
   456 => (x"70",x"87",x"e7",x"d4"),
   457 => (x"02",x"99",x"c2",x"49"),
   458 => (x"c2",x"87",x"d9",x"c0"),
   459 => (x"48",x"bf",x"f5",x"f7"),
   460 => (x"03",x"a8",x"b7",x"c7"),
   461 => (x"c2",x"87",x"c9",x"c0"),
   462 => (x"c7",x"48",x"f5",x"f7"),
   463 => (x"87",x"c2",x"c0",x"78"),
   464 => (x"4d",x"c1",x"4c",x"fc"),
   465 => (x"03",x"ac",x"b7",x"c0"),
   466 => (x"c4",x"87",x"d1",x"c0"),
   467 => (x"d8",x"c1",x"4a",x"66"),
   468 => (x"c0",x"02",x"6a",x"82"),
   469 => (x"4b",x"6a",x"87",x"c6"),
   470 => (x"0f",x"73",x"49",x"74"),
   471 => (x"f0",x"c3",x"1e",x"c0"),
   472 => (x"49",x"da",x"c1",x"1e"),
   473 => (x"c8",x"87",x"ce",x"f7"),
   474 => (x"02",x"98",x"70",x"86"),
   475 => (x"c8",x"87",x"e2",x"c0"),
   476 => (x"f7",x"c2",x"48",x"a6"),
   477 => (x"c8",x"78",x"bf",x"f5"),
   478 => (x"91",x"cb",x"49",x"66"),
   479 => (x"71",x"48",x"66",x"c4"),
   480 => (x"6e",x"7e",x"70",x"80"),
   481 => (x"c8",x"c0",x"02",x"bf"),
   482 => (x"4b",x"bf",x"6e",x"87"),
   483 => (x"73",x"49",x"66",x"c8"),
   484 => (x"02",x"9d",x"75",x"0f"),
   485 => (x"c2",x"87",x"c8",x"c0"),
   486 => (x"49",x"bf",x"f5",x"f7"),
   487 => (x"c2",x"87",x"fa",x"f2"),
   488 => (x"02",x"bf",x"e2",x"e0"),
   489 => (x"49",x"87",x"dd",x"c0"),
   490 => (x"70",x"87",x"c7",x"c2"),
   491 => (x"d3",x"c0",x"02",x"98"),
   492 => (x"f5",x"f7",x"c2",x"87"),
   493 => (x"e0",x"f2",x"49",x"bf"),
   494 => (x"f4",x"49",x"c0",x"87"),
   495 => (x"e0",x"c2",x"87",x"c0"),
   496 => (x"78",x"c0",x"48",x"e2"),
   497 => (x"da",x"f3",x"8e",x"f4"),
   498 => (x"5b",x"5e",x"0e",x"87"),
   499 => (x"1e",x"0e",x"5d",x"5c"),
   500 => (x"f7",x"c2",x"4c",x"71"),
   501 => (x"c1",x"49",x"bf",x"f1"),
   502 => (x"c1",x"4d",x"a1",x"cd"),
   503 => (x"7e",x"69",x"81",x"d1"),
   504 => (x"cf",x"02",x"9c",x"74"),
   505 => (x"4b",x"a5",x"c4",x"87"),
   506 => (x"f7",x"c2",x"7b",x"74"),
   507 => (x"f2",x"49",x"bf",x"f1"),
   508 => (x"7b",x"6e",x"87",x"f9"),
   509 => (x"c4",x"05",x"9c",x"74"),
   510 => (x"c2",x"4b",x"c0",x"87"),
   511 => (x"73",x"4b",x"c1",x"87"),
   512 => (x"87",x"fa",x"f2",x"49"),
   513 => (x"c7",x"02",x"66",x"d4"),
   514 => (x"87",x"da",x"49",x"87"),
   515 => (x"87",x"c2",x"4a",x"70"),
   516 => (x"e0",x"c2",x"4a",x"c0"),
   517 => (x"f2",x"26",x"5a",x"e6"),
   518 => (x"00",x"00",x"87",x"c9"),
   519 => (x"00",x"00",x"00",x"00"),
   520 => (x"00",x"00",x"00",x"00"),
   521 => (x"71",x"1e",x"00",x"00"),
   522 => (x"bf",x"c8",x"ff",x"4a"),
   523 => (x"48",x"a1",x"72",x"49"),
   524 => (x"ff",x"1e",x"4f",x"26"),
   525 => (x"fe",x"89",x"bf",x"c8"),
   526 => (x"c0",x"c0",x"c0",x"c0"),
   527 => (x"c4",x"01",x"a9",x"c0"),
   528 => (x"c2",x"4a",x"c0",x"87"),
   529 => (x"72",x"4a",x"c1",x"87"),
   530 => (x"1e",x"4f",x"26",x"48"),
   531 => (x"bf",x"d9",x"e2",x"c2"),
   532 => (x"c2",x"b9",x"c1",x"49"),
   533 => (x"ff",x"59",x"dd",x"e2"),
   534 => (x"ff",x"c3",x"48",x"d4"),
   535 => (x"48",x"d0",x"ff",x"78"),
   536 => (x"ff",x"78",x"e1",x"c0"),
   537 => (x"78",x"c1",x"48",x"d4"),
   538 => (x"78",x"71",x"31",x"c4"),
   539 => (x"c0",x"48",x"d0",x"ff"),
   540 => (x"4f",x"26",x"78",x"e0"),
   541 => (x"cd",x"e2",x"c2",x"1e"),
   542 => (x"d8",x"f2",x"c2",x"1e"),
   543 => (x"c4",x"fc",x"fd",x"49"),
   544 => (x"70",x"86",x"c4",x"87"),
   545 => (x"87",x"c3",x"02",x"98"),
   546 => (x"26",x"87",x"c0",x"ff"),
   547 => (x"4b",x"35",x"31",x"4f"),
   548 => (x"20",x"20",x"5a",x"48"),
   549 => (x"47",x"46",x"43",x"20"),
   550 => (x"00",x"00",x"00",x"00"),
   551 => (x"5b",x"5e",x"0e",x"00"),
   552 => (x"c2",x"0e",x"5d",x"5c"),
   553 => (x"4a",x"bf",x"e5",x"f7"),
   554 => (x"bf",x"c6",x"e4",x"c2"),
   555 => (x"bc",x"72",x"4c",x"49"),
   556 => (x"c6",x"ff",x"4d",x"71"),
   557 => (x"4b",x"c0",x"87",x"eb"),
   558 => (x"99",x"d0",x"49",x"74"),
   559 => (x"87",x"e7",x"c0",x"02"),
   560 => (x"c8",x"48",x"d0",x"ff"),
   561 => (x"d4",x"ff",x"78",x"e1"),
   562 => (x"75",x"78",x"c5",x"48"),
   563 => (x"02",x"99",x"d0",x"49"),
   564 => (x"f0",x"c3",x"87",x"c3"),
   565 => (x"f4",x"e4",x"c2",x"78"),
   566 => (x"11",x"81",x"73",x"49"),
   567 => (x"08",x"d4",x"ff",x"48"),
   568 => (x"48",x"d0",x"ff",x"78"),
   569 => (x"c1",x"78",x"e0",x"c0"),
   570 => (x"c8",x"83",x"2d",x"2c"),
   571 => (x"c7",x"ff",x"04",x"ab"),
   572 => (x"e4",x"c5",x"ff",x"87"),
   573 => (x"c6",x"e4",x"c2",x"87"),
   574 => (x"e5",x"f7",x"c2",x"48"),
   575 => (x"4d",x"26",x"78",x"bf"),
   576 => (x"4b",x"26",x"4c",x"26"),
   577 => (x"00",x"00",x"4f",x"26"),
   578 => (x"c1",x"1e",x"00",x"00"),
   579 => (x"de",x"48",x"cc",x"e7"),
   580 => (x"dd",x"e4",x"c2",x"50"),
   581 => (x"f1",x"d9",x"fe",x"49"),
   582 => (x"26",x"48",x"c0",x"87"),
   583 => (x"4f",x"54",x"4a",x"4f"),
   584 => (x"55",x"52",x"54",x"55"),
   585 => (x"43",x"52",x"41",x"4e"),
   586 => (x"df",x"f2",x"1e",x"00"),
   587 => (x"87",x"ed",x"fd",x"87"),
   588 => (x"4f",x"26",x"87",x"f8"),
   589 => (x"25",x"26",x"1e",x"16"),
   590 => (x"3e",x"3d",x"36",x"2e"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;


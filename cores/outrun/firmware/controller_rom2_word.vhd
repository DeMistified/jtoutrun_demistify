library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic	(
	ADDR_WIDTH : integer := 8; -- ROM's address width (words, not bytes)
	COL_WIDTH  : integer := 8;  -- Column width (8bit -> byte)
	NB_COL     : integer := 4  -- Number of columns in memory
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

architecture arch of controller_rom2 is

-- type word_t is std_logic_vector(31 downto 0);
type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);

signal ram : ram_type :=
(

     0 => x"00001fea",
     1 => x"48d0ff1e",
     2 => x"7178c9c8",
     3 => x"08d4ff48",
     4 => x"1e4f2678",
     5 => x"eb494a71",
     6 => x"48d0ff87",
     7 => x"4f2678c8",
     8 => x"711e731e",
     9 => x"e0f7c24b",
    10 => x"87c302bf",
    11 => x"ff87ebc2",
    12 => x"c9c848d0",
    13 => x"c0497378",
    14 => x"d4ffb1e0",
    15 => x"c2787148",
    16 => x"c048d4f7",
    17 => x"0266c878",
    18 => x"ffc387c5",
    19 => x"c087c249",
    20 => x"dcf7c249",
    21 => x"0266cc59",
    22 => x"d5c587c6",
    23 => x"87c44ad5",
    24 => x"4affffcf",
    25 => x"5ae0f7c2",
    26 => x"48e0f7c2",
    27 => x"87c478c1",
    28 => x"4c264d26",
    29 => x"4f264b26",
    30 => x"5c5b5e0e",
    31 => x"4a710e5d",
    32 => x"bfdcf7c2",
    33 => x"029a724c",
    34 => x"c84987cb",
    35 => x"d6c0c291",
    36 => x"c483714b",
    37 => x"d6c4c287",
    38 => x"134dc04b",
    39 => x"c2997449",
    40 => x"b9bfd8f7",
    41 => x"7148d4ff",
    42 => x"2cb7c178",
    43 => x"adb7c885",
    44 => x"c287e804",
    45 => x"48bfd4f7",
    46 => x"f7c280c8",
    47 => x"effe58d8",
    48 => x"1e731e87",
    49 => x"4a134b71",
    50 => x"87cb029a",
    51 => x"e7fe4972",
    52 => x"9a4a1387",
    53 => x"fe87f505",
    54 => x"c21e87da",
    55 => x"49bfd4f7",
    56 => x"48d4f7c2",
    57 => x"c478a1c1",
    58 => x"03a9b7c0",
    59 => x"d4ff87db",
    60 => x"d8f7c248",
    61 => x"f7c278bf",
    62 => x"c249bfd4",
    63 => x"c148d4f7",
    64 => x"c0c478a1",
    65 => x"e504a9b7",
    66 => x"48d0ff87",
    67 => x"f7c278c8",
    68 => x"78c048e0",
    69 => x"00004f26",
    70 => x"00000000",
    71 => x"00000000",
    72 => x"005f5f00",
    73 => x"03000000",
    74 => x"03030003",
    75 => x"7f140000",
    76 => x"7f7f147f",
    77 => x"24000014",
    78 => x"3a6b6b2e",
    79 => x"6a4c0012",
    80 => x"566c1836",
    81 => x"7e300032",
    82 => x"3a77594f",
    83 => x"00004068",
    84 => x"00030704",
    85 => x"00000000",
    86 => x"41633e1c",
    87 => x"00000000",
    88 => x"1c3e6341",
    89 => x"2a080000",
    90 => x"3e1c1c3e",
    91 => x"0800082a",
    92 => x"083e3e08",
    93 => x"00000008",
    94 => x"0060e080",
    95 => x"08000000",
    96 => x"08080808",
    97 => x"00000008",
    98 => x"00606000",
    99 => x"60400000",
   100 => x"060c1830",
   101 => x"3e000103",
   102 => x"7f4d597f",
   103 => x"0400003e",
   104 => x"007f7f06",
   105 => x"42000000",
   106 => x"4f597163",
   107 => x"22000046",
   108 => x"7f494963",
   109 => x"1c180036",
   110 => x"7f7f1316",
   111 => x"27000010",
   112 => x"7d454567",
   113 => x"3c000039",
   114 => x"79494b7e",
   115 => x"01000030",
   116 => x"0f797101",
   117 => x"36000007",
   118 => x"7f49497f",
   119 => x"06000036",
   120 => x"3f69494f",
   121 => x"0000001e",
   122 => x"00666600",
   123 => x"00000000",
   124 => x"0066e680",
   125 => x"08000000",
   126 => x"22141408",
   127 => x"14000022",
   128 => x"14141414",
   129 => x"22000014",
   130 => x"08141422",
   131 => x"02000008",
   132 => x"0f595103",
   133 => x"7f3e0006",
   134 => x"1f555d41",
   135 => x"7e00001e",
   136 => x"7f09097f",
   137 => x"7f00007e",
   138 => x"7f49497f",
   139 => x"1c000036",
   140 => x"4141633e",
   141 => x"7f000041",
   142 => x"3e63417f",
   143 => x"7f00001c",
   144 => x"4149497f",
   145 => x"7f000041",
   146 => x"0109097f",
   147 => x"3e000001",
   148 => x"7b49417f",
   149 => x"7f00007a",
   150 => x"7f08087f",
   151 => x"0000007f",
   152 => x"417f7f41",
   153 => x"20000000",
   154 => x"7f404060",
   155 => x"7f7f003f",
   156 => x"63361c08",
   157 => x"7f000041",
   158 => x"4040407f",
   159 => x"7f7f0040",
   160 => x"7f060c06",
   161 => x"7f7f007f",
   162 => x"7f180c06",
   163 => x"3e00007f",
   164 => x"7f41417f",
   165 => x"7f00003e",
   166 => x"0f09097f",
   167 => x"7f3e0006",
   168 => x"7e7f6141",
   169 => x"7f000040",
   170 => x"7f19097f",
   171 => x"26000066",
   172 => x"7b594d6f",
   173 => x"01000032",
   174 => x"017f7f01",
   175 => x"3f000001",
   176 => x"7f40407f",
   177 => x"0f00003f",
   178 => x"3f70703f",
   179 => x"7f7f000f",
   180 => x"7f301830",
   181 => x"6341007f",
   182 => x"361c1c36",
   183 => x"03014163",
   184 => x"067c7c06",
   185 => x"71610103",
   186 => x"43474d59",
   187 => x"00000041",
   188 => x"41417f7f",
   189 => x"03010000",
   190 => x"30180c06",
   191 => x"00004060",
   192 => x"7f7f4141",
   193 => x"0c080000",
   194 => x"0c060306",
   195 => x"80800008",
   196 => x"80808080",
   197 => x"00000080",
   198 => x"04070300",
   199 => x"20000000",
   200 => x"7c545474",
   201 => x"7f000078",
   202 => x"7c44447f",
   203 => x"38000038",
   204 => x"4444447c",
   205 => x"38000000",
   206 => x"7f44447c",
   207 => x"3800007f",
   208 => x"5c54547c",
   209 => x"04000018",
   210 => x"05057f7e",
   211 => x"18000000",
   212 => x"fca4a4bc",
   213 => x"7f00007c",
   214 => x"7c04047f",
   215 => x"00000078",
   216 => x"407d3d00",
   217 => x"80000000",
   218 => x"7dfd8080",
   219 => x"7f000000",
   220 => x"6c38107f",
   221 => x"00000044",
   222 => x"407f3f00",
   223 => x"7c7c0000",
   224 => x"7c0c180c",
   225 => x"7c000078",
   226 => x"7c04047c",
   227 => x"38000078",
   228 => x"7c44447c",
   229 => x"fc000038",
   230 => x"3c2424fc",
   231 => x"18000018",
   232 => x"fc24243c",
   233 => x"7c0000fc",
   234 => x"0c04047c",
   235 => x"48000008",
   236 => x"7454545c",
   237 => x"04000020",
   238 => x"44447f3f",
   239 => x"3c000000",
   240 => x"7c40407c",
   241 => x"1c00007c",
   242 => x"3c60603c",
   243 => x"7c3c001c",
   244 => x"7c603060",
   245 => x"6c44003c",
   246 => x"6c381038",
   247 => x"1c000044",
   248 => x"3c60e0bc",
   249 => x"4400001c",
   250 => x"4c5c7464",
   251 => x"08000044",
   252 => x"41773e08",
   253 => x"00000041",
   254 => x"007f7f00",
   255 => x"41000000",
   256 => x"083e7741",
   257 => x"01020008",
   258 => x"02020301",
   259 => x"7f7f0001",
   260 => x"7f7f7f7f",
   261 => x"0808007f",
   262 => x"3e3e1c1c",
   263 => x"7f7f7f7f",
   264 => x"1c1c3e3e",
   265 => x"10000808",
   266 => x"187c7c18",
   267 => x"10000010",
   268 => x"307c7c30",
   269 => x"30100010",
   270 => x"1e786060",
   271 => x"66420006",
   272 => x"663c183c",
   273 => x"38780042",
   274 => x"6cc6c26a",
   275 => x"00600038",
   276 => x"00006000",
   277 => x"5e0e0060",
   278 => x"0e5d5c5b",
   279 => x"c24c711e",
   280 => x"4dbff1f7",
   281 => x"1ec04bc0",
   282 => x"c702ab74",
   283 => x"48a6c487",
   284 => x"87c578c0",
   285 => x"c148a6c4",
   286 => x"1e66c478",
   287 => x"dfee4973",
   288 => x"c086c887",
   289 => x"efef49e0",
   290 => x"4aa5c487",
   291 => x"f0f0496a",
   292 => x"87c6f187",
   293 => x"83c185cb",
   294 => x"04abb7c8",
   295 => x"2687c7ff",
   296 => x"4c264d26",
   297 => x"4f264b26",
   298 => x"c24a711e",
   299 => x"c25af5f7",
   300 => x"c748f5f7",
   301 => x"ddfe4978",
   302 => x"1e4f2687",
   303 => x"4a711e73",
   304 => x"03aab7c0",
   305 => x"e0c287d3",
   306 => x"c405bfdb",
   307 => x"c24bc187",
   308 => x"c24bc087",
   309 => x"c45bdfe0",
   310 => x"dfe0c287",
   311 => x"dbe0c25a",
   312 => x"9ac14abf",
   313 => x"49a2c0c1",
   314 => x"fc87e8ec",
   315 => x"dbe0c248",
   316 => x"effe78bf",
   317 => x"4a711e87",
   318 => x"721e66c4",
   319 => x"e9dfff49",
   320 => x"4f262687",
   321 => x"dbe0c21e",
   322 => x"dcff49bf",
   323 => x"f7c287d9",
   324 => x"bfe848e9",
   325 => x"e5f7c278",
   326 => x"78bfec48",
   327 => x"bfe9f7c2",
   328 => x"ffc3494a",
   329 => x"2ab7c899",
   330 => x"b0714872",
   331 => x"58f1f7c2",
   332 => x"5e0e4f26",
   333 => x"0e5d5c5b",
   334 => x"c7ff4b71",
   335 => x"e4f7c287",
   336 => x"7350c048",
   337 => x"fedbff49",
   338 => x"4c497087",
   339 => x"eecb9cc2",
   340 => x"87cfcb49",
   341 => x"c24d4970",
   342 => x"bf97e4f7",
   343 => x"87e4c105",
   344 => x"c24966d0",
   345 => x"99bfedf7",
   346 => x"d487d705",
   347 => x"f7c24966",
   348 => x"0599bfe5",
   349 => x"497387cc",
   350 => x"87cbdbff",
   351 => x"c1029870",
   352 => x"4cc187c2",
   353 => x"7587fdfd",
   354 => x"87e3ca49",
   355 => x"c6029870",
   356 => x"e4f7c287",
   357 => x"c250c148",
   358 => x"bf97e4f7",
   359 => x"87e4c005",
   360 => x"bfedf7c2",
   361 => x"9966d049",
   362 => x"87d6ff05",
   363 => x"bfe5f7c2",
   364 => x"9966d449",
   365 => x"87caff05",
   366 => x"daff4973",
   367 => x"987087c9",
   368 => x"87fefe05",
   369 => x"d7fb4874",
   370 => x"5b5e0e87",
   371 => x"f40e5d5c",
   372 => x"4c4dc086",
   373 => x"c47ebfec",
   374 => x"f7c248a6",
   375 => x"c178bff1",
   376 => x"c71ec01e",
   377 => x"87cafd49",
   378 => x"987086c8",
   379 => x"ff87ce02",
   380 => x"87c7fb49",
   381 => x"ff49dac1",
   382 => x"c187ccd9",
   383 => x"e4f7c24d",
   384 => x"c302bf97",
   385 => x"87c0c987",
   386 => x"bfe9f7c2",
   387 => x"dbe0c24b",
   388 => x"ebc005bf",
   389 => x"49fdc387",
   390 => x"87ebd8ff",
   391 => x"ff49fac3",
   392 => x"7387e4d8",
   393 => x"99ffc349",
   394 => x"49c01e71",
   395 => x"7387c6fb",
   396 => x"29b7c849",
   397 => x"49c11e71",
   398 => x"c887fafa",
   399 => x"87c1c686",
   400 => x"bfedf7c2",
   401 => x"dd029b4b",
   402 => x"d7e0c287",
   403 => x"dec749bf",
   404 => x"05987087",
   405 => x"4bc087c4",
   406 => x"e0c287d2",
   407 => x"87c3c749",
   408 => x"58dbe0c2",
   409 => x"e0c287c6",
   410 => x"78c048d7",
   411 => x"99c24973",
   412 => x"c387ce05",
   413 => x"d7ff49eb",
   414 => x"497087cd",
   415 => x"c20299c2",
   416 => x"734cfb87",
   417 => x"0599c149",
   418 => x"f4c387ce",
   419 => x"f6d6ff49",
   420 => x"c2497087",
   421 => x"87c20299",
   422 => x"49734cfa",
   423 => x"ce0599c8",
   424 => x"49f5c387",
   425 => x"87dfd6ff",
   426 => x"99c24970",
   427 => x"c287d502",
   428 => x"02bff5f7",
   429 => x"c14887ca",
   430 => x"f9f7c288",
   431 => x"87c2c058",
   432 => x"4dc14cff",
   433 => x"99c44973",
   434 => x"c387ce05",
   435 => x"d5ff49f2",
   436 => x"497087f5",
   437 => x"dc0299c2",
   438 => x"f5f7c287",
   439 => x"c7487ebf",
   440 => x"c003a8b7",
   441 => x"486e87cb",
   442 => x"f7c280c1",
   443 => x"c2c058f9",
   444 => x"c14cfe87",
   445 => x"49fdc34d",
   446 => x"87cbd5ff",
   447 => x"99c24970",
   448 => x"87d5c002",
   449 => x"bff5f7c2",
   450 => x"87c9c002",
   451 => x"48f5f7c2",
   452 => x"c2c078c0",
   453 => x"c14cfd87",
   454 => x"49fac34d",
   455 => x"87e7d4ff",
   456 => x"99c24970",
   457 => x"87d9c002",
   458 => x"bff5f7c2",
   459 => x"a8b7c748",
   460 => x"87c9c003",
   461 => x"48f5f7c2",
   462 => x"c2c078c7",
   463 => x"c14cfc87",
   464 => x"acb7c04d",
   465 => x"87d1c003",
   466 => x"c14a66c4",
   467 => x"026a82d8",
   468 => x"6a87c6c0",
   469 => x"7349744b",
   470 => x"c31ec00f",
   471 => x"dac11ef0",
   472 => x"87cef749",
   473 => x"987086c8",
   474 => x"87e2c002",
   475 => x"c248a6c8",
   476 => x"78bff5f7",
   477 => x"cb4966c8",
   478 => x"4866c491",
   479 => x"7e708071",
   480 => x"c002bf6e",
   481 => x"bf6e87c8",
   482 => x"4966c84b",
   483 => x"9d750f73",
   484 => x"87c8c002",
   485 => x"bff5f7c2",
   486 => x"87faf249",
   487 => x"bfdfe0c2",
   488 => x"87ddc002",
   489 => x"87c7c249",
   490 => x"c0029870",
   491 => x"f7c287d3",
   492 => x"f249bff5",
   493 => x"49c087e0",
   494 => x"c287c0f4",
   495 => x"c048dfe0",
   496 => x"f38ef478",
   497 => x"5e0e87da",
   498 => x"0e5d5c5b",
   499 => x"c24c711e",
   500 => x"49bff1f7",
   501 => x"4da1cdc1",
   502 => x"6981d1c1",
   503 => x"029c747e",
   504 => x"a5c487cf",
   505 => x"c27b744b",
   506 => x"49bff1f7",
   507 => x"6e87f9f2",
   508 => x"059c747b",
   509 => x"4bc087c4",
   510 => x"4bc187c2",
   511 => x"faf24973",
   512 => x"0266d487",
   513 => x"da4987c7",
   514 => x"c24a7087",
   515 => x"c24ac087",
   516 => x"265ae3e0",
   517 => x"0087c9f2",
   518 => x"00000000",
   519 => x"00000000",
   520 => x"1e000000",
   521 => x"c8ff4a71",
   522 => x"a17249bf",
   523 => x"1e4f2648",
   524 => x"89bfc8ff",
   525 => x"c0c0c0fe",
   526 => x"01a9c0c0",
   527 => x"4ac087c4",
   528 => x"4ac187c2",
   529 => x"4f264872",
   530 => x"d6e2c21e",
   531 => x"b9c149bf",
   532 => x"59dae2c2",
   533 => x"c348d4ff",
   534 => x"d0ff78ff",
   535 => x"78e1c048",
   536 => x"c148d4ff",
   537 => x"7131c478",
   538 => x"48d0ff78",
   539 => x"2678e0c0",
   540 => x"e2c21e4f",
   541 => x"f2c21eca",
   542 => x"fcfd49d8",
   543 => x"86c487c7",
   544 => x"c3029870",
   545 => x"87c0ff87",
   546 => x"35314f26",
   547 => x"205a484b",
   548 => x"46432020",
   549 => x"00000047",
   550 => x"5e0e0000",
   551 => x"0e5d5c5b",
   552 => x"bfe5f7c2",
   553 => x"c3e4c24a",
   554 => x"724c49bf",
   555 => x"ff4d71bc",
   556 => x"c087ebc6",
   557 => x"d049744b",
   558 => x"e7c00299",
   559 => x"48d0ff87",
   560 => x"ff78e1c8",
   561 => x"78c548d4",
   562 => x"99d04975",
   563 => x"c387c302",
   564 => x"e4c278f0",
   565 => x"817349f1",
   566 => x"d4ff4811",
   567 => x"d0ff7808",
   568 => x"78e0c048",
   569 => x"832d2cc1",
   570 => x"ff04abc8",
   571 => x"c5ff87c7",
   572 => x"e4c287e4",
   573 => x"f7c248c3",
   574 => x"2678bfe5",
   575 => x"264c264d",
   576 => x"004f264b",
   577 => x"1e000000",
   578 => x"48c9e7c1",
   579 => x"e4c250de",
   580 => x"d9fe49da",
   581 => x"48c087f1",
   582 => x"544a4f26",
   583 => x"5254554f",
   584 => x"52414e55",
   585 => x"f21e0043",
   586 => x"edfd87df",
   587 => x"2687f887",
   588 => x"261e164f",
   589 => x"3d362e25",
   590 => x"3d362e3e",
  others => ( x"00000000")
);

-- Xilinx Vivado attributes
attribute ram_style: string;
attribute ram_style of ram: signal is "block";

signal q_local : std_logic_vector((NB_COL * COL_WIDTH)-1 downto 0);

signal wea : std_logic_vector(NB_COL - 1 downto 0);

begin

	output:
	for i in 0 to NB_COL - 1 generate
		q((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= q_local((i+1) * COL_WIDTH - 1 downto i * COL_WIDTH);
	end generate;
    
    -- Generate write enable signals
    -- The Block ram generator doesn't like it when the compare is done in the if statement it self.
    wea <= bytesel when we = '1' else (others => '0');

    process(clk)
    begin
        if rising_edge(clk) then
            q_local <= ram(to_integer(unsigned(addr)));
            for i in 0 to NB_COL - 1 loop
                if (wea(NB_COL-i-1) = '1') then
                    ram(to_integer(unsigned(addr)))((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= d((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH);
                end if;
            end loop;
        end if;
    end process;

end arch;

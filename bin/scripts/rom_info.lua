dev.reset();
--rom.write(0xA13000, 0xFFFF);
--rom.write(0xA13008, 0xFFFF);
--rom.write(0xA13010, 0xFFFF);
--rom.write(0xA13018, 0xFFFF);
--rom.write(0xA13020, 0xFFFF);
--rom.write(0xA13030, 0xFFFF);
--rom.write(0xA13040, 0xFFFF);
--rom.write(0xA13060, 0xFFFF);
print(string.format(	"ROM NAME:\r\n"..
			"-GoodGEN: '%s';\r\n"..
			"-Domestic: '%s';\r\n"..
			"-Overseas: '%s';\r\n\r\n"..
			"SIZE:\r\n%Xh bytes",
	rom.name.good(),
	rom.name.dom(),
	rom.name.ovr(),
	rom.size()));
print("ROM's header:");
print(rom.read_word(0, 0x100, true), ascii);
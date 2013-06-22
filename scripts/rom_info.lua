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
print(rom.read(0, 0x200, true), ascii);
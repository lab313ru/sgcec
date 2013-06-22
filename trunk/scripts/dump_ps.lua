local name = rom.saveto();
local f = io.open(name, "ab+");
print("Prepare to dump PS...");
rom.read(0x18010, 0x200);
rom.read(0x0, 2);
rom.write(0xA13001, 3);
rom.write(0xA13003, 0);
rom.write(0xA13001, 1);
rom.read(0x0, 2);
rom.write(0xA13001, 3);
rom.write(0xA13003, 0);
rom.write(0xA13001, 1);
print("Dummy reading...");
rom.read(0x280000, 0x80000);

for i = 0, 0xF do
	rom.read(0x18010, 0x200);
	rom.read(0x0, 2);
	rom.write(0xA13001, 3);
	rom.write(0xA13003, 0);
	rom.write(0xA13001, 1);
	rom.read(0x0, 2);
	rom.write(0xA13001, 3);
	rom.write(0xA13003, i);
	rom.write(0xA13001, 1);
	print(string.format("Reading of %X-bank...", i));
	f:write(rom.read(0x280000, 0x80000, true));
end
f:close();
print(string.format("Successfully dumped to: %s", name));
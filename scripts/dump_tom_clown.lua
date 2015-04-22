--local name = rom.saveto();
--local f = io.open(name, "wb+");
dev.reset();

for m = 0, 0xFF do
	rom.write(0x402000, 4);
end;

for m = 0, 0xFF do
	rom.write(0x404000, 0);
end
for m = 0, 0xFF do
	rom.write(0x400000, 1);
end

rom.read(0, 4);
rom.read(4, 4);

print(rom.read(0x2000, 0x200, true), ascii);

--f:write(rom.read(0x0, 0x80000, true));
--f:close();
--print(string.format("Successfully dumped to: %s", name));
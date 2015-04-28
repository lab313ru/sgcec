dev.reset();

for m = 0, 0xFF do
rom.write_byte(0x402000, 4);
end;

for m = 0, 0xFF do
rom.write_byte(0x404000, 0);
end
for m = 0, 0xFF do
rom.write_byte(0x400000, 1);
end

--print(rom.read_word(0x2000, 0x100, true), ascii);

local name = "test_dump.bin";
local f = io.open(name, "wb+");

f:write(rom.read_word(0, 0x40000, true));
f:close();
print(string.format("Successfully dumped to: %s", name));
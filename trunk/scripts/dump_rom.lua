local f = io.open(rom.saveto(), "wb+");
print(string.format("ROM NAME: '%s'\r\nSIZE: %Xh bytes", rom.name.good(), rom.size()));
f:write(rom.dump());
f:flush();
f:close();
print("Cart was successfully dumped!");
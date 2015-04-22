/*
    SGC Explorer - Sega Genesis Cartridge Explorer
    Copyright (c) 2011-2013 - Bruno Freitas - bootsector@ig.com.br

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/* Maximum string size for serialReadString() function*/
#define MAX_SERIAL_STRING_SIZE 128

/* ROM address SPI pins */
int addrClockPin = 15;
int addrLatchPin = 16;
int addrDataPin = 17;

/* ROM data pins */
#define DATA_PINS 16
int dataPin[DATA_PINS] = {27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}; // LSB - MSB

/* !CE pin */
int CEPin = 18;

/* !OE pin */
int OEPin = 19;

/* !LWR pin */
int LWRPin = 20;

/* !TIME pin */
int TIMEPin = 21;

/* !CART pin */
int CARTPin = 22;

/* !AS pin */
int ASPin = 40;

/* !VRES pin */
int VRESPin = 43;

/* !MRES pin */
int MRESPin = 24;

/* !UWR pin */
int UWRPin = 44;

/* Command received via serial port */
char *command;

/* Operations delay */
uint16_t opDelay = 10;

void setup() {
    pinMode(addrClockPin, OUTPUT);
    pinMode(addrLatchPin, OUTPUT);
    pinMode(addrDataPin, OUTPUT);

    pinMode(CEPin, OUTPUT);
    pinMode(OEPin, OUTPUT);
    pinMode(LWRPin, OUTPUT);
    pinMode(TIMEPin, OUTPUT);
    pinMode(ASPin, OUTPUT);
    pinMode(VRESPin, OUTPUT);
    pinMode(MRESPin, OUTPUT);

    Serial.begin(115200);
}

void CELow() {
    digitalWrite(CEPin, LOW);
}

void CEHigh() {
    digitalWrite(CEPin, HIGH);
}

void OELow() {
    digitalWrite(OEPin, LOW);
}

void OEHigh() {
    digitalWrite(OEPin, HIGH);
}

void LWRLow() {
    digitalWrite(LWRPin, LOW);
}

void LWRHigh() {
    digitalWrite(LWRPin, HIGH);
}

void TIMELow() {
    digitalWrite(TIMEPin, LOW);
}

void TIMEHigh() {
    digitalWrite(TIMEPin, HIGH);
}

void ASLow() {
    digitalWrite(ASPin, LOW);
}

void ASHigh() {
    digitalWrite(ASPin, HIGH);
}

void VRESLow() {
    digitalWrite(VRESPin, LOW);
}

void VRESHigh() {
    digitalWrite(VRESPin, HIGH);
}

void MRESLow() {
    digitalWrite(MRESPin, LOW);
}

void MRESHigh() {
    digitalWrite(MRESPin, HIGH);
}

void UWRHigh() {
    digitalWrite(UWRPin, LOW);
}

void UWRLow() {
    digitalWrite(UWRPin, HIGH);
}

void shiftOut24bit(int clockPin, int latchPin, int dataPin, unsigned long value) {
    digitalWrite(latchPin, LOW);
    shiftOut(dataPin, clockPin, MSBFIRST, (value & 0x00FF0000) >> 16);
    shiftOut(dataPin, clockPin, MSBFIRST, (value & 0x0000FF00) >> 8);
    shiftOut(dataPin, clockPin, MSBFIRST, (value & 0x000000FF));
    digitalWrite(latchPin, HIGH);
}

word wordRead(unsigned long addr, int CARTState) {
    word data = 0;
    int i;

    for(i = 0; i < DATA_PINS; i++) {
        pinMode(dataPin[i], INPUT);
    }

    CEHigh();
    OEHigh();
    LWRHigh();
    UWRHigh();

    shiftOut24bit(addrClockPin, addrLatchPin, addrDataPin, addr >> 1);

    if((CARTState && addr <= 0x3FFFFF) || (!CARTState && addr >= 0x400000 && addr <= 0x7FFFFF)) {
        CELow();
    }

    if(addr <= 0xDFFFFF) {
        OELow();
    }

    if(addr >= 0xA13000 && addr <= 0xA130FF) {
        TIMELow();
    }

    ASLow();

    delayMicroseconds(opDelay);

    for(i = 0; i < DATA_PINS; i++) {
        if(digitalRead(dataPin[i])) {
            data |= (1 << i);
        }
    }

    TIMEHigh();
    ASHigh();
    LWRHigh();
    UWRHigh();
    CEHigh();
    OEHigh();

    return data;
}

byte byteRead(unsigned long addr, int CARTState) {
    word data;
    byte b;

    data = wordRead(addr, CARTState);

    if(addr % 2) {
        b = data & 0x00FF;
    } else {
        b = (data & 0xFF00) >> 8;
    }

    return b;
}

void wordWrite(unsigned long addr, word value, int CARTState) {
    int i;

    CEHigh();
    OEHigh();
    LWRHigh();
    UWRHigh();

    shiftOut24bit(addrClockPin, addrLatchPin, addrDataPin, addr >> 1);

    if((CARTState && addr <= 0x3FFFFF) || (!CARTState && addr >= 0x400000 && addr <= 0x7FFFFF)) {
        CELow();
    }

    if(addr >= 0xA13000 && addr <= 0xA130FF) {
        TIMELow();
    }

    ASLow();

    for(i = 0; i <= DATA_PINS; i++) {
        pinMode(dataPin[i], OUTPUT);

        if(value & (1 << i)) {
            digitalWrite(dataPin[i], HIGH);
        } else {
            digitalWrite(dataPin[i], LOW);
        }
    }

    LWRLow();
    UWRLow();

    delayMicroseconds(opDelay);

    LWRHigh();
    UWRHigh();
    TIMEHigh();
    ASHigh();
    CEHigh();
}

void byteWrite(unsigned long addr, byte value, int CARTState) {
    int i;

    CEHigh();
    OEHigh();
    LWRHigh();
    UWRHigh();

    shiftOut24bit(addrClockPin, addrLatchPin, addrDataPin, addr >> 1);

    if((CARTState && addr <= 0x3FFFFF) || (!CARTState && addr >= 0x400000 && addr <= 0x7FFFFF)) {
        CELow();
    }

    if(addr >= 0xA13000 && addr <= 0xA130FF) {
        TIMELow();
    }

    ASLow();

    value = ((value & 0xFF) | ((value & 0xFF) << 8));

    for(i = 0; i <= DATA_PINS; i++) {
        pinMode(dataPin[i], OUTPUT);

        if(value & (1 << i)) {
            digitalWrite(dataPin[i], HIGH);
        } else {
            digitalWrite(dataPin[i], LOW);
        }
    }

    if(addr % 2) {
        LWRLow();
    } else {
        UWRLow();
    }

    delayMicroseconds(opDelay);

    LWRHigh();
    UWRHigh();
    TIMEHigh();
    ASHigh();
    CEHigh();
}

long romSize() {
    long w1, w2;

    w1 = wordRead(0x1A4, !digitalRead(CARTPin));
    w2 = wordRead(0x1A6, !digitalRead(CARTPin));

    return ((w1 << 16) | w2) + 1;
}

char *serialReadString() {
    static char serialString[MAX_SERIAL_STRING_SIZE];
    int c = 0;
    int count = 0;

    serialString[0] = 0;

    do {
        if (Serial.available() > 0) {
            c = Serial.read();

            if (c == 13)
                break;

            serialString[count++] = (char) c;
        }
    } while (count < MAX_SERIAL_STRING_SIZE - 1);

    serialString[count] = 0;

    return serialString;
}

char *getStrToken(char *str, int pos) {
    static char tmpString[MAX_SERIAL_STRING_SIZE];
    const char delimiters[] = " ";
    char *token;
    int i = 0;

    strcpy(tmpString, str);
    token = strtok(tmpString, delimiters);

    while(token != NULL) {
        if(i == pos)
            return token;

        token = strtok(NULL, delimiters);
        i++;
    }

    return token;
}

void ROMReadByte() {
    char *token;
    unsigned long addr;
    unsigned long count, i;
    byte data;

    token = getStrToken(command, 1);
    if(token == NULL)
        return;

    addr = strtoul(token, NULL, 16);

    token = getStrToken(command, 2);
    if(token == NULL)
        return;

    count = strtoul(token, NULL, 16);

    for(i = 0L; i < count; i++) {
        data = byteRead(addr + i, !digitalRead(CARTPin));
        Serial.print(data, BYTE);
    }
}

void ROMReadWord() {
    char *token;
    unsigned long addr;
    unsigned long count, i;
    word data;

    token = getStrToken(command, 1);
    if(token == NULL)
        return;

    addr = strtoul(token, NULL, 16);

    token = getStrToken(command, 2);
    if(token == NULL)
        return;

    count = strtoul(token, NULL, 16);

    for(i = 0L; i < count; i++) {
        data = wordRead(addr + (i * 2), !digitalRead(CARTPin));

        Serial.print((data & 0xFF00) >> 8, BYTE);
        Serial.print(data & 0xFF, BYTE);
    }
}

void ROMWriteByte() {
    char *token;
    unsigned long addr;
    byte value;

    token = getStrToken(command, 1);
    if(token == NULL)
        return;

    addr = strtoul(token, NULL, 16);

    token = getStrToken(command, 2);
    if(token == NULL)
        return;

    value = (byte) strtoul(token, NULL, 16);

    byteWrite(addr, value, !digitalRead(CARTPin));
}

void ROMWriteWord() {
    char *token;
    unsigned long addr;
    word value;

    token = getStrToken(command, 1);
    if(token == NULL)
        return;

    addr = strtoul(token, NULL, 16);

    token = getStrToken(command, 2);
    if(token == NULL)
        return;

    value = (word) strtoul(token, NULL, 16);

    wordWrite(addr, value, !digitalRead(CARTPin));
}

void setDelay() {
    char *token;

    token = getStrToken(command, 1);
    if(token == NULL)
        return;

    opDelay = (uint16_t) strtoul(token, NULL, 10);
}

void Delay() {
    char *token;
    uint32_t _delay;

    token = getStrToken(command, 1);
    if(token == NULL)
        return;

    _delay = (uint32_t) strtoul(token, NULL, 10);

    delay(_delay);
}

void printRomSize() {
        Serial.println(romSize());
}

void doRESET() {
    VRESLow();
    delayMicroseconds(100);
    VRESHigh();
}

void doINFO() {
    Serial.println("Welcome to SGC Explorer - v2.3.15");
    Serial.println("Based on Bruno Freitas's SGCE v2.3.12");
    Serial.println("04/2015 - Dr. MefistO[Lab 313]");
    Serial.println("(c)05/2011 - bootsector@ig.com.br");
    Serial.println();
}

void loop() {
    char *token;

    CEHigh();
    OEHigh();
    LWRHigh();
    TIMEHigh();
    ASHigh();
    VRESHigh();
    MRESHigh();

    while(!Serial.dtr());

    for (;;) {
        command = serialReadString();

        token = getStrToken(command, 0);
        if(token == NULL)
            continue;

        if (strncasecmp(token, "READ_BYTE", MAX_SERIAL_STRING_SIZE) == 0) {
            ROMReadByte();
        } else if (strncasecmp(token, "READ_WORD", MAX_SERIAL_STRING_SIZE) == 0) {
            ROMReadWord();
        } else if (strncasecmp(token, "WRITE_BYTE", MAX_SERIAL_STRING_SIZE) == 0) {
            ROMWriteByte();
        } else if (strncasecmp(token, "WRITE_WORD", MAX_SERIAL_STRING_SIZE) == 0) {
            ROMWriteWord();
        } else if (strncasecmp(token, "ROMSIZE", MAX_SERIAL_STRING_SIZE) == 0) {
            printRomSize();
        } else if (strncasecmp(token, "SET_DELAY", MAX_SERIAL_STRING_SIZE) == 0) {
            setDelay();
        } else if (strncasecmp(token, "DELAY", MAX_SERIAL_STRING_SIZE) == 0) {
            Delay();
        } else if (strncasecmp(token, "TIME_LOW", MAX_SERIAL_STRING_SIZE) == 0) {
            TIMELow();
        } else if (strncasecmp(token, "TIME_HIGH", MAX_SERIAL_STRING_SIZE) == 0) {
            TIMEHigh();
        } else if (strncasecmp(token, "RESET", MAX_SERIAL_STRING_SIZE) == 0) {
            doRESET();
        } else if (strncasecmp(token, "INFO", MAX_SERIAL_STRING_SIZE) == 0) {
            doINFO();
        } else {
            Serial.println("UNKN");
        }
    }
}

// Packet 5 - Client -> Server (3 bytes)
// Client request shape: 0x06 opcode + 16-bit value. Packet 7 has the same shape (not yet verified).

struct AdvanceSequence {
    u8 Opcode;              // 0x06
    be u16 Value;           // 0x512e in this sample. Not found in Packets 4/6 or the ServerList.
};

AdvanceSequence packet @ 0x0;

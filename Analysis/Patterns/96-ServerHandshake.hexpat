import std.io;

struct ServerHandshake {
    u8 PacketType;            // 96
    u8 SubTypes[2];           // 02 01
    u8 ProtocolVersion[3];    // 39 00 00
    u8 Parameters[4];         // 3c 00 80 02 (Conf Flags or block length descriptors?)
    u8 EncryptedSession[256]; // Encrypted challenge token?
    u8 Footer[10];            // Trailing cipher parameters (All 0)
};

ServerHandshake packet @ 0x0;
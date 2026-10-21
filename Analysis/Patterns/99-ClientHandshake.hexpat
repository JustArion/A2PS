// ASN.1 SEQUENCE with a ASN.1 INTEGER
struct ClientHandshake {
    u8 PacketType;              // 99
    u8 SubTypes[2];             // 02 00
    u8 ProtocolVersion[3]       // 39 8c 02
                                // We always thought of this as a ProtocolVersion or a build constant
                                // Perhaps it's neither, perhaps the 39 is the protocol version, and the 8c 02 are some format parameters
                                //
    u8 AsnTag;                  // 0x30 (SEQUENCE)
    u8 LengthFormat;            // 0x82 (Long-form length indicator)
    be u16 AsnLength;           // 0x0108 (264 bytes, big-endian)
    u8 RsaContent[264];         // Key exchange data
    u8 Footer[5];               // af 7d 97 07 b3 (Trailing cipher parameters)
};

ClientHandshake packet @ 0x0;
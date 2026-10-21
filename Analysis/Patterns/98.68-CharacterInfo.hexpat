// Packet 6, two-character sample (150 bytes). The one-character sample (101 bytes)
// Between the samples: byte 0x06 went 02 -> 03 and an extra 0x01 byte sits at offset 0x01 (see Header).
// Byte 0x16 stayed 0x01, so it is not a character count.

// Heavily WIP due to lots of unused blocks of data

using NetString = std::string::SizedString<u8>;
using ServerId = le u16;

struct Header {
    u8 Opcode;                  // 0x98 here, 0x68 in the one-character sample
    u8 Unknown1;                // 0x01 here, not present in the one-character sample
    u8 TokenLength;             // 0x0b = 11
    u8 ProtocolVersion[3];      // 39 00 00
    u8 RecordCount;             // Number of timestamp blocks. 3 here (CharA creation, CharA logout, CharB logout), 2 in the one-character sample
    ServerId Server;            // 0x0838 = LIVE_Dark_004
    SizedString Token;          // len 0x0c: "$TOKEN" (11 bytes total)
    u8 Unknown16;               // 0x01, unchanged between samples
    u8 Padding[11];             // zeros
};

// Timestamp block: size byte, kind (00 00 00 02), u64 UnixMillis, u64 SecondStamp. Size byte is 0x14 (20) on the CharA block.
// UnixMillis is that character's last logout time, not its entry time (confirmed on CharA and CharB).
// CharA: 19:32:00.000 UTC (user's logout ~19:32:00; entry ~19:30:00).
// CharB: 19:45:00.000 UTC (user's logout ~19:45:00; entry ~19:44:00).
// SecondStamp is 0 until a character is marked for deletion. After CharB was marked it held 24h after the marking (one sample). Likely the scheduled deletion time.
// Size byte 0x23 on the second character does not match the 20 bytes that follow. Unresolved.
struct TimeBlock {
    u8 Size;
    be u32 Kind;                // 2
    u64 UnixMillis;             // LE ms since epoch
    u64 SecondStamp;            // LE ms. Zero normally; deletion time after marking (see above)
};

// CharA's creation block (45 bytes).
struct CreationBlock {
    u8 Size;                    // 0x2c = 44 bytes follow
    be u32 Kind;                // 2
    u64 CreatedUnixMs;          // Unix MS Timestamp
    u8 Unknown2f;               // Byte at 0x2f. 0x00 before CharB was marked for deletion, 0x10 after. Meaning unknown.
    u8 Zeros8[8];
    ServerId Server;            // 0x0838
    NetString Name;             // "CharA"
    u8 NameFlag;                // 0x2d. Per-character byte, meaning unknown.
    u8 Zeros11[11];
};

// Second character (48 bytes). No creation block in front of it.
struct SecondCharacter {
    ServerId Server;            // 0x0838
    NetString Name;             // len 0x0c: "CharB" (the bytes have no space and end in 0x30)
    u8 NameFlag;                // 0x01. Compare CharA's 0x2d.
    u8 Zeros11[11];
    TimeBlock Time;             // Creation value before its first logout; logout time after.
};

struct CharacterInfo {
    Header Header;              // 0x00 - 0x21
    CreationBlock CharA;        // 0x22 - 0x4e
    TimeBlock LastSessionEnd;   // 0x4f - 0x63. Last logout time; confirmed on CharA and CharB, not entry time
    SecondCharacter Second;     // 0x64 - 0x93
    u8 Trailer[2];              // 01 01
};

CharacterInfo packet @ 0x0;

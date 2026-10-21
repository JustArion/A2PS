// Packet 4 - Server -> Client. 103 bytes with opcode 0x6a, or 102 bytes with opcode 0x69.
// Same layout in both. The 0x69/0x6a split and the 102/103 size follow the account number length, not a different packet.
//
// Account = "<regional account number>:<GUID2>". The account number is per region, not per user.
//   NA East       (193.202.112.1)   1689583  (0x6a)
//   Europe        (193.202.112.93)  1711468  (0x6a)
//   NA West       (193.202.112.47)  826907   (0x69)
//   South America (193.202.112.160) 511091   (0x69)
//   Asia          (20.48.104.27)    1043563  (0x6a)
// GUID and GUID2 are new random v4 UUIDs in every capture.

// Payloads removed due to sensitive GUIDs

import std.string;
import std.time;

using NetString = std::string::SizedString<u8>;
using ServerId = le u16;
 
struct UserInfo {
    u8 Opcode;                                  // 0x6a (7-digit account) or 0x69 (6-digit account)
    u8 SubType;                                 // 0x06 - unknown
    u8 ProtocolVersion[3];                      // 39 00 00
    padding[1];                                 // 00
    NetString Guid;                             // len 0x24 (36): random v4 UUID, new in every capture
    u8 Unk0[3];                                 // 01 00 00
                                                // On Anomalous Packet: 02 38 08
    NetString Account;                          // len 0x2c (44) or 0x2b (43): "<regional account>:<GUID2>"
 
    // Trailing block, 12 bytes.
    // Working idea: the last server this account ENTERED (server selector > Enter), with or without characters.
    // Set on entry, so it is not limited to servers that have characters.
    // SelectedServer1/2 are equal in every sample.
    //   NA East: 0x0838 (LIVE_Dark_004). Account has characters there.
    //   Europe:  0x090F (LIVE_Dark_019). Account has no characters there. User did not make EU characters.
    //   NA West, SA, Azure: 0x0000 (no server entered in those captures).
    ServerId LastEntered;                       // EU: 13 09
    u8 CharacterCount;                          // 0x02 on NA East (original sample), 0x00 on the other regions
    std::time::EpochTime UnbannedTime;          // (Speculation) UnbannedTimestamp (when you'll be unbanned) or the ban timestamp
                                                // zeros on NA East, NA West, SA, Azure. Europe: 00 00 00 00
    ServerId LastEnteredLight;                  // Europe: 0x0527 (LIVE_Light_019), which is also the ServerId in the Europe character list (0x6c). 0 elsewhere
    ServerId LastEnteredDark;                   // EU: 13 09
    u8 Unk1;                                    // 0x03 in every sample
};
 
UserInfo packet @ 0x0;
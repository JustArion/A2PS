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
import type.leb128;
import type.guid;
import std.time;

using string = std::string::SizedString<u8>;
using ServerId = le u16;
using uleb = type::LEB128;

struct NetArray<T> {
    u8 Count;
    T Data[Count];
}   [[format("std::impl::format_array")]];

struct Header {
    uleb Length;                        // value + 2 - 4 = total frame size
    be u16 OpCode;                      // 3906
};

struct Packet<T> {
    Header Header;
    padding[2];                         // 00 00
    T Content [[inline]];
};

struct Account {
    padding[1];                         // 0s
    string SessionToken;                // v4 GUID
    u8 Trailer[2];                      // 01 00
    padding[1];                         // 0s
    string Account;                     // "<8 byte regional account id>:<GUID>"
    ServerId LastServerEntered;
    u8 Unk0;                            // 0x2 in 1 test (NA East), 0 on other ones and future ones
    std::time::EpochTime BannedTime;    // (u32) Speculation (All 0s), could be maintenence time remaining
    ServerId LastEnteredLight;          // Last Elyos server you entered
    ServerId LastEnteredDark;           // Last Asmodian server you entered
    u8 Unk1;                            // Always 0x3
};

Packet<Account> packet @ 0x0;
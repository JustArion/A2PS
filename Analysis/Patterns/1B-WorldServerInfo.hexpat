// Packet 12 - Server -> Client (24 bytes)
// Server Address and port for a requested server id

#pragma example 1b 0f 39 00 00 38 08 0e 31 39 33 2e 32 30 32 2e 31 31 32 2e 31 37 10 34
import std.string;

using NetString = std::string::SizedString<u8>;
using ServerId = le u16;
 
struct WorldServerInfo {
    u8 OpCode;              // 1B
    u8 SubType;             // 0F
    u8 ProtocolVersion[3];  // 39 00 00
    ServerId Server;        // 38 08
    NetString IpAddress;    // "193.202.112.17"
    le u16 Port;            // "13328"
};
 
WorldServerInfo packet @ 0x0;
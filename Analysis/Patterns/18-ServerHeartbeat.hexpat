// ServerHeartbeat (opcode 0x18, server -> client). 21 bytes.
// Sent every ~10 seconds during an idle login session (LoginIdle-EU: 420 messages over the capture).
// Layout confirmed on LoginIdle-EU.16.10.26 and MultiRegionCapture.
//
// Byte 0-4 are constant in every sample. Byte 5-9 is a 40-bit counter that increases by
// exactly 100,000,000 per message (100 ns ticks, so 10 s). It is probably server uptime
// (hypothesis, not confirmed). Byte 13-20 is Unix time in milliseconds (u64 LE).
// The upper 4 bytes of the timestamp are constant in the sample (a1 01 00 00).

import std.io;
import std.core;

struct Heartbeat {
    u8 Opcode;              // 0x18
    u8 SubType;             // 0x03 in every sample
    u8 ProtocolVersion[3];  // 0x39 00 00 in every sample (same value as the 39 in the ServerList header)
 
    u8 TickCounter[5];      // 40-bit little-endian. +100000000 per message (100 ns units)
    u8 Reserved[3];         // 00 00 00
 
    u64 UnixMillis;         // little-endian. +10000 per message, jitter of about 10 ms
};
 
Heartbeat packet @ 0x0;
 
std::print("Heartbeat: unix_ms={} tick={}", packet.UnixMillis, packet.TickCounter);
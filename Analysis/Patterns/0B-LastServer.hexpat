// Packet 0x0b - Server -> Client, 8 bytes. Sent after the login exchange, before WorldServerInfo (0x1b).
// (Hypothesis, not confirmed.)
//
// Working idea: the server the account last ENTERED (server selector > Enter). Set on entry, with or without characters.
// NA East (193.202.112.1, has characters on LIVE_Dark_004): 0b 0d 39 00 00 00 38 08 -> ServerId 0x0838
// NA West (193.202.112.47), SA (193.202.112.160), Azure (20.48.104.27), nothing entered in capture:
//                                                                     0b 0b 39 00 00 00 01 01 -> 0x0101
// Europe does not send this packet in the captures.
// In NA East it follows a 5-byte client message (type 0x08), which may be the "enter server" request. Not decoded.

import std.io;

using ServerId = le u16;
 
struct LastServer {
    u8 Opcode;              // 0x0b
    u8 Unknown1;            // 0x0d on NA East, 0x0b on the other regions. No pattern yet
    u8 ProtocolVersion[3];  // 39 00 00
    padding[1] Unknown2;    // 0x00
    ServerId Id;            // LE. 0x0838 NA East (LIVE_Dark_004). 0x0101 = nothing entered (sentinel?)
};
 
LastServer packet @ 0x0;
// Packet 12 - Server -> Client (24 bytes)
// Server Address and port for a requested server id

#pragma example 1b 0f 39 00 00 38 08 0e 31 39 33 2e 32 30 32 2e 31 31 32 2e 31 37 10 34

import std.string;
import std.array;
import type.leb128;

using string = std::string::SizedString<u8>;
using ServerId = le u16;
using uleb = type::LEB128;

struct NetArray<T> {
    u8 Count;
    T Data[Count];
}   [[format("std::impl::format_array")]];

struct Header {
    uleb Length;            // value + 2 - 4 = total frame size
    be u16 OpCode;          // 390F
};

struct Packet<T> {
    Header Header;
    padding[2];             // 00 00
    T Content [[inline]];
};

struct Redirect {
    ServerId Server;        // 38 08
    string IPAddress;       // 193.202.112.17
    le u16 Port;            // "13328"
};
 
Packet<Redirect> packet @ 0x0;
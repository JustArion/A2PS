#pragma example 0B 0D 39 00 00 00 38 08

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
    be u16 OpCode;          // 390D
};

struct Packet<T> {
    Header Header;
    padding[2];             // 00 00
    T Content [[inline]];
};

struct Join {
    padding[1];
    ServerId Server;
};
 
Packet<Join> packet @ 0x0;
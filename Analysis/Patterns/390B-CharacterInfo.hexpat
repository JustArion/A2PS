#pragma author JustArion
#pragma description Character information in AION 2

import std.string;
import std.io;
import std.core;
import std.array;
import std.string;
import type.leb128;

using string = std::string::SizedString<u8>;
using ServerId = le u16;
using uleb = type::LEB128;

struct NetArray<T> {
    u8 Count;
    T Data[Count];
}   [[format("std::impl::format_array")]];

struct Header {
    uleb Length;                    // value + 2 - 4 = total frame size
    be u16 OpCode;                  // 390B
};

struct Packet<T> {
    Header Header;
    padding[2];                     // 00 00
    T Content [[inline]];
};

enum ServerFaction : u8 {
    Light = 0x1,
    Dark = 0x2
};

bitfield GroupConfig {
    Entry0 : 2;
    Entry1 : 2;
    Entry2 : 2;
    Entry3 : 2;
};

struct ServerToken {
    ServerId ServerId;
    string Name;
    le u32 Level;
    u64 Experience;                 // Speculation
    u32 Unk;                        // For ServerTokens its 42 for light and 44 for dark
    
    ServerFaction Faction;          // Light or dark
    u64 EntryDate;
    u64 DeletionDate;

    // Always in groups of 4, 1 byte in size, each server gets 2 config bits
    if (std::core::array_index() % 4 == 0)
        GroupConfig Config;
} [[single_color]];

struct Character : ServerToken {} [[single_color]];

union Record {
    ServerToken Token;              // Token has a name starting with $
    Character Character;            // Identical structure to ServerToken
};

struct CharacterInfo {

    NetArray<Record> CharacterInfo;
    u8 Trailer[2];                  // 01 01
};

Packet<CharacterInfo> packet @ 0x0;
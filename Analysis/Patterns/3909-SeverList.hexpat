// ServerList (packet 8, server -> client). 491 bytes in NA East. Other regions: 1240 (EU), 277 (NA West), 330 (SA), 544 (Azure host).
// Layout: Header (7) + N x Server + Trailer (2: 01 01).
//
// Server record:
//   Id SeverId | Faction u8 | RealmId ServerId (== Id) | Reserved u16 (0) | NameLen u8 | Name
//   [Prefix u8, optional] | Flags u8 | CapacityPercent u8 | Trailer 3 bytes (50 01 00, or 3c 01 00 on Asia)
//
// Observation: prefix is present on every record with index % 4 == 0 (all 5 lists).

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
 
bitfield ServerFlags {
    IsNew : 1;                  // bit 0 (0x01). Set on most servers in the sample.
    IsRecommended : 1;          // bit 1 (0x02). (Speculation) The beta shows a "Recommended" tag
    CreationRestricted : 1;     // bit 2 (0x04). Set on the first 3 of each faction in NA East.
};

enum ServerCapacity : u8 {
    Normal = 0x1,
    Busy = 0x2,
    Full = 0x4
};

bitfield GroupConfig {
    Entry0 : 2;
    Entry1 : 2;
    Entry2 : 2;
    Entry3 : 2;
};
 
struct Server {
    /*
        NA East:
            Light @ 1101 (04 4D)
            Dark  @ 1201 (04 B1)
        (16 Servers)
        NA West:
            Light @ 1201 (04 B1)
            Dark  @ 2201 (08 99)
        (10 Servers)
        Europe:
            Light @ 1301 (08 9A)
            Dark  @ 2301 (08 FD)
        (46 Servers)
        South America:
            Light @ 1401 (05 79)
            Dark  @ 2401 (09 61)
        (12 Servers)
        Asia:
            Light @ 1501 (05 DD)
            Dark  @ 2501 (09 C5)
        (20 Servers)
    */
    ServerId Id;

    ServerFaction FactionId;    // Light or Dark
    ServerId RealmId;           // same value as Id in every record
    padding[2];                 // always 0
 
    string Name;
 

         
    // Always in groups of 4, 1 byte in size, each server gets 2 config bits
    // Unsure what the bits are for, each server in the group show bit 0 as set, and bit 1 as unset
    bool HasConfig = std::core::array_index() % 4 == 0; 
    if (HasConfig)
        GroupConfig Config;     // 0x55 (85) on every multiple of 4 except on the last one, then it's 0x05
 
    ServerFlags Flags;          // 0x05 is valid here (IsNew + CreationRestricted), e.g. LIVE_Dark_010 and LIVE_Dark_011 in EU
    u8 CapacityPercent;         // A percentage from 1 - 100 indicating how full the server is
    u8 BusyCapacityThreshold;   // The CapacityPercent needed to show as "Busy"


    u8 Trailer[2];              // 01 00
} [[single_color]];

fn GetCapacity(Server server) {
    if (server.CapacityPercent >= 100) 
        return ServerCapacity::Full;

    if (server.CapacityPercent >= server.BusyCapacityThreshold)
        return ServerCapacity::Busy;
    
    return ServerCapacity::Normal;
};

struct ServerList {

    NetArray<Server> Servers;
    u8 Trailer[2];                      // 01 01
};

Packet<ServerList> packet @ 0x0;

for (auto i = 0, i < packet.Content.Servers.Count, i += 1) {

    Server server @ addressof(packet.Content.Servers.Data[i]);
    ServerCapacity capacity = GetCapacity(server);
    std::print("{} | {} ({})",
        server.Name,
        server.Flags,
        capacity);
        
    if (std::core::array_index() % 4 == 0)
        std::print("Group Config: ({}-{}) - {}", i / 4, i, server.Config);
}
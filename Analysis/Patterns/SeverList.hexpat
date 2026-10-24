// ServerList (packet 8, server -> client). 491 bytes in NA East. Other regions: 1240 (EU), 277 (NA West), 330 (SA), 544 (Azure host).
// Layout: Header (7) + N x Server + Trailer (2: 01 01).
//
// Server record:
//   Id SeverId | Faction u8 | RealmId ServerId (== Id) | Reserved u16 (0) | NameLen u8 | Name
//   [Prefix u8, optional] | Flags u8 | CapacityPercent u8 | Trailer 3 bytes (50 01 00, or 3c 01 00 on Asia)
//
// Prefix detection: the trailer's last two bytes are always 01 00. The prefix is present exactly when
// those bytes sit 1 byte further on (trailer starts at the prefix + 1). Checked on all 5 region lists:
// every record ends exactly on the list's 01 01 trailer. Byte value (0x55 or 0x05) is NOT used to decide.
// Observation: prefix is present on every record with index % 4 == 0 (all 5 lists).

import std.io;
import std.core;
import std.array;
import std.string;

using NetString = std::string::SizedString<u8>;
using ServerId = le u16;

enum Region : u16 {
    NAEast = 0xED03,            // Confirmed: login at 193.202.112.1   (Cloudflare, Ireland)
    NAWest = 0x9702,            // Confirmed: login at 193.202.112.47  (Cloudflare, Ireland)
    Europe = 0xDA09,            // Confirmed: login at 193.202.112.93  (Cloudflare, Ireland)
    SouthAmerica = 0xCC02,      // Confirmed: login at 193.202.112.160 (Cloudflare, Ireland)
    Asia = 0xA204               // Confirmed: login at 20.48.104.27 (Microsoft Azure, Japan)
};
 
struct Header {
    be Region RegionId;         // ed 03 on NA East. Other regions use their own value
    u8 SubType;                 // The first byte changes between messages (09, 06, 0b, 0d, 0f, 01), so it may be per-message.
    u8 ProtocolVersion[3];      // 39 00 00. "39 00 00" is a build constant that appears in most server packets.
    u8 ServerCount;             // NA East 0x12 = 18. EU 46, NA West 10, SA 12, Azure host 20
};
 
enum ServerFaction : u8 {
    Light = 0x1,
    Dark = 0x2
};
 
bitfield ServerFlags {
    IsNew : 1;                  // bit 0 (0x01). Set on most servers in the sample.
    IsRecommended : 1;          // bit 1 (0x02). (Speculation) The beta shows a "Recommended" tag
    CreationRestricted : 1;     // bit 2 (0x04). Set on the first 3 of each faction in NA East.
    padding : 2;
    EarlyAccessServer : 1;      // bit 5 (0x20). Guess. Set on 1 NA server
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
 
    NetString Name;
 
    // Prefix sentinel check. $ is the position of the candidate prefix byte.
    // If the prefix is absent, this byte is the Flags byte and bytes +4/+5 are trailer bytes 2-3 of the next record.
    // Trailer's 2nd and 3rd bytes are always 01 00, so the check below only passes when the prefix is present.
    bool HasPrefix = std::mem::read_unsigned($ + 4, 1) == 0x01 && std::mem::read_unsigned($ + 5, 1) == 0x00;
    if (HasPrefix)
        u8 Prefix;              // 0x55 (85) on every multiple of 4 except on the last one, then it's 0x05
 
    ServerFlags Flags;          // 0x05 is valid here (IsNew + CreationRestricted), e.g. LIVE_Dark_010 and LIVE_Dark_011 in EU
    u8 CapacityPercent;         // 65% is "Busy" on Asia
 
    // Trailer: 50 01 00 in every record in NA East, EU, NA West, SA.
    // ! Leading 50 could actually be a server's capacity before it's designated as "Busy"
    // Asia (Azure host): 5 of 20 records end in 3c 01 00. The first byte varies, 01 00 does not.
    // The trailer is the sentinel that ends each record, so records have variable size.
    u8 Trailer[3];
};
 
struct ServerList {
    Header Header;
    std::Array<Server, Header.ServerCount> Servers;
    u8 Trailer[2];              // 01 01
};

ServerList packet @ 0x0;

 
std::print("Region: {}", packet.Header.RegionId);
 
for (auto i = 0, i < packet.Header.ServerCount, i += 1) {
    Server server @ addressof(packet.Servers.data[i]);
    std::print("{} | {} | cap={}%",
        server.Name,
        server.Flags,
        server.CapacityPercent);
        
    // Name ends at NameLength's address + 1 + length.
    // Flags comes right after Name, or one byte later when Prefix is present.
    bool hasPrefix = addressof(packet.Servers.data[i].Flags) > addressof(packet.Servers.data[i].Name.size) + 1 + packet.Servers.data[i].Name.size;
    if (hasPrefix)
    {
        std::print("Prefix: ({}-{}) - {}", i / 4, i, server.Prefix);
    }
}
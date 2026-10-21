### Incomplete patterns:

- UserInfo
- ServerList*


> [!NOTE]
> Sub Types in most packets are unknown<br/>
> ProtocolVersion might just be 1 byte, the other 2 bytes may  be payload configuration (See ClientHandshake.hexpat)

### Missing patterns

```
08 - Client -> Server (5)
12 - Client <- Server (15)
18 - Client <- Server (21)
0E - Client -> Server (11)
9E - Client -> Server (156)
72 - Client -> Server (111)
```

---

| Sender | Symbol |
|--------|--------|
| Client | `->`   |
| Server | `<-`   |

|        Id        | Name              | Sender |  Size  | Description                        |
|:----------------:|:------------------|:------:|:------:|------------------------------------|
|        06        | AdvanceSequence   |  `->`  |   3    |                                    |
|        08        |                   |  `->`  |   5    |                                    |
|        12        |                   |  `->`  |   15   |                                    |
|        0E        |                   |  `->`  |   11   |                                    |
|        18        |                   |  `->`  |   21   |                                    |
|        1B        | World Server Info |  `<-`  |   24   |                                    |
| Region Dependent | Server List       |  `<-`  | Varies |                                    |
|     69 / 6A      | User Info         |  `<-`  |  103   | Always 4th packet                  |
|     72 / 9E      |                   |  `->`  |  111   | Always 3rd packet, looks encrypted |
|        96        | Server Handshake  |  `<-`  |  276   | Always 2nd packet                  |
|     98 / 68      | Character Info    |  `<-`  | Varies |                                    |
|        99        | Client Handshake  |  `->`  |  279   | Always 1st packet                  |
![The Project Icon](img/icon.png)

# ``LGV_MeetingSDK``

An adaptible SDK, for finding and listing regularly-occurring, scheduled events.

## Overview

This SDK provides a (mostly) protocol-based definition of an SDK that can be applied to low-level server connections, when the server provides information on regularly-scheduled (weekly) events.

The information is "commoditized" into a relatively straightforward structure, so different types of servers, with different behaviors, can be abstracted behind a common façade.

- [Online technical documentation](https://littlegreenviper.github.io/LGV_MeetingSDK/)
- [Source code available on GitHub](https://github.com/LittleGreenViper/LGV_MeetingSDK)

## What Problem Does This Solve?

There are very many databases and APIs available, for online scheduling of meetings, and it can be quite daunting, to develop connectors to all of them.

This SDK is a "baseline" platform that can be extended and specialized, into discrete, focused, connectors that can be "mixed and matched," and return a single, consistent data structure.

It also allows a "native" Swift approach to these connectors, using modern, platform-agnostic Swift.

## Requirements

This is a [Swift](https://www.swift.org)-only SDK, and is meant to be used by native Swift Apple implementations. It will work for all Apple platforms ([iOS](https://apple.com/ios), [iPadOS](https://apple.com/ipados), [WatchOS](https://apple.com/watchos), [MacOS](https://apple.com/macos), and [TVOS](https://apple.com/tvos)).

There are no dependencies for the SDK, but [the test harness app](https://github.com/LittleGreenViper/LGV_MeetingSDK/tree/master/Tests/LGV_MeetingSDK_Test_Harness) has some dependencies:

- [RVS_Generic_Swift_Toolbox](https://riftvalleysoftware.com/work/open-source-projects/#toolbox)
- [RVS_UIKit_Toolbox](https://riftvalleysoftware.com/work/open-source-projects/#uikit)
- [RVS_Persistent_Prefs](https://riftvalleysoftware.com/work/open-source-projects/#RVS_PersistentPrefs)
- [RVS_Checkbox](https://riftvalleysoftware.com/work/open-source-projects/#RVS_Checkbox)

## What Is A "Meeting"?

For the purposes of this SDK, a meeting is a regularly-occurring event, happening at a certain physical location, or virtual venue (or both). The cadence is weekly.

There are provisions for "one-off" events, but these would best be handled by something like a calendar or scheduling system.

Meetings are associated with "Organizations."

## What Is An "Organization"?

This SDK is being developed in order to specifically address the technical needs of propagating scheduling information for 12-Step Recovery organizations, like [AA](https://aa.org) and [NA](https://na.org), however, it does not need to be restricted to these types of fellowships. It may also be used to "mix and match" meetings from different organizations.

## SDK Structure

The basic structure of the SDK, is an instance of the SDK, specialized for a certain API (for example, the [BMLT](https://bmlt.app) API), that will have an organization assigned. This organization will have a "transport" assigned, which takes care of querying the server, and parsing the response. It does this, via "initiators," and "parsers."

![The System Diagram](img/SystemDiagram.png)

In the diagram above, we see the SDK being used as a connector to a [BMLT](https://bmlt.app) server.

A search is initiated by the user of the SDK, by providing a [Search Type](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Types/LGV_MeetingSDK.swift#L318), and [Search Refinements](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Types/LGV_MeetingSDK.swift#L509). These define the parameters of the search.

The SDK then gets the [Transport](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Transport_Protocol.swift#L107) instance from its [Organization](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Organization_Protocol.swift#L28) instance, and asks it to perform the search.

The [Transport](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Transport_Protocol.swift#L107) instance has an [Initiator](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Transport_Protocol.swift#L50) instance, as well as a [Parser](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Transport_Protocol.swift#L28) instance, that will take care of the actual interaction (in this case, HTTPS) with the *Meeting List Server* (in this case, a BMLT server instance).

The initiator knows how to translate the generic *Search Type* (and, possibly, the *Refinements*) into a server query, and sends a request to the *Meeting List Server* that satisfies the parameters of the requested search.

The server responds with an answer to the query (in this case, [JSON](https://www.json.org) data), which the [Initiator](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Transport_Protocol.swift#L50) sends to the [Parser](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Transport_Protocol.swift#L28), which renders it into the basic object model that will be passed to the SDK user.

Each [Meeting](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Meeting_Protocols.swift#L227) instance may have multiple [Format](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Meeting_Protocols.swift#L61) instances attached. These are metadata that define various attributes of the meeting. It will also have at least one [Physical Venue](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Meeting_Protocols.swift#L95), or at least one [Virtual Venue](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Meeting_Protocols.swift#L127). It can have both types of venues (Called a "hybrid" meeting).

The [response](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Protocols.swift#L83) to the user is returned in a [Swift Completion Block](https://github.com/LittleGreenViper/LGV_MeetingSDK/blob/master/Sources/LGV_MeetingSDK/Protocols/LGV_MeetingSDK_Transport_Protocol.swift#L58).

The response contains the initial search request parameters, as well as any meetings found, that satisfy the request. Any errors encountered are also returned in the closure.

## Built-In Connectors

Currently, the only specialized connector, is one for [the BMLT](https://bmlt.app), a modern, worldwide API for [NA](https://na.org) meetings.

[Here is the source code for the BMLT connector.](https://github.com/LittleGreenViper/LGV_MeetingSDK/tree/master/Sources/LGV_MeetingSDK/Types/BMLT)

## Examples

Examples of the use of the SDK are available in [The Unit Tests](https://github.com/LittleGreenViper/LGV_MeetingSDK/tree/master/Tests/LGV_MeetingSDKTests), and [The Test Harness](https://github.com/LittleGreenViper/LGV_MeetingSDK/tree/master/Tests/LGV_MeetingSDK_Test_Harness).

## Where To Get

### [**Swift Package Manager (SPM)**](https://swift.org/package-manager/)

- The HTTPS URL for the package is [`https://github.com/LittleGreenViper/LGV_MeetingSDK`](https://github.com/LittleGreenViper/LGV_MeetingSDK).
- The SSH URI for the package is `git@github.com:LittleGreenViper/LGV_MeetingSDK.git`.

### [**Carthage**](https://github.com/Carthage/Carthage)

You implement it by adding the following line in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md):

    `github "LittleGreenViper/LGV_MeetingSDK"`

## License

The SDK is provided as [MIT](https://opensource.org/licenses/MIT)-licensed code.

Copyright 2022 [Little Green Viper Software Development LLC](https://littlegreenviper.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



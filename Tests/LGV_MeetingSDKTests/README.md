# ``LGV_MeetingSDKTests``

## Overview

These tests are of limited utility.

They were a set of shims that I created, as I was developing the SDK.

They will test the basic parser, but only in a predictable way, so they aren't really indicative of any real world implementation.

Instead, use the test harness, and concrete implementations for testing.

**NOTE:** The "LiveServerBMLT" unit tests actually connect to an external server, and perform data transactions. The integrity of the source data is not guaranteed, nor is its predictability (which actually makes the tests more useful).
**NB:** The TOMATO server can be quite finicky, so it may be possible to get random timeouts, during the "Live Server" tests.

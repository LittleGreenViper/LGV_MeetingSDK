**2.3.6** *January 10, 2023*

 - Added Comparable conformance to the meeting protocol.
 
**2.3.5** *December 11, 2022*

 - Added CustomDebugStringConvertible conformance
 
**2.3.4** *December 4, 2022*

- I did it again. I left a debug value in there.

**2.3.3** *December 4, 2022*

- The sorting was not being done correctly for the "Find the Next Meeting" search. This has been fixed.

**2.3.2** *December 3, 2022*

- That was dumb. I left a debug value in there.

**2.3.1** *December 3, 2022*

- Some work on the "Find My Next Meeting" search. The code was difficult to understand, and there were a couple of range and sorting issues.

**2.3.0** *November 30, 2022*

- Fairly significant refactoring, in an effort to DRY out, and simplify the code.
- More work to reinforce thread safety.
- Changed the way that the physical location is specified, as a lot of virtual meetings pretend to be physical. They shouldn't do that, but who am I, to judge?

**2.2.1** *November 29, 2022*

- Some thread safety work.

**2.2.0** *November 29, 2022*

- A whole bunch of work to stay DRY, and fixed a possible thread collision bug.

**2.1.2** *November 29, 2022*

- I moved the protocol defaults for the main protocol into the module base class, as I was getting strange optimization errors, in the first implementation.

**2.1.1** *November 28, 2022*

- Fixed a bug in the way that the meetings for the new function are aggregated.

**2.1.0** *November 28, 2022*

- Added the ability to do a "Nearby Meetings" search.
- Added an indicator of the number of meetings found (in the results tab), and results are numbered.

**2.0.2** *November 22, 2022*

- The time range was not being handled properly.

**2.0.1** *November 22, 2022*

- Fixed a bug, where the auto radius was not being reported as such (debug string).

**2.0.0** *November 18, 2022*

- Added support for the LGV_MeetingServer backend.

**1.2.1** *November 1, 2022*

- Addressing some possible memory leaks.

**1.2.0** *October 26, 2022*

- Some simple API changes to afford more flexibility in the initial implementation.

**1.1.3** *October 21, 2022*

- Documentation improvements. No API changes.

**1.1.2** *October 19, 2022*

- Documentation improvements. No API changes.

**1.1.1** *October 14, 2022*

- Fixed an issue, where having information in the meeting comments would cause an invalid virtual venue to be created.
- Fixed a bug, where the start time was wrong (divided military by 1000, not 100).
- Fixed a bug, where virtual-only meetings were getting physical locations assigned.

**1.1.0** *October 12, 2022*

- Fixed an issue with a weak self. No API change.
- Added the refCon to the parser, so it gets propagated properly. This is a minor API change.

**1.0.0** *October 11, 2022*

- Initial Release

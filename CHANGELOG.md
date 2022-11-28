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

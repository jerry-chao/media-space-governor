# 03 — Measure Cold Resource local storage

**What to build:** A user sees accurate Space Saving Opportunity values appear for eligible Cold Resources after classification. Measurement runs sequentially away from the UI, reports progress, and safely stops when cancelled or superseded. Resources whose originals are not on-device remain explicitly unmeasured, with no iCloud download request.

**Blocked by:** 02 — Classify authorized media with Library Access Coverage.

**Status:** ready-for-agent

- [ ] Only non-Protected Cold Resources are eligible for local-original measurement.
- [ ] Measurement counts every locally available original component required to preserve an Original Archive Copy, discarding streamed media bytes immediately.
- [ ] The app never enables network access for measurement; an unavailable local original yields an explicit unavailable result and no Space Saving Opportunity estimate.
- [ ] The Governance-Centered View shows measurement progress, measured savings, and unavailable-size resources without claiming unknown bytes as savings.
- [ ] A new scan or explicit cancellation stops outstanding measurement work without corrupting the current inventory.
- [ ] No Archive Completion, Remote Archive upload, Restore, or Local Primary cleanup is introduced.
- [ ] Automated behavior tests plus a real-device smoke check verify local measurement, unavailable-local-original handling, cancellation, and absence of iCloud download behavior.

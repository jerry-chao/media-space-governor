# iOS: Governance summary view for the Governance-Centered View

## Problem Statement

The Governance-Centered View shows a flat detail list of classified media. A device owner cannot grasp the overall governance situation at a glance: how much authorized media exists, how much is Cold, how much local space could be reclaimed, how much is Protected, and how much remains unmeasured. Without a grouped summary, understanding the library requires scrolling through every row.

## Solution

Rework the main screen into a governance summary organized by Governance-Driven Grouping. The top shows a "全部" overview card with global totals, followed by Usage Heat group cards ordered cold → lukewarm → active, with empty groups hidden. Each heat group is further broken down by shallow Content Class (screenshots / camera photos / ordinary videos). Tapping a heat group drills down to a detail page listing its member media in content-class sections.

Every group reports count, measured local space, and unmeasured count honestly: unmeasured or unavailable originals never contribute a fabricated byte count. Protected Resources remain inside their heat group as marked members rather than forming a separate group. Library Access Coverage is always shown so a limited scan is never mistaken for a full-library summary.

The grouping and aggregation logic lives in the domain package (GovernanceEngine plus a pure GovernanceOverview type), keeping the platform UI a thin renderer and the same summary reproducible on future platforms.

## User Stories

1. As a device owner, I want to see the total count of my authorized media in one place, so that I can grasp the overall library size at a glance.
2. As a device owner, I want to see how many Cold Resources exist, so that I understand the immediate governance opportunity.
3. As a device owner, I want to see the measured local space of Cold candidates, so that I can estimate reclaimable storage.
4. As a device owner, I want to know how many resources are still unmeasured, so that I do not mistake partial measurement for complete savings.
5. As a device owner, I want to see how many media are Protected Resources, so that I know which space the product will not recommend cleaning.
6. As a device owner, I want my library grouped by Usage Heat with cold first, so that governance opportunity is the most visible signal.
7. As a device owner, I want each heat group broken down by Content Class (screenshots / camera photos / ordinary videos), so that I understand what kinds of media dominate each group.
8. As a device owner, I want every group to show count, measured space, and unmeasured count, so that each group is honestly summarized.
9. As a device owner, I want empty heat groups hidden, so that the summary is not cluttered with zeroes.
10. As a device owner, I want to tap a heat group and see its member media as a grouped detail list, so that I can inspect what drives the summary numbers.
11. As a device owner, I want the detail page to keep the second-level Content Class sections, so that the two-level grouping is preserved when drilling in.
12. As a device owner, I want Protected Resources marked inside their heat group, so that retention signals are visible without losing the heat overview.
13. As a device owner, I want the summary and detail pages to share the same live measurement results, so that numbers grow consistently while measurement runs.
14. As a device owner, I want Library Access Coverage shown on the summary, so that I never mistake a partial scan for the full library.
15. As a device owner, I want the existing Governance Recommendations list retained, so that action opportunities are not lost in the new layout.
16. As a future Android user, I want grouping and aggregation in the shared domain layer, so that Android renders the same summary without reimplementing it.

## Implementation Decisions

- Add a pure `GovernanceOverview` type to the domain package: global totals (total count, Cold Resource count, measured local space, unmeasured count, Protected Resource count) plus Usage Heat groups ordered cold → lukewarm → active. Each heat group carries its own count, measured bytes, and unmeasured count, plus a Content Class breakdown (screenshots / camera photos / ordinary videos). Empty groups are omitted.
- Add an aggregation method on GovernanceEngine that builds a GovernanceOverview from normalized resources and a measured-bytes map (resource identifier → measured local bytes). Resources without a measured entry count as unmeasured and contribute no space. Protected Resources stay in their heat group and are marked, never separated into their own group.
- The aggregation is deterministic pure logic: no Photos framework types, no UI types, no measurement execution. It reuses the existing Usage Heat and Content Hint derivations so the summary cannot drift from Governance Classification.
- The main screen of the demo app becomes the summary: overview card, heat group cards, measurement progress, and the retained Governance Recommendations section. The flat per-resource classification list moves into the drill-down detail pages.
- The detail page for a heat group lists member media in Content Class sections; rows show content class, Usage Heat, Protected mark, and local-size state (measured / unmeasured / unavailable-on-device).
- Summary and detail pages derive from the same live measured-sizes state, so numbers grow consistently while the measurement pass runs. No per-group re-measurement is introduced.
- Library Access Coverage is always rendered on the summary, full or limited.

## Testing Decisions

- The deterministic seam is the domain package: GovernanceEngine aggregation and the GovernanceOverview shape, covered by swift test. Existing governance, classification, and measurement-candidate tests are the prior art.
- Tests verify bucket membership per heat group and Content Class, per-group metrics (count, measured bytes, unmeasured count), cold-first ordering, empty-group omission, Protected marking without separate grouping, and that unmeasured resources contribute no space while remaining countable.
- UI behavior (summary rendering, tap-through, live growth, coverage banner) is covered by the real-device smoke checklist in the demo app README, consistent with the platform-boundary testing decision of the underlying feature.

## Out of Scope

- Per-group or per-page re-measurement triggers.
- A standalone Protected Resources filter or group.
- Cross-dimension grouping such as Media Type × Usage Heat.
- Archive-readiness grouping (no archive service exists yet).
- Custom sort order or user-authored grouping rules.
- Persisting the summary snapshot across launches.
- Semantic classification beyond the existing shallow Content Classes.

## Further Notes

- Uses the established terms Governance-Centered View, Governance-Driven Grouping (browse application), Usage Heat, Cold Resource, Protected Resource, Shallow Content Classification, Library Access Coverage, and Space Saving Opportunity.
- Governance-Driven Grouping is applied here as the browse grouping of the summary, distinct from its action grouping behind Governance Batches; both share grouping logic in the domain package.
- The honest-measurement rule carries over: an unmeasured or unavailable local original contributes no Space Saving Opportunity and is never fabricated as zero.
- No ADR is proposed: the decisions are localized to the summary presentation and remain reversible.

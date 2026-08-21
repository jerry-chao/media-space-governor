# 01 — GovernanceOverview aggregation in the domain package

**What to build:** The domain package can aggregate normalized media into a two-level governance summary: global totals, then Usage Heat groups (cold → lukewarm → active) each broken down by Content Class, with honest count / measured-space / unmeasured metrics. This is pure, deterministic logic any platform can render.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [ ] GovernanceOverview exposes global totals: total count, Cold Resource count, measured local space, unmeasured count, and Protected Resource count.
- [ ] Usage Heat groups are ordered cold → lukewarm → active, and empty groups are omitted.
- [ ] Each heat group carries count, measured bytes, and unmeasured count, plus a Content Class breakdown (screenshots / camera photos / ordinary videos).
- [ ] Resources without a measured entry count as unmeasured and contribute no space; no fabricated byte counts.
- [ ] Protected Resources remain members of their heat group and are marked, never grouped separately.
- [ ] The aggregation reuses existing Usage Heat and Content Hint derivations so it cannot drift from Governance Classification.
- [ ] Core tests cover bucket membership, per-group metrics, cold-first ordering, empty-group omission, Protected marking, and unmeasured-no-space behavior.

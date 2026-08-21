# 02 — Governance summary main screen

**What to build:** The main screen shows the governance summary: a "全部" overview card with global totals, Usage Heat group cards (cold first, empty groups hidden) with per-group metrics, the Library Access Coverage banner, live measurement progress, and the retained Governance Recommendations list. A user understands the overall local situation at a glance.

**Blocked by:** 01 — GovernanceOverview aggregation in the domain package.

**Status:** ready-for-agent

- [ ] The "全部" overview card shows total count, Cold Resource count, measured local space, unmeasured count, and Protected Resource count.
- [ ] Usage Heat group cards show count, measured space, and unmeasured count, ordered cold → lukewarm → active, with empty groups hidden.
- [ ] Library Access Coverage is always visible (full or limited), never mistaking a partial scan for the full library.
- [ ] Summary numbers grow live while the measurement pass runs, derived from the shared measured-sizes state.
- [ ] The Governance Recommendations list remains available on the main screen.
- [ ] Real-device smoke check: the summary renders correctly against a real authorized library.

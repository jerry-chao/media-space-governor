# 01 — Truthfully represent unmeasured Space Saving Opportunity

**What to build:** A user can see that a media resource has received Governance Classification even when its local original size is not yet known. Unknown size is never presented as zero, never included in a Space Saving Opportunity total, and never used to prioritize a large video.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [ ] The normalized inventory distinguishes a measured local byte value from an unavailable or unmeasured value without inventing a zero-byte estimate.
- [ ] Governance Classification remains available before local-byte measurement completes.
- [ ] Governance Recommendations and Governance-Driven grouping exclude unmeasured values from storage-impact totals and large-video prioritization.
- [ ] The Governance-Centered View visibly distinguishes an unmeasured resource from a measured zero-size value.
- [ ] Automated behavior tests extend the existing GovernanceEngine coverage for measured and unmeasured storage outcomes.

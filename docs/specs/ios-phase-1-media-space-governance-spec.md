# iOS Phase 1 Spec: Media Space Governance

## Problem Statement

Users accumulate large numbers of photos and videos on a managed device, and that local media gradually consumes too much device storage. Existing gallery products are optimized for browsing, not Media Space Governance, so users cannot easily understand which resources are creating storage pressure, which ones have become Cold Resources, which ones are safe to move into a Remote Archive, or how much space they can reclaim without losing Recoverability.

In phase 1, the immediate problem to solve is on iOS: help an individual user on a single managed device safely reduce local storage consumed by photos and videos, while preserving trust, retaining the Local Primary until the user explicitly confirms cleanup, and avoiding any cloud-library or real-time-sync expectations.

## Solution

Deliver an iOS-first mobile app for Media Space Governance that performs On-Device Analysis of local photos and videos, applies Governance Classification to identify Usage Heat, Cold Resources, Protected Resources, and Space Saving Opportunity, uploads eligible original files into a Remote Archive, verifies Archive Completion, and then presents Governance Recommendations in Governance Batches for explicit user confirmation.

The first release is iOS-first and Android-ready. That means the product experience ships on iOS first, while the domain model, service contracts, and platform boundary design are defined so that Android support can later be added without changing the meaning of Remote Archive, Archive Completion, Restore, Governance Batch, or Default Cooling Policy.

## User Stories

1. As an iPhone user with low storage, I want the app to scan my local photos and videos, so that I can understand how much space my media is consuming.
2. As an iPhone user, I want to see storage pressure summarized clearly, so that I can decide whether action is worth taking.
3. As an iPhone user, I want the app to distinguish photos from videos, so that I can understand which media type is creating the most pressure.
4. As an iPhone user, I want the app to classify media for governance instead of album browsing, so that the experience focuses on saving space.
5. As an iPhone user, I want the app to identify likely Cold Resources, so that I can find media I probably no longer need locally.
6. As an iPhone user, I want the app to identify Protected Resources, so that media that still matters to me is not pushed into default cleanup flows.
7. As an iPhone user, I want the app to recognize screenshots separately from camera photos, so that low-value clutter can be handled more aggressively.
8. As an iPhone user, I want the app to treat large videos as high-governance-value resources, so that the biggest space wins appear first.
9. As an iPhone user, I want Usage Heat to reflect recency and evidence of use, so that old but still relevant media is less likely to be misclassified.
10. As an iPhone user, I want the app to rely on stable device-local signals, so that the product does not depend on invasive cross-app tracking.
11. As an iPhone user, I want a Governance-Centered View instead of another gallery homepage, so that I can act on storage problems quickly.
12. As an iPhone user, I want to see immediate reclaimable space separately from future reclaimable space, so that I understand what I can save now versus after archiving.
13. As an iPhone user, I want the app to show Space Saving Opportunity per Governance Batch, so that I can prioritize the most valuable action.
14. As an iPhone user, I want Governance Recommendations instead of silent actions, so that I remain in control of my personal media.
15. As an iPhone user, I want Governance Batches grouped by governance value, so that I can review actions in meaningful chunks.
16. As an iPhone user, I want to archive original files before local cleanup is suggested, so that Restore remains trustworthy.
17. As an iPhone user, I want the Remote Archive to preserve the Original Archive Copy, so that restored media is not degraded.
18. As an iPhone user, I want the app to verify Archive Completion before a resource becomes cleanup-eligible, so that I do not lose media because of incomplete uploads.
19. As an iPhone user, I want archive status to be visible, so that I know whether a resource is waiting, uploading, completed, or blocked.
20. As an iPhone user, I want some resources to remain in Archived Local Retention after upload, so that archiving and cleanup remain separate decisions.
21. As an iPhone user, I want to review a Governance Batch before confirming cleanup, so that I understand what will happen.
22. As an iPhone user, I want cleanup to require explicit confirmation, so that the app never surprises me by deleting local media.
23. As an iPhone user, I want batch cleanup instead of item-by-item cleanup, so that large libraries remain manageable.
24. As an iPhone user, I want Protected Resources excluded from default cleanup batches, so that trust in the product remains high.
25. As an iPhone user, I want to see why a resource is in a Governance Batch, so that the recommendation feels explainable rather than arbitrary.
26. As an iPhone user, I want to restore an archived resource on demand, so that cleaned resources remain Recoverable.
27. As an iPhone user, I want Restore to return a usable local copy to my device, so that recovery is practical rather than symbolic.
28. As an iPhone user, I want to browse archived items separately from local items, so that I can understand what still lives on-device.
29. As an iPhone user, I want to tune a small number of Default Cooling Policy thresholds, so that the product can match my tolerance without becoming a rule engine.
30. As an iPhone user, I want to choose stricter handling for screenshots, so that I can clean clutter faster.
31. As an iPhone user, I want to choose stricter handling for large videos, so that I can maximize reclaimed space.
32. As an iPhone user, I want cleanup recommendations to depend on Archive Completion, so that only safe candidates appear.
33. As an iPhone user, I want the app to make clear that the Remote Archive is not a real-time sync library, so that my expectations stay aligned with the product.
34. As an iPhone user, I want the app to avoid deep semantic analysis in phase 1, so that the product stays focused on governance value and privacy.
35. As an iPhone user, I want the first release to feel complete on iOS, so that I can get value before Android support ships.
36. As a future Android user, I want the same governance concepts to apply when Android support arrives, so that the product behaves consistently across platforms.
37. As a future Android user, I want Android support to reuse the same Remote Archive and Restore semantics, so that cross-platform expansion does not redefine trust guarantees.
38. As a product engineer, I want an iOS-specific media access adapter behind a stable governance workflow, so that Android can later plug into the same high-level behavior.
39. As a product engineer, I want archive transport to be platform-agnostic, so that object storage integration does not depend on iOS-only code.
40. As a product engineer, I want cleanup and restore behavior expressed through platform boundaries rather than iOS-only assumptions, so that Android support can be added without reworking the domain model.
41. As a support operator, I want archive state and restore capability to be explicit in the product model, so that user issues can be diagnosed clearly.
42. As a product owner, I want trust and safety constraints encoded in the workflow, so that storage savings never come at the cost of accidental loss.
43. As a product owner, I want metrics around archive completion, cleanup confirmation, restore success, and reclaimed space, so that phase 1 success can be evaluated.
44. As a privacy-conscious user, I want On-Device Analysis to be the default classification path, so that my original media is not uploaded just to decide whether it is cold.
45. As a privacy-conscious user, I want the app to archive only what is needed for recoverable offloading, so that the product remains storage-governance-focused rather than data-hoarding.
46. As a cautious user, I want to see failures in archive or restore flows, so that I know when a resource is not safe to clean.
47. As a cautious user, I want the app to preserve Local Primary until I confirm cleanup, so that I keep control over irreversible device changes.
48. As an early-stage team, I want phase 1 scope limited to iOS delivery with Android-ready boundaries, so that the product can ship sooner without locking future platform support out.

## Implementation Decisions

- The primary seam is a single `Media Space Governance workflow` that spans inventory, Governance Classification, remote archiving, Archive Completion, Governance Batch generation, cleanup confirmation, and Restore. Tests and design should prefer this seam over many lower-level seams.
- The first shipped client is iOS only. Android is out of delivery scope for phase 1, but every platform-dependent behavior must sit behind a stable platform boundary so Android can later adopt the same workflow.
- The workflow should be split conceptually into three high-level adapters beneath the single seam: a media access adapter, an archive transport adapter, and a local cleanup-and-restore adapter. iOS implements all three in phase 1; Android support is deferred but the interfaces must not encode iOS-only assumptions.
- The product remains single-context and uses the glossary in `CONTEXT.md` as the canonical language for feature behavior, status naming, and future expansion.
- The ADR requiring Original Archive Copy remains binding. Remote Archive stores original files as the primary archive copy; any previews or derivatives are secondary and cannot replace restore-grade archive objects.
- The product is a Media Space Governance product, not a cloud library. Remote Archive is not a real-time source of truth, and no implementation decision should imply continuous sync semantics.
- The managed device model remains one account to one device in phase 1. No implementation in this spec should assume a unified multi-device library.
- Governance Classification is governance-oriented, not gallery-oriented. It must emphasize media type, storage impact, Usage Heat, archive readiness, and shallow content classes such as screenshots, camera photos, and ordinary videos.
- Usage Heat must be computed from stable local signals available on the device, such as recent view, recent share, recent edit, and creation time where available. The implementation must not depend on comprehensive third-party app usage telemetry.
- Protected Resource behavior is a hard exclusion from first-stage default cleanup recommendations, not merely a lower ranking. This is part of the trust model.
- Archive Completion is a strict state requiring successful remote write, integrity verification, and a recorded restore mapping. Upload success alone is insufficient.
- Archived Local Retention is a first-class state. A resource can be archive-complete and still intentionally remain local until a later cleanup decision.
- Governance Recommendations never directly delete Local Primary. Local cleanup is a separate, user-confirmed action that can operate on a Governance Batch.
- Governance-Driven Grouping should be based on combinations of media type, storage size, cooling duration, and archive readiness. Content-theme grouping is not the organizing principle in phase 1.
- The Governance-Centered View should lead the app experience. Storage pressure, Space Saving Opportunity, archive status, cleanup eligibility, and restore actions are the primary navigation concepts.
- The policy model is `system default plus limited user adjustment`, not a custom automation engine. Threshold-level customization is allowed; arbitrary user-authored rules are not.
- Restore is single-item in phase 1. The workflow should expose recoverability clearly, but bulk restore is deferred.
- Object storage integration should be modeled as a platform-neutral remote archive service. iOS-specific code should not own archive semantics, object identity, or restore mapping rules.
- Any server or service components introduced for archive metadata, object verification, or restore mapping must be designed once for both iOS and future Android clients, even though only iOS consumes them initially.
- Metrics and observability should focus on external outcomes: scan completion, archive initiation, archive completion, cleanup confirmation, reclaimed storage, restore success, and regret indicators such as immediate restore after cleanup.

## Testing Decisions

- Good tests should verify externally visible behavior of the Media Space Governance workflow, not implementation details such as internal helper composition, private scoring formulas, or platform-specific class structure.
- The highest-priority tests should exercise the single workflow seam end-to-end through behavior such as: classifying Cold Resources, excluding Protected Resources, refusing cleanup before Archive Completion, grouping Governance Recommendations into Governance Batches, performing user-confirmed cleanup, and restoring cleaned resources.
- Platform-specific tests should focus only on observable adapter contracts: iOS media access can enumerate the right inventory shape, iOS cleanup removes Local Primary only after confirmation, and iOS restore returns a usable local copy.
- Archive tests should validate the strict meaning of Archive Completion: successful write, integrity verification, and restore mapping establishment.
- Recommendation tests should validate that Governance-Driven Grouping uses storage impact, cooling duration, media type, and archive readiness rather than unrelated content themes.
- Policy tests should validate that Default Cooling Policy adjustments change recommendation eligibility only within the allowed threshold surface.
- Trust-model tests should validate that Protected Resources are excluded from default cleanup recommendations and that no auto-cleanup path exists in phase 1.
- Restore tests should validate Recoverability after cleanup, using the Original Archive Copy rather than a degraded derivative.
- Because the repo currently contains domain docs rather than existing code, there is no local prior art test suite to mirror yet. When implementation begins, the preferred prior art should be the highest-level workflow tests created first for this feature, with lower-level adapter tests added only where platform integration risk justifies them.

## Out of Scope

- Shipping Android client functionality in phase 1
- Multi-device account management
- Real-time sync semantics across devices
- Deep semantic content understanding such as people, scenes, events, or emotional importance
- Server-side upload of original media solely for classification
- User-authored rule engines
- Automatic local deletion without explicit user confirmation
- Bulk restore workflows
- Desktop or web experiences
- Social sharing, album collaboration, or cloud-library browsing features

## Further Notes

- This spec intentionally narrows the previously broader mobile scope to `iOS-first, Android-ready`.
- The current repo is documentation-first. There are no existing implementation modules yet, so naming and structure should be chosen to preserve the single workflow seam rather than prematurely fragmenting the codebase.
- Publishing this spec to GitHub Issues is intentionally deferred in this step because the current request is for local documentation only.
- If this spec is later published to the configured issue tracker, it should use the existing GitHub configuration for `jerry-chao/media-space-governor` and apply the `ready-for-agent` label.

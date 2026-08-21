# Media Space Governance

This context describes a mobile product whose primary purpose is to reduce device storage consumed by photos and videos. It exists to keep the product language focused on storage governance rather than generic cloud storage.

## Language

**Media Space Governance**:
The core product goal of reducing device storage consumed by local photos and videos through analysis, recommendations, and controlled offloading.
_Avoid_: Cloud album, netdisk, cloud migration

**Remote Archive**:
An off-device copy of a local media resource retained primarily to relieve local storage pressure while preserving recoverability, not as the system's real-time source of truth.
_Avoid_: Backup, sync copy, cloud library

**Local Primary**:
The on-device copy of a media resource that remains the authoritative working copy until the user explicitly confirms local cleanup.
_Avoid_: Cache, replica, temporary copy

**Managed Device**:
The single mobile device whose local media inventory is being analyzed and governed by the product for a given account in the first stage.
_Avoid_: Device fleet, endpoint set, multi-device library

**Library Access Coverage**:
The portion of the managed device's photo library the user has authorized the product to analyze. Limited access must be visible so the user never mistakes a partial inventory for a full-library result.
_Avoid_: Assumed full library, complete scan claim, hidden access

**Governance Classification**:
A classification of media used to support storage governance decisions, centered on media type, retention posture, and usage heat rather than rich album-style content labeling.
_Avoid_: Smart album, content taxonomy, AI gallery tags

**Usage Heat**:
A governance-oriented measure of how likely a media resource is to still matter to the user, derived from recency and evidence of use rather than a raw frequency count alone.
_Avoid_: Click count, play count, simple usage frequency

**Cold Resource**:
A media resource whose recent view, share, and edit evidence is weak enough that it becomes a candidate for remote archiving or local cleanup.
_Avoid_: Old file, stale asset, unused item

**Governance Recommendation**:
A system-generated recommendation proposing an archive or cleanup action on a media resource without executing local deletion by itself.
_Avoid_: Auto cleanup, forced action, silent deletion

**Governance Batch**:
A user-reviewable set of governance recommendations grouped so they can be confirmed and executed together.
_Avoid_: Bulk delete, one-click wipe, random selection

**Governance-Driven Grouping**:
A way of grouping media according to storage impact, cooling duration, archive readiness, and similar governance value signals rather than subject matter. Applied in two ways that share the same grouping logic: as the browse grouping of the Governance-Centered View's summary, and as the action grouping behind Governance Batches.
_Avoid_: Album grouping, theme grouping, content-first grouping

**Archive Completion**:
The state in which a media resource has a successfully written remote archive, verifiable object integrity, and a recorded mapping that makes later retrieval possible.
_Avoid_: Upload returned success, probably archived, best-effort copy

**Recoverability**:
The product guarantee that a resource cleaned from the device can still be retrieved from its remote archive.
_Avoid_: Best effort restore, assumed backup

**Restore**:
The user-initiated action of bringing an archived media resource back onto the managed device as a usable local copy.
_Avoid_: Preview fetch, thumbnail load, stream only

**On-Device Analysis**:
The default first-stage approach of deriving governance classifications on the managed device rather than uploading original media content for classification.
_Avoid_: Server-side content scan, cloud-first analysis, upload-then-decide

**Shallow Content Classification**:
First-stage content classification limited to high-governance-value media categories such as screenshots, camera photos, and ordinary videos rather than deep semantic understanding.
_Avoid_: Semantic scene graph, memory detection, rich AI taxonomy

**Original Archive Copy**:
The original, uncompressed media file preserved as the primary remote archive copy so that restore returns the user's full-fidelity resource.
_Avoid_: Compressed-only archive, preview-only copy, downgraded backup

**Default Cooling Policy**:
The system-provided first-stage rule set that determines when media becomes a cold resource candidate, with only limited user adjustment of key thresholds.
_Avoid_: User-authored rule engine, fully manual policy, arbitrary automation script

**Protected Resource**:
A media resource that is excluded from first-stage default cleanup recommendations because the user or the product has strong evidence it should be retained locally.
_Avoid_: Important memory, emotional favorite, never-touch file

**Archived Local Retention**:
The state in which a media resource has completed remote archiving but is still intentionally kept on the managed device pending any later cleanup decision.
_Avoid_: Redundant duplicate, cleanup overdue, failed deletion

**Governance-Centered View**:
The primary product view organized around storage pressure, governance opportunities, archive status, and recovery actions rather than album-style browsing.
_Avoid_: Gallery-first home, timeline-first home, smart album homepage

**Space Saving Opportunity**:
The measured amount of locally available device storage a user could reclaim through a specific governance action or batch. Resources whose original is not on-device contribute no estimate until their local size is known, distinguishing this from theoretical total library size or already-realized savings.
_Avoid_: Total storage, vanity number, mixed savings estimate

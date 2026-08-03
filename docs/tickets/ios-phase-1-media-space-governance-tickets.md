# iOS Phase 1 Ticket Breakdown: Media Space Governance

## Ticketing Approach

These tickets break the iOS-first, Android-ready scope into tracer-bullet delivery slices while preserving a single `Media Space Governance workflow`.

Each ticket states:

- outcome
- scope
- dependencies
- acceptance focus

These are local planning tickets only. They are not yet published to the configured GitHub issue tracker.

## Dependency Summary

- T1 blocks all implementation tickets
- T2 and T3 can start after T1
- T4 depends on T2 and T3
- T5 depends on T2 and T3
- T6 depends on T4 and T5
- T7 depends on T4 and T5
- T8 depends on T6 and T7
- T9 depends on T4, T6, and T7
- T10 depends on all user-visible workflow slices

## T1. Establish Workflow Skeleton and Shared Domain States

### Outcome

Create the initial project structure and shared state vocabulary for the single `Media Space Governance workflow`.

### Scope

- define the workflow stages used across client and service
- define platform-neutral state names for local presence, archive state, and cleanup eligibility
- define the minimum record shapes for media resources, archive snapshots, Governance Recommendations, Governance Batches, and policy settings
- ensure Android-ready boundaries are represented conceptually even though only iOS is implemented

### Depends On

- none

### Acceptance Focus

- the implementation has one coherent workflow model instead of disconnected per-feature models
- iOS-specific code does not define product-wide archive semantics
- future Android support would be able to plug into the same states without renaming the domain

## T2. Implement iOS Media Access Boundary and Local Inventory

### Outcome

The iOS client can request permissions, enumerate the local media inventory, and persist a normalized snapshot of photos and videos on the managed device.

### Scope

- implement iOS permission handling for media access
- enumerate images and videos
- collect metadata needed for Governance Classification
- normalize inventory records into the local state store
- support re-scan and snapshot refresh behavior

### Depends On

- T1

### Acceptance Focus

- the app can produce a stable local inventory from the managed device
- the inventory contains enough information for downstream governance logic
- partial or denied permissions produce understandable degraded behavior

## T3. Implement Local State Store Foundation

### Outcome

The client has a persistent local state store for inventory, archive snapshots, Governance Recommendations, Governance Batches, and policy settings.

### Scope

- persist media inventory records
- persist archive record snapshots from the service
- persist policy settings
- support queries for governance home, archive status, batch review, and archived resources
- support reconciliation between local observation state and remote archive truth

### Depends On

- T1

### Acceptance Focus

- the app can reopen without losing governance-relevant state
- state queries support the key views in the product
- local state and remote state can be reconciled without ambiguity

## T4. Implement On-Device Analysis and Governance Classification

### Outcome

The iOS client can derive Governance Classification from local signals and classify resources into usable governance states.

### Scope

- compute Usage Heat from allowed local signals
- derive Cold Resource candidates
- derive Protected Resource status
- derive shallow content hints such as screenshots, camera photos, and ordinary videos
- calculate Space Saving Opportunity inputs

### Depends On

- T2
- T3

### Acceptance Focus

- the classification pipeline is on-device and deterministic
- Cold Resource and Protected Resource behavior align with the agreed domain model
- no server dependency is required just to decide whether a resource is cold

## T5. Build Archive Service Foundation and Object Storage Control Plane

### Outcome

The backend can create archive sessions, track archive records, verify objects, and expose archive status in a platform-neutral way.

### Scope

- create archive session API
- design archive record lifecycle
- integrate object storage upload target issuance
- implement integrity verification path
- record restore mappings
- expose archive status query capability

### Depends On

- T2
- T3

### Acceptance Focus

- archive status is controlled by the service rather than inferred solely by the client
- Archive Completion requires successful write, integrity verification, and restore mapping
- the contracts remain Android-ready and not iOS-specific

## T6. Implement Client Archive Coordinator and Archive Status Experience

### Outcome

The iOS client can initiate archive work, upload Original Archive Copy files, observe archive progress, and surface archive states in the product.

### Scope

- implement client-side archive coordinator
- request archive sessions from the service
- upload original files to object storage
- synchronize archive status snapshots back into local state
- build archive queue and status experience

### Depends On

- T4
- T5

### Acceptance Focus

- users can initiate archiving from the app
- the archive queue reflects pending, uploading, verifying, complete, and failed states
- archive-complete state is never shown prematurely

## T7. Build Governance-Centered Home and Governance Batch Review

### Outcome

The iOS client presents the governance-first product experience, including storage pressure, Space Saving Opportunity, Governance Recommendations, and Governance Batches.

### Scope

- build Governance-Centered View
- show current local media storage footprint
- show immediate and potential reclaimable space
- show top Governance Batches and rationale
- build batch review screen with item counts, savings, status breakdown, and confirmation CTA

### Depends On

- T4
- T5

### Acceptance Focus

- the app reads as a Media Space Governance product, not a gallery clone
- the user can understand why a batch exists and what benefit it offers
- the UI distinguishes archive-ready opportunity from immediately reclaimable space

## T8. Implement Cleanup Eligibility and User-Confirmed Local Cleanup

### Outcome

The app can turn Archive Completion plus governance rules into cleanup eligibility, and can perform explicit user-confirmed cleanup on a Governance Batch.

### Scope

- derive cleanup eligibility from archive state, policy, and Protected Resource status
- block cleanup for non-archive-complete resources
- implement explicit batch confirmation flow
- delete Local Primary through the iOS media access boundary
- update local state after cleanup and reconcile with remote status if needed

### Depends On

- T6
- T7

### Acceptance Focus

- no cleanup occurs without explicit user confirmation
- Protected Resources stay out of default cleanup batches
- cleaned resources transition out of local-present state correctly

## T9. Implement Archived Resource Listing and Single-Item Restore

### Outcome

Users can view archived resources and restore one cleaned resource back onto the managed device.

### Scope

- build archived resource listing
- distinguish Archived Local Retention from cleaned-local resources
- implement restore request flow against the archive service
- download Original Archive Copy from the Remote Archive
- reinsert the restored file through the iOS media boundary
- update local state after restore

### Depends On

- T4
- T6
- T7

### Acceptance Focus

- users can identify which resources remain recoverable
- Restore produces a usable local copy
- restore behavior does not depend on preview-only data

## T10. Safety, Policy, Observability, and Release Hardening

### Outcome

The product is safe to ship as an iOS phase 1 release, with policy controls, failure handling, and metrics that validate trust and business value.

### Scope

- implement limited Default Cooling Policy settings
- add explicit handling for archive failures, restore failures, and permission degradation
- instrument metrics for scan completion, archive initiation, archive completion, cleanup confirmation, reclaimed storage, restore success, and regret signals
- harden reconciliation flows for stale local versus remote archive state
- finalize Android-ready interface constraints in shared workflow boundaries

### Depends On

- T6
- T7
- T8
- T9

### Acceptance Focus

- trust-model guarantees are observable and enforceable
- the app degrades safely under failure conditions
- the release produces enough operational data to judge phase 1 success

## Recommended Delivery Order

1. T1
2. T2 and T3
3. T4 and T5
4. T6 and T7
5. T8 and T9
6. T10

## Priority Bands

### MVP

These tickets are required for a credible iOS phase 1 release. Without them, the product cannot complete the promised Media Space Governance workflow.

1. T1. Establish Workflow Skeleton and Shared Domain States
2. T2. Implement iOS Media Access Boundary and Local Inventory
3. T3. Implement Local State Store Foundation
4. T4. Implement On-Device Analysis and Governance Classification
5. T5. Build Archive Service Foundation and Object Storage Control Plane
6. T6. Implement Client Archive Coordinator and Archive Status Experience
7. T7. Build Governance-Centered Home and Governance Batch Review
8. T8. Implement Cleanup Eligibility and User-Confirmed Local Cleanup
9. T9. Implement Archived Resource Listing and Single-Item Restore

### P1

These tickets materially improve trust, operability, and release safety, but can be sequenced after the core workflow is proven if the team needs to tighten the first ship scope.

1. T10. Safety, Policy, Observability, and Release Hardening

### P2

No separate P2 tickets are defined yet from the current phase 1 scope. The remaining likely P2 work would come from follow-on expansion rather than unfinished phase 1 essentials, such as:

1. Android client implementation on top of the existing Android-ready boundaries
2. richer archived-resource preview experience
3. more advanced duplicate or near-duplicate analysis
4. broader policy tuning beyond the limited Default Cooling Policy surface

## Minimum Shippable Slice

If the team needs the narrowest possible first ship while still preserving the product promise, the minimum coherent slice is:

1. T1
2. T2
3. T3
4. T4
5. T5
6. T6
7. T7
8. T8
9. T9

This slice delivers:

- iOS media inventory
- On-Device Analysis
- Governance-Centered View
- Original Archive Copy upload
- strict Archive Completion
- Governance Batch review
- explicit local cleanup
- single-item Restore

T10 should still be treated as the first post-MVP hardening pass before any broad rollout.

## Suggested Agent-Friendly Issue Titles

1. Establish shared Media Space Governance workflow states
2. Implement iOS media access and local inventory
3. Build local state store foundation
4. Implement on-device Governance Classification
5. Build archive service and object storage control plane
6. Implement client archive coordinator and archive status UI
7. Build Governance-Centered View and Governance Batch review
8. Implement cleanup eligibility and confirmed local cleanup
9. Implement archived resource listing and single-item restore
10. Harden safety, policy settings, and observability

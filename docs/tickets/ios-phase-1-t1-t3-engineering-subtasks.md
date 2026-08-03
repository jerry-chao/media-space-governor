# T1-T3 Engineering Subtasks: iOS Phase 1 Media Space Governance

## Purpose

This document breaks T1, T2, and T3 into engineer-ready subtasks so implementation can begin without reinterpreting the higher-level tickets.

Scope covered here:

- T1. Establish Workflow Skeleton and Shared Domain States
- T2. Implement iOS Media Access Boundary and Local Inventory
- T3. Implement Local State Store Foundation

## Working Rules

- Preserve one `Media Space Governance workflow`
- Keep product semantics platform-neutral even when implementing iOS-first
- Do not let iOS framework types leak into workflow-domain contracts
- Keep local observation state and remote archive state separate in the data model

## T1. Establish Workflow Skeleton and Shared Domain States

### T1.1 Create initial project layout

- create top-level areas for iOS app code, shared workflow-domain code, and service contract models
- reserve a platform boundary area for future Android parity even if no Android code exists yet
- establish a naming scheme that follows the domain glossary rather than gallery or sync vocabulary

### T1.2 Define workflow-stage vocabulary

- define the major workflow stages used across the product
- document stage transitions for inventory, analysis, archive, cleanup, and restore
- ensure the terms match `CONTEXT.md`

### T1.3 Define state enums or equivalent state shapes

- define local presence states
- define archive states
- define cleanup eligibility states
- define restore states if separated from archive state
- ensure each state is observable in UI and tests

### T1.4 Define core workflow record shapes

- define `Media Resource Record`
- define `Archive Record Snapshot`
- define `Governance Recommendation Record`
- define `Governance Batch Record`
- define `Policy Settings Record`

### T1.5 Define stable identifiers

- define local resource identifier rules
- define archive record identifier rules
- define batch identifier strategy
- ensure identifiers can survive app restarts and local rescans

### T1.6 Define domain-to-platform boundaries

- define the media access adapter interface
- define the archive coordinator interface boundary
- define the local store interface boundary
- ensure none of these interfaces require direct use of iOS UI or framework-specific types in their domain-facing surface
- deferred: the `MediaSpaceGovernorCore` package slice ships only the
  platform-neutral domain shapes and transitions; the three adapter interfaces
  are stubbed conceptually here and implemented as iOS adapters in T2/T3

### T1.7 Create workflow test harness skeleton

- create an initial test target or equivalent structure for high-level workflow tests
- create test doubles for media access, archive status, and local store boundaries
- prove the project can host workflow-first tests before feature logic grows

### T1.8 Acceptance checkpoint for T1

- one shared workflow vocabulary exists
- state names are consistent with spec and technical design
- domain-facing contracts are Android-ready in shape
- implementation can proceed without re-deciding naming or state boundaries

## T2. Implement iOS Media Access Boundary and Local Inventory

### T2.1 Implement permission abstraction

- model permission states relevant to media access
- implement permission request flow
- implement permission inspection/refresh flow
- expose degraded mode behavior for denied or limited access

### T2.2 Implement inventory enumeration entry point

- enumerate image resources
- enumerate video resources
- normalize enumeration output to the shared media resource shape
- support empty-library behavior cleanly

### T2.3 Extract inventory metadata required by downstream governance

- media type
- file size
- creation time
- stable local identifier
- content hints available without deep semantic analysis
- last-known local signals that are actually available on iOS and allowed by the product boundary

### T2.4 Implement screenshot and camera-photo detection path

- define the shallow content classification path for screenshots
- define the shallow content classification path for camera photos
- define fallback behavior when hints are unavailable or ambiguous

### T2.5 Implement incremental re-scan behavior

- define initial full-scan flow
- define re-entry behavior on app reopen
- define refresh behavior after cleanup or restore
- define stale-record handling when a local resource disappears outside the app

### T2.6 Normalize inventory into store-ready records

- map iOS media results into `Media Resource Record`
- mark local presence state correctly
- leave archive state empty or unknown until synced from archive-side information
- preserve enough raw fields for future governance recomputation without rescanning everything unnecessarily

### T2.7 Build media access adapter test coverage

- permission granted flow
- permission denied flow
- limited/partial permission behavior if applicable
- mixed image/video inventory
- empty inventory
- local resource removed between scans

### T2.8 Acceptance checkpoint for T2

- the app can produce a stable normalized inventory from iOS media sources
- inventory records are suitable for Governance Classification
- permission failure produces explicit degraded behavior rather than hidden failure

## T3. Implement Local State Store Foundation

### T3.1 Choose and scaffold local persistence mechanism

- choose the iOS persistence technology
- create store initialization path
- create migration/versioning placeholder strategy
- ensure the persistence choice can support query-by-state and incremental updates

### T3.2 Create persistence models for workflow records

- persist media resource records
- persist archive record snapshots
- persist governance recommendation records if materialized
- persist governance batch records if materialized
- persist policy settings

### T3.3 Separate local observation state from remote archive truth

- store device-derived media facts separately from service-derived archive facts
- define merge/reconciliation rules between them
- prevent archive state from being overwritten by unrelated local scans

### T3.4 Implement repository/query layer for product views

- query storage footprint summary
- query candidate Cold Resources and Protected Resources
- query Governance Batches
- query archive queue/status
- query archived resource list

### T3.5 Implement write/update paths

- upsert inventory from scan results
- update archive snapshots from service sync
- update local presence after cleanup
- update local presence after restore
- update policy settings

### T3.6 Implement reconciliation rules

- handle local resource deleted outside the app
- handle archive snapshot updated while local inventory is stale
- handle restored resource reappearing locally
- handle duplicate updates from rescan and service sync

### T3.7 Implement state invalidation and refresh triggers

- refresh relevant queries after scan completion
- refresh relevant queries after archive status changes
- refresh relevant queries after cleanup
- refresh relevant queries after restore

### T3.8 Build local store test coverage

- store initialization
- inventory upsert and query
- archive snapshot merge
- cleanup state transition persistence
- restore state transition persistence
- stale local vs remote archive reconciliation

### T3.9 Acceptance checkpoint for T3

- the app can persist and reload workflow state across launches
- queries support all near-term product views
- local and remote state remain conceptually separate and reconcilable

## Recommended Build Order

1. T1.1-T1.6
2. T3.1 and T3.2
3. T2.1-T2.4
4. T2.6 and T3.4-T3.5
5. T2.5 and T3.6-T3.7
6. T1.7, T2.7, and T3.8
7. T1.8, T2.8, and T3.9

## Definition of Ready for T4

T4 can start when all of the following are true:

- a normalized media inventory can be produced from iOS media sources
- the local store can persist and query media records and archive snapshots
- shared workflow states are defined and stable
- Governance Classification inputs can be read without reworking the media boundary or store schema

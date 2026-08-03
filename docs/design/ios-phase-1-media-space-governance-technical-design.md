# iOS Phase 1 Technical Design: Media Space Governance

## Goal

Define a technical design for an iOS-first implementation of Media Space Governance that preserves the single high-level workflow while keeping platform-specific behavior behind stable boundaries for future Android support.

The design must preserve the established domain language:

- Media Space Governance
- Remote Archive
- Local Primary
- Governance Classification
- Cold Resource
- Protected Resource
- Archive Completion
- Governance Batch
- Archived Local Retention
- Restore

The design must also preserve the ADR that the Remote Archive stores the Original Archive Copy.

## System Shape

Phase 1 ships one iOS client and one shared backend/service layer.

The system should be organized around a single end-to-end workflow:

1. Enumerate media inventory on the managed device
2. Derive Governance Classification on-device
3. Generate Governance Recommendations and Governance Batches
4. Upload eligible Original Archive Copy files into the Remote Archive
5. Verify Archive Completion through service-side archive records
6. Allow user-confirmed cleanup of Local Primary
7. Support Restore back onto the managed device

Beneath that workflow, there are three main boundaries:

1. iOS media access boundary
2. archive service boundary
3. object storage archive boundary

This keeps the product model unified while isolating platform integration points.

## High-Level Components

### 1. iOS Client

The iOS client owns:

- device permission flow
- local media inventory enumeration
- On-Device Analysis
- local persistence of inventory and status snapshots
- Governance-Centered View rendering
- Governance Batch review and confirmation UI
- upload orchestration initiation
- local cleanup execution after user confirmation and archive eligibility
- Restore initiation and restored-file reinsertion into device-local storage where allowed

The iOS client must not own the canonical meaning of archive state. It may cache archive status, but the source of truth for archive records should be the archive service.

### 2. Archive Service

The archive service owns:

- archive session creation
- upload authorization or upload target issuance
- archive record lifecycle
- integrity verification state
- restore mapping between local resource identity and remote object identity
- cleanup eligibility state derivation based on Archive Completion
- archived resource listing for the client
- restore request orchestration

This service should be designed once for both iOS and future Android clients.

### 3. Object Storage Archive

The object storage archive owns:

- binary storage for Original Archive Copy objects
- durable object identifiers
- object existence and integrity-verification inputs
- optional derivative storage, if previews are later introduced

Object storage is an implementation of Remote Archive, not the business owner of archive semantics.

## Single Workflow Design

### Step 1: Media Inventory

The iOS client scans the managed device and produces a normalized media inventory.

Each inventory item should contain at least:

- stable local resource identifier
- media type
- file size
- creation time
- last-known local usage signals where available
- shallow content hints such as screenshot, camera photo, ordinary video
- local presence state
- archive state snapshot

The client should store this inventory in a local store optimized for repeated scans, incremental refresh, and query-by-governance-state.

### Step 2: On-Device Analysis

Governance Classification should be computed on-device from local metadata and allowed device-local signals.

The analysis pipeline should derive:

- Usage Heat
- Cold Resource candidate status
- Protected Resource status
- Governance-Driven Grouping inputs
- Space Saving Opportunity inputs

This pipeline should be deterministic from the local model plus user policy settings. It should not call the backend merely to decide whether a resource is cold.

### Step 3: Governance Recommendation and Batch Generation

The client should derive Governance Recommendations from the analyzed inventory and then group them into Governance Batches.

Recommended default batch families:

- large cold videos
- cold screenshots
- cold camera photos above a configurable cooling threshold
- archive-complete resources eligible for cleanup

Batch generation should remain local in phase 1, because the product is single-device and the relevant signals are already on-device. The backend should not be required to compute governance logic just to render recommendations.

### Step 4: Archive Initiation

When the user starts archive work, the client should request an archive session from the archive service.

That session should return enough information for the client to:

- associate the local resource with a pending archive record
- upload the Original Archive Copy to object storage
- report progress and completion back to the archive service

This boundary should avoid platform-specific assumptions so Android can later reuse the same service contract.

### Step 5: Archive Completion

Archive Completion must not be inferred from a completed client upload alone.

The service should mark Archive Completion only after:

1. the object exists in the Remote Archive
2. integrity verification succeeds
3. the restore mapping has been recorded

Until then, the client may show intermediate archive states such as pending, uploading, verifying, or failed.

### Step 6: Cleanup Eligibility and User Confirmation

The client should compute cleanup recommendations only for resources that are:

- archive-complete
- not Protected Resources
- included by the current Default Cooling Policy

User confirmation remains mandatory.

The cleanup action should be modeled as:

1. batch review
2. explicit confirmation
3. local deletion of Local Primary through the iOS media boundary
4. local and remote state refresh

Cleanup should update the local store immediately after success and then reconcile with the archive service if needed.

### Step 7: Restore

Restore is a user-initiated action on one archived resource at a time.

The restore flow should be:

1. client requests restore for a specific archived resource
2. archive service resolves the restore mapping
3. client downloads the Original Archive Copy from the Remote Archive
4. iOS media boundary writes the usable local copy back to the managed device
5. local state transitions back to local-present status

Restore should not depend on preview-only assets.

## iOS Client Design

### Client Modules

The iOS client should be structured around a small set of high-level modules.

#### Media Access Adapter

Responsibilities:

- request and inspect media permissions
- enumerate photos and videos
- read metadata needed for Governance Classification
- delete Local Primary after confirmation
- write restored media back to device-visible storage where supported

This adapter is the main platform seam to be mirrored by Android later.

#### Local Governance Engine

Responsibilities:

- compute Usage Heat
- derive Cold Resource and Protected Resource states
- apply Default Cooling Policy
- produce Governance Recommendations
- group Governance Batches
- calculate Space Saving Opportunity

This engine should be platform-neutral in shape even if first implemented inside the iOS codebase.

#### Local State Store

Responsibilities:

- persist inventory snapshots
- persist archive status snapshots
- persist policy settings
- support queries for home view, batch review, and archived resource list

This store should separate local observation state from remote archive-record state so reconciliation stays clear.

#### Archive Coordinator

Responsibilities:

- request archive sessions
- upload files using service-issued instructions
- track upload progress
- synchronize archive status into the local store
- initiate restore requests

This coordinator owns client-side orchestration but not archive truth.

#### Governance UI Layer

Responsibilities:

- render the Governance-Centered View
- render batch review
- render archive queue/status
- render archived resources and restore actions
- render limited policy settings

### Suggested Local Data Model

The client-local model should include at least these conceptual records:

#### Media Resource Record

- local resource id
- media type
- content hint
- size
- creation time
- last-known view/share/edit signals
- local presence state
- protected flag
- cold-resource flag

#### Archive Record Snapshot

- local resource id
- archive record id
- archive state
- remote object id if known
- integrity-verification status
- restore availability flag
- last sync time

#### Governance Recommendation Record

- recommendation id
- recommendation type
- local resource id
- rationale summary
- space saving value
- eligibility state

#### Governance Batch Record

- batch id
- batch type
- item count
- total space saving opportunity
- required action type
- blocking reasons if not fully actionable

#### Policy Settings Record

- cooling threshold
- aggressive screenshot governance enabled
- large video preference enabled
- show cleanup only for archive-complete enabled

## Archive Service Design

### Service Responsibilities

The archive service is the control plane for Remote Archive behavior.

It should expose capabilities for:

- registering archive intent for one or more resources
- issuing upload targets or credentials
- receiving upload completion callbacks or client confirmations
- verifying object existence and integrity
- recording archive metadata and restore mapping
- reporting archive state back to clients
- listing archived resources for a user and managed device
- authorizing and describing restore downloads

### Service Data Model

The service should persist conceptual entities such as:

#### Managed Device

- device id
- user id
- platform type
- lifecycle status

#### Archive Record

- archive record id
- user id
- device id
- client resource id
- media type
- original size
- object id
- archive status
- integrity status
- restore status
- timestamps

#### Restore Mapping

- archive record id
- object id
- original file characteristics needed for restore
- active/inactive state

#### Archive Event Log

- archive record id
- state transition
- actor
- time
- error summary if any

The service does not need to own the full local media inventory for phase 1. It only needs enough metadata to support archive truth and restore.

### Service API Shape

The exact transport can be decided later, but the contract should cover these workflow calls:

1. create archive session
2. query archive status for resources or batches
3. list archived resources
4. create restore request
5. obtain restore download details

The API should use platform-neutral terms such as managed device, archive record, archive status, and restore rather than iOS-specific naming.

## Object Storage Flow

### Upload Path

The archive upload path should be:

1. iOS client asks archive service for an archive session
2. archive service issues upload target details
3. iOS client uploads Original Archive Copy to object storage
4. client reports upload completion or object reference
5. archive service verifies object existence and integrity
6. archive service marks Archive Completion and creates restore mapping

### Download Path

The restore download path should be:

1. iOS client requests restore
2. archive service resolves archive record and object id
3. archive service returns authorized download details
4. iOS client downloads Original Archive Copy
5. iOS media adapter writes it back locally

### Object Identity

Object identity should be opaque to the client except where needed for progress tracking or restore. The archive service should own mapping from product concepts to object storage identities.

### Integrity Verification

Integrity verification may be implemented via checksums, object metadata comparison, or equivalent verifiable means. The important requirement is not the algorithm but the state guarantee: upload success is insufficient until integrity and restore mapping are both complete.

## State Model

### Local Presence State

Each media resource should be able to represent at least:

- local only
- local and archived
- archived with local cleaned
- restore in progress
- restore failed

### Archive State

Each archive record should represent at least:

- not requested
- pending
- uploading
- verifying
- archive complete
- archive failed

### Cleanup Eligibility State

Each resource should distinguish:

- not eligible
- blocked by missing Archive Completion
- blocked as Protected Resource
- blocked by policy
- eligible for cleanup
- cleaned locally

These states should be rendered directly in the product experience where appropriate.

## Security and Trust Constraints

- Original media must not be uploaded merely for remote classification.
- Cleanup must never happen without explicit user confirmation.
- Archive Completion must remain strict.
- Protected Resources must remain outside default cleanup recommendations.
- Restore must use the Original Archive Copy.
- Service-side data should be minimized to archive truth and restore support, not full cloud-gallery semantics.

## Android-Ready Design Rules

Phase 1 does not ship Android behavior, but the design must keep Android support cheap to add later.

Rules:

1. Do not bake iOS framework types into governance-domain interfaces.
2. Do not let archive service APIs depend on iOS-only identifiers outside the client-resource boundary.
3. Keep Governance Classification logic portable in shape, even if the first implementation is written in Swift.
4. Keep Local State Store semantics platform-neutral so Android can mirror the same states.
5. Keep Governance UI concepts aligned to the domain model rather than iOS-specific navigation structure.

## Suggested Implementation Order

### Slice 1: Local Inventory and Governance Insight

- iOS permission flow
- media inventory enumeration
- Local State Store foundation
- Local Governance Engine
- Governance-Centered View with storage summary and top Governance Batches

### Slice 2: Archive Control Plane and Upload Path

- archive service foundation
- archive session API
- object storage upload flow
- archive status reconciliation
- archive queue and status UI

### Slice 3: Cleanup Workflow

- cleanup eligibility derivation
- batch review
- explicit cleanup confirmation
- local deletion through media adapter
- post-cleanup state update

### Slice 4: Restore Workflow

- archived resources list
- restore request flow
- restore download and local reinsertion
- restore-state handling and error presentation

### Slice 5: Safety and Policy Polish

- Protected Resource handling refinements
- policy settings
- error recovery
- observability and regret metrics

## Testing Strategy

### Highest-Level Workflow Tests

Prefer end-to-end behavioral tests around the single workflow seam:

- a Cold Resource becomes archive-eligible but not cleanup-eligible until Archive Completion
- a Protected Resource never enters default cleanup batches
- an archive-complete resource can remain in Archived Local Retention
- a Governance Batch exposes accurate Space Saving Opportunity
- cleanup requires explicit confirmation
- Restore returns a usable local copy after cleanup

### Boundary Tests

Add smaller tests only at the three boundaries:

1. iOS media access adapter
2. archive service contract
3. object storage verification path

These tests should validate observable behavior, not internal implementation structure.

### Failure Cases to Cover

- permission denied or partial permission
- interrupted upload
- failed integrity verification
- stale local status vs remote archive truth
- cleanup attempt before Archive Completion
- restore request for missing or invalid mapping
- local reinsertion failure during Restore

## Open Decisions Left for Implementation

- exact iOS persistence technology for the Local State Store
- exact service transport style and authentication method
- exact object verification mechanism
- exact strategy for incremental rescans and background work limits on iOS
- exact preview-generation behavior for archived resources, if any
- exact heuristics for screenshot and video prioritization beyond the domain-level rules

## Summary

This design keeps the system centered on one Media Space Governance workflow while isolating platform-sensitive behavior behind stable boundaries. It enables a focused iOS phase 1 delivery without forcing the product model, archive semantics, or trust guarantees to be redefined when Android support is added later.

# Phase 1 PRD: Media Space Governance

## Product Definition

This product is a mobile app for individual users on a single device. Its first-stage purpose is to reduce device storage consumed by local photos and videos through on-device analysis, governance recommendations, remote archiving of original files, user-confirmed local cleanup, and on-demand restore.

## Problem Statement

Users accumulate large volumes of local photos and videos on Android and iOS devices. Storage pressure grows over time, but current device galleries are optimized for browsing rather than storage governance. Users struggle to answer practical questions such as:

- What is taking the most space?
- Which media is no longer actively used?
- Which resources are safe to move off-device?
- How much space can be reclaimed now?
- Can removed local media be reliably restored later?

## Product Goal

Help users safely reclaim device storage from photos and videos without feeling that the product is unpredictably deleting or downgrading their personal media.

## Target User

- Individual user
- One account managing one device in phase 1
- Primary pain point is local storage pressure caused by photos and videos

## Core Value Proposition

- Identify storage-saving opportunities from local media
- Classify media for governance rather than album browsing
- Archive original files remotely before any local cleanup
- Let users confirm cleanup in batches instead of item-by-item
- Preserve trust through clear archive status and recoverability

## Non-Goals

- Multi-device unified library
- Real-time cloud sync across devices
- Rich AI album experience
- Deep semantic content understanding
- Automatic local deletion without user confirmation
- Compressed-only archival as the main archive path
- Social sharing or collaborative albums

## Phase 1 Scope

### In Scope

- Android and iOS mobile apps
- Local scan of photos and videos on the current device
- On-device governance classification
- Shallow content classification: screenshots, camera photos, ordinary videos
- Usage heat estimation from stable local signals
- Detection of cold resource candidates
- Identification of protected resources
- Remote archive upload of original files
- Strict archive completion verification before cleanup eligibility
- Governance-centered home view
- Governance recommendations grouped into governance batches
- User-confirmed local cleanup after archive completion
- Archived-local-retention state
- Archived resource listing and single-item restore
- Space saving opportunity display
- Limited user adjustment of cooling thresholds

### Out of Scope

- User-authored rule engines
- Complex third-party app behavior tracking
- Server-side analysis of original media for classification
- Scene, person, event, or emotional-importance classification
- Auto-cleanup without explicit user action
- Bulk restore workflows beyond basic single restore
- Desktop or web client

## User Outcomes

Users should be able to:

1. See where photo and video storage is being consumed.
2. Understand which media is a likely cold resource.
3. See which resources are protected from cleanup.
4. Archive eligible media to a remote archive while preserving originals.
5. Review cleanup opportunities in meaningful batches.
6. Confirm local cleanup only after archive completion.
7. See how much space can be reclaimed now versus later.
8. Restore an archived resource back to the device when needed.

## Primary User Flow

1. User grants local media access permissions.
2. App scans local photos and videos on the managed device.
3. App analyzes local metadata and derives governance classifications on-device.
4. App shows a governance-centered home view with storage pressure and space saving opportunities.
5. User reviews governance batches such as large cold videos or old archived screenshots.
6. User initiates remote archiving for eligible resources.
7. System verifies archive completion.
8. Archived resources enter either:
- archived local retention, if user keeps the local primary
- cleanup recommendation eligibility, if governance rules suggest cleanup
9. User reviews a batch and explicitly confirms local cleanup.
10. App removes the local primary for confirmed items.
11. User can later view archived items and restore a selected resource.

## Functional Requirements

### 1. Media Inventory

- The app must scan local photos and videos on the managed device.
- The app must record enough local metadata to support governance classification and archive mapping.
- The app must distinguish at minimum between image and video media types.

### 2. Governance Classification

- The app must classify media for governance purposes rather than generic album taxonomy.
- The app must support shallow content classification for screenshots, camera photos, and ordinary videos.
- The app must derive usage heat from stable local signals such as recent view, recent share, recent edit, and creation time where available.
- The app must identify cold resource candidates using the default cooling policy.
- The app must identify protected resources and exclude them from first-stage default cleanup recommendations.

### 3. Recommendation Engine

- The app must generate governance recommendations rather than directly deleting local files.
- The app must group recommendations into governance batches.
- The primary grouping logic must be governance-driven, using combinations of media type, storage size, cooling duration, and archive readiness.
- The app must support a limited set of user-adjustable thresholds in the default cooling policy.

### 4. Remote Archive

- The app must upload original media files to the remote archive.
- The remote archive must not be modeled as a real-time sync source of truth.
- Archive completion must require successful remote write, integrity verification, and a recorded restore mapping.
- A media resource may remain in archived local retention after archive completion.

### 5. Local Cleanup

- The app must never perform first-stage local cleanup without explicit user confirmation.
- The app must support batch cleanup confirmation.
- Only media with archive completion may enter cleanup-eligible recommendations.
- Protected resources must be excluded from default cleanup batches.

### 6. Restore

- The app must provide a view of archived resources.
- The app must support user-initiated single-item restore.
- Restore must return a usable local copy to the managed device.

### 7. Product Experience

- The home view must be governance-centered rather than gallery-centered.
- The app must display space saving opportunities as a core part of the experience.
- The app must distinguish immediate reclaimable space from potential future reclaimable space.
- The app must clearly communicate archive state, cleanup consequences, and restore availability.

## Candidate Governance Batches

- Large cold videos already archived
- Images older than a threshold and already archived
- Cold screenshots already archived
- Duplicate or near-duplicate candidates requiring explicit review

## Key Screens

### 1. Governance Home

- Current local media storage footprint
- Immediate reclaimable space
- Potential reclaimable space after archive
- Top governance batches
- Archive progress and archive completion summary

### 2. Batch Review

- Batch definition
- Why the batch was created
- Number of items
- Expected reclaimed space
- Archive status breakdown
- Cleanup confirmation action

### 3. Archive Queue and Status

- Items waiting for archive
- In-progress uploads
- Archive completion results
- Archive failures requiring user attention

### 4. Archived Resources

- Archived items list
- Archived-local-retention vs cleaned-local status
- Single restore action

### 5. Policy Settings

- Cooling threshold selection
- Prefer aggressive screenshot governance toggle
- Prefer large video governance toggle
- Show cleanup recommendations only for archive-complete items toggle

## Success Metrics

- Percentage of users who complete first device scan
- Percentage of users who complete at least one archive action
- Percentage of users who confirm at least one cleanup batch
- Median reclaimed storage per active user
- Restore success rate
- Cleanup regret signals, such as immediate restore after cleanup
- Archive completion success rate

## Trust and Safety Requirements

- No default auto-deletion of local media
- Clear explanation before cleanup confirmation
- Original files preserved as the primary archive copy
- Restore path available for cleaned resources
- Protected resources excluded from default cleanup recommendations

## Open Implementation Topics

- Exact platform-specific signals available for usage heat on iOS versus Android
- Exact local permission model and degraded behavior when permissions are partial
- OSS provider integration details and object naming strategy
- Preview generation strategy for archived resources
- Duplicate and near-duplicate detection confidence thresholds
- Failure recovery behavior for interrupted archive sessions

## Suggested Delivery Breakdown

### Milestone 1: Local Inventory and Governance Insight

- Local scan
- Storage footprint analysis
- Governance-centered home view
- Shallow content classification
- Usage heat and cold resource detection

### Milestone 2: Remote Archive Foundation

- Original file upload
- Archive completion verification
- Archive status tracking
- Archived local retention state

### Milestone 3: Cleanup and Recovery

- Governance batches
- Batch review and cleanup confirmation
- Archived resources list
- Single-item restore

### Milestone 4: Policy Tuning and Safety Polish

- Limited threshold customization
- Protected resource rules
- Better failure handling and trust messaging

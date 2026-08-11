# iOS: classify authorized local media and measure candidate storage

## Problem Statement

The iOS demo can run on a device, but it does not yet provide a truthful Media Space Governance inventory of the user's authorized photos and videos. A user cannot see whether the product analyzed the whole library or a limited selection, receive Governance Classification from real device metadata, or obtain a reliable Space Saving Opportunity without silently downloading iCloud originals. The product must preserve the existing safety boundary: analysis and Governance Recommendations must not upload, delete, or otherwise alter Local Primary media.

## Solution

Provide an iOS Media Access Adapter that requests Photos access, inventories only the user's authorized visible photos and videos, and immediately derives shallow On-Device Analysis through the existing GovernanceEngine. The Governance-Centered View will disclose Library Access Coverage and display classification and archive recommendations without reading media content.

For unprotected Cold Resources, a second non-main-thread pass will measure locally available original-resource bytes one candidate at a time. It will never request an iCloud download. Only measured local originals contribute to Space Saving Opportunity; unavailable originals remain explicitly unmeasured. This feature ends at classification and recommendations: it does not create a Remote Archive, establish Archive Completion, clean a Local Primary, or restore a resource.

## User Stories

1. As a device owner, I want to grant the app access to my photos and videos, so that it can analyze the media I authorize.
2. As a device owner, I want to deny photo access without the app crashing, so that I retain control of my library.
3. As a device owner, I want to see when I granted limited Photos access, so that I do not mistake a partial inventory for my complete library.
4. As a device owner, I want to see how many authorized media resources were scanned, so that I understand the scope of On-Device Analysis.
5. As a device owner, I want authorized screenshots classified as screenshots, so that screenshot-specific cooling policy can apply.
6. As a device owner, I want authorized camera photos classified as camera photos, so that the product can make Governance-Centered recommendations without deep content analysis.
7. As a device owner, I want authorized videos classified as ordinary videos, so that video-oriented governance can be considered.
8. As a device owner, I want the product to use local metadata rather than upload original media for classification, so that analysis respects privacy and avoids unnecessary network use.
9. As a device owner, I want favorite media treated as Protected Resources, so that my explicit retention signal excludes it from default governance recommendations.
10. As a device owner, I want hidden media excluded from the first-stage inventory, so that hidden-library privacy expectations are preserved.
11. As a device owner, I want old, unused authorized resources to become Cold Resources under the Default Cooling Policy, so that I can review archive opportunities.
12. As a device owner, I want newly scanned resources to receive Governance Recommendations promptly, so that size measurement does not block classification.
13. As a device owner, I want accurate local byte measurements for eligible Cold Resources, so that a displayed Space Saving Opportunity is credible.
14. As a device owner, I want size measurement to progress in the background while the app remains responsive, so that a large library does not freeze the Governance-Centered View.
15. As a device owner, I want resources whose originals are not currently on-device to remain unmeasured, so that the app does not download iCloud media merely to analyze storage.
16. As a device owner, I want unmeasured resources clearly excluded from storage-impact totals, so that zero bytes is never mistaken for a measured result.
17. As a device owner, I want measurement to stop safely when a scan is superseded or cancelled, so that the app does not continue unnecessary local I/O.
18. As a device owner, I want this feature to make recommendations only, so that no Local Primary is uploaded or deleted without a separate explicit workflow.
19. As a device owner, I want no semantic people, scene, or event classification, so that the first-stage product remains focused on storage governance.
20. As a future Android user, I want platform-specific media access kept behind one adapter boundary, so that Android can mirror the workflow without duplicating governance rules.

## Implementation Decisions

- Retain the existing GovernanceEngine as the single domain workflow seam for Governance Classification, Cold Resource determination, Protected Resource exclusion, Governance Recommendations, and later Governance-Driven grouping. The iOS client supplies normalized inventory facts; it must not duplicate policy logic.
- Add one iOS Media Access Adapter boundary. It owns Photos authorization, visible-library enumeration, metadata projection, local-original measurement, scan cancellation, and coverage reporting. Photos framework types must not enter the governance-domain API.
- Request Photos read/write access because full-library inventory requires that access level. The app will not invoke mutation APIs in this feature. The user-facing permission purpose states that media is analyzed for storage governance and is not automatically uploaded or deleted.
- Treat both authorized and limited authorization as usable. Limited authorization must be rendered as partial Library Access Coverage with the scanned count. Denied, restricted, and unavailable states must render a recovery message instead of an empty-library result.
- Enumerate only visible photo and video assets. Exclude hidden assets and unsupported asset kinds. Preserve each usable asset's stable local identifier, creation time, media type, shallow Content Hint, and favorite signal. Skip assets whose required metadata is unavailable rather than fabricating a date or classification.
- Map screenshot metadata to the screenshot Content Hint; map other image assets to camera-photo Content Hint; map video assets to ordinary-video Content Hint. Do not add semantic image classification.
- Map a Photos favorite signal to Protected Resource. Leave unavailable view, share, and edit evidence absent rather than inferring it from unrelated Photos metadata.
- Separate local-size availability from a numeric byte value. Unknown or unavailable original bytes must never be represented as a measured zero. Governance Classification may run before size measurement; storage-impact presentation and large-video prioritization may use only measured values.
- After initial metadata classification, measure only unprotected Cold Resources. Process candidates sequentially on non-main execution while the app is active, report progress, and cancel work when a newer scan replaces it or the user cancels it.
- Measure each resource by streaming only the locally available original components required to preserve an Original Archive Copy, including paired components where applicable. Discard streamed bytes immediately after counting. Do not retain media content.
- Disable network access for size measurement. If the original is not locally available, measurement returns an explicit unavailable outcome, contributes no Space Saving Opportunity, and creates no iCloud download request.
- The view must distinguish classified resources, measured candidates, unavailable-size candidates, and scan/measurement progress. It must not claim a full-library result under limited authorization or a storage-saving total that includes unknown sizes.
- Archive state remains service-owned. This feature supplies no ArchiveRecord and therefore can produce archive recommendations only; cleanup remains blocked until a future Archive Completion workflow exists.

## Testing Decisions

- The primary deterministic seam is the existing GovernanceEngine. Tests must continue to verify externally visible governance behavior from normalized inventory inputs, not PhotoKit implementation details. Existing cold-resource, protected-resource, policy, recommendation, batch, workflow, and record-shape tests are the prior art.
- Extend domain tests to verify that unmeasured size cannot contribute to Space Saving Opportunity or large-video prioritization, while it does not prevent valid metadata-only Governance Classification.
- Test the Media Access Adapter through its observable normalized-inventory and measurement-outcome contract using controlled asset facts and local-resource results. Verify shallow Content Hint mapping, favorite-to-Protected Resource mapping, hidden/unsupported exclusion, limited-coverage reporting, cancellation, and unavailable-local-original behavior. Do not unit-test private Photos framework calls.
- Add a device-level smoke checklist on a real iPhone for permission prompt, full access, limited access, denial recovery, visible scan count, responsive measurement progress, and confirmation that iCloud-only originals do not download during measurement.
- Good tests must assert user-observable coverage, classification, recommendation eligibility, and measured-space behavior. They must not depend on helper layout, threading primitives, or Photos object internals.

## Out of Scope

- Deep semantic classification of people, scenes, events, duplicates, blur, or emotional importance.
- Hidden-library inventory.
- iCloud download, cloud-first analysis, or uploading originals for classification.
- Remote Archive upload, integrity verification, Archive Completion, cleanup of Local Primary, Restore, or any automatic deletion.
- Background system tasks that continue after the app leaves the foreground.
- Multi-device inventory, Android client implementation, server-side media analysis, and user-authored governance rules.

## Further Notes

- This feature uses the established terms Media Space Governance, On-Device Analysis, Governance Classification, Cold Resource, Protected Resource, Governance Recommendation, Library Access Coverage, Local Primary, and Space Saving Opportunity.
- The measured-size rule preserves the meaning of Space Saving Opportunity: it is a locally measured reclaimable amount, not a theoretical library total.
- Measuring all original components needed for a resource remains compatible with ADR 0001: a future Remote Archive must preserve an Original Archive Copy, not a derivative-only representation.
- No ADR is proposed: the decisions are localized to the iOS media-access boundary and remain reversible before archive execution is introduced.
- Migrated from GitHub Issue #1 when this repository moved spec tracking to local Markdown. The remote issue is retained unchanged as historical context.

# UX Completeness Checklist: Post Bookmarks

**Purpose**: Validate requirements quality for UX interaction states, empty states, and authorization rules
**Created**: 2026-04-07
**Feature**: [spec.md](../spec.md)
**Focus**: All interaction states (loading, error, success, disabled, transitions), empty states, authorization (binary logged-in/not)
**Depth**: Standard | **Audience**: Reviewer

## Loading States

- [ ] CHK001 - Are loading indicator requirements defined for the bookmarks screen while data is being fetched? [Gap — SC-002 specifies timing but no visual loading state]
- [ ] CHK002 - Are loading state requirements defined for the batch bookmark status check when a page of posts loads? [Gap — no mention in spec]
- [ ] CHK003 - Are loading state requirements specified for the "load more" trigger during infinite scroll pagination? [Gap — FR-003 specifies pagination but no loading indicator for subsequent pages]
- [ ] CHK004 - Is the initial load vs. pagination load visually distinguished in requirements? [Completeness, Gap]

## Error States

- [ ] CHK005 - Is the error presentation format specified for optimistic revert failures (snackbar, inline banner, dialog)? [Clarity — FR-007 says "reverts with an error message" but format undefined]
- [ ] CHK006 - Are error state requirements defined for the bookmarks screen failing to load entirely? [Gap — no error state for list load failure]
- [ ] CHK007 - Are error message content requirements specified, or is only "error message" referenced generically? [Clarity, Spec §FR-007]
- [ ] CHK008 - Are retry/recovery requirements defined after a bookmark toggle fails and reverts? [Gap — spec defines revert but not recovery path]
- [ ] CHK009 - Are error requirements defined for pagination failure mid-scroll (partial data loaded, next page fails)? [Gap]

## Success & Feedback States

- [ ] CHK010 - Is "clear visual indicator" for bookmarked posts quantified with specific icon, color, or sizing? [Clarity, Spec §FR-005 — "clear" is subjective]
- [ ] CHK011 - Are visual feedback requirements specified for the moment a bookmark is toggled (animation, icon transition, haptic)? [Gap — FR-007 says "updates immediately" but no feedback specification]
- [ ] CHK012 - Is the bookmarked vs. unbookmarked icon/state visually defined or referenced to a design spec? [Clarity, Spec §FR-005]
- [ ] CHK013 - Are success confirmation requirements specified beyond the icon state change (e.g., brief toast, no toast)? [Gap]

## Disabled & In-Progress States

- [ ] CHK014 - Are interaction requirements defined for the bookmark icon during the server confirmation window (tappable, disabled, debounced)? [Gap — rapid-tap edge case mentions "final intended state" but no intermediate UI state]
- [ ] CHK015 - Is the debounce/throttle behavior for rapid tapping quantified with a specific time window? [Clarity, Spec §Edge Cases — "processes only the final intended state" lacks timing]

## Transition & Animation States

- [ ] CHK016 - Are requirements defined for the visual transition when a post is removed from the bookmarks list (fade, slide, instant removal)? [Gap — User Story 3 §AS-2 says "removed immediately" but no transition specified]
- [ ] CHK017 - Are requirements defined for the transition from loaded list to empty state when the last bookmark is removed? [Gap — User Story 3 §AS-3 mentions empty state shown but no transition]

## Empty States

- [ ] CHK018 - Is the empty state content specified beyond "a message indicating they have no saved posts" (illustration, call-to-action, suggested posts)? [Clarity, Spec §FR-006 — content is vague]
- [ ] CHK019 - Are requirements defined for whether the empty state includes a call-to-action (e.g., "Browse posts" button)? [Gap]
- [ ] CHK020 - Is the empty state requirement consistent between initial empty (never bookmarked) and cleared empty (all removed in session)? [Consistency, Spec §FR-006 vs. User Story 3 §AS-3]
- [ ] CHK021 - Are empty state requirements defined for when pagination returns zero additional results (end of list indicator)? [Gap — FR-003 defines infinite scroll but no end-of-list state]

## Authorization Rules

- [ ] CHK022 - Is the bookmark icon visibility defined for unauthenticated users (visible but triggers login, or hidden entirely)? [Gap — FR-008 says "directed to log in" but icon visibility unspecified]
- [ ] CHK023 - Is "directed to log in" specified with a concrete interaction (redirect to login screen, modal overlay, bottom sheet)? [Clarity, Spec §FR-008 — mechanism undefined]
- [ ] CHK024 - Are requirements defined for post-login bookmark completion (does the intended bookmark action auto-complete after successful login, or must the user re-tap)? [Gap — User Story 1 §AS-3 says "prompted to log in before the action is completed" but post-login flow unclear]
- [ ] CHK025 - Are requirements defined for the bookmarks screen navigation entry point visibility for unauthenticated users (visible but guarded, or hidden)? [Gap — FR-003 says "accessible from app navigation" but auth guard behavior unspecified]
- [ ] CHK026 - Is the authorization check point defined (checked at icon tap time, at screen entry, or both)? [Clarity, Gap]

## Cross-Screen Consistency

- [ ] CHK027 - Are bookmark icon placement and interaction requirements consistent across posts list, post detail, and bookmarks screen? [Consistency — three surfaces defined but visual consistency not specified]
- [ ] CHK028 - Are requirements defined for bookmark state synchronization when the same post appears on multiple screens simultaneously? [Gap — if user unbookmarks from bookmarks screen, is the post list icon also updated?]

## Notes

- Check items off as completed: `[x]`
- Items marked [Gap] indicate missing requirements that should be added to the spec
- Items marked [Clarity] indicate existing requirements that need more specificity
- Items marked [Consistency] indicate potential misalignment between spec sections

> Records the design of DMUnLoader 1.0. The code is the reference: where this document and the code differ, the code is right.

# Test Cases for "DMLoadingView"

## 1. General Information
- **Module**: DMLoadingView
- **Type of Tests**: Functional Tests, Snapshot Testing, and Unit Inspection.
- **Status**: ? / 🚧 / ❌ / ✅

---

## 2. Test Scenarios

### Scenario 1: ✅ Verify Empty State (`.none`)
- **Description**: Check if the `DMLoadingView` correctly displays the empty state.
- **Steps**:
  - [✅] Initialize the `DMLoadingView` with `loadableState = .none`.
  - [✅] Use snapshot testing to verify that no overlay or background is visible.
  - [✅] Inspect the view hierarchy to ensure the tag `0001` is assigned to the empty view.
- **Expected Result**:
  - The view displays an empty state.
  - No overlay or background is visible.
  - The tag `0001` is assigned to the empty view.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 2: ✅ Verify Loading State (`.loading`)
- **Description**: Check if the `DMLoadingView` correctly displays the loading state.
- **Steps**:
  - [✅] Initialize the `DMLoadingView` with `loadableState = .loading`.
  - [✅] Use snapshot testing to verify the appearance of the loading view.
  - [✅] Inspect the view hierarchy to ensure the tag `0203` is assigned to the loading view.
  - [✅] Verify that the overlay animates smoothly into view.
- **Expected Result**:
  - The loading view is displayed with a semi-transparent overlay.
  - The tag `0203` is assigned to the loading view.
  - The overlay animates smoothly.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 3: ✅ Verify Failure State (`.failure`)
- **Description**: Check if the `DMLoadingView` correctly displays the failure state.
- **Steps**:
  - [✅] Initialize the `DMLoadingView` with `loadableState = .failure`.
  - [✅] Use snapshot testing to verify the appearance of the failure view.
  - [✅] Inspect the view hierarchy to ensure the tag `0304` is assigned to the failure view.
  - [✅] Verify that the overlay animates smoothly into view.
- **Expected Result**:
  - The failure view is displayed with a semi-transparent overlay.
  - The tag `0304` is assigned to the failure view.
  - The overlay animates smoothly.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 4: ✅ Verify Success State (`.success`)
- **Description**: Check if the `DMLoadingView` correctly displays the success state.
- **Steps**:
  - [✅] Initialize the `DMLoadingView` with `loadableState = .success`.
  - [✅] Use snapshot testing to verify the appearance of the success view.
  - [✅] Inspect the view hierarchy to ensure the tag `0405` is assigned to the success view.
  - [✅] Verify that the overlay animates smoothly into view.
- **Expected Result**:
  - The success view is displayed with a semi-transparent overlay.
  - The tag `0405` is assigned to the success view.
  - The overlay animates smoothly.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 5: ✅ Verify Tap Gesture Behavior
- **Description**: Check if the tap gesture behaves correctly.
- **Steps**:
  - [✅] Tap on the overlay when the state is `.success`.
  - [✅] Verify that the view transitions back to `.none`.
  - [✅] Tap on the overlay when the state is `.loading`.
  - [✅] Verify that the tap has no effect.
  - [✅] Inspect the view hierarchy to ensure the tag `0515` is assigned to the tap gesture view.
- **Expected Result**:
  - Tapping dismisses the view in `.success` and `.failure` states.
  - Tapping has no effect in `.loading` state.
  - The tag `0515` is assigned to the tap gesture view.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 6: Verify Auto-Hide Behavior
- **Description**: Check if the auto-hide behavior works as expected.
- **Steps**:
  - [✅] Configure the `settings.autoHideDelay` to `0.05` seconds.
  - [✅] Initialize the `DMLoadingView` with `loadableState = .success`.
  - [✅] Wait for `0.06` seconds and verify that the view transitions back to `.none`.
  - [✅] Repeat the test for the `.failure` and `.none` states.
- **Expected Result**:
  - The view automatically transitions back to `.none` after the specified delay.
- **Status**: ? / 🚧 / ❌ / ✅
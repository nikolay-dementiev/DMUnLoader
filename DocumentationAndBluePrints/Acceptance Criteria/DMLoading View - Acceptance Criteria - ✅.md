> Records the design of DMUnLoader 1.0. The code is the reference: where this document and the code differ, the code is right.

# Acceptance Criteria for "DMLoadingView"

## 1. General Information
- **Module**: DMLoadingView
- **Description**: A custom SwiftUI view that dynamically displays loading, failure, success, or empty states based on the `loadableState` of a `loadingManager`.
- **Purpose**: To provide a consistent and visually appealing way to manage loading states in the user interface.

---

## 2. Acceptance Criteria

### 1. Empty State (`.none`)
- **Scenario**: The `DMLoadingView` is in the `.none` state.
- **Criteria**:
  - The view should display an empty state (`EmptyView`).
  - No overlay or background should be visible.
  - The tag `0001` should be assigned to the empty view.

---

### 2. Loading State (`.loading`)
- **Scenario**: The `DMLoadingView` is in the `.loading` state.
- **Criteria**:
  - A semi-transparent overlay with a loading view should be displayed.
  - The loading view should be provided by the `provider.getLoadingView()` method.
  - The overlay should have a gray background with an opacity of 0.8 when fully animated.
  - The tag `0203` should be assigned to the loading view.
  - The animation should smoothly transition the overlay into view.

---

### 3. Failure State (`.failure`)
- **Scenario**: The `DMLoadingView` is in the `.failure` state.
- **Criteria**:
  - A semi-transparent overlay with a failure view should be displayed.
  - The failure view should include:
    - An error message describing the failure.
    - An optional retry button if `onRetry` is provided.
    - A close button to dismiss the view.
  - The failure view should be provided by the `provider.getErrorView()` method.
  - The tag `0304` should be assigned to the failure view.
  - The overlay should have a gray background with an opacity of 0.8 when fully animated.

---

### 4. Success State (`.success`)
- **Scenario**: The `DMLoadingView` is in the `.success` state.
- **Criteria**:
  - A semi-transparent overlay with a success view should be displayed.
  - The success view should include:
    - A success message (e.g., "Data loaded successfully").
    - Optionally, a call-to-action button or additional details.
  - The success view should be provided by the `provider.getSuccessView()` method.
  - The tag `0405` should be assigned to the success view.
  - The overlay should have a gray background with an opacity of 0.8 when fully animated.

---

### 5. Tap Gesture Behavior
- **Scenario**: The user taps on the overlay.
- **Criteria**:
  - Tapping on the overlay should dismiss the view if the state is `.success`, `.failure`, or `.none`.
  - Tapping should have no effect if the state is `.loading`.
  - The tag `0515` should be assigned to the tap gesture view.

---

### 6. Animation and Appearance
- **Scenario**: The `DMLoadingView` transitions between states.
- **Criteria**:
  - The overlay should animate smoothly using a spring animation.
  - The animation duration should be approximately 0.2 seconds.
  - The overlay should scale up slightly during the animation for a polished effect.

---

### 7. Auto-Hide Behavior
- **Scenario**: The `DMLoadingView` is configured with an auto-hide delay.
- **Criteria**:
  - If the `settings.autoHideDelay` is set (e.g., 10 seconds), the view should automatically transition back to the `.none` state after the specified delay.
  - This behavior should apply to both `.success` and `.failure` states.
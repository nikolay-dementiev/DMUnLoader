# Acceptance Criteria: "Loading View (`DMProgressView`)"

## 1. General Information
- **Module**: DMProgressView
- **Description**: A custom SwiftUI view that displays a progress indicator with optional text. It uses a settings provider (`DMLoadingViewSettings`) to configure its appearance.
- **Purpose**: Define the expected behavior of `DMProgressView` to ensure it meets functional and visual requirements.

---

## 2. Acceptance Criteria

### Criterion 1: Default Initialization
- **Description**: The `DMProgressView` should initialize correctly with default settings provided by `DMLoadingDefaultViewSettings`.
- **Requirements**:
  - The `settingsProvider` must be passed during initialization.
  - Default settings (`loadingTextProperties`, `progressIndicatorProperties`, `loadingContainerForegroundColor`, `frameGeometrySize`) must match their respective default implementations.
- **Expected Behavior**:
  - When initialized with default settings, the view displays a progress indicator and text `"Loading..."`.

---

### Criterion 2: Progress Indicator Behavior
- **Description**: The progress indicator should be styled according to the `progressIndicatorProperties` in the settings.
- **Requirements**:
  - The progress indicator size must match the `size` property in `progressIndicatorProperties`.
  - The tint color of the progress indicator must match the `tintColor` property.
- **Expected Behavior**:
  - The progress indicator is displayed with the correct size and tint color.

---

### Criterion 3: Loading Text Behavior
- **Description**: The loading text should be styled according to the `loadingTextProperties` in the settings.
- **Requirements**:
  - The text must match the `text` property in `loadingTextProperties`.
  - The alignment, foreground color, font, line limit, and padding must match the corresponding properties.
- **Expected Behavior**:
  - The text is displayed with the correct styling and alignment.

---

### Criterion 4: Container Appearance
- **Description**: The container view should have a foreground color matching the `loadingContainerForegroundColor` in the settings.
- **Requirements**:
  - The foreground color of the container must match the `loadingContainerForegroundColor` property.
- **Expected Behavior**:
  - The container view has the correct foreground color.

---

### Criterion 5: Geometry and Layout
- **Description**: The layout of the `DMProgressView` should adapt dynamically based on the `frameGeometrySize` in the settings.
- **Requirements**:
  - The minimum size of the view must be calculated based on `frameGeometrySize`.
  - The layout must ensure proper alignment and spacing between the text and progress indicator.
- **Expected Behavior**:
  - The view adapts dynamically to the provided geometry and constraints.

---

### Criterion 6: Snapshot Testing
- **Description**: The visual appearance of the `DMProgressView` should match the reference snapshot.
- **Requirements**:
  - Use a snapshot testing library (e.g., `SnapshotTesting` or `XCTest`) to capture the rendered view.
  - Compare the rendered view with a reference snapshot.
  - Update the reference snapshot only after verifying intentional UI changes.
- **Expected Behavior**:
  - The rendered view matches the reference snapshot.
  - If the test fails, investigate whether the changes are intentional before updating the snapshot.

---

## 3. Notes
- Ensure that all criteria are verified through unit tests, snapshot testing, and manual testing.
- Localization testing should cover at least two languages (e.g., English and Ukrainian) if your app supports localization.
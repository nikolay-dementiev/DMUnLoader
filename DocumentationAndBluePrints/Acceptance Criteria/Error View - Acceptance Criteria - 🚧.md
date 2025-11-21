# Acceptance Criteria: "Error View (`DMErrorView`)"

## 1. General Information
- **Module**: DMErrorView
- **Description**: A custom SwiftUI view that displays an error state with an image, error text, and optional action buttons (e.g., "Retry" and "Close"). It uses a settings provider (`DMErrorViewSettings`) to configure its appearance.
- **Purpose**: Define the expected behavior of `DMErrorView` to ensure it meets functional and visual requirements.

---

## 2. Acceptance Criteria

### Criterion 1: Default Initialization
- **Description**: The `DMErrorView` should initialize correctly with default settings provided by `DMErrorDefaultViewSettings`.
- **Requirements**:
  - The `settingsProvider`, `error`, `onRetry`, and `onClose` must be passed during initialization.
  - Default settings (`errorText`, `actionButtonCloseSettings`, `actionButtonRetrySettings`, `errorTextSettings`, `errorImageSettings`) must match their respective default implementations.
- **Expected Behavior**:
  - When initialized with default settings:
    - The error image is displayed as an exclamation mark triangle icon.
    - The error text is `"An error has occurred!"`.
    - The "Close" button is always present.
    - The "Retry" button is present only if `onRetry` is provided.

---

### Criterion 2: Error Image Behavior
- **Description**: The error image should be styled according to the `errorImageSettings` in the settings.
- **Requirements**:
  - The image must match the `image` property in `errorImageSettings`.
  - The foreground color of the image must match the `foregroundColor` property.
  - The size of the image frame must match the `frameSize` property.
- **Expected Behavior**:
  - The error image is displayed with the correct image, foreground color, and frame size.

---

### Criterion 3: Error Text Behavior
- **Description**: The error text should be styled according to the `errorTextSettings` in the settings.
- **Requirements**:
  - The text must match the `errorText` property in `settingsProvider` or the localized description of the `error`.
  - The alignment, foreground color, padding, and multiline text alignment must match the corresponding properties.
- **Expected Behavior**:
  - The error text is displayed with the correct styling and alignment.

---

### Criterion 4: Action Buttons Behavior
- **Description**: The "Close" and "Retry" buttons should be styled and behave according to their respective settings.
- **Requirements**:
  - The "Close" button must always be present and functional.
  - The "Retry" button must be present and functional only if `onRetry` is provided.
  - The button styles must match the `actionButtonCloseSettings` and `actionButtonRetrySettings`.
- **Expected Behavior**:
  - The buttons are displayed and styled correctly.
  - Clicking the "Close" button triggers the `onClose` action.
  - Clicking the "Retry" button triggers the `onRetry` action.

---

### Criterion 5: Snapshot Testing
- **Description**: The visual appearance of the `DMErrorView` should match the reference snapshot.
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

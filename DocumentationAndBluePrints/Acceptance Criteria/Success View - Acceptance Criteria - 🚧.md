# Acceptance Criteria: "Success View (`DMSuccessView`)"

## 1. General Information
- **Module**: DMSuccessView
- **Description**: A custom SwiftUI view that displays a success state with an image and optional text. It uses a settings provider (`DMSuccessViewSettings`) to configure its appearance.
- **Purpose**: Define the expected behavior of `DMSuccessView` to ensure it meets functional and visual requirements.

---

## 2. Acceptance Criteria

### Criterion 1: Default Initialization
- **Description**: The `DMSuccessView` should initialize correctly with default settings provided by `DMSuccessDefaultViewSettings`.
- **Requirements**:
  - The `settingsProvider` and `assosiatedObject` must be passed during initialization.
  - Default settings (`successImageProperties`, `successTextProperties`) must match their respective default implementations.
- **Expected Behavior**:
  - When initialized with default settings:
    - The success image is displayed as a checkmark circle icon.
    - The success text is `"Success!"`.
    - The image and text are styled according to the default settings.

---

### Criterion 2: Success Image Behavior
- **Description**: The success image should be styled according to the `successImageProperties` in the settings.
- **Requirements**:
  - The image must match the `image` property in `successImageProperties`.
  - The foreground color of the image must match the `foregroundColor` property.
  - The size of the image frame must match the `frame` property.
- **Expected Behavior**:
  - The success image is displayed with the correct image, foreground color, and frame size.

---

### Criterion 3: Success Text Behavior
- **Description**: The success text should be styled according to the `successTextProperties` in the settings.
- **Requirements**:
  - The text must match the `text` property in `successTextProperties` or the `description` of the `assosiatedObject`.
  - The foreground color of the text must match the `foregroundColor` property.
- **Expected Behavior**:
  - The success text is displayed with the correct styling and alignment.

---

### Criterion 4: Layout and Alignment
- **Description**: The layout of the `DMSuccessView` should ensure proper alignment and spacing between the image and text.
- **Requirements**:
  - The image and text must be vertically aligned.
  - The spacing between the image and text must be consistent.
- **Expected Behavior**:
  - The layout ensures proper alignment and spacing between the image and text.

---

### Criterion 5: Snapshot Testing
- **Description**: The visual appearance of the `DMSuccessView` should match the reference snapshot.
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

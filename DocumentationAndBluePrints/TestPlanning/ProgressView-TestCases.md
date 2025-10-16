# Test Cases: "DMProgressView"

## 1. General Information
- **Module**: DMProgressView
- **Description**: A custom SwiftUI view that displays a progress indicator with optional text. It uses settings provided by `DMLoadingViewSettings` to configure its appearance.
- **Type of Tests**: Functional Tests (BDD), Snapshot Testing, and Unit Inspection.
- **Status**: ? / 🚧 / ❌ / ✅

---

## 1.1 The Mockup design

![](../Assets/Loading-on-empty-screen.png)

## 2. Test Scenarios

### Scenario 1: 🚧 Verify Default Initialization
- **Description**: Check if the `DMProgressView` is initialized correctly with default settings.
- **Steps**:
  - [✅] Use snapshot testing to verify the layout and appearance of `DMProgressView` with default settings.
  - [✅] Inspect the view to ensure it contains a `ProgressView`.
  - [✅] Verify that the ProgressView's default text is `"Loading..."`.
  - [✅] Verify that the default tint color of the progress indicator is `.white`.
- **Expected Result**:
  - The view is displayed with a circular progress indicator.
  - The default text `"Loading..."` is displayed.
  - The progress indicator has a `.white` tint color.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 2: 🚧 Verify Custom Settings
- **Description**: Check if the `DMProgressView` applies custom settings correctly.
- **Steps**:
  - [✅] Create a custom instance of `DMLoadingDefaultViewSettings` with:
    - Custom text: `"Processing.."`.
    - Custom font: `.title3`.
    - Custom text foreground color: `.orange`.
    - Custom progress indicator tint color: `.green`.
    - Custom frame size: `iPhone 13: portrait: CGSize(width: 390, height: 844)`.
  - [✅] Use snapshot testing to verify the layout and appearance with the custom settings.
  - [✅] Inspect the view to validate that the custom text, font, and foreground color are applied.
- **Expected Result**:
  - The custom text `"Processing..."` is displayed.
  - The font is `.title3`.
  - The text foreground color is `.orange`.
  - The progress indicator has a `.green` tint color.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 3: Verify Localization Support
- **Description**: Check if the `DMProgressView` supports localized text.
- **Steps**:
  - [?] Set the system language to a non-default locale (e.g., Ukrainian).
  - [?] Use snapshot testing to verify the layout and appearance with localized text (e.g., `"Завантаження..."`).
  - [?] Inspect the view to ensure the localized text is displayed.
- **Expected Result**:
  - The localized text `"Завантаження..."` is displayed.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 4: Verify Dynamic Layout Behavior
- **Description**: Check if the `DMProgressView` adapts dynamically to different geometry sizes.
- **Steps**:
  - [?] Use snapshot testing to verify the layout with:
    - Small frame size: `CGSize(width: 100, height: 100)`.
    - Large frame size: `CGSize(width: 600, height: 600)`.
  - [?] Inspect the view to ensure proper scaling of the progress indicator and text.
  - [?] Verify that the layout remains consistent and does not overflow.
- **Expected Result**:
  - The view scales correctly for small and large frame sizes.
  - The layout remains visually consistent.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 5: Verify Tags in View Hierarchy
- **Description**: Check if the correct tags are assigned to views within the `DMProgressView`.
- **Steps**:
  - [?] Initialize `DMProgressView` with default settings.
  - [?] Inspect the view hierarchy for the following tags:
    - `containerViewTag`: 2102.
    - `progressViewTag`: 2203.
    - `textTag`: 2204.
    - `vStackViewTag`: 2205.
  - [?] Verify that each view has the correct tag.
- **Expected Result**:
  - All views have the correct tags as defined in `DMProgressViewOwnSettings`.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 6: Verify Accessibility Features
- **Description**: Check if the `DMProgressView` supports accessibility features.
- **Steps**:
  - [?] Enable accessibility features (e.g., VoiceOver).
  - [?] Inspect the view to verify that:
    - The progress indicator is accessible.
    - The text has appropriate accessibility labels.
  - [?] Optionally, use snapshot testing to capture accessibility-focused snapshots.
- **Expected Result**:
  - The progress indicator and text are accessible.
  - Accessibility labels are correctly set.
- **Status**: ? / 🚧 / ❌ / ✅

---

## 3. Test Data
| Method               | Input Data                          | Expected Output                     |
|---------------------|--------------------------------------|------------------------------------------|
| Default Initialization | None                                | `DMProgressView` with default settings (`"Loading..."`, `.white` tint, etc.) |
| Custom Settings     | Custom text: `"Processing..."`, Font: `.headline`, Tint: `.green`, Frame: `CGSize(width: 400, height: 400)` | `DMProgressView` with custom settings |
| Localization         | System language: Ukrainian          | Localized text `"Завантаження..."`       |
| Dynamic Layout       | Small frame: `CGSize(width: 100, height: 100)` | Scaled layout without overflow          |
| Tags                 | None                                | Correct tags assigned to views          |

---

## 4. Notes
- Use snapshot testing to verify the visual appearance of the view across multiple configurations (e.g., different locales, frame sizes, and settings).
- Use unit inspection to programmatically validate view hierarchy, tags, and accessibility features.
- If the expected result does not match the actual result, create a bug report.
- Ensure that all tests are performed on multiple devices and screen sizes to verify responsiveness.
- Localization testing should cover at least two languages (e.g., English and Ukrainian).

---

### Status Icons:
- `?`: Default status (not verified).
- `🚧`: In progress.
- `❌`: Test failed / issue detected.
- `✅`: Test successfully completed.

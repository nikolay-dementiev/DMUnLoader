# Test Cases: "DMLoadingViewProvider"

## 1. ✅ General Information
- **Module**: DMLoadingViewProvider
- **Description**: A protocol defining the interface for providing views and settings related to loading, error, and success states. Conforming types must also conform to `ObservableObject` and `Hashable`.
- **Type of Tests**: Functional Tests (BDD), Unit Testing, Integration Testing.
- **Status**: ? / 🚧 / ❌ / ✅

Example: 
```Swift
protocol DMLoadingViewProvider: ObservableObject, Hashable {
    associatedtype LoadingViewType: View
    associatedtype ErrorViewType: View
    associatedtype SuccessViewType: View
    
    func getLoadingView() -> LoadingViewType
    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> ErrorViewType
    func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType

    var loadingManagerSettings: DMLoadingManagerSettings { get }
    var loadingViewSettings: DMLoadingViewSettings { get }
    var errorViewSettings: DMErrorViewSettings { get }
    var successViewSettings: DMSuccessViewSettings { get }
}
```
---

## 2. Test Scenarios

### Scenario 1: ✅ Verify Default Initialization
- **Description**: Check if the `DefaultDMLoadingViewProvider` is initialized correctly with default settings.
- **Steps**:
  - [✅] Create few new instances of `DefaultDMLoadingViewProvider`.
  - [✅] Verify that the `hash` is unique.
  - [✅] Verify that the default settings (`loadingManagerSettings`, `loadingViewSettings`, `errorViewSettings`, `successViewSettings`) match their respective default implementations.
- **Expected Result**:
  - The `hash` is unique.
  - Default settings are applied correctly.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 2: 🚧 Verify Loading View
- **Description**: Check if the `getLoadingView` method returns a `DMProgressView` configured with the provided `loadingViewSettings`.

**[> test plan available here <](../TestPlanning/LoadingView-TestCases.md)**
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 3: ? Verify Error View
- **Description**: Check if the `getErrorView` method returns a `DMErrorView` configured with the provided `errorViewSettings`, `error`, `onRetry`, and `onClose`.
**[> test plan available here <](../TestPlanning/Error%20View%20-%20TestCases.md)**
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 4: ? Verify Success View
- **Description**: Check if the `getSuccessView` method returns a `DMSuccessView` configured with the provided `successViewSettings` and `object`.
- **Steps**:
  - [?] Call the `getSuccessView` method with a sample success message (`"Operation Completed!"`).
  - [?] Verify that the returned view is a `DMSuccessView`.
  - [?] Verify that the checkmark circle icon is displayed.
  - [?] Verify that the success message matches the provided object.
- **Expected Result**:
  - The returned view is a `DMSuccessView`.
  - The icon and success message match the provided settings and object.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 5: ? Verify Hashable Conformance
- **Description**: Ensure that two instances of `DefaultDMLoadingViewProvider` are distinguishable by their `id`.
- **Steps**:
  - [?] Create two instances of `DefaultDMLoadingViewProvider`.
  - [?] Compare their `id` values using the `==` operator.
  - [?] Verify that the `hash(into:)` method combines the `id` into the hasher.
- **Expected Result**:
  - Two instances with different `id` values are not equal.
  - Two instances with the same `id` values are equal.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 6: ? Verify Customization via Settings
- **Description**: Check if the provider allows customization of views through settings.
- **Steps**:
  - [?] Create custom settings for `loadingViewSettings`, `errorViewSettings`, and `successViewSettings`.
  - [?] Call the `getLoadingView`, `getErrorView`, and `getSuccessView` methods with the custom settings.
  - [?] Verify that the views reflect the custom settings.
- **Expected Result**:
  - Views reflect the custom settings provided.
- **Status**: ? / 🚧 / ❌ / ✅

---

## 3. Test Data
| Method               | Input Data                          | Expected Output                     |
|---------------------|--------------------------------------|------------------------------------------|
| Default Initialization | None                                | `DefaultDMLoadingViewProvider` with unique `id` and default settings |
| Get Loading View    | None                                | `DMProgressView` with default settings |
| Get Error View      | Error: `NSError(domain: "Test", code: 404)`, `onRetry`, `onClose` | `DMErrorView` with error message, icon, and buttons |
| Get Success View    | Success message: `"Operation Completed!"` | `DMSuccessView` with checkmark icon and success message |

---

## 4. Notes
- Use snapshot testing (if applicable) to verify the visual appearance of views managed by `DMLoadingViewProvider`.
- Use unit inspection to programmatically validate view configurations and settings.
- Ensure that all tests are performed on multiple devices and screen sizes to verify responsiveness.
- Localization testing should cover at least two languages (e.g., English and Ukrainian) if your app supports localization.

---
## Examples

```Swift
// Custom Loading View Provider
final class CustomDMLoadingViewProvider: DMLoadingViewProvider {
    public var id: UUID = UUID()
    
    // Custom Loading View Settings
    var loadingViewSettings: DMLoadingViewSettings {
        DMLoadingDefaultViewSettings(
            loadingTextProperties: LoadingTextProperties(text: "Please Wait..."),
            progressIndicatorProperties: ProgressIndicatorProperties(size: .small),
            loadingContainerForegroundColor: .blue,
            frameGeometrySize: CGSize(width: 400, height: 400)
        )
    }
    
    // Custom Error View Settings
    var errorViewSettings: DMErrorViewSettings {
        DMErrorDefaultViewSettings(
            errorText: "Custom Error Message",
            actionButtonCloseSettings: ActionButtonSettings(text: "Dismiss"),
            actionButtonRetrySettings: ActionButtonSettings(text: "Try Again"),
            errorTextSettings: ErrorTextSettings(foregroundColor: .black),
            errorImageSettings: ErrorImageSettings(image: Image(systemName: "xmark.octagon"), foregroundColor: .orange)
        )
    }
    
    // Custom Success View Settings
    var successViewSettings: DMSuccessViewSettings {
        DMSuccessDefaultViewSettings(
            successImageProperties: SuccessImageProperties(image: Image(systemName: "star.fill"), foregroundColor: .yellow),
            successTextProperties: SuccessTextProperties(text: "Custom Success!", foregroundColor: .black)
        )
    }
    
    // Implement Protocol Methods
    @MainActor
    func getLoadingView() -> some View {
        DMProgressView(settings: loadingViewSettings)
    }
    
    @MainActor
    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> some View {
        DMErrorView(settings: errorViewSettings, error: error, onRetry: onRetry, onClose: onClose)
    }
    
    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
        DMSuccessView(settings: successViewSettings, assosiatedObject: object)
    }
}
```

---

### Status Icons:
- `?`: Default status (not verified).
- `🚧`: In progress.
- `❌`: Test failed / issue detected.
- `✅`: Test successfully completed.
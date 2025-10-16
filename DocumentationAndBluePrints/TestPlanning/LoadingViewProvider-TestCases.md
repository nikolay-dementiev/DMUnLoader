# Test Cases: "DMLoadingViewProvider"

## 1. General Information
- **Module**: DMLoadingViewProvider
- **Description**: Protocol and implementation for providing views and settings related to loading, error, and success states.
- **Type of Tests**: Functional Tests (BDD)
- **Status**: In Progress / ✅ Completed

---

## 2. Test Scenarios

### Scenario 1: Verify Loading State
- **Description**: Check if the loading state view is generated correctly.
- **Steps**:
  - [✅] Create an instance of `DefaultDMLoadingViewProvider`.
  - [✅] Call the `getLoadingView()` method.
  - [✅] Verify that the returned view is of type `DMProgressView`.
  - [✅] Verify that the correct settings (`loadingViewSettings`) are used.
- **Expected Result**:
  - [✅] A view of type `DMProgressView` is returned.
  - [✅] The view settings match `DMLoadingDefaultViewSettings`.
- **Status**: ❌ / ✅

---

### Scenario 2: Verify Error State
- **Description**: Check if the error state view is generated correctly.
- **Steps**:
  - [✅] Create an instance of `DefaultDMLoadingViewProvider`.
  - [✅] Call the `getErrorView(error:onRetry:onClose:)` method with test data.
  - [✅] Verify that the returned view is of type `DMErrorView`.
  - [✅] Verify that the correct error message is displayed.
  - [✅] Verify that the `onRetry` and `onClose` actions ids' are as expected.
- **Expected Result**:
  - [✅] A view of type `DMErrorView` is returned.
  - [✅] The view settings match `DMErrorDefaultViewSettings`.
- **Status**: ❌ / ✅

---

### Scenario 3: Verify Success State
- **Description**: Check if the success state view is generated correctly.
- **Steps**:
  - [✅] Create an instance of `DefaultDMLoadingViewProvider`.
  - [✅] Call the `getSuccessView(object:)` method with a test object.
  - [✅] Verify that the returned view is of type `DMSuccessView`.
  - [✅] Verify that the correct success message is displayed.
  - [✅] Verify that the correct settings (`successViewSettings`) are used.
- **Expected Result**:
  - [✅] A view of type `DMSuccessView` is returned.
  - [✅] The success message is displayed correctly.
  - [✅] The view settings match `DMSuccessDefaultViewSettings`.
- **Status**: ❌ / ✅

---

### Scenario 4: Verify Unique ID
- **Description**: Check if each instance of `DefaultDMLoadingViewProvider` has a unique ID.
- **Steps**:
  - [✅] Create two instances of `DefaultDMLoadingViewProvider`.
  - [✅] Compare their IDs.
- **Expected Result**:
  - [✅] The IDs of the two instances do not match.
- **Status**: ❌ / ✅

---

### Scenario 5: Verify Default Settings
- **Description**: Check if default settings are provided correctly.
- **Steps**:
  - [✅] Create an instance of `DefaultDMLoadingViewProvider`.
  - [✅] Verify the values of `loadingManagerSettings`, `loadingViewSettings`, `errorViewSettings`, and `successViewSettings`.
- **Expected Result**:
  - [✅] All settings match their default types (`DMLoadingManagerConfiguration`, `DMLoadingDefaultViewSettings`, etc.).
- **Status**: ❌ / ✅

---

## 3. Test Data
| Method               | Input Data                          | Expected Output                     |
|---------------------|--------------------------------------|------------------------------------------|
| `getLoadingView()`  | None                                | `DMProgressView` with default settings |
| `getErrorView()`    | `NSError(domain: "Test", code: 404)` | `DMErrorView` with message "Test"       |
| `getSuccessView()`  | `"Operation Completed!"`            | `DMSuccessView` with message "Operation Completed!" |

---

## 4. Notes
- If the expected result does not match the actual result, create a bug report.

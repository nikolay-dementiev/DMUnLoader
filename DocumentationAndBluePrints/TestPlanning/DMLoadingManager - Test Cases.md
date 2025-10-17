# Test Cases: "DMLoadingManager"

## 1. General Information
- **Module**: DMLoadingManager
- **Description**: A `ViewModel` responsible for managing and handling loading states in a user interface. It supports states such as `.none`, `.loading`, `.success`, and `.failure`, and includes an inactivity timer for auto-hiding.
- **Type of Tests**: Functional Tests (BDD), Unit Testing, Snapshot Testing (optional).
- **Status**: ? / 🚧 / ❌ / ✅

---

## 2. Test Scenarios

### Scenario 1: ✅ Verify Default Initialization
- **Description**: Check if the `DMLoadingManager` is initialized correctly with default settings.
- **Steps**:
  - [✅] Create a new instance of `DMLoadingManager`.
  - [✅] Verify that new instance conforms to `DMLoadingManagerProtocol`
  - [✅] Verify that the initial `loadableState` is `.none`.
  - [✅] Verify that the `settings` are set to `DMLoadingManagerDefaultSettings`.
- **Expected Result**:
  - The `loadableState` is `.none`.
  - The `settings` match `DMLoadingManagerDefaultSettings`.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 2: 🚧 Verify Loading State
- **Description**: Check if the `DMLoadingManager` correctly transitions to the `.loading` state.
- **Steps**:
  - [ ] Call the `showLoading(provider:)` method with a mock `DMLoadingViewProvider`.
  - [ ] Verify that the `loadableState` is `.loading`.
  - [ ] Verify that the inactivity timer is stopped.
- **Expected Result**:
  - The `loadableState` is `.loading`.
  - The inactivity timer is stopped.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 3: 🚧 Verify Success State
- **Description**: Check if the `DMLoadingManager` correctly transitions to the `.success` state.
- **Steps**:
  - [ ] Call the `showSuccess(_:provider:)` method with a success message and a mock `DMLoadingViewProvider`.
  - [ ] Verify that the `loadableState` is `.success`.
  - [ ] Verify that the inactivity timer is started with the delay specified in `settings.autoHideDelay`.
  - [ ] Wait for the auto-hide delay and verify that the `loadableState` transitions back to `.none`.
- **Expected Result**:
  - The `loadableState` is `.success` immediately after the call.
  - The inactivity timer is started.
  - After the delay, the `loadableState` transitions to `.none`.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 4: 🚧 Verify Failure State
- **Description**: Check if the `DMLoadingManager` correctly transitions to the `.failure` state.
- **Steps**:
  - [ ] Call the `showFailure(_:provider:onRetry:)` method with an error and optional retry action.
  - [ ] Verify that the `loadableState` is `.failure`.
  - [ ] Verify that the inactivity timer is started with the delay specified in `settings.autoHideDelay`.
  - [ ] If `onRetry` is provided, verify that the retry action is callable.
  - [ ] Wait for the auto-hide delay and verify that the `loadableState` transitions back to `.none`.
- **Expected Result**:
  - The `loadableState` is `.failure` immediately after the call.
  - The inactivity timer is started.
  - The retry action is callable (if provided).
  - After the delay, the `loadableState` transitions to `.none`.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 5: 🚧 Verify Hide State
- **Description**: Check if the `DMLoadingManager` correctly transitions to the `.none` state when `hide()` is called.
- **Steps**:
  - [ ] Set the `loadableState` to `.loading`, `.success`, or `.failure`.
  - [ ] Call the `hide()` method.
  - [ ] Verify that the `loadableState` is `.none`.
  - [ ] Verify that the inactivity timer is stopped.
- **Expected Result**:
  - The `loadableState` is `.none`.
  - The inactivity timer is stopped.
- **Status**: ? / 🚧 / ❌ / ✅

---

### Scenario 6: 🚧 Verify Reactive Programming
- **Description**: Check if the `loadableStatePublisher` emits changes correctly.
- **Steps**:
  - [ ] Subscribe to the `loadableStatePublisher`.
  - [ ] Change the `loadableState` by calling methods like `showLoading`, `showSuccess`, `showFailure`, and `hide`.
  - [ ] Verify that the publisher emits the correct state changes.
- **Expected Result**:
  - The `loadableStatePublisher` emits the correct state changes in real-time.
- **Status**: ? / 🚧 / ❌ / ✅

---

## 3. Test Data
| Method               | Input Data                          | Expected Output                     |
|---------------------|--------------------------------------|------------------------------------------|
| Default Initialization | None                                | `DMLoadingManager` with `.none` state and default settings |
| Show Loading        | Mock `DMLoadingViewProvider`         | `.loading` state                       |
| Show Success        | Success message: `"Operation Completed"`, Mock `DMLoadingViewProvider` | `.success` state with auto-hide delay |
| Show Failure        | Error: `NSError(domain: "Test", code: 404)`, Mock `DMLoadingViewProvider` | `.failure` state with auto-hide delay |
| Hide                | None                                | `.none` state                         |

---

## 4. Notes
- Use snapshot testing (if applicable) to verify the visual appearance of views managed by `DMLoadingManager`.
- Use unit inspection to programmatically validate state transitions, timers, and reactive programming behavior.
- Ensure that all tests are performed on multiple devices and screen sizes to verify responsiveness.
- Localization testing should cover at least two languages (e.g., English and Ukrainian) if your app supports localization.

---

### Status Icons:
- `?`: Default status (not verified).
- `🚧`: In progress.
- `❌`: Test failed / issue detected.
- `✅`: Test successfully completed.
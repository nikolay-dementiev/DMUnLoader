# Acceptance Criteria: "DMLoadingManager"

## 1. General Information
- **Module**: DMLoadingManager
- **Description**: A `ViewModel` responsible for managing and handling loading states in a user interface. It supports states such as `.none`, `.loading`, `.success`, and `.failure`, and includes an inactivity timer for auto-hiding.
- **Purpose**: Define the expected behavior of the `DMLoadingManager` to ensure it meets functional requirements.

---

## 2. Acceptance Criteria

### Criterion 1: Default Initialization
- **Description**: The `DMLoadingManager` should initialize correctly with default settings.
- **Requirements**:
  - The initial state (`loadableState`) must be `.none`.
  - The default settings (`settings`) must match `DMLoadingManagerDefaultSettings`.
- **Expected Behavior**:
  - When a new instance is created, the `loadableState` is `.none`.
  - The `settings` are applied correctly from `DMLoadingManagerDefaultSettings`.

---

### Criterion 2: Loading State Transition
- **Description**: The `DMLoadingManager` should transition to the `.loading` state when `showLoading(provider:)` is called.
- **Requirements**:
  - The `loadableState` must change to `.loading`.
  - The inactivity timer must be stopped if it was running.
- **Expected Behavior**:
  - After calling `showLoading(provider:)`, the `loadableState` is `.loading`.
  - The inactivity timer is stopped.

---

### Criterion 3: Success State Transition
- **Description**: The `DMLoadingManager` should transition to the `.success` state when `showSuccess(_:provider:)` is called.
- **Requirements**:
  - The `loadableState` must change to `.success`.
  - The inactivity timer must start with the delay specified in `settings.autoHideDelay`.
  - After the delay, the `loadableState` must transition back to `.none`.
- **Expected Behavior**:
  - After calling `showSuccess(_:provider:)`, the `loadableState` is `.success`.
  - The inactivity timer starts with the correct delay.
  - After the delay, the `loadableState` transitions to `.none`.

---

### Criterion 4: Failure State Transition
- **Description**: The `DMLoadingManager` should transition to the `.failure` state when `showFailure(_:provider:onRetry:)` is called.
- **Requirements**:
  - The `loadableState` must change to `.failure`.
  - The inactivity timer must start with the delay specified in `settings.autoHideDelay`.
  - If `onRetry` is provided, the retry action must be callable.
  - After the delay, the `loadableState` must transition back to `.none`.
- **Expected Behavior**:
  - After calling `showFailure(_:provider:onRetry:)`, the `loadableState` is `.failure`.
  - The inactivity timer starts with the correct delay.
  - The retry action is callable if provided.
  - After the delay, the `loadableState` transitions to `.none`.

---

### Criterion 5: Hide State Transition
- **Description**: The `DMLoadingManager` should transition to the `.none` state when `hide()` is called.
- **Requirements**:
  - The `loadableState` must change to `.none`.
  - The inactivity timer must be stopped if it was running.
- **Expected Behavior**:
  - After calling `hide()`, the `loadableState` is `.none`.
  - The inactivity timer is stopped.

---

### Criterion 6: Reactive Programming
- **Description**: The `loadableStatePublisher` must emit changes in real-time.
- **Requirements**:
  - The `loadableStatePublisher` must emit the correct state when `loadableState` changes.
- **Expected Behavior**:
  - When the `loadableState` changes (e.g., `.loading`, `.success`, `.failure`, `.none`), the `loadableStatePublisher` emits the updated state.

---

### Criterion 7: Timer Management
- **Description**: The inactivity timer must behave correctly based on the current state.
- **Requirements**:
  - The timer must stop when transitioning to `.loading`.
  - The timer must start when transitioning to `.success` or `.failure`.
  - The timer must stop when transitioning to `.none`.
- **Expected Behavior**:
  - The timer behaves as expected for each state transition.

---

### Criterion 8: Localization Support (Optional)
- **Description**: The `DMLoadingManager` should support localized text for success and failure messages.
- **Requirements**:
  - The success and failure messages must adapt to the system's locale.
- **Expected Behavior**:
  - When the system language is changed, the success and failure messages display localized text.

---

## 3. Notes
- These acceptance criteria define the expected behavior of the `DMLoadingManager` and serve as a foundation for writing test cases.
- Ensure that all criteria are verified through unit tests, integration tests, and manual testing.
- Localization testing should cover at least two languages (e.g., English and Ukrainian) if your app supports localization.
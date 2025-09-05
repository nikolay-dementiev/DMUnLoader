# DMUnLoader **User Story**

## Manage Application States with DMUmLoader

As a developer,
I want to easily manage and display the current state of the application (e.g., `Idle`, `Loading`, `Error`, or `Success` screens),
so that users can understand what is happening in the app at any given moment, improving their overall experience.

## Acceptance Criteria

### 1. `Idle` State
1. When the app is not performing any operation, the `Idle` state should be activated.
2. In the `Idle` state, no screen should be displayed — the library should render a null view, ensuring that no visible content is shown to the user.

### 2. `Loading` State:
1. When the app is e.g. fetching data or performing an operation, the `Loading` Screen could replace the `Idle` (or any other currently displayed) Screen.
2. The Loading Screen must include:
- A spinner or progress indicator to inform the user that an operation is in progress.
- Optionally, a message such as "Loading..." to provide additional context.

### `Error` State:
1. If an error occurs during an operation, the client should be notified so it can use this library to display an `Error` Screen.
2. The `Error` Screen must include:
- A clear error message explaining what went wrong (e.g., "Failed to load data. Please check your internet connection.").
- An option to retry the operation. The user should be allowed to retry the operation 0+ times (i.e. configurable number of attempts) before showing the error again.

### `Success` State
1. After a successful operation, the `Success` Screen should be displayed.
The `Success` Screen may include the following optional elements:
- Image: An image that visually represents the result of the action (e.g., a checkmark icon or a custom illustration).
- Feedback Message: A textual description of the completed action (e.g., "Data loaded successfully").
- Call-to-Action (CTA): A button or instructions for the next steps (e.g., "Continue" or "Go to Dashboard").
3. If none of the optional elements (image, feedback message, or CTA) are provided by the developer:
- The library should notify the developer via the logging system with a message such as:
`"No content provided for Success Screen. Displaying default success image."`
- The Success Screen should display a default success image (e.g., a generic checkmark icon) to ensure the user still receives visual confirmation of success.

### Transition Back to `Idle`:
- After a short delay or user interaction, the app transitions back to the `Idle` state.

## Behavior Rules
1. Exclusive State Display:
- Only one state (Idle, Loading, Error, or Success) can be displayed at a time.
- Switching between states should be smooth and intuitive, ensuring a seamless user experience.
2. Customizability:
- Developers should be able to customize the appearance and content of each default state screen (e.g., colors, text, icons).
- Developers should have the option to provide their own implementation for any state screen, allowing them to completely replace the default implementation.
- If developers do not provide a custom implementation for a state screen, the **default implementation** must be used automatically.

## Example Scenario
#### Scenario: Fetching User Data

1.`Idle` State:
- When the user opens the app and no operation is in progress, the Idle state is activated.
- The library renders a `null` view, and **no visible content is displayed**.
2. `Loading` State:
- When the user requests their profile data, the `Loading` Screen is displayed with a spinner and the message "Loading...".
3. `Error` State:
- If the data fetch fails due to a network error, the `Error` Screen is displayed with the message "Failed to load data. Please check your internet connection."
- The user is given the option to retry the operation. After `3` failed attempts (configurable), the error message changes to "Unable to load data. Please try again later."
4. `Success` State:
- If the data fetch succeeds:
- - If the developer provides an image, feedback message, or CTA, the Success Screen displays these elements.
 - - If no content is provided, the library logs a message:
"No content provided for Success Screen. Displaying default success image."
The `Success` Screen then displays a **default** success image (e.g., a checkmark icon).
5. Transition Back to Idle:
- After a short delay or user interaction, the app transitions back to the `Idle` state.

#### Notes on Null View
- A `null` view is useful when the app does not require any initial content or when the UI is dynamically populated based on user actions or external data.
- In a `null` view, the screen remains visually empty or hidden until another state (e.g., Loading, Error, or Success) is triggered.
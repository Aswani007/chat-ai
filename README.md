<<<<<<< HEAD
# AI Chat Assistant - Flutter Application
Web Link - https://chat-4c7a3.web.app/
A modern, production-ready Flutter application that simulates an AI chat assistant with dynamic response types and polling behavior. The app supports both Android and Web platforms from a single codebase.

## Features

- **Dynamic Response Types**: The app handles three different response types based on user intent:
  - **Text Responses**: Default response for normal chat messages. Returns immediate text replies from the assistant.
  - **Image Generation**: Triggered when user requests an image (keywords: "image", "generate image", "create image", "draw", "picture", "photo", etc.). Creates a job with polling and progress updates.
  - **Data Processing**: Triggered when user requests data processing (keywords: "process data", "data processing", "analyze data", "process", "analyze", etc.). Creates a job with progress indicators and formatted JSON results.

- **Robust Polling System**: 
  - Automatic polling every 2-3 seconds for long-running jobs
  - Progress tracking with visual indicators
  - Automatic cleanup on completion or failure
  - Graceful error handling for network issues and timeouts

- **Clean, Responsive UI**:
  - Modern Material Design 3 interface
  - Responsive layout for both mobile and web
  - Message bubbles with timestamps
  - Loading indicators and progress bars
  - Error banners with dismiss functionality

- **State Management**: 
  - GetX for reactive state management
  - Optimistic UI updates
  - Proper cleanup of resources

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── controllers/
│   └── chat_controller.dart # GetX controller with state management and polling logic
├── models/
│   ├── api_response.dart    # API response model
│   ├── chat_message.dart    # Chat message model
│   ├── job_status.dart      # Job status enum
│   ├── poll_response.dart   # Polling response model
│   └── response_type.dart   # Response type enum
├── services/
│   └── mock_backend_service.dart # Mock backend service simulating API endpoints
├── views/
│   └── chat_screen.dart     # Main chat screen
└── widgets/
    ├── chat_input.dart      # Message input widget
    └── message_bubble.dart  # Message bubble widget
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Chrome (for web development)

### Installation

1. **Clone or navigate to the project directory:**
   ```bash
   cd ai_chat_assistant
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Enable web support (if not already enabled):**
   ```bash
   flutter config --enable-web
   ```

### Running the Application

#### For Android:
```bash
flutter run
```
Or select an Android device/emulator from your IDE.

#### For Web:
```bash
flutter run -d chrome
```
Or select Chrome from your IDE's device selector.

### Building for Production

#### Android APK:
```bash
flutter build apk --release
```

#### Web:
```bash
flutter build web --release
```

## Design Decisions

### State Management: GetX
- **Why GetX?**: GetX provides a simple, powerful solution for state management with minimal boilerplate. It offers reactive programming, dependency injection, and route management in a single package.
- **Benefits**: 
  - Automatic memory management
  - Built-in reactivity with `.obs` and `Obx()`
  - Easy dependency injection with `Get.put()` and `Get.find()`

### Mock Backend Service
- **Why a local mock service?**: The application uses a mock backend service that simulates real API behavior without requiring external dependencies.
- **Features**:
  - **Intent Detection**: Analyzes user messages to determine response type:
    - Normal chat → Text response
    - Image-related keywords → Image generation job
    - Data processing keywords → Data processing job
  - Simulated network delays
  - Job state management with progress tracking
  - Random failure simulation (5% chance) for testing error handling

### Polling Strategy
- **Polling Interval**: Configurable via `pollingIntervalSeconds` in `ChatController` (default: 2 seconds)
- **Polling Behavior**: 
  - Polls each job every `pollingIntervalSeconds` until completion or failure
  - Automatically stops polling when jobs complete or fail
  - Handles network errors gracefully with try-catch blocks
  - Cleans up resources properly (timers cancelled, maps cleared)
- **State Tracking**: Active jobs are tracked in `activePollingJobs` map for proper cleanup
- **Error Recovery**: Network errors are caught and displayed to the user, with automatic cleanup

### Responsive Design
- **Breakpoint**: 600px width for web/mobile distinction
- **Web Layout**: Constrained to 800px max width for better readability
- **Mobile Layout**: Full-width with appropriate padding
- **Image Sizing**: Responsive image dimensions (400x300 on web, 300x200 on mobile)

## Architecture

### Models
- **ChatMessage**: Represents a single message in the chat, with support for different response types, job statuses, and metadata
- **ApiResponse**: Represents the initial response from the `/chat` endpoint
- **PollResponse**: Represents polling updates from the `/poll/{jobId}` endpoint
- **ResponseType**: Enum for the three response types (text, imageGeneration, dataProcessing)
- **JobStatus**: Enum for job states (pending, processing, completed, failed)

### Services
- **MockBackendService**: Singleton service that simulates:
  - `POST /chat`: Returns random response types with optional job IDs
  - `GET /poll/{jobId}`: Returns job status updates with progress

### Controllers
- **ChatController**: Manages:
  - Message list state
  - Loading states
  - Error states
  - Active polling jobs
  - Waiting messages (messages awaiting job completion)

### UI Components
- **ChatScreen**: Main screen with message list, error banner, and input
- **MessageBubble**: Displays messages with support for:
  - Text content
  - Image display (with loading states)
  - JSON data display (formatted and selectable)
  - Progress indicators
  - Error states
- **ChatInput**: Text input with send button and loading state

## Known Limitations

1. **No Persistence**: Messages are not persisted across app restarts. All state is lost when the app is closed.

2. **Mock Backend**: The backend is completely mocked. To integrate with a real API, replace `MockBackendService` with actual HTTP calls.

3. **Image URLs**: Generated images use placeholder URLs from `picsum.photos`. In production, these would come from your actual image generation service.

4. **No Authentication**: The app doesn't include user authentication or session management.

5. **Limited Error Recovery**: While errors are handled gracefully, there's no automatic retry mechanism for failed requests.

6. **Polling State Restoration**: Active polling jobs are not restored on app restart. If the app is closed during a job, the job state is lost.

## Future Enhancements

- [ ] Add local storage to persist messages and restore polling state
- [ ] Implement retry logic for failed requests
- [ ] Add support for file uploads
- [ ] Implement user authentication
- [ ] Add dark mode support
- [ ] Add message search functionality
- [ ] Implement message reactions/feedback
- [ ] Add support for markdown rendering in messages
- [ ] Implement message editing and deletion

## Dependencies

- **get**: ^4.6.6 - State management and dependency injection
- **http**: ^1.1.0 - HTTP client (currently unused, available for real API integration)
- **flutter**: SDK - Flutter framework
- **cupertino_icons**: ^1.0.6 - iOS-style icons

## Testing

To run tests:
```bash
flutter test
```

## Contributing

This is a demonstration project. For production use, consider:
- Adding comprehensive unit and widget tests
- Implementing proper error logging
- Adding analytics
- Setting up CI/CD pipelines
- Adding accessibility features
- Implementing proper security measures

## License

This project is provided as-is for demonstration purposes.

=======
# chat-ai
Chat assistant
>>>>>>> b9b7950a47d1fbbf705f71ecd2344a60531a4fc4

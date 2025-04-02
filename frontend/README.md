# Personal Expense Tracker - Flutter Frontend

This is the Flutter frontend for the Personal Expense Tracker application.

## Features

- User authentication (login/register)
- Add, edit, and delete expenses
- Categorize expenses
- View monthly expense summaries
- Profile management

## Technologies Used

- Flutter 3.24
- Provider for state management
- HTTP package for API communication
- Flutter Secure Storage for token storage
- Intl package for date and number formatting

## Project Structure

- `lib/models` - Data models (User, Expense)
- `lib/screens` - UI screens
- `lib/services` - API services for authentication and expense management
- `lib/widgets` - Reusable UI components
- `lib/providers` - State management
- `lib/utils` - Utility classes and helper functions

## Setup Instructions

1. Ensure you have Flutter installed on your machine
2. Clone the repository
3. Install dependencies:
```
flutter pub get
```

4. Update the API URL in `lib/services/api_constants.dart` if needed:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';  // For Android emulator
// For physical device, use the actual IP address of your backend
// static const String baseUrl = 'http://192.168.1.x:3000/api';
```

5. Run the app:
```
flutter run
```

## Backend

This frontend requires the Node.js/Express backend to be running. See the backend README for setup instructions.

## Screenshots

[Add screenshots here when available]

# Mini TaskHub

A Flutter application for personal task tracking with user authentication, task management, and Supabase integration.

## Features

- User authentication (signup, login, logout) using Supabase
- Task management (create, delete, mark as completed)
- Responsive UI
- State management using Provider
- Clean architecture and folder structure

## Screenshots

[Include screenshots of your app here]

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- An IDE (VS Code, Android Studio, etc.)
- Supabase account

### Installation

1. Clone this repository:
   \`\`\`
   git clone https://github.com/yourusername/mini-taskhub.git
   cd mini-taskhub
   \`\`\`

2. Install dependencies:
   \`\`\`
   flutter pub get
   \`\`\`

3. Create a `.env` file in the root directory with your Supabase credentials:
   \`\`\`
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   \`\`\`

4. Run the app:
   \`\`\`
   flutter run
   \`\`\`

### Supabase Setup

1. Create a new Supabase project
2. Set up authentication (Email/Password provider)
3. Create a 'tasks' table with the following schema:

\`\`\`sql
CREATE TABLE tasks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create a policy to allow users to only access their own tasks
CREATE POLICY "Users can only access their own tasks"
  ON tasks
  FOR ALL
  USING (auth.uid() = user_id);

-- Enable Row Level Security
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
\`\`\`

## Hot Reload vs. Hot Restart

- **Hot Reload**: Allows you to quickly see the changes you've made to the UI without losing the current state of the app. Flutter injects the updated source code files into the running Dart VM, and the Flutter framework automatically rebuilds the widget tree. Use this when making UI changes.

- **Hot Restart**: Completely restarts the app and reloads all code, losing the current state. Use this when making changes to initialization code, state management setup, or when hot reload doesn't work as expected.

## Project Structure

- `lib/main.dart` - Entry point of the application
- `lib/app/theme.dart` - Theme configuration
- `lib/auth/` - Authentication related files
  - `auth_service.dart` - Handles user authentication
  - `login_screen.dart` - Login UI
  - `signup_screen.dart` - Signup UI
- `lib/dashboard/` - Task management related files
  - `dashboard_screen.dart` - Main screen for task list
  - `task_model.dart` - Task data model
  - `task_tile.dart` - UI for a single task
- `lib/services/` - Services for external APIs
  - `supabase_service.dart` - Handles Supabase database operations
- `lib/utils/` - Utility functions
  - `validators.dart` - Form validation functions

## Libraries Used

- `supabase_flutter` - Supabase client for Flutter
- `provider` - State management
- `flutter_dotenv` - Environment variables management

## Testing

Run tests using:
\`\`\`
flutter test
\`\`\`

## License

[Specify your license]

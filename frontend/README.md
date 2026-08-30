# ChemBridge Prep - Flutter Mobile App

Mobile study application built with Flutter for Edexcel and Cambridge Chemistry students.

## Architecture
- `lib/models/`: Strongly typed Dart data models (`UserModel`, `TopicModel`, `QuestionModel`, `PastPaperModel`, `ProgressModel`).
- `lib/services/`: `ApiService` (powered by Dio with Bearer token interceptor) & `AuthService` (powered by `FlutterSecureStorage`).
- `lib/screens/`:
  - `AuthScreen`: Login & Registration with target board selection.
  - `HomeScreen`: Interactive topic explorer with exam board switcher.
  - `QuizScreen`: MCQ quiz taker with real-time feedback & explanation popups.
  - `PastPapersScreen`: PDF past paper repository launcher.
  - `ProgressScreen`: Performance breakdown & score history.
- `lib/widgets/`: Reusable UI components.

## Getting Started
1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
2. Configure API Endpoint in `lib/services/api_service.dart`:
   - Android Emulator: `http://10.0.2.2:5000/api`
   - iOS Simulator / Web / Desktop: `http://localhost:5000/api`
   - Physical Device: `http://<YOUR_LOCAL_IP>:5000/api`
3. Run the application:
   ```bash
   flutter run
   ```

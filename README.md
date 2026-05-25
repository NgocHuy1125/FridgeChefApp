# Fridge Chef App 🍳📱
**Fridge Chef App** (also known as Fridge Food App) is a smart mobile application designed to act as a "virtual chef" right in your pocket. The app helps users answer the daily question: *"What should I cook today with the ingredients available in my fridge?"* by recommending recipes based on what they currently have.

This project is a personal product that combines an optimized user interface, flexible recommendation logic, and integration with rich culinary data APIs, including custom support for traditional Vietnamese dishes.

## ✨ Key Features

* **Smart Recipe Recommendations:** Users simply input the ingredients they have in their fridge, and the system suggests the most suitable recipes.
* **Diverse & Vietnamese Cuisine Support:** Integrates data from **TheMealDB** API while implementing custom matching logic to support and recommend traditional Vietnamese dishes.
* **Authentication & User Management:** Uses **Supabase** as the backend service to manage the database and handle secure user authentication flows.
* **Seamless UI/UX:** Developed through multiple rounds of UI/UX testing and continuous bug fixing to ensure a smooth, intuitive, and responsive user experience.

## 🛠 Technology Stack

* **Mobile Framework:** Flutter & Dart
* **Backend & Database:** Supabase (Database Management & Authentication)
* **Additional Services:** Firebase
* **Data Communication:** RESTful APIs (Connecting to TheMealDB and backend systems)
* **Core Algorithm:** Enhanced and optimized recipe-matching logic based on input ingredient lists.

## 🚀 Getting Started

**Prerequisites:**
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest version)
* Android Studio or Xcode to run an Emulator/Simulator or test on a physical device.

**Installation Steps:**

1. Clone the repository to your local machine:
   ```bash
   git clone [https://github.com/NgocHuy1125/FridgeChefApp.git](https://github.com/NgocHuy1125/FridgeChefApp.git)
Navigate to the project directory:
  ```Bash
  cd FridgeChefApp
  ```
Install the required dependencies:
  ```Bash
  flutter pub get
  ```
Environment Setup:
Configure your environment variables or add your Supabase, Firebase, and TheMealDB API connection keys according to the project's security guidelines.
Build and run the application:
  ```Bash
  flutter run

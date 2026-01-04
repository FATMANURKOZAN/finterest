# Finterest – Pinterest-like Flutter Application

Finterest is a Pinterest-inspired mobile application developed using **Flutter** and **Firebase**.  
The application allows users to authenticate, upload images, explore visual content, and view detailed posts in a modern and user-friendly interface.

This project was developed as part of a **mobile application development course** and serves as a portfolio project demonstrating Flutter, Firebase, and cross-platform development skills.

---

## Features

- User authentication (Firebase Auth)
- Image upload and storage (Firebase Storage)
- Home feed displaying visual content
- Profile page with user-specific posts
- Detailed image view page
- Modern and responsive UI
- Cross-platform support (Android, iOS, Web, Desktop)

---

## Technologies Used

- Flutter (Dart)
- Firebase Authentication
- Firebase Storage
- Firebase Core
- Image Picker
- Material UI

---

## 📸 Screenshots

### Login

![Login Screen](screenshots/login.jpg)

### Home Feed

![Home Screen](screenshots/home.jpg)

### 👤 Profile

![Profile Screen](screenshots/profile.jpg)

### 📷 Photo Detail

![Detail Screen](screenshots/photo_detail.jpg)

### 📷 Sign In

![Sign In Screen](screenshots/sign_in.jpg)

### 📷 Photo Delete

![Photo Delete Screen](screenshots/photo_delete.jpg)

## Project Structure

lib/
│── main.dart
│── firebase_options.dart
│── home.dart
│── profile.dart
│── photo_detail_page.dart
│
├── pages/
│ └── auth/
│ ├── login.dart
│ └── sign_in.dart

---

## Firebase Configuration

> **Note**
> The Firebase Storage free tier used during development has expired.  
> Image upload and retrieval features may not function unless a new Firebase project or billing plan is configured.

---

## How to Run the Project

```bash
git clone https://github.com/FATMANURKOZAN/finterest.git
cd finterest
flutter pub get
flutter run

👩‍💻 Author
Fatma Nur Kozan
Computer Engineering Student

GitHub: https://github.com/FATMANURKOZAN
```

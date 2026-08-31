<div align="center">

# 📋 Employee Attendance Management System

A cross-platform **Flutter** application for tracking employee attendance in real time — with role-based access control, manager oversight, and Firebase-backed sync.

[![Flutter](https://img.shields.io/badge/Flutter-3.13%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![BLoC](https://img.shields.io/badge/State%20Management-flutter__bloc-4285F4)](https://bloclibrary.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](#)
</div>

---

## ✨ Overview

**EAMS** replaces manual attendance registers with a mobile-first system where employees check in, managers monitor their teams, and admins control the whole organization all synced live through Firebase.

The app runs from a single Flutter codebase to **Android**.

## 🖼️ Screenshots
<div align="center">

<table width="100%">
  <tr>
    <td align="center" width="33%">
      <img width="240" alt="splash light" src="https://github.com/user-attachments/assets/313ff4d2-f7e9-4a5f-b94a-3a0336db99fd" /><br />      <b>Splash Page</b><br/>
    </td>
    <td align="center" width="33%">
      <img width="240" alt="login light" src="https://github.com/user-attachments/assets/d8542998-c611-43bb-840d-3e8e2cc05b84" />
<br />
      <b>Login Page</b><br/>
    </td>
    <td align="center" width="33%">
      <img width="240" alt="signup light" src="https://github.com/user-attachments/assets/76b00c7e-37db-4c32-8805-a52aebb6fb52" /><br />
      <b>Signup Page</b><br/>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <img width="240" alt="dashboard light" src="https://github.com/user-attachments/assets/3a3d2986-5f06-4bdf-953a-2f78630e7944" />
<br />
      <b>Dashboard</b><br/>
    </td>
    <td align="center" width="33%">
      <img width="240" alt="attendance light" src="https://github.com/user-attachments/assets/d80bd57a-91fc-4b01-8794-cb25eec7a942" />
<br />
      <b>Attendance Page</b><br/>
    </td>
    <td align="center" width="33%">
      <img width="240" alt="profile light" src="https://github.com/user-attachments/assets/4f21419d-afaa-46a3-ad3e-2f73b7c6509a" />
<br />
      <b>Profile Page</b><br/>
    </td>
      </tr>
    <tr>
  <td align="center" width="33%">
    <img width="240" alt="avatar light" src="https://github.com/user-attachments/assets/caa6a743-1a3e-46a5-b6ee-fd95e07f865f" />
    <br/>
    <b>Avatar Selection</b><br/>
  </td>
  <td align="center" width="33%">
    <img width="240" alt="splash dark" src="https://github.com/user-attachments/assets/01abf8e3-194a-45de-997c-48007b28ecc8" />
<br/>
    <b>Splash Page Dark Mode</b><br/>
  </td>
  <td align="center" width="33%">
    <img width="240" alt="login dark" src="https://github.com/user-attachments/assets/57de4c18-9f92-418f-80c6-236df40ac163" />
<br/>
    <b>Login Page Dark Mode</b><br/>
  </td>
</tr>
  <tr>
  <td align="center" width="33%">
    <img width="240" alt="signup dark" src="https://github.com/user-attachments/assets/772c8747-c26e-44e0-a0dd-c3acfcff111f" />
<br/>
    <b>Signup Page Dark Mode</b><br/>
  </td>
  <td align="center" width="33%">
    <img width="240" alt="dashboard dark" src="https://github.com/user-attachments/assets/226de6ed-88c4-4ea4-8e99-1bbb0406075a" />
<br/>
    <b>Dashboard Page Dark Mode</b><br/>
  </td>
  <td align="center" width="33%">
    <img width="240" alt="attendance dark" src="https://github.com/user-attachments/assets/223f6964-1870-4011-8df2-06a9737e0ac9" /><br/>
    <b>Attendance Page Dark Mode</b><br/>
  </td>
</tr>
  <tr>
  <td align="center" width="33%">
    <img width="240" alt="profile dark" src="https://github.com/user-attachments/assets/cbc93d6e-197d-4f13-b2d8-9fb4dab7aac7" />
<br/>
    <b>Profile Page Dark Mode</b><br/>
  </td>
  <td align="center" width="33%">
    <img width="240" alt="avatar dark" src="https://github.com/user-attachments/assets/043ccd09-904d-40ff-aa0c-e60f71a5d153" />
<br/>
    <b>Avatar Dark Mode</b><br/>
  </td>
      <td align="center" width="33%"></td>
</tr>
</table>
</div>

## 🚀 Features

### 🔐 Role-Based Access Control
Three built-in roles with granular permissions:

| Role | Capabilities |
|------|---------------|
| **Admin** | Full access — manage employees, assign roles/managers, view all attendance |
| **Manager** | View and manage attendance for their assigned team |
| **Employee** | Check in and view their own attendance history |

Permissions (`viewOwnAttendance`, `viewTeamAttendance`, `viewAllEmployees`, `manageEmployees`, `manageRoles`, `manageAttendance`) can be assigned independently of role for fine-grained control.

### 🕒 Attendance Tracking
- One-tap **check-in** with automatic status detection — `Present`, `Late`, or `Absent`
- **"My Attendance"** and **"People I Can View"** tabs for personal vs. team records
- Filter attendance by **Today**, **This Week**, or **Monthly**
- Offline-aware sync flag so records aren't lost without a connection

### 🏠 Dashboard
- Time-aware greeting (good morning/afternoon/evening)
- At-a-glance recent attendance summary card

### 👥 Employee Management
- Register new employees
- Assign or remove a manager for each employee
- Grant/revoke authority (roles & permissions)
- Remove employees from the system

### 👤 Profile
- Editable profile with photo upload (`image_picker`)
- Persisted across sessions via `shared_preferences`

### 🎨 UX
- Full **light/dark mode** toggle, saved to local preferences
- Bottom navigation: **Home · Attendance · Profile**

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart SDK ^3.13.0) |
| State Management | `flutter_bloc`, `bloc_concurrency`, `equatable` |
| Backend | [Firebase](https://firebase.google.com) — Authentication & Cloud Firestore |
| Local Storage | `shared_preferences` |
| Config | `flutter_dotenv` (`.env`) |
| Media | `image_picker`, `image` |
| Testing | `bloc_test`, `mocktail`, `fake_cloud_firestore` |

**Architecture:** Feature-first structure (`attendance`, `authentication`, `dashboard`, `employees`, `profile`) — each module cleanly split into `bloc/`, `models/`, `repository/`, and `view/` layers.

## 📂 Project Structure

```
lib/
├── attendance/
│   ├── bloc/            # attendance_bloc.dart, attendance_event.dart, attendance_state.dart
│   ├── models/          # attendance.dart (Attendance model, AttendanceStatus enum)
│   ├── repository/      # attendance_repository.dart
│   ├── view/            # attendance_page.dart
│   └── widgets/         # attendance_list_item.dart, employee_attendance_card.dart, today_employee_attendance.dart
├── authentication/
│   ├── bloc/            # auth_bloc.dart, auth_event.dart, auth_state.dart
│   ├── models/          # user.dart (User model, UserRole, UserPermission)
│   ├── repository/      # firebase_auth_repository.dart
│   ├── view/            # login_page.dart, signup_page.dart
│   └── widgets/         # auth_button.dart, email_field.dart, name_field.dart, password_field.dart
├── dashboard/
│   ├── bloc/            # dashboard_bloc.dart, dashboard_event.dart, dashboard_state.dart
│   ├── view/            # dashboard_page.dart
│   └── widgets/         # attendance_summary.dart, check_in_card.dart, swipe_check_button.dart
├── employees/
│   ├── bloc/            # employee_bloc.dart, employee_event.dart, employee_state.dart
│   ├── models/          # employee.dart
│   └── repository/      # employee_repository.dart
├── profile/
│   ├── repository/      # profile_repository.dart
│   ├── view/            # profile_page.dart
│   └── widgets/         # profile_image.dart
├── shared/
│   └── widgets/         # app_bottom_navigation.dart
├── splash/
│   ├── view/             # splash_page.dart
│   └── widgets/          # splash_logo.dart
├── app.dart              # App shell, theming, routing
├── main.dart              # Entry point
└── simple_bloc_observer.dart   # BLoC transition/error logging
```


---

## 🛠️ Built With

- **Flutter** — cross-platform UI toolkit
- **Dart** — programming language
- **flutter_bloc** / **bloc** / **bloc_concurrency** — state management
- **firebase_core**, **firebase_auth**, **cloud_firestore** — backend & auth
- **shared_preferences** — local persistence
- **flutter_dotenv** — environment variable management
- **image_picker** / **image** — profile image handling
- **equatable** — value equality for BLoC states/events
- **bloc_test**, **mocktail**, **fake_cloud_firestore** — testing

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Dart ^3.13.0)
- A Firebase project (Authentication + Cloud Firestore enabled)

### Setup

1. Clone the repository
```bash
   git clone https://github.com/eshalwaseem/employee-attendance-management-system.git
   cd employee-attendance-management-system
```

2. Install dependencies
```bash
   flutter pub get
```

3. Create a `.env` file in the project root with your Firebase config:
```
   FIREBASE_API_KEY=your_api_key
   FIREBASE_APP_ID=your_app_id
   FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_AUTH_DOMAIN=your_auth_domain
   FIREBASE_STORAGE_BUCKET=your_storage_bucket
```

4. Run the app
```bash
   flutter run
```

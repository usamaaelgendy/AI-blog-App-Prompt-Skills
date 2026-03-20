# Blog App — Educational Project

> This is an educational project for the **Developer X AI** course. The code serves as a reference for the examples in Section 3: Prompt Skill.

## Purpose

This project is **not meant to be run**. It exists so you can:
- See the structure of a real Flutter project using Clean Architecture
- Understand the files used in the lessons
- Follow along with the examples in context

## Structure

```
lib/
├── core/                    # Shared core utilities
│   ├── network/             # API Client (abstract + impl)
│   ├── theme/               # App Theme
│   ├── storage/             # SharedPreferences wrapper
│   └── errors/              # Exceptions, Failures, AppError
├── services/                # General services (UserService)
└── features/                # Features (Clean Architecture)
    ├── auth/                # Authentication (login)
    ├── posts/               # Posts (read, search, add, delete)
    ├── profile/             # User profile
    └── home/                # Home page
```

## Tech Stack

- Flutter 3.24+
- Dart 3.5+
- BLoC (flutter_bloc)
- Supabase
- Clean Architecture (data / domain / presentation)
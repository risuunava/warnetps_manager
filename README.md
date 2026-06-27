# WarnetPS Manager

Aplikasi manajemen **Warnet & Rental PlayStation** berbasis Flutter yang menggantikan proses manual (catatan + stopwatch) dengan sistem digital real-time terhubung ke cloud.

**Platform:** Android (Flutter)  
**Backend:** Firebase (Firestore + Auth)  
**Status:** MVP — Fungsional lengkap ✅

---

## Fitur

| Fitur | Status |
|-------|--------|
| **Autentikasi** — Login Email/Password dengan role-based access (Owner & Operator) | ✅ |
| **Dashboard** — Grid 10 unit (5 PC + 5 PS) dengan status real-time (`available`/`in_use`/`maintenance`), live timer di unit aktif, ringkasan statistik | ✅ |
| **Manajemen Sesi** — Start/stop sesi, timer real-time, kalkulasi biaya otomatis, tambah extra (makanan/minuman), checkout dengan struk digital | ✅ |
| **Membership** — CRUD member, sistem poin (Rp1.000 = 1 poin), level (Regular/Silver/Gold), diskon otomatis, histori kunjungan | ✅ |
| **Laporan (Owner)** — Filter periode (hari/minggu/bulan), total pendapatan, distribusi platform (PC vs PS), riwayat transaksi real-time | ✅ |
| **Pengaturan (Owner)** — Kelola tarif per tipe unit, kelola akun operator, profil toko | ✅ |

### Unit yang Dikelola

- **PC:** 5 unit (PC 01–PC 05)
- **PlayStation:** 5 unit (PS4 ×1, PS3 ×2, PS2 ×2) — PS Station 1–5

---

## Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| Framework | Flutter (Dart) — `>=3.11.0` |
| State Management | Riverpod (`flutter_riverpod` + `riverpod_annotation`) |
| Navigation | go_router |
| Database | Firebase Firestore (real-time) |
| Auth | Firebase Authentication (Email/Password) |
| Charts | fl_chart |
| Storage | Firebase Storage (foto member) |
| Font | Google Fonts (Arimo + Tinos) |

---

## Struktur Proyek

```
lib/
├── main.dart                        # Entry point: Firebase init, ProviderScope, router
├── firebase_options.dart            # Firebase project config (auto-generated)
├── models/                          # Data models (fromMap/toMap)
│   ├── unit_model.dart
│   ├── session_model.dart
│   ├── member_model.dart
│   ├── tariff_model.dart
│   └── user_model.dart
├── services/                        # Firebase CRUD + business logic
│   ├── auth_service.dart            # Firebase Auth
│   ├── unit_service.dart            # Firestore units
│   ├── session_service.dart         # Firestore sessions + kalkulasi biaya
│   ├── tariff_service.dart          # Firestore tariffs
│   ├── member_service.dart          # Firestore members
│   ├── report_service.dart          # Firestore laporan
│   └── router.dart                  # go_router config
├── providers/                       # Riverpod providers
│   ├── auth_provider.dart
│   └── services_provider.dart
├── screens/                         # Halaman aplikasi
│   ├── auth/login_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── session/ (start_session, session_detail, checkout)
│   ├── member/ (member_list, member_detail, add_member)
│   ├── report/report_screen.dart
│   ├── settings/ (settings, manage_tariff, manage_operators)
│   └── main_screen.dart             # Bottom navigation shell
├── widgets/                         # Komponen UI reusable
│   ├── elapsed_time_text.dart
│   └── shared/ (unit_card, retro_scaffold, retro_crt_monitor, dll)
└── theme/
    └── app_theme.dart               # Tema retro Dell 1996
```

---

## Firestore Data Model

- `/users/{userId}` — name, email, role (owner/operator)
- `/units/{unitId}` — name, type, status, currentSessionId
- `/tariffs/{tariffId}` — unitType, pricePerHour, weekendPrice, minimumMinutes
- `/sessions/{sessionId}` — unitId, startTime, endTime, duration, memberId, total, extras, status
- `/members/{memberId}` — name, phone, points, level, totalVisits
- `/memberVisits/{visitId}` — memberId, sessionId, pointsEarned, amountSpent

---

## Cara Menjalankan

```bash
# Install dependencies
flutter pub get

# Generate code (riverpod, dll)
dart run build_runner build --delete-conflicting-outputs

# Jalankan di perangkat/emulator
flutter run
```

> Firebase config (`firebase_options.dart`) sudah tersedia. Pastikan menggunakan Firebase project `warnetps-manager` atau ganti dengan project Anda sendiri.

---

## Pengembangan

Proyek ini menggunakan:
- **Riverpod** untuk state management
- **go_router** untuk routing + auth redirect
- **Code generation** dengan `riverpod_generator`
- **Desain retro Dell 1996** — frame hitam 8px, Times New Roman, Arial Black, bevel Win95, ikon monitor CRT

### Perintah berguna

```bash
# Generate kode (setelah edit provider)
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch
```

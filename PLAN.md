# PLAN.md — Rencana Pengerjaan Warnet & Rental PS Manager
**Versi:** 1.0.0  
**Framework:** Flutter + Firebase  
**Target:** Android  
**Untuk:** Pemula Android Studio & Flutter

---

> **📌 Cara Baca Dokumen Ini**
> Setiap fase dijelaskan step by step. Navigasi Android Studio ditulis **tebal** seperti `Menu > Submenu`. File yang dibuat ditulis seperti `lib/screens/dashboard.dart`. Ikuti urutan fase, jangan loncat-loncat.

---

## 🗺️ Peta Fase Pengerjaan

```
FASE 0 → FASE 1 → FASE 2 → FASE 3 → FASE 4 → FASE 5 → FASE 6
Setup    Auth     Dashboard  Sesi     Member   Laporan  Finishing
(3 hari) (2 hari) (2 hari)  (3 hari) (2 hari) (2 hari) (2 hari)

Total estimasi: ~16 hari kerja (bisa lebih, santai saja)
```

---

## 📁 Struktur Folder Project (Gambaran Awal)

Setelah project dibuat, folder `lib/` akan terlihat seperti ini:

```
lib/
├── main.dart                  ← Pintu masuk aplikasi
├── firebase_options.dart      ← Auto-generated oleh FlutterFire CLI
│
├── models/                    ← Definisi data (blueprint)
│   ├── unit_model.dart
│   ├── session_model.dart
│   ├── member_model.dart
│   └── tariff_model.dart
│
├── services/                  ← Koneksi ke Firebase
│   ├── auth_service.dart
│   ├── unit_service.dart
│   ├── session_service.dart
│   └── member_service.dart
│
├── providers/                 ← State management (Riverpod)
│   ├── auth_provider.dart
│   └── unit_provider.dart
│
├── screens/                   ← Halaman-halaman aplikasi
│   ├── auth/
│   │   └── login_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── session/
│   │   ├── start_session_screen.dart
│   │   └── checkout_screen.dart
│   ├── member/
│   │   ├── member_list_screen.dart
│   │   └── member_detail_screen.dart
│   ├── report/
│   │   └── report_screen.dart
│   └── settings/
│       └── settings_screen.dart
│
└── widgets/                   ← Komponen kecil yang dipakai berulang
    ├── unit_card.dart
    └── status_badge.dart
```

---

## ✅ FASE 0 — Setup Project & Firebase
**Estimasi: 3 hari**  
**Tujuan: Project bisa jalan di emulator/HP dan terhubung ke Firebase**

---

### LANGKAH 0.1 — Buat Project Flutter Baru di Android Studio

1. Buka **Android Studio**
2. Di layar welcome, klik tombol **`New Project`**
3. Di window yang muncul, pilih tab **`Flutter`** di kiri
4. Pilih template **`Flutter Application`** → klik **Next**
5. Isi form:
   - **Project name:** `warnetps_manager` *(huruf kecil, pakai underscore)*
   - **Project location:** pilih folder yang kamu mau (misal: `D:\Projects\`)
   - **Organization:** `com.namakamu` *(misal: `com.risu`)*
   - **Android language:** Kotlin *(biarkan default)*
   - **Platforms:** centang **Android** saja dulu
6. Klik **Finish** — tunggu Gradle sync selesai (bisa 2–5 menit pertama kali)

> 💡 **Kamu akan lihat:** Di kiri ada panel `Project` yang menampilkan folder-folder. Di tengah ada editor kode. Di bawah ada terminal dan log.

---

### LANGKAH 0.2 — Kenali Layout Android Studio

```
┌─────────────────────────────────────────────────────┐
│  Menu Bar: File | Edit | View | Run | Tools | Help  │
├──────────────┬──────────────────────────┬────────────┤
│              │                          │            │
│  Panel Kiri  │    AREA EDITOR KODE      │ Panel Kanan│
│  (Project    │    (tulis kode disini)   │ (opsional) │
│   Explorer)  │                          │            │
│              │                          │            │
├──────────────┴──────────────────────────┴────────────┤
│  Panel Bawah: Terminal | Logcat | Build | Problems   │
└─────────────────────────────────────────────────────┘
```

**Panel yang sering kamu pakai:**
- **Project (kiri):** Klik file `.dart` untuk membukanya di editor
- **Terminal (bawah):** Ketik command Flutter/Dart di sini
- **Logcat (bawah):** Lihat error/log dari emulator atau HP kamu

**Cara buka Terminal:** Klik `Terminal` di panel bawah, atau tekan `Alt + F12`

---

### LANGKAH 0.3 — Tambahkan Dependencies (Package)

1. Di panel kiri, klik file **`pubspec.yaml`** (ada di root project)
2. Di dalam file itu, cari bagian `dependencies:`
3. Tambahkan package-package berikut:

```yaml
dependencies:
   flutter:
      sdk: flutter

   # Firebase
   firebase_core: ^3.6.0
   firebase_auth: ^5.3.1
   cloud_firestore: ^5.4.4
   # firebase_storage → TIDAK DIPAKAI (butuh kartu kredit, zero cost)

   # State Management
   flutter_riverpod: ^2.5.1
   riverpod_annotation: ^2.3.5

   # Navigation
   go_router: ^14.2.7

   # UI Helpers
   intl: ^0.19.0             # Format tanggal & angka (Rp 15.000, 14:30)
   fl_chart: ^0.69.0         # Grafik laporan pendapatan

dev_dependencies:
   flutter_test:
      sdk: flutter
   build_runner: ^2.4.12
   riverpod_generator: ^2.4.3
```

> ℹ️ **Kenapa tidak ada firebase_storage, image_picker, cached_network_image?**
> Firebase Storage butuh kartu kredit untuk aktivasi. Fitur foto member diganti dengan **avatar inisial nama** (contoh: "Budi Santoso" → lingkaran dengan huruf "BS"). Ini zero cost dan tidak mengurangi fungsi utama aplikasi.

4. Setelah edit, klik **`Pub get`** yang muncul di atas editor, ATAU buka Terminal dan ketik:
```bash
flutter pub get
```

> ✅ **Berhasil jika:** Terminal menampilkan `Got dependencies!` tanpa error merah

---

### LANGKAH 0.4 — Setup Firebase

**A. Buat Project di Firebase Console**
1. Buka browser → pergi ke [console.firebase.google.com](https://console.firebase.google.com)
2. Klik **`Tambahkan Project`** (atau `Add Project`)
3. Nama project: `warnetps-manager`
4. Matikan Google Analytics (tidak perlu untuk MVP) → klik **Create Project**
5. Tunggu sebentar → klik **Continue**

**B. Aktifkan Layanan yang Dibutuhkan**
Di sidebar Firebase Console:
- **Authentication** → `Get started` → aktifkan **Email/Password**
- **Firestore Database** → `Create database` → pilih **`Start in test mode`** → pilih region `asia-southeast1` (Singapore, paling dekat)

> ⚠️ **Storage TIDAK perlu diaktifkan** — butuh kartu kredit. Foto member diganti avatar inisial nama, zero cost.

**C. Hubungkan Firebase ke Flutter (FlutterFire CLI)**

Buka Terminal di Android Studio, ketik satu per satu:

```bash
# Install FlutterFire CLI (sekali saja)
dart pub global activate flutterfire_cli

# Login ke Google (browser akan terbuka)
firebase login

# Hubungkan project Flutter ke Firebase
flutterfire configure
```

Saat `flutterfire configure` berjalan:
- Pilih project `warnetps-manager` yang tadi dibuat
- Centang **Android** saja
- Tekan Enter → tunggu proses selesai

> ✅ **Berhasil jika:** File `lib/firebase_options.dart` muncul di panel kiri project

**D. Inisialisasi Firebase di `main.dart`**

Buka `lib/main.dart`, ganti semua isinya dengan ini:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
   );
   runApp(
      const ProviderScope(  // Wrapper untuk Riverpod
         child: MyApp(),
      ),
   );
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

   @override
   Widget build(BuildContext context) {
      return MaterialApp(
         title: 'WarnetPS Manager',
         theme: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
               primary: Color(0xFF0088FF),
               secondary: Color(0xFF00D4FF),
            ),
         ),
         home: const Scaffold(
            body: Center(
               child: Text('Firebase Connected!'), // Placeholder dulu
            ),
         ),
      );
   }
}
```

**E. Test Jalankan di Emulator**
1. Di toolbar atas Android Studio, klik dropdown device → pilih emulator yang ada (atau buat baru via `Device Manager`)
2. Klik tombol ▶️ **Run** (tombol hijau di toolbar atas), atau tekan `Shift + F10`
3. Tunggu build (pertama kali bisa 3–5 menit)

> ✅ **Berhasil jika:** Emulator menyala dan tampil tulisan "Firebase Connected!" di tengah layar hitam

---

## ✅ FASE 1 — Autentikasi (Login & Logout)
**Estimasi: 2 hari**  
**Tujuan: Ada halaman login, Owner & Operator bisa masuk dengan akun masing-masing**

---

### LANGKAH 1.1 — Buat Halaman Login

**Cara buat file baru di Android Studio:**
1. Di panel kiri, klik kanan folder `lib`
2. Pilih **`New > Directory`** → ketik `screens`
3. Klik kanan folder `screens` → **`New > Directory`** → ketik `auth`
4. Klik kanan folder `auth` → **`New > Dart File`** → ketik `login_screen`

File `lib/screens/auth/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
   const LoginScreen({super.key});

   @override
   ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
   final _emailController = TextEditingController();
   final _passwordController = TextEditingController();
   bool _isLoading = false;

   @override
   Widget build(BuildContext context) {
      return Scaffold(
         backgroundColor: const Color(0xFF0A0A0F),
         body: Center(
            child: Padding(
               padding: const EdgeInsets.all(32.0),
               child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     // Logo / Judul
                     const Icon(Icons.computer, color: Color(0xFF0088FF), size: 64),
                     const SizedBox(height: 16),
                     const Text(
                        'WarnetPS Manager',
                        style: TextStyle(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: Colors.white,
                        ),
                     ),
                     const SizedBox(height: 48),

                     // Input Email
                     TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                           labelText: 'Email',
                           prefixIcon: Icon(Icons.email),
                           border: OutlineInputBorder(),
                        ),
                     ),
                     const SizedBox(height: 16),

                     // Input Password
                     TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                           labelText: 'Password',
                           prefixIcon: Icon(Icons.lock),
                           border: OutlineInputBorder(),
                        ),
                     ),
                     const SizedBox(height: 24),

                     // Tombol Login
                     SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                           onPressed: _isLoading ? null : _handleLogin,
                           style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0088FF),
                           ),
                           child: _isLoading
                                   ? const CircularProgressIndicator(color: Colors.white)
                                   : const Text('Masuk', style: TextStyle(fontSize: 16)),
                        ),
                     ),
                  ],
               ),
            ),
         ),
      );
   }

   Future<void> _handleLogin() async {
      // Akan diisi di langkah berikutnya
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1)); // placeholder
      setState(() => _isLoading = false);
   }

   @override
   void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
   }
}
```

### LANGKAH 1.2 — Buat Auth Service

Buat folder `lib/services/` → file `auth_service.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
   final _auth = FirebaseAuth.instance;
   final _db = FirebaseFirestore.instance;

   // Cek siapa yang sedang login
   User? get currentUser => _auth.currentUser;

   // Stream perubahan status login
   Stream<User?> get authStateChanges => _auth.authStateChanges();

   // Login
   Future<Map<String, dynamic>> login(String email, String password) async {
      try {
         final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
         );
         // Ambil data role dari Firestore
         final userDoc = await _db
                 .collection('users')
                 .doc(credential.user!.uid)
                 .get();
         return {'success': true, 'role': userDoc['role']};
      } on FirebaseAuthException catch (e) {
         return {'success': false, 'message': e.message};
      }
   }

   // Logout
   Future<void> logout() async {
      await _auth.signOut();
   }
}
```

### LANGKAH 1.3 — Daftarkan Akun Pertama (Owner) di Firebase Console

1. Buka Firebase Console → **Authentication** → tab **Users**
2. Klik **`Add user`**
3. Masukkan email dan password Owner
4. Klik **Add user** → copy **User UID** yang muncul

5. Buka **Firestore Database** → klik **`Start collection`**
6. Collection ID: `users`
7. Document ID: paste **User UID** dari langkah 4
8. Tambah fields:
   - `name` (string): `"Owner"`
   - `email` (string): email owner
   - `role` (string): `"owner"`

> 💡 Ulangi untuk buat akun Operator, dengan `role: "operator"`

---

## ✅ FASE 2 — Dashboard Utama
**Estimasi: 2 hari**  
**Tujuan: Halaman utama dengan grid 10 unit yang update real-time**

---

### LANGKAH 2.1 — Isi Data Unit di Firestore

Di **Firestore Console**, buat collection `units` dengan 10 dokumen:

**Contoh dokumen untuk `pc_01`:**
```
Document ID: pc_01
Fields:
  name: "PC 01"
  type: "pc"
  psType: null
  status: "available"
  currentSessionId: null
  tariffId: "tariff_pc"
```

**Contoh untuk `ps_01` (PS4):**
```
Document ID: ps_01
Fields:
  name: "PS Station 1"
  type: "ps"
  psType: "ps4"
  status: "available"
  currentSessionId: null
  tariffId: "tariff_ps4"
```

Buat 10 dokumen lengkap (pc_01–pc_05, ps_01–ps_05).

### LANGKAH 2.2 — Buat Dashboard Screen

`lib/screens/dashboard/dashboard_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
   const DashboardScreen({super.key});

   @override
   Widget build(BuildContext context) {
      return Scaffold(
         backgroundColor: const Color(0xFF0A0A0F),
         appBar: AppBar(
            backgroundColor: const Color(0xFF12121A),
            title: const Text('WarnetPS Manager'),
            actions: [
               IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {/* logout */},
               ),
            ],
         ),
         body: Column(
            children: [
               // Bagian PC
               _buildSectionHeader('💻 Komputer (PC)'),
               _buildUnitGrid(unitType: 'pc'),

               // Bagian PS
               _buildSectionHeader('🎮 PlayStation (PS)'),
               _buildUnitGrid(unitType: 'ps'),
            ],
         ),
      );
   }

   Widget _buildSectionHeader(String title) {
      return Padding(
         padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
         child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
               title,
               style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
               ),
            ),
         ),
      );
   }

   Widget _buildUnitGrid({required String unitType}) {
      return StreamBuilder<QuerySnapshot>(
         // StreamBuilder = otomatis update ketika data Firestore berubah
         stream: FirebaseFirestore.instance
                 .collection('units')
                 .where('type', isEqualTo: unitType)
                 .snapshots(),
         builder: (context, snapshot) {
            if (!snapshot.hasData) {
               return const Center(child: CircularProgressIndicator());
            }
            final units = snapshot.data!.docs;
            return GridView.builder(
               shrinkWrap: true,
               physics: const NeverScrollableScrollPhysics(),
               padding: const EdgeInsets.symmetric(horizontal: 16),
               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 kolom
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
               ),
               itemCount: units.length,
               itemBuilder: (context, index) {
                  final unit = units[index].data() as Map<String, dynamic>;
                  return _UnitCard(unit: unit, unitId: units[index].id);
               },
            );
         },
      );
   }
}

class _UnitCard extends StatelessWidget {
   final Map<String, dynamic> unit;
   final String unitId;

   const _UnitCard({required this.unit, required this.unitId});

   @override
   Widget build(BuildContext context) {
      final status = unit['status'] as String;
      final isAvailable = status == 'available';
      final isInUse = status == 'in_use';

      final statusColor = isAvailable
              ? const Color(0xFF00C853)
              : isInUse
              ? const Color(0xFFFF1744)
              : const Color(0xFF616161);

      return GestureDetector(
         onTap: () {
            // TODO: Buka dialog start/stop sesi
         },
         child: Container(
            decoration: BoxDecoration(
               color: const Color(0xFF12121A),
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
            ),
            child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                  Icon(
                     unit['type'] == 'pc' ? Icons.computer : Icons.sports_esports,
                     color: statusColor,
                     size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                     unit['name'],
                     style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                     ),
                     textAlign: TextAlign.center,
                  ),
                  if (unit['psType'] != null)
                     Text(
                        unit['psType'].toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 10),
                     ),
                  const SizedBox(height: 4),
                  Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                     ),
                     child: Text(
                        isAvailable
                                ? 'Tersedia'
                                : isInUse
                                ? 'Dipakai'
                                : 'Maintenance',
                        style: TextStyle(color: statusColor, fontSize: 9),
                     ),
                  ),
               ],
            ),
         ),
      );
   }
}
```

---

## ✅ FASE 3 — Manajemen Sesi
**Estimasi: 3 hari**  
**Tujuan: Operator bisa start sesi, lihat timer berjalan, dan stop + kasir**

---

### Alur Screen Sesi:

```
Dashboard (tap unit kosong)
    ↓
StartSessionScreen
  - Input nama pelanggan
  - Pilih member (opsional)
  - Tombol "Mulai Sesi"
    ↓ [Firestore: buat dokumen session, update status unit]
Dashboard (unit berubah merah, tampil timer)
    ↓
(tap unit yang sedang dipakai)
    ↓
SessionDetailScreen
  - Tampil: nama, durasi, biaya sementara
  - Tombol "Stop & Bayar"
    ↓
CheckoutScreen
  - Tampil total biaya
  - Input item tambahan (opsional)
  - Diskon member (otomatis)
  - Tombol "Konfirmasi Bayar"
    ↓ [Firestore: update session jadi completed, reset status unit]
Dashboard (unit kembali hijau)
```

> 📝 **File yang dibuat di fase ini:**
> - `lib/screens/session/start_session_screen.dart`
> - `lib/screens/session/session_detail_screen.dart`
> - `lib/screens/session/checkout_screen.dart`
> - `lib/services/session_service.dart`
> - `lib/services/tariff_service.dart`

---

## ✅ FASE 4 — Membership
**Estimasi: 2 hari**  
**Tujuan: Daftarkan member, cari member saat transaksi, poin otomatis terhitung**

---

### Alur Screen Member:

```
Bottom Nav → Tab "Member"
    ↓
MemberListScreen
  - Search bar (cari by nama/HP)
  - List semua member + level badge
  - FAB (+) untuk tambah member baru
    ↓ (tap member)
MemberDetailScreen
  - Info: nama, poin, level, total kunjungan
  - Riwayat transaksi member ini
    ↓ (tap FAB +)
AddMemberScreen
  - Form: Nama, No HP, Foto (opsional)
  - Tombol Simpan
```

> 📝 **File yang dibuat di fase ini:**
> - `lib/screens/member/member_list_screen.dart`
> - `lib/screens/member/member_detail_screen.dart`
> - `lib/screens/member/add_member_screen.dart`
> - `lib/services/member_service.dart`

---

## ✅ FASE 5 — Laporan (Owner Only)
**Estimasi: 2 hari**  
**Tujuan: Owner bisa lihat ringkasan pendapatan dan statistik**

---

### Alur Screen Laporan:

```
Bottom Nav → Tab "Laporan" (hanya tampil jika role = owner)
    ↓
ReportScreen
  - Filter: Hari ini / 7 hari / Bulan ini
  - Card: Total pendapatan periode ini
  - Grafik batang: pendapatan per hari (fl_chart)
  - List: Unit tersibuk (PC vs PS)
  - List: Jam tersibuk
```

> 📝 **File yang dibuat:**
> - `lib/screens/report/report_screen.dart`
> - `lib/services/report_service.dart`

---

## ✅ FASE 6 — Pengaturan & Finishing
**Estimasi: 2 hari**  
**Tujuan: Tarif bisa diubah, UI dipoles, tidak ada bug kritikal**

---

### Checklist Finishing:

- [ ] Navigasi pakai `go_router` (semua route terdaftar di satu file)
- [ ] Bottom Navigation Bar: Dashboard | Member | Laporan | Pengaturan
- [ ] Halaman Pengaturan: ubah tarif per tipe unit, kelola status maintenance
- [ ] Handle error: tidak ada internet, login gagal, sesi gagal dibuat
- [ ] Loading state di semua tombol aksi
- [ ] Test di HP Android sungguhan (bukan hanya emulator)
- [ ] Firestore Security Rules diperketat (tidak lagi test mode)

---

## 🗺️ Navigasi Lengkap Aplikasi

```
Splash / Auth Check
    ├── Belum login → LoginScreen
    └── Sudah login → MainScreen (Bottom Nav)
            ├── Tab 0: DashboardScreen
            │       ├── Tap unit kosong → StartSessionScreen
            │       │       └── Submit → kembali ke Dashboard
            │       └── Tap unit aktif → SessionDetailScreen
            │               └── "Stop & Bayar" → CheckoutScreen
            │                       └── Konfirmasi → Dashboard
            │
            ├── Tab 1: MemberListScreen
            │       ├── Tap member → MemberDetailScreen
            │       └── FAB + → AddMemberScreen
            │
            ├── Tab 2: ReportScreen (Owner only)
            │
            └── Tab 3: SettingsScreen (Owner only)
                    ├── ManageTariffScreen
                    ├── ManageUnitsScreen
                    └── ManageOperatorsScreen
```

---

## 🔧 Firestore Security Rules (Fase 6 — Sebelum Launch)

Ganti security rules di Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: hanya bisa baca data sendiri
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if false; // hanya dari console
    }

    // Units: semua login bisa baca, hanya operator/owner bisa update
    match /units/{unitId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Sessions: semua login bisa baca & tulis
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null;
    }

    // Members: semua login bisa baca & tulis
    match /members/{memberId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📦 Daftar Package & Kegunaannya

| Package | Kegunaan |
|---|---|
| `firebase_core` | Inisialisasi Firebase |
| `firebase_auth` | Login / Logout |
| `cloud_firestore` | Database real-time |
| `firebase_storage` | Upload foto member |
| `flutter_riverpod` | Kelola state (data yang berubah-ubah) |
| `go_router` | Navigasi antar halaman |
| `intl` | Format: "Rp 15.000" dan "14:30" |
| `fl_chart` | Grafik laporan |
| `image_picker` | Ambil foto dari kamera / galeri |
| `cached_network_image` | Tampilkan foto member dari internet |

---

## ⚠️ Catatan Penting untuk Pemula Flutter

1. **Hot Reload vs Hot Restart**
   - Tekan `r` di terminal → Hot Reload (cepat, tapi tidak reset state)
   - Tekan `R` di terminal → Hot Restart (lambat, tapi reset penuh)
   - Gunakan Hot Reload saat ubah UI, Hot Restart saat ubah logika/data

2. **Error merah di kode ≠ panic**
   - Garis merah di editor = ada yang salah syntax/import
   - Klik di garis merah → tekan `Alt + Enter` → Android Studio biasanya bisa auto-fix

3. **Import otomatis**
   - Saat ketik nama class/widget, tekan `Alt + Enter` untuk auto-import

4. **StreamBuilder vs FutureBuilder**
   - `StreamBuilder` = data update otomatis real-time (pakai untuk unit status, sesi aktif)
   - `FutureBuilder` = data diambil sekali (pakai untuk laporan, detail member)

5. **Jika Gradle sync gagal**
   - Klik `File > Sync Project with Gradle Files`
   - Atau di terminal: `flutter clean` lalu `flutter pub get`

---

## 🚀 Urutan Commit Git yang Disarankan

```
feat: initial flutter project setup
feat: firebase integration and initialization
feat: login screen and auth service
feat: dashboard screen with realtime unit grid
feat: start session flow
feat: checkout and payment flow
feat: member management CRUD
feat: report screen with charts
feat: settings and tariff management
fix: error handling and loading states
chore: firestore security rules
```

---

*Dokumen ini akan diupdate seiring pengerjaan. Tandai setiap langkah yang sudah selesai dengan ✅*
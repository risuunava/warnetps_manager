# PRD.md — Aplikasi Manajemen Warnet & Rental PS
**Nama Proyek:** WarnetPS Manager  
**Platform:** Android (Flutter)  
**Backend:** Firebase (Firestore + Auth + Realtime)  
**Versi Dokumen:** 1.0.0  
**Tanggal:** Juni 2026

---

## 1. Latar Belakang

Pengelolaan warnet dan rental PS secara manual (menggunakan jam tangan + catatan tulis) rawan kesalahan hitung, sulit dipantau dari jarak jauh, dan tidak menghasilkan laporan yang akurat. Aplikasi ini hadir untuk menggantikan proses manual tersebut dengan sistem digital berbasis Android yang terhubung secara real-time.

---

## 2. Tujuan Produk

- Operator dapat memulai dan menghentikan sesi penggunaan unit (PC & PS) dengan mudah
- Owner dapat memantau status semua unit dan laporan keuangan secara real-time dari HP-nya sendiri
- Sistem membership yang mencatat histori dan memberikan benefit ke pelanggan setia
- Data tersimpan di cloud (Firebase) sehingga tidak hilang meski HP rusak/ganti

---

## 3. Pengguna (Roles)

| Role | Deskripsi | Akses |
|---|---|---|
| **Owner/Admin** | Pemilik usaha | Semua fitur + laporan + pengaturan |
| **Operator/Kasir** | Karyawan yang jaga | Kelola sesi, kasir, lihat status unit |

> Satu akun Firebase Auth per pengguna. Role disimpan di Firestore field `role`.

---

## 4. Unit yang Dikelola

### Komputer (PC)
| ID | Nama | Spesifikasi |
|---|---|---|
| pc_01 | PC 01 | Spek Standar |
| pc_02 | PC 02 | Spek Standar |
| pc_03 | PC 03 | Spek Standar |
| pc_04 | PC 04 | Spek Standar |
| pc_05 | PC 05 | Spek Standar |

### PlayStation (PS)
| ID | Nama | Tipe |
|---|---|---|
| ps_01 | PS Station 1 | PlayStation 4 |
| ps_02 | PS Station 2 | PlayStation 3 |
| ps_03 | PS Station 3 | PlayStation 3 |
| ps_04 | PS Station 4 | PlayStation 2 |
| ps_05 | PS Station 5 | PlayStation 2 |

**Total unit: 10 unit**

---

## 5. Fitur Utama (MVP)

### 5.1 Autentikasi
- Login dengan Email + Password via Firebase Auth
- Sistem role-based (Owner vs Operator)
- Logout

### 5.2 Dashboard Utama
- Tampilan grid semua 10 unit (PC + PS) dengan status real-time
- Status unit: `Tersedia` (hijau) / `Sedang Dipakai` (merah) / `Maintenance` (abu-abu)
- Tap unit untuk melihat detail atau memulai sesi
- Counter: unit aktif, pendapatan hari ini

### 5.3 Manajemen Sesi
- **Start Sesi:** Pilih unit → input nama pelanggan (opsional, atau pilih dari member) → konfirmasi → timer mulai
- **Timer:** Berjalan real-time, tampil di card unit
- **Stop Sesi:** Tap unit aktif → sistem hitung durasi → tampil total biaya → konfirmasi bayar
- **Tambah Item:** Saat checkout, bisa tambah item (minuman/snack) secara manual
- Sesi tersimpan ke Firestore setelah selesai

### 5.4 Kasir & Pembayaran
- Kalkulasi otomatis: `durasi (menit) / 60 × tarif per jam`
- Pembayaran: Cash (MVP) — bisa extend ke QRIS nanti
- Struk digital tampil di layar (bisa screenshot)
- History transaksi per shift

### 5.5 Membership
- Daftarkan pelanggan: Nama, No. HP, Foto (opsional)
- Kartu member dengan ID unik
- Poin: setiap Rp 1.000 = 1 poin
- Level member: Regular (0–499 poin) → Silver (500–1.999) → Gold (2.000+)
- Benefit Gold: Diskon 10% otomatis
- Benefit Silver: Diskon 5% otomatis
- History kunjungan per member
- Cari member by nama / nomor HP

### 5.6 Manajemen Tarif
- Set tarif per tipe unit:
  - PC Standar: Rp X/jam
  - PS4: Rp X/jam
  - PS3: Rp X/jam
  - PS2: Rp X/jam
- Tarif weekend (opsional, bisa diaktifkan/nonaktifkan)
- Tarif minimum (misal: minimal bayar 30 menit)
- Paket jam (misal: 3 jam = harga 2,5 jam)

### 5.7 Laporan (Owner Only)
- Pendapatan hari ini / minggu / bulan
- Grafik pendapatan per hari (7 hari terakhir)
- Unit tersibuk (ranking)
- Jam tersibuk (heatmap jam 08.00–24.00)
- Total sesi per tipe (PC vs PS)
- Export laporan ke PDF (stretch goal)

### 5.8 Pengaturan (Owner Only)
- Kelola nama/tipe unit
- Set status maintenance unit
- Tambah/hapus akun Operator
- Ubah tarif
- Info profil toko (nama, alamat)

---

## 6. Struktur Data Firebase (Firestore)

```
/users/{userId}
  - name: string
  - email: string
  - role: "owner" | "operator"
  - createdAt: timestamp

/units/{unitId}
  - name: string          // "PC 01", "PS Station 1"
  - type: "pc" | "ps"
  - psType: "ps4"|"ps3"|"ps2"|null
  - status: "available" | "in_use" | "maintenance"
  - currentSessionId: string | null
  - tariffId: string

/tariffs/{tariffId}
  - unitType: string
  - pricePerHour: number
  - weekendPrice: number | null
  - minimumMinutes: number

/sessions/{sessionId}
  - unitId: string
  - unitName: string
  - startTime: timestamp
  - endTime: timestamp | null
  - durationMinutes: number | null
  - memberId: string | null
  - customerName: string
  - subtotal: number
  - discount: number
  - total: number
  - extras: [{name, price}]
  - paymentMethod: "cash"
  - operatorId: string
  - status: "active" | "completed"

/members/{memberId}
  - name: string
  - phone: string
  - photoUrl: string | null
  - points: number
  - level: "regular" | "silver" | "gold"
  - totalVisits: number
  - totalSpent: number
  - createdAt: timestamp

/memberVisits/{visitId}
  - memberId: string
  - sessionId: string
  - date: timestamp
  - pointsEarned: number
  - amountSpent: number
```

---

## 7. Alur Utama (User Flow)

### Alur Sesi Normal
```
Pelanggan datang
    ↓
Operator buka Dashboard → tap unit kosong
    ↓
Input nama / pilih member
    ↓
Tap "Mulai Sesi" → Timer berjalan, unit jadi merah
    ↓
[Waktu berlalu...]
    ↓
Operator tap unit aktif → "Stop Sesi"
    ↓
Sistem hitung biaya (+ diskon jika member)
    ↓
Tambah item tambahan? → opsional
    ↓
Konfirmasi Bayar → Struk tampil
    ↓
Poin member diupdate (jika ada)
    ↓
Unit kembali hijau (Tersedia)
```

### Alur Daftar Member Baru
```
Operator → Menu Member → Tambah Member
    ↓
Input: Nama, No HP
    ↓
Simpan → ID Member dibuat otomatis
    ↓
Saat transaksi berikutnya, cari nama/HP → pilih member
```

---

## 8. Desain UI (Panduan Umum)

- **Tema:** Dark mode (cocok untuk suasana warnet)
- **Warna utama:** Biru elektrik `#0088FF`
- **Warna aksen:** Cyan `#00D4FF`
- **Background:** `#0A0A0F` (hampir hitam)
- **Card:** `#12121A`
- **Font:** Inter / Roboto
- **Status warna:**
  - Tersedia: `#00C853` (hijau)
  - Sedang dipakai: `#FF1744` (merah)
  - Maintenance: `#616161` (abu-abu)

---

## 9. Tech Stack

| Komponen | Teknologi |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Database | Firebase Firestore |
| Auth | Firebase Authentication |
| Real-time | Firestore real-time listener |
| Storage (foto member) | Firebase Storage |
| Timer | Dart `Timer` + Firestore startTime |
| Navigation | go_router |

---

## 10. Yang Tidak Termasuk MVP

- Pembayaran digital (QRIS, GoPay, dll) — fase 2
- Notifikasi push — fase 2
- Loyalty reward redeem — fase 2
- Denah visual interaktif — fase 2
- Multi-cabang — fase 3
- Web dashboard — fase 3

---

## 11. Kriteria Sukses MVP

- [ ] Operator bisa start/stop sesi dalam < 30 detik
- [ ] Kalkulasi biaya akurat 100%
- [ ] Status unit update real-time di semua device terhubung
- [ ] Data tidak hilang jika HP mati mendadak saat sesi aktif
- [ ] Owner bisa lihat laporan hari ini dari HP-nya sendiri
- [ ] Member bisa didaftarkan dan poin terhitung otomatis

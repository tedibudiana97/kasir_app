# 🧾 Kasir Premium - Aplikasi Manajemen Transaksi

> Aplikasi kasir modern berbasis Flutter dengan fitur lengkap untuk manajemen transaksi, laporan, dan analisis penjualan.

---

## 📱 **Tentang Aplikasi**

Aplikasi Kasir Premium adalah solusi manajemen transaksi yang dirancang untuk memudahkan pencatatan penjualan, pengelolaan data, dan pembuatan laporan keuangan. Dibangun dengan Flutter untuk performa tinggi dan pengalaman pengguna yang mulus di berbagai platform.

---

## ✨ **Fitur Utama**

### 🔐 **Autentikasi**
- Splash Screen dengan animasi
- Onboarding 3 halaman
- Login & Register dengan validasi
- Akun bawaan: `admin@email.com` / `admin123`

### 📊 **Manajemen Transaksi**
- Tambah transaksi dengan kategori
- Edit transaksi yang sudah masuk
- Hapus transaksi
- Search & Filter berdasarkan kategori

### 📈 **Laporan & Analisis**
- Laporan per bulan dengan filter tahun
- Grafik penjualan per kategori (Bar Chart)
- Dashboard dengan ringkasan data
- Grafik aktivitas harian

### 🖨️ **Cetak & Export**
- Cetak struk transaksi (PDF)
- Share PDF via WhatsApp/Email
- Export laporan ke PDF

### 🎨 **UI/UX**
- Dark Mode
- Bottom Navigation (5 Tab)
- Animasi transisi
- Responsive design

---

## 🛠️ **Teknologi yang Digunakan**

| Teknologi | Fungsi |
|-----------|--------|
| **Flutter** | Framework utama |
| **Dart** | Bahasa pemrograman |
| **SharedPreferences** | Penyimpanan data lokal |
| **PDF** | Generate PDF (struk & laporan) |
| **FL Chart** | Grafik & chart interaktif |
| **Intl** | Format tanggal & mata uang |

---


## 📁 **Struktur Proyek**
lib/
├── main.dart # Root aplikasi
├── models/
│ └── transaction_model.dart # Model data transaksi
├── screens/
│ ├── splash_screen.dart # Halaman pembuka
│ ├── onboarding_screen.dart # Perkenalan aplikasi
│ ├── login_screen.dart # Halaman login
│ ├── register_screen.dart # Halaman daftar
│ ├── home_screen.dart # Halaman utama (tambah transaksi)
│ ├── history_screen.dart # Riwayat transaksi
│ ├── report_screen.dart # Laporan per bulan
│ ├── dashboard_screen.dart # Dashboard admin
│ └── profile_screen.dart # Profil pengguna
├── widgets/
│ ├── custom_button.dart # Tombol reusable
│ └── custom_textfield.dart # Input reusable
├── services/
│ ├── auth_service.dart # Autentikasi
│ └── database_service.dart # CRUD database
└── utils/
├── constants.dart # Konstanta (warna, string, dll)
└── helpers.dart # Fungsi bantuan (format, cetak struk)


---

## 🚀 **Cara Menjalankan Aplikasi**

### Prasyarat
- Flutter SDK 3.44+
- Android Studio / VS Code
- Chrome / Android Emulator

### Langkah-langkah

```bash
# 1. Clone repository
git clone https://github.com/tedibudiana97/kasir_app.git

# 2. Masuk ke folder proyek
cd kasir_app

# 3. Install dependencies
flutter pub get

# 4. Jalankan aplikasi (Chrome)
flutter run -d chrome

# 5. Atau jalankan di Android
flutter run

🔧 Build Aplikasi
Build APK (Android)
bash
flutter build apk --release
Build AAB (Play Store)
bash
flutter build appbundle --release
Build Web
bash
flutter build web
Build Windows
bash
flutter build windows --release
📋 Fitur Lengkap
No	Fitur	Status
1	Splash Screen	✅
2	Onboarding	✅
3	Login / Register	✅
4	Tambah Transaksi	✅
5	Edit Transaksi	✅
6	Hapus Transaksi	✅
7	Search & Filter	✅
8	Riwayat Transaksi	✅
9	Laporan per Bulan	✅
10	Grafik Kategori	✅
11	Dashboard Admin	✅
12	Grafik Harian	✅
13	Cetak Struk (PDF)	✅
14	Dark Mode	✅
15	Bottom Navigation	✅
16	Diskon & Pajak	✅


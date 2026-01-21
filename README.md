# 🐾 Pet Information App

Project **Pet Information** adalah aplikasi mobile lintas platform (Android & Web) yang dirancang untuk mengelola dan menampilkan informasi komprehensif mengenai berbagai jenis hewan. Proyek ini merupakan implementasi nyata dari integrasi Cloud Database dan REST API untuk **Tugas Besar Pemrograman Mobile**.

---

## 🚀 Fitur Utama & Progress

Aplikasi ini telah memenuhi standar aplikasi modern dengan fitur-fitur berikut:

* **Autentikasi Firebase**: Sistem Login dan Register yang aman.
* **Manajemen Data Real-time (CRUD)**:
    * **Create/Update/Delete**: Tambah, edit, dan hapus data hewan langsung ke Cloud Firestore.
    * **Search & Filtering**: Pencarian hewan berdasarkan nama dan kategori (Dilindungi/Biasa) menggunakan TabBar.
* **Integrasi REST API (News Module)**: Menampilkan berita konservasi hewan terbaru yang diambil dari external API (npoint.io).
* **Sistem Favorit**: Menyimpan hewan pilihan ke penyimpanan lokal menggunakan `Shared Preferences`.
* **UI/UX Premium**: 
    * **Detail View**: Halaman detail dengan desain Glassmorphism dan layout yang bersih.
    * **Responsive Design**: Tampilan yang menyesuaikan antara versi Mobile dan Web (PWA) https://pet-information-mobile.netlify.app/.
    * **Dark Mode Support**: Mendukung tema gelap sistem secara otomatis.

---

## 🛠️ Arsitektur & Teknologi

* **Framework**: Flutter (Dart)
* **Backend & Database**: 
    * [Firebase Auth](https://firebase.google.com/): Autentikasi User.
    * [Cloud Firestore](https://firebase.google.com/docs/firestore): Database NoSQL Real-time.
* **REST API**: Data berita via JSON API  https://api.npoint.io/79589d4930b56adc5c24.
* **Local Storage**: `shared_preferences` untuk data favorit.
* **Rendering Web**: CanvasKit & HTML Renderer untuk optimasi PWA.

---

## 📱 Tampilan Aplikasi

Netlify Demo: [https://pet-information-mobile.netlify.app/](https://pet-information-mobile.netlify.app/)

---

## ⚙️ Cara Menjalankan Project

1.  **Clone & Install**:
    ```bash
    git clone https://github.com/Rioprmn/pet_information.git
    cd pet_information
    flutter pub get
    ```

2.  **Konfigurasi Android (SHA-1)**:
    Pastikan SHA-1 sudah terdaftar di Firebase Console agar fitur login di APK tidak terblokir.
    ```bash
    cd android && ./gradlew signingReport
    ```

3.  **Build & Run**:
    * **Android**: `flutter run` atau `flutter build apk --release`
    * **Web**: `flutter run -d chrome --web-renderer html`

---

## 📋 Progress Tugas Besar (Status: Final)

- [x] **Ide & Tema**: Informasi Hewan (Selesai)
- [x] **Firebase**: Auth & Firestore (Selesai)
- [x] **CRUD**: Full Implementasi (Selesai)
- [x] **REST API**: Berita Hewan via npoint.io (Selesai)
- [x] **Halaman Dinamis**: 7+ Halaman (Login, Register, Home, Detail, News, Favorite, Profile) (Selesai)
- [x] **Local Storage**: Shared Preferences untuk Favorit (Selesai)
- [x] **Deployment**: PWA di Netlify & APK Release (Selesai)

---

## 🎬 Demo GIF

### Mobile Review
<img src="https://raw.githubusercontent.com/Rioprmn/pet_information/main/gifs/mobile_review.gif" width="480" />


---

**Dibuat oleh:**
- **Nama**: Rio Permana
- **NIM**: 23552011057
- **Kelas**: TIF 23 RP CNS A
- **Project**: pet_information (Tugas Besar Pemrograman Mobile)

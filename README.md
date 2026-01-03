# 🐾 Pet Information App

Project **Pet Information** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mengelola dan menampilkan informasi mengenai berbagai jenis hewan, khususnya spesies yang dilindungi. Proyek ini dibuat untuk memenuhi **Tugas Besar Individu Pemrograman Mobile**.

---

## 🚀 Fitur Utama

Aplikasi ini mencakup fungsi **CRUD (Create, Read, Update, Delete)** yang terintegrasi penuh dengan layanan Cloud:

* **Autentikasi Pengguna**: Login aman menggunakan Firebase Authentication.
* **Daftar Hewan Real-time**: Menampilkan daftar hewan langsung dari Cloud Firestore menggunakan `StreamBuilder`.
* **Manajemen Data (CRUD)**:
    * **Create**: Menambah data hewan baru (nama, nama latin, status, dan foto).
    * **Update**: Memperbarui informasi hewan yang sudah ada.
    * **Delete**: Menghapus data hewan dengan fitur konfirmasi (Long Press).
* **Detail View & Animasi**: Perpindahan halaman yang halus menggunakan **Hero Animation** pada gambar hewan.

---

## 🛠️ Arsitektur & Teknologi

Aplikasi ini dibangun menggunakan teknologi terkini:

* **Bahasa Pemrograman**: Dart
* **Framework**: Flutter
* **Backend as a Service (BaaS)**: [Firebase](https://firebase.google.com/)
    * **Firebase Auth**: Untuk manajemen akun pengguna.
    * **Cloud Firestore**: Database NoSQL untuk penyimpanan data hewan secara real-time.
* **State Management**: Menggunakan fitur bawaan Flutter (`setState` & `StreamBuilder`).



---

## 📱 Tampilan Aplikasi

| Halaman Login | Daftar Hewan | Form Tambah/Edit |
| :---: | :---: | :---: |
| ![Login](https://via.placeholder.com/200x400?text=Login+Page) | ![Home](https://via.placeholder.com/200x400?text=Home+Page) | ![Form](https://via.placeholder.com/200x400?text=Form+CRUD) |

*(Tips: Kamu bisa mengganti link gambar di atas dengan screenshot aplikasi kamu nantinya)*

---

## ⚙️ Cara Menjalankan Project

1.  **Clone repository ini**:
    ```bash
    git clone [https://github.com/username/pet_information.git](https://github.com/username/pet_information.git)
    ```
2.  **Masuk ke direktori project**:
    ```bash
    cd pet_information
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Konfigurasi Firebase**:
    Pastikan file `firebase_options.dart` sudah terkonfigurasi dengan project Firebase kamu.
5.  **Jalankan aplikasi**:
    ```bash
    flutter run
    ```

---

## 📋 Progress Tugas Besar

- [x] Ide Bebas (Informasi Hewan)
- [x] Integrasi Firebase (Auth & Firestore)
- [x] Fitur CRUD (Selesai)
- [x] Implementasi Animasi (Hero Animation)
- [ ] Implementasi REST API (Next Phase)
- [ ] 7 Halaman Dinamis (4/7 Completed)
- [ ] Deploy PWA/APK

---

**Dibuat oleh:**
- Nama: [Nama Kamu]
- Project: pet_information (Tugas Besar Pemrograman Mobile)

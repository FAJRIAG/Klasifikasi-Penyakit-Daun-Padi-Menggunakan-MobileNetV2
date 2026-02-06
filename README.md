# 🌾 Klasifikasi Penyakit Daun Padi Menggunakan MobileNetV2

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![TensorFlow](https://img.shields.io/badge/TensorFlow-%23FF6F00.svg?style=for-the-badge&logo=TensorFlow&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google&logoColor=white)

Aplikasi mobile berbasis **Flutter** untuk mendeteksi penyakit pada daun padi secara real-time menggunakan model _Deep Learning_ **MobileNetV2** (TensorFlow Lite). Aplikasi ini juga dilengkapi dengan asisten cerdas berbasis **Google Gemini AI** untuk memberikan konsultasi dan solusi penanganan penyakit bagi petani.

## ✨ Fitur Utama

### 1. 🔍 Deteksi Penyakit Daun Padi
Menggunakan model *CNN MobileNetV2* yang telah dioptimasi (TFLite) untuk mendeteksi kondisi berikut dengan akurasi tinggi:
*   **BrownSpot** (Bercak Coklat)
*   **Hispa** (Hama Putih Palsu)
*   **LeafBlast** (Blas Daun)
*   **Healthy** (Tanaman Sehat)

### 2. 🤖 Konsultasi AI (Gemini 2.5 Flash)
Terintegrasi dengan Google Gemini AI untuk:
*   Memberikan konfirmasi diagnosis penyakit.
*   Menjelaskan gejala visual secara mendalam.
*   Memberikan saran penanganan dan pencegahan yang praktis bagi petani.
*   Fitur Chatbot interaktif untuk tanya jawab seputar pertanian.

### 3. 🛡️ Sistem Manajemen API Key Cerdas
*   **Rotasi Key Otomatis**: Mendukung penggunaan multiple API Keys untuk menghindari limit kuota (*Rate Limit*).
*   **Fallback Mechanism**: Jika satu key habis kuotanya, sistem otomatis beralih ke key cadangan tanpa mengganggu pengguna.

### 4. 📸 Fleksibilitas Input Gambar
*   Ambil foto langsung melalui **Kamera**.
*   Pilih foto dari **Galeri**.
*   *Pre-processing* otomatis (Crop & Resize) untuk hasil deteksi optimal.

---

## 🛠️ Teknologi yang Digunakan

*   **Frontend**: Flutter SDK (Dart)
*   **State Management**: Provider
*   **AI/ML Framework**:
    *   TensorFlow Lite (`tflite_flutter`) untuk inferensi offline model klasifikasi.
    *   Google Generative AI SDK (`google_generative_ai`) untuk fitur Chatbot & Analisis Lanjut.
*   **Image Processing**: `image` package.
*   **Environment Management**: `flutter_dotenv`.

---

## 🚀 Cara Instalasi & Menjalankan Aplikasi

### Prasyarat
*   Flutter SDK terinstal (Versi terbaru, minimal 3.7.0).
*   Android Studio / VS Code.
*   Perangkat Android fisik atau Emulator.

### Langkah-langkah

1.  **Clone Repository**
    ```bash
    git clone https://github.com/FAJRIAG/Klasifikasi-Penyakit-Daun-Padi-Menggunakan-MobileNetV2.git
    cd Klasifikasi-Penyakit-Daun-Padi-Menggunakan-MobileNetV2
    ```

2.  **Instal Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Environment (.env)**
    Buat file `.env` di root project dan tambahkan API Key Gemini Anda.
    
    Aplikasi ini mendukung satu atau banyak key (dipisahkan koma) untuk rotasi:

    ```env
    # Single Key
    GEMINI_API_KEY=AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxx

    # Multiple Keys (Recommended for stability)
    GEMINI_API_KEYS=AIzaSyDxxxx,AIzaSyDyyyy,AIzaSyDzzzz
    ```

4.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```

---

## 📂 Struktur Project

```
lib/
├── models/          # Model data (Prediction, DiseaseInfo, dll)
├── providers/       # State management (Provider)
├── screens/         # Tampilan UI (Home, Result, Chat, History)
├── services/        # Logika bisnis & API (TFLite, Gemini, ImageService)
├── main.dart        # Entry point aplikasi
assets/
├── models/          # File model .tflite dan labels.txt
├── images/          # Aset gambar aplikasi
├── .env             # File konfigurasi (TIDAK DI-UPLOAD KE GIT)
```

---

## 🧠 Detail Model AI

### Klasifikasi Gambar (Offline)
*   **Model Architecture**: MobileNetV2 (Quantized).
*   **Input Size**: 224x224 pixels.
*   **Normalization**: Pixel values normalized to [-1, 1].
*   **Output**: Probability distribution across 4 classes.

### Generative AI (Online)
*   **Model**: Gemini 2.5 Flash.
*   **Prompt Engineering**: System prompt khusus yang memposisikan AI sebagai "Pakar Patologi Tanaman Padi" dengan instruksi output Bahasa Indonesia yang ramah petani.

---

## 🤝 Kontribusi

Kontribusi selalu diterima! Silakan buat **Pull Request** atau buka **Issue** jika menemukan bug atau ingin menambahkan fitur baru.

1.  Fork project ini.
2.  Buat feature branch (`git checkout -b fitur-keren`).
3.  Commit perubahan Anda (`git commit -m 'Menambahkan fitur keren'`).
4.  Push ke branch (`git push origin fitur-keren`).
5.  Buat Pull Request.

---

## 📄 Lisensi

Project ini dilisensikan di bawah [MIT License](LICENSE).

---

**Dikembangkan oleh [Fajri Ghurri]**

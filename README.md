# logbook_app_001

A new Flutter project.

## Getting Started
# Self-Reflection: Task 1 & 2, homework

**Pertanyaan:** Bagaimana prinsip SRP membantu kalian saat harus menambah fitur History Logger tadi?

**Jawaban:**
Prinsip SRP (Single Responsibility Principle) sangat membantu karena adanya pemisahan yang jelas antara logika data dan tampilan UI:
1. **Modifikasi Terfokus**: Saat saya perlu menambah logika pencatatan riwayat, saya hanya perlu mengedit file `CounterController`. Saya tidak perlu pusing memikirkan bagaimana cara menampilkannya di layar saat sedang menulis logika `insert` dan `removeLast`.
2. **UI yang Bersih**: Di file `CounterView`, saya cukup memanggil `_controller.history`. UI tidak perlu tahu bagaimana cara data itu disimpan atau dibatasi jumlahnya menjadi 5; UI hanya bertugas menggambar data yang sudah disediakan.
3. **Mudah Debugging**: Jika ada kesalahan pada teks riwayat, saya tahu persis harus mencari di file Controller. Jika ada kesalahan warna, saya langsung menuju file View.

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

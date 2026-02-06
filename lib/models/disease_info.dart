/// Disease information model with symptoms and treatments
class DiseaseInfo {
  final String name;
  final String description;
  final String cause; // Penyebab
  final List<String> symptoms;
  final List<String> treatments; // Pengobatan/Penanganan
  final List<String> prevention; // Pencegahan
  final String severity;
  
  DiseaseInfo({
    required this.name,
    required this.description,
    required this.cause,
    required this.symptoms,
    required this.treatments,
    required this.prevention,
    required this.severity,
  });
  
  /// Static database of disease information in Indonesian
  static final Map<String, DiseaseInfo> database = {
    // --- BROWN SPOT (BERCAK COKLAT) ---
    'BrownSpot': DiseaseInfo(
      name: 'Brown Spot (Bercak Coklat)',
      description: 'Penyakit yang sering disebut "penyakit tanah kurus". Biasanya muncul di lahan yang tanahnya kurang subur, kekurangan Kalium, atau drainase buruk.',
      cause: 'Jamur *Bipolaris oryzae*. Dipicu oleh kekurangan unsur hara (terutama Kalium dan Silika) dan kondisi tanah yang masam atau terlalu kering.',
      symptoms: [
        'Bercak oval seukuran biji wijen di daun, berwarna coklat dengan titik tengah abu-abu.',
        'Daun tampak "kurus" dan menguning sebelum waktunya.',
        'Pada fase generatif, menyerang bulir padi menyebabkan kulit gabah bernoda hitam ("gabah kusam") dan hampa.',
        'Sering terjadi pada bibit tanaman di persemaian yang kurang terurus.',
      ],
      treatments: [
        'SEGERA berikan pupuk Kalium (KCL) untuk memperkuat daun.',
        'Semprot fungisida berbahan aktif: Difenokonazol, Propikonazol, atau Mancozeb.',
        'Perbaiki saluran air, jangan biarkan sawah kekeringan terus-menerus.',
        'Tambahkan pupuk organik atau kapur dolomit jika tanah terlalu masam.',
      ],
      prevention: [
        'Lakukan pemupukan berimbang (Urea, SP-36, KCL) sesuai anjuran dinas setempat.',
        'Gunakan benih unggul yang sudah dibilas fungisida sebelum semai.',
        'Pendam jerami sisa panen (jangan dibakar) dan beri dekomposer agar tanah lebih subur.',
        'Rotasi tanaman dengan palawija untuk memutus siklus jamur.',
      ],
      severity: 'Sedang (Bisa menurunkan kualitas beras)',
    ),

    // --- HISPA (HAMA PUTIH/KUMBANG) ---
    'Hispa': DiseaseInfo(
      name: 'Rice Hispa (Hama Putih/Kumbang)',
      description: 'Serangan hama kumbang berduri. Daun terlihat memutih dan kering seperti terbakar karena jaringan hijaunya dimakan.',
      cause: 'Kumbang *Dicladispa armigera*. Kumbang dewasa memakan permukaan daun, larvanya menggerek masuk ke dalam daging daun.',
      symptoms: [
        'Terdapat garis-garis putih transparan pada daun yang sejajar dengan tulang daun.',
        'Ujung daun mengering dan memutih (efek "minings").',
        'Jika dilihat dekat, ada bekas gigitan memanjang.',
        'Pada serangan hebat, hamparan sawah terlihat putih seperti habis terbakar.',
      ],
      treatments: [
        'Lakukan penyemprotan insektisida sistemik berbahan aktif: Kartap Hidroklorida, Dimehipo, atau Fipronil.',
        'Pangkas ujung daun bibit yang mengandung telur/larva sebelum pindah tanam.',
        'Jika masih sedikit, kumbang bisa dipungut manual menggunakan jaring pada pagi hari.',
      ],
      prevention: [
        'Bersihkan gulma "rumput-rumputan" di pematang sawah yang sering jadi sarang.',
        'Jangan memupuk Urea (Nitrogen) berlebihan karena membuat daun lunak dan disukai kumbang.',
        'Pasang perangkap lampu (Light Trap) di malam hari untuk menangkap induk kumbang.',
        'Jaga jarak tanam, gunakan sistem tegel atau jajar legowo agar tidak terlalu rimbun.',
      ],
      severity: 'Sedang-Tinggi (Berbahaya di fase vegetatif)',
    ),

    // --- LEAF BLAST (BLAST DAUN) ---
    'LeafBlast': DiseaseInfo(
      name: 'Leaf Blast (Blast Daun)',
      description: 'Penyakit "Potong Leher" atau "Patah Leher" pada fase lanjut. Salah satu penyakit paling mematikan bagi padi, penyebarannya lewat angin.',
      cause: 'Jamur *Pyricularia oryzae*. Sangat ganas saat cuaca mendung/gerimis terus-menerus, kelembaban tinggi, dan penggunaan pupuk Urea berlebihan.',
      symptoms: [
        'Bercak berbentuk belah ketupat (seperti mata) dengan ujung runcing.',
        'Tengah bercak berwarna putih/abu-abu, pinggirnya coklat kemerahan.',
        'Bercak bisa membesar dan menyatu membuat daun hangus dan mati.',
        'Jika menyerang tangkai malai, malai akan busuk leher dan patah (gabah hampa total).',
      ],
      treatments: [
        'HENTIKAN sementara pupuk Urea/Nitrogen saat gejala muncul.',
        'Semprot fungisida spesifik Blast: Trisiklasol (paling efektif), Isoprotiolan, atau Piraklostrobin.',
        'Lakukan penyemprotan pagi hari setelah embun kering.',
        'Genangi sawah dengan air (jangan dikeringkan) untuk menghambat spora.',
      ],
      prevention: [
        'Wajib tanam varietas tahan Blast (misal: Inpari 32, Inpari 42) terutama di musim hujan.',
        'Hindari tanam padi terus menerus tanpa jeda (lakukan pergiliran varietas).',
        'Gunakan pupuk Silika (Si) untuk memperkeras batang dan daun.',
        'Rendam benih dengan fungisida (seed treatment) sebelum semai.',
      ],
      severity: 'Sangat Tinggi (Bisa gagal panen)',
    ),

    // --- HEALTHY (SEHAT) ---
    'Healthy': DiseaseInfo(
      name: 'Tanaman Sehat',
      description: 'Kondisi pertanaman padi ideal. Potensi hasil maksimal jika dipertahankan sampai panen.',
      cause: 'Manajemen lahan yang baik, pemupukan berimbang, dan pengairan yang tepat.',
      symptoms: [
        'Daun berwarna hijau royo-royo (segar) namun tegak kaku (tidak terkulai).',
        'Helaian daun bersih mulus tanpa bercak jamur atau gigitan hama.',
        'Anakan produktif banyak dan seragam.',
        'Batang kokoh dan tidak mudah rebah.',
      ],
      treatments: [
        'Pertahankan ketinggian air "macak-macak" (lembab basah).',
        'Lanjutkan pemupukan susulan (KCL/NPK) sesuai fase umur.',
        'Lakukan pengamatan rutin (keliling sawah) setiap pagi.',
      ],
      prevention: [
        'Tetap waspada perubahan cuaca ekstrem.',
        'Jaga kebersihan pematang dari gulma.',
        'Berikan nutrisi pelengkap (PPC) jika diperlukan untuk memaksimalkan bobot gabah.',
      ],
      severity: 'Aman - Siap Panen',
    ),
  };
  
  /// Get disease information by class name
  static DiseaseInfo? getInfo(String className) {
    // Extract disease name from class (e.g., "Tomato___Late_Blight" -> "Late_Blight")
    final parts = className.split('___');
    final diseaseName = parts.length > 1 ? parts[1] : className;
    
    return database[diseaseName];
  }
}

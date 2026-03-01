# 🎯 Okey 101 Asistanı

Android & iOS için offline Okey 101 asistanı. Yapay zeka API'si yok — tamamen deterministik, kural bazlı motor.

---

## 🚀 Kurulum

### Gereksinimler
- Flutter 3.22+ (stable channel)
- Dart 3.4+
- Android Studio veya Xcode

### Adımlar
```bash
# 1. Bağımlılıkları yükle
flutter pub get

# 2. Kod üretimi (Hive adapters, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Android'de çalıştır
flutter run -d android

# 4. iOS'ta çalıştır
cd ios && pod install && cd ..
flutter run -d ios
```

---

## 🏗 Mimari

```
lib/
├── core/           # Tema, sabitler, router
├── engine/         # Analiz motoru (pure Dart, test edilebilir)
│   ├── models/     # Tile, AnalysisResult, vb.
│   ├── analyzer.dart        # Ana orkestratör
│   ├── set_finder.dart      # Per algoritması
│   ├── run_finder.dart      # Seri algoritması
│   ├── joker_resolver.dart  # Joker DP
│   ├── pair_evaluator.dart  # Çifte modu
│   └── risk_calculator.dart # Risk skoru
├── vision/         # Kamera + TFLite (ileriki faz)
├── data/           # Hive depolama, repository
├── providers/      # Riverpod state management
└── ui/
    ├── screens/    # 4 ana ekran
    └── widgets/    # TileWidget, ScoreBoard, vb.
```

---

## 🧪 Test

```bash
# Tüm testleri çalıştır
flutter test

# Sadece engine testleri
flutter test test/engine/

# Coverage raporu
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📱 Ekranlar

| Sekme | Ekran | Açıklama |
|-------|-------|----------|
| 📷 ANALİZ | CameraScreen | Kamera ile taş tespiti ve anlık analiz |
| ✏️ MANUEL | ManualScreen | Elle taş girişi |
| 📊 SONUÇ | ResultScreen | Dizilim önerileri, risk skoru |
| 🎮 OYUN | GameScreen | Çok oyunculu puan takibi |

---

## 🎲 Okey Kuralları (Desteklenen)

- ✅ Per: Aynı sayı, farklı renk, minimum 3
- ✅ Seri: Aynı renk, ardışık sayı, minimum 3
- ✅ 101 açılış sistemi
- ✅ Joker (Okey) davranışı
- ✅ Sahte Okey
- ✅ Çifte gitme (5 çift)
- ✅ Açılmış oyuncu sonrası kural değişikliği

---

## 💰 Gelir Modeli

- `google_mobile_ads` paketi ile AdMob
- Banner: Tüm ekranlar alt kısmı
- Interstitial: Her 3 el sonunda
- Premium: `in_app_purchase` ile ₺49.99 tek seferlik

---

## 📋 TODO (Sonraki Fazlar)

- [ ] Gerçek kamera entegrasyonu (camera paketi)
- [ ] TFLite model eğitimi ve entegrasyonu
- [ ] OpenCV preprocessing pipeline
- [ ] AdMob production ID'leri
- [ ] Hive ile oyun geçmişi persist
- [ ] Konfeti animasyonu (Lottie)
- [ ] App Store / Play Store yayın

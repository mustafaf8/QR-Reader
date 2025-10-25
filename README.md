# 📱 QR Okuyucu (QR Reader)

Gelişmiş QR kod tarama yetenekleri, çok dilli destek, tema yönetimi ve kapsamlı geçmiş takibi ile güçlü bir Flutter QR kod okuyucu uygulaması.

## ✨ Özellikler

### 🔍 **QR Kod Tarama**

- **Gerçek zamanlı tarama** kamera entegrasyonu ile
- **Çoklu QR kod türleri** desteği (URL, WiFi, İletişim, SMS, vb.)
- **Akıllı ayrıştırma** farklı veri formatları için
- **Tek seferlik tarama** otomatik kamera durdurma ile
- **Responsive tarama alanı** tüm cihaz boyutlarında optimize

### 📶 **WiFi QR Kod Desteği**

- **Otomatik WiFi algılama** QR kodlardan
- **SSID çıkarma** ve görüntüleme
- **Şifre ayrıştırma** güvenli maskeleme ile
- **Çoklu kopyalama seçenekleri** (şifre, ham veri, WiFi bilgileri)
- **Kolay WiFi bağlantı** bilgileri

### 📊 **Tarama Geçmişi**

- **Yerel depolama** Hive veritabanı ile
- **Arama ve filtreleme** işlevselliği
- **Dışa aktarma yetenekleri** tarama verileri için
- **Detaylı tarama bilgileri** zaman damgaları ile
- **Favoriler sistemi** önemli taramaları kaydetme

### 🎨 **Tema Yönetimi**

- **Çoklu renk temaları** (Mavi, Yeşil, Mor, Turuncu, Kırmızı)
- **Tema modları** (Açık, Koyu, Sistem)
- **Dinamik renk uyumu** tüm UI bileşenlerinde
- **Kullanıcı tercihleri** kalıcı kaydetme

### 🌐 **Çok Dilli Destek**

- **3 dil desteği** (Türkçe, İngilizce, İspanyolca)
- **Tam yerelleştirme** tüm UI metinleri
- **Dinamik dil değiştirme** uygulama içinde
- **Responsive metin boyutları** farklı dillerde

### 📱 **QR Kod Oluşturma**

- **İletişim kartları** (vCard formatında)
- **Takvim etkinlikleri** (vEvent formatında)
- **WiFi ağları** (otomatik QR kod oluşturma)
- **Genel barkodlar** (özel veri girişi)
- **Canlı önizleme** oluşturma sırasında

### 🔧 **Gelişmiş Özellikler**

- **Responsive tasarım** tüm cihaz boyutlarında
- **Akıllı metin taşma önleme** uzun içeriklerde
- **Merkezi hata yönetimi** tutarlı kullanıcı deneyimi
- **Ortak yardımcı fonksiyonlar** kod tekrarını önleme
- **Performans optimizasyonu** hızlı ve akıcı kullanım

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK (3.0.0 veya üzeri)
- Dart SDK (2.17.0 veya üzeri)
- Android Studio / VS Code
- Android/iOS cihaz veya emülatör

### Kurulum Adımları

1. **Depoyu klonlayın**

   ```bash
   git clone https://github.com/yourusername/qr-okuyucu.git
   cd qr-okuyucu
   ```

2. **Bağımlılıkları yükleyin**

   ```bash
   flutter pub get
   ```

3. **Hive adaptörlerini oluşturun**

   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Yerelleştirme dosyalarını oluşturun**

   ```bash
   flutter gen-l10n
   ```

5. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 📱 Desteklenen QR Kod Türleri

| Tür          | Format                                   | Açıklama                      |
| ------------ | ---------------------------------------- | ----------------------------- |
| **URL**      | `https://example.com`                    | Web adresleri                 |
| **WiFi**     | `WIFI:S:SSID;T:WPA;P:password;H:false;;` | WiFi ağ kimlik bilgileri      |
| **E-posta**  | `mailto:user@example.com`                | E-posta adresleri             |
| **Telefon**  | `tel:+1234567890`                        | Telefon numaraları            |
| **SMS**      | `sms:+1234567890:message`                | SMS mesajları                 |
| **Konum**    | `geo:lat,lng`                            | GPS koordinatları             |
| **İletişim** | `BEGIN:VCARD...`                         | vCard iletişim bilgileri      |
| **OTP**      | `otpauth://totp/...`                     | İki faktörlü kimlik doğrulama |
| **Kripto**   | `bitcoin:address`                        | Kripto para adresleri         |

## 🛠️ Teknik Detaylar

### **Mimari**

- **Flutter Framework** Material Design ile
- **Durum Yönetimi** StatefulWidget ile
- **Yerel Depolama** Hive veritabanı ile
- **Kamera Entegrasyonu** mobile_scanner paketi ile
- **Tema Yönetimi** SharedPreferences ile
- **Yerelleştirme** flutter_localizations ile

### **Ana Paketler**

- `mobile_scanner: ^7.1.3` - QR kod tarama
- `hive: ^2.2.3` - Yerel veritabanı
- `url_launcher: ^6.3.1` - URL işleme
- `share_plus: ^10.0.2` - İçerik paylaşma
- `path_provider: ^2.1.4` - Dosya sistemi erişimi
- `barcode_widget: ^2.2.0` - QR kod oluşturma
- `image_picker: ^1.1.2` - Resim seçme
- `intl: ^0.19.0` - Tarih/saat formatlama

### **Proje Yapısı**

```
lib/
├── main.dart                    # Ana uygulama giriş noktası
├── models/
│   └── qr_scan_model.dart      # QR tarama veri modeli
├── screens/
│   ├── home_screen.dart         # Ana ekran
│   ├── qr_scanner_screen.dart   # QR tarama ekranı
│   ├── scan_history_screen.dart # Tarama geçmişi
│   ├── favorites_screen.dart    # Favoriler
│   ├── settings_screen.dart     # Ayarlar
│   ├── image_scan_screen.dart   # Resim tarama
│   └── create/                  # QR kod oluşturma ekranları
│       ├── create_qr_screen.dart
│       ├── create_contact_screen.dart
│       ├── create_calendar_screen.dart
│       ├── create_wifi_screen.dart
│       └── create_generic_barcode_screen.dart
├── services/
│   ├── hive_service.dart        # Veritabanı işlemleri
│   ├── theme_service.dart       # Tema yönetimi
│   ├── common_helpers.dart      # Ortak yardımcı fonksiyonlar
│   └── error_service.dart       # Hata yönetimi
├── providers/
│   └── locale_provider.dart     # Dil yönetimi
└── l10n/                        # Yerelleştirme dosyaları
    ├── app_en.arb
    ├── app_tr.arb
    ├── app_es.arb
    └── app_localizations.dart
```

## 🎨 Tema Sistemi

### **Renk Temaları**

- **Mavi** - Varsayılan profesyonel tema
- **Yeşil** - Doğa dostu tema
- **Mor** - Yaratıcı ve modern tema
- **Turuncu** - Enerjik ve canlı tema
- **Kırmızı** - Dikkat çekici tema

### **Tema Modları**

- **Açık Tema** - Klasik açık renkler
- **Koyu Tema** - Göz yormayan koyu renkler
- **Sistem Tema** - Cihaz ayarlarına uyum

## 🌍 Dil Desteği

### **Desteklenen Diller**

- **Türkçe** (TR) - Ana dil
- **İngilizce** (EN) - Uluslararası kullanım
- **İspanyolca** (ES) - Genişletilmiş erişim

### **Yerelleştirilmiş Özellikler**

- Tüm UI metinleri
- Hata mesajları
- Bildirimler
- Tarih/saat formatları
- QR kod türleri

## 🔒 İzinler

### Android

- `CAMERA` - QR kod tarama için
- `INTERNET` - URL açma için
- `READ_EXTERNAL_STORAGE` - Resim seçme için
- `WRITE_EXTERNAL_STORAGE` - Dosya kaydetme için

### iOS

- Kamera erişim izni
- Resim galerisi erişim izni
- Ağ erişimi URL açma için

## 📸 Ekran Görüntüleri

_Ekran görüntüleri buraya eklenecek_

## 🚀 Gelecek Özellikler

- [ ] **Toplu QR kod oluşturma** - Çoklu veri girişi
- [ ] **QR kod şablonları** - Hızlı oluşturma
- [ ] **Bulut senkronizasyonu** - Veri yedekleme
- [ ] **QR kod analizi** - Detaylı istatistikler
- [ ] **Widget desteği** - Ana ekran widget'ı
- [ ] **Otomatik yedekleme** - Zamanlanmış yedekleme

## 🤝 Katkıda Bulunma

1. Depoyu fork edin
2. Özellik dalınızı oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Dalınıza push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🙏 Teşekkürler

- Flutter ekibi harika framework için
- mobile_scanner paketi geliştiricileri
- Hive veritabanı ekibi
- Tüm katkıda bulunanlar ve test edenler

## 📞 Destek

Herhangi bir sorunla karşılaştığınızda veya sorularınız olduğunda:

1. [Issues](https://github.com/yourusername/qr-okuyucu/issues) sayfasını kontrol edin
2. Detaylı bilgi ile yeni bir issue oluşturun
3. Cihaz bilgileri ve hata loglarını ekleyin

---

**Flutter ile ❤️ ile yapıldı**

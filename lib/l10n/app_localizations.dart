import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('tr'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @scanQrCode.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Tara'**
  String get scanQrCode;

  /// No description provided for @scanHistory.
  ///
  /// In tr, this message translates to:
  /// **'Tarama Geçmişi'**
  String get scanHistory;

  /// No description provided for @favorites.
  ///
  /// In tr, this message translates to:
  /// **'Sık Kullanılanlar'**
  String get favorites;

  /// No description provided for @createQrCode.
  ///
  /// In tr, this message translates to:
  /// **'QR Oluştur'**
  String get createQrCode;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @colorTheme.
  ///
  /// In tr, this message translates to:
  /// **'Renk Teması'**
  String get colorTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçin'**
  String get selectLanguage;

  /// No description provided for @galleryScan.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden QR Tara'**
  String get galleryScan;

  /// No description provided for @scanFromGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Seç'**
  String get scanFromGallery;

  /// No description provided for @homeScreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Okuyucu'**
  String get homeScreenTitle;

  /// No description provided for @homeScreenSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'QR kodları ve barkodları kolayca tarayın'**
  String get homeScreenSubtitle;

  /// No description provided for @view.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get view;

  /// No description provided for @appInfo.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Bilgisi'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon'**
  String get version;

  /// No description provided for @license.
  ///
  /// In tr, this message translates to:
  /// **'Lisans'**
  String get license;

  /// No description provided for @selectColorTheme.
  ///
  /// In tr, this message translates to:
  /// **'Renk Teması Seç'**
  String get selectColorTheme;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In tr, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @myQrCodes.
  ///
  /// In tr, this message translates to:
  /// **'QR Kodlarım'**
  String get myQrCodes;

  /// No description provided for @imageScan.
  ///
  /// In tr, this message translates to:
  /// **'Resim Tara'**
  String get imageScan;

  /// No description provided for @scanFromImage.
  ///
  /// In tr, this message translates to:
  /// **'Resimden Tara'**
  String get scanFromImage;

  /// No description provided for @createWifi.
  ///
  /// In tr, this message translates to:
  /// **'WiFi QR Oluştur'**
  String get createWifi;

  /// No description provided for @createText.
  ///
  /// In tr, this message translates to:
  /// **'Metin Oluştur'**
  String get createText;

  /// No description provided for @createUrl.
  ///
  /// In tr, this message translates to:
  /// **'URL Oluştur'**
  String get createUrl;

  /// No description provided for @createEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Oluştur'**
  String get createEmail;

  /// No description provided for @createSms.
  ///
  /// In tr, this message translates to:
  /// **'SMS Oluştur'**
  String get createSms;

  /// No description provided for @createPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Oluştur'**
  String get createPhone;

  /// No description provided for @createContact.
  ///
  /// In tr, this message translates to:
  /// **'Kişi QR Oluştur'**
  String get createContact;

  /// No description provided for @createEvent.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Oluştur'**
  String get createEvent;

  /// No description provided for @createLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum Oluştur'**
  String get createLocation;

  /// No description provided for @scanResult.
  ///
  /// In tr, this message translates to:
  /// **'Tarama Sonucu'**
  String get scanResult;

  /// No description provided for @copy.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @addToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere Ekle'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden Çıkar'**
  String get removeFromFavorites;

  /// No description provided for @noHistory.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tarama geçmişi yok'**
  String get noHistory;

  /// No description provided for @noFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori yok'**
  String get noFavorites;

  /// No description provided for @noQrCodes.
  ///
  /// In tr, this message translates to:
  /// **'Henüz QR kod oluşturulmamış'**
  String get noQrCodes;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @open.
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get open;

  /// No description provided for @statistics.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statistics;

  /// No description provided for @export.
  ///
  /// In tr, this message translates to:
  /// **'Dışa Aktar'**
  String get export;

  /// No description provided for @removeDuplicates.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarları Kaldır'**
  String get removeDuplicates;

  /// No description provided for @deleteAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Sil'**
  String get deleteAll;

  /// No description provided for @removeFromFavoritesConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sık kullanılanlardan çıkarıldı'**
  String get removeFromFavoritesConfirm;

  /// No description provided for @deleteAllFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Sık Kullanılanları Sil'**
  String get deleteAllFavorites;

  /// No description provided for @deleteAllFavoritesConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm sık kullanılanları silmek istediğinizden emin misiniz?'**
  String get deleteAllFavoritesConfirm;

  /// No description provided for @allFavoritesDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm sık kullanılanlar silindi'**
  String get allFavoritesDeleted;

  /// No description provided for @deleteError.
  ///
  /// In tr, this message translates to:
  /// **'Silme hatası'**
  String get deleteError;

  /// No description provided for @urlOpenFeature.
  ///
  /// In tr, this message translates to:
  /// **'URL açma özelliği'**
  String get urlOpenFeature;

  /// No description provided for @historyLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yüklenirken hata'**
  String get historyLoadError;

  /// No description provided for @deleteScanConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu taramayı silmek istediğinizden emin misiniz?'**
  String get deleteScanConfirm;

  /// No description provided for @addedToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Sık kullanılanlara eklendi'**
  String get addedToFavorites;

  /// No description provided for @duplicatesRemoved.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar eden taramalar kaldırıldı'**
  String get duplicatesRemoved;

  /// No description provided for @removeDuplicatesError.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarları kaldırma hatası'**
  String get removeDuplicatesError;

  /// No description provided for @deleteAllScans.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Taramaları Sil'**
  String get deleteAllScans;

  /// No description provided for @deleteAllScansConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm tarama geçmişini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'**
  String get deleteAllScansConfirm;

  /// No description provided for @allScansDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm taramalar silindi'**
  String get allScansDeleted;

  /// No description provided for @historyCopiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Tarama geçmişi panoya kopyalandı'**
  String get historyCopiedToClipboard;

  /// No description provided for @exportError.
  ///
  /// In tr, this message translates to:
  /// **'Dışa aktarma hatası'**
  String get exportError;

  /// No description provided for @statisticsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statisticsTitle;

  /// No description provided for @noPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre yok'**
  String get noPassword;

  /// No description provided for @contactQrCode.
  ///
  /// In tr, this message translates to:
  /// **'Kişi QR Kodu'**
  String get contactQrCode;

  /// No description provided for @wifiPassword.
  ///
  /// In tr, this message translates to:
  /// **'WiFi şifresi panoya kopyalandı'**
  String get wifiPassword;

  /// No description provided for @searchHistory.
  ///
  /// In tr, this message translates to:
  /// **'Tarama geçmişinde ara...'**
  String get searchHistory;

  /// No description provided for @all.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get all;

  /// No description provided for @noScansYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tarama yapılmamış'**
  String get noScansYet;

  /// No description provided for @startScanning.
  ///
  /// In tr, this message translates to:
  /// **'QR kod taramaya başlayın!'**
  String get startScanning;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @removeFromFavoritesAction.
  ///
  /// In tr, this message translates to:
  /// **'Sık kullanılanlardan çıkar'**
  String get removeFromFavoritesAction;

  /// No description provided for @addToFavoritesAction.
  ///
  /// In tr, this message translates to:
  /// **'Sık kullanılanlara ekle'**
  String get addToFavoritesAction;

  /// No description provided for @noPasswordText.
  ///
  /// In tr, this message translates to:
  /// **'Şifre yok'**
  String get noPasswordText;

  /// No description provided for @hiddenPassword.
  ///
  /// In tr, this message translates to:
  /// **'GİZLİ'**
  String get hiddenPassword;

  /// No description provided for @content.
  ///
  /// In tr, this message translates to:
  /// **'İçerik'**
  String get content;

  /// No description provided for @wifiPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'WiFi Şifresi'**
  String get wifiPasswordLabel;

  /// No description provided for @urlScan.
  ///
  /// In tr, this message translates to:
  /// **'URL Taraması'**
  String get urlScan;

  /// No description provided for @firstScan.
  ///
  /// In tr, this message translates to:
  /// **'İlk Tarama'**
  String get firstScan;

  /// No description provided for @typeDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Tip Dağılımı'**
  String get typeDistribution;

  /// No description provided for @clearAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Temizle'**
  String get clearAll;

  /// No description provided for @noFavoritesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz sık kullanılan yok'**
  String get noFavoritesYet;

  /// No description provided for @addFavoritesHint.
  ///
  /// In tr, this message translates to:
  /// **'Tarama geçmişinden yıldız ikonuna tıklayarak\nsık kullanılanlara ekleyebilirsiniz'**
  String get addFavoritesHint;

  /// No description provided for @removeFromFavoritesTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Sık kullanılanlardan çıkar'**
  String get removeFromFavoritesTooltip;

  /// No description provided for @copiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Panoya kopyalandı'**
  String get copiedToClipboard;

  /// No description provided for @favoriteDetail.
  ///
  /// In tr, this message translates to:
  /// **'Sık Kullanılan Detayı'**
  String get favoriteDetail;

  /// No description provided for @dataContent.
  ///
  /// In tr, this message translates to:
  /// **'Veri İçeriği'**
  String get dataContent;

  /// No description provided for @description.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get description;

  /// No description provided for @openWebPage.
  ///
  /// In tr, this message translates to:
  /// **'Web Sayfasını Aç'**
  String get openWebPage;

  /// No description provided for @networkName.
  ///
  /// In tr, this message translates to:
  /// **'Ağ Adı'**
  String get networkName;

  /// No description provided for @passwordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get passwordLabel;

  /// No description provided for @alignQrCode.
  ///
  /// In tr, this message translates to:
  /// **'QR kodu kare alan içine hizalayın'**
  String get alignQrCode;

  /// No description provided for @dataInput.
  ///
  /// In tr, this message translates to:
  /// **'Veri Girişi'**
  String get dataInput;

  /// No description provided for @preview.
  ///
  /// In tr, this message translates to:
  /// **'Önizleme'**
  String get preview;

  /// No description provided for @invalidDataFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz veri formatı'**
  String get invalidDataFormat;

  /// No description provided for @downloadsFolderNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Downloads klasörü bulunamadı'**
  String get downloadsFolderNotFound;

  /// No description provided for @creationDate.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturulma Tarihi'**
  String get creationDate;

  /// No description provided for @saveError.
  ///
  /// In tr, this message translates to:
  /// **'Kaydetme hatası'**
  String get saveError;

  /// No description provided for @shareError.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım hatası'**
  String get shareError;

  /// No description provided for @qrCodeDataShared.
  ///
  /// In tr, this message translates to:
  /// **'QR kod verisi paylaşıldı'**
  String get qrCodeDataShared;

  /// No description provided for @eventTitle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Başlığı'**
  String get eventTitle;

  /// No description provided for @enterEventName.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik adını girin'**
  String get enterEventName;

  /// No description provided for @eventDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get eventDescription;

  /// No description provided for @enterEventDescription.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik açıklaması'**
  String get enterEventDescription;

  /// No description provided for @organizer.
  ///
  /// In tr, this message translates to:
  /// **'Organizatör'**
  String get organizer;

  /// No description provided for @startDate.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get endDate;

  /// No description provided for @startTime.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Saati'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Saati'**
  String get endTime;

  /// No description provided for @location.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get location;

  /// No description provided for @enterLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum girin'**
  String get enterLocation;

  /// No description provided for @qrCodeGenerated.
  ///
  /// In tr, this message translates to:
  /// **'QR kod oluşturuldu'**
  String get qrCodeGenerated;

  /// No description provided for @eventQrCode.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik QR Kodu'**
  String get eventQrCode;

  /// No description provided for @organizerInfo.
  ///
  /// In tr, this message translates to:
  /// **'Organizatör bilgisi'**
  String get organizerInfo;

  /// No description provided for @start.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get start;

  /// No description provided for @startTimeTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç saati'**
  String get startTimeTooltip;

  /// No description provided for @end.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get end;

  /// No description provided for @endTimeTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş saati'**
  String get endTimeTooltip;

  /// No description provided for @qrCodePreview.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Önizlemesi'**
  String get qrCodePreview;

  /// No description provided for @enterEventTitle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik başlığı girin'**
  String get enterEventTitle;

  /// No description provided for @invalidEventInfo.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz etkinlik bilgisi'**
  String get invalidEventInfo;

  /// No description provided for @aboutEventQrCode.
  ///
  /// In tr, this message translates to:
  /// **'vEvent bilgi kartı'**
  String get aboutEventQrCode;

  /// No description provided for @eventQrCodeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu QR kodu tarayan kişiler otomatik olarak etkinliği takvimlerine ekleyebilir. Etkinlik başlığı zorunludur.'**
  String get eventQrCodeDescription;

  /// No description provided for @eventQrCodeShared.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik QR kodu paylaşıldı'**
  String get eventQrCodeShared;

  /// No description provided for @title.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get title;

  /// No description provided for @qrCodeInfo.
  ///
  /// In tr, this message translates to:
  /// **'QR kodlar herhangi bir metin, URL, telefon numarası veya diğer veri türlerini içerebilir.'**
  String get qrCodeInfo;

  /// No description provided for @ean13Info.
  ///
  /// In tr, this message translates to:
  /// **'EAN-13 kodu tam olarak 12 haneli sayı olmalıdır. Son hane otomatik hesaplanır.'**
  String get ean13Info;

  /// No description provided for @ean8Info.
  ///
  /// In tr, this message translates to:
  /// **'EAN-8 kodu tam olarak 7 haneli sayı olmalıdır. Son hane otomatik hesaplanır.'**
  String get ean8Info;

  /// No description provided for @upcAInfo.
  ///
  /// In tr, this message translates to:
  /// **'UPC-A kodu tam olarak 11 haneli sayı olmalıdır. Son hane otomatik hesaplanır.'**
  String get upcAInfo;

  /// No description provided for @upcEInfo.
  ///
  /// In tr, this message translates to:
  /// **'UPC-E kodu tam olarak 6 haneli sayı olmalıdır.'**
  String get upcEInfo;

  /// No description provided for @code39Info.
  ///
  /// In tr, this message translates to:
  /// **'CODE-39 sadece büyük harfler, sayılar ve bazı özel karakterleri destekler.'**
  String get code39Info;

  /// No description provided for @code93Info.
  ///
  /// In tr, this message translates to:
  /// **'CODE-93 gelişmiş alfanumerik karakter desteği sunar.'**
  String get code93Info;

  /// No description provided for @code128Info.
  ///
  /// In tr, this message translates to:
  /// **'CODE-128 yüksek yoğunluklu veri depolama sağlar.'**
  String get code128Info;

  /// No description provided for @itfInfo.
  ///
  /// In tr, this message translates to:
  /// **'ITF sadece sayısal karakterleri destekler.'**
  String get itfInfo;

  /// No description provided for @pdf417Info.
  ///
  /// In tr, this message translates to:
  /// **'PDF-417 iki boyutlu barkod formatıdır ve büyük miktarda veri saklayabilir.'**
  String get pdf417Info;

  /// No description provided for @codabarInfo.
  ///
  /// In tr, this message translates to:
  /// **'Codabar sadece sayısal karakterleri destekler.'**
  String get codabarInfo;

  /// No description provided for @dataMatrixInfo.
  ///
  /// In tr, this message translates to:
  /// **'Data Matrix iki boyutlu barkod formatıdır.'**
  String get dataMatrixInfo;

  /// No description provided for @aztecInfo.
  ///
  /// In tr, this message translates to:
  /// **'Aztec iki boyutlu barkod formatıdır.'**
  String get aztecInfo;

  /// No description provided for @unknownBarcodeInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bu barkod formatı hakkında bilgi mevcut değil.'**
  String get unknownBarcodeInfo;

  /// No description provided for @wifiNetwork.
  ///
  /// In tr, this message translates to:
  /// **'WiFi Ağı'**
  String get wifiNetwork;

  /// No description provided for @securityType.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Türü'**
  String get securityType;

  /// No description provided for @hiddenNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Gizli Ağ'**
  String get hiddenNetwork;

  /// No description provided for @hiddenNetworkDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu ağ SSID yayınlamıyor'**
  String get hiddenNetworkDescription;

  /// No description provided for @enterNetworkName.
  ///
  /// In tr, this message translates to:
  /// **'Ağ adını girin'**
  String get enterNetworkName;

  /// No description provided for @invalidWifiInfo.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz Wi-Fi bilgisi'**
  String get invalidWifiInfo;

  /// No description provided for @aboutWifiQrCode.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi QR Kodu Hakkında'**
  String get aboutWifiQrCode;

  /// No description provided for @wifiQrCodeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu QR kodu tarayan kişiler otomatik olarak Wi-Fi ağınıza bağlanabilir. Ağ adı (SSID) zorunludur. Şifreli ağlar için şifre de gereklidir.'**
  String get wifiQrCodeDescription;

  /// No description provided for @wifiQrCodeShared.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi QR kodu paylaşıldı'**
  String get wifiQrCodeShared;

  /// No description provided for @contactInfo.
  ///
  /// In tr, this message translates to:
  /// **'Kişi Bilgileri'**
  String get contactInfo;

  /// No description provided for @firstName.
  ///
  /// In tr, this message translates to:
  /// **'Adınız'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In tr, this message translates to:
  /// **'Soyadınız'**
  String get lastName;

  /// No description provided for @companyName.
  ///
  /// In tr, this message translates to:
  /// **'Şirket adı'**
  String get companyName;

  /// No description provided for @aboutContactQrCode.
  ///
  /// In tr, this message translates to:
  /// **'vCard bilgi kartı'**
  String get aboutContactQrCode;

  /// No description provided for @contactQrCodeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu QR kodu tarayan kişiler otomatik olarak kişi bilgilerinizi telefonlarına kaydedebilir. Ad veya soyad en az birinin girilmesi gereklidir.'**
  String get contactQrCodeDescription;

  /// No description provided for @contactQrCodeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kişi QR kodu kaydedildi'**
  String get contactQrCodeSaved;

  /// No description provided for @contactQrCodeShared.
  ///
  /// In tr, this message translates to:
  /// **'Kişi QR kodu paylaşıldı'**
  String get contactQrCodeShared;

  /// No description provided for @selectImageFromGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Resim Seç'**
  String get selectImageFromGallery;

  /// No description provided for @scanQrFromGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden bir görüntü seçerek QR kod tarayın'**
  String get scanQrFromGallery;

  /// No description provided for @notFound.
  ///
  /// In tr, this message translates to:
  /// **'bulunamadı'**
  String get notFound;

  /// No description provided for @errorSelectingImage.
  ///
  /// In tr, this message translates to:
  /// **'Hata: Resim seçilirken bir sorun oluştu'**
  String get errorSelectingImage;

  /// No description provided for @noQrCodeInImage.
  ///
  /// In tr, this message translates to:
  /// **'Bu resimde QR kod bulunamadı'**
  String get noQrCodeInImage;

  /// No description provided for @errorScanningQr.
  ///
  /// In tr, this message translates to:
  /// **'Hata: QR kod taranırken bir sorun oluştu'**
  String get errorScanningQr;

  /// No description provided for @contact.
  ///
  /// In tr, this message translates to:
  /// **'Kişi'**
  String get contact;

  /// No description provided for @urlCannotBeOpened.
  ///
  /// In tr, this message translates to:
  /// **'URL açılamadı'**
  String get urlCannotBeOpened;

  /// No description provided for @errorOpeningUrl.
  ///
  /// In tr, this message translates to:
  /// **'URL açılırken hata oluştu'**
  String get errorOpeningUrl;

  /// No description provided for @qrCodeScannedAndSaved.
  ///
  /// In tr, this message translates to:
  /// **'QR kod tarandı ve kaydedildi!'**
  String get qrCodeScannedAndSaved;

  /// No description provided for @qrCodeAlreadyScanned.
  ///
  /// In tr, this message translates to:
  /// **'Bu QR kod daha önce taranmış!'**
  String get qrCodeAlreadyScanned;

  /// No description provided for @wifiNetworkInfo.
  ///
  /// In tr, this message translates to:
  /// **'WiFi ağ bilgileri'**
  String get wifiNetworkInfo;

  /// No description provided for @openWebPageQuestion.
  ///
  /// In tr, this message translates to:
  /// **'QR kodda bir web adresi bulundu. Bu sayfayı açmak istiyor musuniz?'**
  String get openWebPageQuestion;

  /// No description provided for @urlCannotBeOpenedError.
  ///
  /// In tr, this message translates to:
  /// **'URL açılamadı'**
  String get urlCannotBeOpenedError;

  /// No description provided for @creationDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturulma Tarihi'**
  String get creationDateLabel;

  /// No description provided for @titleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Unvan'**
  String get titleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get descriptionLabel;

  /// No description provided for @organizerLabel.
  ///
  /// In tr, this message translates to:
  /// **'Organizatör'**
  String get organizerLabel;

  /// No description provided for @startDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get endDateLabel;

  /// No description provided for @contactInformation.
  ///
  /// In tr, this message translates to:
  /// **'Kişi Bilgileri'**
  String get contactInformation;

  /// No description provided for @firstNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Adınız'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Soyadınız'**
  String get lastNameHint;

  /// No description provided for @companyNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Şirket adı'**
  String get companyNameHint;

  /// No description provided for @invalidContactInfo.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz kişi bilgisi'**
  String get invalidContactInfo;

  /// No description provided for @networkNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ağ Adı (SSID)'**
  String get networkNameLabel;

  /// No description provided for @networkNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi ağ adınız'**
  String get networkNameHint;

  /// No description provided for @securityTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Türü'**
  String get securityTypeLabel;

  /// No description provided for @passwordHint.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi şifreniz'**
  String get passwordHint;

  /// No description provided for @hiddenNetworkLabel.
  ///
  /// In tr, this message translates to:
  /// **'Gizli Ağ'**
  String get hiddenNetworkLabel;

  /// No description provided for @noPasswordValue.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get noPasswordValue;

  /// No description provided for @yesValue.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yesValue;

  /// No description provided for @noValue.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get noValue;

  /// No description provided for @passwordPartRemoved.
  ///
  /// In tr, this message translates to:
  /// **'Şifre: kısmını çıkar'**
  String get passwordPartRemoved;

  /// No description provided for @qrCodeTypes.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Türleri'**
  String get qrCodeTypes;

  /// No description provided for @barcodeTypes.
  ///
  /// In tr, this message translates to:
  /// **'Barkod Türleri'**
  String get barcodeTypes;

  /// No description provided for @clipboardContent.
  ///
  /// In tr, this message translates to:
  /// **'Panodan İçerik'**
  String get clipboardContent;

  /// No description provided for @clipboardContentSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Panodaki metni QR koda dönüştür'**
  String get clipboardContentSubtitle;

  /// No description provided for @urlSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Web sitesi adresi oluştur'**
  String get urlSubtitle;

  /// No description provided for @plainText.
  ///
  /// In tr, this message translates to:
  /// **'Düz Metin'**
  String get plainText;

  /// No description provided for @plainTextSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Herhangi bir metin oluştur'**
  String get plainTextSubtitle;

  /// No description provided for @enterYourText.
  ///
  /// In tr, this message translates to:
  /// **'Metninizi buraya yazın'**
  String get enterYourText;

  /// No description provided for @wifiSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi ağ bilgileri oluştur'**
  String get wifiSubtitle;

  /// No description provided for @contactVcard.
  ///
  /// In tr, this message translates to:
  /// **'Kişi (vCard)'**
  String get contactVcard;

  /// No description provided for @contactVcardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İletişim bilgileri oluştur'**
  String get contactVcardSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresi'**
  String get emailAddress;

  /// No description provided for @emailAddressSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi oluştur'**
  String get emailAddressSubtitle;

  /// No description provided for @smsAddress.
  ///
  /// In tr, this message translates to:
  /// **'SMS Adresi'**
  String get smsAddress;

  /// No description provided for @smsAddressSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'SMS mesajı oluştur'**
  String get smsAddressSubtitle;

  /// No description provided for @messageBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınız'**
  String get messageBody;

  /// No description provided for @geographicCoordinates.
  ///
  /// In tr, this message translates to:
  /// **'Coğrafi Koordinatlar'**
  String get geographicCoordinates;

  /// No description provided for @geographicCoordinatesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konum bilgisi oluştur'**
  String get geographicCoordinatesSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Numarası'**
  String get phoneNumber;

  /// No description provided for @phoneNumberSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası oluştur'**
  String get phoneNumberSubtitle;

  /// No description provided for @calendarVevent.
  ///
  /// In tr, this message translates to:
  /// **'Takvim (vEvent)'**
  String get calendarVevent;

  /// No description provided for @calendarVeventSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik bilgileri oluştur'**
  String get calendarVeventSubtitle;

  /// No description provided for @ean8Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'8 haneli ürün kodu'**
  String get ean8Subtitle;

  /// No description provided for @createEan8.
  ///
  /// In tr, this message translates to:
  /// **'EAN-8 Oluştur'**
  String get createEan8;

  /// No description provided for @ean13Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'13 haneli ürün kodu'**
  String get ean13Subtitle;

  /// No description provided for @createEan13.
  ///
  /// In tr, this message translates to:
  /// **'EAN-13 Oluştur'**
  String get createEan13;

  /// No description provided for @upcESubtitle.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli UPC kodu'**
  String get upcESubtitle;

  /// No description provided for @createUpcE.
  ///
  /// In tr, this message translates to:
  /// **'UPC-E Oluştur'**
  String get createUpcE;

  /// No description provided for @upcASubtitle.
  ///
  /// In tr, this message translates to:
  /// **'12 haneli UPC kodu'**
  String get upcASubtitle;

  /// No description provided for @createUpcA.
  ///
  /// In tr, this message translates to:
  /// **'UPC-A Oluştur'**
  String get createUpcA;

  /// No description provided for @code39Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Alfanumerik kod'**
  String get code39Subtitle;

  /// No description provided for @createCode39.
  ///
  /// In tr, this message translates to:
  /// **'CODE-39 Oluştur'**
  String get createCode39;

  /// No description provided for @code93Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş alfanumerik kod'**
  String get code93Subtitle;

  /// No description provided for @createCode93.
  ///
  /// In tr, this message translates to:
  /// **'CODE-93 Oluştur'**
  String get createCode93;

  /// No description provided for @code128Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek yoğunluklu kod'**
  String get code128Subtitle;

  /// No description provided for @createCode128.
  ///
  /// In tr, this message translates to:
  /// **'CODE-128 Oluştur'**
  String get createCode128;

  /// No description provided for @itfInterleaved.
  ///
  /// In tr, this message translates to:
  /// **'ITF (Interleaved 2 of 5)'**
  String get itfInterleaved;

  /// No description provided for @itfSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sayısal kod'**
  String get itfSubtitle;

  /// No description provided for @createItf.
  ///
  /// In tr, this message translates to:
  /// **'ITF Oluştur'**
  String get createItf;

  /// No description provided for @pdf417Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'İki boyutlu barkod'**
  String get pdf417Subtitle;

  /// No description provided for @createPdf417.
  ///
  /// In tr, this message translates to:
  /// **'PDF-417 Oluştur'**
  String get createPdf417;

  /// No description provided for @pdf417Example.
  ///
  /// In tr, this message translates to:
  /// **'PDF417 örneği'**
  String get pdf417Example;

  /// No description provided for @codabarSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sayısal kod'**
  String get codabarSubtitle;

  /// No description provided for @createCodabar.
  ///
  /// In tr, this message translates to:
  /// **'Codabar Oluştur'**
  String get createCodabar;

  /// No description provided for @dataMatrixSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İki boyutlu barkod'**
  String get dataMatrixSubtitle;

  /// No description provided for @createDataMatrix.
  ///
  /// In tr, this message translates to:
  /// **'Data Matrix Oluştur'**
  String get createDataMatrix;

  /// No description provided for @dataMatrixExample.
  ///
  /// In tr, this message translates to:
  /// **'Data Matrix örneği'**
  String get dataMatrixExample;

  /// No description provided for @aztecSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İki boyutlu barkod'**
  String get aztecSubtitle;

  /// No description provided for @createAztec.
  ///
  /// In tr, this message translates to:
  /// **'Aztec Oluştur'**
  String get createAztec;

  /// No description provided for @aztecExample.
  ///
  /// In tr, this message translates to:
  /// **'Aztec örneği'**
  String get aztecExample;

  /// No description provided for @scanFromGalleryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden QR Tara'**
  String get scanFromGalleryTitle;

  /// No description provided for @scanFromGallerySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden bir görüntü seçerek QR kod tarayın'**
  String get scanFromGallerySubtitle;

  /// No description provided for @qrCodeFound.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Bulundu!'**
  String get qrCodeFound;

  /// No description provided for @powerfulQrReader.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü QR kod okuyucu'**
  String get powerfulQrReader;

  /// No description provided for @removeAds.
  ///
  /// In tr, this message translates to:
  /// **'Reklamları Kaldır'**
  String get removeAds;

  /// No description provided for @removeAdsFeature.
  ///
  /// In tr, this message translates to:
  /// **'Reklamları kaldır özelliği yakında eklenecek'**
  String get removeAdsFeature;

  /// No description provided for @myQrPage.
  ///
  /// In tr, this message translates to:
  /// **'QR Kodlarım'**
  String get myQrPage;

  /// No description provided for @featureComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik yakında gelecek'**
  String get featureComingSoon;

  /// No description provided for @pleaseEnsureBrowser.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen cihazınızda bir web tarayıcısı olduğundan emin olun.'**
  String get pleaseEnsureBrowser;

  /// No description provided for @urlCopiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'URL panoya kopyalandı'**
  String get urlCopiedToClipboard;

  /// No description provided for @urlOpenError.
  ///
  /// In tr, this message translates to:
  /// **'URL açma hatası'**
  String get urlOpenError;

  /// No description provided for @shareAppText.
  ///
  /// In tr, this message translates to:
  /// **'QR Okuyucu uygulamasını kullanıyorum! 📱\n\nQR kodları ve barkodları kolayca tarayabilir, yeni QR kodlar oluşturabilirsiniz.\n\n'**
  String get shareAppText;

  /// No description provided for @shareAppSubject.
  ///
  /// In tr, this message translates to:
  /// **'QR Okuyucu Uygulaması'**
  String get shareAppSubject;

  /// No description provided for @contactQrCodeVcard.
  ///
  /// In tr, this message translates to:
  /// **'Kişi QR Kodu (vCard)'**
  String get contactQrCodeVcard;

  /// No description provided for @contactQrCodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişi QR Kodu'**
  String get contactQrCodeTitle;

  /// No description provided for @eventQrCodeVevent.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik QR Kodu (vEvent)'**
  String get eventQrCodeVevent;

  /// No description provided for @wifiQrCode.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi QR Kodu'**
  String get wifiQrCode;

  /// No description provided for @networkNameSSID.
  ///
  /// In tr, this message translates to:
  /// **'Ağ Adı (SSID)'**
  String get networkNameSSID;

  /// No description provided for @none.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get none;

  /// No description provided for @urlOpeningError.
  ///
  /// In tr, this message translates to:
  /// **'URL açılırken hata oluştu'**
  String get urlOpeningError;

  /// No description provided for @phone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @organization.
  ///
  /// In tr, this message translates to:
  /// **'Organizasyon'**
  String get organization;

  /// No description provided for @positionHint.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyonunuz'**
  String get positionHint;

  /// No description provided for @website.
  ///
  /// In tr, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @address.
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get address;

  /// No description provided for @addressInfoHint.
  ///
  /// In tr, this message translates to:
  /// **'Adres bilginiz'**
  String get addressInfoHint;

  /// No description provided for @enterFirstNameOrLastName.
  ///
  /// In tr, this message translates to:
  /// **'Ad veya soyad girin'**
  String get enterFirstNameOrLastName;

  /// No description provided for @vCardData.
  ///
  /// In tr, this message translates to:
  /// **'vCard Verisi'**
  String get vCardData;

  /// No description provided for @eventInformation.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Bilgileri'**
  String get eventInformation;

  /// No description provided for @dateAndTime.
  ///
  /// In tr, this message translates to:
  /// **'Tarih ve Saat'**
  String get dateAndTime;

  /// No description provided for @vEventData.
  ///
  /// In tr, this message translates to:
  /// **'vEvent Verisi'**
  String get vEventData;

  /// No description provided for @wifiQrCodeInfo.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi bilgi kartı'**
  String get wifiQrCodeInfo;

  /// No description provided for @rawData.
  ///
  /// In tr, this message translates to:
  /// **'Ham Veri'**
  String get rawData;

  /// No description provided for @qrCodeDataSaved.
  ///
  /// In tr, this message translates to:
  /// **'QR kod verisi kaydedildi'**
  String get qrCodeDataSaved;

  /// No description provided for @enterData.
  ///
  /// In tr, this message translates to:
  /// **'Veri girin'**
  String get enterData;

  /// No description provided for @information.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi'**
  String get information;

  /// No description provided for @wpaSecurityType.
  ///
  /// In tr, this message translates to:
  /// **'WPA/WPA2'**
  String get wpaSecurityType;

  /// No description provided for @wepSecurityType.
  ///
  /// In tr, this message translates to:
  /// **'WEP'**
  String get wepSecurityType;

  /// No description provided for @copyAction.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get copyAction;

  /// No description provided for @deleteAction.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get deleteAction;

  /// No description provided for @saveAction.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get saveAction;

  /// No description provided for @closeAction.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get closeAction;

  /// No description provided for @errorPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get errorPrefix;

  /// No description provided for @scanDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tarama silindi'**
  String get scanDeleted;

  /// No description provided for @urlFound.
  ///
  /// In tr, this message translates to:
  /// **'URL Bulundu'**
  String get urlFound;

  /// No description provided for @calendarQrCodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takvim QR Kodu'**
  String get calendarQrCodeTitle;

  /// No description provided for @wifiQrCodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi QR Kodu'**
  String get wifiQrCodeTitle;

  /// No description provided for @deleteScanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarama Sil'**
  String get deleteScanTitle;

  /// No description provided for @versionNumber.
  ///
  /// In tr, this message translates to:
  /// **'1.0.0'**
  String get versionNumber;

  /// No description provided for @licenseType.
  ///
  /// In tr, this message translates to:
  /// **'Proprietary'**
  String get licenseType;

  /// No description provided for @enterDataHint.
  ///
  /// In tr, this message translates to:
  /// **'Veri girin'**
  String get enterDataHint;

  /// No description provided for @phoneHint.
  ///
  /// In tr, this message translates to:
  /// **'+90 555 123 45 67'**
  String get phoneHint;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get emailHint;

  /// No description provided for @websiteHint.
  ///
  /// In tr, this message translates to:
  /// **'www.ornek.com'**
  String get websiteHint;

  /// No description provided for @urlHint.
  ///
  /// In tr, this message translates to:
  /// **'https://example.com'**
  String get urlHint;

  /// No description provided for @emailAddressHint.
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get emailAddressHint;

  /// No description provided for @phoneNumberHint.
  ///
  /// In tr, this message translates to:
  /// **'+905551234567'**
  String get phoneNumberHint;

  /// No description provided for @locationHint.
  ///
  /// In tr, this message translates to:
  /// **'41.0082,28.9784'**
  String get locationHint;

  /// No description provided for @smsHint.
  ///
  /// In tr, this message translates to:
  /// **'+905551234567'**
  String get smsHint;

  /// No description provided for @ean8Hint.
  ///
  /// In tr, this message translates to:
  /// **'1234567'**
  String get ean8Hint;

  /// No description provided for @ean13Hint.
  ///
  /// In tr, this message translates to:
  /// **'123456789012'**
  String get ean13Hint;

  /// No description provided for @upcEHint.
  ///
  /// In tr, this message translates to:
  /// **'123456'**
  String get upcEHint;

  /// No description provided for @upcAHint.
  ///
  /// In tr, this message translates to:
  /// **'123456789012'**
  String get upcAHint;

  /// No description provided for @code39Hint.
  ///
  /// In tr, this message translates to:
  /// **'ABC123'**
  String get code39Hint;

  /// No description provided for @code93Hint.
  ///
  /// In tr, this message translates to:
  /// **'ABC123'**
  String get code93Hint;

  /// No description provided for @code128Hint.
  ///
  /// In tr, this message translates to:
  /// **'ABC123'**
  String get code128Hint;

  /// No description provided for @itfHint.
  ///
  /// In tr, this message translates to:
  /// **'1234567890'**
  String get itfHint;

  /// No description provided for @pdf417Hint.
  ///
  /// In tr, this message translates to:
  /// **'1234567890'**
  String get pdf417Hint;

  /// No description provided for @refreshTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refreshTooltip;

  /// No description provided for @filterLabel.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele:'**
  String get filterLabel;

  /// No description provided for @typeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tip:'**
  String get typeLabel;

  /// No description provided for @timeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Zaman:'**
  String get timeLabel;

  /// No description provided for @formatLabel.
  ///
  /// In tr, this message translates to:
  /// **'Format:'**
  String get formatLabel;

  /// No description provided for @totalScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Tarama:'**
  String get totalScansLabel;

  /// No description provided for @urlScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'URL Taramaları:'**
  String get urlScansLabel;

  /// No description provided for @emailScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Taramaları:'**
  String get emailScansLabel;

  /// No description provided for @phoneScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Taramaları:'**
  String get phoneScansLabel;

  /// No description provided for @smsScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'SMS Taramaları:'**
  String get smsScansLabel;

  /// No description provided for @locationScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'Konum Taramaları:'**
  String get locationScansLabel;

  /// No description provided for @wifiScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'WiFi Taramaları:'**
  String get wifiScansLabel;

  /// No description provided for @contactScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kişi Taramaları:'**
  String get contactScansLabel;

  /// No description provided for @mecardScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'MeCard Taramaları:'**
  String get mecardScansLabel;

  /// No description provided for @otpScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'OTP Taramaları:'**
  String get otpScansLabel;

  /// No description provided for @cryptoScansLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kripto Para Taramaları:'**
  String get cryptoScansLabel;

  /// No description provided for @urlType.
  ///
  /// In tr, this message translates to:
  /// **'URL'**
  String get urlType;

  /// No description provided for @emailType.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get emailType;

  /// No description provided for @phoneType.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phoneType;

  /// No description provided for @smsType.
  ///
  /// In tr, this message translates to:
  /// **'SMS'**
  String get smsType;

  /// No description provided for @locationType.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get locationType;

  /// No description provided for @wifiType.
  ///
  /// In tr, this message translates to:
  /// **'WiFi'**
  String get wifiType;

  /// No description provided for @contactType.
  ///
  /// In tr, this message translates to:
  /// **'vCard'**
  String get contactType;

  /// No description provided for @mecardType.
  ///
  /// In tr, this message translates to:
  /// **'MeCard'**
  String get mecardType;

  /// No description provided for @otpType.
  ///
  /// In tr, this message translates to:
  /// **'OTP'**
  String get otpType;

  /// No description provided for @cryptoType.
  ///
  /// In tr, this message translates to:
  /// **'Kripto Para'**
  String get cryptoType;

  /// No description provided for @saveTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get saveTooltip;

  /// No description provided for @firstNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get lastNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get emailLabel;

  /// No description provided for @organizationLabel.
  ///
  /// In tr, this message translates to:
  /// **'Organizasyon'**
  String get organizationLabel;

  /// No description provided for @websiteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// No description provided for @errorLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get errorLabel;

  /// No description provided for @vCardDataLabel.
  ///
  /// In tr, this message translates to:
  /// **'vCard Verisi'**
  String get vCardDataLabel;

  /// No description provided for @eventInfoLabel.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Bilgileri'**
  String get eventInfoLabel;

  /// No description provided for @dateAndTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarih ve Saat'**
  String get dateAndTimeLabel;

  /// No description provided for @qrReaderTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Okuyucu'**
  String get qrReaderTitle;

  /// No description provided for @blueTheme.
  ///
  /// In tr, this message translates to:
  /// **'Mavi'**
  String get blueTheme;

  /// No description provided for @tealTheme.
  ///
  /// In tr, this message translates to:
  /// **'Yeşil'**
  String get tealTheme;

  /// No description provided for @purpleTheme.
  ///
  /// In tr, this message translates to:
  /// **'Mor'**
  String get purpleTheme;

  /// No description provided for @lastScanResult.
  ///
  /// In tr, this message translates to:
  /// **'Son Tarama Sonucu'**
  String get lastScanResult;

  /// No description provided for @vcardType.
  ///
  /// In tr, this message translates to:
  /// **'vCard'**
  String get vcardType;

  /// No description provided for @textType.
  ///
  /// In tr, this message translates to:
  /// **'Metin'**
  String get textType;

  /// No description provided for @statsAction.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statsAction;

  /// No description provided for @exportAction.
  ///
  /// In tr, this message translates to:
  /// **'Dışa Aktar'**
  String get exportAction;

  /// No description provided for @removeDuplicatesAction.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarları Kaldır'**
  String get removeDuplicatesAction;

  /// No description provided for @clearAllAction.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Temizle'**
  String get clearAllAction;

  /// No description provided for @openAction.
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get openAction;

  /// No description provided for @lightTheme.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get systemTheme;

  /// No description provided for @themeSelection.
  ///
  /// In tr, this message translates to:
  /// **'Tema Seçimi'**
  String get themeSelection;

  /// No description provided for @selectTheme.
  ///
  /// In tr, this message translates to:
  /// **'Tema Seçin'**
  String get selectTheme;

  /// No description provided for @imageAnalyzing.
  ///
  /// In tr, this message translates to:
  /// **'Resim analiz ediliyor...'**
  String get imageAnalyzing;

  /// No description provided for @wifiInfo.
  ///
  /// In tr, this message translates to:
  /// **'Wi-Fi Bilgileri'**
  String get wifiInfo;

  /// No description provided for @urlNotFound.
  ///
  /// In tr, this message translates to:
  /// **'URL bulunamadı'**
  String get urlNotFound;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// No description provided for @errorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get errorOccurred;

  /// No description provided for @operationCompleted.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başarıyla tamamlandı'**
  String get operationCompleted;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In tr, this message translates to:
  /// **'gün önce'**
  String get daysAgo;

  /// No description provided for @copyFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kopyalama başarısız'**
  String get copyFailed;

  /// No description provided for @savedToDownloads.
  ///
  /// In tr, this message translates to:
  /// **'İndirilenler klasörüne kaydedildi'**
  String get savedToDownloads;

  /// No description provided for @saveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaydetme başarısız'**
  String get saveFailed;

  /// No description provided for @shareFailed.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşma başarısız'**
  String get shareFailed;

  /// No description provided for @urlOpenFailed.
  ///
  /// In tr, this message translates to:
  /// **'URL açılamadı'**
  String get urlOpenFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

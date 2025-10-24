# 📱 QR Reader

A powerful and feature-rich Flutter QR code scanner application with advanced parsing capabilities, logging system, and scan history management.

## ✨ Features

### 🔍 **QR Code Scanning**
- **Real-time scanning** with camera integration
- **Multiple QR code types** support (URL, WiFi, Contact, SMS, etc.)
- **Smart parsing** for different data formats
- **One-time scan** with automatic camera stop

### 📶 **WiFi QR Code Support**
- **Automatic WiFi detection** from QR codes
- **SSID extraction** and display
- **Password parsing** with secure masking
- **Easy WiFi connection** information

### 📊 **Scan History**
- **Local storage** with Hive database
- **Search and filter** functionality
- **Export capabilities** for scan data
- **Detailed scan information** with timestamps

### 🔧 **Advanced Logging**
- **Comprehensive error tracking** with file logging
- **Real-time log viewer** with filtering
- **Debug information** for development
- **Export logs** for troubleshooting

### 🌐 **URL Handling**
- **Smart URL detection** and validation
- **User confirmation** before opening URLs
- **Multiple launch modes** (browser, in-app, etc.)
- **Copy to clipboard** functionality

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/qr-reader.git
   cd qr-reader
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Supported QR Code Types

| Type | Format | Description |
|------|--------|-------------|
| **URL** | `https://example.com` | Web addresses |
| **WiFi** | `WIFI:S:SSID;T:WPA;P:password;H:false;;` | WiFi network credentials |
| **Email** | `mailto:user@example.com` | Email addresses |
| **Phone** | `tel:+1234567890` | Phone numbers |
| **SMS** | `sms:+1234567890:message` | SMS messages |
| **Location** | `geo:lat,lng` | GPS coordinates |
| **Contact** | `BEGIN:VCARD...` | vCard contact information |
| **OTP** | `otpauth://totp/...` | Two-factor authentication |

## 🛠️ Technical Details

### **Architecture**
- **Flutter Framework** with Material Design
- **State Management** with StatefulWidget
- **Local Storage** with Hive database
- **Camera Integration** with mobile_scanner package

### **Key Packages**
- `mobile_scanner: ^7.1.3` - QR code scanning
- `hive: ^2.2.3` - Local database
- `url_launcher: ^6.3.1` - URL handling
- `logger: ^2.4.0` - Logging system
- `path_provider: ^2.1.4` - File system access

### **Project Structure**
```
lib/
├── main.dart                 # Main application entry point
├── models/
│   └── qr_scan_model.dart   # QR scan data model
├── screens/
│   ├── log_viewer_screen.dart    # Log viewing interface
│   └── scan_history_screen.dart  # Scan history management
└── services/
    ├── hive_service.dart     # Database operations
    └── log_service.dart      # Logging functionality
```

## 🔒 Permissions

### Android
- `CAMERA` - For QR code scanning
- `INTERNET` - For URL launching
- `QUERY_ALL_PACKAGES` - For URL handling

### iOS
- Camera access permission
- Network access for URL launching

## 📸 Screenshots

*Screenshots will be added here*

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- mobile_scanner package developers
- Hive database team
- All contributors and testers

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/qr-reader/issues) page
2. Create a new issue with detailed information
3. Include device information and error logs

---

**Made with ❤️ using Flutter**
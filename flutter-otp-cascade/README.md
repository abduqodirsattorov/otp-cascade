# Flutter OTP Cascade Package

Flutter ilovalariga parolsiz biometrik autentifikatsiya va In-App Push OTP interfeyslarini integratsiya qilish uchun rasmiy paket.

---

## 🛠️ O'rnatish

1.  `pubspec.yaml` faylingizga paketni qo'shing:
    ```yaml
    dependencies:
      flutter_otp_cascade:
        path: ../flutter-otp-cascade  # mahalliy ulash uchun yoki git orqali ulasangiz bo'ladi
    ```
2.  Bog'liqliklarni yuklab oling:
    ```bash
    flutter pub get
    ```

### Platforma Sozlamalari (iOS & Android)

#### iOS Sozlamalari (`ios/Runner/Info.plist`)
Biometriyadan foydalanish uchun ruxsat qo'shing:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Ilovaga tezkor kirish uchun FaceID/TouchID dan foydalaniladi</string>
```

#### Android Sozlamalari (`android/app/src/main/AndroidManifest.xml`)
Biometriya va Push xizmatlarini yoqing. Minimum SDK darajasi kamida 23 bo'lishi lozim.

---

## 🚀 Foydalanish

### 1. SDK ni Boshlash
```dart
OtpCascade.initialize(baseUrl: 'https://api.sizningsaytingiz.uz');
```

### 2. Biometrik Kalit (Passkey) Ro'yxatdan O'tkazish
```dart
final result = await OtpCascade.registerPasskey(
  userId: '12345',
  email: 'foydalanuvchi@pochta.uz',
);
if (result['success']) {
  print("Passkey muvaffaqiyatli saqlandi!");
}
```

### 3. Tizimga Kirish (Authentication)
```dart
final result = await OtpCascade.authenticateWithPasskey(userId: '12345');
if (result['success']) {
  String token = result['token'];
  // Tizimga kirdi!
}
```

### 4. Push OTP Kelganda BottomSheet Modal Oynasini Chiqarish
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => OtpCascadePushPrompt(
    userId: '12345',
    onApproved: () {
      // Muvaffaqiyatli tasdiqlandi
    },
    onFailed: (error) {
      // Tasdiqlashda xato
    },
    onFallbackSms: () {
      // SMS zaxira kanaliga yo'naltirish
    },
  ),
);
```

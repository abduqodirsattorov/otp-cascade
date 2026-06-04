# Laravel OTP Cascade Package

Laravel backend loyihalarida parolsiz biometrik autentifikatsiya (Passkey/FIDO2) va tekin In-App Push OTP tizimini joriy qilish uchun rasmiy paket.

---

## 🛠️ O'rnatish

1.  Paketni composer orqali o'rnating:
    ```bash
    composer require otp-cascade/laravel-otp-cascade
    ```
2.  Konfiguratsiya faylini nashr qiling:
    ```bash
    php artisan vendor:publish --tag=otp-cascade-config
    ```
3.  Migratsiyalarni ishga tushiring:
    ```bash
    php artisan migrate
    ```

---

## ⚙️ Sozlash (`config/otp_cascade.php`)

Nashr qilingan `config/otp_cascade.php` faylida quyidagi parametrlarni o'zgartirishingiz mumkin:
*   `rp`: Relying Party (ilova domeni va nomi).
*   `cache`: Redis kesh sozlamalari va OTP umr muddati.
*   `fcm`: Firebase Cloud Messaging sozlamalari (loyiha ID va JSON hisob ma'lumotlari fayli).

---

## 🚀 API Endpointlar

Paket avtomatik ravishda quyidagi route'larni ro'yxatdan o'tkazadi:

### 1. Passkey Ro'yxatdan o'tkazish
*   `POST /api/otp/passkey/register/begin` — Yangi challenge yaratish.
*   `POST /api/otp/passkey/register/finish` — Foydalanuvchining biometrik ochiq kalitini saqlash.

### 2. Passkey orqali Kirish
*   `POST /api/otp/passkey/authenticate/begin` — Tizimga kirish uchun challenge olish.
*   `POST /api/otp/passkey/authenticate/finish` — Imzoni tekshirish va JWT token berish.

### 3. Push OTP va Qurilmalarni Boshqarish
*   `POST /api/otp/push/token` — Foydalanuvchining yangi qurilma push tokenini saqlash.
*   `POST /api/otp/push/send` — Ilovaga 6 xonali kod bilan yuqori ustuvorlikdagi push jo'natish.
*   `POST /api/otp/push/verify` — Kodni tekshirish (maksimal 3 urinish).

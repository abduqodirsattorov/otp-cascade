# OTP Cascade: Passkey & In-App Push OTP Authentication

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

OTP Cascade — bu foydalanuvchini tasdiqlash xarajatlarini keskin kamaytirish (75%-85% gacha tejash) va xavfsizlikni maksimal darajaga ko'tarish uchun mo'ljallangan open-source kutubxonalar to'plami. U WebAuthn (FIDO2) Passkeys, In-App Push bildirishnomalari va SMS zaxira kanallarini bitta silliq kaskad oqimiga birlashtiradi.

---

## 📐 Arxitektura Oqimi

```
[Foydalanuvchi So'rovi]
        │
        ├──► [Bosqich 1: Passkey / Biometriya] (Tep-tekin / Yuqori Xavfsizlik)
        │         │ (Muvaffaqiyatsiz yoki ro'yxatdan o'tmagan bo'lsa)
        │         ▼
        └──► [Bosqich 2: In-App Push OTP] (Tep-tekin / O'rtacha-Yuqori)
                  │ (FCM yetib bormasa / 3 daqiqa o'tsa)
                  ▼
             [Bosqich 3: SMS Zaxira] (Pullik zaxira kanali)
```

---

## 📦 Loyiha Tarkibi

Ushbu repozitoriya ikkita mustaqil paketni o'z ichiga oladi:

1.  **[Laravel Package (`laravel-otp-cascade`)](./laravel-otp-cascade)**:
    *   FIDO2/WebAuthn biometrik ro'yxatdan o'tish va tasdiqlash endpointlari.
    *   SHA-256 xeshlangan In-App Push OTP va Redis sessiya boshqaruvi.
    *   FCM High-Priority marshrutlash va urinishlarni cheklash (Rate limiting).
2.  **[Flutter Package (`flutter-otp-cascade`)](./flutter-otp-cascade)**:
    *   iOS va Android biometriya drayverlari (FaceID/TouchID/Credentials).
    *   Push OTP xabarlarini qabul qiluvchi va tasdiqlovchi tayyor, animatsiyali va glassmorphism dizaynli BottomSheet modal widgeti.

---

## 🔒 Xavfsizlik Kafolatlari (Security Analysis)

Open-source loyiha sifatida ushbu paket quyidagi zamonaviy hujumlarga qarshi to'liq himoyalangan:
*   **Fishing (Phishing) Himoyasi:** Passkey origin-binding yordamida ishlaydi, ya'ni soxta domenlarda biometrik kalitlar aslo ishlamaydi.
*   **Replay Attacks (Qayta yuborish):** Har bir tranzaksiya backend tomonidan beriladigan bir martalik tasodifiy *challenge* bilan imzolanadi.
*   **Brute-Force & Credential Stuffing:** In-App Push OTP uchun maxsus 3 urinish limiti va Redis orqali 3 daqiqalik qat'iy umr muddati (TTL) o'rnatilgan.

---

## 🤝 Hissa Qo'shish (Contributing)

Biz har qanday yordam va yangi g'oyalardan xursandmiz! Hissa qo'shish uchun:
1. Loyihani Fork qiling.
2. Yangi feature uchun branch oching (`git checkout -b feature/amazing-feature`).
3. O'zgarishlarni commit qiling (`git commit -m 'Add amazing feature'`).
4. Branchga push qiling (`git push origin feature/amazing-feature`).
5. Pull Request yuboring.

---

## 📄 Litsenziya

Ushbu loyiha **MIT Litsenziyasi** ostida taqdim etilgan. Batafsil ma'lumot uchun [LICENSE](./LICENSE) fayliga qarang.

# Open-Source Git va Paketlarni Chop Etish (Publishing) Qo'llanmasi

Ushbu qo'llanma orqali siz yaratilgan paketlarni GitHub-ga joylashingiz va ularni dunyo bo'yicha dasturchilar ishlatishi uchun Packagist (Laravel) va Pub.dev (Flutter) tizimlariga joylashtirishingiz mumkin.

---

## 1. Kodni Git-ga yuklash (GitHub)

1.  **Loyiha papkasida Git-ni faollashtiring:**
    ```bash
    git init
    ```
2.  **Fayllarni kiritib, birinchi commit-ni yarating:**
    ```bash
    git add .
    git commit -m "initial commit: OTP Cascade package source code and configs"
    ```
3.  **GitHub-dan yangi repozitoriya oching** (nomini `otp-cascade` deb qo'yishingiz mumkin).
4.  **GitHub repozitoriyasini mahalliy git-ga bog'lang va yuklang:**
    ```bash
    git branch -M main
    git remote add origin https://github.com/USER_NAME/otp-cascade.git
    git push -u origin main
    ```

---

## 2. Laravel Paketini Packagist.org-da chop etish

Laravel paketini dasturchilar `composer require` yordamida oson o'rnatishi uchun quyidagi ishlarni bajarasiz:

1.  **Versiya qo'shish (Git Tag):**
    Packagist versiyalarni git taglari orqali aniqlaydi.
    ```bash
    git tag v1.0.0
    git push origin v1.0.0
    ```
2.  **Packagist-da ro'yxatdan o'tish:**
    [Packagist.org](https://packagist.org) saytiga kiring va GitHub profilingiz orqali ro'yxatdan o'ting.
3.  **Paketni yuborish:**
    "Submit" tugmasini bosing va o'zingizning GitHub repozitoriya manzilingizni kiriting (`https://github.com/USER_NAME/otp-cascade`).
4.  **Avtomatik yangilash (Webhook):**
    Har safar yangi kod yuklaganda Packagist avtomatik yangilanishi uchun GitHub-da "Packagist Service" yoki Webhook sozlang.

---

## 3. Flutter Paketini Pub.dev-da chop etish

Flutter paketini pub.dev saytida global e'lon qilish uchun:

1.  **Quruq tekshiruv (Dry Run):**
    Har qanday sintaktik yoki tuzilishdagi xatolarni aniqlash uchun terminalda `flutter-otp-cascade` papkasiga kiring va quyidagilarni bajaring:
    ```bash
    cd flutter-otp-cascade
    flutter pub publish --dry-run
    ```
2.  **Chop etish (Publish):**
    Agarda xatoliklar topilmasa, quyidagi buyruqni bering:
    ```bash
    flutter pub publish
    ```
3.  Terminalda ko'rsatilgan Google hisobingizga kirish havolasini ochib, ruxsat bering. Paket pub.dev saytida avtomatik e'lon qilinadi.

---

## ⚠️ Open-Source Mas'uliyati va Maslahatlar
*   **Security Vulnerabilities:** Kodingizda hech qanday API kalitlari (`FCM token`, `credentials.json`) qolib ketmaganini tekshiring (buning uchun `.gitignore` sozlandi).
*   **Issues va PR (Pull Request):** Ilovani ishlatayotgan dasturchilar tomonidan kelib tushadigan takliflar va xatoliklarni kuzatib borish uchun haftada bir bor GitHub Issues sahifasini ko'rib turing.

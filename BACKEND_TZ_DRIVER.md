# 📋 TEXNIK TOPSHIRIQ (TZ): "Yo'l-Yo'lakay" Mobil Ilovasi (Haydovchi / Driver Qismi)

> **Loyiha nomi:** Yo'l-Yo'lakay (Hamrohlik va Taksi Xizmati)  
> **Hujjat maqsadi:** Backend dasturchi uchun Driver (Haydovchi) mobil ilovasining barcha API, WebSocket va ma'lumotlar bazasi talablarini belgilash.  
> **Sana:** 2026-yil  
> **API Versiyasi:** `v1`  
> **Asosiy Base URL:** `https://api.yolyolakay.uz/api/v1`  
> **WebSocket URL:** `wss://api.yolyolakay.uz/ws`  

---

## 📌 MUNDARIJA

1. [Umumiy Arxitektura va Qoidalar](#1-umumiy-arxitektura-va-qoidalar)
2. [Modul 1: Autentifikatsiya, Haydovchi Verifikatsiyasi va Profil](#2-modul-1-autentifikatsiya-haydovchi-verifikatsiyasi-va-profil-auth-verification--profile)
3. [Modul 2: Haydovchi Bosh Sahifasi va Smena Holati](#3-modul-2-haydovchi-bosh-sahifasi-va-smena-holati-driver-home--shift)
4. [Modul 3: Shaharlararo Qatnov Yaratish va Boshqarish](#4-modul-3-shaharlararo-qatnov-yaratish-va-boshqarish-create--manage-rides)
5. [Modul 4: Yo'lovchilar Bronlarini Boshqarish](#5-modul-4-yolovchilar-bronlarini-boshqarish-manage-passenger-bookings)
6. [Modul 5: Tezkor Taksi Radari va Buyurtmalarni Bajarish](#6-modul-5-tezkor-taksi-radari-va-buyurtmalarni-bajarish-taxi-radar--orders)
7. [Modul 6: Hamyon, Komissiya va Daromadlar](#7-modul-6-hamyon-komissiya-va-daromadlar-wallet-earnings--transactions)
8. [Modul 7: Baholash, Reyting va Sharhlar](#8-modul-7-baholash-reyting-va-sharhlar-reviews--rating)
9. [Modul 8: Bildirishnomalar va FCM](#9-modul-8-bildirishnomalar-va-fcm-notifications)
10. [Modul 9: Qo'llab-quvvatlash va Qoidalar](#10-modul-9-qollab-quvvatlash-va-qoidalar-support--help)
11. [Real-Time WebSocket Hodisalari](#11-real-time-websocket-hodisalari-websocket-events)
12. [Ma'lumotlar Bazasi (Database Schema) Tavsiyasi](#12-malumotlar-bazasi-database-schema-tavsiyasi)
13. [Backendchi uchun Checklist (Vazifalar Ro'yxati)](#13-backendchi-uchun-checklist-vazifalar-royxati)

---

## 1. Umumiy Arxitektura va Qoidalar

### 1.1. HTTP So'rov va Javob Standartlari
* **Content-Type:** `application/json` (Fayl va hujjatlar yuklashda: `multipart/form-data`)
* **Autentifikatsiya:** `Authorization: Bearer <access_token>`
* **Vaqt formati:** ISO 8601 UTC (`2026-09-19T10:00:00Z`)
* **Pul birligi:** So'mda (butun son `integer`, masalan: `85000`)
* **Koordinata formati:** WGS 84 (`lat`: `double precision`, `lng`: `double precision`)

---

### 1.2. Standart Response Formati

#### Muvaffaqiyatli javob (HTTP 200 / 201):
```json
{
  "success": true,
  "message": "Operatsiya muvaffaqiyatli bajarildi",
  "data": { },
  "error": null
}
```

#### Xatolik javobi (HTTP 400 / 401 / 403 / 404 / 422 / 500):
```json
{
  "success": false,
  "message": "Hujjatlar to'liq yuklanmagan",
  "data": null,
  "error": {
    "code": "DOCUMENTS_REQUIRED",
    "details": [
      {
        "field": "driver_license_front",
        "message": "Haydovchilik guvohnomasi old tomoni rasmi majburiy"
      }
    ]
  }
}
```

#### Pagination (Sahifalash) Formati:
```json
{
  "page": 1,
  "limit": 20,
  "total_items": 42,
  "total_pages": 3
}
```

---

## 2. Modul 1: Autentifikatsiya, Haydovchi Verifikatsiyasi va Profil (Auth, Verification & Profile)

### 2.1. SMS OTP Yuborish
* **Metod:** `POST`
* **URL:** `/auth/driver/send-otp`
* **Request Body:**
```json
{
  "phone": "+998901234567"
}
```
* **Response Data (200 OK):**
```json
{
  "session_id": "drv_ses_c4b8e21a-6379-4674-8b1e-b8160cb711c1",
  "expires_in": 120,
  "resend_interval": 60
}
```

---

### 2.2. OTP Kodni Tasdiqlash va Kirish
* **Metod:** `POST`
* **URL:** `/auth/driver/verify-otp`
* **Request Body:**
```json
{
  "phone": "+998901234567",
  "session_id": "drv_ses_c4b8e21a-6379-4674-8b1e-b8160cb711c1",
  "code": "1234"
}
```
* **Response Data (200 OK):**
```json
{
  "is_registered": true,
  "verification_status": "approved", // "pending_submission" | "under_review" | "approved" | "rejected"
  "rejection_reason": null,
  "tokens": {
    "access_token": "eyJhbGciOi...",
    "refresh_token": "dGhpc2lzcmVmcmVzaA...",
    "expires_in": 86400
  },
  "driver": {
    "id": "drv_991201",
    "phone": "+998901234567",
    "first_name": "Sardor",
    "last_name": "Rahimov",
    "avatar_url": "https://cdn.yolyolakay.uz/avatars/drv_991201.jpg",
    "rating": 4.95,
    "total_trips": 154,
    "balance": 145000,
    "is_online": true,
    "role": "driver"
  }
}
```

---

### 2.3. Haydovchi Registratsiyasi va Hujjatlarini Yuborish (Verification KYC)
* **Metod:** `POST`
* **URL:** `/driver/verify-application`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Body Form-Data:**
  * `first_name`: `"Sardor"`
  * `last_name`: `"Rahimov"`
  * `birth_date`: `"1992-04-15"`
  * `gender`: `"male"`
  * `car_model`: `"Chevrolet Cobalt"`
  * `car_color`: `"Oq (Gaz-67)"`
  * `car_year`: `2022`
  * `plate_number`: `"01 A 777 AA"`
  * `tech_passport_number`: `"AAF 1234567"`
  * `driver_license_number`: `"AA 9876543"`
  * `driver_license_front`: `[file (jpg, png, webp)]`
  * `driver_license_back`: `[file (jpg, png, webp)]`
  * `tech_passport_front`: `[file (jpg, png, webp)]`
  * `tech_passport_back`: `[file (jpg, png, webp)]`
  * `car_front_photo`: `[file (jpg, png, webp)]`
  * `car_interior_photo`: `[file (jpg, png, webp)]`
  * `car_seats_count`: `4`
  * `has_ac`: `true`
* **Response Data (201 Created):**
```json
{
  "application_id": "app_55412",
  "verification_status": "under_review",
  "message": "Hujjatlaringiz qabul qilindi. Moderatsiya 24 soat ichida ko'rib chiqadi."
}
```

---

### 2.4. Profil Ma'lumotlarini Olish
* **Metod:** `GET`
* **URL:** `/driver/profile`
* **Headers:** `Authorization: Bearer <token>`
* **Response Data (200 OK):**
```json
{
  "id": "drv_991201",
  "phone": "+998901234567",
  "first_name": "Sardor",
  "last_name": "Rahimov",
  "avatar_url": "https://cdn.yolyolakay.uz/avatars/drv_991201.jpg",
  "rating": 4.95,
  "completed_trips_count": 210,
  "cancelled_trips_count": 3,
  "acceptance_rate_percent": 96.5,
  "verification_status": "approved",
  "vehicle": {
    "id": "veh_332",
    "model": "Chevrolet Cobalt",
    "color": "Oq",
    "plate_number": "01 A 777 AA",
    "year": 2022,
    "has_ac": true,
    "total_seats": 4
  },
  "wallet": {
    "balance": 145000,
    "hold_balance": 0,
    "currency": "UZS"
  }
}
```

---

### 2.5. Haydovchi Avatarini Yuklash
* **Metod:** `POST`
* **URL:** `/driver/profile/avatar`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Body:** `file` (Rasm: jpg, png, webp, max 5MB)
* **Response Data (200 OK):**
```json
{
  "avatar_url": "https://cdn.yolyolakay.uz/avatars/drv_991201_new.jpg"
}
```

---

### 2.6. FCM Tokenni Yangilash
* **Metod:** `POST`
* **URL:** `/driver/fcm-token`
* **Request Body:**
```json
{
  "fcm_token": "eX_driver_fcm_token_987654",
  "device_platform": "android"
}
```
* **Response Data (200 OK):** `{ "success": true }`

---

## 3. Modul 2: Haydovchi Bosh Sahifasi va Smena Holati (Driver Home & Shift)

### 3.1. Bosh Sahifa Dashbording (Home Feed)
* **Metod:** `GET`
* **URL:** `/driver/home`
* **Response Data (200 OK):**
```json
{
  "is_online": true,
  "verification_status": "approved",
  "daily_stats": {
    "today_earnings": 380000,
    "today_trips_count": 6,
    "online_hours": 5.5,
    "acceptance_rate": 98.0
  },
  "wallet_balance": 145000,
  "active_taxi_order": null,
  "active_intercity_trip": {
    "id": "ride_908",
    "from_city": { "id": "city_tas", "name": "Toshkent" },
    "to_city": { "id": "city_sam", "name": "Samarqand" },
    "departure_time": "2026-09-20T08:30:00Z",
    "total_seats": 4,
    "booked_seats": 3,
    "available_seats": 1,
    "price_per_seat": 85000,
    "status": "active"
  },
  "system_alerts": []
}
```

---

### 3.2. Smena (Online / Offline) Holatini O'zgartirish
* **Metod:** `POST`
* **URL:** `/driver/shift/toggle`
* **Request Body:**
```json
{
  "is_online": true,
  "current_lat": 41.31115,
  "current_lng": 69.27973
}
```
* **Response Data (200 OK):**
```json
{
  "is_online": true,
  "message": "Siz qidiruv radarida faolsiz. Buyurtmalarni kutishingiz mumkin."
}
```

---

## 4. Modul 3: Shaharlararo Qatnov Yaratish va Boshqarish (Create & Manage Rides)

### 4.1. Yangi Qatnov (E'lon) Joylashtirish
* **Metod:** `POST`
* **URL:** `/driver/rides`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
```json
{
  "from_city_id": "city_tas",
  "to_city_id": "city_sam",
  "departure_time": "2026-09-20T08:30:00Z",
  "price_per_seat": 85000,
  "total_seats": 4,
  "has_ac": true,
  "allow_luggage": true,
  "allow_smoking": false,
  "allow_pets": false,
  "women_only": false,
  "pickup_locations": [
    { "name": "Olmazor metro bekati", "lat": 41.2580, "lng": 69.2010 },
    { "name": "Erkin posti", "lat": 41.2150, "lng": 69.1550 }
  ],
  "dropoff_locations": [
    { "name": "Samarqand Vokzal", "lat": 39.6710, "lng": 66.9240 },
    { "name": "Registon maydoni", "lat": 39.6547, "lng": 66.9758 }
  ],
  "comment": "Bagajda joy bor, konditsioner yoqiladi. Vaqtida chiqamiz."
}
```
* **Response Data (201 Created):**
```json
{
  "ride_id": "ride_908",
  "status": "active",
  "created_at": "2026-09-19T14:00:00Z",
  "message": "Qatnov muvaffaqiyatli e'lon qilindi"
}
```

---

### 4.2. Haydovchining Barcha E'lonlari Ro'yxati
* **Metod:** `GET`
* **URL:** `/driver/rides?status=active&page=1&limit=20` (qiymatlar: `active` | `completed` | `cancelled`)
* **Response Data (200 OK):**
```json
{
  "items": [
    {
      "id": "ride_908",
      "from_city": "Toshkent",
      "to_city": "Samarqand",
      "departure_time": "2026-09-20T08:30:00Z",
      "price_per_seat": 85000,
      "total_seats": 4,
      "booked_seats": 3,
      "available_seats": 1,
      "status": "active",
      "total_estimated_earnings": 255000,
      "created_at": "2026-09-19T14:00:00Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total_items": 1, "total_pages": 1 }
}
```

---

### 4.3. Qatnovning To'liq Ma'lumotlari va Bron Qilgan Yo'lovchilar
* **Metod:** `GET`
* **URL:** `/driver/rides/{ride_id}`
* **Response Data (200 OK):**
```json
{
  "id": "ride_908",
  "from_city": "Toshkent",
  "to_city": "Samarqand",
  "departure_time": "2026-09-20T08:30:00Z",
  "price_per_seat": 85000,
  "total_seats": 4,
  "available_seats": 1,
  "status": "active",
  "passengers": [
    {
      "booking_id": "book_77412",
      "passenger_id": "usr_991201",
      "name": "Aziz Karimov",
      "phone": "+998901234567",
      "avatar_url": "https://cdn.yolyolakay.uz/avatars/usr_991201.jpg",
      "seats_count": 2,
      "total_price": 170000,
      "payment_type": "cash",
      "pickup_point": { "name": "Olmazor metro bekati", "lat": 41.2580, "lng": 69.2010 },
      "dropoff_point": { "name": "Samarqand Vokzal", "lat": 39.6710, "lng": 66.9240 },
      "status": "confirmed"
    }
  ]
}
```

---

### 4.4. Qatnov Statusini O'zgartirish (Boshlash / Yakunlash / Bekor Qilish)
* **Metod:** `PATCH`
* **URL:** `/driver/rides/{ride_id}/status`
* **Request Body:**
```json
{
  "status": "started" // "started" | "completed" | "cancelled",
  "cancel_reason": null
}
```
* **Response Data (200 OK):**
```json
{
  "ride_id": "ride_908",
  "status": "started",
  "message": "Safar boshlandi deb belgilandi. Yo'lovchilarga bildirishnoma yuborildi."
}
```

---

## 5. Modul 4: Yo'lovchilar Bronlarini Boshqarish (Manage Passenger Bookings)

### 5.1. Bron So'rovini Tasdiqlash yoki Rad Etish
* **Metod:** `POST`
* **URL:** `/driver/bookings/{booking_id}/action`
* **Request Body:**
```json
{
  "action": "accept", // "accept" | "reject",
  "reject_reason": "Bo'sh joy qolmagan"
}
```
* **Response Data (200 OK):**
```json
{
  "booking_id": "book_77412",
  "status": "confirmed",
  "message": "Bron so'rovi qabul qilindi"
}
```

---

### 5.2. Haydovchi Tomonidan Yo'lovchi Bronini Bekor Qilish
* **Metod:** `POST`
* **URL:** `/driver/bookings/{booking_id}/cancel`
* **Request Body:**
```json
{
  "reason": "Yo'lovchi aytilgan vaqtda bekatga kelmadi va telefonni ko'tarmadi"
}
```
* **Response Data (200 OK):**
```json
{
  "booking_id": "book_77412",
  "status": "cancelled",
  "message": "Bron bekor qilindi, o'rinlar qayta bo'shatildi"
}
```

---

## 6. Modul 5: Tezkor Taksi Radari va Buyurtmalarni Bajarish (Taxi Radar & Orders)

### 6.1. Radar: Atrofdagi Taksi Buyurtmalarini Ko'rish (Polling / REST fallback)
* **Metod:** `GET`
* **URL:** `/driver/taxi/radar?lat=41.31115&lng=69.27973&radius_km=3`
* **Response Data (200 OK):**
```json
{
  "active_orders": [
    {
      "order_id": "tx_ord_88201",
      "tier": "standard",
      "estimated_price": 18000,
      "distance_to_pickup_km": 1.2,
      "pickup": {
        "address": "Amir Temur xiyoboni, 4",
        "lat": 41.31115,
        "lng": 69.27973
      },
      "destination": {
        "address": "Chilonzor 9-mavze, 12-uy",
        "lat": 41.28552,
        "lng": 69.20384
      },
      "payment_type": "cash",
      "created_at": "2026-09-19T14:10:00Z",
      "timeout_seconds": 25
    }
  ]
}
```

---

### 6.2. Taksi Buyurtmasini Qabul Qilish (Accept Order)
* **Metod:** `POST`
* **URL:** `/driver/taxi/orders/{order_id}/accept`
* **Request Body:**
```json
{
  "driver_lat": 41.31400,
  "driver_lng": 69.28100
}
```
* **Response Data (200 OK):**
```json
{
  "order_id": "tx_ord_88201",
  "status": "driver_assigned",
  "passenger": {
    "id": "usr_991201",
    "name": "Aziz",
    "phone": "+998901234567",
    "avatar_url": "https://cdn.yolyolakay.uz/avatars/usr_991201.jpg",
    "rating": 4.9
  },
  "pickup": { "address": "Amir Temur xiyoboni, 4", "lat": 41.31115, "lng": 69.27973 },
  "destination": { "address": "Chilonzor 9-mavze, 12-uy", "lat": 41.28552, "lng": 69.20384 },
  "price": 18000,
  "commission_amount": 1800,
  "payment_type": "cash"
}
```

---

### 6.3. Taksi Buyurtmasi Bosqichlarini O'zgartirish (Order State Machine)
* **Metod:** `PATCH`
* **URL:** `/driver/taxi/orders/{order_id}/status`
* **Request Body:**
```json
{
  "status": "arrived", // "arrived" (Yetib keldim) | "in_progress" (Yo'lga chiqdik) | "completed" (Yakunlandi)
  "current_lat": 41.31115,
  "current_lng": 69.27973
}
```
* **Response Data (200 OK):**
```json
{
  "order_id": "tx_ord_88201",
  "status": "arrived",
  "updated_at": "2026-09-19T14:15:00Z"
}
```

---

### 6.4. Taksi Buyurtmasini Yakunlash va To'lovni Qabul Qilish
* **Metod:** `POST`
* **URL:** `/driver/taxi/orders/{order_id}/complete`
* **Request Body:**
```json
{
  "final_price": 18000,
  "payment_received": true
}
```
* **Response Data (200 OK):**
```json
{
  "order_id": "tx_ord_88201",
  "status": "completed",
  "earnings": 16200,
  "commission_deducted": 1800,
  "new_wallet_balance": 143200,
  "message": "Safar muvaffaqiyatli yakunlandi"
}
```

---

## 7. Modul 6: Hamyon, Komissiya va Daromadlar (Wallet, Earnings & Transactions)

### 7.1. Hamyon Balansi va Tranzaksiyalar Tarixi
* **Metod:** `GET`
* **URL:** `/driver/wallet/history?page=1&limit=20`
* **Response Data (200 OK):**
```json
{
  "balance": 143200,
  "currency": "UZS",
  "min_balance_threshold": 20000, // Minimal balans (kam bo'lsa buyurtma ololmaydi)
  "transactions": [
    {
      "id": "tx_9981",
      "type": "commission", // "commission" | "deposit" | "bonus" | "cashback"
      "amount": -1800,
      "description": "Taksi buyurtmasi #88201 uchun komissiya (10%)",
      "created_at": "2026-09-19T14:20:00Z"
    },
    {
      "id": "tx_9970",
      "type": "deposit",
      "amount": 50000,
      "description": "Payme orqali hisob to'ldirildi",
      "created_at": "2026-09-19T10:00:00Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total_items": 45, "total_pages": 3 }
}
```

---

### 7.2. Hamyonni To'ldirish (Create Deposit Order)
* **Metod:** `POST`
* **URL:** `/driver/wallet/deposit`
* **Request Body:**
```json
{
  "amount": 100000,
  "payment_system": "payme" // "payme" | "click" | "uzum"
}
```
* **Response Data (200 OK):**
```json
{
  "invoice_id": "inv_12903",
  "payment_url": "https://checkout.paycom.uz/..."
}
```

---

### 7.3. Daromadlar Statistikasi (Kunlik, Haftalik, Oylik)
* **Metod:** `GET`
* **URL:** `/driver/earnings/stats?period=weekly` (qiymatlar: `today` | `weekly` | `monthly`)
* **Response Data (200 OK):**
```json
{
  "period": "weekly",
  "total_earnings": 1850000,
  "total_trips": 28,
  "total_distance_km": 420.5,
  "total_online_hours": 32.5,
  "chart_data": [
    { "date": "2026-09-13", "day": "Dush", "earnings": 240000, "trips": 4 },
    { "date": "2026-09-14", "day": "Sesh", "earnings": 310000, "trips": 5 },
    { "date": "2026-09-15", "day": "Chor", "earnings": 180000, "trips": 3 },
    { "date": "2026-09-16", "day": "Pay",  "earnings": 290000, "trips": 4 },
    { "date": "2026-09-17", "day": "Juma", "earnings": 420000, "trips": 6 },
    { "date": "2026-09-18", "day": "Shan", "earnings": 260000, "trips": 4 },
    { "date": "2026-09-19", "day": "Yak",  "earnings": 150000, "trips": 2 }
  ]
}
```

---

## 8. Modul 7: Baholash, Reyting va Sharhlar (Reviews & Rating)

### 8.1. Haydovchiga Qoldirilgan Sharhlar Ro'yxati
* **Metod:** `GET`
* **URL:** `/driver/reviews?page=1&limit=20`
* **Response Data (200 OK):**
```json
{
  "overall_rating": 4.95,
  "rating_counts": { "5": 190, "4": 15, "3": 3, "2": 1, "1": 1 },
  "items": [
    {
      "id": "rev_332",
      "passenger_name": "Aziz K.",
      "rating": 5,
      "comment": "Juda hushmuomala va xavfsiz haydovchi, rahmat!",
      "tags": ["Toza mashina", "Xushmuomala", "Konditsioner"],
      "created_at": "2026-09-18T19:40:00Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total_items": 210, "total_pages": 11 }
}
```

---

### 8.2. Yo'lovchini Baholash (Rate Passenger)
* **Metod:** `POST`
* **URL:** `/driver/trips/{trip_id}/rate-passenger`
* **Request Body:**
```json
{
  "passenger_id": "usr_991201",
  "rating": 5,
  "comment": "Vaqtida chiqdi, to'lovni muammosiz qildi."
}
```
* **Response Data (200 OK):** `{ "message": "Yo'lovchi baholandi" }`

---

## 9. Modul 8: Bildirishnomalar va FCM (Notifications)

### 9.1. Haydovchi Bildirishnomalari
* **Metod:** `GET`
* **URL:** `/driver/notifications?page=1&limit=20`
* **Response Data (200 OK):**
```json
{
  "unread_count": 2,
  "items": [
    {
      "id": "notif_881",
      "title": "Yangi bron so'rovi!",
      "body": "Aziz Karimov Toshkent - Samarqand qatnovingizga 2 ta o'rin band qildi.",
      "type": "new_booking_request",
      "payload": { "ride_id": "ride_908", "booking_id": "book_77412" },
      "is_read": false,
      "created_at": "2026-09-19T14:15:00Z"
    }
  ]
}
```

---

### 9.2. Bildirishnomani O'qilgan Deb Belgilash
* **Metod:** `PATCH`
* **URL:** `/driver/notifications/{id}/read`

---

## 10. Modul 9: Qo'llab-quvvatlash va Qoidalar (Support & Help)

* `GET /driver/support/faq` — Haydovchilar uchun savol-javoblar (Komissiya, qoidalar, verifikatsiya).
* `POST /driver/support/tickets` — Haydovchi shikoyat yoki texnik murojaati:
```json
{
  "subject": "Buyurtma bo'yicha komissiya noto'g'ri yechildi",
  "message": "Buyurtma #88201 bekor qilingan edi, lekin hisobimdan komissiya ushlandi.",
  "order_id": "tx_ord_88201"
}
```

---

## 11. Real-Time WebSocket Hodisalari (WebSocket Events)

Ulanish manzili: `wss://api.yolyolakay.uz/ws?token=<driver_access_token>&role=driver`

### 11.1. Haydovchi ➔ Serverga (Outgoing GPS Telemetry)
Haydovchi online bo'lganida har 3–5 soniyada serverga o'z koordinatasini yuboradi:
```json
{
  "event": "DRIVER_LOCATION_UPDATE",
  "data": {
    "lat": 41.31115,
    "lng": 69.27973,
    "bearing": 185.2,
    "speed_kmh": 45,
    "accuracy": 5.0,
    "is_online": true,
    "active_trip_id": "ride_908" // yoki null
  }
}
```

---

### 11.2. Server ➔ Haydovchiga (Incoming Events)

#### 1. Yangi Tezkor Taksi Buyurtmasi Taklifi:
```json
{
  "event": "NEW_TAXI_ORDER_OFFER",
  "data": {
    "order_id": "tx_ord_88201",
    "tier": "standard",
    "price": 18000,
    "distance_to_pickup_km": 0.8,
    "pickup": {
      "address": "Amir Temur xiyoboni, 4",
      "lat": 41.31115,
      "lng": 69.27973
    },
    "destination": {
      "address": "Chilonzor 9, 12",
      "lat": 41.28552,
      "lng": 69.20384
    },
    "timeout_seconds": 20
  }
}
```

#### 2. Yo'lovchi Bron Qilganida yoki Bekor Qilganida:
```json
{
  "event": "BOOKING_UPDATE",
  "data": {
    "ride_id": "ride_908",
    "booking_id": "book_77412",
    "status": "created", // "created" | "cancelled_by_passenger"
    "seats_count": 2,
    "passenger_name": "Aziz Karimov",
    "passenger_phone": "+998901234567"
  }
}
```

#### 3. Buyurtma Yo'lovchi Tomonidan Bekor Qilinganda:
```json
{
  "event": "ORDER_CANCELLED_BY_PASSENGER",
  "data": {
    "order_id": "tx_ord_88201",
    "reason": "Mijoz buyurtmani bekor qildi"
  }
}
```

---

## 12. Ma'lumotlar Bazasi (Database Schema) Tavsiyasi

PostgreSQL jadvallari:

```sql
-- 1. Haydovchi Profil va Verifikatsiya Jadvali
CREATE TABLE driver_profiles (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    verification_status VARCHAR(30) DEFAULT 'under_review', -- 'pending_submission', 'under_review', 'approved', 'rejected'
    rejection_reason TEXT,
    car_model VARCHAR(100) NOT NULL,
    car_color VARCHAR(50) NOT NULL,
    car_year INTEGER NOT NULL,
    plate_number VARCHAR(20) UNIQUE NOT NULL,
    tech_passport_number VARCHAR(50) NOT NULL,
    driver_license_number VARCHAR(50) NOT NULL,
    driver_license_front_url TEXT,
    driver_license_back_url TEXT,
    tech_passport_front_url TEXT,
    tech_passport_back_url TEXT,
    car_front_photo_url TEXT,
    car_interior_photo_url TEXT,
    total_seats INTEGER DEFAULT 4,
    has_ac BOOLEAN DEFAULT FALSE,
    is_online BOOLEAN DEFAULT FALSE,
    current_lat DOUBLE PRECISION,
    current_lng DOUBLE PRECISION,
    last_location_time TIMESTAMP WITH TIME ZONE,
    rating NUMERIC(3, 2) DEFAULT 5.0,
    trips_completed INTEGER DEFAULT 0,
    acceptance_rate NUMERIC(5, 2) DEFAULT 100.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Haydovchi Hamyoni (Driver Wallet)
CREATE TABLE driver_wallets (
    id VARCHAR(36) PRIMARY KEY,
    driver_id VARCHAR(36) UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance INTEGER DEFAULT 0,
    hold_balance INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Hamyon Tranzaksiyalari (Wallet Transactions)
CREATE TABLE wallet_transactions (
    id VARCHAR(36) PRIMARY KEY,
    wallet_id VARCHAR(36) REFERENCES driver_wallets(id) ON DELETE CASCADE,
    type VARCHAR(30) NOT NULL, -- 'commission', 'deposit', 'bonus', 'refund'
    amount INTEGER NOT NULL,
    related_order_id VARCHAR(36),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Shaharlararo Qatnovlar (Rides)
CREATE TABLE rides (
    id VARCHAR(36) PRIMARY KEY,
    driver_id VARCHAR(36) REFERENCES users(id),
    from_city_id VARCHAR(36) REFERENCES cities(id),
    to_city_id VARCHAR(36) REFERENCES cities(id),
    departure_time TIMESTAMP WITH TIME ZONE NOT NULL,
    estimated_arrival TIMESTAMP WITH TIME ZONE,
    price_per_seat INTEGER NOT NULL,
    total_seats INTEGER NOT NULL,
    available_seats INTEGER NOT NULL,
    has_ac BOOLEAN DEFAULT FALSE,
    allow_luggage BOOLEAN DEFAULT TRUE,
    allow_smoking BOOLEAN DEFAULT FALSE,
    allow_pets BOOLEAN DEFAULT FALSE,
    women_only BOOLEAN DEFAULT FALSE,
    pickup_locations JSONB DEFAULT '[]',
    dropoff_locations JSONB DEFAULT '[]',
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'started', 'completed', 'cancelled'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Taksi Buyurtmalari (Taxi Orders)
CREATE TABLE taxi_orders (
    id VARCHAR(36) PRIMARY KEY,
    passenger_id VARCHAR(36) REFERENCES users(id),
    driver_id VARCHAR(36) REFERENCES users(id),
    tier VARCHAR(20) NOT NULL, -- 'standard', 'comfort', 'business'
    pickup JSONB NOT NULL,
    destination JSONB NOT NULL,
    price INTEGER NOT NULL,
    commission INTEGER NOT NULL,
    payment_type VARCHAR(20) DEFAULT 'cash',
    status VARCHAR(30) DEFAULT 'searching_driver', -- 'searching_driver', 'driver_assigned', 'arrived', 'in_progress', 'completed', 'cancelled'
    cancellation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);
```

---

## 13. Backendchi uchun Checklist (Vazifalar Ro'yxati)

* [ ] **1. SMS & Auth:** Haydovchilar uchun SMS OTP kirish va JWT sessiyalari (`role: driver`).
* [ ] **2. Driver KYC & Moderatsiya:** Haydovchilik guvohnomasi va tex-pasport rasmlarini MinIO/S3 ga yuklash, admin paneldan tasdiqlash/rad etish logikasi.
* [ ] **3. Geolocation & Smena Boshqaruvi:** Redis GEO (yoki PostGIS) orqali atrofdagi faol haydovchilarni saqlash va qidirish.
* [ ] **4. Shaharlararo Qatnovlar API:** Yangi qatnov yaratish, yo'lovchilar bronlarini tasdiqlash/bekor qilish, o'rindiqlar hisobini `transaction` bilan to'g'ri boshqarish (Race condition bo'lmasligi uchun).
* [ ] **5. Taksi Buyurtmalari & Matching Algoritmi:** Buyurtma berilganda eng yaqin haydovchilarga navbatma-navbat 20 soniyalik offer yuborish mexanizmi.
* [ ] **6. Real-Time WebSocket Server:** Haydovchi koordinatasini qabul qilish va yangi buyurtmalarni zudlik bilan push qilish.
* [ ] **7. Hamyon & Komissiya Tizimi:** Har bir yakunlangan safardan belgilangan komissiyani (masalan 10%) avtomatik yechish, minus balansga tushganda buyurtma olishni to'xtatish.
* [ ] **8. To'lov Gateway Integratsiyasi:** Payme, Click, Uzum orqali haydovchi hamyonini to'ldirish (Merchant API).
* [ ] **9. FCM Push Bildirishnomalar:** Yangi buyurtma taklifi va bron o'zgarishlarini haydovchining telefoniga push qilib yuborish.
* [ ] **10. Swagger / Postman Dokumentatsiya:** Mobil dasturchi test qilishi uchun tayyor endpointlar to'plami.

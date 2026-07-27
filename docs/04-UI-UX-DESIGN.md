# UI/UX Design — IderKopi Absensi

## 1. Design System

### Color Palette (dari web project IderKopi)

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| **Primary** | Red 600 | `#DC2626` | Button, active state, header |
| **Primary Dark** | Red 700 | `#B91C1C` | Gradient end, pressed state |
| **Primary Light** | Red 100 | `#FEE2E2` | Badge bg, subtle accent |
| **Primary Lighter** | Red 50 | `#FEF2F2` | Card bg accent |
| **Background** | White | `#FFFFFF` | Screen background |
| **Surface** | White | `#FFFFFF` | Cards, sheets |
| **Surface Alt** | Gray 50 | `#F9FAFB` | Input fields, alternate bg |
| **Text Primary** | Gray 900 | `#111827` | Headlines, body |
| **Text Secondary** | Gray 600 | `#4B5563` | Subtitles, captions |
| **Text Muted** | Gray 400 | `#9CA3AF` | Hints, timestamps |
| **Border** | Gray 200 | `#E5E7EB` | Card borders, dividers |
| **Success** | Green 600 | `#16A34A` | Check-in success, "hadir" |
| **Warning** | Amber 500 | `#F59E0B` | Terlambat |
| **Error** | Red 500 | `#EF4444` | Error state, alpha |
| **Gradient** | Red 600 → Red 700 | `#DC2626 → #B91C1C` | Headers, CTA buttons |

### Brand Color Scale (dari tailwind.config.ts)

```
brand-50:  #FEF2F2
brand-100: #FEE2E2
brand-200: #FECACA
brand-300: #FCA5A5
brand-400: #F87171
brand-500: #EF4444
brand-600: #DC2626  ← Primary
brand-700: #B91C1C  ← Primary Dark
brand-800: #991B1B
brand-900: #7F1D1D
```

### Typography

```dart
fontFamily: 'Inter'  // atau 'Poppins' untuk heading

// Scale
headlineLarge:  28px / bold       → Page titles
headlineMedium: 22px / bold       → Card titles
bodyLarge:      16px / medium     → Main content
bodyMedium:     14px / normal     → Body text
labelLarge:     14px / semibold   → Buttons
labelMedium:    12px / medium     → Badges, tags
bodySmall:      12px / normal     → Captions, timestamps
```

### Spacing & Radius

```
Spacing: 4, 8, 12, 16, 20, 24, 32
Radius:  8 (sm), 12 (md), 16 (lg), 24 (xl)
```

### Shadows

```dart
// Card shadow
boxShadow: [
  BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
]

// Elevated button shadow
boxShadow: [
  BoxShadow(color: Color(0x1ADC2626), blurRadius: 12, offset: Offset(0, 4)),
]
```

---

## 2. App Theme (Flutter ThemeData)

```dart
class AppTheme {
  static const primary = Color(0xFFDC2626);
  static const primaryDark = Color(0xFFB91C1C);
  static const primaryLight = Color(0xFFFEE2E2);
  static const primaryLighter = Color(0xFFFEF2F2);
  static const background = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF9FAFB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF4B5563);
  static const textMuted = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: textPrimary,
      error: error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButtonTheme.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary, width: 2),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textMuted),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
    ),
  );
}
```

---

## 3. Screen Mockups

### 3.1 Splash Screen

```
┌─────────────────────────────┐
│                             │
│                             │
│         ┌─────────┐         │
│         │  LOGO   │         │  ← Logo IderKopi, ring-2 red-500
│         │ 80x80   │         │     rounded-2xl
│         └─────────┘         │
│                             │
│       IderKopi Absensi      │  ← 22px bold, gray-900
│                             │
│        Versi 1.0.0          │  ← 12px, gray-400
│                             │
│                             │
│         ● ● ●               │  ← Loading dots (red)
│                             │
└─────────────────────────────┘
```

### 3.2 Login Page

```
┌─────────────────────────────┐
│  ← gradient header (40%) ──┐│
│                            ││
│        ┌─────────┐         ││
│        │  LOGO   │         ││  ← White circle bg, logo inside
│        └─────────┘         ││
│      IderKopi Absensi      ││  ← White text, 24px bold
│    Catat kehadiranmu       ││  ← Red-100, 14px
│                            ││
└─────────────────────────────┘  ← gradient end
│                             │
│  ┌─────────────────────────┐│
│  │ 📧 Email                ││  ← Input field, surfaceAlt bg
│  │ email@iderkopi.id       ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ 🔒 Password             ││
│  │ ••••••••••          👁 ││  ← Show/hide toggle
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │      MASUK              ││  ← Red-600 bg, white text
│  └─────────────────────────┘│     full width, 14px vertical
│                             │
│  ─── Belum punya akun? ─── │
│  Hubungi admin HR          │  ← 14px, gray-500, centered
│                             │
└─────────────────────────────┘
```

**Design notes:**
- Top 40% gradient `red-600 → red-700`
- Bottom 60% white
- Logo dalam white circle dengan shadow
- Inputs dengan `surfaceAlt` background, border hanya saat focus
- Button full-width dengan subtle red shadow

### 3.3 Home / Dashboard

```
┌─────────────────────────────┐
│  IderKopi Absensi    [👤]   │  ← AppBar white, title left
├─────────────────────────────┤
│                             │
│  ┌─────────────────────────┐│
│  │  Selamat Pagi,          ││  ← Greeting card
│  │  Budi Santoso           ││     gradient red-600 → red-700
│  │  Kang Ider - Cilandak   ││     white text
│  │                         ││
│  │  📅 Sabtu, 26 Jul 2026  ││
│  └─────────────────────────┘│
│                             │
│  Status Hari Ini            │  ← 14px semibold, gray-600
│  ┌─────────────────────────┐│
│  │  ✅ Check In            ││  ← Green badge if done
│  │  08:15 WIB              ││     Red badge if not yet
│  │                         ││
│  │  ⏳ Check Out           ││  ← Amber if waiting
│  │  Belum                  ││     Green if done
│  └─────────────────────────┘│
│                             │
│  ┌──────────┐ ┌──────────┐ │
│  │   📷     │ │   📋     │ │  ← Two action cards
│  │ Check In │ │ Riwayat  │ │     white bg, border
│  │          │ │          │ │     icon in red-100 circle
│  └──────────┘ └──────────┘ │
│                             │
│  Riwayat Terkini            │  ← 14px semibold, gray-600
│  ┌─────────────────────────┐│
│  │ ● 25 Jul  08:10 - 17:00││  ← List items
│  │   Tepat Waktu           ││     green dot
│  ├─────────────────────────┤│
│  │ ● 24 Jul  08:25 - 17:15││
│  │   Terlambat             ││     amber dot
│  ├─────────────────────────┤│
│  │ ● 23 Jul  08:05 - 17:00││
│  │   Tepat Waktu           ││     green dot
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
    [🏠] [📷] [📋] [👤]       ← Bottom nav: Home, Absen, Riwayat, Profil
```

### 3.4 Check-In Page (Core Feature)

```
┌─────────────────────────────┐
│  ← Absensi Masuk            │  ← AppBar with back button
├─────────────────────────────┤
│                             │
│  ┌─────────────────────────┐│
│  │   📍 Lokasi Terdeteksi  ││  ← Location card
│  │                         ││
│  │   ┌─────────────────┐   ││
│  │   │   🗺️ Map Preview│   ││  ← Static map or mini Google Map
│  │   │   (mini map)    │   ││     200px height
│  │   └─────────────────┘   ││
│  │                         ││
│  │   Lat: -6.123456        ││  ← 12px, gray-500
│  │   Lng: 106.789012       ││
│  │   ✅ Dalam area kantor  ││  ← Green text if in radius
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │   Foto Selfie           ││  ← Camera section
│  │                         ││
│  │   ┌─────────────────┐   ││
│  │   │                 │   ││
│  │   │   CAMERA        │   ││  ← Camera preview, 1:1 aspect
│  │   │   PREVIEW       │   ││     front-facing camera
│  │   │                 │   ││
│  │   └─────────────────┘   ││
│  │                         ││
│  │   [  Ambil Foto  ]      ││  ← Red-600 button
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │  Jam: 08:15:30 WIB      ││  ← Current time display
│  │  Tanggal: 26 Jul 2026   ││     16px medium
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │    KIRIM ABSENSI        ││  ← Full-width red-600
│  └─────────────────────────┘│     disabled until photo + GPS ready
│                             │
└─────────────────────────────┘
```

**States:**

| State | UI |
|-------|----|
| GPS loading | Spinner + "Mengambil lokasi..." |
| GPS denied | Red icon + "Aktifkan GPS untuk absensi" + "Buka Pengaturan" button |
| Camera not taken | Dashed border placeholder + camera icon |
| Photo taken | Photo preview + "Ambil Ulang" text button |
| Submitting | Button shows spinner, disabled |
| Success | Green checkmark overlay → auto pop to home |
| Error | Red snackbar with message |

### 3.5 Check-Out Page

```
┌─────────────────────────────┐
│  ← Absensi Pulang           │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────────┐│
│  │  Check In Hari Ini      ││  ← Summary of morning check-in
│  │  ✅ 08:15 WIB           ││     green accent
│  │  📍 -6.12, 106.78       ││
│  │  📷 Selfie tersimpan    ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │   📍 Lokasi Pulang      ││  ← Same location card pattern
│  │   ...map preview...     ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │   Foto Selfie Pulang    ││  ← Optional selfie for checkout
│  │   ...camera...          ││
│  └─────────────────────────┘│
│                             │
│  Jam: 17:05:00 WIB          │
│                             │
│  ┌─────────────────────────┐│
│  │    CHECK OUT            ││  ← Red-600 full width
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

### 3.6 Riwayat Absensi (History)

```
┌─────────────────────────────┐
│  Riwayat Absensi            │
├─────────────────────────────┤
│                             │
│  [▼ Juli 2026]              │  ← Month picker dropdown
│                             │
│  ┌─────────────────────────┐│
│  │ Sabtu, 26 Jul           ││  ← Date header, 14px semibold
│  │ ┌─────┐ Masuk  08:15 ✅ ││
│  │ │ 📷  │ Pulang 17:05 ✅ ││  ← Selfie thumbnail (40x40)
│  │ └─────┘ Tepat Waktu     ││     green badge
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ Jumat, 25 Jul           ││
│  │ ┌─────┐ Masuk  08:10 ✅ ││
│  │ │ 📷  │ Pulang 17:00 ✅ ││
│  │ └─────┘ Tepat Waktu     ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ Kamis, 25 Jul           ││
│  │ ┌─────┐ Masuk  08:25 ⚠️ ││
│  │ │ 📷  │ Pulang 17:15 ✅ ││
│  │ └─────┘ Terlambat       ││  ← amber badge
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ Rabu, 24 Jul            ││
│  │ ┌─────┐ Masuk  -        ││
│  │ │  —  │ Pulang -        ││  ← No selfie, gray placeholder
│  │ └─────┘ Alpha           ││  ← red badge
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

### 3.7 Profile Page

```
┌─────────────────────────────┐
│  Profil                     │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────────┐│
│  │      ┌───────┐          ││  ← Gradient header card
│  │      │       │          ││     red-600 → red-700
│  │      │ 👤    │          ││     avatar circle (white border)
│  │      │       │          ││
│  │      └───────┘          ││
│  │   Budi Santoso          ││  ← white, 20px bold
│  │   Kang Ider - Cilandak  ││  ← red-100, 14px
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ 📧 Email                ││
│  │ budi@iderkopi.id        ││
│  ├─────────────────────────┤│
│  │ 🏪 Outlet               ││
│  │ Cilandak                ││
│  ├─────────────────────────┤│
│  │ 📱 Telepon              ││
│  │ 0812-xxxx-xxxx          ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │  Statistik Bulan Ini    ││  ← 14px semibold header
│  ├─────────────────────────┤│
│  │  Hadir        22 hari   ││  ← green count
│  │  Terlambat     3 hari   ││  ← amber count
│  │  Alpha         1 hari   ││  ← red count
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │  ⚙️ Pengaturan          ││  ← List items
│  ├─────────────────────────┤│
│  │  📜 Kebijakan Privasi   ││
│  ├─────────────────────────┤│
│  │  ℹ️ Tentang Aplikasi    ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │    KELUAR               ││  ← Outlined red button
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

---

## 4. Reusable Components

### 4.1 Status Badge

```dart
// Green — Tepat Waktu
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Color(0xFFDCFCE7),  // green-100
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text('Tepat Waktu', style: TextStyle(
    color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w600,
  )),
)

// Amber — Terlambat
color: Color(0xFFFEF3C7), text: Color(0xFFF59E0B)

// Red — Alpha
color: Color(0xFFFEE2E2), text: Color(0xFFDC2626)
```

### 4.2 Action Card (Home)

```dart
Container(
  width: 160,
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFE5E7EB)),
  ),
  child: Column(
    children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: Color(0xFFFEE2E2),  // red-100
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.camera_alt, color: Color(0xFFDC2626)),
      ),
      SizedBox(height: 12),
      Text('Check In', style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600,
      )),
    ],
  ),
)
```

### 4.3 Gradient Header Card

```dart
Container(
  width: double.infinity,
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Selamat Pagi,', style: TextStyle(
        color: Colors.white70, fontSize: 14,
      )),
      Text('Budi Santoso', style: TextStyle(
        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700,
      )),
    ],
  ),
)
```

---

## 5. Bottom Navigation

```
┌───────────────────────────────────┐
│   🏠      📷      📋      👤      │
│  Home    Absen   Riwayat  Profil  │
└───────────────────────────────────┘
```

- **Active**: red-600 icon + red-600 label
- **Inactive**: gray-400 icon + gray-400 label
- **Background**: white with top border gray-200
- **"Absen" tab**: di-center dengan FAB-style circle (red-600 bg, white camera icon)

---

## 6. Animations & Micro-interactions

| Element | Animation |
|---------|-----------|
| Page transition | Slide from right (300ms ease) |
| Button press | Scale 0.97 + darken color |
| Card tap | Scale 0.98 + subtle shadow |
| Success check-in | Green checkmark pop-in (scale + fade) |
| Loading | Red spinner with pulse |
| Pull to refresh | Red refresh indicator |
| Snackbar | Slide up from bottom, red-50 bg for error, green-50 for success |

---

## 7. Empty & Error States

### No Attendance History

```
┌─────────────────────────────┐
│                             │
│          📋                 │  ← gray-300 icon, 64px
│                             │
│   Belum ada riwayat         │  ← 16px, gray-500
│   absensi                   │
│                             │
│   Mulai absen hari ini      │  ← 14px, gray-400
│                             │
└─────────────────────────────┘
```

### GPS Disabled

```
┌─────────────────────────────┐
│          📍                  │  ← red-100 circle, red-600 icon
│                             │
│   GPS Tidak Aktif           │  ← 18px bold, gray-900
│                             │
│   Aktifkan GPS untuk        │  ← 14px, gray-500
│   melakukan absensi         │
│                             │
│  [  Buka Pengaturan  ]      │  ← Red-600 button
└─────────────────────────────┘
```

### Network Error

```
┌─────────────────────────────┐
│          📡                  │
│                             │
│   Koneksi Terputus          │
│                             │
│   Periksa koneksi internet  │
│   Anda dan coba lagi        │
│                             │
│  [  Coba Lagi  ]            │
└─────────────────────────────┘
```

---

## 8. Dark Mode (Future)

Untuk MVP: light mode only. Struktur `AppTheme` siap untuk `dark` variant:

| Role | Light | Dark |
|------|-------|------|
| Background | `#FFFFFF` | `#0F172A` (slate-900) |
| Surface | `#FFFFFF` | `#1E293B` (slate-800) |
| Primary | `#DC2626` | `#DC2626` (same) |
| Text Primary | `#111827` | `#F1F5F9` (slate-100) |
| Border | `#E5E7EB` | `#334155` (slate-700) |

<div align="center">

# ðŸ’Ž LuxeJewel

**A luxury jewelry shopping app built with Flutter and Supabase.**

Dark theme Â· gold accents Â· real accounts Â· persistent cart & wishlist Â· demo checkout

![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-Auth%20%7C%20Postgres%20%7C%20Storage-3ECF8E?logo=supabase)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

</div>

> [!IMPORTANT]
> **Payments are demo-only.** Checkout creates real orders in Supabase, flagged
> `payment_mode = 'demo'` and `payment_status = 'demo_completed'`. No money is charged,
> no card details are collected, and inventory is never decremented.

---

## âœ¨ Features

| Area | What you get |
|---|---|
| **Accounts** | Email/password sign-up & login, email verification, forgot/reset password, persistent sessions, optional Google/Apple sign-in |
| **Catalog** | Products & categories from Postgres, search, price-range filter, in-stock toggle, sorting, stock badges |
| **Cart** | Saved per user, synced across devices, stock-aware quantities, optimistic updates with rollback |
| **Wishlist** | One tap to save, persisted and synced |
| **Profile** | Edit name/phone, upload a profile photo, manage shipping addresses, settings, help & support |
| **Checkout** | Address selection, server-calculated totals (subtotal + $50 shipping + 8% tax), clearly labeled **Demo Payment** |
| **Orders** | Order history, order details, demo badge, status tracking |
| **Navigation** | Protected routes, return-to-page after login, deep links, safe back buttons, 404 page |
| **Responsive** | Product grids scale from 2 columns on phones up to 6 on desktop |

---

## ðŸ§± Tech Stack

- **Flutter 3.41** with `provider` for state and `go_router` for navigation
- **Supabase**: Auth, Postgres with Row Level Security, Storage (avatars), RPC
- `cached_network_image`, `image_picker`, `intl`

## ðŸ—‚ Project Structure

```text
lib/
â”œâ”€â”€ application/        # AppState: catalog, cart, wishlist, orders, profile
â”œâ”€â”€ core/               # auth, config (env), errors, formatting, theme, validation
â”œâ”€â”€ data/
â”‚   â”œâ”€â”€ repositories/   # backend interfaces (auth, catalog, cart, â€¦)
â”‚   â””â”€â”€ supabase/       # Supabase implementations + DemoPaymentService
â”œâ”€â”€ domain/             # models, pricing rules, PaymentService abstraction
â”œâ”€â”€ features/           # screens: auth, home, product, cart, checkout, orders, profileâ€¦
â”œâ”€â”€ router/             # go_router config + route guards
â””â”€â”€ shared/             # reusable widgets & feedback helpers
supabase/
â”œâ”€â”€ migrations/         # schema, RLS policies, triggers, place_demo_order()
â””â”€â”€ seed.sql            # the 8 demo products
test/                   # unit + widget tests with an in-memory backend
```

---

## ðŸš€ Getting Started

### Prerequisites

- Flutter SDK **3.41.x** (`flutter --version`)
- A Supabase project
- Android SDK (for APK builds) and/or Chrome (for web)

### 1. Set up Supabase

1. Open **SQL Editor** in the Supabase dashboard and run, in order:
   1. `supabase/migrations/20260528100000_init_luxejewel.sql`
   2. `supabase/seed.sql`
2. Under **Authentication â†’ URL Configuration**:
   - set **Site URL** to your web origin (e.g. `http://localhost:5000`, or your Vercel URL)
   - add `<origin>/home` and `<origin>/reset-password` to **Redirect URLs**
3. *(Optional)* Enable Google/Apple under **Authentication â†’ Providers**.

### 2. Configure the app

```bash
cp env/dev.json.example env/dev.json
```

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT-REF.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_...",
  "GOOGLE_AUTH_ENABLED": false,
  "APPLE_AUTH_ENABLED": false
}
```

> [!WARNING]
> Use only the **publishable** key. Never put the secret/service-role key or database
> password in the app or in `env/*.json`. `env/*.json` is git-ignored.

### 3. Run

```bash
flutter pub get
flutter run -d chrome --web-port 5000 --dart-define-from-file=env/dev.json   # web
flutter run --dart-define-from-file=env/dev.json                             # device/emulator
```

---

## ðŸ“¦ Building

| Target | Command | Output |
|---|---|---|
| Android APK | `flutter build apk --release --dart-define-from-file=env/dev.json` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android App Bundle | `flutter build appbundle --release --dart-define-from-file=env/dev.json` | `build/app/outputs/bundle/release/app-release.aab` |
| Web | `flutter build web --release --dart-define-from-file=env/dev.json` | `build/web/` |

> The release APK is currently signed with the debug key, which is fine for sideloading and
> testing. Configure a release keystore before publishing to the Play Store.

### Deploying the web app to Vercel

`vercel.json` installs Flutter 3.41.7, builds the app, and rewrites every path to
`index.html` so browser refreshes and deep links work. Add these environment variables to the
Vercel project:

| Variable | Example |
|---|---|
| `SUPABASE_URL` | `https://<project-ref>.supabase.co` |
| `SUPABASE_PUBLISHABLE_KEY` | `sb_publishable_â€¦` |

---

## ðŸ” Security Model

- **Row Level Security** on every table: users can read and write only their own profile,
  addresses, cart, and wishlist, and can **read** only their own orders.
- **Catalog is read-only** for clients; only the service role (dashboard) can change prices or stock.
- **Orders are created only by `place_demo_order()`** (a `SECURITY DEFINER` function), which:
  - recalculates prices and totals from the database, ignoring anything the client sends;
  - validates stock without decrementing it;
  - sets `payment_mode = 'demo'` and `payment_status = 'demo_completed'`;
  - can be disabled through the private `app_settings.demo_payments_enabled` setting.
- A check constraint ensures a demo order can never be marked as `paid`.
- Avatars are publicly readable, but users can upload only into their own `<user-id>/` folder.

## ðŸ’³ Adding a Real Payment Gateway Later

Checkout depends on the `PaymentService` interface (`lib/domain/payment/payment_service.dart`),
not on a specific provider. To go live:

1. Create the payment intent in a Supabase Edge Function.
2. Confirm the payment in the client.
3. Verify it server-side via webhook, then insert the order with `payment_mode = 'live'`.
4. Swap `DemoPaymentService` for the new implementation and disable demo payments.

---

## ðŸ§ª Testing

```bash
flutter analyze
flutter test
```

The tests use an in-memory backend (no network, no payments) and cover validation, route
protection, cart and stock rules, wishlist persistence, user isolation, catalog error states,
and demo order creation.

## ðŸ—º Roadmap

- [ ] Real payment gateway (Stripe / Razorpay)
- [ ] Mobile deep links for email verification and password reset
- [ ] Admin panel for products and order status
- [ ] Product variants (size, metal)
- [ ] Order notifications

---

<div align="center">Made with Flutter ðŸ’› and Supabase</div>

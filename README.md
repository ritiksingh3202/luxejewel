# LuxeJewel

A luxury jewelry shopping application built with Flutter and Supabase, available on Android and the web.

![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-Auth%20%7C%20Postgres%20%7C%20Storage-3ECF8E?logo=supabase)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20Web-lightgrey)

**Download:** [Android APK](https://drive.google.com/file/d/1gtcXcBg-sZ9DJeZQC8TgYLkvfO0JfZQ5/view?usp=drive_link)

> [!IMPORTANT]
> Payments are demo-only. Checkout creates real orders in Supabase, marked with
> `payment_mode = 'demo'` and `payment_status = 'demo_completed'`. No money is charged,
> no card details are collected, and inventory is never decremented.

## Overview

LuxeJewel lets customers browse a jewelry catalog, save items to a wishlist, manage a cart,
and place orders through a demo checkout. All data is stored in Supabase Postgres and
protected with Row Level Security, so each user can access only their own information.

## Features

| Area | Description |
|---|---|
| Accounts | Email and password sign-up with instant access, login, forgot and reset password, persistent sessions |
| Catalog | Products and categories from Postgres, search, price filter, in-stock filter, sorting, stock badges |
| Cart | Saved per user, synced across devices, stock-aware quantities, optimistic updates with rollback |
| Wishlist | Save products with one tap, persisted and synced |
| Profile | Edit name and phone, upload a profile photo, manage shipping addresses, settings, help and support |
| Checkout | Address selection, server-calculated totals (subtotal, $50 shipping, 8% tax), clearly labeled Demo Payment |
| Orders | Order history, order details, demo badge, status tracking |
| Navigation | Protected routes, return to the requested page after login, deep links, 404 page |
| Responsive layout | Product grids scale from 2 columns on phones to 6 columns on desktop |

## Tech Stack

- Flutter 3.41 and Dart 3.11
- Provider for state management and go_router for navigation
- Supabase Auth, Postgres with Row Level Security, Storage and RPC functions
- cached_network_image, image_picker and intl
- Outfit typeface throughout the interface

## Project Structure

```text
lib/
  application/       App state: catalog, cart, wishlist, orders, profile
  core/              Auth, environment config, errors, formatting, theme, validation
  data/
    repositories/    Backend interfaces (auth, catalog, cart, wishlist, orders, profile)
    supabase/        Supabase implementations and the demo payment service
  domain/            Models, pricing rules, payment service interface
  features/          Screens: auth, home, products, cart, checkout, orders, profile
  router/            Route configuration and route guards
  shared/            Reusable widgets and feedback helpers
supabase/
  migrations/        Schema, RLS policies, triggers, place_demo_order()
  seed.sql           Demo categories and products
test/                Unit and widget tests using an in-memory backend
```

## Getting Started

### Prerequisites

- Flutter SDK 3.41.x
- A Supabase project
- Android SDK for APK builds, or Chrome for the web version

### 1. Set up Supabase

Open the SQL Editor in the Supabase dashboard and run these files in order:

1. `supabase/migrations/20260528100000_init_luxejewel.sql`
2. `supabase/seed.sql`
3. `supabase/migrations/20260610100000_auto_confirm_email.sql`

The third file confirms new accounts automatically, so users can sign in immediately after
signing up. For the same behavior at the project level, turn off "Confirm email" under
Authentication, Sign In / Providers, Email.

For password reset links on the web, set the Site URL under Authentication, URL Configuration
to your web origin (for example `http://localhost:5000`) and add `<origin>/reset-password`
to the Redirect URLs.

### 2. Configure the app

Copy the example environment file and fill in your project values:

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
> Use only the publishable key. Never put the secret key, service-role key or database
> password in the app or in `env/*.json`. The `env/*.json` files are excluded from Git.

### 3. Run

```bash
flutter pub get

# Web
flutter run -d chrome --web-port 5000 --dart-define-from-file=env/dev.json

# Android device or emulator
flutter run --dart-define-from-file=env/dev.json
```

## Building

| Target | Command | Output |
|---|---|---|
| Android APK | `flutter build apk --release --dart-define-from-file=env/dev.json` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android App Bundle | `flutter build appbundle --release --dart-define-from-file=env/dev.json` | `build/app/outputs/bundle/release/app-release.aab` |
| Web | `flutter build web --release --dart-define-from-file=env/dev.json` | `build/web/` |

The release APK is currently signed with the debug key, which is suitable for sideloading and
testing. Configure a release keystore before publishing to the Play Store.

### Deploying to Vercel

`vercel.json` installs Flutter 3.41.7, builds the web app and routes every path to
`index.html` so page refreshes and deep links work. Add these environment variables to the
Vercel project:

| Variable | Example |
|---|---|
| `SUPABASE_URL` | `https://<project-ref>.supabase.co` |
| `SUPABASE_PUBLISHABLE_KEY` | `sb_publishable_...` |

## Security Model

- Row Level Security is enabled on every table. Users can read and write only their own
  profile, addresses, cart and wishlist, and can only read their own orders.
- The catalog is read-only for clients. Prices and stock can be changed only from the
  Supabase dashboard.
- Orders are created only through `place_demo_order()`, a `SECURITY DEFINER` function that:
  - recalculates prices and totals from the database and ignores client-supplied amounts;
  - validates stock without decrementing it;
  - sets `payment_mode = 'demo'` and `payment_status = 'demo_completed'`;
  - can be disabled with the private `app_settings.demo_payments_enabled` setting.
- A check constraint prevents a demo order from ever being marked as paid.
- Profile photos are publicly readable, but each user can upload only into their own folder.

## Adding a Real Payment Gateway

Checkout depends on the `PaymentService` interface in
`lib/domain/payment/payment_service.dart` rather than on a specific provider. To accept real
payments:

1. Create the payment intent in a Supabase Edge Function.
2. Confirm the payment in the client.
3. Verify the payment on the server through a webhook, then create the order with
   `payment_mode = 'live'`.
4. Replace `DemoPaymentService` with the new implementation and disable demo payments.

## Testing

```bash
flutter analyze
flutter test
```

The tests run against an in-memory backend with no network access or payments. They cover
input validation, route protection, cart and stock rules, wishlist persistence, user data
isolation, catalog error states and demo order creation.

## Roadmap

- Real payment gateway (Stripe or Razorpay)
- Mobile deep links for password reset
- Admin panel for products and order status
- Product variants such as size and metal
- Order notifications

## License

This project is for portfolio and demonstration purposes.

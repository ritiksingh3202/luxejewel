# LuxeJewel

Luxury jewelry shopping app built with Flutter — dark theme, gold accents, cart, wishlist, checkout, and auth UI.

## Run locally

```bash
flutter pub get
flutter run -d chrome    # web
flutter run              # connected device or emulator
```

## Build for web (Vercel)

```bash
flutter build web --release
```

Deploy the `build/web` folder.

## Stack

- Flutter 3.x
- Provider, go_router
- Bundled product images and fonts (offline-friendly)

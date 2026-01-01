# Restoku App (Flutter)

Customer and seller mobile app for Restoku.

## Features

- Customer: browse menu, add to cart, place order, view order history and details.
- Seller: manage menu, categories, tables, and kitchen order status.
- Realtime: SSE notifications for completed orders with polling fallback.

## Requirements

- Flutter SDK
- Restoku API running locally (default `http://localhost:8000`)

## Configure API Base URL

Update `restoku-app/lib/config.dart` to point to the API server:

```
url_api: "http://localhost:8000",
```

## Run (Dev)

```
flutter pub get
flutter run
```

## Test Accounts (Local)

If you ran the backend seeders:

- Seller: `seller@restoku.test` / `password`

Customers can register via the app and verify OTP.

## Build (Release)

```
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

## Notes

- Menu images use `image_url` from the API; category images use `image_url` too.
- Order-ready notifications navigate to order detail on tap.

# Restoku App Smoke Tests

Quick manual checks to validate core flows.

## Auth
- Login: request OTP, verify OTP, redirect by role.
- Register: create new account, login with OTP.
- Logout: token cleared, redirect to login.

### Expected
- After OTP verify: customer -> Home, seller -> Seller Home.
- On invalid OTP: inline error shown under OTP field.

## Customer
- Browse menu list with images and category filter.
- Add menu to cart, update qty, remove item.
- Select table and create order (idempotent).
- Add per-item and order-level notes.
- View order history and order detail.

### Expected
- Inactive menu shows "Tidak tersedia" badge and cannot be added.
- Notes appear in order detail.
- Order history opens detail on tap.

## Seller/Kitchen
- Kitchen list shows pending/processing with search.
- Update status pending -> processing -> done.
- Assign order to staff name.
- Bulk update status from kitchen.
- Manage categories (create/edit/delete + image URL).
- Manage menus (create/edit/delete + image upload).
- Manage tables (create/edit/delete, cannot delete occupied).

### Expected
- Kitchen list search filters by order ID or table name.
- Priority label and elapsed time visible on kitchen cards.
- Deleting occupied table shows 409 error message.

## Notifications
- SSE shows "Order siap" and opens detail on tap.
- Polling fallback works when SSE disconnected.

### Expected
- Notification toast includes table name and total price when available.

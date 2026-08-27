# Khyate B2B

> A complete Flutter-based B2B booking and service-management application for customers, trainers/groomers, managers, and administrators.

Khyate B2B provides an end-to-end platform for managing service bookings, trainers, subscriptions, packages, payments, availability, promotions, reviews, and operational master data.

---

## Features

### Customer Features

- User registration, login, OTP verification, and password recovery
- Profile, cover image, and address management
- Browse categories, sessions, services, and sub-services
- Search, filter, and discover nearby subscriptions
- Select booking dates, timeslots, and available groomers
- Add services to cart and calculate total cost
- Apply promo codes
- Create orders and make payments
- Create and manage manual bookings
- Purchase subscriptions and packages
- Join classes through purchased packages
- Submit trainer and subscription ratings and reviews
- Receive and manage notifications

### Trainer / Groomer Features

- Trainer profile creation and update
- View assigned jobs
- Job check-in using location coordinates
- Initiate and complete checkout
- Upload completion images
- View and manage assigned subscriptions
- Subscription check-in and checkout
- Availability and holiday-related operations

### Admin Features

- User, trainer, manager, and role management
- Country, city, location, tax, and currency management
- Category, session, and sub-service management
- Timeslot and holiday management
- Promo code management
- Article management
- Terms and policy management
- Planner dashboard and groomer availability
- Subscription and package management
- Review moderation and admin replies

---

## User Roles

| Role | Responsibilities |
|---|---|
| Customer | Browse services, add items to cart, book services, purchase subscriptions/packages, make payments, and submit reviews |
| Trainer / Groomer | View jobs, manage profile, check in/out of services, and manage assigned subscriptions |
| Manager | Manage operational information and assigned administrative activities |
| Admin | Manage users, trainers, master data, bookings, promotions, reviews, packages, subscriptions, and dashboards |

---

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Architecture:** Feature-based modular architecture
- **API Integration:** REST APIs
- **Request Formats:** JSON and `multipart/form-data`
- **Authentication:** Bearer token authentication
- **Notifications:** Firebase Cloud Messaging token integration
- **Image Uploads:** Multipart file upload support

---

## Project Structure

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── config/
│   ├── routes/
│   └── theme/
├── core/
│   ├── constants/
│   ├── network/
│   ├── storage/
│   ├── utils/
│   ├── validators/
│   └── widgets/
├── features/
│   ├── authentication/
│   ├── user/
│   ├── address/
│   ├── master/
│   ├── subservice/
│   ├── trainer/
│   ├── timeslot/
│   ├── cart/
│   ├── order/
│   ├── payment/
│   ├── booking/
│   ├── subscription/
│   ├── package/
│   ├── package_booking/
│   ├── notification/
│   ├── manager/
│   └── admin/
└── shared/
    ├── models/
    ├── services/
    └── widgets/
```

---

## Getting Started

### Prerequisites

Make sure the following are installed:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android SDK / Xcode for device builds
- Git

Verify Flutter installation:

```bash
flutter doctor
```

### Clone the Repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd khyate_b2b
```

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

### Build Android App Bundle

```bash
flutter build appbundle --release
```

---

## Environment Configuration

Configure the API base URL using `--dart-define`.

```bash
flutter run --dart-define=BASE_URL=<YOUR_API_BASE_URL>
```

Example:

```bash
flutter run --dart-define=BASE_URL=https://example.com/api/v1
```

Example configuration class:

```dart
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://your-domain.com/api/v1',
  );
}
```

> Do not commit production URLs, API secrets, payment credentials, or access tokens to the repository.

---

## Authentication

Protected endpoints require the following header:

```http
Authorization: Bearer <access_token>
```

Authentication flow:

```text
Check Email
   ↓
Register User
   ↓
Generate OTP
   ↓
Verify OTP
   ↓
Login
   ↓
Store Access Token
   ↓
Access Protected Features
```

---

## API Conventions

### Base API Path

```text
/api/v1
```

### Request Content Types

| Content Type | Usage |
|---|---|
| `application/json` | Standard API requests |
| `multipart/form-data` | Requests that upload profile images, category images, package images, media, or other files |

### Common Pagination Body

```json
{
  "page": 1,
  "limit": 10
}
```

### Common Search Body

```json
{
  "page": 1,
  "limit": 10,
  "search": "keyword"
}
```

### Date and Time Formats

```text
Date: YYYY-MM-DD
Date-Time: YYYY-MM-DDTHH:mm:ssZ
Time: HH:mm
```

---

# API Documentation

## Authentication APIs

Base path: `/api/v1/auth`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/check-email` | Check whether an email is registered |
| POST | `/auth/register` | Register a new user |
| POST | `/auth/login/:role_id` | Login using role ID |
| POST | `/auth/generate-otp` | Generate OTP |
| POST | `/auth/verify-otp` | Verify OTP |
| POST | `/auth/reset-password` | Reset password |
| POST | `/auth/change-password` | Change password |
| PATCH | `/auth/update-account` | Update account details |
| PATCH | `/auth/update-cover-image` | Update cover image |
| POST | `/auth/create-fcm-token` | Create or update FCM token |

### Login Request

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### OTP Verification Request

```json
{
  "emailOrPhone": "user@example.com",
  "otp": "123456"
}
```

### Change Password Request

```json
{
  "oldPassword": "old_password123",
  "newPassword": "new_password123"
}
```

---

## User Management APIs

Base path: `/api/v1/user`

| Method | Endpoint | Description |
|---|---|---|
| PATCH | `/user/update-user-status/:userId` | Update user approval/status |
| POST | `/user/create-user` | Create user |
| PUT | `/user/update-user` | Update user |
| POST | `/user/create-address` | Create address |
| PUT | `/user/update-address/:id` | Update address |
| POST | `/user/create-subscription-rating-review` | Create subscription review |
| PUT | `/user/update-subscription-review/:subscriptionId` | Update subscription review |
| POST | `/user/create-trainer-rating-review` | Create trainer review |
| PUT | `/user/update-trainer-review/:trainerId` | Update trainer review |
| POST | `/user/admin-reply-trainer-review/:reviewId` | Reply to trainer review |
| POST | `/user/reply-subscription-review/:reviewId` | Reply to subscription review |
| PUT | `/user/admin-hide-trainer-review/:reviewId` | Toggle trainer-review visibility |
| PUT | `/user/review-subscription-visibility/:reviewId` | Toggle subscription-review visibility |
| POST | `/user/cart-total-price-calculate` | Calculate cart total |
| PUT | `/user/update-notification/:id` | Mark notification as read |
| PUT | `/user/cancel-by-customer/:orderDetailsId` | Cancel booking/order |

### Create Address Request

```json
{
  "name": "Home",
  "phone_number": "1234567890",
  "pincode": "12345",
  "street": "123 Main St",
  "flat_no": "Apt 4B",
  "city": "city_id",
  "country": "country_id",
  "isDefault": true
}
```

### Cart Total Request

```json
{
  "cartItems": ["cart_id1", "cart_id2"],
  "promoCode": "promo_id"
}
```

---

## Master Data APIs

Base path: `/api/v1/master`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/master/create-terms-n-policy` | Create terms and policy |
| PATCH | `/master/update-terms-n-policy/:policyId` | Update terms and policy |
| POST | `/master/create-tenure` | Create tenure |
| PUT | `/master/update-tenure/:id` | Update tenure |
| POST | `/master/create-tax-master` | Create tax |
| PUT | `/master/update-tax-master/:id` | Update tax |
| POST | `/master/get-all-tax-master` | Get tax masters |
| POST | `/master/create-location-master` | Create location |
| PUT | `/master/update-location-master/:id` | Update location |
| POST | `/master/get-all-location-master` | Get locations |
| GET | `/master/get-location-by-country-city` | Get locations by country and city |
| POST | `/master/create-session` | Create session |
| PUT | `/master/update-session/:id` | Update session |
| POST | `/master/create-category` | Create category |
| PUT | `/master/update-category/:id` | Update category |
| POST | `/master/create-role` | Create role |
| PUT | `/master/update-role/:id` | Update role |
| POST | `/master/get-all-role` | Get roles |
| POST | `/master/create-country` | Create country |
| PUT | `/master/update-country/:countryId` | Update country |
| POST | `/master/create-city` | Create city |
| PUT | `/master/update-city/:cityId` | Update city |

### Create Location Request

```json
{
  "name": "Dubai Marina",
  "country": "country_id",
  "city": "city_id",
  "latitude": 25.0772,
  "longitude": 55.1398,
  "address": "Dubai Marina, Dubai"
}
```

### Create Tax Request

```json
{
  "name": "VAT",
  "percentage": 5,
  "isActive": true
}
```

---

## Sub-Service APIs

Base path: `/api/v1/subservice`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/subservice/createSubService` | Create sub-service |
| PUT | `/subservice/updateSubService/:subServiceId` | Update sub-service |
| POST | `/subservice/getAllSubService` | Get sub-services |

### Create Sub-Service Request

```text
Content-Type: multipart/form-data

image: <file>
name: Haircut
serviceTypeId: service_id
groomingDetails: [{"weightType":"small","price":100,"description":"Small pet"}]
```

---

## Trainer APIs

Base path: `/api/v1/trainer`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/trainer/create-trainer` | Create trainer |
| PUT | `/trainer/update-trainer/:id` | Update trainer |
| PATCH | `/trainer/update-trainer-status/:trainerId` | Update trainer status |
| PUT | `/trainer/update-trainer-profiles/:trainerId` | Update trainer profile |
| POST | `/trainer/get-all-assigned-jobs` | Get assigned jobs |
| POST | `/trainer/checkin/:orderDetailsId` | Check in to job |
| POST | `/trainer/initiate-checkout/:orderDetailsId` | Initiate checkout |
| POST | `/trainer/complete-checkout/:orderDetailsId` | Complete checkout |

### Trainer Check-In Request

```json
{
  "checkinTime": "2024-01-01T10:00:00Z",
  "latitude": 25.0772,
  "longitude": 55.1398
}
```

### Trainer Checkout Request

```json
{
  "completionTime": "2024-01-01T11:00:00Z",
  "images": ["url1", "url2"]
}
```

---

## Admin APIs

Base path: `/api/v1/admin`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/admin/create-promo-code` | Create promo code |
| PUT | `/admin/update-promo-code/:id` | Update promo code |
| POST | `/admin/get-all-promo-codes` | Get promo codes |
| POST | `/admin/get-planner-dashboard` | Get planner dashboard |
| POST | `/admin/get-all-available-groomers` | Get available groomers |
| POST | `/admin/get-all-available-groomers-booking` | Get groomers for booking |
| POST | `/admin/create-artical` | Create article |
| PUT | `/admin/update-artical/:id` | Update article |

### Create Promo Code Request

```text
Content-Type: multipart/form-data

image: <file>
code: SAVE20
discountType: percentage
discountValue: 20
minOrderAmount: 100
maxDiscountAmount: 50
validFrom: 2024-01-01
validTo: 2024-12-31
usageLimit: 100
isActive: true
```

### Planner Dashboard Request

```json
{
  "startDate": "2024-01-01",
  "endDate": "2024-01-31",
  "locationId": "location_id"
}
```

---

## Manager APIs

Base path: `/api/v1/manager`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/manager/create-manager` | Create manager |
| PUT | `/manager/update-manger/:id` | Update manager |

### Create Manager Request

```text
Content-Type: multipart/form-data

profile_image: <file>
email: manager@example.com
first_name: John
last_name: Doe
phone_number: 1234567890
password: password123
```

---

## Timeslot APIs

Base path: `/api/v1/timeslot`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/timeslot/createTimeslot` | Create timeslot |
| PUT | `/timeslot/updateTimeslot/:timeslotId` | Update timeslot |
| POST | `/timeslot/getAllTimeslots` | Get timeslots |
| POST | `/timeslot/getFreeGroomers` | Get free groomers |
| POST | `/timeslot/getAvailableTimeSlots/:subServiceId` | Get available timeslots |
| POST | `/timeslot/markOfficeHoliday` | Mark office holiday |
| POST | `/timeslot/markGroomerHoliday` | Mark groomer holiday |

### Create Timeslot Request

```json
{
  "startTime": "09:00",
  "endTime": "10:00",
  "isActive": true
}
```

---

## Cart APIs

Base path: `/api/v1/cart`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/cart/create-cart` | Add service to cart |

### Create Cart Request

```json
{
  "subServiceId": "subservice_id",
  "quantity": 1,
  "timeslotId": "timeslot_id",
  "bookingDate": "2024-01-01",
  "petDetails": {
    "weightType": "small",
    "petName": "Buddy"
  }
}
```

---

## Currency APIs

Base path: `/api/v1/currency`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/currency/create-currency` | Create currency |
| PUT | `/currency/update-currency/:id` | Update currency |
| POST | `/currency/createOrUpdateExchange` | Create or update exchange rate |

### Create Exchange Rate Request

```json
{
  "fromCurrency": "USD",
  "toCurrency": "AED",
  "rate": 3.67,
  "isActive": true
}
```

---

## Order and Payment APIs

### Order Base Path

```text
/api/v1/order
```

| Method | Endpoint | Description |
|---|---|---|
| POST | `/order/create-order` | Create order |
| PUT | `/order/update-order` | Update order |

### Payment Base Path

```text
/api/v1/payment
```

| Method | Endpoint | Description |
|---|---|---|
| POST | `/payment/create-payment` | Create payment |

### Create Order Request

```json
{
  "cartItems": ["cart_id1", "cart_id2"],
  "addressId": "address_id",
  "paymentMethod": "card",
  "promoCode": "promo_id"
}
```

### Create Payment Request

```json
{
  "orderId": "order_id",
  "amount": 100,
  "paymentMethod": "card",
  "transactionId": "txn_123456"
}
```

---

## Booking APIs

Base path: `/api/v1/booking`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/booking/create-manual-booking` | Create manual booking |
| PUT | `/booking/update-booking/:bookingId` | Update booking |
| POST | `/booking/subscribe` | Create subscription booking |
| POST | `/booking/cancel-subscribe` | Cancel subscription booking |
| POST | `/booking/subscription-apply-promo` | Apply promo code to subscription |
| POST | `/booking/mark-Subscription-Attendance` | Mark subscription attendance |

### Create Manual Booking Request

```json
{
  "subServiceId": "subservice_id",
  "timeslotId": "timeslot_id",
  "bookingDate": "2024-01-01",
  "groomerId": "groomer_id",
  "addressId": "address_id",
  "petDetails": {
    "weightType": "small",
    "petName": "Buddy"
  }
}
```

---

## Subscription APIs

Base path: `/api/v1/subscription`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/subscription/create-subscription` | Create subscription |
| PUT | `/subscription/update-subscription/:id` | Update subscription |
| POST | `/subscription/get-all-subscription` | Get all subscriptions |
| POST | `/subscription/get-subscriptions-by-date` | Get subscriptions by date |
| POST | `/subscription/get-subscriptions-by-coordinates` | Get subscriptions by coordinates |
| GET | `/subscription/get-subscriptions-by-loc-id/:locationId` | Get subscriptions by location |
| POST | `/subscription/get-subscriptions-filter` | Filter and sort subscriptions |
| POST | `/subscription/get-trainer-Assigned-Subscriptions-filters` | Get trainer subscriptions |
| GET | `/subscription/search-subscriptions?query=yoga` | Search subscriptions |
| GET | `/subscription/subscriptions/nearby` | Get nearby subscriptions |
| POST | `/subscription/subscription-check-in/:subscriptionId` | Subscription check-in |
| POST | `/subscription/subscription-check-out/:subscriptionId` | Subscription check-out |

### Create Subscription Request

```text
Content-Type: multipart/form-data

media: <file>
name: Yoga Class
categoryId: category_id
price: 100
trainer: trainer_id
sessionType: session_id
description: Yoga class description
isActive: true
date: ["2024-01-01", "2024-01-08"]
startTime: 09:00
endTime: 10:00
Address: {...}
isSingleClass: false
```

### Filter Subscription Request

```json
{
  "categoryId": "category_id",
  "sessionTypeId": "session_id",
  "trainerId": "trainer_id",
  "minPrice": 50,
  "maxPrice": 200,
  "sortBy": "price",
  "sortOrder": "asc"
}
```

---

## Package APIs

Base path: `/api/v1/package`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/package/create-package` | Create package |
| PUT | `/package/update-package/:id` | Update package |
| POST | `/package/get-all-packages` | Get packages |

### Create Package Request

```text
Content-Type: multipart/form-data

image: <file>
name: Premium Package
description: Package description
price: 500
duration: 30
classesIncluded: 10
isActive: true
```

---

## Package Booking APIs

Base path: `/api/v1/package-booking`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/package-booking/create-package-booking` | Purchase package |
| POST | `/package-booking/package-booking-join-class` | Join class using package |
| POST | `/package-booking/mark-attendance` | Mark class attendance |

### Create Package Booking Request

```json
{
  "packageId": "package_id",
  "paymentMethod": "card",
  "promoCode": "promo_id"
}
```

### Join Class With Package Request

```json
{
  "packageBookingId": "package_booking_id",
  "subscriptionId": "subscription_id",
  "classDate": "2024-01-01"
}
```

---

# Main Application Flows

## Service Booking Flow

```text
Browse Service
   ↓
Choose Sub-Service
   ↓
Enter Pet Details
   ↓
Choose Date and Timeslot
   ↓
Select Available Groomer
   ↓
Add to Cart
   ↓
Apply Promo Code
   ↓
Select Address
   ↓
Create Order
   ↓
Make Payment
   ↓
Booking Confirmation
```

## Subscription Flow

```text
Browse Subscriptions
   ↓
Search / Filter / Sort
   ↓
View Subscription Details
   ↓
Apply Promo Code
   ↓
Create Subscription Booking
   ↓
Make Payment
   ↓
View Attendance and Booking Details
```

## Package Booking Flow

```text
Browse Packages
   ↓
Purchase Package
   ↓
Select Available Class
   ↓
Join Class Using Package
   ↓
Track Attendance
```

---

## Error Handling

The application handles the following common cases:

- Invalid form data
- Invalid or expired access token
- OTP verification failure
- Network connectivity issues
- API timeout
- Server-side errors
- Failed image uploads
- Unavailable timeslots
- Unavailable groomers
- Failed payment transactions
- Duplicate booking prevention
- Empty list and no-data states

---

## Useful Commands

```bash
# Get project dependencies
flutter pub get

# Run application
flutter run

# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Build release APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release
```

---

## Screenshots

Add application screenshots in the `assets/screenshots/` directory and update the paths below.

```md
| Login | Home | Booking |
|---|---|---|
|  |  |  |
```

---

## Important Notes

- API paths are based on the backend API document.
- `multipart/form-data` must be used for endpoints accepting images or media files.
- All protected requests must include a valid Bearer access token.
- Pagination is supported on relevant listing APIs.
- Confirm final API response models, status codes, and backend validation rules before further API changes.
- The endpoint `/manager/update-manger/:id` uses the spelling provided by the backend API.
- The customer cancellation route should be confirmed with the backend if it differs from the documented format.

---

## Project Status

✅ Completed

The application includes authentication, role-based flows, booking management, cart and order flow, payment integration endpoints, subscription management, package booking, trainer operations, admin management, master-data management, review management, notifications, and API integration support.

---

## License

This project is proprietary and intended for authorized use only.

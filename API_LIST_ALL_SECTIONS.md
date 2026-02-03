# Complete API List – All Sections & Subsections

**Base URL:** `http://localhost:5000/api/v1`  
**Auth:** Send `Authorization: Bearer <access_token>` for protected routes.

**Success response:** `{ statusCode, data, message, success: true }`  
**Error response:** `{ statusCode, message, success: false, data: null, errors?: [] }`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Customers](#2-customers)
3. [Trainers](#3-trainers)
4. [Memberships](#4-memberships)
   - 4.1 [Programs / Classes (Subscription)](#41-programs--classes-subscription)
   - 4.2 [Membership (Package)](#42-membership-package)
   - 4.3 [Bookings](#43-bookings)
   - 4.4 [Package Bookings](#44-package-bookings)
5. [Promo Codes](#5-promo-codes)
6. [Payments](#6-payments)
7. [Ratings](#7-ratings)
   - 7.1 [Trainer Ratings](#71-trainer-ratings)
   - 7.2 [Membership / Subscription Ratings](#72-membership--subscription-ratings)
8. [Masters](#8-masters)
   - 8.1 [Location Master](#81-location-master)
   - 8.2 [Categories Master](#82-categories-master)
   - 8.3 [Session Master](#83-session-master)
   - 8.4 [Country & City](#84-country--city)
   - 8.5 [Role](#85-role)
   - 8.6 [Tenure](#86-tenure)
   - 8.7 [Tax Master](#87-tax-master)
   - 8.8 [Terms & Policy](#88-terms--policy)
9. [Other Services](#9-other-services)
   - 9.1 [Sub Service](#91-sub-service)
   - 9.2 [Time Slot](#92-time-slot)
   - 9.3 [Cart](#93-cart)
   - 9.4 [Order](#94-order)
   - 9.5 [Payment](#95-payment)
   - 9.6 [Currency](#96-currency)
   - 9.7 [Manager](#97-manager)
   - 9.8 [Articles](#98-articles)

---

## 1. Authentication

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/check-email` | No | Check if email exists. Body: `{ "email" }` |
| POST | `/auth/register` | Firebase token | Register user. **multipart/form-data:** profile_image, email, user_role, first_name, last_name, country, city, gender, address, age, password, emirates_id, etc. |
| POST | `/auth/login/:role_id` | Firebase token | Login. Body: `{ "emailOrPhone", "password", "provider?" }` |
| POST | `/auth/logout` | **Yes (JWT)** | Logout; clears cookies and refresh token. No body. |
| POST | `/auth/refresh-token` | No | Refresh access token. Body: `{ "refreshToken" }` or cookie |
| POST | `/auth/generate-otp` | No | Body: `{ "emailOrPhone" }` |
| POST | `/auth/verify-otp` | No | Body: `{ "emailOrPhone", "otp" }` |
| POST | `/auth/reset-password` | No | Body: `{ "emailOrPhone", "newPassword" }` |
| POST | `/auth/change-password` | Yes | Body: `{ "oldPassword", "newPassword" }` |
| GET | `/auth/current-user` | Yes | Get current user. No body. |
| PATCH | `/auth/update-account` | Yes | **multipart:** profile_image, first_name, last_name, phone_number |
| PATCH | `/auth/update-cover-image` | Yes | **multipart:** cover_image |
| POST | `/auth/create-fcm-token` | No | Body: `{ "user_id", "fcm_token", "device_type", "device_id" }` |

---

## 2. Customers

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/user/get-customers-filtered` | Yes | **Query:** country, city, gender, ageGroup (under18, 18to25, 26to35, 36to45, 46plus), isActive, subscriptionId, categoryId, isSingleClass. Returns filtered customers. |
| GET | `/user/get-all-user` | Yes | Get all users. |
| GET | `/user/get-userby-id/:id` | Yes | Get user by ID. |
| PATCH | `/user/update-user-status/:userId` | Yes (Admin) | Body: `{ "status": "Approved" \| "Rejected" \| ... }` |
| POST | `/user/create-user` | Yes | **multipart/form-data:** profile_image, email, user_role, first_name, last_name, phone_number, emirates_id, gender, address, age, country, city, specialization?, experience?, experienceYear?, password |
| PUT | `/user/update-user` | Yes | **multipart:** profile_image?, email, first_name, last_name, phone_number, … |
| DELETE | `/user/delete-user/:id` | Yes (Admin) | Delete user. |

**Address (customer):**

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/user/create-address` | Yes (Customer) | Body: `{ "name", "phone_number", "pincode", "street", "flat_no", "city", "country", "isDefault" }` |
| PUT | `/user/update-address/:id` | Yes (Customer) | Body: `{ "name?", "street?", "isDefault?", … }` |
| GET | `/user/get-address-by-id/:id` | Yes (Customer) | Get address by ID. |
| GET | `/user/get-all-address` | Yes (Customer) | Get all addresses of user. |
| DELETE | `/user/delete-address/:id` | Yes (Customer) | Delete address. |

---

## 3. Trainers

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/trainer/get-all-trainers` | Yes | Get all trainers (with averageRating, totalReviews). |
| GET | `/trainer/get-trainerBy-id/:id` | Yes | Get trainer by ID. |
| POST | `/trainer/create-trainer` | Yes (Admin) | **multipart:** profile_image, email, first_name, last_name, phone_number, gender, address, age, country, city, specialization, experience, experienceYear, password, serviceProvider (JSON array of IDs) |
| PUT | `/trainer/update-trainer/:id` | Yes (Admin) | **multipart:** same fields as create (partial). |
| PATCH | `/trainer/update-trainer-status/:trainerId` | Yes (Trainer) | Body: `{ "status": "active" \| "inactive" \| ... }` |
| DELETE | `/trainer/delete-trainer/:id` | Yes (Admin) | Delete trainer. |
| PUT | `/trainer/update-trainer-profiles/:trainerId` | Yes | **multipart:** Trainer self-update (first_name, last_name, profile_image, etc.) |
| GET | `/trainer/get-all-orders` | Yes (Trainer) | Get all orders for trainer. |
| POST | `/trainer/get-all-assigned-jobs` | Yes | Body: `{ "page", "limit", "status?" }` |
| GET | `/trainer/get-all-order-by-id/:id` | Yes | Get order details by ID. |
| POST | `/trainer/checkin/:orderDetailsId` | Yes | Body: `{ "checkinTime", "latitude", "longitude" }` |
| POST | `/trainer/initiate-checkout/:orderDetailsId` | Yes | Body: `{ "notes?" }` |
| POST | `/trainer/complete-checkout/:orderDetailsId` | Yes | Body: `{ "completionTime", "images?" }` |

---

## 4. Memberships

### 4.1 Programs / Classes (Subscription)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/subscription/create-subscription` | Yes (Admin) | **multipart:** media, name, categoryId, price, trainer, sessionType, description?, isActive, date (JSON array), startTime, endTime, Address (location ID), isSingleClass |
| PUT | `/subscription/update-subscription/:id` | Yes (Admin) | **multipart:** media?, name, price, description, … |
| POST | `/subscription/get-all-subscription` | No | Body: `{ "page", "limit", "categoryId?", "sessionTypeId?", "trainerId?" }` |
| GET | `/subscription/get-subscription-by-id/:id` | No | Get subscription by ID. |
| DELETE | `/subscription/delete-subscription/:id` | Yes (Admin) | Delete subscription. |
| POST | `/subscription/get-all-subscription/:categoryId` | No | Get subscriptions by category (body/params as used). |
| GET | `/subscription/get-subscriptions-by-session/:sessionTypeId` | No | By session type. |
| POST | `/subscription/get-subscriptions-by-date` | No | Body: `{ "date" }` |
| GET | `/subscription/get-subscriptions-by-trainer/:trainerId` | No | By trainer. |
| GET | `/subscription/get-subscriptions-by-loc-id/:locationId` | No | By location. |
| POST | `/subscription/get-subscriptions-filter` | No | Body: `{ "categoryId?", "sessionTypeId?", "trainerId?", "minPrice?", "maxPrice?", "sortBy?", "sortOrder?" }` |
| GET | `/subscription/search-subscriptions` | No | Query: `query` |
| GET | `/subscription/subscriptions/nearby` | Yes | Query: latitude, longitude, radius? |
| POST | `/subscription/get-subscriptions-by-coordinates` | No | Body: `{ "latitude", "longitude", "miles?" \| "radius?" }` |
| POST | `/subscription/get-trainer-Assigned-Subscriptions-filters` | Yes | Body: `{ "status?", "date?" }` |
| GET | `/subscription/trainer-class-stats` | Yes | Trainer class statistics. |
| POST | `/subscription/subscription-check-in/:subscriptionId` | Yes | Body: `{ "checkinTime", "latitude", "longitude" }` |
| POST | `/subscription/subscription-check-out/:subscriptionId` | Yes | Body: `{ "checkoutTime", "notes?" }` |

### 4.2 Membership (Package)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/package/create-package` | Yes (Admin) | **multipart:** image, name, description, price, duration, classesIncluded, isActive |
| PUT | `/package/update-package/:id` | Yes (Admin) | **multipart:** image?, name, description, price, duration, classesIncluded, isActive |
| POST | `/package/get-all-packages` | No | Body: `{ "page", "limit", "search?" }` |
| GET | `/package/get-package-by-id/:id` | No | Get package by ID. |
| DELETE | `/package/delete-package/:id` | Yes (Admin) | Delete package. |

### 4.3 Bookings

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/booking/create-manual-booking` | Yes | Body: subServiceId, timeslotId, bookingDate, groomerId, addressId, petDetails |
| PUT | `/booking/update-booking/:bookingId` | Yes | Body: `{ "bookingDate?", "timeslotId?" }` |
| GET | `/booking/get-all-bookings` | Yes | Get all bookings. |
| GET | `/booking/get-booking/:bookingId` | Yes | Get booking by ID. |
| DELETE | `/booking/delete-booking/:bookingId` | Yes | Delete booking. |
| POST | `/booking/subscribe` | Yes | Create subscription booking. Body: subscriptionId, paymentMethod, promoCode? |
| POST | `/booking/cancel-subscribe` | Yes | Body: `{ "bookingId", "reason?" }` |
| POST | `/booking/subscription-apply-promo` | Yes | Body: `{ "subscriptionId", "promoCode" }` |
| GET | `/booking/my-subscriptions` | Yes | Customer's subscription bookings. |
| GET | `/booking/get-all-subscriptionBooking` | Yes | All subscription bookings. |
| GET | `/booking/get-booking-by-id/:bookingId` | Yes | Single subscription booking by ID. |
| GET | `/booking/subscriptions-by-user-id/:userId` | No | Subscriptions by user ID. |
| GET | `/booking/get-expired-subscriptions` | Yes | Expired bookings for customer. |
| GET | `/booking/get-allCustomers-subscriptions/:subscriptionId` | Yes | Customers by subscription ID. |
| GET | `/booking/get-All-Subscription-Customers` | Yes | All subscription customers. |
| POST | `/booking/mark-Subscription-Attendance` | Yes | Body: subscriptionId, bookingId, attendanceStatus |

### 4.4 Package Bookings

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/package-booking/create-package-booking` | Yes | Body: `{ "packageId" }` |
| GET | `/package-booking/package-booking-activation/:bookingId` | Yes | Activate package booking. |
| POST | `/package-booking/package-booking-join-class` | Yes | Body: `{ "subscriptionId", "packageId" }` (or packageBookingId as per controller) |
| GET | `/package-booking/get-all-package-booking` | Yes | All package bookings. |
| GET | `/package-booking/get-package-booking-by-id/:id` | Yes | Package booking by ID. |
| GET | `/package-booking/get-package-booking-by-user-id/:userId` | Yes | By user ID. |
| GET | `/package-booking/get-customers-by-package--id/:packageId` | Yes | Customers by package ID. |
| GET | `/package-booking/get-all-joined-classes-user` | Yes | User's joined classes. |
| POST | `/package-booking/mark-attendance` | Yes | Body: packageBookingId, subscriptionId, attendanceStatus |

---

## 5. Promo Codes

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/admin/create-promo-code` | Yes (Admin) | **multipart:** image?, code, discountType, discountValue, description?, isActive?, is_validation_date?, startDate?, endDate?, apply_offer_after_orders?, minOrderAmount?, maxDiscountAmount?, maxUses, termsAndConditions |
| PUT | `/admin/update-promo-code/:id` | Yes (Admin) | **multipart:** same fields (all optional). |
| POST | `/admin/get-all-promo-codes` | Yes | Body: `{}` (optional). Returns all promo codes. |
| GET | `/admin/get-promo-code-by-id/:id` | Yes | Get promo by ID. |
| DELETE | `/admin/delete-promo-code/:id` | Yes (Admin) | Delete promo code. |

---

## 6. Payments

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/admin/get-all-orders` | Yes (Admin) | Get all orders (for payments/orders table). |
| GET | `/admin/get-dashboard-details` | Yes (Admin) | Dashboard stats (revenue, counts, etc.). |
| GET | `/admin/get-month-wise-data` | Yes (Admin) | Query: `year`. Month-wise data. |
| POST | `/payment/create-payment` | Yes | Body: `{ "orderId", "amount", "paymentMethod", "transactionId?" }` |
| POST | `/order/create-order` | Yes | Body: cartItems, addressId, paymentMethod, promoCode? |
| PUT | `/order/update-order` | Yes | Body: orderId, status?, notes? |
| GET | `/order/get-all-order` | Yes | Get all orders (user context). |
| GET | `/order/get-order-detail/:orderId` | Yes | Order details by order ID. |

---

## 7. Ratings

### 7.1 Trainer Ratings

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/user/get-all-trainer-reviews` | Yes | Get all trainer reviews. |
| GET | `/user/get-trainer-review/:trainerId` | Yes | Reviews for one trainer. |
| GET | `/user/trainer/my-reviews` | Yes (Trainer) | Current trainer's reviews. |
| POST | `/user/create-trainer-rating-review` | Yes (Customer) | Body: `{ "trainerId", "rating", "review?", "images?" }` |
| PUT | `/user/update-trainer-review/:trainerId` | Yes (Customer) | Body: `{ "rating?", "review?", "images?" }` |
| PUT | `/user/admin-hide-trainer-review/:reviewId` | Yes (Admin) | Body: `{ "isHidden": true \| false }` |
| POST | `/user/admin-reply-trainer-review/:reviewId` | Yes (Admin) | Body: `{ "reply": "..." }` |

### 7.2 Membership / Subscription Ratings

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/user/get-all-subscription-rating-review` | No | All subscription reviews. |
| GET | `/user/get-all-subscription-rating-review/:subscriptionId` | No | Reviews for one subscription. |
| GET | `/user/get-rating-review/:subscriptionId` | Yes | Current user's review for subscription. |
| POST | `/user/create-subscription-rating-review` | Yes (Customer) | Body: `{ "subscriptionId", "rating", "review?", "images?" }` |
| PUT | `/user/update-subscription-review/:subscriptionId` | Yes (Customer) | Body: `{ "rating?", "review?", "images?" }` |
| POST | `/user/reply-subscription-review/:reviewId` | Yes (Admin) | Body: `{ "reply": "..." }` |
| PUT | `/user/review-subscription-visibility/:reviewId` | Yes (Admin) | Body: `{ "isHidden": true \| false }` |
| GET | `/admin/get-all-subservice-rating-review/:subServiceId` | Yes (Admin) | Subservice rating reviews (if used). |

---

## 8. Masters

### 8.1 Location Master

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/master/create-location-master` | Yes (Admin) | Body: `{ "streetName", "country", "city", "landmark?", "is_active?", "location": [latitude, longitude] }` |
| PUT | `/master/update-location-master/:id` | Yes (Admin) | Body: `{ "streetName?", "country?", "city?", "landmark?", "is_active?", "location?": [lat, lng] }` |
| POST | `/master/get-all-location-master` | Yes | Body: `{ "filter?": { "country?", "city?" }, "page?", "limit?", "sortOrder?" }`; Query: `search` |
| GET | `/master/get-location-master/:id` | Yes (Admin) | Get location by ID. |
| GET | `/master/get-location-by-country-city` | Yes (Admin) | Query: `country`, `city`. |
| DELETE | `/master/delete-location-master-by-id/:id` | Yes (Admin) | Delete location. |

### 8.2 Categories Master

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/master/create-category` | Yes (Admin) | **multipart:** image?, cName, description |
| PUT | `/master/update-category/:id` | Yes (Admin) | **multipart:** image?, cName, description |
| GET | `/master/get-all-categories` | No | Get all categories. |
| GET | `/master/get-category-by-id/:id` | Yes | Get category by ID. |
| DELETE | `/master/delete-category/:id` | Yes (Admin) | Delete category. |

### 8.3 Session Master

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/master/create-session` | Yes (Admin) | **multipart:** image?, name, categoryId, description?, isActive |
| PUT | `/master/update-session/:id` | Yes (Admin) | **multipart:** image?, name, description? |
| GET | `/master/get-all-sessions` | No | Get all sessions. |
| GET | `/master/get-session-by-id/:id` | No | Get session by ID. |
| GET | `/master/get-session-by-category-id/:categoryId` | No | Sessions by category. |
| DELETE | `/master/delete-session/:id` | Yes (Admin) | Delete session. |

### 8.4 Country & City

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/master/create-country` | No | Body: `{ "name", "code", "isActive?" }` |
| PUT | `/master/update-country/:countryId` | No | Body: name, code, isActive |
| GET | `/master/get-all-country` | No | Get all countries. |
| GET | `/master/get-country/:id` | No | Get country by ID. |
| DELETE | `/master/delete-all-country` | No | Delete all countries. |
| POST | `/master/create-city` | No | Body: `{ "name", "country", "isActive?" }` |
| PUT | `/master/update-city/:cityId` | No | Body: name, country, isActive |
| GET | `/master/get-all-city/:countryId` | No | Get cities by country ID. |
| GET | `/master/get-city/:id` | No | Get city by ID. |
| DELETE | `/master/delete-all-city` | No | Delete all cities. |

### 8.5 Role

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/master/create-role` | No | Body: `{ "name", "isActive?" }` |
| PUT | `/master/update-role/:id` | Yes (Admin) | Body: name, isActive |
| POST | `/master/get-all-role` | Yes | Body: `{ "page?", "limit?" }` |
| GET | `/master/get-active-role` | Yes | Get active roles. |

### 8.6 Tenure

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/master/create-tenure` | Yes (Admin) | Body: `{ "name", "duration", "isActive?" }` |
| GET | `/master/get-all-tenure` | Yes | Get all tenures. |
| GET | `/master/get-tenure-by-id/:id` | Yes | Get tenure by ID. |
| PUT | `/master/update-tenure/:id` | Yes (Admin) | Body: name, duration |
| DELETE | `/master/delete-tenure/:id` | Yes (Admin) | Delete tenure. |

### 8.7 Tax Master

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/master/create-tax-master` | Yes (Admin) | Body: `{ "name", "percentage", "isActive?" }` |
| PUT | `/master/update-tax-master/:id` | Yes (Admin) | Body: name, percentage, isActive |
| POST | `/master/get-all-tax-master` | Yes | Body: `{ "page", "limit" }` |
| GET | `/master/get-all-tax` | Yes | Get all tax. |
| GET | `/master/get-tax-master/:id` | Yes (Admin) | Get tax by ID. |
| DELETE | `/master/delete-tax-master-by-id/:id` | Yes (Admin) | Delete tax. |

### 8.8 Terms & Policy

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/master/create-terms-n-policy` | Yes (Admin) | Body: `{ "type", "content", "version?" }` |
| PATCH | `/master/update-terms-n-policy/:policyId` | Yes (Admin) | Body: content, version |
| DELETE | `/master/delete-terms-n-policy/:id` | No | Delete policy. |
| GET | `/master/all-tnc` | No | Get all policies. |
| GET | `/master/get-all-terms` | No | Latest terms. |
| GET | `/master/get-all-privacy` | No | Latest privacy. |

---

## 9. Other Services

### 9.1 Sub Service

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/subservice/createSubService` | Yes (Admin) | **multipart:** image?, name, serviceTypeId, groomingDetails (JSON string) |
| PUT | `/subservice/updateSubService/:subServiceId` | Yes (Admin) | **multipart:** image?, name, groomingDetails? |
| GET | `/subservice/getSubServiceById/:subServiceId` | Yes (Admin) | Get subservice by ID. |
| POST | `/subservice/getAllSubService` | Yes (Admin) | Body: `{ "page", "limit", "search?" }` |
| DELETE | `/subservice/deleteSubService/:subServiceId` | Yes (Admin) | Delete subservice. |

### 9.2 Time Slot

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/timeslot/createTimeslot` | Yes (Admin) | Body: `{ "startTime", "endTime", "isActive?" }` |
| PUT | `/timeslot/updateTimeslot/:timeslotId` | Yes (Admin) | Body: startTime, endTime, isActive |
| GET | `/timeslot/getTimeslotById/:timeslotId` | Yes | Get timeslot by ID. |
| POST | `/timeslot/getAllTimeslots` | Yes | Body: `{ "page?", "limit?" }` |
| DELETE | `/timeslot/deleteTimeslot/:timeslotId` | Yes (Admin) | Delete timeslot. |
| POST | `/timeslot/getFreeGroomers` | Yes | Body: date, timeslotId |
| POST | `/timeslot/getAvailableTimeSlots/:subServiceId` | Yes | Body: date, groomerId? |
| POST | `/timeslot/markOfficeHoliday` | Yes | Body: date, reason |
| POST | `/timeslot/markGroomerHoliday` | Yes | Body: groomerId, date, reason |

### 9.3 Cart

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/cart/create-cart` | Yes | Body: subServiceId, quantity?, timeslotId, bookingDate, petDetails |
| GET | `/cart/get-all-cart` | Yes | Get all cart items. |
| DELETE | `/cart/delete-cart-item/:cartId` | Yes | Delete cart item. |
| POST | `/user/cart-total-price-calculate` | Yes (Customer) | Body: `{ "cartItems", "promoCode?" }` |

### 9.4 Order

*(Listed under [Payments](#6-payments) as well.)*

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/order/create-order` | Yes | Body: cartItems, addressId, paymentMethod, promoCode? |
| PUT | `/order/update-order` | Yes | Body: orderId, status?, notes? |
| GET | `/order/get-all-order` | Yes | Get all orders. |
| GET | `/order/get-order-detail/:orderId` | Yes | Order details. |

### 9.5 Payment

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/payment/create-payment` | Yes | Body: `{ "orderId", "amount", "paymentMethod", "transactionId?" }` |

### 9.6 Currency

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/currency/create-currency` | Yes | Body: code, name, symbol, isActive |
| PUT | `/currency/update-currency/:id` | Yes | Body: name, symbol, isActive |
| GET | `/currency/get-currency-by-id/:id` | Yes | Get currency by ID. |
| GET | `/currency/get-all-currencies` | Yes | Get all currencies. |
| DELETE | `/currency/delete-currency/:id` | Yes | Delete currency. |
| POST | `/currency/createOrUpdateExchange` | Yes | Body: fromCurrency, toCurrency, rate, isActive |
| GET | `/currency/getExchangeById/:id` | Yes | Get exchange by ID. |
| GET | `/currency/getAllExchanges` | Yes | Get all exchanges. |
| DELETE | `/currency/deleteExchange/:id` | Yes | Delete exchange. |

### 9.7 Manager

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/manager/create-manager` | Yes (Admin) | **multipart:** profile_image?, email, first_name, last_name, phone_number, password |
| PUT | `/manager/update-manger/:id` | Yes (Admin) | **multipart:** profile_image?, first_name, last_name, … |
| GET | `/manager/get-all-manager` | Yes (Admin) | Get all managers. |
| GET | `/manager/get-manager-by-id/:id` | Yes (Admin) | Get manager by ID. |
| DELETE | `/manager/delete-manager/:id` | Yes (Admin) | Delete manager. |

### 9.8 Articles

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/admin/create-artical` | Yes (Admin) | **multipart:** image (required), title, description? |
| PUT | `/admin/update-artical/:id` | Yes (Admin) | **multipart:** image?, title?, description? |
| GET | `/admin/get-all-articals` | Yes (Admin) | Get all articles. |
| GET | `/admin/get-artical/:id` | Yes (Admin) | Get article by ID. (Also `/user/get-artical/:id` for non-admin.) |
| DELETE | `/admin/delete-artical/:id` | Yes (Admin) | Delete article. |

---

## Admin / Dashboard helpers

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/admin/get-planner-dashboard` | Yes (Admin) | POST in router. Body: bookingDate, subServiceId? |
| POST | `/admin/get-all-available-groomers` | Yes (Admin) | Body: groomerId, timeSlotId, date |
| POST | `/admin/get-all-available-groomers-booking` | Yes (Admin) | Body: date, timeslot, subServiceId |
| GET | `/user/get-admin-details` | No | Get admin details. |
| GET | `/user/get-all-notification` | Yes | Get all notifications. |
| PUT | `/user/update-notification/:id` | Yes | Body: `{ "isRead": true }` |
| PUT | `/user/update-all-notification` | Yes | Mark all as read. |
| PUT | `/user/cancel-by-customer/::orderDetailsId` | Yes | Cancel by customer (note: double colon in path). |

---

*Generated from mobile-gym-backend routes. For request/response examples, see `API_ENDPOINTS_WITH_BODY.md` and `README.md`.*

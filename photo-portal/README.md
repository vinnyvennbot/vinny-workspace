# Event Photo Portal - Project Plan

**Goal:** Build photographer portal for uploading & selling event photos (like sfeventphoto.com)

**Timeline:** 10:37 PM - 7:00 AM PST (8.5 hours)

## Core Features (MVP)

### 1. Photographer Portal
- Upload photos (drag & drop, bulk upload)
- Create/manage events
- Set pricing per event or per photo
- Watermarking system
- Photo organization (tagging, albums)

### 2. Client Portal
- Browse events by date/name/code
- View photo galleries
- Search photos by face recognition (future)
- Shopping cart
- Purchase & download

### 3. Admin Dashboard
- Event management
- Photographer management
- Sales analytics
- Photo approval/moderation

### 4. Payment Integration
- Stripe for payments
- Digital delivery after purchase
- Receipt generation

### 5. Photo Delivery
- High-res downloads after purchase
- Watermarked previews
- Email delivery with download links

## Tech Stack

**Frontend:** Next.js 14 (App Router), TypeScript, Tailwind CSS
**Backend:** Next.js API routes, Prisma ORM
**Database:** PostgreSQL (or SQLite for dev)
**Storage:** AWS S3 / Cloudflare R2 (or local for dev)
**Payments:** Stripe
**Auth:** NextAuth.js

## Database Schema

```prisma
model User {
  id            String   @id @default(cuid())
  email         String   @unique
  name          String?
  role          Role     @default(CLIENT)
  events        Event[]  // photographer's events
  purchases     Purchase[]
  createdAt     DateTime @default(now())
}

model Event {
  id            String   @id @default(cuid())
  name          String
  date          DateTime
  accessCode    String   @unique
  photographer  User     @relation(fields: [photographerId], references: [id])
  photographerId String
  photos        Photo[]
  pricing       Json     // pricing config
  status        EventStatus @default(DRAFT)
  createdAt     DateTime @default(now())
}

model Photo {
  id            String   @id @default(cuid())
  event         Event    @relation(fields: [eventId], references: [id])
  eventId       String
  filename      String
  s3Key         String
  thumbnailKey  String
  watermarkedKey String
  price         Decimal
  tags          String[]
  metadata      Json
  purchases     PhotoPurchase[]
  createdAt     DateTime @default(now())
}

model Purchase {
  id            String   @id @default(cuid())
  user          User     @relation(fields: [userId], references: [id])
  userId        String
  photos        PhotoPurchase[]
  total         Decimal
  stripeId      String?
  status        PurchaseStatus
  createdAt     DateTime @default(now())
}

model PhotoPurchase {
  id            String   @id @default(cuid())
  purchase      Purchase @relation(fields: [purchaseId], references: [id])
  purchaseId    String
  photo         Photo    @relation(fields: [photoId], references: [id])
  photoId       String
  price         Decimal
}

enum Role {
  ADMIN
  PHOTOGRAPHER
  CLIENT
}

enum EventStatus {
  DRAFT
  PUBLISHED
  ARCHIVED
}

enum PurchaseStatus {
  PENDING
  COMPLETED
  FAILED
}
```

## Development Phases

### Phase 1: Setup (30 min)
- [x] Initialize Next.js project
- [ ] Set up Prisma + database
- [ ] Configure Tailwind CSS
- [ ] Set up file structure

### Phase 2: Auth & User Management (1 hour)
- [ ] NextAuth.js setup
- [ ] Login/register pages
- [ ] Role-based access control
- [ ] User dashboard

### Phase 3: Photographer Features (2 hours)
- [ ] Event creation/management
- [ ] Photo upload (single & bulk)
- [ ] Watermarking system
- [ ] Photo organization

### Phase 4: Client Features (2 hours)
- [ ] Event browsing
- [ ] Photo gallery
- [ ] Shopping cart
- [ ] Checkout flow

### Phase 5: Payment Integration (1 hour)
- [ ] Stripe setup
- [ ] Payment processing
- [ ] Order confirmation
- [ ] Email notifications

### Phase 6: Polish & Testing (2 hours)
- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] Error handling
- [ ] Testing

## Progress Log

**10:37 PM PST** - Project kickoff, created plan

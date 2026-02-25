# OnlyCars 🚗

Premium auto-services marketplace for Qatar. Connects car owners with workshops, parts shops, and delivery drivers.

## Architecture

- **Consumer App** — Flutter (iOS/Android) — Browse workshops, order parts, track repairs
- **Pro App** — Flutter (iOS/Android) — Workshop, Driver, and Shop modes  
- **Admin Dashboard** — Flutter Web — Manage users, orders, disputes
- **Backend** — Supabase (PostgreSQL + Auth + Realtime + Storage + Edge Functions)

## Monorepo Structure

```
onlycars/
├── apps/
│   ├── consumer/          # Consumer mobile app
│   ├── pro/               # Workshop/Driver/Shop app
│   └── admin/             # Admin web dashboard
├── packages/
│   ├── oc_models/         # Shared data models (Freezed)
│   ├── oc_api/            # Supabase API client
│   └── oc_ui/             # Design system (Arabic-first)
├── supabase/              # Database migrations + Edge Functions
└── .github/workflows/     # CI/CD
```

## Setup

```bash
# Install dependencies for each package
cd packages/oc_models && flutter pub get
cd ../oc_ui && flutter pub get  
cd ../oc_api && flutter pub get
cd ../../apps/consumer && flutter pub get
cd ../pro && flutter pub get
cd ../admin && flutter pub get
```

## Tech Stack

| Layer | Tech |
|-------|------|
| Frontend | Flutter 3.x |
| State | Riverpod |
| Navigation | GoRouter |
| Backend | Supabase |
| Auth | Phone OTP (Supabase Auth) |
| Maps | Google Maps Flutter |
| Payments | Sadad (Qatar) |
| Notifications | Firebase Cloud Messaging |

## License

Proprietary — OnlyCars © 2026

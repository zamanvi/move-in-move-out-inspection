# Move In Move Out Inspection

Flutter app: create move-in, move-out, HVAC & property inspection PDF reports on-site, fully offline, no web portal or account required.

## What's in this repo

- `lib/` — full app source (checklists, photo markup, digital signature, PDF export, offline storage via Hive, company branding)
- `.github/workflows/build.yml` — builds the Android APK/AAB entirely in GitHub's cloud. **Nothing needs to be installed on your PC.**
- `android/`, `ios/` etc. are intentionally **not** committed — the workflow generates them fresh on every build via `flutter create`, so there's nothing to keep in sync locally.

## How to publish this to GitHub (via GitHub Desktop)

1. Open **GitHub Desktop** → File → Add Local Repository → select this folder (`C:\Users\UseR\move-in-move-out-inspection`).
2. Click **Publish repository** (choose public or private — private is fine, Actions still runs).
3. Once pushed, go to the repo on GitHub.com → **Actions** tab. A build will start automatically.
4. When it finishes (a few minutes), open the run → **Artifacts** section at the bottom → download:
   - `app-release-apk` — install directly on an Android phone to test
   - `app-release-aab` — this is the file you upload to Play Console

## Before you upload to Play Console — 2 things to fix first

1. **Application ID**: the workflow currently uses a placeholder `com.tensai.move_in_move_out_inspection` (see `.github/workflows/build.yml`, the `--org com.tensai` flag). Change `com.tensai` to your own reverse-domain (e.g. `com.yourcompany`) — Play Console requires a unique, permanent application ID you control.
2. **Release signing**: right now the AAB builds with Flutter's default **debug** signing key (fine for the test APK, not for a real Play Store submission). Before your first real upload, you need a proper release keystore. Tell me when you're ready and I'll set up:
   - A `keytool`-generated keystore (Java is already installed on this machine)
   - GitHub Actions secrets to hold it securely
   - A signing step added to the workflow

## Store listing copy

### Title (27 chars)
Move In Move Out Inspection

Chosen over the more generic "Inspection Report Generator" because it targets a lower-competition, long-tail keyword for faster initial ranking. The app itself still covers HVAC, roof, and electrical checklists too.

### Short description (71 chars)
No portal login. Create move-in, move-out, HVAC & property PDF reports.

### Long description

```markdown
Generate professional move-in, move-out, and property condition reports directly from your phone or tablet — completely free, with no web portal, no separate account, no office computer needed.

Landlords, tenants, property managers, real estate agents, and maintenance contractors use this app to document a rental's condition the moment they walk through it, and turn it into a client-ready PDF on the spot.

KEY FEATURES
• Free to Use — no portal sign-up, no paywall to get started
• Move-In / Move-Out Checklists — built-in templates for rental condition reports, protecting both landlord and tenant deposits
• Instant PDF Export — create, edit, and send inspection reports without leaving the property
• Photo Annotations — snap photos during your walk-through and mark defects directly on the image
• Fully Custom Checklists — also covers HVAC maintenance, roof checks, and electrical safety inspections
• Digital Signatures — capture landlord and tenant sign-off on screen
• Offline Mode — keep working with no signal; everything syncs when you're back online
• Company Branding — add your logo, contact details, and terms to every report

PERFECT FOR
• Landlords & tenants — move-in/move-out condition reports that protect security deposits
• Property managers & real estate agents — rental turnover documentation
• Home inspectors & service technicians — HVAC, roof, and electrical checklists

Download free today and complete your first move-in or move-out report on-site.
```

## Monetization

Ships fully free for launch. Add paid tiers later once there's a user base — remember to update the Play Console "Contains ads" / "In-app purchases" disclosures whenever that changes.

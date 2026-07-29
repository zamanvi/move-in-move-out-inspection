# Inspection Report Generator

Flutter app: create home, rental, HVAC & property inspection PDF reports on-site, fully offline, no web portal or account required.

## What's in this repo

- `lib/` — full app source (checklists, photo markup, digital signature, PDF export, offline storage via Hive, company branding)
- `.github/workflows/build.yml` — builds the Android APK/AAB entirely in GitHub's cloud. **Nothing needs to be installed on your PC.**
- `android/`, `ios/` etc. are intentionally **not** committed — the workflow generates them fresh on every build via `flutter create`, so there's nothing to keep in sync locally.

## How to publish this to GitHub (via GitHub Desktop)

1. Open **GitHub Desktop** → File → Add Local Repository → select this folder (`C:\Users\UseR\inspection-report-app`).
2. Click **Publish repository** (choose public or private — private is fine, Actions still runs).
3. Once pushed, go to the repo on GitHub.com → **Actions** tab. A build will start automatically.
4. When it finishes (a few minutes), open the run → **Artifacts** section at the bottom → download:
   - `app-release-apk` — install directly on an Android phone to test
   - `app-release-aab` — this is the file you upload to Play Console

## Before you upload to Play Console — 2 things to fix first

1. **Application ID**: the workflow currently uses a placeholder `com.tensai.inspection_report_generator` (see `.github/workflows/build.yml`, the `--org com.tensai` flag). Change `com.tensai` to your own reverse-domain (e.g. `com.yourcompany`) — Play Console requires a unique, permanent application ID you control.
2. **Release signing**: right now the AAB builds with Flutter's default **debug** signing key (fine for the test APK, not for a real Play Store submission). Before your first real upload, you need a proper release keystore. Tell me when you're ready and I'll set up:
   - A `keytool`-generated keystore (Java is already installed on this machine)
   - GitHub Actions secrets to hold it securely
   - A signing step added to the workflow

## Store listing copy (already drafted)

- **Title:** Inspection Report Generator (27 chars)
- **Short description:** Free inspection PDF reports for property, HVAC & equipment - no portal login. (77 chars)
- **Long description:** see prior conversation — covers key features, target trades, and free-to-start positioning.

## Monetization

Ships fully free for launch. Add paid tiers later once there's a user base — remember to update the Play Console "Contains ads" / "In-app purchases" disclosures whenever that changes.

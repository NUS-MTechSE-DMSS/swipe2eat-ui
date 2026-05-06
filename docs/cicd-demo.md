# Swipe2Eat CI/CD Demo Guide

This project uses GitHub Actions as the CI/CD engine, Netlify for Flutter web deployment, and Firebase App Distribution for free Android tester distribution.

## Architecture

`GitHub commit -> GitHub Actions -> Flutter build/test/security -> Netlify + Firebase App Distribution`

- Source control and trigger: GitHub push or pull request.
- Build: Flutter dependency install and platform packaging.
- Test: Flutter unit tests, integration tests, and coverage artifacts.
- Performance: Lighthouse audit against the deployed staging web app.
- Security: Snyk dependency scan, Semgrep SAST, Gitleaks secret scan, and OWASP ZAP DAST baseline scan.
- Deployment: Netlify staging web deploy and Firebase Android APK distribution.

Container scanning is not part of the current pipeline because the frontend is deployed as static Netlify assets, not as a container image.

## Firebase Setup

Create one Firebase project and add two Android apps:

- Staging app:
  - App name: `Swipe2Eat Staging`
  - Android package: `edu.nus.swipe2eat.staging`
  - GitHub variable: `FIREBASE_ANDROID_APP_ID_STAGING`
- Production/manual release app:
  - App name: `Swipe2Eat`
  - Android package: `edu.nus.swipe2eat`
  - GitHub variable: `FIREBASE_ANDROID_APP_ID_PROD`

In Firebase App Distribution, add tester emails directly. Store the comma-separated tester list in each GitHub environment as:

```text
FIREBASE_APPDISTRO_TESTERS=person1@example.com,person2@example.com
```

Create a Google Cloud service account for CI, grant it Firebase App Distribution upload permissions, download the JSON key, then store the base64 value as:

```text
FIREBASE_APPDISTRO_SERVICE_ACCOUNT_JSON_BASE64
```

## Android Signing

Generate one Android release keystore and keep it out of git:

```bash
keytool -genkeypair \
  -v \
  -keystore upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

Store these GitHub secrets:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

On macOS, encode the keystore with:

```bash
base64 -i upload-keystore.jks
```

## Demo Flow

1. Show the architecture: GitHub Actions, Flutter, Snyk, Semgrep, Gitleaks, Netlify, Firebase.
2. Push a harmless commit to `main`.
3. Open `Main Validation` in GitHub Actions and show:
   - format
   - analyze
   - unit tests with coverage
   - web integration
   - Android integration or Android test package
   - security scans
   - generated artifacts
4. Open `Staging Deploy`, triggered by the successful validation run.
5. Show the Netlify staging deployment URL.
6. Show the Lighthouse score summary and the `staging-lighthouse-report` artifact.
7. Show the OWASP ZAP `staging-zap-baseline-report` artifact for DAST coverage.
8. Show the Firebase App Distribution summary with the Android tester install link.
9. Open the deployed web app in a browser.

## Quality Attributes

- Maintainability: automated format, analysis, tests, coverage, and deployment checks in GitHub Actions.
- Performance: scripted Lighthouse audit runs against the deployed staging web app and uploads the report.
- Scalability: the Flutter web frontend is deployed as static assets on Netlify, so scaling is handled by managed CDN-backed hosting instead of an app server.

## Manual Android Release

Run the `Release` workflow manually with:

- `target_platforms`: `android` or `mobile`
- `version`: semantic version, for example `1.0.1`
- `release_notes`: tester-facing release notes

The workflow builds `app-prod-release.apk`, uploads it to Firebase App Distribution, and stores the APK as a GitHub Actions artifact.

## iOS Status

iOS deployment is intentionally disabled. Firebase App Distribution can host iOS builds, but installable iOS builds still require Apple signing and a provisioning profile. That requires an Apple Developer account/team, so it is outside the free college-project setup.

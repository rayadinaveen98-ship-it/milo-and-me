#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tool/bootstrap_android.py
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --debug

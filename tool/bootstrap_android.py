"""Obtain only the official Gradle wrapper from an installed Flutter SDK.
Never downloads an arbitrary wrapper binary or overwrites app source.
"""
import pathlib, shutil, subprocess, tempfile
root=pathlib.Path(__file__).resolve().parents[1]
flutter=shutil.which('flutter')
if not flutter:raise SystemExit('Flutter SDK is required. Install Flutter 3.35.7 or run the included Android CI workflow.')
with tempfile.TemporaryDirectory(prefix='milo-flutter-') as temp:
 scaffold=pathlib.Path(temp)/'wrapper_scaffold'
 subprocess.run([flutter,'create','--platforms=android','--project-name=wrapper_scaffold','--no-pub',str(scaffold)],check=True)
 for name in ['gradlew','gradlew.bat','gradle','local.properties']:
  src=scaffold/'android'/name;dst=root/'android'/name
  if src.is_dir():shutil.copytree(src,dst,dirs_exist_ok=True)
  elif src.exists():shutil.copy2(src,dst)
 print('Official Flutter wrapper and local SDK paths prepared.')

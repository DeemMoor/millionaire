#!/usr/bin/env bash
# Builds the Windows app from WSL: syncs the project to the Windows drive
# (MSBuild doesn't like \\wsl$ paths) and runs the Windows Flutter SDK there.
set -euo pipefail

src="$(cd "$(dirname "$0")/.." && pwd)"
dst=/mnt/c/dev/millionaire-build
flutter_win='C:\dev\flutter\bin\flutter.bat'

rsync -a --delete --exclude build/ --exclude .dart_tool/ --exclude .git/ "$src/" "$dst/"
cd /mnt/c
cmd.exe /c "cd /d C:\\dev\\millionaire-build && $flutter_win build windows --release"

echo "Built: C:\\dev\\millionaire-build\\build\\windows\\x64\\runner\\Release\\millionaire.exe"

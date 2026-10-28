# Выпуск версий и автообновление «Миллионера»

Схема взята из MD Reader (github.com/DeemMoor/md-reader), где она уже работает: тег `vX.Y.Z` → GitHub Actions собирает все платформы и публикует веб-версию → GitHub Release с описанием из `CHANGELOG.md` и `SHA256SUMS.txt` → программа сама находит новую версию и ставит её.

## Что сейчас и что поменять

| Сейчас | Проблема | Как надо |
|---|---|---|
| Windows собирается скриптом `tool/build_windows.sh`: копия проекта в `C:\dev\millionaire-build` и Flutter для Windows | Сборка зависит от одного компьютера; результат — папка с exe, которую надо раздавать вручную | Сборка в GitHub Actions на `windows-latest`: там нет проблемы с путями `\\wsl$`, копировать проект не нужно |
| Веб собирается вручную и смотрится через `tool/serve.mjs` | Веб — приоритетная платформа, но её нет в интернете | Публикация на GitHub Pages при каждом выпуске |
| Нет CI вообще | Тесты запускаются только вручную | `ci.yml` с тестами на каждый пуш, `release.yml` на тег |
| Версия `1.0.0+1` не меняется | Программа не может понять, что вышла новая версия | Версия в `pubspec.yaml` поднимается при каждом выпуске |
| Нет установщика для Windows | Нет ярлыков, удаления; обновлять нечем | Установщик Inno Setup с тихим режимом |
| APK подписывается debug-ключом (`signingConfigs.getByName("debug")`) | Когда дойдёт до Android: на каждом раннере GitHub debug-ключ свой, новый APK не встанет поверх старого | Постоянный ключ подписи (раздел 3), сделать до первого выпуска APK |

`tool/build_windows.sh` можно оставить для локальной проверки.

## 1. Версия и CHANGELOG

- Версия живёт в одном месте — `pubspec.yaml`, `version: X.Y.Z+N`. Часть `+N` (build number, для Android это `versionCode`, который обязан только расти) CI подставляет сам из номера запуска: `--build-number=${{ github.run_number }}`. Вручную меняется только `X.Y.Z`.
- В корне `CHANGELOG.md`. Каждое заметное для игрока изменение записывается в раздел «Не выпущено» тем же коммитом, что и код:

  ```markdown
  # Что нового в «Миллионере»

  ## Не выпущено

  - Фирмы продаются банку перед банкротством.
  ```

- Выпуск:
  1. Раздел «Не выпущено» переименовать в `## 1.1.0 — 2026-11-02`, в `pubspec.yaml` поставить `version: 1.1.0+1`.
  2. Коммит, тег, пуш:

     ```sh
     git tag v1.1.0
     git push origin main v1.1.0
     ```

  3. Сборка проверит, что тег совпадает с версией и что в CHANGELOG есть раздел этой версии, иначе остановится. Текст раздела станет описанием релиза, его же программа покажет в окне «Что нового».

## 2. Установщик для Windows (Inno Setup)

Файл `packaging/windows/installer.iss`. Сохранить в **UTF-8 с BOM**, иначе Inno Setup испортит кириллицу.

```iss
#define Name "Миллионер"
#define Exe "millionaire.exe"
; Version comes from the command line: ISCC /DVersion=1.1.0

[Setup]
; Never change AppId: updates find the installed copy by it.
AppId={{9602C40E-4322-41F9-A734-05BC41FA4688}
AppName={#Name}
AppVersion={#Version}
AppPublisher=DeemMoor
AppPublisherURL=https://github.com/DeemMoor/millionaire
; Per-user install: no admin rights, updates run without a UAC prompt.
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\{#Name}
DisableProgramGroupPage=yes
OutputDir=..\..\dist
OutputBaseFilename=millionaire-{#Version}-windows-setup
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#Exe}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
; Closes the running game before replacing files.
CloseApplications=force

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[InstallDelete]
; Assets of the previous version must not linger next to the new ones.
Type: filesandordirs; Name: "{app}\data"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\{#Name}"; Filename: "{app}\{#Exe}"
Name: "{autodesktop}\{#Name}"; Filename: "{app}\{#Exe}"; Tasks: desktopicon

[Run]
; Normal install: "Launch" checkbox on the last page.
Filename: "{app}\{#Exe}"; Description: "{cm:LaunchProgram,{#Name}}"; Flags: nowait postinstall skipifsilent
; Silent install (the in-app update): start the new version right away.
Filename: "{app}\{#Exe}"; Flags: nowait; Check: WizardSilent
```

Ключи командной строки, которые использует автообновление: `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART` — ни одного окна и кнопки, установщик закрывает игру, заменяет файлы и запускает новую версию.

Локально: после `tool/build_windows.sh` запустить на Windows `ISCC.exe /DVersion=1.1.0 C:\dev\millionaire-build\packaging\windows\installer.iss`. Пути в скрипте относительные, поэтому он берёт сборку из той же копии проекта.

## 3. Ключ подписи Android

Нужен до первого выпуска APK. **Ключ и пароли сохранить в надёжном месте**: если ключ потерять, ни одно следующее обновление не встанет поверх установленной игры.

1. Создать ключ:

   ```sh
   keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. В репозитории на GitHub: Settings → Secrets and variables → Actions, добавить секреты:
   - `ANDROID_KEYSTORE` — содержимое `base64 -w0 upload.jks`;
   - `ANDROID_KEYSTORE_PASSWORD` и `ANDROID_KEY_PASSWORD` — пароли из шага 1.
3. В `android/app/build.gradle.kts` читать ключ из `key.properties`, а если его нет (локальная отладка) — остаться на debug-ключе:

   ```kotlin
   import java.util.Properties

   val keyProps = Properties().apply {
       val file = rootProject.file("key.properties")
       if (file.exists()) file.inputStream().use { load(it) }
   }

   android {
       // ...
       signingConfigs {
           create("release") {
               if (!keyProps.isEmpty) {
                   storeFile = file(keyProps.getProperty("storeFile"))
                   storePassword = keyProps.getProperty("storePassword")
                   keyAlias = keyProps.getProperty("keyAlias")
                   keyPassword = keyProps.getProperty("keyPassword")
               }
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName(if (keyProps.isEmpty) "debug" else "release")
           }
       }
   }
   ```

4. В `.gitignore` добавить `*.jks` и `key.properties`.

## 4. GitHub Actions

### Проверка пушей — `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.47.8
          cache: true
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

### Выпуск — `.github/workflows/release.yml`

Перед первым запуском: Settings → Pages → Source: **GitHub Actions**. Веб-версия будет по адресу `https://deemmoor.github.io/millionaire/`.

```yaml
name: Release

on:
  push:
    tags: ["v*"]

permissions:
  contents: write

env:
  FLUTTER_VERSION: 3.47.8

jobs:
  check:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
    steps:
      - uses: actions/checkout@v7
      - id: version
        name: Tag, version and changelog agree
        run: |
          version="${GITHUB_REF_NAME#v}"
          app=$(sed -n 's/^version: *\([^+]*\).*/\1/p' pubspec.yaml)
          [ "$app" = "$version" ] || { echo "::error::Tag $GITHUB_REF_NAME does not match pubspec.yaml version $app"; exit 1; }
          awk -v v="$version" '/^## /{p = ($2 == v); next} p' CHANGELOG.md > notes.md
          grep -q "[^[:space:]]" notes.md || { echo "::error::CHANGELOG.md has no section for $version"; exit 1; }
          echo "version=$version" >> "$GITHUB_OUTPUT"
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter test

  web:
    needs: check
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deploy.outputs.page_url }}
    steps:
      - uses: actions/checkout@v7
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      # The site lives under /millionaire/, not at the domain root.
      - run: flutter build web --release --wasm --no-web-resources-cdn --base-href /millionaire/
      - uses: actions/upload-pages-artifact@v4
        with:
          path: build/web
      - id: deploy
        uses: actions/deploy-pages@v4

  windows:
    needs: check
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v7
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter build windows --release --build-number=${{ github.run_number }}
      # Flutter needs the VC++ runtime; ship it next to the exe so users don't have to install it.
      - name: Bundle VC++ runtime
        shell: pwsh
        run: Copy-Item C:\Windows\System32\msvcp140.dll, C:\Windows\System32\vcruntime140.dll, C:\Windows\System32\vcruntime140_1.dll build\windows\x64\runner\Release\
      - name: Installer
        shell: pwsh
        run: |
          choco install innosetup -y --no-progress
          $iscc = Get-ChildItem "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe", "$env:ProgramFiles\Inno Setup 6\ISCC.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
          & $iscc.FullName "/DVersion=${{ needs.check.outputs.version }}" packaging\windows\installer.iss
          if ($LASTEXITCODE) { exit $LASTEXITCODE }
      - uses: actions/upload-artifact@v7
        with:
          name: windows
          path: dist/*
          if-no-files-found: error

  macos:
    needs: check
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v7
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter build macos --release --build-number=${{ github.run_number }}
      - name: DMG
        run: |
          mkdir -p dist staging
          cp -R build/macos/Build/Products/Release/millionaire.app staging/
          ln -s /Applications staging/Applications
          hdiutil create -volname "Миллионер" -srcfolder staging -ov -format UDZO \
            "dist/millionaire-${{ needs.check.outputs.version }}-macos.dmg"
      - uses: actions/upload-artifact@v7
        with:
          name: macos
          path: dist/*
          if-no-files-found: error

  linux:
    needs: check
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v7
      - name: Linux build dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: flutter build linux --release --build-number=${{ github.run_number }}
      - name: Archive
        run: |
          mkdir -p dist
          tar -czf "dist/millionaire-${{ needs.check.outputs.version }}-linux-x64.tar.gz" -C build/linux/x64/release/bundle .
      - uses: actions/upload-artifact@v7
        with:
          name: linux
          path: dist/*
          if-no-files-found: error

  release:
    needs: [check, windows, macos, linux]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Release notes
        run: awk -v v="${GITHUB_REF_NAME#v}" '/^## /{p = ($2 == v); next} p' CHANGELOG.md > notes.md
      - uses: actions/download-artifact@v8
        with:
          path: dist
          merge-multiple: true
      - name: Checksums
        run: cd dist && sha256sum * > SHA256SUMS.txt && cat SHA256SUMS.txt
      - uses: softprops/action-gh-release@v3
        with:
          files: dist/*
          body_path: notes.md
```

Файлы релиза: `millionaire-X.Y.Z-windows-setup.exe`, `millionaire-X.Y.Z-macos.dmg`, `millionaire-X.Y.Z-linux-x64.tar.gz`, `SHA256SUMS.txt`. Автообновление ищет файлы по этим окончаниям, поэтому имена менять согласованно.

Android добавляется, когда до него дойдёт очередь: задание `android` с ключом из раздела 3 и `flutter build apk`, файл `millionaire-X.Y.Z.apk`, плюс `android` в `needs` у `release`. iOS без платного аккаунта Apple Developer раздать нельзя.

`.github/dependabot.yml`, чтобы версии actions обновлялись сами:

```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: monthly
```

## 5. Автообновление в игре

Как работает:

1. Раз в сутки при запуске игра спрашивает GitHub API о последнем релизе (`/repos/DeemMoor/millionaire/releases/latest`) и сравнивает его версию со своей. Без авторизации GitHub даёт 60 запросов в час с одного адреса, раз в сутки — с запасом.
2. Если вышла новая, показывает кнопку «Обновление» и окно «Что нового» с текстом релиза (это раздел CHANGELOG).
3. По нажатию:
   - **Windows** — скачивает установщик, сверяет SHA-256 с `SHA256SUMS.txt` из того же релиза, запускает его с `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART` и закрывает игру. Установщик заменяет файлы и сам запускает новую версию. Пользователь не нажимает ни одной кнопки установщика.
   - **Android** — открывает ссылку на APK, система скачивает его и предлагает установить поверх (работает только при постоянном ключе подписи, см. раздел 3).
   - **macOS и Linux** — открывает страницу релиза.
   - **Web** — проверка не нужна, при перезагрузке страницы и так открывается новая версия.

Обновление ставится только по нажатию, не посреди партии: игрок должен сам решить, когда закрыть игру. Если партию можно сохранить, сохранить её перед запуском установщика.

Зависимости в `pubspec.yaml`: `http`, `crypto`, `package_info_plus`, `url_launcher` (`shared_preferences` уже есть — в нём хранить время последней проверки и настройку «Проверять обновления»). Пункт «Проверить обновления» удобно добавить в меню рядом со справкой.

`dart:io` в веб-сборке не работает, поэтому код обновления подключается условным импортом:

```dart
// lib/update/update.dart
export 'update_stub.dart' if (dart.library.io) 'update_io.dart';
```

`update_stub.dart` — те же функции, `checkForUpdate()` возвращает `null`. Основная часть, `update_io.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _latest = 'https://api.github.com/repos/DeemMoor/millionaire/releases/latest';

class Release {
  Release(this.version, this.notes, this.page, this.installer, this.checksums);

  final String version;

  /// Markdown from the release description, i.e. this version's CHANGELOG section.
  final String notes;
  final String page;

  /// The file this platform can install itself, if any.
  final String? installer;
  final String? checksums;
}

/// The latest release if it is newer than this build, otherwise null.
Future<Release?> checkForUpdate() async {
  final res = await http.get(Uri.parse(_latest), headers: {'Accept': 'application/vnd.github+json'});
  if (res.statusCode != 200) throw HttpException('GitHub answered ${res.statusCode}');
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  final version = (json['tag_name'] as String).replaceFirst(RegExp('^v'), '');
  final current = (await PackageInfo.fromPlatform()).version;
  if (!isNewer(version, current)) return null;
  final assets = (json['assets'] as List).cast<Map<String, dynamic>>();
  String? asset(bool Function(String name) match) => assets
      .where((a) => match(a['name'] as String))
      .map((a) => a['browser_download_url'] as String)
      .firstOrNull;
  return Release(
    version,
    json['body'] as String? ?? '',
    json['html_url'] as String,
    Platform.isWindows
        ? asset((n) => n.endsWith('-windows-setup.exe'))
        : Platform.isAndroid
            ? asset((n) => n.endsWith('.apk'))
            : null,
    asset((n) => n == 'SHA256SUMS.txt'),
  );
}

bool isNewer(String candidate, String current) {
  List<int> parts(String v) =>
      v.split(RegExp(r'[.+-]')).take(3).map((p) => int.tryParse(p) ?? 0).toList();
  final a = parts(candidate), b = parts(current);
  for (var i = 0; i < 3; i++) {
    final x = i < a.length ? a[i] : 0, y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

/// Windows: download, verify against SHA256SUMS.txt, run the installer silently and quit;
/// the installer starts the new version. Android: hand the APK to the system.
/// Elsewhere: open the release page.
Future<void> install(Release r) async {
  final url = r.installer;
  if (url == null) {
    await launchUrl(Uri.parse(r.page), mode: LaunchMode.externalApplication);
    return;
  }
  if (Platform.isAndroid) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    return;
  }
  final name = url.split('/').last;
  final listing = r.checksums;
  if (listing == null) throw StateError('the release has no SHA256SUMS.txt');
  final expected = (await http.read(Uri.parse(listing)))
      .split('\n')
      .map((line) => line.trim().split(RegExp(r'\s+')))
      .where((p) => p.length == 2 && p[1].replaceFirst('*', '') == name)
      .map((p) => p[0].toLowerCase())
      .firstOrNull;
  if (expected == null) throw StateError('$name is not listed in SHA256SUMS.txt');

  final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}$name');
  final response = await http.Client().send(http.Request('GET', Uri.parse(url)));
  await response.stream.pipe(file.openWrite());
  final actual = (await sha256.bind(file.openRead()).first).toString();
  if (actual != expected) {
    await file.delete();
    throw StateError('checksum mismatch, the file is damaged or replaced');
  }
  await Process.start(file.path, ['/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART'],
      mode: ProcessStartMode.detached);
  exit(0);
}
```

Для индикатора загрузки можно считать байты из `response.stream` и сравнивать с `response.contentLength`.

## 6. Подпись и предупреждения систем

- **Windows**: неподписанный установщик SmartScreen встречает окном «Windows защитила ваш компьютер» (Подробнее → Выполнить в любом случае). Бесплатная подпись для открытых проектов — SignPath Foundation (signpath.org), подписывает прямо в GitHub Actions. Условия: OSI-лицензия (в репозитории сейчас нет файла `LICENSE`), страница Code signing policy, ручное подтверждение каждого выпуска.
- **macOS**: без аккаунта Apple Developer (99 $ в год) приложение не подписано и не нотаризовано, при первом запуске: правый клик → Открыть, либо `xattr -cr /Applications/millionaire.app`.
- **Web**: подпись не нужна.

## Порядок внедрения

1. `ci.yml` и `dependabot.yml` — тесты на каждый пуш.
2. `CHANGELOG.md`, версия `1.0.0` → первая запись.
3. `packaging/windows/installer.iss` (раздел 2).
4. `release.yml`, включить GitHub Pages (раздел 4).
5. Пробный выпуск `v1.0.0`: проверить веб-версию на GitHub Pages и установку на Windows.
6. Автообновление в игре (раздел 5), затем выпуск `v1.0.1` — на нём проверить, что обновление с 1.0.0 проходит без единой кнопки.
7. Когда дойдёт до Android — ключ подписи (раздел 3) до первого выпуска APK.

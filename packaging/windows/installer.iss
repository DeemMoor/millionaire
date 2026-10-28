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

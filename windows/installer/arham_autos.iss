[Setup]
AppName=Arham Autos Desktop Suite
AppVersion=1.0.0
AppPublisher=Arham Autos
DefaultDirName={autopf}\Arham Autos Desktop Suite
DefaultGroupName=Arham Autos
OutputDir=..\..\build\windows\installer
OutputBaseFilename=ArhamAutosSetup
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
UninstallDisplayIcon={app}\arham_autos.exe

[Dirs]
; Create APPDATA directory explicitly to ensure it exists for the app database and logs
Name: "{userappdata}\ArhamAutos"; Permissions: users-modify

[Files]
; Core application binaries
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{group}\Arham Autos"; Filename: "{app}\arham_autos.exe"
Name: "{commondesktop}\Arham Autos"; Filename: "{app}\arham_autos.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

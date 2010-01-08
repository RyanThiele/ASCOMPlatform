; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

; Added [Run] section to make the driver self register

#define MyAppName "ASCOM Rotator Simulator 32/64-bit Update"
#define MyAppVerName "ASCOM Rotator Simulator 32/64-bit Update 1.0.2"
#define MyAppPublisher "The ASCOM Initiative"
#define MyAppURL "http://ascom-standards.org/"
#define MyAppVersion "1.0.2"

[Setup]
AppName={#MyAppName}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={cf32}\ASCOM\Rotator
DisableDirPage=yes
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=RotSim-32-64-bit(1.0.3)
Compression=lzma
SolidCompression=yes
Uninstallable=no
DirExistsWarning=no
WizardImageFile="C:\Program Files\ASCOM\InstallGen\Resources\WizardImage.bmp"


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\RotatorDriver\bin\Release\ASCOM.Simulator.Rotator.dll"; DestDir: "{app}\RotatorSimulatorServedClasses"; Flags: ignoreversion
Source: "..\RotatorDriver\bin\Release\ASCOM.RotatorSimulator.exe"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\ASCOM.RotatorSimulator.exe"; Parameters: "/regserver"; StatusMsg: "Registering Rotator Simulator"; Flags: runhidden
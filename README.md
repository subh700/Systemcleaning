# README

This PowerShell command runs `clean.ps1` and targets files with these extensions:

- `.c`
- `.cpp`
- `.skm`
- `.python`

Command:

```powershell
powershell -ExecutionPolicy Bypass -File .\clean.ps1 -Extensions ".c",".cpp",".skm",".python"
```

## Which files are deleted

The script scans these locations and deletes matching files after confirmation:

- User profile folders under `C:\Users`
- Extra drives if present: `D:\`, `E:\`, `F:\`, `G:\`, `H:\`

A file is deleted only if:

- Its extension is one of `.c`, `.cpp`, `.skm`, `.python`
- Its path is **not** inside `\AppData\`
- Its path is **not** inside `\Contacts\`
- Its path does **not** contain any folder segment that starts with `.`
- You type `YES` when prompted

## Important note about the extensions

The script deletes files only by extension. It does **not** check whether they are system files.

Typical meaning of the requested extensions:

- `.c` → C source code files
- `.cpp` → C++ source code files
- `.skm` → custom/application-specific file type, not a common Windows system file extension
- `.python` → uncommon extension, usually custom text or script files; normal Python files usually use `.py`

So this command is mainly deleting developer, project, or custom files that match those extensions, not normal Windows system files.

## Safety warning

Be careful with this command because it searches broadly across user folders and other drives. If you have programming projects, backups, datasets, or custom software files with these extensions, they can be removed permanently.

## Safer test

To preview deletion behavior, use the script's optional switch:

```powershell
powershell -ExecutionPolicy Bypass -File .\clean.ps1 -Extensions ".c",".cpp",".skm",".python" -WhatIfOnly
```


```powershell
powershell -ExecutionPolicy Bypass -File .\clean.ps1 -Extensions ".c",".cpp",".skm",".python"
```

That lets the script simulate removal with `Remove-Item -WhatIf` instead of actually deleting files.





# README

This PowerShell command runs `network_on_off.ps1` and targets files with these extensions:

-'powershell run as administareter'

```powershell
powershell -ExecutionPolicy Bypass -File .\network-on-off.ps1 -DisableAll
```


```powershell
powershell -ExecutionPolicy Bypass -File .\network-on-off.ps1 -EnableAll
```

Command:

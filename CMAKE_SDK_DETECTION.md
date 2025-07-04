# 3ds Max SDK Detection in CMake

This project uses an advanced 3ds Max SDK detection system that works across different developer environments and computer setups.

## Automatic Detection

The CMake configuration automatically searches for 3ds Max SDKs in the following order:

### 1. Environment Variables
The system checks for these environment variable patterns:
- `ADSK_3DSMAX_SDK_2025`, `ADSK_3DSMAX_SDK_2024`, etc. (Direct SDK paths)
- `3DSMAX_SDK_2025`, `3DSMAX_SDK_2024`, etc. (Alternative SDK paths)
- `MAX_SDK_2025`, `MAX_SDK_2024`, etc. (Generic SDK paths)
- `ADSK_3DSMAX_x64_2025`, `ADSK_3DSMAX_x64_2024`, etc. (Installation paths + SDK subdirectory)
- `ADSK_3DSMAX_2025`, `ADSK_3DSMAX_2024`, etc. (Installation paths)

### 2. Common Installation Directories
The system searches these directories for SDK installations:
- `C:/Program Files/Autodesk/3ds Max {VERSION} SDK/maxsdk`
- `C:/Program Files (x86)/Autodesk/3ds Max {VERSION} SDK/maxsdk`
- `D:/Program Files/Autodesk/3ds Max {VERSION} SDK/maxsdk`
- `F:/Program Files/Autodesk/3ds Max {VERSION} SDK/maxsdk` 
- And other common drive letters and directory structures

### 3. Supported Versions
The system automatically detects these 3ds Max versions:
- 2025, 2024, 2023, 2022, 2021, 2020, 2019, 2018, 2017, 2016, 2015, 2014, 2013, 2012

## What You'll See During Configuration

When running CMake, you'll see output like:
```
-- Searching for 3ds Max SDK through environment variables...
-- Found 3ds Max 2025 SDK via ADSK_3DSMAX_x64_2025: F:\Program Files\Autodesk\3ds Max 2025\..\3ds Max 2025 SDK/maxsdk
-- Found 3ds Max 2024 SDK via ADSK_3DSMAX_x64_2024: F:\Program Files\Autodesk\3ds Max 2024\..\3ds Max 2024 SDK/maxsdk
-- Searching for 3ds Max SDK in common installation directories...
-- Found 2 3ds Max SDK installation(s)
-- Using 3ds Max 2025 SDK: F:\Program Files\Autodesk\3ds Max 2025\..\3ds Max 2025 SDK/maxsdk
-- Other available SDKs:
--   - 3ds Max 2024: F:\Program Files\Autodesk\3ds Max 2024\..\3ds Max 2024 SDK/maxsdk
```

## Manual Override

If you need to use a specific SDK version or path:

### Option 1: Set Environment Variable
Set one of the supported environment variables, for example:
```bash
# Windows Command Prompt
set ADSK_3DSMAX_SDK_2024=C:\Path\To\Your\3dsMax2024SDK\maxsdk

# PowerShell
$env:ADSK_3DSMAX_SDK_2024="C:\Path\To\Your\3dsMax2024SDK\maxsdk"
```

### Option 2: CMake Cache Variable
```bash
cmake .. -DMAX_SDK_PATH="C:/Path/To/Your/3dsMaxSDK/maxsdk"
```

### Option 3: CMake GUI
Use the CMake GUI to set the `MAX_SDK_PATH` variable.

## Building Multiple Versions

The system automatically builds targets for all detected SDK versions:
- `3DsMax-2025` (if 2025 SDK found)
- `3DsMax-2024` (if 2024 SDK found)
- etc.

Each target produces a corresponding `.dlu` file for that 3ds Max version.

## Troubleshooting

### No SDK Found
If no SDK is detected:
1. Verify your 3ds Max SDK is installed
2. Check that the SDK directory contains `include/max.h`
3. Set an environment variable manually (see Manual Override above)
4. Check the CMake output for search paths being tried

### Wrong SDK Selected
If the wrong SDK is being used:
1. Use the manual override options above
2. Set a more specific environment variable for your preferred version
3. Check that your preferred SDK has the correct directory structure

### Multiple Installations
The system will list all found SDKs and their locations, making it easy to see what's available and choose the right one.

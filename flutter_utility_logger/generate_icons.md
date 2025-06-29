# App Icon Generation Guide

## Step 1: Convert SVG to PNG

You need to convert the `assets/app_icon.svg` file to PNG format. Here are several options:

### Option A: Online Converters
1. Go to https://convertio.co/svg-png/ or https://cloudconvert.com/svg-to-png
2. Upload the `assets/app_icon.svg` file
3. Download the converted PNG file
4. Save it as `assets/app_icon.png`

### Option B: Using ImageMagick (if installed)
```bash
magick assets/app_icon.svg assets/app_icon.png
```

### Option C: Using Inkscape (if installed)
```bash
inkscape assets/app_icon.svg --export-filename=assets/app_icon.png
```

## Step 2: Generate App Icons

Once you have the PNG file, run these commands:

```bash
# Install flutter_launcher_icons if not already installed
flutter pub get

# Generate app icons for all platforms
flutter pub run flutter_launcher_icons:main
```

## Step 3: Clean and Rebuild

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Run the app to see the new icon
flutter run
```

## Icon Design

The custom icon features:
- Blue circular background (#2563EB)
- White meter dial with markings
- Red needle pointing to 45 degrees
- Digital display showing "123.4 kWh"
- Small utility symbols (lightning, water, gas) in corners
- Professional and recognizable design for utility tracking

## Platforms Supported

The configuration will generate icons for:
- Android (various densities)
- iOS (all required sizes)
- Web (favicon and PWA icons)
- Windows (desktop app)
- macOS (desktop app) 

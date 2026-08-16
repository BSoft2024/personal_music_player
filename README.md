# Personal Music Player

**Build your own offline music player for your songs — no coding knowledge required after the initial setup.**

This is a ready-made Android app template. You put your own music files, cover images and a simple spreadsheet into the project, then build an app that only plays *your* music.

---

## What the finished app can do

- Plays only the songs you put into it (completely offline)
- Shows cover art for every track
- Lets listeners **filter** by instrumentation, album, year and type
- Lets listeners **sort** by title, album, year, type or length
- Has a **Favorites** (heart) system that remembers liked songs
- Shuffle, play/pause, next/previous, seek bar
- Clean dark interface

---

## What you need before starting

1. A Windows, Mac or Linux computer
2. Your music files (FLAC recommended, WAV or high-quality MP3 also work)
3. Cover images for the songs (JPG or PNG)
4. About 30–60 minutes the first time

You do **not** need to know how to write code.

---

## Step-by-step instructions (for complete beginners)

### Step 1 — Install Flutter (one-time setup)

1. Go to the official Flutter website:  
   https://docs.flutter.dev/get-started/install
2. Choose your operating system (Windows / macOS / Linux) and follow the instructions.
3. Also install **Android Studio** when the Flutter instructions tell you to (this is needed to build Android apps).
4. Open a terminal / PowerShell / Command Prompt and type:
   ```
   flutter doctor
   ```
   Fix any red errors it shows (the website explains how).

### Step 2 — Download this project

1. Click the green **Code** button on this GitHub page.
2. Choose **Download ZIP**.
3. Unzip the file somewhere easy to find (for example your Desktop).
4. Rename the unzipped folder to something simple, e.g. `my_music_player`.

### Step 3 — Create your spreadsheet

1. Open the file `assets/sample_songs.xlsx` in Excel, Google Sheets or LibreOffice.
2. Look at the example rows — this is the exact format you must follow.
3. Delete the example songs and add **your own** songs.

**Required columns (first four):**

| Song Title | Album / Release Title | Type | Release Year |
|------------|-----------------------|------|--------------|
| My Song    | My Album              | Single | 2024       |

**Optional instrument columns** (any extra columns you add become filters):

You can add as many instrument columns as you like (Piano, Guitar, Synth, Drums, Vocals, etc.).  
Put an `x` in the cell if that instrument is used on the track.

4. Save the file as `songs.xlsx` (not sample_songs.xlsx) inside the `assets` folder.

### Step 4 — Prepare your audio and cover files

Every song needs two files with **exactly** the same base name.

**Rules for the name:**
- All lowercase
- Spaces become underscores `_`
- Special characters and accents are removed or simplified  
  (ä → a, ö → o, é → e, etc.)

**Examples:**

| Song Title in spreadsheet | Audio file name          | Cover file name           |
|---------------------------|--------------------------|---------------------------|
| Morning Light             | `morning_light.flac`     | `morning_light.jpg`       |
| Dämmerung                 | `dammerung.flac`         | `dammerung.jpg`           |
| Fortun Okt: A Lydian      | `fortun_okt_a_lydian.flac` | `fortun_okt_a_lydian.jpg` |

- Put all audio files in the folder: `assets/audio/`
- Put all cover images in the folder: `assets/covers/`

**Supported audio formats:** FLAC (best), WAV, MP3, M4A/AAC  
**Supported cover formats:** JPG or PNG

### Step 5 — Build the app

1. Open a terminal / PowerShell.
2. Go into your project folder:
   ```
   cd Desktop/my_music_player
   ```
   (adjust the path if you put the folder somewhere else)
3. Run these three commands one after another:
   ```
   flutter create .
   flutter pub get
   flutter build apk --release
   ```
4. When it finishes, your app is here:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

You can copy this APK to any Android phone and install it (you may need to allow “Install from unknown sources”).

---

## Optional: Change the app name that appears on the phone

1. Open the file `lib/screens/home_screen.dart`
2. Find the line that says `'My Music'`
3. Change it to whatever you want (e.g. `'Sarah\'s Songs'` or your artist name)
4. Rebuild with `flutter build apk --release`

---

## Optional: Change the package name (recommended if you publish)

Open `android/app/build.gradle.kts` and change:

```
namespace = "com.example.personal_music_player"
applicationId = "com.example.personal_music_player"
```

to something unique, for example:

```
namespace = "com.yourname.musicplayer"
applicationId = "com.yourname.musicplayer"
```

Then rebuild.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| “No tracks match…” or empty list | Check that your spreadsheet is named `songs.xlsx` and is inside the `assets` folder. Make sure the column titles are exactly `Song Title`, `Album / Release Title`, `Type`, `Release Year`. |
| Song plays but has no cover | The cover filename must match the audio filename (same base name). Try both `.jpg` and `.png`. |
| Song does not play | Check the audio filename is correct and the file is really inside `assets/audio/`. |
| Build fails with network errors | Try again later or switch networks / turn off VPN. |
| “flutter” is not recognized | Flutter is not installed or not added to your system PATH. Go back to Step 1. |

---

## License

You are free to use this template to build players for your own music.

If you share the finished app, please do not sell other people’s music without permission.

---

## Credits

Originally created as a private player for the Aldus-X catalogue, then turned into a reusable template so any musician can have their own offline app.

# Gehana YouTube Downloader

A simple, clean PyQt5-based desktop application for downloading YouTube videos as **audio (.opus)** or **video (webm/mp4)** using `yt-dlp`. Designed to be lightweight, modern, and easy to use.

## Features

- Download YouTube videos as audio or video  
- Clean, modern dark UI  
- Log window showing download progress  
- Threaded downloading (UI never freezes)  
- Select output folder  
- Uses `yt-dlp` for reliable downloads

## Requirements

### Python  
Python **3.8+**

### Python Packages  
Install required libraries:

```
pip install PyQt5 yt-dlp
```

### yt-dlp  
`yt-dlp` must be installed and available in your PATH.

## How to Run

Download or clone this project, then run:

```
python tinGUI.pyw
```

## Usage

1. Paste a YouTube URL into the field  
2. Select **audio** or **video**  
3. Choose an output folder  
4. Click **Download**  
5. View progress in the log window  

Downloaded files save as:

```
<title>.<ext>
```

## Legal Notice

This software does not grant permission to download copyrighted material.  
**The user is solely responsible and legally liable for any content downloaded using this tool.**  
Ensure compliance with YouTube’s Terms of Service and all applicable copyright laws.

## Project Structure

```
tinGUI.pyw      # Main application file
README.md       # Documentation
```

## Notes

- Playlists are ignored; only single videos are downloaded  
- Errors related to missing yt-dlp appear in the log  
- Downloads run in a background thread to prevent UI freezing

## License

Open for personal or educational use. Modify freely.

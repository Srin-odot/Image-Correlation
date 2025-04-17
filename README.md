# 🌞 Image Correlation Analysis Tool for Sequential Images (IDL)

This repository contains a general-purpose IDL script for analyzing solar FITS data, originally developed for Nobeyama Radioheliograph datasets. It extracts features like longitudinal and latitudinal shifts, rotation rate , and correlation metrics and logs them in a structured way for further scientific analysis. This code can be used for any further studies only after citing our paper Routh et al 2025.

---

## 🔧 Features

- Processes solar FITS image sequences
- Computes latitude-binned outputs like:
  - Longitudinal shift (φ)
  - Latitudinal shift (y-shift)
  - Rotation (ω)
  - Cross-correlation values
- Writes tabular outputs to structured `.dat` files
- Easy customization of:
  - Latitude bins
  - Year-specific outputs
  - Data directory paths

---

## 🛠 Requirements

- [IDL](https://www.l3harrisgeospatial.com/Software-Technology/IDL) (Interactive Data Language)
- FITS handling libraries (e.g., `astrolib` or `SolarSoft`)
- Data: FITS files in a consistent time-series format (e.g., `*.fits`)

---

## 📁 Directory Structure

```
your_project/
├── solar_corr_analysis.pro     # Main IDL procedure
├── README.md
└── results/                    # Output `.dat` files saved here
```

---

## 🚀 Usage

You can run the tool directly in IDL:

```idl
IDL> .r image_correlation
IDL> image_correlation, data_dir='/path/to/fits/', output_dir='./results/', year=2022
```

### Arguments

| Parameter     | Type   | Description                         |
|---------------|--------|-------------------------------------|
| `data_dir`    | string | Directory where input FITS files are stored |
| `output_dir`  | string | Folder where `.dat` files will be saved |
| `year`        | int    | Year (used in file naming)         |

---

## 🔬 What This Code Actually Does

This tool processes time-series solar FITS files, converts them to heliographic coordinates and computes correlation coefficients between sequential latitudinal bin pairs.

### Step-by-Step Breakdown:

1. **FITS File Discovery**:
   - Searches for all FITS files matching the pattern `ifa*.fits` in the provided directory.

2. **Loop Over FITS File Pairs**:
   - Iterates over consecutive pairs of images (i.e., `file[k]` and `file[k+1]`).

3. **FITS Metadata Extraction**:
   - Reads image data and header using `MRDFITS`.
   - Extracts:
     - Observation frequency (`OBS-FREQ`)
     - Observation date/time (`DATE-OBS`, `TIME-OBS`)
     - Solar disk coordinates (`CRVAL1`, `CRVAL2`)

4. **Timestamp Handling**: (originally taken as a step of precaution against non-uniform timestamp format in the Nobeyama datasets)
   - Converts date formats from slashes (`/`) or dashes (`-`) into standard format. (Ignore this step if your dataset has uniform format for timestamps)
   - Computes time difference `dt` (in days) using `anytim2tai`.

5. **Validation Checks**:
   - Ensures:
     - Both FITS files have valid solar center positions (`CRVAL1`, `CRVAL2` ≠ 0)
     - Time difference ≤ 1.25 days
     - Both images have the same observation frequency

6. **(Placeholder for Analysis)**:
   - Once validated, the images are ready for further analysis like:
     - Longitudinal drift (φ)
     - Rotation (ω)
     - Y-shift
     - Cross-correlation over latitude bands

7. **Structured Output**:
   - Results are written into `.dat` files, each named by the measurement type and year.



## 📝 License

MIT License – free to use, modify, and distribute.

---

## 👩‍💻 Authors & Credits



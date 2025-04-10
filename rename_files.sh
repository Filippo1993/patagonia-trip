#!/bin/bash

# Step 1: Convert HEIC files to JPEG with resizing (1024px)
sips -s format jpeg -Z 1024 /Users/filippomichelon/Documents/PersonalCode/garmin_patagonia_plots/base_img_iphone/*.[hH][eE][iI][cC] --out /Users/filippomichelon/Documents/PersonalCode/garmin_patagonia_plots/converted_img/

# Step 2: Copy GPS metadata (EXIF) from HEIC to JPG
for heic_file in /Users/filippomichelon/Documents/PersonalCode/garmin_patagonia_plots/base_img_iphone/*.[hH][eE][iI][cC]; do
    jpg_file="/Users/filippomichelon/Documents/PersonalCode/garmin_patagonia_plots/converted_img/$(basename "${heic_file%.[hH][eE][iI][cC]}.jpg")"
    
    # Copy EXIF metadata from HEIC to JPG using exiftool
    exiftool -overwrite_original -tagsFromFile "$heic_file" "$jpg_file"
done

# Step 3: Rename JPG files based on GPS latitude and longitude
dir="/Users/filippomichelon/Documents/PersonalCode/garmin_patagonia_plots/converted_img/"

# Loop over each JPG file
for file in "$dir"*.jpg; do
    # Extract Latitude and Longitude from EXIF metadata in DMS format
    lat_dms=$(exiftool -GPSLatitude "$file" | awk -F': ' '{print $2}')
    lon_dms=$(exiftool -GPSLongitude "$file" | awk -F': ' '{print $2}')
    
    # Check if both Latitude and Longitude exist
    if [ -n "$lat_dms" ] && [ -n "$lon_dms" ]; then
        # Convert DMS to Decimal Degrees
        lat_decimal=$(echo $lat_dms | awk -F'[^\-0-9\.]+' '{print $1 + $2/60 + $3/3600}')
        lon_decimal=$(echo $lon_dms | awk -F'[^\-0-9\.]+' '{print $1 + $2/60 + $3/3600}')
        
        # Replace comma with period in the new filename
        new_name=$(printf "%.6f_%.6f.jpg" $lat_decimal $lon_decimal)
        new_name_with_periods=$(echo $new_name | sed 's/,/./g')  # Replace commas with periods
        
        # Rename the file
        mv "$file" "$dir$new_name_with_periods"
        echo "Renamed $file to $new_name_with_periods"
    else
        echo "No GPS data for $file"
    fi
done

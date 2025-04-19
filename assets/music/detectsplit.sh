#!/bin/bash

# Parse arguments
while getopts "i:l:a:d:" opt; do
  case $opt in
    i) MP3="$OPTARG" ;;
    l) LIST="$OPTARG" ;;
    a) ARTIST="$OPTARG" ;;
    d) ALBUM="$OPTARG" ;;
    *) echo "Usage: $0 -i input.mp3 -l track_list.csv -a artist -d album"; exit 1 ;;
  esac
done

# Ensure required arguments are present
if [ -z "$MP3" ] || [ -z "$LIST" ] || [ -z "$ARTIST" ] || [ -z "$ALBUM" ]; then
    echo "Usage: $0 -i input.mp3 -l track_list.csv -a artist -d album"
    exit 1
fi

# Read titles from second column of CSV
titles=()
while IFS=',' read -r track title start; do
    # Skip empty lines or header (optional: detect numeric track to be stricter)
    [[ -z "$title" || "$track" == "Track Number" ]] && continue
    titles+=("$title")
done < "$LIST"

total=${#titles[@]}

# Analyze silence
echo "Analyzing silence in $MP3..."
ffmpeg -i "$MP3" -af "silencedetect=noise=-50dB:d=0.5" -f null - 2> silence.log

# Extract silence start times
silence_starts=$(grep "silence_start" silence.log | sed 's/.*silence_start: //;s/\r$//' | tr -d '\r')
start_times=(0)
for start in $silence_starts; do
    start_times+=("$start")
done

# Ensure there's an end marker
if [ ${#start_times[@]} -lt $((total)) ]; then
    echo "Not enough silence points. Appending end of file..."
    total_sec=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$MP3" | cut -d. -f1)
    start_times+=("$total_sec")
fi

# Format seconds as HH:MM:SS
to_hms() {
    local seconds=$1
    printf '%02d:%02d:%02d' $(($seconds / 3600)) $((($seconds % 3600) / 60)) $(($seconds % 60))
}

# Sanitize filename parts
clean_filename() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e "s/[[:space:]]\+/\./g" -e "s/[\"']//g"
}

# Create output
echo "Generating splits.txt..."
> splits.txt

clean_artist=$(clean_filename "$ARTIST")
clean_album=$(clean_filename "$ALBUM")

for ((i=0; i<total; i++)); do
    start_sec=${start_times[$i]}
    end_sec=${start_times[$((i+1))]}
    duration_sec=$(echo "$end_sec - $start_sec" | bc)
    start_hms=$(to_hms "$start_sec")
    dur_hms=$(to_hms "$duration_sec")

    title="${titles[$i]}"
    clean_title=$(clean_filename "$title")
    track_num=$(printf "%02d" $((i + 1)))

    filename="${track_num}-${clean_artist}-${clean_album}-${clean_title}.mp3"

    echo "$start_hms $dur_hms $filename" >> splits.txt
    echo "Added: $start_hms $dur_hms $filename"
done

echo "✅ splits.txt generated."

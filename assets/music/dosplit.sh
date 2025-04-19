#!/bin/bash

# Parse arguments
while getopts "i:l:" opt; do
  case $opt in
    i) input_audio="$OPTARG" ;;
    l) track_list="$OPTARG" ;;
    *) echo "Usage: $0 -i input_audio.mp3 -l track_list.csv"; exit 1 ;;
  esac
done

# Validate inputs
if [ -z "$input_audio" ] || [ -z "$track_list" ]; then
  echo "Usage: $0 -i input_audio.mp3 -l track_list.csv"
  exit 1
fi

if [ ! -f "$input_audio" ]; then
  echo "❌ Error: Input file '$input_audio' not found."
  exit 1
fi

if [ ! -f "$track_list" ]; then
  echo "❌ Error: Track list '$track_list' not found."
  exit 1
fi

# Read titles from CSV (column 2)
titles=()
while IFS=',' read -r track title start; do
  [[ "$track" =~ ^[0-9]+$ ]] || continue
  titles+=("$title")
done < "$track_list"

total=${#titles[@]}
splits_file="splits.txt"

# Function to convert HH:MM:SS to seconds
hms_to_seconds() {
    local time=$1
    time=$(echo "$time" | sed 's/^0\:/00:/;s/^:\([0-9]\{1,2\}\):/:\0\1:/;s/^[0-9]\{1,2\}\(:[0-9]\{1,2\}\)$/\0:00/')
    IFS=: read -r h m s <<< "$time"
    h=${h:-0}; m=${m:-0}; s=${s:-0}
    echo $((10#$h * 3600 + 10#$m * 60 + 10#$s))
}

# Step 1: Check for splits.txt
if [ ! -f "$splits_file" ]; then
  echo "❌ Error: $splits_file not found. Run the silence detection script first."
  exit 1
fi

# Step 2: Begin extraction
echo "🔪 Splitting audio using $splits_file..."
count=1

while read -r start dur title_rest; do
  if [[ -z "$start" || -z "$dur" || -z "$title_rest" ]]; then
    echo "[$count/$total] ⚠️ Skipping malformed line."
    ((count++))
    continue
  fi

  title=$(echo "$title_rest" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  if [ -z "$title" ]; then
    echo "[$count/$total] ⚠️ Skipping empty title."
    ((count++))
    continue
  fi

  printf -v track_no "%02d" "$count"
  outfile="${track_no} - ${title}.mp3"

  echo "[$count/$total] Extracting: $outfile"

  dur_sec=$(hms_to_seconds "$dur" 2>/dev/null || echo 0)
  if [ "$dur_sec" -eq 0 ]; then
    echo "[$count/$total] ⚠️ Invalid duration: $dur" >&2
    ((count++))
    continue
  fi

  ffmpeg -hide_banner -loglevel error \
    -ss "$start" -t "$dur" -i "$input_audio" \
    -b:a 192k -y "$outfile" \
    -progress - -nostats 2>&1 |
  while IFS='=' read -r key val; do
    if [[ $key == "out_time_ms" && "$val" =~ ^[0-9]+$ ]]; then
      elapsed_sec=$((val / 1000000))
      percent=$((elapsed_sec * 100 / dur_sec))
      percent=$(( percent > 100 ? 100 : percent ))
      bar=$(printf "%-${percent}s" "#" | tr ' ' '#')
      printf "\r[$count/$total] ▓%-50s %3d%%" "$bar" "$percent"
    fi
  done

  echo -e "\r[$count/$total] ✅ Done: $outfile"
  ((count++))
done < "$splits_file"

echo "🎉 All tracks extracted."


#!/bin/bash

set -eo pipefail

# URL of the JSON data
json_url="$1"

output_dir="output"

mkdir -p "$output_dir"

# Temporary file to store the JSON data
temp_json=$(mktemp)

# Fetch JSON data using curl
curl -s "$json_url" -o "$temp_json"

echo "PID,TeamID,LastName,FirstName,Number,Club,Active,Email" > "$output_dir/_players.csv"

# Generate players.csv
jq -r '
.Results[].Participant | 
  .Number as $number |
  ._people | to_entries | map(
    select(.value._lastName != "--NEW--") | 
    [
      .key, 
      $number, 
      .value._lastName, 
      .value._firstName, 
      .value._pid.Number, 
      .value._club, 
      1, 
      ""
    ] | join(",")
  ) | .[]
' "$temp_json" >> "$output_dir/_players.csv"

echo "" > "$output_dir/_rankings.csv"

# Generate rankings.csv
jq -r '
   .Results[] | 
  [
    1,
    .Place,
    .Place,
    .Participant.Number,
    0,
    0,
    .Result._pointsDecimal,
    1
  ] | join(",") 
' "$temp_json" >> "$output_dir/_rankings.csv"

echo "TeamID,TeamName,TeamShortName" > "$output_dir/_teams.csv"

# Generate teams.csv
jq -r '
  .Results[].Participant | 
  [
    .Number,
    .Number,
    ._name
  ] | join(",")
' "$temp_json" >> "$output_dir/_teams.csv"


iconv -f UTF-8 -t CP1250 "$output_dir/_rankings.csv"  >"$output_dir/rankings.csv"
iconv -f UTF-8 -t CP1250 "$output_dir/_teams.csv"     >"$output_dir/teams.csv"
iconv -f UTF-8 -t CP1250 "$output_dir/_players.csv"   >"$output_dir/players.csv"

rm "$output_dir/_rankings.csv"
rm "$output_dir/_teams.csv"
rm "$output_dir/_players.csv"
rm "$temp_json"
#!/bin/bash

# URL of the JSON data
json_url="$1"

# Temporary file to store the JSON data
temp_json=$(mktemp)

# Fetch JSON data using curl
curl -s "$json_url" -o "$temp_json"

echo "PID,TeamID,LastName,FirstName,Number,Club,Active,Email" > players.csv

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
' "$temp_json" >> players.csv

echo "" > rankings.csv

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
' "$temp_json" >> rankings.csv

echo "TeamID,TeamName,TeamShortName" > teams.csv

# Generate teams.csv
jq -r '
  .Results[].Participant | 
  [
    .Number,
    .Number,
    ._name
  ] | join(",")
' "$temp_json" >> teams.csv


iconv -f UTF-8 -t CP1250 rankings.csv -o rankings.csv
iconv -f UTF-8 -t CP1250 teams.csv -o teams.csv
iconv -f UTF-8 -t CP1250 players.csv -o players.csv

rm "$temp_json"
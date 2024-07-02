#!/bin/bash

set -eo pipefail

output_dir="output"

mkdir -p "$output_dir"

json_url="$1"
shift


usage() {
    echo "Usage: $0 url [-n|--noname]"
    exit 1
}
# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--noname)
            noname=1
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done



if [[ $noname -eq 1 ]]; then
    jq_filter='.Results[] | [ 
    .Place, 
    (.Result._pointsDecimal * 100 | round / 100), 
    "", 
    (.Participant._person._pid.Number | if . > 10000 then "" else . end),
    "" 
] | join(",")' 
else
    jq_filter='.Results[] | [ 
    .Place, 
    (.Result._pointsDecimal * 100 | round / 100), 
    (.Participant._person._lastName + " " + .Participant._person._firstName), 
    (.Participant._person._pid.Number | if . > 10000 then "" else . end),
    ""
] | join(",")' 
fi

curl --silent $json_url | jq --raw-output "$jq_filter"
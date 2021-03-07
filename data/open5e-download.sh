#!/bin/bash

function download () {
	local url_path=$1
	local suffix=${2:-1}
	local file_infix=${3:-`basename $url_path`}
	local outfile="open5e-${infix}${suffix}.json"
	wget "https://api.open5e.com/$url_path" "$outfile"
	local next_page=`<"$outfile" jq .next`
	if [[ $next_page != null ]]; then
		suffix=$(( $suffix + 1 ))
		download url_path "$1" "$suffix" "$file_infix"
	fi
}

function download_classes () {
	download 'classes' '1' 'player-classes'
}

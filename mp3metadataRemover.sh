#!/bin/bash

enable_auto_updates=true #Set to 'false' to disable auto updates

frame_list=("AENC" "APIC" "COMM" "COMR" "ENCR" "EQUA" "ETCO" "GEOB" "GRID" "IPLS" "LINK" "MCDI" "MLLT" "OWNE" "PRIV" "PCNT" "POPM" "POSS" "RBUF" "RVAD" "RVRB" "SYLT" "SYTC" "TALB" "TBPM" "TCOM" "TCON" "TCOP" "TDAT" "TDLY" "TENC" "TEXT" "TFLT" "TIME" "TIT1" "TIT3" "TKEY" "TLAN" "TLEN" "TMED" "TOAL" "TOFN" "TOLY" "TOPE" "TORY" "TOWN" "TPE2" "TPE3" "TPE4" "TPOS" "TPUB" "TRCK" "TRDA" "TRSN" "TRSO" "TSIZ" "TSRC" "TSSE" "TXXX" "TYER" "UFID" "USER" "USLT" "WCOM" "WCOP" "WOAF" "WOAR" "WOAS" "WORS" "WPAY" "WPUB" "WXXX")
#TIT2 (Title/songname/content description) and TPE1 (Lead performer(s)/Soloist(s)) omitted

auto_update () {
    if wget -V > /dev/null 2>&1; then
        if ! file_network=$(wget -qO- "$1"); then
            return 1
        fi
    elif curl -V > /dev/null 2>&1; then
        if ! file_network=$(curl -fsSL "$1"); then
            return 1
        fi
    else
        # wget and curl not found, can't check for update
        return 2
    fi
    hash_local=$(md5sum "$2" | awk '{ print $1 }')
    hash_network=$(echo -E "$file_network" | md5sum | awk '{ print $1 }')
    if [[ "$hash_local" != "$hash_network" ]]; then
        tmpfile=$(mktemp "${2##*/}".XXXXXXXXXX --tmpdir)
        echo -E "$file_network" > "$tmpfile"
        chown --reference="$2" "$tmpfile"
        chmod --reference="$2" "$tmpfile"
        mv "$tmpfile" "$(realpath "$2")"
        exec "${@:2}"
    fi
}

parsing () {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 MUSIC_FILE[S].mp3"
        exit 1
    fi

    if ! id3v2 -V > /dev/null 2>&1; then
        echo "Command 'id3v2' not found." >&2
        exit 2
    fi

    if ! mp3check --version > /dev/null 2>&1; then
        echo "Command 'mp3check' not found." >&2
        exit 3
    fi
}

main () {
    for file in "$@"; do
        if [ ! -f "$file" ]; then
            echo "$file: Invalid file." >&2
            continue
        fi
        if ! mp3check -l -q "$file" > /dev/null 2>&1; then
            echo "$file: Invalid mp3 file." >&2
            continue
        fi
        echo "$file"
        id3v2 -C "$file"
        id3v2 -s "$file"
        echo "Deleting Frames in file $file ..."
        for frame in "${frame_list[@]}"; do
            id3v2 -r "$frame" "$file" > /dev/null
        done
        echo "Deleting Frames in file $file ... Done."
        #exiftool -Comment "$file"
    done
}

if [ "$enable_auto_updates" = true ] ; then
    auto_update "https://raw.githubusercontent.com/Sad-theFaceless/mp3metadataRemover/main/mp3metadataRemover.sh" "$0" "$@"
fi
parsing "$@"
main "$@"

exit 0

#!/bin/bash

frame_list=("AENC" "APIC" "COMM" "COMR" "ENCR" "EQUA" "ETCO" "GEOB" "GRID" "IPLS" "LINK" "MCDI" "MLLT" "OWNE" "PRIV" "PCNT" "POPM" "POSS" "RBUF" "RVAD" "RVRB" "SYLT" "SYTC" "TALB" "TBPM" "TCOM" "TCON" "TCOP" "TDAT" "TDLY" "TENC" "TEXT" "TFLT" "TIME" "TIT1" "TIT3" "TKEY" "TLAN" "TLEN" "TMED" "TOAL" "TOFN" "TOLY" "TOPE" "TORY" "TOWN" "TPE2" "TPE3" "TPE4" "TPOS" "TPUB" "TRCK" "TRDA" "TRSN" "TRSO" "TSIZ" "TSRC" "TSSE" "TXXX" "TYER" "UFID" "USER" "USLT" "WCOM" "WCOP" "WOAF" "WOAR" "WOAS" "WORS" "WPAY" "WPUB" "WXXX")
#TIT2 (Title/songname/content description) and TPE1 (Lead performer(s)/Soloist(s)) omitted

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

parsing "$@"
main "$@"

exit 0

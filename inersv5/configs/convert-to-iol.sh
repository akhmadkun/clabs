#!/bin/bash

# Mendapatkan list semua direktori di folder saat ini (kecuali hidden folders)
DIRS=$(find . -maxdepth 1 -type d ! -name ".*")

for DIR in $DIRS
do
    # Menghapus "./" dari nama folder agar rapi
    DIR_NAME=$(basename "$DIR")
    
    # Abaikan jika itu adalah direktori root (titik)
    if [ "$DIR_NAME" == "." ]; then continue; fi

    echo "=================================================="
    echo "MEMASUKI FOLDER: $DIR_NAME"
    echo "=================================================="

    # Masuk ke folder dan cari file .txt
    # Kita gunakan subshell ( ) agar saat selesai kembali ke folder asal otomatis
    (
        cd "$DIR" || exit
        FILES=$(ls *.txt 2>/dev/null)

        if [ -z "$FILES" ]; then
            echo "--> Tidak ada file .txt di folder ini."
        else
            for FILE in $FILES
            do
                FILENAME="${FILE%.*}"
                OUTPUT_FILE="${FILENAME}.partial"

                echo "    Konversi: $FILE -> $OUTPUT_FILE"

                # Proses ekstraksi dan penggantian teks
                # Mengambil blok interface/router dan ganti Gig menjadi Eth
                > "$OUTPUT_FILE"
                sed -n '/^\(interface\|router\)/,/!/p' "$FILE" | \
                sed 's/GigabitEthernet1/Ethernet0\/1/g' >> "$OUTPUT_FILE"
                echo 'alias exec siib show ip int brief | ex una' >> "$OUTPUT_FILE"
                echo 'interface Ethernet0/1' >> "$OUTPUT_FILE"
                echo 'no shutdown' >> "$OUTPUT_FILE"
                echo 'no ip address' >> "$OUTPUT_FILE"
                rm -vf $FILE
            done
            echo "--> Selesai memproses folder $DIR_NAME."
        fi
    )
    echo -e "\n"
done

echo "--------------------------------------------------"
echo "PROSES SELESAI UNTUK SEMUA FOLDER."

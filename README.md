# mp3metadataRemover
A bash script to remove the metadatas from one or multiple mp3 files.
Does not remove the **Title** nor the **Contributing artists** metadatas (unless they are ID3v1). 

## Download
### GNU/Linux
```bash
wget https://raw.githubusercontent.com/Sad-theFaceless/mp3metadataRemover/main/mp3metadataRemover.sh && chmod +x mp3metadataRemover.sh
```

## How to use
Works for both single and multiple files
```bash
./mp3metadataRemover.sh $FILE.mp3 [...]
```
```bash
./mp3metadataRemover.sh $DIRECTORY/*.mp3
```

## Intro

This repo contains mutashabiha ayat data for Quran. It is based on the work of Qari Idrees Al Asim (late) and my own experience of reciting and memorizing Quran.

**IMPORTANT**

The assumed end consumer of this data e.g., via an app is a Hafiz of Quran. Thus the data in this repo is not an exhaustive list of all possible mutashabihas in the quran nor is that my aim. The repo tries to collect most common mutashabihas that confuse huffaz. The reason is that huffaz don't get confused by many mutashabihas in the Quran at all. For e.g., the first ayah of Surah al-fatiha has many similarities but it is unlikely that a hafiz will get confused by those similarities.

## Json data format

The data is an array of mutashabiha objects, examples:

```
 {
  "src": {
   "ayah": 3733
  },
  "muts": [
   {
    "ayah": 3753
   },
   {
    "ayah": 3757
   }
  ]
 }
```
---
```
 {
  "src": {
   "ayah": [
    53,
    54
   ]
  },
  "muts": [
   {
    "ayah": [
     128,
     129
    ]
   }
  ],
  "ctx": 2
 },
```

- `src` is the absolute source ayah number in the Quran. `src.ayah` can be a number or an array of numbers
- `muts` is a list of matching absolute ayah numbers for the `src.ayah`
- `ctx` is an indicator that this mutashabiha should show some context to the user e.g., show a portion of the next ayah

The data is available in the file `mutashabihat_data.json`. You can generate it youself using the provided scripts, see the Scripts section below.

## Base Data

- `txts/` directory contains the base text files that I used to generate json data. The format in those files is as follows:
    - each line represents a mutashabiha
    - a line has two parts separated by a `|`
    - the left side or the first part is the `source_surah:source_ayah`
    - the right side is a list of matching `surah:ayahs` separated by `,`
    - source and matching can have multiple ayahs, in which case they are separated by `/`
    - a line may have a `\n` at the end which means this mutashabiha should show some context e.g., portion of next ayah

## Scripts

- `txt_to_json.dart` can be used to generate json data from txt. Run it as `dart txt_to_json.dart` to generate data for all paras/juz.
- `combine.dart` can be used to combine the data produced by `txt_to_json.dart` into a single file
- `rev_gen.dart` is a helper script that looks at a txt file and foreach line it generates reverse mutashabihas for each entry e.g., if you run the script on it will look at each file in `txts/` folder and then for each line in each file, it will generate reverse lines `2:3|44:2` => `44:2|2:3`. This is just to reduce the amount of work.

## LICENSE

The data in this project is free to use as you see fit. However, I would appreciate if you mention the use of this project in your app or any other kind of work if you decide to use this data.

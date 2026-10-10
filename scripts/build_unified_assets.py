#!/usr/bin/env python3
"""
build_unified_assets.py
Merges the entire kehvto dataset (1,437+ rich proverbs with multi-tier meanings,
backstories, fables, and categories) into the Android app assets directory.
"""
import glob
import json
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
KEHVTO_DIR = Path("/home/patel/AI/kehvto")
ASSETS_DIR = BASE_DIR / "App1_Lok_Sahitya_Kehavat" / "Android_Sample" / "app" / "src" / "main" / "assets"

def main():
    print("Reading categories from kehvto...")
    cats_file = KEHVTO_DIR / "data" / "categories.json"
    categories = []
    if cats_file.exists():
        with open(cats_file, "r", encoding="utf-8") as f:
            categories = json.load(f).get("categories", [])
    
    seen_ids = set()
    all_kehvto = []

    # 1. Base gu.json
    gu_file = KEHVTO_DIR / "data" / "kehvto" / "gu.json"
    if gu_file.exists():
        with open(gu_file, "r", encoding="utf-8") as f:
            for k in json.load(f).get("kehvto", []):
                k["lang"] = "gu"
                if k["id"] not in seen_ids:
                    seen_ids.add(k["id"])
                    all_kehvto.append(k)

    # 2. Harvest files
    harvest_files = sorted(glob.glob(str(KEHVTO_DIR / "data" / "harvest" / "kehvto" / "*.json")))
    print(f"Loading {len(harvest_files)} harvest files...")
    for hf in harvest_files:
        with open(hf, "r", encoding="utf-8") as f:
            for k in json.load(f).get("kehvto", []):
                k["lang"] = "gu"
                if k["id"] not in seen_ids:
                    seen_ids.add(k["id"])
                    all_kehvto.append(k)

    print(f"Total categories: {len(categories)}")
    print(f"Total rich proverbs: {len(all_kehvto)}")

    payload = {
        "categories": categories,
        "kehvto": all_kehvto
    }

    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    out_file = ASSETS_DIR / "kehvto_full.json"
    with open(out_file, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=None)

    size_mb = os.path.getsize(out_file) / (1024 * 1024)
    print(f"Successfully generated {out_file} ({size_mb:.2f} MB)")

if __name__ == "__main__":
    main()

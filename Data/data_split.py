import pandas as pd
from sklearn.model_selection import train_test_split
from pathlib import Path

def split_dataset(csv_path, random_state=42):
    df = pd.read_csv(csv_path)

    # 70% train, 30% temp
    train, temp = train_test_split(df, test_size=0.3, random_state=random_state)

    # From temp (30%): 20% test, 10% val overall
    # test_size=0.333 means 1/3 of temp -> 10% overall val
    test, val = train_test_split(temp, test_size=0.333, random_state=random_state)

    return train, test, val

def main():
    # Always save outputs in the same folder as this script
    outdir = Path(__file__).resolve().parent

    train1, test1, val1 = split_dataset(outdir / "df_activists.csv")
    train2, test2, val2 = split_dataset(outdir / "df_newspeople.csv")
    train3, test3, val3 = split_dataset(outdir / "df_politicians.csv")

    train_final = pd.concat([train1, train2, train3], ignore_index=True)
    test_final  = pd.concat([test1, test2, test3], ignore_index=True)
    val_final   = pd.concat([val1, val2, val3], ignore_index=True)

    train_path = outdir / "train.csv"
    test_path  = outdir / "test.csv"
    val_path   = outdir / "validation.csv"

    train_final.to_csv(train_path, index=False)
    test_final.to_csv(test_path, index=False)
    val_final.to_csv(val_path, index=False)

    print("Wrote:", train_path)
    print("Wrote:", test_path)
    print("Wrote:", val_path)
    print(f"Train: {len(train_final)}, Test: {len(test_final)}, Val: {len(val_final)}")

if __name__ == "__main__":
    main()

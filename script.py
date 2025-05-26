import pandas as pd
import argparse

def adjust_relative_time(input_csv_path, output_csv_path, value_to_remove=610.857518):
    """
    Reads a CSV file, subtracts a specific value from the 'relative_time_s' column,
    and saves the modified data to a new CSV file.

    Args:
        input_csv_path (str): The path to the input CSV file.
        output_csv_path (str): The path to the output CSV file.
        value_to_remove (float): The value to subtract from 'relative_time_s'.
    """
    try:
        df = pd.read_csv(input_csv_path)
    except FileNotFoundError:
        print(f"Error: Input file '{input_csv_path}' not found.")
        return
    except Exception as e:
        print(f"Error reading CSV file: {e}")
        return

    if 'relative_time_s' in df.columns:
        df['relative_time_s'] = df['relative_time_s'] - value_to_remove
        try:
            df.to_csv(output_csv_path, index=False)
            print(f"Successfully processed '{input_csv_path}' and saved to '{output_csv_path}'.")
        except Exception as e:
            print(f"Error writing output CSV file: {e}")
    else:
        print("Error: 'relative_time_s' column not found in the CSV file.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Adjust 'relative_time_s' column in a CSV file by subtracting a specific value."
    )
    parser.add_argument("input_csv", help="Path to the input CSV file.")
    parser.add_argument("output_csv", help="Path for the output CSV file.")

    args = parser.parse_args()

    adjust_relative_time(args.input_csv, args.output_csv)
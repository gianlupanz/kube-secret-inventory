# This script is created by Gianluca Panzuto
# Copyright (C) Nov 3rd, 2023 Gianluca Panzuto
# All rights reserved.

import csv
import openpyxl
import argparse
import pandas as pd

class CommandArgs:
    def __init__(self):
        """ Setup the CLI parser options """
        description = """Convert txt file to excel"""
        self.parser = argparse.ArgumentParser(description=description)
        self.parser.add_argument("--input", help="file to input")
        self.parser.add_argument("--output", help="excel output")

    def parse(self):
        """ Parse the command arguments """
        return self.parser.parse_args()

if __name__ == '__main__':
    command_args = CommandArgs()
    args = command_args.parse()
    input_file = args.input
    output_file = args.output

    # Read the CSV data and write to Excel in a single loop

    with open(input_file, 'r', newline='') as data:
        reader = csv.reader(data, delimiter='\t')

        # Initialize a list for storing data

        data_list = []
        for row in reader:
            values = row[0].split(' ')
            data_list.append(values)

    # Convert the data to a DataFrame, sort by Namespace and Kube Secret and save the dataframe as Excel file

    df = pd.DataFrame(data_list, columns=["Kube Secret", "Type", "Age", "Namespace", "Created By", "Service Account Name", "Expiration"])
    df.sort_values(by=['Namespace', 'Kube Secret'], inplace=True)
    df.to_excel(output_file, index=False)

    # Load the workbook and adjust column widths

    wb = openpyxl.load_workbook(output_file)
    sheet = wb.active

    for column in sheet.columns:
        max_length = 0
        for cell in column:
            try:
                if len(str(cell.value)) > max_length:
                    max_length = len(str(cell.value))
            except:
                pass
        adjusted_width = (max_length + 2)
        sheet.column_dimensions[column[0].column_letter].width = adjusted_width
    
    # Save the adjusted workbook

    wb.save(output_file)

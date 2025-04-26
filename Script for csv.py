import csv
from datetime import datetime

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

input_file = 'file.csv'
output_file = 'insert.sql'
table_name = 'tablename'
batch_size = 9999

output = []

with open(input_file, 'r', encoding='utf-8') as f:
    reader = csv.reader(f, delimiter=';')
    next(reader)
    for row in reader:
        formatted_row = []
        for idx, value in enumerate(row):
            value = value.strip()
            if value == '':
                formatted_row.append('NULL')
            elif idx == 3:
                try:
                    date_obj = datetime.strptime(value, '%m/%d/%y')
                    formatted_row.append("'" + date_obj.strftime('%Y-%m-%d') + "'")
                except ValueError:
                    formatted_row.append('NULL')
            elif is_number(value):
                formatted_row.append(value)
            else:
                formatted_row.append("'" + value.replace("'", "''") + "'")
        output.append("(" + ", ".join(formatted_row) + ")")

with open(output_file, 'w', encoding='utf-8') as f_out:
    for i in range(0, len(output), batch_size):
        batch = output[i:i+batch_size]
        f_out.write(f'INSERT INTO {table_name} VALUES\n')
        f_out.write(",\n".join(batch))
        f_out.write(";\n\n")





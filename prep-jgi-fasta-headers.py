'''
Make sure to first unzip all assembly files before running this script.
Then run this script from within the toplevel taxa folder (e.g. "phycocosm").
'''
import sys
from pathlib import Path
import pandas as pd


assemblies_file = Path('assembly_list.txt')
fasta_files = Path('assembly').glob('*.fasta')
cwd = Path('.').resolve().name

out_path = Path("annotated-assembly")
print(f"Creating output directory: {out_path}")
out_path.mkdir(exist_ok=True)
out_file = out_path / cwd
out_file = out_file.with_suffix(".fasta")

df = pd.read_csv(assemblies_file, sep="\t")
df.columns = ["Organism", "JGI ORG ID", "Download URL"]

uniq_ids = set()

with open(out_file, 'w') as f:
    for file in fasta_files:
        print(f"Prepping {file}")
        id = file.name.split("_Assembly")[0].split("_nuclear")[0].split("_scaffolds")[0]

        if id in list(df["JGI ORG ID"]):
            org_annotation = df[df["JGI ORG ID"] == id].iloc[0]['Organism']
            org_annotation = org_annotation.replace(" ", "_")
            org_annotation = org_annotation.replace("scaffold", "scfld").replace("isolate", "isol")
        else:
            print(f"*WARNING* Skipping '{id}' - not found in assemblies file")
            org_annotation = "Unannotated"
            continue

        if len(org_annotation) > 52:
            print(f"*WARNING* Skipping due to id length > 50: {org_annotation}")
            continue

        skip_record = False
        for line in open(file, 'r'):

            if line.startswith(">"):
                record = line.replace(">", f">{org_annotation}_")
                record = record.replace("scaffold", "scfld").replace("isolate", "isol")

                if record in uniq_ids:
                    skip_record = True
                else:
                    uniq_ids.update(record)
                    f.write(record)
                    skip_record = False
            else:
                if not skip_record:
                    f.write(line)

        print(f"Successfully reformatted file: {out_file}")


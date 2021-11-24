# README

This is a rough, work in progress document to help the developer 
to better keep track of important steps performed. It is not comprehensive
so some interpretation will sometimes be required 
(for example, making logical decisions about which directory to execute the 
cmds from). This document is not meant to be neat!

---


## Steps to start jbconect server

The steps werent recorded here but a few rough documents I made outline the installation steps ("working-cmds-.....txt")
But some other useful things to note for future:

- the jbconnect/sails server is being run from the (base) conda env!
- it is being run in a tmux session called "serve"


------------------------------------------------------------------------------------------
## Steps taken to download and prepare chondrus crispus protein blast db for blastx search:

Link to uniprot ftp server with all organisms ref sequen ces (AA sequneces):
```
https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/
```

Link to Chondrus chrispus specifically (use the top level readme to map organism to folder):
```
https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000012073/
```

Download the fasta AA sequence file:
```
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000012073/UP000012073_2769.fasta.gz
```
Use the blast binaries in this location:
```
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/
```

To construct the blast db as follows:
```
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb -in UP000012073_2769.fasta -parse_seqids -blastdb_version 5 -title "chondrus_crispus_prot" -out output/chondrus_crispus_prot -taxid 2769 -dbtype prot
```
Note, to perform taxid lookups automatically as part of the blast search is a two step process...
This file needs to be downloaded in the same dir as your blast db:
ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz

```
in other words do this:
wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz
tar -xzf taxdb.tar.gz
```

And then see this VERY useful guide (the best one I've seen) for the second step
(generating the taxid map file used as part of makeblastdb):
http://www.verdantforce.com/2014/12/building-blast-databases-with-taxonomy.html

Also see this post:
https://www.biostars.org/p/76551/

Tip: the outformat flag might need to be used in a specific way when running blast.
As an *example*:
```
-outfmt "6 qseqid sseqid evalue pident stitle staxids sscinames scomnames sblastnames sskingdoms salltitles stitle" \
```

--------

## Creating the phycocosm aa blastx db:

use the script in:
```
/data/davis--blast-dbs/get_jgi_genomes-release
```

to do the following:
```
cd /databases/blast/
sudo mkdir phycocosm-proteins
sudo chmod a+rw phycocosm-proteins/
```

sign in and then download all phycocosm protein sequences:
```
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -u davistodt@gmail.com -p {w3...}
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -a -l
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes   -c signon.cookie -a
```

download all phycocosm/mycocosm taxon ids (this link was acquired via email query to JGI on oct 18th):
```
wget https://mycocosm.jgi.doe.gov/ext-api/mycocosm/catalog/download-group?flt=&seq=all&pub=all&grp=all&srt=released&ord=desc
mv download-group\?flt\= all_org_names_and_taxa.csv
```
NB: note that the above file might throw encoding errors in the subsequent step so you might need to manually select all, copy and
paste from the web link into the file.

Create a single fasta file from all sep fasta files:
```
cd pep
for f in `ls`; do gunzip $f; done
cat * > ../concatted-phycocosm-proteins.fasta
cd ../
```

prepare them as a blastdb with tax ids and appropriately formatted fa headers with seq id and taxa (this is possible attempt one of many because of the fasta headers)
```
python make_tax_id_map.py
python format_fa_headers_for_blast.py
mkdir output
```

Build the blastdb:
```
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb -in concatted-phycocosm-proteins.fasta -parse_seqids -blastdb_version 5 -title "jgi-phycocosm-prot" -out output/jgi-phycocosm-prot -taxid_map tax_map.txt -dbtype prot
```

ok so actually, after much experimentation I decided to not run the above makeblastdb command.
There were too many cryptic errors no matter how I tried to format the fasta headers and/or the tax_map.txt file to
accommodate these.
Instead, I ran the following command (i.e. I didnt tell blast to expect ncbi std formatted headers - the advice I've come across most often
 is to omit this if the files arent already in the ncbi format because its a headache).

```
 /data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb -in ../concatted-phycocosm-proteins.fasta -blastdb_version 5 -title "jgi-phycocosm-prot" -out jgi-phycocosm-prot -dbtype prot -max_file_sz '4GB'
```
The workflow script just needs to be formatted to parse out the extra info from the result/subject ids now.

To test the blast output format generated:
```
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/blastx \
-db /home/ec2-user/jbconnect/blastdb/phycocosm-prot/jgi-phycocosm-prot \
-query /home/ec2-user/jbconnect/blastdb/tmp/ \
76-jgi-phycocsm-original-blastx-job-blastx-query-seq.fasta \
-outfmt '7 qaccver sseqid saccver qstart qend sstart send sseq evalue bitscore length pident nident mismatch gapopen staxid ssciname scomname stitle' -out /home/ec2-user/jbconnect/blastdb/tmp/test-jgi-phycocsm-blastx-job-blastx-results.tsv
```

-----------

## Mycocosm steps:
```
cd /databases/blast/
mkdir mycocosm-proteins
sudo chmod a+rw mycocosm-proteins/
cd mycocosm-proteins
```
sign in and then download all phycocosm protein sequences:
```
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -u davistodt@gmail.com -p {w3...}
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -f -l
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -f
```

download all phycocosm/mycocosm taxon ids (this link was acquired via email query to JGI on oct 18th):
```
wget https://mycocosm.jgi.doe.gov/ext-api/mycocosm/catalog/download-group?flt=&seq=all&pub=all&grp=all&srt=released&ord=desc
mv download-group\?flt\= all_org_names_and_taxa.csv
```
NB: note that the above file might throw encoding errors in the subsequent step so you might need to manually select all, copy and
paste from the web link into the file.

install gnu parallel (easy):
```
http://git.savannah.gnu.org/cgit/parallel.git/tree/README
```

Create a single fasta file from all sep fasta files and format their headers at the same time:
```
cd pep
for f in `ls`; do gunzip $f; done
cd ../
python format-and-build-fa.py
```
OR... run the same script in parallel much faster (preferred choice in theory but it seems to be way too slow so maybe stick with normal execution if this at first seems slow (dont increase -j here rhough!)):
```
for f in `ls pep/*.aa.fasta`; do echo "python format-and-build-fa.py ${f}"; done | parallel -j 6 -k
```

then concat all these temp files into a single fasta:
```
cat tmp_files/*.aa.fasta.tmp > concatted-mycocosm.formatted.fasta
```

Build the blastdb:
```
mkdir output
cd output
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb \
-in ../concatted-mycocosm.formatted.fasta -blastdb_version 5 \
-title "jgi-mycocosm-prot" -out jgi-mycocosm-prot \
-dbtype prot -max_file_sz '4GB'
```


The workflow script just needs to be formatted to parse out the extra info from the result/subject ids now.

a workflow script was created in the usual place (jbconnect/node_modules/blastx-../workflows/...py and softlinked into jbconnect/workflows
and the above blast db was softlinked into the uisual place: jbconnect/blastdb/

Tested successfully in app.
Complete.


-----------

## JGI Phytozome steps:
```
cd /databases/blast
sudo mkdir phytozome12-proteins
sudo chmod a+rw phytozome12-proteins/
cd phytozome12-proteins

/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -u davistodt@gmail.com -p {w3...}
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -P 12 -l
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -P 12
```

download all phycocosm/mycocosm taxon ids (this was acquired via new email query to JGI answered on oct 20th by David Goodstein):
```
cd PhytozomeV12
curl -X GET "https://phytozome-next.jgi.doe.gov/api/db/properties/proteome/456%2C502%2C281%2C461%2C227%2C325%2C228%2C229%2C231%2C317%2C539%2C538%2C320%2C318%2C310%2C522%2C521%2C676%2C91%2C572%2C291%2C531%2C566%2C322%2C459%2C548%2C392%2C382%2C309%2C692%2C575%2C453%2C388%2C494%2C589%2C467%2C689%2C256%2C506%2C553%2C505%2C551%2C451%2C390%2C514%2C691%2C448%2C686%2C297%2C457%2C530%2C679%2C673%2C492%2C122%2C501%2C677%2C675%2C275%2C508%2C678%2C510%2C509%2C571%2C567%2C491%2C285%2C580%2C581%2C563%2C442%2C670%2C534%2C298%2C687%2C385%2C573%2C562%2C561%2C588%2C469%2C540%2C545%2C544%2C541%2C558%2C543%2C559%2C507%2C200%2C305%2C520%2C671%2C445%2C210%2C444%2C533%2C532%2C119%2C289%2C519%2C518%2C449%2C113%2C233%2C523%2C472%2C264%2C384%2C167%2C447%2C278%2C266%2C474%2C470%2C484%2C585%2C482%2C489%2C582%2C483%2C173%2C485%2C478%2C476%2C477%2C473%2C574%2C486%2C479%2C446%2C277%2C481%2C488%2C487%2C480%2C584%2C475%2C471%2C583%2C526%2C529%2C458%2C527%2C524%2C221%2C525%2C182%2C154%2C565%2C586%2C321%2C498%2C504%2C550%2C587%2C304%2C290%2C324%2C668%2C462%2C386%2C323%2C499%2C680%2C503%2C296%2C463%2C577%2C316%2C490%2C314%2C556%2C549%2C460%2C537%2C515%2C283%2C337%2C343%2C364%2C379%2C336%2C369%2C356%2C333%2C381%2C359%2C372%2C355%2C349%2C362%2C353%2C331%2C361%2C378%2C346%2C328%2C344%2C374%2C380%2C357%2C363%2C352%2C334%2C365%2C345%2C376%2C367%2C354%2C370%2C329%2C348%2C358%2C338%2C366%2C339%2C375%2C351%2C342%2C330%2C368%2C347%2C377%2C350%2C373%2C335%2C326%2C360%2C340%2C371%2C341%2C332%2C327%2C560%2C497%2C450%2C516%2C672%2C312%2C311%2C500%2C454%2C564%2C552%2C468%2C669%2C493%2C681%2C682%2C683%2C443%2C513%2C684%2C512%2C685%2C308%2C495%2C590%2C496%2C591?format=tsv" -H "accept: application/json"  > all_orgs_and_taxids.tsv
NB to note: we filter out the ones that are "restricted" in the python formatting script

cd pep
for f in `ls`; do gunzip $f; done
cd ..

format fasta headers of files and concat into one fasta:
python format-and-build-fa.py

build blastdb:
mkdir output
cat tmp_files/*.tmp > concatted-phytozome.formatted.fasta
cd output
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb \
-in ../concatted-phytozome.formatted.fasta -blastdb_version 5 \
-title "jgi-phytozome-prot" -out jgi-phytozome-prot \
-dbtype prot
```

then add the relevant workflow scripts to the blastx plugin dir and
symlink into jbconnect workflows, like followed in one of the above process.

-----
## Build EBI bacterial blastx db steps:

```
cd /databases/blast
sudo mkdir ebi-bacterial
sudo chmod a+rw ebi-bacterial/
cd ebi-bacterial/
```

Download table with ALL bacterial assemblies from EBI (this command was built using the webportal available at: https://www.ebi.ac.uk/ena/browser/)
```
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'result=assembly&query=tax_tree(2)&fields=accession%2Cassembly_title%2Cstudy_description%2Cscientific_name%2Ctax_id&limit=0&format=tsv' "https://www.ebi.ac.uk/ena/portal/api/search" > all_bacterial_accessions_taxon_2.tsv
```
Nevermind, scratch that. The EBI bacterial data portal does not have protein sequences.
Instead, we used ensembl bacterial portal and went to the download section, i.e: https://bacteria.ensembl.org/info/data/ftp/index.html

So:
```
cd ../
sudo mkdir ensembl-bacteria
sudo chmod a+rw ensembl-bacteria/
cd ensembl-bacteria
rsync --list-only -av --include='**/pep/*' rsync://ftp.ensemblgenomes.org/all/pub/bacteria/current/fasta/ . | grep "/pep/" | sed "s|^.* bacteria_|bacteria_|g" > file_list_to_dl.txt
```

which gives this example output (sample only):
```
head -n 3 file_list_to_dl.txt
bacteria_0_collection/acinetobacter_baumannii_aye_gca_000069245/pep/Acinetobacter_baumannii_aye_gca_000069245.ASM6924v1.pep.all.fa.gz
bacteria_0_collection/acinetobacter_baumannii_aye_gca_000069245/pep/CHECKSUMS
bacteria_0_collection/acinetobacter_baumannii_aye_gca_000069245/pep/README
```

Then use this file in the rsync cmd (I tried various combinations of --include-pattern and --exclude-pattern to no avail btw):
```
rsync -avrP --files-from=file_list_to_dl.txt rsync://ftp.ensemblgenomes.org/all/pub/bacteria/current/fasta/ .
```
note that you might need to run with the flag if rsync crashes with a weird error (its due to high mem/cpu usage on the machine even though it doesnt sound like it):
```
--bwlimit=6000
```

```
mkdir downloaded
mv * downloaded
mv downloaded/file_list_to_dl.txt .
```

format fasta headers (and bring in info from the file name into the header):
```
(no need to unzip fasta files)
python format-fa-headers.py
```

build blastdb:
```
mkdir blastdb_output
```
(the following is needed because a simple ls or cat will fail with so many files found:)
```
find output/ -name '*.tmp' -print0 | xargs -0 cat > concatted-ensemble-bacteria.formatted.fasta
(note that the above file is massive: about 76GB; so we will delete it when done)
```

```
cd blastdb_output
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb \
-in /databases/blast/ensembl-bacteria/concatted-ensemble-bacteria.formatted.fasta -blastdb_version 5 \
-title "ens-bacteria-prot" -out ens-bacteria-prot \
-dbtype prot

rm concatted-ensemble-bacteria.formatted.fasta
touch concatted-ensemble-bacteria.formatted.fasta.was.removed.due.to.size--regenerate-it-with-cat
```

NB!! there is a chance the whole db was not moved over as the connection broke
(instead of the abopve cmd,
I actually built the db in /blastdb, deleted the concatted fasta file, and moved it back to
the working dir of /databases/blast/ens....
Now since I deleted the concatted fasta (which took long to build), it would be difficult to
rebuild (since I am pretty sure that the whole dir was indeed copied) - its low risk but
bear in mind in case any weird results later on. Also, it **did** run the above touch cmd
automatically (i pasted it and ran it during the execution, so once the first cmd finished then it
would only have run the touch cmd, which it did).


------------------------------------------------------------------------------------------
## I think this was the cmd to add the repeat mnasker track:

```
./bin/flatfile-to-json.pl --gff data/Kappaphycus_alvarezii/repeat_masker/Kappaphycus_alvarezii.fasta.out.gff3 --trackLabel "Repeat Masker" --key "Repeat Masker" --out data/Kappaphycus_alvarezii --nameAttributes "Target,Repeat_Class,Position_in_repeat_begin,Position_in_repeat_end,Perc_div,Perc_del,Perc_ins"
```

------------------------------------------------------------------------------------------
## I think this was the cmd used to build the current (soon to be replaced) annotation track

```
some cmd here to add gff
```

```
./bin/generate-names.pl --verbose --out data/Kappaphycus_alvarezii --mem 1200000000 --workdir /blastdb/tmp/ --incremental
```


------------------------------------------------------------------------------------------
## Steps taken to download and install pathway tools (rough copy paste of most of the cmds)
 
 ```
 1004  mkdir p-tools
 1005  chmod a+rw p-tools/
 1006  cd p-tools/
 1007  wget http://bioinformatics.ai.sri.com/ecocyc/dist/ptools-tier1-34987569/pathway-tools-25.0-linux-64-tier1-install
 1008  wget --user=ptools-runtimes --password=runtimes-14285  http://bioinformatics.ai.sri.com/ecocyc/dist/ptools-tier1-34987569/pathway-tools-25.0-linux-64-tier1-install
 1009  which csh
 1010  yum install motif
 1011  sudo yum install motif
 1012  ls
 1013  lbblk
 1014  lsblk
 1015  sudo file -s /dev/xvdi
 1016  sudo mkfs -t xfs /dev/xvdi
 1017  sudo mkdir /large-store
 1018  sudo mount /dev/xvdi /large-store
 1019  chmod a+rw /large-store/
 1020  sudo chmod a+rw /large-store/
 1021  pwd
 1022  ls
 1023  cd ..
 1024  ls
 1025  mv p-tools/ /large-store/
 1026  cd /large-store/
 1027  ls
 1028  cd p-tools/
```

```
chmod u+x pathway-tools-25.0-linux-64-tier1-install
```

To allow x11 forwarding:
```
sudo yum install xorg-x11-xauth

sudo yum install gnome-terminal

tmux a -t ptools

 mkdir pathway-tools
 mkdir data

./pathway-tools-25.0-linux-64-tier1-install
```

Review settings before copying files

```
Install Directory:
      /large-store/p-tools/pathway-tools

      Pathway Tools Configuration and Data Directory:
      /large-store/p-tools/data/ptools-local

```
then run the software (doesnt work, throws errors):
```
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools

Some errors (slightly different after conda deactivating):
******
(base) [ec2-user@ip-172-31-89-223 p-tools]$ conda deactivate
[ec2-user@ip-172-31-89-223 p-tools]$
[ec2-user@ip-172-31-89-223 p-tools]$
[ec2-user@ip-172-31-89-223 p-tools]$
[ec2-user@ip-172-31-89-223 p-tools]$ ./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools
Warning: Loading sys:climxm.so failed with error:
         libXpm.so.4: cannot open shared object file: No such file or directory.
;; ensure-directories-exist: creating
;;   /large-store/p-tools/pathway-tools/aic-export/pathway-tools/ptools/25.0/patches/bin-acl-10-1-amd64-linux/
;; Directory
;;   /large-store/p-tools/pathway-tools/aic-export/pathway-tools/ptools/25.0/patches/bin-acl-10-1-amd64-linux/
;;   does not exist, will create.
;; Optimization settings: safety 3, space 1, speed 1, debug 3.
;; For a complete description of all compiler switches given the
;; current optimization settings evaluate (EXPLAIN-COMPILER-SETTINGS).
An unhandled error occurred during initialization:
Attempt to call
#("InitializeMyDrawingAreaQueryGeometry" 140226142711360 0 2
  140226142711360 8)
for which the definition has not yet been (or is no longer) loaded.
*****
```
Then I did this (not sure if its right but it seems to get me further):
```
sudo yum install libXpm
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools
```

which gave the following errors:
```
****
Error: Init file /large-store/p-tools/data/ptools-local/ptools-init.dat
       not found.
This probably means that Pathway Tools installation did not complete
       successfully.
Check for installation errors or try reinstalling.
If this is a shared installation, you will need to generate your own
       init file.
To do this, invoke pathway-tools with the -config option.


Restart actions (select using :continue):
 0: Abort entirely from this (lisp) process.
*****
```

exit
ssh back in (to rather try from the std conda base env like before, now that we have libxm installed)
```
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools
```
ok so still same errors as before, which means we need to do the conda deactivate afterall:
```
*******
An unhandled error occurred during initialization:
Error #<FILE-ERROR @ #x1007428ca52> occurred loading OpenSSL
libraries.  Is OpenSSL installed in a standard place, or is
LD_LIBRARY_PATH set?.
Loading libcrypto.so failed with error:
libcrypto.so: cannot open shared object file: No such file or directory.

****
```
NB: read issue 1 of https://bioinformatics.ai.sri.com/ptools/faq.html for some tips for future

```
conda deactivate
```
then create a config file since one doesnt exist yet:
```
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools -config

less /large-store/p-tools/data/ptools-local/ptools-init.dat
nano /large-store/p-tools/data/ptools-local/ptools-init.dat
```
^ edit the above file to have the following:
```
WWW-Server-SSL-Certificate NIL
WWW-Server-Hostname localhost
WWW-Server-Port 1555
```

```
tmux a -t ptools
conda deactivate
```
now, it is essential to proceed using the *xQuartz terminal* (if on mac)!
Using that terminal (not a normal/pychar,m terminal), ssh in with the -Y flag
and rejoin the tmux session and then run:
```
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools -www -www-server-hostname 0.0.0.0
```

(when asked for x forwarding display to use, type in localhost:10.0 and hit enter a few times)
then wait at least a minute and a wiondow shold display ion your mac!

Then open up port `:1555` in AWS console so that we can access the webserver

seems to not quite work.


------------------------------------------------------
## Installing sequenceserver

```
mkdir /blastdb/sequenceserver
cd /blastdb
chmod a+rw sequenceserver
cd sequenceserver
```
```
 NOTE ---> `sudo yum -y install gem`  --> ran this first but it crashed so reran the following cmd and it worked:
```
```
sudo yum install ruby-devel
gem install sequenceserver
```
set up directory to store blastdbs for seq server and link in the latest gene/prot prediction seqs:
```
mkdir /blastdb/sequenceserver/dbs
cd /blastdb/sequenceserver/dbs
ln -s /data/juans-annotations/oct18-version/Kappaphycus_alvarezii_proteins_v2.fasta .
ln -s /data/juans-annotations/oct18-version/Kappaphycus_alvarezii_cdna_v2.fasta .
do the same for the genome assemby:
ln -s /data/moved-from-home-dir/data/kappaphycus_alvarezii_genome/GCA_002205965.3_ASM220596v3_genomic.fasta .

tmux
```
then rename it to sequenceserver
```
tmux a -t sequenceserver
```

then run sequenceserver to set it up for the first time and follow the prompts:
```
sequenceserver
```

and supply it with the blast+ binaries and dbs folder, i.e.:
/data/davis--blast-dbs/ncbi-blast-2.12.0+/


to restart the server in future, you just rerun:
```
sequenceserver
```


------------------------------------------------------------------------------------------
## Rough steps taken to REBUILD non-working phycocosm blastn db (this is an abbreviated version)

```
install gnu parallel (easy):
http://git.savannah.gnu.org/cgit/parallel.git/tree/README

tmux a -t build-blast-db
```

The following are completed after phycocosm sequences are already downloaded to the below path, using get_jgi_genomes gutub open source tool
```
cd /blastdb/phycocosm

for f in `ls assembly/*.fasta`; do echo "python format-and-build-fasta.py ${f}"; done | parallel -j 6 -k

mkdir annotated-assembly-v2/
cat tmp_files/*.tmp > annotated-assembly-v2/concatted-phycocosm.fasta
cd annotated-assembly-v2/
mkdir output
cd output

/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb -in ../concatted-phycocosm.fasta -blastdb_version 5 -title "jgi-phycocosm" -out jgi-phycocosm -dbtype nucl
```

The workflow script just needs to be formatted to parse out the extra info from the result/subject ids now.

Then test the run using the following:
```
/data/jbconnect/blastbin/ncbi-blast-2.8.1+/bin/blastn -db /data/jbconnect/blastdb/jgi-phycocosm/jgi-phycocosm -outfmt 5 -out /data/jbconnect/node_modules/@gmod/jbrowse/d
ata/Kappaphycus_alvarezii/jblastdata/592c1e30-3c70-11ec-9eee-5b7e88f1a1a1.blastxml -query /data/jbconnect/node_modules/@gmod/jbrowse/data/Kappaphycus_alvarezii/jblastdata/blast_region16
35921371543.fa

```

------------------------------------------------------------------------------------------
## Stesp to copy meiks transcriptome across to ec2 instance:

first mkdirs:
```
/databases/transcriptome_assembly_meik

then from within the cro server, inside my ftp folder space:
scp -i deleteme.txt -r 01_denovo ec2-user@52.90.88.45:/databases/transcriptome_assembly_meik
scp -i deleteme.txt -r 02_guided ec2-user@52.90.88.45:/databases/transcriptome_assembly_meik
```

then add as tracks:
```
mkdir /home/ec2-user/jbconnect/node_modules/@gmod/jbrowse/data/transcriptome
cd /home/ec2-user/jbconnect/node_modules/@gmod/jbrowse/data/transcriptome

ln -s /databases/transcriptome_assembly_meik/01_denovo/redalgae-denovo.fasta .
ln -s /databases/transcriptome_assembly_meik/02_guided/redalgae-guided.fasta .
samtools faidx redalgae-denovo.fasta
samtools faidx redalgae-guided.fasta
cd ../..

./bin/prepare-refseqs.pl --fasta \
data/transcriptome/redalgae-denovo.fasta \
--out data/Kappaphycus_alvarezii \
--trackLabel "De novo Transcriptome assembly" \
--key "De novo Transcriptome assembly"

./bin/prepare-refseqs.pl --fasta \
data/transcriptome/redalgae-guided.fasta \
--out data/Kappaphycus_alvarezii \
--trackLabel "Guided Transcriptome assembly" \
--key "Guided Transcriptome assembly"

(note that --indexed_fasta did not work in borwser!)
```

------------------------------------------------------------------------------------------
## Steps to copy meiks transcriptome **annotations** across to ec2 instance and REDO the adding of transcriptome reference sequence as a new ref seq to the app + adding all annotation files

first mkdirs:
```
mkdir -p /large-store/annotations/transcriptome_assembly_meik/03_annotation/
cd /large-store/annotations/transcriptome_assembly_meik/03_annotation/
```

then from within the cro server:
```
cd /scratch/projects/c026/algea/transcriptome_Meik/03_annotation
scp -i deleteme.txt -r recommended scp -i /scratch/ftp/user2046/deleteme.txt -r recommended ec2-user@52.90.88.45:/large-store/annotations/transcriptome_assembly_meik/03_annotation
```

then back to the aws server from now on, move the other transcriptome files to live closer to these 
(note that this will break softlinks in the app but we dont care
about them because we are going to rather re-add these as an entirely new ref sequence in the app.

```
cd ..
mv /databases/transcriptome_assembly_meik/* .
```

go into previous trans folder and replace broken links with new ones:
```
cd /home/ec2-user/jbconnect/node_modules/@gmod/jbrowse/data/transcriptome
unlink redalgae-denovo.fasta
unlink redalgae-guided.fasta
ln -s /large-store/annotations/transcriptome_assembly_meik/01_denovo/redalgae-denovo.fasta .
ln -s /large-store/annotations/transcriptome_assembly_meik/02_guided/redalgae-guided.fasta .
```

NB!!! In case something goes wrong in the app later! I moved some files as follows:
```
(base) [ec2-user@ip-172-31-89-223 data]$ mv davis--blast-dbs/blastdbs/phycocosm /large-store/blastdbs-moved/phycocosm
(base) [ec2-user@ip-172-31-89-223 data]$ cd davis--blast-dbs/blastdbs/
(base) [ec2-user@ip-172-31-89-223 blastdbs]$ ls
(base) [ec2-user@ip-172-31-89-223 blastdbs]$ ls /large-store/blastdbs-moved/phycocosm/
phycocosm.00.nhr  phycocosm.00.nog  phycocosm.01.nhr  phycocosm.01.nog  phycocosm.02.nhr  phycocosm.02.nog  phycocosm.nal  phycocosm.nos  phycocosm.ntf
phycocosm.00.nin  phycocosm.00.nsq  phycocosm.01.nin  phycocosm.01.nsq  phycocosm.02.nin  phycocosm.02.nsq  phycocosm.ndb  phycocosm.not  phycocosm.nto
(base) [ec2-user@ip-172-31-89-223 blastdbs]$ ln -s /large-store/blastdbs-moved/phycocosm .
```

Build new ref sequence:
```
tmux a -t indexing
cd - (i.e. into jbrowse root folder)

./bin/prepare-refseqs.pl --fasta \
data/transcriptome/redalgae-denovo.fasta \
--out data/Kappaphycus_alvarezii_transcriptome \
--trackLabel "De novo transcriptome assembly" \
--key "De novo transcriptome assembly"
```

The above was tested and worked in the browser, now time to format and add annotation tracks:
Firstly, the annotation gff file seems to have UTF-8 encoded URL in the fields which needs to be changed, eg:

```
TRINITY_DN0_c0_g1_i1    transdecoder    gene    1       906     .       +       .       ID=TRINITY_DN0_c0_g1_i1|g.2833;Name=ORF%20TRINITY_DN0_c0_g1_i1%7Cg.2833%20TRINITY_DN0_c0_g1_i1%7Cm.2833%20type%3A3prime_partial%20len%3A119%20%28%2B%29
TRINITY_DN0_c0_g1_i1    transdecoder    mRNA    1       906     .       +       .       ID=TRINITY_DN0_c0_g1_i1|m.2833;Parent=TRINITY_DN0_c0_g1_i1|g.2833;Name=ORF%20TRINITY_DN0_c0_g1_i1%7Cg.2833%20TRINITY_DN0_c0_g1_i1%7Cm.2833%20type%3A3prime_partial%20len%3A119%20%28%2B%29
```

so therefore run the script to reformat:
```
python format-gff3.py
```

and get a list of params in the gff to use during adding the track:
```
head -n 3 transcripts.formatted.gff3

TRINITY_DN0_c0_g1_i1    transdecoder    gene    1       906     .       +       .       ID=TRINITY_DN0_c0_g1_i1|g.2833;Name=ORF TRINITY_DN0_c0_g1_i1|g.2833 TRINITY_DN0_c0_g1_i1|m.2833 type:3prime_partial len:119 (+)
TRINITY_DN0_c0_g1_i1    transdecoder    mRNA    1       906     .       +       .       ID=TRINITY_DN0_c0_g1_i1|m.2833;Parent=TRINITY_DN0_c0_g1_i1|g.2833;Name=ORF TRINITY_DN0_c0_g1_i1|g.2833 TRINITY_DN0_c0_g1_i1|m.2833 type:3prime_partial len:119 (+)
TRINITY_DN0_c0_g1_i1    transdecoder    five_prime_UTR  1       550     .       +       .       ID=TRINITY_DN0_c0_g1_i1|m.2833.utr5p1;Parent=TRINITY_DN0_c0_g1_i1|m.2833
```

Note that the script also adds some essential gff3 tags to the file, for example the header,
and rows with "###" which are essential for the flatfile to json script to run properly.
Otherwise it crashes with the uninformative error "Killed." which is due to memory/file format.

```
pwd
cd ~/jbconnect/node_modules/@gmod/jbrowse/
cd data/transcriptome/
ln -s /large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended/transcripts.formatted.gff3 .
cd ../..
./bin/flatfile-to-json.pl \
--gff data/transcriptome/transcripts.formatted.gff3 \
--trackLabel "Annotated genes - transcriptome" --key "Annotated genes - transcriptome" \
--out data/Kappaphycus_alvarezii_transcriptome \
--nameAttributes "ID,Name" \
--sortMem 209715200 \
--maxLookback 1000
```

^ the above crashed due to disk space... so..
NB!!! In case something goes wrong in the app later! I moved some files as follows:

```
mv /data/data-dir-used-by-jbrowse1-data-dir /large-store/data-dir-used-by-jbrowse1-data-dir
cd ~/jbconnect/node_modules/@gmod/jbrowse/
unlink data
ln -s /large-store/data-dir-used-by-jbrowse1-data-dir data
```

Then try rerunning the crashed script:
```
./bin/flatfile-to-json.pl --gff data/transcriptome/transcripts.formatted.gff3 --trackLabel "Annotated genes - transcriptome" --key "Annotated genes - transcriptome" --out data/Kappaphycus_alvarezii_transcriptome --nameAttributes "ID,Name" --sortMem 109715200 --maxLookback 100
```

It ran to completion.
I then restarted the server and can confirm that it works after these changes.


Then I removed the old, wrong trans assembly tracks which were under the ka genome view.
In the ka tracklist.json file I deleted the following two tracks:
```bash
,
        {
            "category": "Reference sequence",
            "chunkSize": 20000,
            "key": "De novo Transcriptome assembly",
            "label": "De novo Transcriptome assembly",
            "seqType": "dna",
            "storeClass": "JBrowse/Store/Sequence/StaticChunked",
            "type": "SequenceTrack",
            "urlTemplate": "seq/{refseq_dirpath}/{refseq}-"
        },
        {
            "category": "Reference sequence",
            "chunkSize": 20000,
            "key": "Guided Transcriptome assembly",
            "label": "Guided Transcriptome assembly",
            "seqType": "dna",
            "storeClass": "JBrowse/Store/Sequence/StaticChunked",
            "type": "SequenceTrack",
            "urlTemplate": "seq/{refseq_dirpath}/{refseq}-"
        }
```
Remember that these were manually removed in future, if the indexing thing
gives us cases where you get search results for something not meant to be 
there.

Note that the following was the original track created now from the above steps to add
the tra gene annotation track. It looked nice in terms of colour and name of the 
track being diplayed next to each feature but it only showed genes, not exons etc below 
the genes:

```bash
      {
         "compress" : 0,
         "category": "Annotations",
         "key" : "Annotated genes - transcriptome",
         "label" : "Annotated genes - transcriptome",
         "storeClass" : "JBrowse/Store/SeqFeature/NCList",
         "style" : {
            "className" : "feature"
         },
         "trackType" : null,
         "type" : "FeatureTrack",
         "urlTemplate" : "tracks/Annotated genes - transcriptome/{refseq}/trackData.json"
      }
```

Ok so I ended up moving on, I couldnt seem to get the subfeatures to all display 
independently, despite using the same config settings as the main ka tracklist.json config.


Ok, now to add the uniprot blastx hits.
```
cd /large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended
```

nano and add this line to the top of the uniprot hits gff file:
```
##gff-version 3
```

then go back, link the file (not shown here!) and attempt to add as a track using flatfile to json:
``` 
cd -
./bin/flatfile-to-json.pl \
--gff data/transcriptome/uniprot_hits.gff3 \
--trackLabel "Blastx UniProt results" \
--key "Blastx UniProt results" \
--out data/Kappaphycus_alvarezii_transcriptome \
--nameAttributes "ID,Name,Parent," --sortMem 109715200 --maxLookback 100

```

It worked perfectly. 
Now lets add the other annotation, the pfam one:

```
cd /large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended
```

nano and add this line to the top of the uniprot hits gff file:
```
##gff-version 3
```

then go back, link the file and attempt to add as a track using flatfile to json:
``` 
cd -
cd data/transcriptome
ln -s /large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended/pfam.gff3 .
cd ../..

./bin/flatfile-to-json.pl \
--gff data/transcriptome/pfam.gff3 \
--trackLabel "Pfam domain results" \
--key "Pfam domain results" \
--out data/Kappaphycus_alvarezii_transcriptome \
--nameAttributes "ID,Name,Parent," --sortMem 109715200 --maxLookback 100
```

It seemed to finish successfully but yet in the browser the track has zero features...
I realised that this is because its mapped to peptide sequence, not nucleotide, so we
shouldn't really have it as a track here. We wont add it in the new iteration.


We then got that massive bug where the app takes forever to load. 
So we deleted all traces of the transcr tracks and started again in the below section.


We will revisit this and other tracks later on, once we have added the trans protein ref seq.

---------------------------------------
## [2021-11-11] Replacing Juans repeat masker track with new one

NB: moved the entire juans annotations folder to the large store so that we can keep
everything in one place. Important to remember if things dont work right in the app!!

``` 
cd /large-store/annotations/
mv /data/juans-annotations .
cd /data
ln -s /large-store/annotations/juans-annotations .
cd /large-store/annotations/juans-annotations
mkdir nov9th-version
cd nov9th-version
mkdir repeat_masker
cd repeat_masker
wget -O Kappaphycus_alvarezii_repeats.gff.gz https://www.dropbox.com/s/a5jv4685x6eqb21/Kappaphycus_alvarezii_repeats.gff.gz?dl=1
```

Upon inspection, it looks like the "new" file above has no more information
than what I already annotated my old repeat file with. So I'm going to continue
leaving it as is and NOT replace the old track with this new one above.



--------
[2021-11-11] Trying to fix broken app

```
./bin/generate-names.pl --verbose --out data/Kappaphycus_alvarezii_transcriptome --mem 1200000000 --workdir /blastdb/tmp/ --incremental
```

Above didnt help.

Trying to clear up space on "/" (only 200mb free space):
(NB: in case one or two bam files have any issues displaying later down the line, 
consider checking that no links were broken from the below changes).
```
1020  cd /data/
 1021  unlink ERR2041141.bam
 1022  df -h
 1023  mv /davis-data/bams-moved-from-root-data-dir/ERR2041141.bam .
 1024  ll ERR2041141.bam
 1025  md5sum ERR2041141.bam
 1026  md5sum /davis-data/bams-moved-from-root-data-dir/ERR2041141.bam
 1027  sudo rm /davis-data/bams-moved-from-root-data-dir/ERR2041141.bam
 1028  df -h
 1029  ll /davis-data/bams-moved-from-root-data-dir/
 1030  ll | grep "SRR1207056.b"
 1031  unlink SRR1207056.bam
 1032  cp /davis-data/bams-moved-from-root-data-dir/SRR1207056.bam .
 1033  md5sum /davis-data/bams-moved-from-root-data-dir/SRR1207056.bam
 1034  md5sum SRR1207056.bam
 1035  rm /davis-data/bams-moved-from-root-data-dir/SRR1207056.bam
 1036  sudo rm /davis-data/bams-moved-from-root-data-dir/SRR1207056.bam
```

Tested the above. Doesnt seem that it was a disk space issue.

Then also tried to "delete" all traces of the transcriptome reference 
dataset track because this issue never used to happen before we added the transcriptome
annotation track pFam. So going to try this and then try re-add it all in another test afterwards.

```
cd into jbrowse directory
mkdir /large-store/temp/
cp -r Kappaphycus_alvarezii_transcriptome /large-store/temp/Kappaphycus_alvarezii_transcriptome
rm -r Kappaphycus_alvarezii_transcriptome/seq
rm -r Kappaphycus_alvarezii_transcriptome/
then also remove mention of this reference from jbrowse.conf
```

------------------------------------------------------------------------------------------
## [2021-11-15 DAVIS+ALEX TOGETHER] Steps to re-add meiks transcriptome reference + **annotations**

Note that this section follows the above section, after deleting the transcr tracks.


To view our available files that we might want to add (once you've copied them here):
```
ls /large-store/annotations/transcriptome_assembly_meik/03_annotation/
```

index fasta (if not done already):
```
samtools faidx data/transcriptome/redalgae-denovo.fasta
```

build ref using script:
```
date && \
./bin/prepare-refseqs.pl --indexed_fasta \
data/transcriptome/redalgae-denovo.fasta \
--out data/Kappaphycus_alvarezii_transcriptome \
--trackLabel "De novo transcriptome assembly" \
--key "De novo transcriptome assembly" \
&& date
```

Add the following code block to jbrowse.conf to add this reference as a menu option in the browser:
`` 
[datasets.Kappaphycus_alvarezii_transcriptome]
url  = ?data=data/Kappaphycus_alvarezii_transcriptome
name = Kappaphycus alvarezii Transcriptome
``

Add the following line to the trascriptomes trackList.json file, at the top level:

``` 
   "dataset_id": "Kappaphycus_alvarezii_transcriptome",
```

add the gene annotation track:
```
date && \
./bin/flatfile-to-json.pl \
--gff data/transcriptome/transcripts.formatted.gff3 \
--trackLabel "Annotated genes - transcriptome" \
--key "Annotated genes - transcriptome" \
--out data/Kappaphycus_alvarezii_transcriptome \
--nameAttributes "ID,Name" \
--sortMem 109715200 \
&& date
```

then add the (previously formatted) blastx hits file as a track using flatfile to json:
``` 
date && \
./bin/flatfile-to-json.pl \
--gff data/transcriptome/uniprot_hits.gff3 \
--trackLabel "Blastx UniProt results" \
--key "Blastx UniProt results" \
--out data/Kappaphycus_alvarezii_transcriptome \
--nameAttributes "ID,Name," --sortMem 109715200 \
&& date
```

All of the above up until here have now been tested and work.
In my browser it seems to still be behaving slowly, but via phone and also tested by Alex, 
it all works as expected.



---------------------------------------
## [2021-11-16/17] Adding Meik's 2 new tracks (unigene and interpro hits) 


Then from within the cro server, we need to copy over the two new files to the aws (i.e. app server) server:
```
cd /scratch/projects/c026/algea/transcriptome_Meik/03_annotation
scp -i /scratch/ftp/user2046/deleteme.txt recommended/interpro_hits.* ec2-user@52.90.88.45:/large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended
scp -i /scratch/ftp/user2046/deleteme.txt -r unigene_annotated_264089 ec2-user@52.90.88.45:/large-store/annotations/transcriptome_assembly_meik/03_annotation/unigene_annotated_264089
```

Then back to the aws server from now on.

Now, we want to see what fields are present inside the gff3 file that we might want to use for indexing.
```
less /large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended/interpro_hits.gff3
```

The following fields are currently present:
```
ID,Name,signature_desc,Dbxref,Ontology_term......
```

Lets make it as similar to juans old annotation as possible, i.e. we want at least the following fields in the gff3, probably others too:
```
Parent,Name,transcript_id,gene_id,pathway_term,Ontology_term,SUPERFAMILY_ID=
```

e.g.: `pathway_term=MetaCyc:PWY-1061,MetaCyc:PWY-1121,.......`
e.g.: `pathway_term=Reactome:R-HSA-2408522,Reactome:R-HSA-379716,Reactome:R-HSA-379726,`
e.g.: `Ontology_term=GO:0000166,GO:0004812,GO:0005524,GO:0006418;`
e.g.: `SUPERFAMILY_ID=SSF47323 (Anticodon-binding domain of a subclass of class I aminoacyl-tRNA synthetases);`
e.g.: `PANTHER_ID=PTHR10890 (CYSTEINYL-TRNA SYNTHETASE),PTHR10890:SF3 (CYSTEINE--TRNA LIGASE, CYTOPLASMIC);`
e.g.: `Gene3D_DESCR=- (G3DSA:1.20.120.1910);`
e.g.: `PANTHER_DESCR=CYSTEINE--TRNA LIGASE, CYTOPLASMIC (PTHR10890:SF3),CYSTEINYL-TRNA SYNTHETASE (PTHR10890);`
e.g.: `SUPERFAMILY_DESCR=Anticodon-binding domain of a subclass of class I aminoacyl-tRNA synthetases (SSF47323)`


Actually, we needed to write a script anyway to format the file, which gives us the above info as it runs:
```
python format-interpro-gff.py interpro_hits.gff3
```

which gave the following output:
```
DBS encountered (useful when adding flatfile as a jbrowse track):
SUPERFAMILY_DESCR,CDD_ID,ProSitePatterns_ID,PANTHER_DESCR,ProSiteProfiles_DESCR,PIRSR_DESCR,Gene3D_DESCR,PANTHER_ID,SFLD_DESCR,TIGRFAM_ID,SMART_DESCR,SFLD_ID,Pfam_ID,Ontology_term,Gene3D
_ID,CDD_DESCR,TIGRFAM_DESCR,Coils_DESCR,ProSitePatterns_DESCR,PRINTS_DESCR,MobiDBLite_DESCR,Coils_ID,pathway_term,MobiDBLite_ID,SMART_ID,SUPERFAMILY_ID,Pfam_DESCR,Hamap_ID,InterPro_ID,Ha
map_DESCR,ProSiteProfiles_ID,PIRSF_ID,PRINTS_ID,PIRSF_DESCR,PIRSR_ID
Out file written to: format-ips-file/interpro_hits.formatted.gff3.
Total time: 0:02:53.817312
Complete.
```


Therefore, the following fields will be used:
```
signature_desc
```

Now, add this newly formatted gff3 file as a track using flatfile to json:
``` 
cd data/transcriptome/
ln -s /large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended/format-ips-file/interpro_hits.formatted.gff3 .
cd ../..

date && \
./bin/flatfile-to-json.pl \
--gff data/transcriptome/interpro_hits.formatted.gff3 \
--trackLabel "Gene annotation results (InterPro Scan)" \
--key "Gene annotation results (InterPro Scan)" \
--out data/Kappaphycus_alvarezii_transcriptome \
--nameAttributes "ID,Name,SUPERFAMILY_DESCR,CDD_ID,ProSitePatterns_ID,PANTHER_DESCR,ProSiteProfiles_DESCR,PIRSR_DESCR,Gene3D_DESCR,PANTHER_ID,SFLD_DESCR,TIGRFAM_ID,SMART_DESCR,SFLD_ID,Pfam_ID,Ontology_term,Gene3D_ID,CDD_DESCR,TIGRFAM_DESCR,Coils_DESCR,ProSitePatterns_DESCR,PRINTS_DESCR,MobiDBLite_DESCR,Coils_ID,pathway_term,MobiDBLite_ID,SMART_ID,SUPERFAMILY_ID,Pfam_DESCR,Hamap_ID,InterPro_ID,Hamap_DESCR,ProSiteProfiles_ID,PIRSF_ID,PRINTS_ID,PIRSF_DESCR,PIRSR_ID" --sortMem 209715200 \
&& date
```

NB: just realised that the above track was using peptide coordinates, NOT nucleotide coordinates...
Therefore it maps successfully to the transcriptome assembly but its incorrect - the positions are meant to be for
amino acids. So lets add a new reference seq for the peptides and rather add this track there. 



---------------------------------------
## [2021-11-17] Adding a new reference sequence just for protein (aa) + annotations (interpro + unigene)

So, lets add a new amino acid reference sequence:
```
cd data/transcriptome
ln -s /large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended/transcripts.faa .
```

index fasta:
```
samtools faidx data/transcriptome/transcripts.faa
```

build ref using script:
```
date && \
./bin/prepare-refseqs.pl --indexed_fasta \
data/transcriptome/transcripts.faa \
--out data/Kappaphycus_alvarezii_transcriptome_protein \
--trackLabel "De novo transcriptome assembly protein" \
--key "De novo transcriptome assembly protein" \
&& date
```

Add the following code block to jbrowse.conf to add this reference as a menu option in the browser:
`` 
[datasets.Kappaphycus_alvarezii_transcriptome_protein]
url  = ?data=data/Kappaphycus_alvarezii_transcriptome_protein
name = Kappaphycus alvarezii Transcriptome (Protein)
``

Add the following line to the new reference's trackList.json file, at the top level:

``` 
   "dataset_id": "Kappaphycus_alvarezii_transcriptome_protein",
```


Now add gff annotation as a track, using a similar cmd to what we tried to do when we added it incorrectly as a track to the transcriptome nucleotide sequence:
```
cd data/transcriptome/
ln -s /large-store/annotations/transcriptome_assembly_meik/03_annotation/recommended/format-ips-file/interpro_hits.aa.formatted.gff3 .
cd ../..

date && \
./bin/flatfile-to-json.pl \
--gff data/transcriptome/interpro_hits.aa.formatted.gff3 \
--trackLabel "De novo transcriptome assembly - protein annotation (InterPro Scan)" \
--key "De novo transcriptome assembly - protein annotation (InterPro Scan)" \
--out data/Kappaphycus_alvarezii_transcriptome_protein \
--nameAttributes "ID,Name,Coils_ID,Hamap_ID,ProSiteProfiles_ID,Pfam_DESCR,pathway_term,ProSiteProfiles_DESCR,InterPro_ID,SMART_DESCR,SFLD_DESCR,PANTHER_DESCR,Pfam_ID,Gene3D_DESCR,SUPERFAMILY_ID,MobiDBLite_ID,PRINTS_ID,ProSitePatterns_DESCR,PRINTS_DESCR,Hamap_DESCR,PIRSR_ID,PANTHER_ID,TIGRFAM_ID,SMART_ID,ProSitePatterns_ID,PIRSF_DESCR,PIRSR_DESCR,MobiDBLite_DESCR,TIGRFAM_DESCR,SFLD_ID,Ontology_term,PIRSF_ID,SUPERFAMILY_DESCR,CDD_DESCR,Coils_DESCR,Gene3D_ID,CDD_ID" --sortMem 209715200 \
&& date
```

Completed successfully and tested the app - this new page works.

Now we can also add Meik's unigene annotation to this new aa reference:
```
cd /large-store/annotations/transcriptome_assembly_meik/03_annotation/unigene_annotated_264089
python format-unigene.py redalgae-longest_orfs-85.pep.gff3

which outputs:

Wrote 20000 lines. Total so far: 4140000
Databases (keys) encountered (useful when adding flatfile as a jbrowse track):
Pfam_ID,TIGRFAM_DESCR,SMART_ID,MobiDBLite_DESCR,PIRSR_DESCR,PRINTS_ID,InterPro_ID,pathway_term,ProSitePatterns_DESCR,SUPERFAMILY_DESCR,Coils_ID,MobiDBLite_ID,ProSitePatterns_ID,CDD_DESCR,Ontology_term,SUPERFAMILY_ID,TIGRFAM_ID,Gene3D_DESCR,ProSiteProfiles_ID,PANTHER_ID,Gene3D_ID,Coils_DESCR,PIRSF_DESCR,Pfam_DESCR,PANTHER_DESCR,PRINTS_DESCR,Hamap_ID,ProSiteProfiles_DESCR,CDD_ID,Hamap_DESCR,SMART_DESCR,PIRSF_ID,SFLD_DESCR,PIRSR_ID,SFLD_ID
Out file written to: format-ips-file/redalgae-longest_orfs-85.pep.formatted.gff3.
Total time: 0:01:34.671508
Complete.
```

Now add as track:
```
cd /home/ec2-user/jbconnect/node_modules/@gmod/jbrowse/data/transcriptome
ln -s /large-store/annotations/transcriptome_assembly_meik/03_annotation/unigene_annotated_264089/format-unigene/redalgae-longest_orfs-85.pep.formatted.gff3 .
cd ../..


date && \
./bin/flatfile-to-json.pl \
--gff data/transcriptome/redalgae-longest_orfs-85.pep.formatted.gff3 \
--trackLabel "De novo transcriptome assembly - protein annotation (UniGene)" \
--key "De novo transcriptome assembly - protein annotation (UniGene)" \
--out data/Kappaphycus_alvarezii_transcriptome_protein \
--nameAttributes "ID,Name,Pfam_ID,TIGRFAM_DESCR,SMART_ID,MobiDBLite_DESCR,PIRSR_DESCR,PRINTS_ID,InterPro_ID,pathway_term,ProSitePatterns_DESCR,SUPERFAMILY_DESCR,Coils_ID,MobiDBLite_ID,ProSitePatterns_ID,CDD_DESCR,Ontology_term,SUPERFAMILY_ID,TIGRFAM_ID,Gene3D_DESCR,ProSiteProfiles_ID,PANTHER_ID,Gene3D_ID,Coils_DESCR,PIRSF_DESCR,Pfam_DESCR,PANTHER_DESCR,PRINTS_DESCR,Hamap_ID,ProSiteProfiles_DESCR,CDD_ID,Hamap_DESCR,SMART_DESCR,PIRSF_ID,SFLD_DESCR,PIRSR_ID,SFLD_ID" --sortMem 209715200 \
&& date
```

Added and tested in the app successfully!

---------------------------------------
## [2021-11-17] Re-adding the pfam track from a few days ago when the app broke (this time, adding to the protein refseq)

Add as a track using flatfile to json:
``` 
date && \
./bin/flatfile-to-json.pl \
--gff data/transcriptome/pfam.gff3 \
--trackLabel "Pfam domain results" \
--key "Pfam domain results" \
--out data/Kappaphycus_alvarezii_transcriptome_protein \
--nameAttributes "ID,Name" --sortMem 109715200 --maxLookback 100 \
&& date
```

Tested in the app and it works successfully.

---------------------------------------
## [2021-11-17/18] Replacing Juans annotation track with new one from nov9th

download all new files:
``` 
cd /large-store/annotations/juans-annotations/nov9th-version
wget -O Kappaphycus_alvarezii_cdna_v2.fasta.gz https://www.dropbox.com/s/7s8cyn52uxmupe2/Kappaphycus_alvarezii_cdna_v2.fasta.gz?dl=1
wget -O Kappaphycus_alvarezii_proteins_annot_seqs_v2.gtf.gz https://www.dropbox.com/s/6smc8cf1450suxl/Kappaphycus_alvarezii_proteins_annot_seqs_v2.gtf.gz?dl=0
gunzip Kappaphycus_alvarezii_proteins_annot_seqs_v2.gtf.gz
split -n l/6 Kappaphycus_alvarezii_proteins_annot_seqs_v2.gtf Kappaphycus_alvarezii_proteins_annot_seqs_v2.
```
The last cmd above splits the input file into 6 each parts using the correct prefix.
Just need to rename all of these to .gtf for the script to recognise:

```
for f in `ls *_v2.a*`; do echo $f; mv $f ${f}.gtf; done; ls

date && for f in `ls *_v2.a*gtf`; do python format-ips-gtf.py ${f}; done && date

cat *v2.a*gff3 > Kappaphycus_alvarezii_proteins_annot_seqs_v2.all.formatted.gff3
cat *v2.a*csv > Kappaphycus_alvarezii_proteins_annot_seqs_v2.all.all-db-names.csv

wc -l Kappaphycus_alvarezii_proteins_annot_seqs_v2.all.formatted.gff3
wc -l Kappaphycus_alvarezii_proteins_annot_seqs_v2.gtf
```

Then merge all dbs to get unique list (in python):
```python
from pathlib import Path
p = Path('.').glob('*v2.a*csv') 
all_data = []

for csv in p:                                                                                                                                                                         
    with open(csv, 'r') as in_file:                                                                                                                                                   
        all = in_file.read()                                                                                                                                                      
        all_data.append(all)

all_data = ",".join(all_data)

dbs = set()
for db in all_data.split(","):
    dbs.add(db)

with open("Kappaphycus_alvarezii_proteins_annot_seqs_v2.all.all-db-names.csv.unique.csv", "w") as f:
    result = ",".join([d for d in dbs if " " not in d])
    print(result)
    f.write(result)
```

The result of the above is:
```
'ProSiteProfiles_ID,PANTHER_ID,ProSitePatterns_DESCR,CDD_ID,ProSitePatterns_ID,TIGRFAM_ID,PANTHER_DESCR,Pfam_ID,ProSiteProfiles_DESCR,PIRSF_ID,TIGRFAM_DESCR,Gene3D_DESCR,PIRSF_DESCR,SUPERFAMILY_DESCR,SFLD_ID,SUPERFAMILY_ID,CDD_DESCR,SMART_DESCR,Hamap_ID,Hamap_DESCR,PRINTS_DESCR,SMART_ID,PRINTS_ID,Pfam_DESCR,SFLD_DESCR,Gene3D_ID'
```

Now we can add this file as a track:
```
cd /home/ec2-user/jbconnect/node_modules/@gmod/jbrowse/data/gff3
ln -s /data/juans-annotations/nov9th-version/Kappaphycus_alvarezii_proteins_annot_seqs_v2.all.formatted.gff3 .
cd ../..

date && \
./bin/flatfile-to-json.pl \
--gff data/gff3/Ka_anno_v2_alias.gff3 \
--trackLabel "Gene functional annotations v2" \
--key "Gene functional annotations v2" \
--out data/Kappaphycus_alvarezii \
--nameAttributes "ID,Name,ProSiteProfiles_ID,PANTHER_ID,ProSitePatterns_DESCR,CDD_ID,ProSitePatterns_ID,TIGRFAM_ID,PANTHER_DESCR,Pfam_ID,ProSiteProfiles_DESCR,PIRSF_ID,TIGRFAM_DESCR,Gene3D_DESCR,PIRSF_DESCR,SUPERFAMILY_DESCR,SFLD_ID,SUPERFAMILY_ID,CDD_DESCR,SMART_DESCR,Hamap_ID,Hamap_DESCR,PRINTS_DESCR,SMART_ID,PRINTS_ID,Pfam_DESCR,SFLD_DESCR,Gene3D_ID" \
--sortMem 109715200 --maxLookback 100 \
&& date
```

The above crashed!!!

So I tried to rename the file and rerun using the folloowing cmd:
```
date && \
> ./bin/flatfile-to-json.pl \
> --gff data/gff3/Ka_anno_v2_alias.gff3 \
> --trackLabel "Gene functional annotations v2" \
> --key "Gene functional annotations v2" \
> --out data/Kappaphycus_alvarezii \
> --nameAttributes "ID,Name,ProSiteProfiles_ID,PANTHER_ID,ProSitePatterns_DESCR,CDD_ID,ProSitePatterns_ID,TIGRFAM_ID,PANTHER_DESCR,Pfam_ID,ProSiteProfiles_DESCR,PIRSF_ID,TIGRFAM_DESCR,Gene3D_DESCR,PIRSF_DESCR,SUPERFAMILY_DESCR,SFLD_ID,SUPERFAMILY_ID,CDD_DESCR,SMART_DESCR,Hamap_ID,Hamap_DESCR,PRINTS_DESCR,SMART_ID,PRINTS_ID,Pfam_DESCR,SFLD_DESCR,Gene3D_ID" \
> --sortMem 109715200 --maxLookback 100 \
> ; date && echo "succuss"; date

```

Turns out that we just needed to remove some bad concattenation which found its way into the gff3 file.
We reomved and reloaded this together and now it works.


--------------------------------
## [21 Nov 2021] Try to install elastic search plugin

```
cd jbconnect/node_modules/@gmod/jbrowse/plugins/jbrowse_elasticsearch/
```


```
(base) [ec2-user@ip-172-31-89-223 jbrowse_elasticsearch]$ cat setup.sh 
#!/bin/bash
set -eu -o pipefail

echo "Installing Perl pre-requisites"

# added by davis to run once off and then comentedout:
cpan -i App::cpanminus
#

cpanm -v --notest Bio::Perl@1.7.2 < /dev/null;
cpanm -v --notest Bio::Perl@1.7.2 < /dev/null;
cpanm --notest .

# line removed by Davis:
#cpanm --notest https://github.com/GMOD/jbrowse/archive/master.tar.gz

echo "Installing NodeJS pre-requisites"
npm install

echo "Setting up test dataset"
# note: Davis added all the '../' path suffixes below
../bin/prepare-refseqs.pl --fasta test/data/volvox.fa --out ../el_search_test/volvox
../bin/flatfile-to-json.pl --gff test/data/volvox.gff3 --out ../el_search_test/volvox --type mRNA --trackLabel volvox_transcript --trackType CanvasFeatures --nameAttributes name,alias,id,description,note
../bin/flatfile-to-json.pl --gff test/data/volvox.gff3 --out ../el_search_test/volvox --trackLabel volvox --trackType CanvasFeatures --nameAttributes name,alias,id,description,note
cat test/data/volvox.conf > ../el_search_test/volvox/tracks.conf
cp test/data/*gz* ../el_search_test/volvox

echo "Done"
(base) [ec2-user@ip-172-31-89-223 jbrowse_elasticsearch]$ cpanm Search::Elasticsearch
--> Working on Search::Elasticsearch
Fetching http://www.cpan.org/authors/id/E/EZ/EZIMUEL/Search-Elasticsearch-7.715.tar.gz ... OK
Configuring Search-Elasticsearch-7.715 ... OK
==> Found dependencies: Log::Any::Adapter::Callback, Net::IP, Sub::Exporter, Log::Any::Adapter, HTTP::Tiny, Test::Deep, Test::SharedFork, JSON::MaybeXS, Try::Tiny, Test::Exception, Devel::GlobalDestruction, Moo::Role, Log::Any, Module::Runtime, Test::Pod, Any::URI::Escape, Moo, Package::Stash, namespace::clean
--> Working on Log::Any::Adapter::Callback
Fetching http://www.cpan.org/authors/id/P/PE/PERLANCAR/Log-Any-Adapter-Callback-0.101.tar.gz ... OK
Configuring Log-Any-Adapter-Callback-0.101 ... OK
==> Found dependencies: Log::Any::Adapter
--> Working
```

Run the modified instal script:

```
./setup.sh 
```

Then install elasticsearch 
```
cpanm Search::Elasticsearch
```

---------------------------------------------------------
---------------------------------------------------------
# Random [IGNORE]

        {
         "category" : "Annotations",
         "key" : "Repeat Masker",
         "label" : "Repeat Masker",
         "metadata" : {
            "description" : "Repeat Masker"
         },
         "storeClass" : "JBrowse/Store/SeqFeature/GFF3",
         "trackId" : "Repeat Masker",
         "type" : "CanvasFeatures",
         "urlTemplate" : "repeat_masker/Kappaphycus_alvarezii.fasta.out.gff"
      }


random backup of trackList.json oct 22:
------
{
    "bpSizeLimit": 25000,
    "dataset_id": "Kappaphycus_alvarezii",
    "formatVersion": 1,
    "include": [
        "/track/get_tracklist?dataset=data/Kappaphycus_alvarezii"
    ],
    "names": {
        "type": "Hash",
        "url": "names/"
    },
    "plugins": [
        "HideTrackLabels",
        "NeatCanvasFeatures",
        "NeatHTMLFeatures",
        "JBAnalyze",
        "JBClient",
        "JBCdemo",
        "JBlast",
        "blastx"
    ],
    "tracks": [
        {
            "category": "Reference sequence",
            "chunkSize": 20000,
            "key": "Reference sequence",
            "label": "DNA",
            "seqType": "dna",
            "storeClass": "JBrowse/Store/Sequence/StaticChunked",
            "type": "SequenceTrack",
            "urlTemplate": "seq/{refseq_dirpath}/{refseq}-"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757333",
            "label": "SRR2757333",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360608; Run acn: SRR2757333]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757333.bam"
        },
        {
            "category": "RNAseq alignments / Illumina HiSeq 2000 paired end sequencing",
            "key": "ERR2041141",
            "label": "ERR2041141",
            "metadata": {
                "description": "Illumina HiSeq 2000 paired end sequencing [SRA project acn: ERP023948; Experiment acn: ERX2100198; Run acn: ERR2041141]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/ERR2041141.bam"
        },
        {
            "category": "RNAseq alignments / De novo sequencing and comparative of Kappaphycus alvarezii (Solieriaceae- Rhodophyta) under three different temperatures to discover putative genes associated with photosynthesis",
            "key": "SRR1763039",
            "label": "SRR1763039",
            "metadata": {
                "description": "De novo sequencing and comparative of Kappaphycus alvarezii (Solieriaceae, Rhodophyta) under three different temperatures to discover putative genes associated with photosynthesis [SRA project acn: SRP052519; Experiment acn: SRX845433; Run acn: SRR1763039]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR1763039.bam"
        },
        {
            "category": "RNAseq alignments / Transcriptome sequencing and characterization for Kappaphycus alvarezii",
            "key": "SRR1207056",
            "label": "SRR1207056",
            "metadata": {
                "description": "Transcriptome sequencing and characterization for Kappaphycus alvarezii (Doty) [SRA project acn: SRP040669; Experiment acn: SRX502687; Run acn: SRR1207056]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR1207056.bam"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757332",
            "label": "SRR2757332",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360503; Run acn: SRR2757332]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757332.bam"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757334",
            "label": "SRR2757334",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360622; Run acn: SRR2757334]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757334.bam"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757335",
            "label": "SRR2757335",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360666; Run acn: SRR2757335]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757335.bam"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757337",
            "label": "SRR2757337",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360673; Run acn: SRR2757337]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757337.bam"
        },
        {
            "category": "RNAseq alignments / Transcriptome of Kappaphycus alvarezii",
            "key": "SRR5357790",
            "label": "SRR5357790",
            "metadata": {
                "description": "Transcriptome of Kappaphycus alvarezii [SRA project acn: SRP102128; Experiment acn: SRX2653631; Run acn: SRR5357790]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR5357790.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466463",
            "label": "SRR6466463",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556421; Run acn: SRR6466463]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466463.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466464",
            "label": "SRR6466464",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556420; Run acn: SRR6466464]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466464.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466465",
            "label": "SRR6466465",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556419; Run acn: SRR6466465]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466465.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466466",
            "label": "SRR6466466",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556418; Run acn: SRR6466466]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466466.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466467",
            "label": "SRR6466467",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556417; Run acn: SRR6466467]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466467.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus Alvarezii-Wild type",
            "key": "SRR7637208",
            "label": "SRR7637208",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus Alvarezii: Wild type [SRA project acn: SRP156108; Experiment acn: SRX4500752; Run acn: SRR7637208]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637208.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus Alvarezii-Wild type",
            "key": "SRR7637235",
            "label": "SRR7637235",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus Alvarezii: Wild type [SRA project acn: SRP156108; Experiment acn: SRX4500779; Run acn: SRR7637235]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637235.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus alvarezii-tissue culture",
            "key": "SRR7637249",
            "label": "SRR7637249",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus alvarezii: tissue culture [SRA project acn: SRP156108; Experiment acn: SRX4500793; Run acn: SRR7637249]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637249.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus alvarezii-Wild type",
            "key": "SRR7637250",
            "label": "SRR7637250",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus alvarezii: Wild type [SRA project acn: SRP156108; Experiment acn: SRX4500794; Run acn: SRR7637250]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637250.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus alvarezii-tissue culture",
            "key": "SRR7637252",
            "label": "SRR7637252",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus alvarezii: tissue culture [SRA project acn: SRP156108; Experiment acn: SRX4500796; Run acn: SRR7637252]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637252.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus alvarezii-tissue culture",
            "key": "SRR7637253",
            "label": "SRR7637253",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus alvarezii: tissue culture [SRA project acn: SRP156108; Experiment acn: SRX4500797; Run acn: SRR7637253]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637253.bam"
        },
        {
            "category": "RNAseq alignments / Marine Maroalga Kappaphycus alvarezii transcriptome under low temperature",
            "key": "SRR1762980",
            "label": "SRR1762980",
            "metadata": {
                "description": "Marine Maroalga Kappaphycus alvarezii transcriptome under low temperature [SRA project acn: SRP052517; Experiment acn: SRX845400; Run acn: SRR1762980]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR1762980.bam"
        },
        {
            "category": "RNAseq alignments / De novo sequencing and comparative of Kappaphycus alvarezii (Solieriaceae- Rhodophyta) under three different temperatures to discover putative genes associated with photosynthesis",
            "key": "SRR1763037",
            "label": "SRR1763037",
            "metadata": {
                "description": "De novo sequencing and comparative of Kappaphycus alvarezii (Solieriaceae, Rhodophyta) under three different temperatures to discover putative genes associated with photosynthesis [SRA project acn: SRP052518; Experiment acn: SRX845422; Run acn: SRR1763037]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR1763037.bam"
        },
        {
            "category": "Pre-computed BLAST tracks",
            "key": "Blastx, 80% identities, min 50bp",
            "label": "Blastx, 80% identities, min 50bp",
            "metadata": {
                "description": "Blastx, 80% identities, min 50bp"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BEDTabix",
            "tbiUrlTemplate": "../bed/sorted_80pc_50bp.bed.gz.tbi",
            "trackId": "Annotation_blastx_80pc_50bp",
            "type": "CanvasFeatures",
            "urlTemplate": "../bed/sorted_80pc_50bp.bed.gz"
        },
        {
            "category": "Pre-computed BLAST tracks",
            "key": "Blastx, 80% identities, min 75% length",
            "label": "Blastx, 80% identities, min 75% length",
            "metadata": {
                "description": "Blastx, 80% identities, min 75% length"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BEDTabix",
            "tbiUrlTemplate": "../bed/sorted_80pc_75pc.bed.gz.tbi",
            "trackId": "Annotation_blastx_80pc_75",
            "type": "CanvasFeatures",
            "urlTemplate": "../bed/sorted_80pc_75pc.bed.gz"
        },
        {
            "category": "Pre-computed BLAST tracks",
            "key": "Blastx, 90% identities, min 50bp",
            "label": "Blastx, 90% identities, min 50bp",
            "metadata": {
                "description": "Blastx, 90% identities, min 50bp"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BEDTabix",
            "tbiUrlTemplate": "../bed/sorted_90pc_50bp.bed.gz.tbi",
            "trackId": "Annotation_blastx_90pc_50bp",
            "type": "CanvasFeatures",
            "urlTemplate": "../bed/sorted_90pc_50bp.bed.gz"
        },
        {
            "category": "Pre-computed BLAST tracks",
            "key": "Blastx, 90% identities, min 75% length",
            "label": "Blastx, 90% identities, min 75% length",
            "metadata": {
                "description": "Blastx, 90% identities, min 75% length"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BEDTabix",
            "tbiUrlTemplate": "../bed/sorted_90pc_75pc.bed.gz.tbi",
            "trackId": "Annotation_blastx_90pc_75pc",
            "type": "CanvasFeatures",
            "urlTemplate": "../bed/sorted_90pc_75pc.bed.gz"
        },
        {
            "category": "Annotations",
            "compress": 0,
            "key": "Gene functional annotations full - all rows (added by script to K. alva subdir of data)",
            "label": "Gene functional annotations full - all rows (added by script to K. alva subdir of data)",
            "storeClass": "JBrowse/Store/SeqFeature/NCList",
            "style": {
                "className": "feature"
            },
            "trackType": null,
            "type": "FeatureTrack",
            "urlTemplate": "tracks/Gene functional annotations full - all rows (added by script to K. alva subdir of data)/{refseq}/trackData.json"
        }
    ]
}

------


nov11 copy paste of ka trans config that i had before closing and opening another one:

{
   "formatVersion" : 1,
   "tracks" : [
      {
         "category" : "Reference sequence",
         "chunkSize" : 20000,
         "key" : "De novo transcriptome assembly",
         "label" : "De novo transcriptome assembly",
         "seqType" : "dna",
         "storeClass" : "JBrowse/Store/Sequence/StaticChunked",
         "type" : "SequenceTrack",
         "urlTemplate" : "seq/{refseq_dirpath}/{refseq}-"
      },
      {
         "category" : "Annotations",
         "compress" : 0,
         "key" : "Annotated genes - transcriptome",
         "label" : "Annotated genes - transcriptome",
         "storeClass" : "JBrowse/Store/SeqFeature/NCList",
         "style" : {
            "className" : "feature"
         },
         "trackType" : null,
         "type" : "FeatureTrack",
         "urlTemplate" : "tracks/Annotated genes - transcriptome/{refseq}/trackData.json"
      },
      {
         "category" : "Annotations",
         "compress" : 0,
         "key" : "Annotated genes - transcriptome",
         "label" : "Annotated genes - transcriptome",
         "storeClass" : "JBrowse/Store/SeqFeature/NCList",
         "style" : {
            "className" : "feature"
         },
         "subParts" : "gene,mRNA,five_prime_UTR,exon,CDS,three_prime_UTR",
         "transcriptType": "mRNA",
         "trackType" : null,
         "type" : "CanvasFeatures",
         "urlTemplate" : "tracks/Annotated genes - transcriptome/{refseq}/trackData.json"
      },
      {
         "compress" : 0,
         "key" : "Blastx UniProt results",
         "label" : "Blastx UniProt results",
         "storeClass" : "JBrowse/Store/SeqFeature/NCList",
         "style" : {
            "className" : "feature"
         },
         "trackType" : null,
         "type" : "FeatureTrack",
         "urlTemplate" : "tracks/Blastx UniProt results/{refseq}/trackData.json"
      },
      {
         "compress" : 0,
         "key" : "Pfam domain results",
         "label" : "Pfam domain results",
         "storeClass" : "JBrowse/Store/SeqFeature/NCList",
         "style" : {
            "className" : "feature"
         },
         "trackType" : null,
         "type" : "FeatureTrack",
         "urlTemplate" : "tracks/Pfam domain results/{refseq}/trackData.json"
      }
   ]
}


nov11 copy paste of ka genome config that i had before closing and opening another one:
{
    "bpSizeLimit": 20000,
    "dataset_id": "Kappaphycus_alvarezii",
    "formatVersion": 1,
    "include": [
        "/track/get_tracklist?dataset=data/Kappaphycus_alvarezii"
    ],
    "names": {
        "type": "Hash",
        "url": "names/"
    },
    "plugins": [
        "HideTrackLabels",
        "NeatCanvasFeatures",
        "NeatHTMLFeatures",
        "JBAnalyze",
        "JBClient",
        "JBCdemo",
        "JBlast",
        "blastx"
    ],
    "tracks": [
        {
            "category": "Reference sequence",
            "chunkSize": 20000,
            "key": "Reference sequence",
            "label": "DNA",
            "seqType": "dna",
            "storeClass": "JBrowse/Store/Sequence/StaticChunked",
            "type": "SequenceTrack",
            "urlTemplate": "seq/{refseq_dirpath}/{refseq}-"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757333",
            "label": "SRR2757333",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360608; Run acn: SRR2757333]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757333.bam"
        },
        {
            "category": "RNAseq alignments / Illumina HiSeq 2000 paired end sequencing",
            "key": "ERR2041141",
            "label": "ERR2041141",
            "metadata": {
                "description": "Illumina HiSeq 2000 paired end sequencing [SRA project acn: ERP023948; Experiment acn: ERX2100198; Run acn: ERR2041141]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/ERR2041141.bam"
        },
        {
            "category": "RNAseq alignments / De novo sequencing and comparative of Kappaphycus alvarezii (Solieriaceae- Rhodophyta) under three different temperatures to discover putative genes associated with photosynthesis",
            "key": "SRR1763039",
            "label": "SRR1763039",
            "metadata": {
                "description": "De novo sequencing and comparative of Kappaphycus alvarezii (Solieriaceae, Rhodophyta) under three different temperatures to discover putative genes associated with photosynthesis [SRA project acn: SRP052519; Experiment acn: SRX845433; Run acn: SRR1763039]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR1763039.bam"
        },
        {
            "category": "RNAseq alignments / Transcriptome sequencing and characterization for Kappaphycus alvarezii",
            "key": "SRR1207056",
            "label": "SRR1207056",
            "metadata": {
                "description": "Transcriptome sequencing and characterization for Kappaphycus alvarezii (Doty) [SRA project acn: SRP040669; Experiment acn: SRX502687; Run acn: SRR1207056]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR1207056.bam"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757332",
            "label": "SRR2757332",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360503; Run acn: SRR2757332]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757332.bam"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757334",
            "label": "SRR2757334",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360622; Run acn: SRR2757334]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757334.bam"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757335",
            "label": "SRR2757335",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360666; Run acn: SRR2757335]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757335.bam"
        },
        {
            "category": "RNAseq alignments / TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS",
            "key": "SRR2757337",
            "label": "SRR2757337",
            "metadata": {
                "description": "TRANSCRIPTOMIC AND CARRAGEENAN ANALYSES OF MICROPROPAGATED KAPPAPHYCUS AND EUCHEUMA SEAWEEDS UNDER DIFFERENT LIGHT REGIMES AND CARBON DIOXIDE CONCENTRATIONS [SRA project acn: SRP065060; Experiment acn: SRX1360673; Run acn: SRR2757337]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR2757337.bam"
        },
        {
            "category": "RNAseq alignments / Transcriptome of Kappaphycus alvarezii",
            "key": "SRR5357790",
            "label": "SRR5357790",
            "metadata": {
                "description": "Transcriptome of Kappaphycus alvarezii [SRA project acn: SRP102128; Experiment acn: SRX2653631; Run acn: SRR5357790]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR5357790.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466463",
            "label": "SRR6466463",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556421; Run acn: SRR6466463]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466463.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466464",
            "label": "SRR6466464",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556420; Run acn: SRR6466464]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466464.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466465",
            "label": "SRR6466465",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556419; Run acn: SRR6466465]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466465.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466466",
            "label": "SRR6466466",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556418; Run acn: SRR6466466]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466466.bam"
        },
        {
            "category": "RNAseq alignments / RNA-seq of Kappaphycus alvarezii",
            "key": "SRR6466467",
            "label": "SRR6466467",
            "metadata": {
                "description": "RNA-seq of Kappaphycus alvarezii [SRA project acn: SRP128943; Experiment acn: SRX3556417; Run acn: SRR6466467]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR6466467.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus Alvarezii-Wild type",
            "key": "SRR7637208",
            "label": "SRR7637208",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus Alvarezii: Wild type [SRA project acn: SRP156108; Experiment acn: SRX4500752; Run acn: SRR7637208]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637208.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus Alvarezii-Wild type",
            "key": "SRR7637235",
            "label": "SRR7637235",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus Alvarezii: Wild type [SRA project acn: SRP156108; Experiment acn: SRX4500779; Run acn: SRR7637235]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637235.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus alvarezii-tissue culture",
            "key": "SRR7637249",
            "label": "SRR7637249",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus alvarezii: tissue culture [SRA project acn: SRP156108; Experiment acn: SRX4500793; Run acn: SRR7637249]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637249.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus alvarezii-Wild type",
            "key": "SRR7637250",
            "label": "SRR7637250",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus alvarezii: Wild type [SRA project acn: SRP156108; Experiment acn: SRX4500794; Run acn: SRR7637250]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637250.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus alvarezii-tissue culture",
            "key": "SRR7637252",
            "label": "SRR7637252",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus alvarezii: tissue culture [SRA project acn: SRP156108; Experiment acn: SRX4500796; Run acn: SRR7637252]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637252.bam"
        },
        {
            "category": "RNAseq alignments / RNA-Seq of Kappaphycus alvarezii-tissue culture",
            "key": "SRR7637253",
            "label": "SRR7637253",
            "metadata": {
                "description": "RNA-Seq of Kappaphycus alvarezii: tissue culture [SRA project acn: SRP156108; Experiment acn: SRX4500797; Run acn: SRR7637253]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR7637253.bam"
        },
        {
            "category": "RNAseq alignments / Marine Maroalga Kappaphycus alvarezii transcriptome under low temperature",
            "key": "SRR1762980",
            "label": "SRR1762980",
            "metadata": {
                "description": "Marine Maroalga Kappaphycus alvarezii transcriptome under low temperature [SRA project acn: SRP052517; Experiment acn: SRX845400; Run acn: SRR1762980]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR1762980.bam"
        },
        {
            "category": "RNAseq alignments / De novo sequencing and comparative of Kappaphycus alvarezii (Solieriaceae- Rhodophyta) under three different temperatures to discover putative genes associated with photosynthesis",
            "key": "SRR1763037",
            "label": "SRR1763037",
            "metadata": {
                "description": "De novo sequencing and comparative of Kappaphycus alvarezii (Solieriaceae, Rhodophyta) under three different temperatures to discover putative genes associated with photosynthesis [SRA project acn: SRP052518; Experiment acn: SRX845422; Run acn: SRR1763037]"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BAM",
            "type": "JBrowse/View/Track/Alignments2",
            "urlTemplate": "../bam/SRR1763037.bam"
        },
        {
            "category": "Pre-computed BLAST tracks",
            "key": "Blastx, 80% identities, min 50bp",
            "label": "Blastx, 80% identities, min 50bp",
            "metadata": {
                "description": "Blastx, 80% identities, min 50bp"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BEDTabix",
            "tbiUrlTemplate": "../bed/sorted_80pc_50bp.bed.gz.tbi",
            "trackId": "Annotation_blastx_80pc_50bp",
            "type": "CanvasFeatures",
            "urlTemplate": "../bed/sorted_80pc_50bp.bed.gz"
        },
        {
            "category": "Pre-computed BLAST tracks",
            "key": "Blastx, 80% identities, min 75% length",
            "label": "Blastx, 80% identities, min 75% length",
            "metadata": {
                "description": "Blastx, 80% identities, min 75% length"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BEDTabix",
            "tbiUrlTemplate": "../bed/sorted_80pc_75pc.bed.gz.tbi",
            "trackId": "Annotation_blastx_80pc_75",
            "type": "CanvasFeatures",
            "urlTemplate": "../bed/sorted_80pc_75pc.bed.gz"
        },
        {
            "category": "Pre-computed BLAST tracks",
            "key": "Blastx, 90% identities, min 50bp",
            "label": "Blastx, 90% identities, min 50bp",
            "metadata": {
                "description": "Blastx, 90% identities, min 50bp"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BEDTabix",
            "tbiUrlTemplate": "../bed/sorted_90pc_50bp.bed.gz.tbi",
            "trackId": "Annotation_blastx_90pc_50bp",
            "type": "CanvasFeatures",
            "urlTemplate": "../bed/sorted_90pc_50bp.bed.gz"
        },
        {
            "category": "Pre-computed BLAST tracks",
            "key": "Blastx, 90% identities, min 75% length",
            "label": "Blastx, 90% identities, min 75% length",
            "metadata": {
                "description": "Blastx, 90% identities, min 75% length"
            },
            "storeClass": "JBrowse/Store/SeqFeature/BEDTabix",
            "tbiUrlTemplate": "../bed/sorted_90pc_75pc.bed.gz.tbi",
            "trackId": "Annotation_blastx_90pc_75pc",
            "type": "CanvasFeatures",
            "urlTemplate": "../bed/sorted_90pc_75pc.bed.gz"
        },
        {
            "category": "Annotations",
            "compress": 0,
            "key": "Gene functional annotations",
            "label": "Gene functional annotations",
            "storeClass": "JBrowse/Store/SeqFeature/NCList",
            "style": {
                "className": "feature"
            },
            "trackType": null,
            "type": "FeatureTrack",
            "urlTemplate": "tracks/Gene functional annotations full - all rows (added by script to K. alva subdir of data)/{refseq}/trackData.json"
        },
        {
            "category": "Annotations",
            "compress": 0,
            "key": "Repeat Masker",
            "label": "Repeat Masker",
            "storeClass": "JBrowse/Store/SeqFeature/NCList",
            "style": {
                "className": "feature"
            },
            "trackType": null,
            "type": "FeatureTrack",
            "urlTemplate": "tracks/Repeat Masker/{refseq}/trackData.json"
        }
    ]
}

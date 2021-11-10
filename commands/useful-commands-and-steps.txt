# Steps to start jbconect server
The steps werent recorded here but a few rough documents I made outline the installation steps ("working-cmds-.....txt")
But some other useful things to note for future:

- the jbconnect/sails server is being run from the (base) conda env!
- it is being run in a tmux session called "serve"


------------------------------------------------------------------------------------------
# Steps taken to download and install pathway tools (rough copy paste of most of the cmds)
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

chmod u+x pathway-tools-25.0-linux-64-tier1-install

To allow x11 forwarding:
sudo yum install xorg-x11-xauth

sudo yum install gnome-terminal

tmux a -t ptools

 mkdir pathway-tools
 mkdir data

./pathway-tools-25.0-linux-64-tier1-install

 Review settings before copying files

Install Directory:
      /large-store/p-tools/pathway-tools

      Pathway Tools Configuration and Data Directory:
      /large-store/p-tools/data/ptools-local


then run the software (doesnt work, throws errors):
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

Then I did this (not sure if its right but it seems to get me further):

sudo yum install libXpm
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools

which gave the following errors:
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

exit
ssh back in (to rather try from the std conda base env like before, now that we have libxm installed)
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools
ok so still same errors as before, which means we need to do the conda deactivate afterall:
*******
An unhandled error occurred during initialization:
Error #<FILE-ERROR @ #x1007428ca52> occurred loading OpenSSL
libraries.  Is OpenSSL installed in a standard place, or is
LD_LIBRARY_PATH set?.
Loading libcrypto.so failed with error:
libcrypto.so: cannot open shared object file: No such file or directory.

****

NB: read issue 1 of https://bioinformatics.ai.sri.com/ptools/faq.html for some tips for future

conda deactivate
then create a config file since one doesnt exist yet:
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools -config

less /large-store/p-tools/data/ptools-local/ptools-init.dat
nano /large-store/p-tools/data/ptools-local/ptools-init.dat

^ edit the above file to have the following:
WWW-Server-SSL-Certificate NIL
WWW-Server-Hostname localhost
WWW-Server-Port 1555

tmux a -t ptools
conda deactivate

now, it is essential to proceed using the *xQuartz terminal* (if on mac)!
Using that terminal (not a normal/pychar,m terminal), ssh in with the -Y flag
and rejoin the tmux session and then run:
./pathway-tools/aic-export/pathway-tools/ptools/25.0/pathway-tools -www -www-server-hostname 0.0.0.0
(when asked for x forwarding display to use, type in localhost:10.0 and hit enter a few times)
then wait at least a minute and a wiondow shold display ion your mac!

Then open up port :1555 in AWS console so that we can acces the webs erver

seems to not quite work


------------------------------------------------------------------------------------------
# Steps taken to download and prepare chondrus crispus protein blast db for blastx search:

Link to uniprot ftp server with all organisms ref sequen ces (AA sequneces):
https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/

Link to Chondrus chrispus specifically (use the top level readme to map organism to folder):
https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000012073/

Download the fasta AA sequence file:
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000012073/UP000012073_2769.fasta.gz

Use the blast binaries in this location:
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/

To construct the blast db as follows:
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb -in UP000012073_2769.fasta -parse_seqids -blastdb_version 5 -title "chondrus_crispus_prot" -out output/chondrus_crispus_prot -taxid 2769 -dbtype prot

Note, to perform taxid lookups aytomatically as part of the blast search is a two step process...
This file needs to be downloaded in the same dir as your blast db:
ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz

in other words do this:
wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz
tar -xzf taxdb.tar.gz

And then see this VERY useful guide (the best one I've seen) for the second step
(generating the taxid map file used as part of makeblastdb):
http://www.verdantforce.com/2014/12/building-blast-databases-with-taxonomy.html

Also see this post:
https://www.biostars.org/p/76551/

Tip: the outformat flag might need to be used in a specific way when running blast.
As an *example*:
-outfmt "6 qseqid sseqid evalue pident stitle staxids sscinames scomnames sblastnames sskingdoms salltitles stitle" \

--------

Creating the phycocosm aa blastx db:

use the script in:
/data/davis--blast-dbs/get_jgi_genomes-release

to do the following:
cd /databases/blast/
sudo mkdir phycocosm-proteins
sudo chmod a+rw phycocosm-proteins/

sign in and then download all phycocosm protein sequences:
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -u davistodt@gmail.com -p {w3...}
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -a -l
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes   -c signon.cookie -a

download all phycocosm/mycocosm taxon ids (this link was acquired via email query to JGI on oct 18th):
wget https://mycocosm.jgi.doe.gov/ext-api/mycocosm/catalog/download-group?flt=&seq=all&pub=all&grp=all&srt=released&ord=desc
mv download-group\?flt\= all_org_names_and_taxa.csv
NB: note that the above file might throw encoding errors in the subsequent step so you might need to manually select all, copy and
paste from the web link into the file.

Create a single fasta file from all sep fasta files
cd pep
for f in `ls`; do gunzip $f; done
cat * > ../concatted-phycocosm-proteins.fasta
cd ../

prepare them as a blastdb with tax ids and appropriately formatted fa headers with seq id and taxa (this is possible attempt one of many because of the fasta headers)
python make_tax_id_map.py
python format_fa_headers_for_blast.py
mkdir output

Build the blastdb
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb -in concatted-phycocosm-proteins.fasta -parse_seqids -blastdb_version 5 -title "jgi-phycocosm-prot" -out output/jgi-phycocosm-prot -taxid_map tax_map.txt -dbtype prot

ok so actually, after much experimentation I decided to not run the above makeblastdb command.
There were too many cryptic errors no matter how I tried to format the fasta headers and/or the tax_map.txt file to
accommodate these.
Instead, I ran the following command (i.e. I didnt tell blast to expect ncbi std formatted headers - the advice I've come across most often
 is to omit this if the files arent already in the ncbi format because its a headache).

 /data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb -in ../concatted-phycocosm-proteins.fasta -blastdb_version 5 -title "jgi-phycocosm-prot" -out jgi-phycocosm-prot -dbtype prot -max_file_sz '4GB'

The workflow script just needs to be formatted to parse out the extra info from the result/subject ids now.

To test the blast output format generated:
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/blastx \
-db /home/ec2-user/jbconnect/blastdb/phycocosm-prot/jgi-phycocosm-prot \
-query /home/ec2-user/jbconnect/blastdb/tmp/ \
76-jgi-phycocsm-original-blastx-job-blastx-query-seq.fasta \
-outfmt '7 qaccver sseqid saccver qstart qend sstart send sseq evalue bitscore length pident nident mismatch gapopen staxid ssciname scomname stitle' -out /home/ec2-user/jbconnect/blastdb/tmp/test-jgi-phycocsm-blastx-job-blastx-results.tsv


-----------

Mycocosm steps:

cd /databases/blast/
mkdir mycocosm-proteins
sudo chmod a+rw mycocosm-proteins/
cd mycocosm-proteins

sign in and then download all phycocosm protein sequences:
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -u davistodt@gmail.com -p {w3...}
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -f -l
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -f

download all phycocosm/mycocosm taxon ids (this link was acquired via email query to JGI on oct 18th):
wget https://mycocosm.jgi.doe.gov/ext-api/mycocosm/catalog/download-group?flt=&seq=all&pub=all&grp=all&srt=released&ord=desc
mv download-group\?flt\= all_org_names_and_taxa.csv
NB: note that the above file might throw encoding errors in the subsequent step so you might need to manually select all, copy and
paste from the web link into the file.

install gnu parallel (easy):
http://git.savannah.gnu.org/cgit/parallel.git/tree/README

Create a single fasta file from all sep fasta files and format their headers at the same time
cd pep
for f in `ls`; do gunzip $f; done
cd ../
python format-and-build-fa.py
OOOOORRRRR.... run the same script in parallel much faster (preferred choice in theory but it seems to be way too slow so maybe stick with normal execution if this at first seems slow (dont increase -j here rhough!)):
for f in `ls pep/*.aa.fasta`; do echo "python format-and-build-fa.py ${f}"; done | parallel -j 6 -k

then concat all these temp files into a single fasta:
cat tmp_files/*.aa.fasta.tmp > concatted-mycocosm.formatted.fasta

Build the blastdb
mkdir output
cd output
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb \
-in ../concatted-mycocosm.formatted.fasta -blastdb_version 5 \
-title "jgi-mycocosm-prot" -out jgi-mycocosm-prot \
-dbtype prot -max_file_sz '4GB'

The workflow script just needs to be formatted to parse out the extra info from the result/subject ids now.

a workflow script was created in the usual place (jbconnect/node_modules/blastx-../workflows/...py and softlinked into jbconnect/workflows
and the above blast db was softlinked into the uisual place: jbconnect/blastdb/

Tested successfully in app.
Complete.


-----------

JGI Phytozome steps:
cd /databases/blast
sudo mkdir phytozome12-proteins
sudo chmod a+rw phytozome12-proteins/
cd phytozome12-proteins

/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -u davistodt@gmail.com -p {w3...}
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -P 12 -l
/data/davis--blast-dbs/get_jgi_genomes-release/bin/get_jgi_genomes -c signon.cookie -P 12


download all phycocosm/mycocosm taxon ids (this was acquired via new email query to JGI answered on oct 20th by David Goodstein):
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

then add the relevant workflow scripts to the blastx plugin dir and
symlink into jbconnect workflows, like followed in one of the above process.

-----
Build EBI bacterial blastx db steps:

cd /databases/blast
sudo mkdir ebi-bacterial
sudo chmod a+rw ebi-bacterial/
cd ebi-bacterial/

Download table with ALL bacterial assemblies from EBI (this command was built using the webportal available at: https://www.ebi.ac.uk/ena/browser/)
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'result=assembly&query=tax_tree(2)&fields=accession%2Cassembly_title%2Cstudy_description%2Cscientific_name%2Ctax_id&limit=0&format=tsv' "https://www.ebi.ac.uk/ena/portal/api/search" > all_bacterial_accessions_taxon_2.tsv
Nevermind, scratch that. The EBI bacterial data portal does not have protein sequences.
Instead, we used ensembl bacterial portal and went to the download section, i.e: https://bacteria.ensembl.org/info/data/ftp/index.html

So:
cd ../
sudo mkdir ensembl-bacteria
sudo chmod a+rw ensembl-bacteria/
cd ensembl-bacteria
rsync --list-only -av --include='**/pep/*' rsync://ftp.ensemblgenomes.org/all/pub/bacteria/current/fasta/ . | grep "/pep/" | sed "s|^.* bacteria_|bacteria_|g" > file_list_to_dl.txt

which gives this example output (sample only):
head -n 3 file_list_to_dl.txt
bacteria_0_collection/acinetobacter_baumannii_aye_gca_000069245/pep/Acinetobacter_baumannii_aye_gca_000069245.ASM6924v1.pep.all.fa.gz
bacteria_0_collection/acinetobacter_baumannii_aye_gca_000069245/pep/CHECKSUMS
bacteria_0_collection/acinetobacter_baumannii_aye_gca_000069245/pep/README

Then use this file in the rsync cmd (I tried various combinations of --include-pattern and --exclude-pattern to no avail btw):
rsync -avrP --files-from=file_list_to_dl.txt rsync://ftp.ensemblgenomes.org/all/pub/bacteria/current/fasta/ .
note that you might need to run with the flag if rsync crashes with a weird error (its due to high mem/cpu usage on the machine even though it doesnt sound like it):
--bwlimit=6000
mkdir downloaded
mv * downloaded
mv downloaded/file_list_to_dl.txt .

format fasta headers (and bring in info from the file name into the header)
(no need to unzip fasta files)
python format-fa-headers.py

build blastdb:
mkdir blastdb_output
(the following is needed because a simple ls or cat will fail with so many files found:)
find output/ -name '*.tmp' -print0 | xargs -0 cat > concatted-ensemble-bacteria.formatted.fasta
(note that the above file is massive: about 76GB; so we will delete it when done)
cd blastdb_output
/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb \
-in /databases/blast/ensembl-bacteria/concatted-ensemble-bacteria.formatted.fasta -blastdb_version 5 \
-title "ens-bacteria-prot" -out ens-bacteria-prot \
-dbtype prot

rm concatted-ensemble-bacteria.formatted.fasta
touch concatted-ensemble-bacteria.formatted.fasta.was.removed.due.to.size--regenerate-it-with-cat

NB!! there is a chance the whole db was not moved over as the connection broke
(instead of the abopve cmd,
I actually built the db in /blastdb, deleted the concatted fasta file, and moved it back to
the working dir of /databases/blast/ens....
Now since I deleted the concatted fasta (which took long to build), it would be difficult to
rebuild (since I am pretty sure that the whole dir was indeed copied) - its low risk but
bear in mind in case any weird results later on. Also, it **did** run the above touch cmd
automatically (i pasted it and ran it during the execution, so once the first cmd finished then it
would only have run the touch cmd, which it did).

------------------------------------------------------
# Installing sequenceserver

mkdir /blastdb/sequenceserver
cd /blastdb
chmod a+rw sequenceserver
cd sequenceserver
# sudo yum -y install gem  --> ran this first but it crashed so reran the following cmd and it worked:
sudo yum install ruby-devel
gem install sequenceserver

set up directory to store blastdbs for seq server and link in the latest gene/prot prediction seqs:
mkdir /blastdb/sequenceserver/dbs
cd /blastdb/sequenceserver/dbs
ln -s /data/juans-annotations/oct18-version/Kappaphycus_alvarezii_proteins_v2.fasta .
ln -s /data/juans-annotations/oct18-version/Kappaphycus_alvarezii_cdna_v2.fasta .
do the same for the genome assemby:
ln -s /data/moved-from-home-dir/data/kappaphycus_alvarezii_genome/GCA_002205965.3_ASM220596v3_genomic.fasta .


tmux
then rename it to sequenceserver
tmux a -t sequenceserver

then run sequenceserver to set it up for the first time and follow the prompts:
sequenceserver
and supply it with the blast+ binaries and dbs folder, i.e.:
/data/davis--blast-dbs/ncbi-blast-2.12.0+/

to restart the server in future, you just rerun:
sequenceserver



------------------------------------------------------------------------------------------
# I think this was the cmd to add the repeat mnasker track:
./bin/flatfile-to-json.pl --gff data/Kappaphycus_alvarezii/repeat_masker/Kappaphycus_alvarezii.fasta.out.gff3 --trackLabel "Repeat Masker" --key "Repeat Masker" --out data/Kappaphycus_alvarezii --nameAttributes "Target,Repeat_Class,Position_in_repeat_begin,Position_in_repeat_end,Perc_div,Perc_del,Perc_ins"


------------------------------------------------------------------------------------------
# I think this was the cmd used to build the current (soon to be replaced) annotation track
some cmd here to add gff
./bin/generate-names.pl --verbose --out data/Kappaphycus_alvarezii --mem 1200000000 --workdir /blastdb/tmp/ --incremental


------------------------------------------------------------------------------------------
# Rough steps taken to REBUILD non-working phycocosm blastn db (this is an abbreviated version)

install gnu parallel (easy):
http://git.savannah.gnu.org/cgit/parallel.git/tree/README

tmux a -t build-blast-db

The following are completed after phycocosm sequences are already downloaded to the below path, using get_jgi_genomes gutub open source tool
cd /blastdb/phycocosm

for f in `ls assembly/*.fasta`; do echo "python format-and-build-fasta.py ${f}"; done | parallel -j 6 -k

mkdir annotated-assembly-v2/
cat tmp_files/*.tmp > annotated-assembly-v2/concatted-phycocosm.fasta
cd annotated-assembly-v2/
mkdir output
cd output

/data/davis--blast-dbs/ncbi-blast-2.12.0+/bin/makeblastdb -in ../concatted-phycocosm.fasta -blastdb_version 5 -title "jgi-phycocosm" -out jgi-phycocosm -dbtype nucl

The workflow script just needs to be formatted to parse out the extra info from the result/subject ids now.

Then test the run using the following:
/data/jbconnect/blastbin/ncbi-blast-2.8.1+/bin/blastn -db /data/jbconnect/blastdb/jgi-phycocosm/jgi-phycocosm -outfmt 5 -out /data/jbconnect/node_modules/@gmod/jbrowse/d
ata/Kappaphycus_alvarezii/jblastdata/592c1e30-3c70-11ec-9eee-5b7e88f1a1a1.blastxml -query /data/jbconnect/node_modules/@gmod/jbrowse/data/Kappaphycus_alvarezii/jblastdata/blast_region16
35921371543.fa



------------------------------------------------------------------------------------------
# Stesp to copy meiks transcriptome across to ec2 instance:

first mkdirs:
/databases/transcriptome_assembly_meik

then from within the cro server, inside my ftp folder space:
scp -i deleteme.txt -r 01_denovo ec2-user@52.90.88.45:/databases/transcriptome_assembly_meik
scp -i deleteme.txt -r 02_guided ec2-user@52.90.88.45:/databases/transcriptome_assembly_meik

then add as tracks:
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

(--indexed_fasta did not work in borwser!)


------------------------------------------------------------------------------------------
# Stesp to copy meiks transcriptome **annotations** across to ec2 instance and REDO the adding of
# transcriptome reference sequence as a new ref seq to the app + adding all annotation files

first mkdirs:
mkdir -p /large-store/annotations/transcriptome_assembly_meik/03_annotation/
cd /large-store/annotations/transcriptome_assembly_meik/03_annotation/

then from within the cro server:
cd /scratch/projects/c026/algea/transcriptome_Meik/03_annotation
scp -i deleteme.txt -r recommended scp -i /scratch/ftp/user2046/deleteme.txt -r recommended ec2-user@52.90.88.45:/large-store/annotations/transcriptome_assembly_meik/03_annotation

then back to the aws server from now on, move the other transcriptome files to live closer to these (note that this will break softklinks in the app but we dont care
about them because we are going to rather re-add these as an entirely new ref sequnce in the app.
cd ..
mv /databases/transcriptome_assembly_meik/* .

go into previous trans folder and replace broken links with new ones:
cd /home/ec2-user/jbconnect/node_modules/@gmod/jbrowse/data/transcriptome
unlink redalgae-denovo.fasta
unlink redalgae-guided.fasta
ln -s /large-store/annotations/transcriptome_assembly_meik/01_denovo/redalgae-denovo.fasta .
ln -s /large-store/annotations/transcriptome_assembly_meik/02_guided/redalgae-guided.fasta .


NB!!! In case something goes wrong in the app later! I moved some files as follows:
(base) [ec2-user@ip-172-31-89-223 data]$ mv davis--blast-dbs/blastdbs/phycocosm /large-store/blastdbs-moved/phycocosm
(base) [ec2-user@ip-172-31-89-223 data]$ cd davis--blast-dbs/blastdbs/
(base) [ec2-user@ip-172-31-89-223 blastdbs]$ ls
(base) [ec2-user@ip-172-31-89-223 blastdbs]$ ls /large-store/blastdbs-moved/phycocosm/
phycocosm.00.nhr  phycocosm.00.nog  phycocosm.01.nhr  phycocosm.01.nog  phycocosm.02.nhr  phycocosm.02.nog  phycocosm.nal  phycocosm.nos  phycocosm.ntf
phycocosm.00.nin  phycocosm.00.nsq  phycocosm.01.nin  phycocosm.01.nsq  phycocosm.02.nin  phycocosm.02.nsq  phycocosm.ndb  phycocosm.not  phycocosm.nto
(base) [ec2-user@ip-172-31-89-223 blastdbs]$ ln -s /large-store/blastdbs-moved/phycocosm .



Build new ref sequence:
cd - (i.e. into jbrowse root folder)

./bin/prepare-refseqs.pl --fasta \
data/transcriptome/redalgae-denovo.fasta \
--out data/Kappaphycus_alvarezii_transcriptome \
--trackLabel "De novo transcriptome assembly" \
--key "De novo transcriptome assembly"

The above was tested and worked in the browser, now time to format and add annotation tracks:
Firstly, the annotation gff file seems to have UTF-8 encoded URL in the fields which needs to be changed, eg:
TRINITY_DN0_c0_g1_i1    transdecoder    gene    1       906     .       +       .       ID=TRINITY_DN0_c0_g1_i1|g.2833;Name=ORF%20TRINITY_DN0_c0_g1_i1%7Cg.2833%20TRINITY_DN0_c0_g1_i1%7Cm.2833%20type%3A3prime_partial%20len%3A119%20%28%2B%29
TRINITY_DN0_c0_g1_i1    transdecoder    mRNA    1       906     .       +       .       ID=TRINITY_DN0_c0_g1_i1|m.2833;Parent=TRINITY_DN0_c0_g1_i1|g.2833;Name=ORF%20TRINITY_DN0_c0_g1_i1%7Cg.2833%20TRINITY_DN0_c0_g1_i1%7Cm.2833%20type%3A3prime_partial%20len%3A119%20%28%2B%29

so therefore run the script to reformat:
python format-gff3.py

and get a list of params in the gff to use during adding the track:
head -n 3 transcripts.formatted.gff3

output:
TRINITY_DN0_c0_g1_i1    transdecoder    gene    1       906     .       +       .       ID=TRINITY_DN0_c0_g1_i1|g.2833;Name=ORF TRINITY_DN0_c0_g1_i1|g.2833 TRINITY_DN0_c0_g1_i1|m.2833 type:3prime_partial len:119 (+)
TRINITY_DN0_c0_g1_i1    transdecoder    mRNA    1       906     .       +       .       ID=TRINITY_DN0_c0_g1_i1|m.2833;Parent=TRINITY_DN0_c0_g1_i1|g.2833;Name=ORF TRINITY_DN0_c0_g1_i1|g.2833 TRINITY_DN0_c0_g1_i1|m.2833 type:3prime_partial len:119 (+)
TRINITY_DN0_c0_g1_i1    transdecoder    five_prime_UTR  1       550     .       +       .       ID=TRINITY_DN0_c0_g1_i1|m.2833.utr5p1;Parent=TRINITY_DN0_c0_g1_i1|m.2833

Note that the script also adds some essential gff3 tags to the file, for example the header,
and rows with "###" which are essential for the flatfile to json script to run properly.
Otherwise it crashes with the uninformative error "Killed." which is due to memory/file format.


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






---------------------------------------------------------
ranodm;

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


random backup of traclist.json oct 22:
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

# A treemap R script produced by the Revigo server at http://revigo.irb.hr/
# If you found Revigo useful in your work, please cite the following reference:
# Supek F et al. "REVIGO summarizes and visualizes long lists of Gene Ontology
# terms" PLoS ONE 2011. doi:10.1371/journal.pone.0021800

# author: Anton Kratz <anton.kratz@gmail.com>, RIKEN Omics Science Center, Functional Genomics Technology Team, Japan
# created: Fri, Nov 02, 2012  7:25:52 PM
# last change: Fri, Nov 09, 2012  3:20:01 PM

# -----------------------------------------------------------------------------
# If you don't have the treemap package installed, uncomment the following line:
# install.packages( "treemap" );
library(treemap) 								# treemap package by Martijn Tennekes

# Set the working directory if necessary
# setwd("C:/Users/username/workingdir");

# --------------------------------------------------------------------------
# Here is your data from Revigo. Scroll down for plot configuration options.

revigo.names <- c("term_ID","description","frequency","uniqueness","dispensability","representative");
revigo.data <- rbind(c("GO:0003777","microtubule motor activity",0.186774888171784,0.980471032740639,0,"microtubule motor activity"),
c("GO:0009976","tocopherol cyclase activity",0.00233164041800187,0.966660386682601,0,"tocopherol cyclase activity"),
c("GO:0016531","copper chaperone activity",0.00889678179815229,0.993092718813977,0,"copper chaperone activity"),
c("GO:0017056","structural constituent of nuclear pore",0.0657800093543112,0.967327543925251,0,"structural constituent of nuclear pore"),
c("GO:0005458","GDP-mannose transmembrane transporter activity",0.004389169262915,0.95622197093477,0.15930104,"structural constituent of nuclear pore"),
c("GO:0008381","mechanosensitive ion channel activity",0.0357732523348299,0.939102658650786,0.24350338,"structural constituent of nuclear pore"),
c("GO:0015204","urea transmembrane transporter activity",0.0129543098985648,0.954691831524541,0.30742468,"structural constituent of nuclear pore"),
c("GO:0005548","phospholipid transporter activity",0.0355228294162056,0.954369191760674,0.31786895,"structural constituent of nuclear pore"),
c("GO:0015297","antiporter activity",0.443712186773805,0.936135327586757,0.32767776,"structural constituent of nuclear pore"),
c("GO:0015232","heme transmembrane transporter activity",0.0523282377119927,0.936663117540341,0.36149147,"structural constituent of nuclear pore"),
c("GO:0042030","ATPase inhibitor activity",0.0164365421048405,0.982640983503025,0,"ATPase inhibitor activity"),
c("GO:0043856","anti-sigma factor antagonist activity",0.0355769749121244,0.984135562118943,0,"anti-sigma factor antagonist activity"),
c("GO:0009882","blue light photoreceptor activity",0.00935363441996688,0.979756525215589,0.14909646,"anti-sigma factor antagonist activity"),
c("GO:0004602","glutathione peroxidase activity",0.0432859398935588,0.893164932121501,0.22776794,"anti-sigma factor antagonist activity"),
c("GO:2001070","starch binding",0.0232859473385644,0.996676516175374,0,"starch binding"),
c("GO:0016251","RNA polymerase II general transcription initiation factor activity",0.0157495711253712,0.929463370334169,0.00646348,"RNA polymerase II general transcription initiation factor activity"),
c("GO:0047793","cycloeucalenol cycloisomerase activity",0.0010050757679921,0.933172795503301,0.01560939,"cycloeucalenol cycloisomerase activity"),
c("GO:0047918","GDP-mannose 3,5-epimerase activity",0.001404398800393,0.928955314116587,0.31614954,"cycloeucalenol cycloisomerase activity"),
c("GO:0050220","prostaglandin-E synthase activity",0.00302199549096615,0.925511997984975,0.33227694,"cycloeucalenol cycloisomerase activity"),
c("GO:0047727","isobutyryl-CoA mutase activity",0.00537732456343248,0.922663518854642,0.35432035,"cycloeucalenol cycloisomerase activity"),
c("GO:0016853","isomerase activity",2.52668941476875,0.950426047097818,0.02412933,"isomerase activity"),
c("GO:0050194","phosphonoacetaldehyde hydrolase activity",0.00264297701953478,0.929346115563161,0.02434202,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0033916","beta-agarase activity",0.000730964194903345,0.922521537228385,0.11932732,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0050333","thiamin-triphosphatase activity",0.00123857821914178,0.926267386367596,0.12220863,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0004334","fumarylacetoacetase activity",0.0142334972396457,0.920175233412722,0.13759081,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0050126","N-carbamoylputrescine amidase activity",0.00387817114518164,0.906505007353297,0.14036549,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0047389","glycerophosphocholine phosphodiesterase activity",0.00447038750679314,0.899419223908737,0.14142244,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0019784","NEDD8-specific protease activity",0.00670050511994733,0.887040138433096,0.14452156,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0004013","adenosylhomocysteinase activity",0.0300710547958848,0.91891504121167,0.15731025,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0019789","SUMO transferase activity",0.0180541387954136,0.846862998462536,0.22171739,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0018738","S-formylglutathione hydrolase activity",0.013783412804821,0.898378904824111,0.30010104,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0003847","1-alkyl-2-acetylglycerophosphocholine esterase activity",0.0182639525920989,0.895307274195945,0.32424046,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0008803","bis(5'-nucleosyl)-tetraphosphatase (symmetrical) activity",0.00558375426662278,0.92021561458024,0.34289707,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0036374","glutathione hydrolase activity",0.0343383966929826,0.878013341244475,0.34541497,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0008409","5'-3' exonuclease activity",0.0759593625870393,0.852745281782845,0.35928583,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0033925","mannosyl-glycoprotein endo-beta-N-acetylglucosaminidase activity",0.00573265438039938,0.913861188672709,0.37864331,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0017110","nucleoside-diphosphatase activity",0.0107038877244411,0.917283393632838,0.38195129,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0016805","dipeptidase activity",0.0733028491935248,0.871276042483549,0.39979978,"phosphonoacetaldehyde hydrolase activity"),
c("GO:0045550","geranylgeranyl reductase activity",0.00341793442987212,0.917067782376955,0.02479031,"geranylgeranyl reductase activity"),
c("GO:0016166","phytoene dehydrogenase activity",0.0012419623126367,0.910654328734679,0.16558953,"geranylgeranyl reductase activity"),
c("GO:0016719","carotene 7,8-desaturase activity",0.00140778289388792,0.914645510829477,0.16655678,"geranylgeranyl reductase activity"),
c("GO:0010349","L-galactose dehydrogenase activity",0.00194585375958066,0.911187490011236,0.16910809,"geranylgeranyl reductase activity"),
c("GO:0004322","ferroxidase activity",0.0210592138189052,0.908240382707724,0.19058891,"geranylgeranyl reductase activity"),
c("GO:0010308","acireductone dioxygenase (Ni2+-requiring) activity",0.00380710518178826,0.905836245468134,0.19169137,"geranylgeranyl reductase activity"),
c("GO:0001735","prenylcysteine oxidase activity",0.00551945649021924,0.906949007112186,0.19558821,"geranylgeranyl reductase activity"),
c("GO:0003884","D-amino-acid oxidase activity",0.0176480475760229,0.899354712698389,0.20887688,"geranylgeranyl reductase activity"),
c("GO:0003885","D-arabinono-1,4-lactone oxidase activity",0.0183045617140379,0.891161513472313,0.20932379,"geranylgeranyl reductase activity"),
c("GO:0004324","ferredoxin-NADP+ reductase activity",0.0244568436878078,0.907430048402098,0.21293808,"geranylgeranyl reductase activity"),
c("GO:0046429","4-hydroxy-3-methylbut-2-en-1-yl diphosphate synthase activity",0.0258443220207262,0.903660829706736,0.21556823,"geranylgeranyl reductase activity"),
c("GO:0003942","N-acetyl-gamma-glutamyl-phosphate reductase activity",0.0290389062799334,0.900446965391837,0.21782477,"geranylgeranyl reductase activity"),
c("GO:0016851","magnesium chelatase activity",0.00980710294828655,0.91117642692439,0.02681468,"magnesium chelatase activity"),
c("GO:0030729","acetoacetate-CoA ligase activity",0.0130490645164227,0.908449094434439,0.35747579,"magnesium chelatase activity"),
c("GO:0004329","formate-tetrahydrofolate ligase activity",0.0193603988844539,0.89919560911856,0.37137362,"magnesium chelatase activity"),
c("GO:0004819","glutamine-tRNA ligase activity",0.0190558304699108,0.843353694313704,0.37958987,"magnesium chelatase activity"),
c("GO:0030366","molybdopterin synthase activity",0.0155329891416961,0.883982313706186,0.02780526,"molybdopterin synthase activity"),
c("GO:0050487","sulfoacetaldehyde acetyltransferase activity",0.00184433095473298,0.882084173006975,0.1217235,"molybdopterin synthase activity"),
c("GO:0046406","magnesium protoporphyrin IX methyltransferase activity",0.00263620883254494,0.873151839847869,0.12397491,"molybdopterin synthase activity"),
c("GO:0030410","nicotianamine synthase activity",0.00317089560474275,0.883093875125772,0.12517178,"molybdopterin synthase activity"),
c("GO:0003975","UDP-N-acetylglucosamine-dolichyl-phosphate N-acetylglucosaminephosphotransferase activity",0.00566497251050093,0.866601869234127,0.12908775,"molybdopterin synthase activity"),
c("GO:0003956","NAD(P)+-protein-arginine ADP-ribosyltransferase activity",0.00616581834774952,0.869924482423329,0.12968005,"molybdopterin synthase activity"),
c("GO:0008661","1-deoxy-D-xylulose-5-phosphate synthase activity",0.0316040491490849,0.883812045661308,0.14227283,"molybdopterin synthase activity"),
c("GO:0008483","transaminase activity",0.734656240906306,0.851795075954815,0.18456523,"molybdopterin synthase activity"),
c("GO:0046522","S-methyl-5-thioribose kinase activity",0.00338070940142797,0.855944299746738,0.22650779,"molybdopterin synthase activity"),
c("GO:0003877","ATP adenylyltransferase activity",0.00542131777886648,0.857346166635286,0.23196506,"molybdopterin synthase activity"),
c("GO:0050242","pyruvate, phosphate dikinase activity",0.0171133608038251,0.863126070503695,0.24641624,"molybdopterin synthase activity"),
c("GO:0004788","thiamine diphosphokinase activity",0.0185245277912079,0.859258960911497,0.26332445,"molybdopterin synthase activity"),
c("GO:0008772","[isocitrate dehydrogenase (NADP+)] kinase activity",0.00282910216175554,0.831912139293439,0.28100651,"molybdopterin synthase activity"),
c("GO:0004349","glutamate 5-kinase activity",0.0299695319910372,0.837986454588882,0.28523102,"molybdopterin synthase activity"),
c("GO:0043743","LPPG:FO 2-phospho-L-lactate transferase activity",0.0197766423843294,0.854867754900301,0.31003596,"molybdopterin synthase activity"),
c("GO:0009030","thiamine-phosphate kinase activity",0.0203891633069104,0.835883128755364,0.3160869,"molybdopterin synthase activity"),
c("GO:0035299","inositol pentakisphosphate 2-kinase activity",0.00548223146177509,0.852208125613306,0.31820831,"molybdopterin synthase activity"),
c("GO:0047325","inositol tetrakisphosphate 1-kinase activity",0.00561082701458216,0.852024061516313,0.31861111,"molybdopterin synthase activity"),
c("GO:0052726","inositol-1,3,4-trisphosphate 5-kinase activity",0.00561082701458216,0.850027747210552,0.31861111,"molybdopterin synthase activity"),
c("GO:0008974","phosphoribulokinase activity",0.00600338185999322,0.851484588587054,0.31979178,"molybdopterin synthase activity"),
c("GO:0004001","adenosine kinase activity",0.00698815306701578,0.824631090977693,0.32247587,"molybdopterin synthase activity"),
c("GO:0004496","mevalonate kinase activity",0.0104230079643625,0.846932255320782,0.3297609,"molybdopterin synthase activity"),
c("GO:0004379","glycylpeptide N-tetradecanoyltransferase activity",0.00791877877811958,0.873808544617272,0.33121621,"molybdopterin synthase activity"),
c("GO:0009029","tetraacyldisaccharide 4'-kinase activity",0.0142673381745949,0.844215010965182,0.33571664,"molybdopterin synthase activity"),
c("GO:0008478","pyridoxal kinase activity",0.0142774904550797,0.84420874526319,0.33573037,"molybdopterin synthase activity"),
c("GO:0003873","6-phosphofructo-2-kinase activity",0.0154450027108281,0.834238318510192,0.33725538,"molybdopterin synthase activity"),
c("GO:0016756","glutathione gamma-glutamylcysteinyltransferase activity",0.00363113232005227,0.860094335431299,0.34262488,"molybdopterin synthase activity"),
c("GO:0004020","adenylylsulfate kinase activity",0.0271302775487968,0.838341226231398,0.34860484,"molybdopterin synthase activity"),
c("GO:0047151","methylenetetrahydrofolate-tRNA-(uracil-5-)-methyltransferase (FADH2-oxidizing) activity",0.00890016589164721,0.871524404354459,0.34951607,"molybdopterin synthase activity"),
c("GO:0004143","diacylglycerol kinase activity",0.0325312907666938,0.836601034234445,0.35928642,"molybdopterin synthase activity"),
c("GO:0004712","protein serine/threonine/tyrosine kinase activity",0.030548211978669,0.808351391204708,0.36193034,"molybdopterin synthase activity"),
c("GO:0004370","glycerol kinase activity",0.0337326439573914,0.836248959036294,0.36416987,"molybdopterin synthase activity"),
c("GO:0004140","dephospho-CoA kinase activity",0.0344128467498709,0.836054487582444,0.36545213,"molybdopterin synthase activity"),
c("GO:0008531","riboflavin kinase activity",0.0345888196116069,0.836004728488528,0.36602664,"molybdopterin synthase activity"),
c("GO:0004371","glycerone kinase activity",0.0406294265000443,0.834418825230306,0.36987909,"molybdopterin synthase activity"),
c("GO:0004594","pantothenate kinase activity",0.042483909735262,0.833973645600349,0.37476248,"molybdopterin synthase activity"),
c("GO:0047150","betaine-homocysteine S-methyltransferase activity",0.0106328217610477,0.867988529198095,0.37589845,"molybdopterin synthase activity"),
c("GO:0003825","alpha,alpha-trehalose-phosphate synthase (UDP-forming) activity",0.00810151982684541,0.868021183660445,0.37895791,"molybdopterin synthase activity"),
c("GO:0004366","glycerol-3-phosphate O-acyltransferase activity",0.00766158767250544,0.871963637452017,0.38570608,"molybdopterin synthase activity"),
c("GO:0008685","2-C-methyl-D-erythritol 2,4-cyclodiphosphate synthase activity",0.0244060822853839,0.908392191454938,0.0288526,"2-C-methyl-D-erythritol 2,4-cyclodiphosphate synthase activity"),
c("GO:0050080","malonyl-CoA decarboxylase activity",0.00530287450654418,0.907717150949492,0.35298095,"2-C-methyl-D-erythritol 2,4-cyclodiphosphate synthase activity"),
c("GO:0018822","nitrile hydratase activity",0.00819289035120833,0.90602834119715,0.36164268,"2-C-methyl-D-erythritol 2,4-cyclodiphosphate synthase activity"),
c("GO:0004397","histidine ammonia-lyase activity",0.0150355273979424,0.906651838197284,0.37446764,"2-C-methyl-D-erythritol 2,4-cyclodiphosphate synthase activity"),
c("GO:0004462","lactoylglutathione lyase activity",0.0309069258891308,0.907169961343117,0.39092053,"2-C-methyl-D-erythritol 2,4-cyclodiphosphate synthase activity"),
c("GO:0032051","clathrin light chain binding",0.00998984399701239,0.988714041583723,0.03110535,"clathrin light chain binding"),
c("GO:0097602","cullin family protein binding",0.0170490630274215,0.988376331598851,0.33098227,"clathrin light chain binding"),
c("GO:0051879","Hsp90 protein binding",0.0203113291565272,0.98826167522126,0.34465443,"clathrin light chain binding"),
c("GO:0048487","beta-tubulin binding",0.018389164051411,0.986606466159594,0.34617924,"clathrin light chain binding"),
c("GO:0019905","syntaxin binding",0.0253333239029928,0.988114040830285,0.3527874,"clathrin light chain binding"),
c("GO:0051087","chaperone binding",0.1035803336926,0.987090992017694,0.39071623,"clathrin light chain binding"),
c("GO:0008139","nuclear localization sequence binding",0.0110422970739334,0.992832548009201,0.03128363,"nuclear localization sequence binding"),
c("GO:0005545","1-phosphatidylinositol binding",0.0170761357753809,0.99455621411285,0.03208397,"1-phosphatidylinositol binding"),
c("GO:0043023","ribosomal large subunit binding",0.0687174025079043,0.994297098979391,0.03493873,"ribosomal large subunit binding"),
c("GO:0008061","chitin binding",0.114879821872148,0.994152055234871,0.0389071,"chitin binding"),
c("GO:0035438","cyclic-di-GMP binding",0.0483959210708923,0.991815342121047,0.20829737,"chitin binding"),
c("GO:0042834","peptidoglycan binding",0.0579627533810394,0.992185843096885,0.21093928,"chitin binding"),
c("GO:0016829","lyase activity",3.59670593692842,0.948899263955041,0.04942248,"lyase activity"),
c("GO:0020037","heme binding",1.45224988241121,0.991329424198848,0.04969697,"heme binding"),
c("GO:0017070","U6 snRNA binding",0.0119966114395017,0.990870011433054,0.08639577,"U6 snRNA binding"),
c("GO:0032422","purine-rich negative regulatory element binding",0.00673773014839148,0.990601305317709,0.1426164,"U6 snRNA binding"),
c("GO:0042134","rRNA primary transcript binding",0.0126768142319812,0.990841417870534,0.30188262,"U6 snRNA binding"),
c("GO:0003747","translation release factor activity",0.117421276086835,0.899354577051336,0.34568823,"U6 snRNA binding"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="revigo_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "uniqueness",
  type = "categorical",
  vColor = "representative",
  title = "Revigo TreeMap",
  inflate.labels = FALSE,      # set this to TRUE for space-filling group labels - good for posters
  lowerbound.cex.labels = 0,   # try to draw as many labels as possible (still, some small squares may not get a label)
  bg.labels = "#CCCCCCAA",   # define background color of group labels
								 # "#CCCCCC00" is fully transparent, "#CCCCCCAA" is semi-transparent grey, NA is opaque
  position.legend = "none"
)

dev.off()


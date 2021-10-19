# A plotting R script produced by the Revigo server at http://revigo.irb.hr/
# If you found Revigo useful in your work, please cite the following reference:
# Supek F et al. "REVIGO summarizes and visualizes long lists of Gene Ontology
# terms" PLoS ONE 2011. doi:10.1371/journal.pone.0021800

# --------------------------------------------------------------------------
# If you don't have the ggplot2 package installed, uncomment the following line:
# install.packages( "ggplot2" );
library( ggplot2 );

# --------------------------------------------------------------------------
# If you don't have the scales package installed, uncomment the following line:
# install.packages( "scales" );
library( scales );

# --------------------------------------------------------------------------
# Here is your data from Revigo. Scroll down for plot configuration options.

revigo.names <- c("term_ID","description","frequency","plot_X","plot_Y","log_size","uniqueness","dispensability");
revigo.data <- rbind(c("GO:0006355","regulation of transcription, DNA-templated",10.0330757015203,3.63343593629487,3.24057401264512,6.38540588000018,1,0),
c("GO:0043248","proteasome assembly",0.0565085918670257,0.720287387460935,5.88449900257212,4.13611784289648,0.98575338032234,0),
c("GO:0006457","protein folding",0.934345608200157,-4.2947438969286,-7.12669918444942,5.35448108068912,0.981552998471582,0.00855445),
c("GO:0006099","tricarboxylic acid cycle",0.547166746775582,3.31308964696577,-4.26629630355972,5.12209458665147,0.912296043941627,0.01051996),
c("GO:0016192","vesicle-mediated transport",1.40900125690309,-3.53416886371581,6.99387613238112,5.53288426583489,0.980715619961727,0.01163358),
c("GO:0006629","lipid metabolic process",4.3305532868586,-0.139536142071664,-6.1570355004481,6.02051541325903,0.897828371017346,0.08192739),
c("GO:0015074","DNA integration",0.820964918904387,-7.09757877733079,-1.13758827095414,5.29829839672268,0.735442722598561,0.08611279),
c("GO:0044237","cellular metabolic process",51.6198386134444,4.34590366324056,-0.509569946907891,7.09678828926572,0.911204959754897,0.09120721),
c("GO:0006396","RNA processing",3.83107599133337,-6.16779780614135,-0.256437936982967,5.96729284688461,0.648944169829009,0.42215331),
c("GO:0002098","tRNA wobble uridine modification",0.127156723935866,-7.12811795713048,0.674762672712628,4.48832505035772,0.66305279137594,0.46415412),
c("GO:0006388","tRNA splicing, via endonucleolytic cleavage and ligation",0.0341736535464842,-6.50884139314326,1.16387651069593,3.91771551655949,0.64443567920214,0.56285109));

one.data <- data.frame(revigo.data);
names(one.data) <- revigo.names;
one.data <- one.data [(one.data$plot_X != "null" & one.data$plot_Y != "null"), ];
one.data$plot_X <- as.numeric( as.character(one.data$plot_X) );
one.data$plot_Y <- as.numeric( as.character(one.data$plot_Y) );
one.data$log_size <- as.numeric( as.character(one.data$log_size) );
one.data$frequency <- as.numeric( as.character(one.data$frequency) );
one.data$uniqueness <- as.numeric( as.character(one.data$uniqueness) );
one.data$dispensability <- as.numeric( as.character(one.data$dispensability) );
#head(one.data);


# --------------------------------------------------------------------------
# Names of the axes, sizes of the numbers and letters, names of the columns,
# etc. can be changed below

p1 <- ggplot( data = one.data );
p1 <- p1 + geom_point( aes( plot_X, plot_Y, colour = uniqueness, size = log_size), alpha = I(0.6) ) + scale_size_area();
p1 <- p1 + scale_colour_gradientn( colours = c("blue", "green", "yellow", "red"), limits = c( min(one.data$uniqueness), 0) );
p1 <- p1 + geom_point( aes(plot_X, plot_Y, size = log_size), shape = 21, fill = "transparent", colour = I (alpha ("black", 0.6) )) + scale_size_area();
p1 <- p1 + scale_size( range=c(5, 30)) + theme_bw(); # + scale_fill_gradientn(colours = heat_hcl(7), limits = c(-300, 0) );
ex <- one.data [ one.data$dispensability < 0.15, ];
p1 <- p1 + geom_text( data = ex, aes(plot_X, plot_Y, label = description), colour = I(alpha("black", 0.85)), size = 3 );
p1 <- p1 + labs (y = "semantic space x", x = "semantic space y");
p1 <- p1 + theme(legend.key = element_blank()) ;
one.x_range = max(one.data$plot_X) - min(one.data$plot_X);
one.y_range = max(one.data$plot_Y) - min(one.data$plot_Y);
p1 <- p1 + xlim(min(one.data$plot_X)-one.x_range/10,max(one.data$plot_X)+one.x_range/10);
p1 <- p1 + ylim(min(one.data$plot_Y)-one.y_range/10,max(one.data$plot_Y)+one.y_range/10);


# --------------------------------------------------------------------------
# Output the plot to screen

p1;

# Uncomment the line below to also save the plot to a file.
# The file type depends on the extension (default=pdf).

ggsave("revigo-plot.png");


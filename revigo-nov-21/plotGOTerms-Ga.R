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
revigo.data <- rbind(c("GO:0005874","microtubule",0.590923058896654,-4.00372136407618,3.93380303408685,5.07433362293908,0.743307611944267,0),
                     c("GO:0042555","MCM complex",0.0516392267501353,5.29409032883786,-0.438484234906433,4.01582063426207,0.736867388621876,0),
                     c("GO:0005886","plasma membrane",15.5064680247866,-2.59930578712986,-4.79438349762051,6.49331205332051,0.980465972776413,4.124E-05),
                     c("GO:0030173","integral component of Golgi membrane",0.0482779463204013,-0.0820996416106789,6.61844221537962,3.98659260682221,0.720783016873817,0.16417986),
                     c("GO:0031083","BLOC-1 complex",0.0157955281823943,6.03044083325888,2.61728943021364,3.50147007210041,0.638408624494431,0.22740185),
                     c("GO:0030532","small nuclear ribonucleoprotein complex",0.138166054523554,2.1939043417736,2.03060434260059,4.44321603416583,0.571526896999077,0.2622474),
                     c("GO:0008250","oligosaccharyltransferase complex",0.0394539627330108,2.22238070210506,4.52148800747906,3.89894446686651,0.602647357590838,0.39260902));

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

# p1;

# Uncomment the line below to also save the plot to a file.
# The file type depends on the extension (default=pdf).

ggsave("revigo-plot.png");


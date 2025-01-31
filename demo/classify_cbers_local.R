# This is a demonstration of classification of using
# local data (images organised by tiles)
# The input is a CBERS-4 data set covering an area in the Cerrado
# of the state of Bahia (Brazil)
# with two bands (NDVI and EVI)
library(sits)
if (!requireNamespace("sitsdata", quietly = TRUE)) {
    if (!requireNamespace("devtools", quietly = TRUE)) {
        install.packages("devtools")
    }
    devtools::install_github("e-sensing/sitsdata")
}
# load the sitsdata library
library(sitsdata)

# define the local directory to load the images
local_dir <- system.file("extdata/CBERS", package = "sitsdata")

# define the local CBERS data cube
cbers_cube <- sits_cube(
    source     = "LOCAL",
    name       = "cbers_022024",
    satellite  = "CBERS-4",
    sensor     = "AWFI",
    resolution = "64m",
    data_dir   = local_dir,
    parse_info = c("X1", "X2", "X3", "X4", "X5", "date", "X7", "band")
)

# load the samples
data("samples_cerrado_cbers")

# set up the bands
bands <- c("NDVI", "EVI")

# select the ndvi and evi bands
cbers_samples_2bands <- sits_select(
    data  = samples_cerrado_cbers,
    bands = bands
)

# train a random forest model
rfor_model <- sits_train(
    data      = cbers_samples_2bands,
    ml_method = sits_rfor()
)

# classify the data (remember to set the appropriate memory size)
cbers_probs <- sits_classify(
    data       = cbers_cube,
    ml_model   = rfor_model,
    memsize    = 6,
    maxcores   = 2,
    output_dir = tempdir()
)

# smoothen the probabibilities with bayesian estimator
cbers_bayes <- sits_smooth(
    cube       = cbers_probs,
    type       = "bayes",
    output_dir = tempdir())

# label the resulting probs maps
cbers_label <- sits_label_classification(
    cube       = cbers_bayes,
    output_dir = tempdir()
)

# plot the image (first and last instances)
sits_view(cbers_cube, red = "EVI", green = "NDVI", blue = "EVI", time = 1)
sits_view(cbers_cube, red = "EVI", green = "NDVI", blue = "EVI", time = 23)

# plot the probabilities for each class
plot(cbers_probs)

plot(cbers_label)

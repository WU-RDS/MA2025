#-------------------------------------------------------------------#
#---------------------Descriptive statistics------------------------#
#-------------------------------------------------------------------#
# The following code is taken from the fourth chapter of the online script, which provides more detailed explanations:
# https://wu-rds.github.io/MA2025/summarizing-data.html

#-------------------------------------------------------------------#
#---------------------Install missing packages----------------------#
#-------------------------------------------------------------------#

# At the top of each script this code snippet will make sure that all required packages are installed
## ------------------------------------------------------------------------
req_packages <- c("psych","summarytools")
req_packages <- req_packages[!req_packages %in% installed.packages()]
lapply(req_packages, install.packages)
# Useful options setting that prevents R from using scientific notation on numeric values
options(scipen = 999, digits = 2)

#-------------------------------------------------------------------#
#----------------------Categorical variables------------------------#
#-------------------------------------------------------------------#

# Load data
## ------------------------------------------------------------------------
music_data <- read.csv2("https://short.wu.ac.at/ma22_musicdata")
dim(music_data)
head(music_data)
names(music_data)

# Convert variables to correct data type
## ------------------------------------------------------------------------
library(tidyverse)
music_data <- music_data %>% # pipe music data into mutate
  mutate(release_date = as.Date(release_date), # convert to date
         explicit = factor(explicit, levels = 0:1, labels = c("not explicit", "explicit")), # convert to factor w. new labels
         label = as.factor(label), # convert to factor with values as labels
         genre = as.factor(genre),
         top10 = as.logical(top10),
         # Create an ordered factor for the ratings (e.g., for arranging the data)
         expert_rating = factor(expert_rating, 
                                levels = c("poor", "fair", "good", "excellent", "masterpiece"), 
                                ordered = TRUE)
  )

# The table function creates frequency tables
## ------------------------------------------------------------------------
table(music_data$genre) #absolute frequencies 
table(music_data$label) #absolute frequencies
table(music_data$explicit) #absolute frequencies

# The prop.table function produces relative frequency tables
## ------------------------------------------------------------------------
prop.table(table(music_data$genre))  #relative frequencies
prop.table(table(music_data$label))  #relative frequencies
prop.table(table(music_data$explicit))  #relative frequencies

# By adding a second column we can investigate the conditional relative frequencies 
## ------------------------------------------------------------------------
prop.table(table(select(music_data, genre, explicit)),1) #conditional relative frequencies

# Median of rank variable
median_rating <- quantile(music_data$expert_rating, 0.5, type = 1)
median_rating
# Quantile function
quantile(music_data$expert_rating,c(0.25,0.5,0.75), type = 1)
# Quantiles by genre
percentiles <- c(0.25, 0.5, 0.75)
rating_percentiles <- music_data %>%
  group_by(explicit) %>%
  reframe(
    percentile = percentiles,
    value = quantile(expert_rating, percentiles, type = 1)
  )
rating_percentiles

#-------------------------------------------------------------------#
#----------------------Continuous variables-------------------------#
#-------------------------------------------------------------------#

# The psych package contains the useful describe function, which produces more summary statistics than
# the simple summary function contained in base R
## ------------------------------------------------------------------------
library(psych)
psych::describe(select(music_data, streams, danceability, valence))

# describeBy produces the summary statistics grouped by a grouping variable, in our case this is genre
## ------------------------------------------------------------------------
describeBy(select(music_data, streams, danceability, valence), music_data$genre, 
           skew = FALSE, range = FALSE)

# Use the summarytools package for nice formatting
## ------------------------------------------------------------------------
library(summarytools)
view(dfSummary(music_data[, c("streams","valence", "genre", "label", "explicit")], plain.ascii = FALSE, 
                style = "grid", valid.col = FALSE, tmp.img.dir = "tmp"),headings = FALSE, footnote = NA)

#-------------------------------------------------------------------#
#------------------------Creating subsets---------------------------#
#-------------------------------------------------------------------#

# Check for missing values
music_data_valence <- filter(music_data, !is.na(valence))

#-------------------------------------------------------------------#
#---------------------Going beyond the data-------------------------#
#-------------------------------------------------------------------#

# Histogram of tempo variable
hist(music_data$tempo)

# Standardize variable
music_data$tempo_std <- (music_data$tempo - mean(music_data$tempo))/sd(music_data$tempo)
hist(music_data$tempo_std)

# Standardize using the scale() function
music_data$tempo_std <- scale(music_data$tempo)

# Normal distribution function can be used to determine the probability of observations
pnorm(-1.96)
pnorm(-1.96) * 2
min(music_data$tempo_std)
pnorm(min(music_data$tempo_std)) * 2

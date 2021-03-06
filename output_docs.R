require(rmarkdown)
require(dplyr)
require(ggplot2)
require(knitr)

# Define a function to enumerate exercises
exercise_number <- 0
exercise <- function(txt) {
  exercise_number <<- exercise_number + 1
  cat(paste0("\n**Exercise ", exercise_number, ":** "), paste0("*", txt, "*\n"))
}

opts_chunk$set(results="markup")
maxprint <- getOption("max.print")
options(max.print = 30L)

# clean old files
clean_files <- list.files(c(".", "./pdf", "./pdf/fig", "./fig"), pattern = ".\\.html|.\\.pdf|.\\.png", 
                          full.names = TRUE, recursive = FALSE)
clean_files <- setdiff(clean_files, "./_navbar.html")

unlink(clean_files, recursive = TRUE)

# Create data sets
if (!file.exists("data/iris.zip")) {
  set.seed(42)
  dat <- iris
  dat$Sepal.Width[sample(nrow(dat), 5)] <- NA
  setosa <- dat[dat$Species == "setosa",]
  versicolor <- dat[dat$Species == "versicolor",]
  virginica <- dat[dat$Species == "virginica",]
  dir.create("data", showWarnings = FALSE)
  write.csv(dat, "data/iris.csv", row.names=FALSE)
  write.csv(setosa, "data/iris_setosa.csv", row.names=FALSE)
  write.csv(versicolor, "data/iris_versicolor.csv", row.names=FALSE)
  write.csv(virginica, "data/iris_virginica.csv", row.names=FALSE)
  setwd("data")
  zip("iris.zip", c("iris_setosa.csv", "iris_versicolor.csv", "iris_virginica.csv"))
  setwd("..")
}

gapdata <- "data/gapminder-FiveYearData.csv"
if (!file.exists(gapdata)) {
  download.file("https://raw.githubusercontent.com/resbaz/r-novice-gapminder-files/master/data/gapminder-FiveYearData.csv", destfile = gapdata)
}

# Knit Rmd files to html
RmdDocs <- list.files(".", pattern = "\\.Rmd$", full.names = TRUE)
old_RmdDocs <- list.files(".", pattern = "^old_.*\\.Rmd$", full.names = TRUE)
files <- setdiff(RmdDocs, old_RmdDocs)
files <- normalizePath(files, winslash="/")
for (fname in files) {
  render(basename(fname))
}

# knit pdf
exercise_number <- 0
dplyr_tidyr_pngs_to_copy <- list.files("fig/dplyr_tidyr/", "^(05-dplyr|06-tidyr)-.+\\.png$", full.names = TRUE)
dir.create("pdf/fig/dplyr_tidyr/", showWarnings = FALSE)
file.copy(dplyr_tidyr_pngs_to_copy, to = "pdf/fig/dplyr_tidyr")
render("pdf/Intro_R_ATeucher.Rmd")

# Reset options and get rid of stuff
options(max.print = maxprint)
rm(list = ls())

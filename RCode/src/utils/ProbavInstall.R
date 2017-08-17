if (!("probaV" %in% installed.packages()[,"Package"]))
{
  if (!("devtools" %in% installed.packages()[,"Package"]))
  {
    install.packages("devtools")
  }
  library(devtools)
  options(unzip = 'internal') # Needed for devtools on Ubuntu and openSUSE
  if (!("lubridate" %in% installed.packages()[,"Package"]))
  {
    install.packages("lubridate") # Required but not in required packages yet, PR#1
  }
  install_github("JornDallinga/probaV", force=T)
}

library(probaV)
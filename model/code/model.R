## Script to manage the creation of models for
## measuring and predicting HDX's audience.

library(ggplot2)
library(GGally)


# Reading data.
readData <- function(p = NULL) {
  data <- read.csv(p)
  return(data)
}

data <- readData("data/funel.csv")



####
## plotting ##
####
ggpairs(data[,c(6:10,12,14:16)]) +
  theme(text = element_text(size=12))

attach(data)
fit <- lm(Unique.Visitors ~ Number.of.Shares)
summary(fit) ; fit

fit2 <- lm(Unique.Visitors ~ Number.of.New.Users)
summary(fit2) ; fit2

fit3 <- lm(Unique.Visitors ~ Number.of.New.Datasets)
summary(fit3) ; fit3

fit4 <- lm(Unique.Visitors ~ Unique.Shares)
summary(fit4) ; fit4


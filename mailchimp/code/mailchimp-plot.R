#### Plotting #### 

library(ggplot2)
library(lubridate)
library(gridExtra)
# library(forecast)
library(reshape)

members <- read.csv('data/members.csv')

# Standardizing dates.
members$CONFIRM_TIME <- as.Date(members$CONFIRM_TIME)
members.day <- data.frame(table(members$CONFIRM_TIME))  # summary of susbcriptions by day.
colnames(members.day)[1] <- 'members.day'  # renaming the first column for easier manipulation.
members.day$members.day <- as.Date(members.day$members.day)
members.trend$members.day <- as.Date(members.trend$members.day)
members.trend <- subset(members.day, day > as.Date(ymd('2014-03-03')))


# Tolower in email.domains
members$Email.Address <- tolower(members$Email.Address)

# Regex for extracting email domains. 
members$email.domains <- gsub(".*\\@", "\\1", members$Email.Address)


# Subscribers numbers
ggplot(members.day) + theme_bw() + 
  geom_bar(aes(day, Freq), stat = 'identity', fill = "#0988bb", size = 1.5) +
  scale_x_date(limits = c(as.Date(ymd('2014-02-15')), c(as.Date(ymd('2014-03-26'))))) + 
  scale_y_continuous(limits = c(0, 30)) 


# Subsetting for the trend of the days after the launch.
ggplot(members.trend) + theme_bw() + 
  geom_area(aes(as.Date(m.day), Freq), fill = "#0988bb", alpha = 0.3) +
  geom_line(aes(as.Date(m.day), Freq), color = "#0988bb", size = 1.5) +
  stat_smooth(aes(m.day, Freq), se = FALSE, method = 'lm', size = 1.5, color = "#EB5C53") +
  scale_x_date(limits = c(as.Date(ymd('2014-03-03')), c(as.Date(ymd('2014-03-26'))))) 
#   scale_y_continuous(limits = c(0, 30)) +
  



# Subsetting the top 20 domains.
domains <- table(members$email.domains)
domains <- as.data.frame(domains)
sort.domains <- domains[order(- domains$Freq), ]
top.20 <- sort.domains[1:20,]
top.un <- top.20[5:20,]


# Number of domains. 
ggplot(top.20) + theme_bw() + 
  geom_bar(aes(reorder(top.20$Var1, - top.20$Freq), Freq), stat = 'identity', fill = "#0988bb") +
  theme(axis.text.x = element_text(size = 12, angle = 90, hjust = 1))

# Number of UN-related emails
ggplot(top.un) + theme_bw() + 
  geom_bar(aes(reorder(top.un$Var1, - top.un$Freq), Freq), stat = 'identity', fill = "#0988bb") +
  theme(axis.text.x = element_text(size = 12, angle = 90, hjust = 1))


# Visualizing the best performing campaign
open.rate <- read.csv('open-rate.csv')
ggplot(open.rate) + theme_bw() +
  geom_bar(aes(reorder(open.rate$Campaign, - open.rate$Open.Rate), Open.Rate), stat = 'identity', fill = "#0988bb") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))





#### Plotting #### 

library(ggplot2)
library(lubridate)
library(gridExtra)
library(reshape)
library(wesanderson)


# Loading user data.
members <- read.csv('data/members/members.csv')
visits <- read.csv('data/visits/visits.csv', skip = 5)
unsubscribed <- read.csv('data/members/unsubscribed.csv')

# Standardizing dates for members
members$CONFIRM_TIME <- as.Date(members$CONFIRM_TIME)
members.day <- data.frame(table(members$CONFIRM_TIME))  # summary of susbcriptions by day.
colnames(members.day)[1] <- 'sign.up.day'  # renaming the first column for easier manipulation.
members.day$sign.up.day <- as.Date(members.day$sign.up.day)  # standardizing the dats

# Creating the unsubscribe trend. 
unsubscribe.day
unsubscribe.day <- data.frame(table(unsubscribed$UNSUB_TIME))  # summary of susbcriptions by day.
unsubscribe.day$Freq <- unsubscribe.day$Freq * -1
colnames(unsubscribe.day)[1] <- 'day.it.unsubscribed' 

# Standardizing dates for visits
visits$Day.Index <- as.Date(mdy(visits$Day.Index))

# Standardizing the visits count 
visits$Visits <- as.integer(visits$Visits)

# Subsetting to exclude the outlier "add" in MailChimp. 
members.trend <- subset(members.day, members.day$sign.up.day > as.Date('2014-02-24'))
visits.trend <- subset(visits, visits$Day.Index > as.Date('2014-02-24'))


# Calculations 
unsubscribe.day.week <- subset(unsubscribe.day, unsubscribe.day$Freq > as.Date('2014-04-14'))
members.trend.week <- subset(members.trend, members.trend$sign.up.day > as.Date('2014-04-14'))
visits.trend.week <- subset(visits.trend, visits.trend$Day.Index > as.Date('2014-04-14'))

sum(unsubscribe.day.week$Freq)
sum(members.trend.week$Freq)
sum(visits.trend.week$Visits)







# Subscribers numbers
ggplot(members.trend, aes(sign.up.day, Freq)) + theme_bw() + 
  geom_bar(stat = 'identity', fill = "#F1BB7B", size = 1.5) + 
  geom_text(aes(label = Freq), position = position_dodge (width = 0.9), vjust = -0.25 ) +
  labs(title="User registration per day since February.") + 
  xlab("Sign-up Day") + ylab("Number of People per Day") 

# Unsubscribed numbers
ggplot(unsubscribe.day, aes(day.it.unsubscribed, Freq)) + theme_bw() + 
  geom_bar(stat = 'identity', fill = "#5B1A18", size = 1.5) + 
  scale_x_date(limits = c(as.Date(ymd('2014-02-25')), c(as.Date(ymd('2014-04-16'))))) +
#   geom_text(aes(label = Freq), position = position_dodge (width = 0.9), vjust = -0.25 ) +
  labs(title="Unsubscribed users.") + 
  xlab("Unsubscriptio Day") + ylab("Number of People per Day") 


# Visit numbers
ggplot(visits.trend, aes(Day.Index, Visits)) + theme_bw() + 
  geom_bar(stat = 'identity', 
           fill = "#FD6467", size = 1.5) + 
  geom_text(aes(label = Visits), position = position_dodge (width = 0.9), vjust = -0.25 ) + 
  labs(title="Visits to HDX site (hdx.rwlabs.org).") + 
  xlab("Day")



#   scale_x_date(limits = c(as.Date(ymd('2014-02-25')), c(as.Date(ymd('2014-04-16'))))) + 
#   scale_y_continuous(limits = c(0, 30))



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





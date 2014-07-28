#### User Analysis #### 

library(ggplot2)
library(lubridate)
library(gridExtra)
library(reshape)


# Loading user data.
members <- read.csv('data/members/members.csv')

# Tolower in email.domains
members$Email.Address <- tolower(members$Email.Address)

# Regex for extracting email domains. 
members$email.domains <- gsub(".*\\@", "\\1", members$Email.Address)


### Analyzing our members ### 
campaign.1 <- read.csv('opens/members_Introducing_Humanitarian_Data_Exchange_opened_Mar_31_2014.csv')
campaign.2 <- read.csv('opens/members_Blog_Post_Responding_To_Demand_opened_Mar_31_2014.csv')
campaign.3 <- read.csv('opens/members__New_Post_HDX_Repository_User_Research_5_Findings_5_Features_opened_Mar_31_2014.csv')
campaign.4 <- read.csv('opens/members__New_Post_User_Archetypes_Which_One_Describes_You__opened_Mar_31_2014.csv')
campaign.5 <- read.csv('members__New_Post_Standards_Can_Make_Humanitarian_Data_Easier_opened_Apr_16_2014.csv')

# sorting the most frequent users.
sort.campaign.1 <- campaign.1[order(- campaign.1$Opens), ]
camp1.top.5 <- sort.campaign.1[1:5,]

sort.campaign.2 <- campaign.2[order(- campaign.2$Opens), ]
camp2.top.5 <- sort.campaign.2[1:5,]

sort.campaign.3 <- campaign.3[order(- campaign.3$Opens), ]
camp3.top.5 <- sort.campaign.3[1:5,]

sort.campaign.4 <- campaign.4[order(- campaign.4$Opens), ]
camp4.top.5 <- sort.campaign.4[1:5,]

# Getting the most active users. 
## Create a function here for identifying the most active user.

# plotting the most frequent users 
p1 <- ggplot(camp1.top.5) + theme_bw() +
  geom_bar(aes(reorder(camp1.top.5$Email.Address, - camp1.top.5$Opens), Opens), stat = 'identity', fill = "#EB5C53") + 
  scale_y_continuous(limits = c(0, 300)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p2 <- ggplot(camp2.top.5) + theme_bw() +
  geom_bar(aes(reorder(camp2.top.5$Email.Address, - camp2.top.5$Opens), Opens), stat = 'identity', fill = "#EB5C53") + 
  scale_y_continuous(limits = c(0, 300)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p3 <- ggplot(camp3.top.5) + theme_bw() +
  geom_bar(aes(reorder(camp3.top.5$Email.Address, - camp3.top.5$Opens), Opens), stat = 'identity', fill = "#EB5C53") + 
  scale_y_continuous(limits = c(0, 300)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p4 <- ggplot(camp4.top.5) + theme_bw() +
  geom_bar(aes(reorder(camp4.top.5$Email.Address, - camp4.top.5$Opens), Opens), stat = 'identity', fill = "#EB5C53") + 
  scale_y_continuous(limits = c(0, 300)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))



# arraging all the plots in a single page.
grid.arrange(p1, p2, p3, p4, ncol = 2, main = "")





# Identifying the most active users 
# sorting the most frequent users.
active.users <- merge(sort.campaign.1, sort.campaign.2, by = 'Email.Address', all = TRUE)
active.users <- merge(active.users, sort.campaign.3, by = 'Email.Address', all = TRUE)
active.users <- merge(active.users, sort.campaign.4, by = 'Email.Address', all = TRUE)

# summing the rows
active.users$sum <- rowSums(active.users[c("Opens.x", "Opens.y", "Opens")], na.rm = TRUE)

active.users <- active.users[order(- active.users$sum), ]  # arranging 

top.20.active.users <- active.users[1:20, ]  # the top 20


### Plotting the most active users. 
ggplot(top.20.active.users) + theme_bw() + 
  geom_bar(aes(reorder(top.20.active.users$Email.Address, - top.20.active.users$sum), sum), stat = 'identity', fill = "#EB5C53") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
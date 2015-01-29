## Plotting ##
# timeline with the number of followers
ggplot(twitter_friends) + theme_bw() +
  geom_line(aes(date, followers), stat = 'identity', color = "#F2645A", size = 1.3) +
  geom_area(aes(date, followers), stat = 'identity', fill = "#F2645A", alpha = .3) +
  geom_bar(aes(date, new_followers), stat = 'identity', fill = "#1EBFB3")

ggplot(hdxTimeline) + theme_bw() +
  geom_line(aes(created), stat = 'bin', color = "#F2645A", size = 1.3) +
  geom_area(aes(created), stat = 'bin', fill = "#F2645A", alpha = .3)

ggplot(data) + theme_bw() + 
  geom_line(aes(created), stat = 'bin', color = '#0988bb', size = 1.3) + 
  geom_area(aes(created), stat = 'bin', fill = '#0988bb', alpha = .3)
## Twitter credentials ##
require(twitteR)
# download.file(url="http://curl.haxx.se/ca/cacert.pem", 
#               destfile="twitter/auth/cacert.pem")

#to get your consumerKey and consumerSecret see the twitteR documentation for instructions
cred <- OAuthFactory$new(consumerKey='7SfTxcJHRVoLLD4JlhgDg',
                         consumerSecret='SDUu2EUUpoutE0zCnoRagCciZseOwnXu7S0I2ylY5M',
                         requestURL='https://api.twitter.com/oauth/request_token',
                         accessURL='https://api.twitter.com/oauth/access_token',
                         authURL='https://api.twitter.com/oauth/authorize')

cred$handshake(cainfo="twitter/auth/cacert.pem")
# save(cred, file="twitter/auth/twitter authentication.Rdata")

registerTwitterOAuth(cred)

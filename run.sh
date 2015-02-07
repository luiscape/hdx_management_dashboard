#!/bin/bash

CKAN_API_KEY="XXX"
MAILCHIMP_API_KEY="XXX"
# Different scripts that collect the necessary
# data for the making of HDX reports.

##  Twitter
~/R/bin/Rscript ~/tool/twitter/code/get_tweets.R

## Google Analytics
# source venv/bin/activate
# python YYY

## CKAN
~/R/bin/Rscript ~/tool/ckan/code/activity_data.R
~/R/bin/Rscript ~/tool/ckan/code/dataset_data.R $CKAN_API_KEY
~/R/bin/Rscript ~/tool/ckan/code/organization_data.R $CKAN_API_KEY
~/R/bin/Rscript ~/tool/ckan/code/user_data.R $CKAN_API_KEY

## MailChimp
~/R/bin/Rscript ~/tool/mailchimp/code/campaign_data.R $MAILCHIMP_API_KEY
~/R/bin/Rscript ~/tool/mailchimp/code/list_data.R $MAILCHIMP_API_KEY
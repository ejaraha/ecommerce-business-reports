source("C:/Users/Owner/repos/miay/analysis/functions.R")

#set working directory
#---------------------------------------------->>
wd <- "C:/Users/Owner/repos/miay/data"
setwd(wd)

#define year and month
#---------------------------------------------->>
yearmo <- readline(prompt = "Please type the year and month of data to be loaded. ex. 202008 ")

#load data to dataframes
#---------------------------------------------->>
source_medium_log <- read.csv("source_medium_log.csv", stringsAsFactors = FALSE)
print("source_medium_log dataframe created")

wc_orders <- read.csv(paste(yearmo,"/woocommerce_orders_", yearmo,".csv", sep=""), stringsAsFactors = FALSE)
print("wc_orders dataframe created")

wc_tax <- read.csv(paste(yearmo,"/woocommerce_tax_", yearmo,".csv", sep=""), stringsAsFactors = FALSE)
print("wc_tax dataframe created")

wc_registrations <- read.csv(paste(yearmo,"/woocommerce_registrations_", yearmo,".csv", sep=""), stringsAsFactors = FALSE)
print("wc_registrations dataframe created")

wpe_returning_customer <- read.csv(paste(yearmo,"/wpengine_returning_customers_", yearmo,".csv", sep=""), stringsAsFactors = FALSE, header = FALSE, col.names = c("date_created", "returning_customer"))
print("wpe_returning_customer dataframe created")

wpe_coupon_data <- read.csv(paste(yearmo,"/wpengine_coupon_data_", yearmo,".csv", sep=""), stringsAsFactors = FALSE, header = FALSE, col.names = c("order_id", "coupon_code", "date_applied", "discount_amount"), skipNul =  TRUE)
print("wpe_coupon_data dataframe created")

paypal <- read.csv(paste(yearmo,"/paypal_completed_payments_", yearmo,".csv", sep=""), stringsAsFactors = FALSE)
print("paypal dataframe created")

usps <- read.csv(paste(yearmo,"/usps_", yearmo,".csv", sep=""), stringsAsFactors = FALSE)
print("usps dataframe created")

ups <- read.csv(paste(yearmo,"/ups_", yearmo, ".csv", sep=""), stringsAsFactors = FALSE)
print("ups dataframe created")

google_analytics <- read.csv(paste(yearmo,"/google_analytics_exports_", yearmo,".csv", sep=""), stringsAsFactors = FALSE)
print("google_analytics dataframe created")

#clean data
#---------------------------------------------->>
wc_orders <- clean_wc_orders(wc_orders) 
glimpse(wc_orders)

wc_tax <- clean_wc_tax(wc_tax)
glimpse(wc_tax)

wc_registrations <- clean_wc_registrations(wc_registrations)
glimpse(wc_registrations)

wpe_returning_customer <- clean_wpe_returning_customer(wpe_returning_customer)
glimpse(wpe_returning_customer)

wpe_coupon_data <- clean_wpe_coupon_data(wpe_coupon_data)
glimpse(wpe_coupon_data)

paypal <- clean_paypal(paypal)
glimpse(paypal)

usps <- clean_usps(usps)
glimpse(usps)

ups <- clean_ups(ups)
glimpse(ups)

google_analytics <- clean_google_analytics(google_analytics)
glimpse(google_analytics)

#check new source/medium combos
#-------------------------------------------------

#run this and edit clean_google_analytics() based on results (edit search_engine list, mutate redundant source/medium combos ex. m.facebook, l.facebook)
source_medium_diff <- source_medium_check_diff(google_analytics, source_medium_log)


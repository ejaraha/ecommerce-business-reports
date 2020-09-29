library(tidyverse)


clean_wc_orders <- function(wc_orders){
  #(description) cleans the wc_orders data frame
  #(parameters) wc_orders - the data frame with data from woocommerce_orders_YM.csv
  #(returns) the clean wc_orders data frame 
  wc_orders <- wc_orders %>% 
    #change data types
    mutate("order_date" = as.Date(�..Date)) %>%
    #rename variables
    rename("products_purchased" = Number.of.items.sold,
           "orders_placed" = Number.of.orders,
           "coupons" = Coupon.amount) %>%
    #select only necessary variables
    select(order_date, 
           products_purchased, 
           orders_placed, 
           coupons)
  print("wc_orders successfully cleaned")
  return(wc_orders)
}
clean_wc_tax <- function(wc_tax){
  #(description) cleans the wc_tax data frame
  #(parameters) wc_tax - the data frame with data from woocommerce_tax_YM.csv
  #(returns) the clean wc_tax data frame 
  wc_tax <- wc_tax %>% 
    #change date field from "\n\t\t\t\t\t\t\t\tAugust 1, 2020\t\t\t\t\t\t\t" to Y-M-D
    mutate("order_date" =
              lubridate::mdy(
                str_extract(�..Period, "[:alpha:]+ [:digit:]{1,2}, [:digit:]{4}"))) %>%
    #remove "$" and "," then change to double
    mutate_at(c("Total.sales.", "Total.shipping.", "Total.tax."), 
              list(~as.double(str_replace(str_sub(., start = 2), pattern = ",", replace = "")))) %>%
    #rename variables
    rename("sales" = Total.sales.,
           "shipping_charged" = Total.shipping.,
           "tax" = Total.tax.) %>% 
    #select only necessary variables
    select(order_date,
           sales,
           shipping_charged,
           tax)
  print("wc_tax successfully cleaned")
  return(wc_tax[1:nrow(wc_tax)-1,])
}
clean_wc_engine <- function(wc_engine){
  #(description) cleans the wc_engine data frame
  #(parameters) wc_engine - the data frame with data from wp_wc_order_stats_YM.csv
  #(returns) the clean wc_engine data frame
  wc_engine <- wc_engine %>% 
    mutate("order_date" = as.Date(date_created),
           returning_customer = as.integer(returning_customer)) %>%
    select(order_date,
           returning_customer)
  print("wc_engine successfully cleaned")
  return(wc_engine)
}
clean_usps <- function(usps){
  #(description) cleans the usps data frame
  #(parameters) usps - the data frame with data from usps_YM.csv
  #(returns) the clean usps data frame 
  usps <- usps %>%
  filter(Weight != "") %>%
  separate(Weight, c("lb", "oz")) %>%
  mutate("postage_date" = lubridate::mdy(Print.Date),
         #remove "$"
         "shipping_cost" = as.double(str_sub(Cost, start = 2)),
         #extract state from full address
         "state" = toupper(str_extract(Recipient, "(?<=, )[:alpha:]{2}(?= [:digit:]{5})")),
         #remove "=" 
         "tracking_id" = str_sub(Tracking...Insurance.ID, start = 2),
         "status" = Status,
         #combine oz and lb to weight_lbs
         "weight_lb" = round(as.double(str_sub(lb, start = 0, end = -3)) 
                             + 0.0625*as.double(str_sub(oz, start = 0, end = -3))
                             , digits = 1)) %>%
  select(postage_date,
         shipping_cost,
         weight_lb,
         state,
         status,
         tracking_id)
  print("usps successfully cleaned")
  return(usps)
}
clean_paypal <- function(paypal){
  paypal <- paypal %>% 
    mutate("date"=lubridate::mdy(�..Date),
           #remove "-"
           "fee" = replace_na(as.double(str_sub(Fee, start = 2)), 0),
           #remove "WC-" from "WC-19824"
           "invoice_number" = str_replace(Invoice.Number, "WC-", "")) %>%
    #remove commas, cast to double
    mutate_at(c("Gross", "Net"), list(~as.double(str_replace_all(.,pattern=",", replacement = "")))) %>%
    #set to na if ""
    mutate_at(c("Type", "From.Email.Address", "Name","To.Email.Address", "invoice_number"), list(~na_if(., y=""))) %>%
    #rename variables
    rename("name"=Name,
           "email" = From.Email.Address,
           "email_to" = To.Email.Address,
           "type" = Type,
           "gross" = Gross,
           "net" = Net,
           "tax" = Sales.Tax,
           "shipping" = Shipping.and.Handling.Amount) %>%
    #reorder and select
    select(date,
           name,
           email,
           invoice_number,
           gross,
           net,
           fee,
           type) 
  print("paypal successfully cleaned")
  return(paypal)
}
clean_google_analytics <- function(google_analytics){
  #(description) cleans the google_analytics data frame
  #(parameters) google_analytics - the data frame with data from google_analytics_YM.csv
  #(returns) the clean google_analytics data frame 
  search_engine <- c("search.aol.com", "search.nation.com", "results.searchlock.com", "emoji.srchmbl.com", "google.com", "okeano.com", "webcrawler.com", "search.xfinity.com")
  google_analytics <- google_analytics %>% 
    separate(Source...Medium, into = c("source", "medium"), sep = "/") %>%
    mutate("date" = lubridate::ymd(google_analytics$Date),
           #remove "(" and ")"
           source = str_trim(str_replace_all(source, "[()]", "")),
           #remove "(" and ")" & add NA
           medium = na_if(str_trim(str_replace_all(medium, "[()]", "")), "none"),
           #add NA
           "campaign" = na_if(str_trim(Campaign), "(not set)")) %>% 
    #standardize $source & $medium
    mutate(medium = case_when(source %in% search_engine & medium == "referral" ~ "organic",
                              TRUE ~ as.character(medium)), #fix "organic" searches that were misclassified as "referrals"
           source = case_when(source == "m.chinabrands.com" ~ "chinabrands.com",             
                              source %in% c("m.facebook.com", "l.facebook.com") ~ "facebook.com",
                              TRUE ~ as.character(source))) %>%
    #exclude data outside of USA
    filter(Country == "United States") %>%
    rename("users" = Users,
           "new_users" = New.Users,
           "newsletter_sign_up" = Newsletter.sign.up..Goal.1.Completions.,
           "reach_checkout" = Reached.Checkout..Goal.2.Completions.,
           "view_cart" = View.cart..Goal.3.Completions.) %>%
    select(date,
           users,
           new_users,
           source,
           medium,
           campaign,
           newsletter_sign_up,
           reach_checkout,
           view_cart)
  print("google_analytics successfully cleaned")
  return(google_analytics)
}
source_medium_check_diff <- function(google_analytics, source_medium_log){
  #(description) compares source/medium combos in current data to source/medium combos in source_medium_log.csv
  #              returns a dataframe with new source/medium combos from the current data
  #(parameters) google_analytics - the data frame with current data from google_analytics_YM.csv
  #             source_medium_log - the data frame with data from source_medium_log.csv
  #(returns) dataframe with new source/medium combos
  
  #get distinct source/medium combos from google_analytics df
  source_medium_current <- google_analytics %>% 
    distinct(source, medium) %>%
    select(source, medium)
  #compare source/medium combos in google analytics with source/medium combos stores in source_medium_log.csv
  #create a dataframe with only the source/medium combos that are different between the two
  source_medium_diff <- setdiff(source_medium_current, source_medium_log)
  print(sprintf("%i source/medium combos in google_analytics were different from source/medium combos in source_medium_log.csv", nrow(source_medium_diff)))
  return(source_medium_diff)
}
source_medium_update_log <- function(){
  #(description) depending on user input, stops script OR updates source_medium_log.csv with records from source_medium_diff
  #(parameters) none
  #(returns) if yes_no == "yes", updated source_medium_log.csv. if yes_no == "no", returns nothing.
  print(source_medium_diff)
  yes_no <- as.character(readline(prompt = "Should the records in source_medium_diff be added to source_medium_log.csv? Type \"yes\" or \"no\". "))
  #if "yes", combine source_medium_log and source_medium_diff then update source_medium_log.csv with new records
  if(yes_no == "yes"){
    write.csv(union(source_medium_log, source_medium_diff), "C:/Users/Owner/repos/miay/data/source_medium_log.csv", row.names = FALSE)
    print("records from source_medium_diff have been added to source_medium_log.csv")
  }else{
    print("edit clean_google_analytics() accordingly then rerun script")
    stop()
  }
}
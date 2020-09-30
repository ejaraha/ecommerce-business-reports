library(tidyverse)

source("C:/Users/Owner/repos/miay/analysis/clean.R")

#convert order-level data to date-level data
#-------------------------------------------->>

#refunds issued by date
paypal_refunds <- paypal %>% 
  filter(type == "Payment Refund") %>%
  group_by(date) %>%
  summarise(refunds = sum(gross)) 

#fees paid to paypal by date (woocommerce payments only)
paypal_fee <- paypal %>%
  filter(type %in% c("Website Payment", "Direct Credit Card Payment")) %>%
  group_by(date) %>%
  summarise(fee = sum(fee))

#new customers by date
wc_engine_new_customers <- wc_engine %>% 
  group_by(order_date) %>%
  summarise("new_customers" = replace_na(n(), 0) - replace_na(sum(returning_customer),0)) 
  
#usps.shipping_cost by date
usps_shipping_cost <- usps %>%
  group_by(postage_date) %>%
  summarise(shipping_cost = sum(shipping_cost))

#create orders table
#----------------------------------------------->
#ALWAYS JOIN ON WC_ORDERS. WC_TAX does not include observations for dates with no orders but wc_orders does.

orders <- wc_orders %>% 
  left_join(wc_tax, by = "order_date") %>% 
  left_join(paypal_refunds, by = c("order_date" = "date")) %>% 
  left_join(paypal_fee, by = c("order_date" = "date")) %>%
  left_join(wc_engine_new_customers, by = "order_date") %>%
  left_join(usps_shipping_cost, by = c("order_date" = "postage_date")) %>%
  mutate("turnover" = sales - tax) %>% 
  select(-c(sales, tax))

#create registration table
#------------------------------------------------------->>

registrations <- wc_registrations

#create traffic table
#------------------------------------------------------->>

source_medium_update_log()

traffic <- google_analytics %>%
  group_by(date, source, medium, campaign) %>%
  summarise(users = sum(users), 
            new_users = sum(new_users), 
            newsletter_sign_up = sum(newsletter_sign_up),
            reach_checkout = sum(reach_checkout),
            view_cart = sum(view_cart))


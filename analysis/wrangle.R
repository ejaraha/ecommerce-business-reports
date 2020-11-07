source("C:/Users/Owner/repos/ecommerce_business_report/analysis/clean.R")

#creates five new csv files in "C:/Users/Owner/repos/ecommerce_business_report/data/YYYYMM/processed"
#orders_YYYYMM.csv, traffic_YYYYMM.csv, registrations_YYYYMM.csv, 
#coupon_YYYYMM.csv, campaign_YYYYMM.csv

#create directory ./processed
#-------------------------------------------->>

dir_name <- paste("C:/Users/Owner/repos/ecommerce_business_report/data/", yearmo, "/processed", sep="")
ifelse(dir.exists(dir_name) == TRUE, dir_name, dir.create(dir_name))

#convert order-level data to date-level data
#-------------------------------------------->>

#refunds issued by date
paypal_refunds <- paypal %>% 
  filter(type == "Payment Refund") %>%
  group_by(date) %>%
  summarise(refunds = abs(sum(gross))) #gross where type = refund

#fees paid to paypal by date (woocommerce payments only)
paypal_fee <- paypal %>%
  filter(type %in% c("Website Payment", "Direct Credit Card Payment")) %>%
  group_by(date) %>%
  summarise("fee_paypal" = sum(fee))

#new customers by date
wpe_new_customers <- wpe_returning_customer %>% 
  group_by(order_date) %>%
  summarise("new_customers" = replace_na(n(), 0) - replace_na(sum(returning_customer),0))

#discounts by date
discounts <- wpe_coupon_data %>%
  group_by(date_applied) %>%
  summarise(discounts = sum(discount_amount))

#usps.shipping_cost and ups.shipping_cost by date
shipping_cost <- usps %>%
  bind_rows(ups) %>%
  group_by(date) %>%
  summarise("shipping_cost" = sum(shipping_cost))

#create orders table
#----------------------------------------------->
#ALWAYS JOIN ON WC_ORDERS. WC_TAX does not include observations for dates with no orders but wc_orders does.

#vector of days in the report month
from_date <- as.Date(paste(yearmo, "01", sep=""), "%Y%m%d")
to_date <- from_date %m+% months(1)
days_of_month <- data.frame(seq(from_date, to_date, by="day")) %>% 
  rename("date" = 1) %>%
  filter(date != to_date)

orders <- wc_orders %>% #number of products purchased
  #discount data
  left_join(discounts, by=c("order_date"="date_applied")) %>%
  #sales, number of orders, shipping
  left_join(wc_tax, by = "order_date") %>% 
  left_join(paypal_refunds, by = c("order_date" = "date")) %>% 
  left_join(paypal_fee, by = c("order_date" = "date")) %>%
  left_join(wpe_new_customers, by = "order_date") %>%
  left_join(shipping_cost, by = c("order_date" = "date")) %>% 
  mutate_at(c("discounts", "orders_placed", "shipping_charged", "refunds", "fee_paypal", "new_customers","shipping_cost", "sales", "tax"), ~replace_na(.,0)) %>%
  mutate("turnover" = sales + discounts - tax,
         "net_profit" = sales - tax - fee_paypal - refunds - shipping_cost + shipping_charged) %>% 
  select(-c(sales, tax))

file_path <- paste("C:/Users/Owner/repos/ecommerce_business_report/data/", yearmo, "/processed/orders_", yearmo, ".csv",sep="")
write.csv(orders, file_path, row.names = FALSE)
print(sprintf("FILE CREATED: %s", file_path))

#create registration table
#------------------------------------------------------->>

registrations <- wc_registrations

file_path <- paste("C:/Users/Owner/repos/ecommerce_business_report/data/", yearmo, "/processed/registrations_", yearmo, ".csv",sep="")
write.csv(registrations, file_path, row.names = FALSE)
print(sprintf("FILE CREATED: %s", file_path))

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

file_path <- paste("C:/Users/Owner/repos/ecommerce_business_report/data/", yearmo, "/processed/traffic_", yearmo, ".csv",sep="")
write.csv(traffic, file_path, row.names = FALSE)
print(sprintf("FILE CREATED: %s", file_path))

#create coupon table
#------------------------------------------------------->>

coupon <- wpe_coupon_data %>%
  group_by(coupon_code) %>%
  summarize(total_discounts = sum(discount_amount), total_orders = n())

file_path <- paste("C:/Users/Owner/repos/ecommerce_business_report/data/", yearmo, "/processed/coupon_", yearmo, ".csv",sep="")
write.csv(coupon, file_path, row.names = FALSE)
print(sprintf("FILE CREATED: %s", file_path))

vars <- c("users", "view_cart", "reach_checkout")


#create campaign table
#------------------------------------------------------->>

campaign <- traffic %>%
  filter(source %in% c("newsletter", "facebook")
         & is.na(campaign) != TRUE) %>%
  group_by(source, campaign) %>%
  summarise(across(all_of(vars),sum)) %>%
  rename("click" = users)

file_path <- paste("C:/Users/Owner/repos/ecommerce_business_report/data/", yearmo, "/processed/campaign_", yearmo, ".csv",sep="")
write.csv(campaign, file_path, row.names = FALSE)
print(sprintf("FILE CREATED: %s", file_path))




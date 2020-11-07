[toc]



# DATA TABLES 

## Cleaned 

### wc_orders	

| variable           | type |
| ------------------ | ---- |
| order_date**       | date |
| products_purchased | int  |

### wc_tax

| variable         | type | notes              |
| ---------------- | ---- | ------------------ |
| order_date**     | date |                    |
| orders_placed    | int  |                    |
| sales            | dbl  | sales includes tax |
| shipping_charged | dbl  |                    |
| tax              | dbl  |                    |

### wc_registrations

| variable               | type |
| ---------------------- | ---- |
| date                   | date |
| customer_registrations | int  |



### wpe_returning_customer

| variable           | type |
| ------------------ | ---- |
| order_date**       | date |
| returning_customer | int  |

### wpe_coupon_data

| variable        | type |
| --------------- | ---- |
| order_id        | int  |
| coupon_code     | chr  |
| date_applied    | date |
| discount_amount | dbl  |



### paypal

| variable       | type | notes                    |
| -------------- | ---- | ------------------------ |
| date           | date |                          |
| name           | chr  |                          |
| email          | chr  |                          |
| invoice_number | chr  |                          |
| gross          | dbl  | order total              |
| net            | dbl  | order total - paypal.fee |
| fee            | dbl  |                          |
| type           | chr  |                          |

### usps

| variable      | type |
| ------------- | ---- |
| postage_date  | date |
| shipping_cost | dbl  |
| weight_lb     | dbl  |
| state         | chr  |
| status        | chr  |
| tracking_id   | chr  |

### ups

| variable      | type |
| ------------- | ---- |
| date          | date |
| shipping_cost | dbl  |

### google_analytics

| variable           | type |
| ------------------ | ---- |
| date**             | date |
| users              | int  |
| new_users          | int  |
| source**           | chr  |
| medium**           | chr  |
| campaign**         | chr  |
| newsletter_sign_up | int  |
| reach_checkout     | int  |
| view_cart          | int  |

## Wrangled

### registrations 

| variable               | how it's calculated |
| ---------------------- | ------------------- |
| date                   | na                  |
| customer_registrations | na                  |



### orders

| variable           | how it's calculated                                          |
| ------------------ | ------------------------------------------------------------ |
| order_date**       | wc_orders.order_date                                         |
| new_customers      | #customers - #returning customers                            |
| orders_placed      | wc_orders.orders_placed                                      |
| products_purchased | wc_orders.products_purchased                                 |
| turnover           | wc_tax.sales - wc_tax.tax                                    |
| net_profit         | wc_tax.sales - wc_tax.tax - shipping_cost_usps - shipping_cost_ups + shipping_charged - coupons - refunds - fee |
| coupons            | wc_orders.coupons                                            |
| refunds            | paypal.refunds                                               |
| shipping_charged   | wc_tax.shipping_charged                                      |
| shipping_cost      | usps.shipping_cost OR ups.shipping_cost                      |
| fee                | paypal.fee                                                   |

### traffic

| variable           | how it's calculated                 |
| ------------------ | ----------------------------------- |
| date**             | google_analytics.date               |
| users              | google_analytics.users              |
| new_users          | google_analytics.new_users          |
| source**           | google_analytics.source             |
| medium**           | google_analytics.medium             |
| campaign**         | google_analytics.campaign           |
| newsletter_sign_up | google_analytics.newsletter_sign_up |
| reach_checkout     | google_analytics.reach_checkout     |
| view_cart          | google_analytics.view_cart          |

### coupon

| variable        | how it's calculated                             |
| --------------- | ----------------------------------------------- |
| coupon_code     | wpe_coupon_data$coupon_code                     |
| total_discounts | sum(wpe_coupon_data$discount_amount)            |
| total_orders    | n() when grouped by wpe_coupon_data$coupon_code |

### campaign

| variable       | how it's calculated         |
| -------------- | --------------------------- |
| source         | traffic$source              |
| campaign       | traffic$campaign            |
| click          | sum(traffic$users)          |
| view_cart      | sum(traffic$view_cart)      |
| reach_checkout | sum(traffic$reach_checkout) |


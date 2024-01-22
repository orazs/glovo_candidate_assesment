library(tidyverse)
library(data.table)
1/6
glovo <- fread("glovo.csv")
glovo <- glovo %>%
  mutate(order_hour = hour(strptime(order_creation_time_local, format = "%H:%M:%S")))

#00a082
#ffc244

glovo %>%
  ggplot(aes(payment_status, eur_amount, color=order_type))+
  stat_summary(fun="mean",geom="point", position=position_dodge(width=0.9))+
  stat_summary(fun.data = "mean_cl_normal", geom="errorbar",width=0.5, position=position_dodge(width=0.9))+
  theme_minimal()+
  theme(legend.position = 'bottom',legend.title = element_blank())+
  scale_y_continuous(labels=scales::percent)+
  scale_color_brewer(palette = "Set1")

sum(t$ratio)

glovo %>%
  mutate(fraud_ratio = sum(if_else(final_order_status=="CanceledStatus",1,0)/n())) %>%
  ggplot(aes(multiple_account, fraud_ratio))+
  stat_summary(fun="mean",geom="point", position=position_dodge(width=0.9))+
  theme_minimal()+
  theme(legend.position = 'bottom',legend.title = element_blank())+
  scale_y_continuous(labels=scales::percent)+
  
  scale_color_brewer(palette = "Set1")

  geom_line(color="red")+
  geom_line(aes(y=ratio2/0.2),color="#00a082", stat="identity")+
  scale_y_continuous(labels=scales::percent,
                     name="Fraud Ratio (%)",
                     sec.axis = sec_axis(~.*0.2, name="Profit Ratio (%)",labels=scales::percent))+
  theme(axis.text.y = element_text(colour="red",),
        axis.text.y.right = element_text(color = "#00a082"))

glovo$cut_cnt <- cut(glovo$customer_orders_count,
                     breaks = c(seq(0,100,10),max(glovo$customer_orders_count,na.rm=T)),
                     right = T,
                     include.lowest = T,
                     labels = c("<10","10-20","20-30","30-40","40-50","50-60","60-70","70-80","80-90","90-100","100+"))

library(rpart.plot)
glovo_model <- rpart(final_order_status~cut_cnt+device_os+order_hour+order_type+multiple_account, glovo)
rpart.plot(glovo_model, box.palette="GnBu", shadow.col="gray", nn=TRUE)

saveRDS(glovo_model,"model.RData")

rpart.rules(glovo_model, cover = T,style="tallw")


glovo <- glovo %>%
  group_by(device_ip) %>%
  mutate(multiple_account=ifelse(length(unique(customer_id))>1,T,F) ) %>%
  select(customer_id, device_ip, multiple_account)


glovo %>%
  ggplot(aes(multiple_account, eur_amount,color=order_type))+
  stat_summary(fun="mean",geom="point", position=position_dodge(width=0.9))+
  stat_summary(fun.data = "mean_cl_normal", geom="errorbar",width=0.5, position=position_dodge(width=0.9))+
  geom_line(aes(group=order_type),position=position_dodge(width=0.9))+
  theme_minimal()+
  scale_y_continuous(labels=scales::percent)+
  scale_color_brewer(palette = "Set1")


glovo %>%
  group_by(multiple_account, cut_cnt) %>%
  summarise(fraud_ratio = sum(if_else(final_order_status=="CanceledStatus",1,0)/n()),N=n()) %>%
  ungroup() %>%
  mutate(sum(N),total_ratio=N/sum(N))


glovo %>%
  filter(final_order_status=="CanceledStatus", multiple_account==T, order_type=="QUIERO") %>%
  group_by() %>%
  summarise(n())

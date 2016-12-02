library(ggplot2)
library(dplyr)
library(graphics)
library(MASS)
library(car)
library(Metrics) # rmsle
library(stats) # glm
library(mgcv)
library(vegan)
library(randomForest)
library(rfUtilities)
library(caret)
library(e1071)
set.seed(123)
setwd("~/NanZHAO/Formation_BigData/Memoires/tmp/db")

data1 = read.csv2("table_country_company_contract.csv")
group <- group_by(data1, country)
summary1 <- summarise(group, 
            sum_contract = n())

data2 = read.csv2("table_country_company_contract_name.csv")
group <- group_by(data2, country, contract_name)
summary2 <- summarise(group, 
                      stations = n())
ggplot(data2, aes(contract_name)) +
  geom_bar()+
  facet_wrap(~country, scale="free")

data3 = read.csv2("table_country_company_contract_name_bonus.csv") 
ggplot(data3, aes(contract_name, fill=bonus)) +
  geom_bar()+
  facet_wrap(~country, scale="free")

ggplot(filter(data3, country %in% ("France")), aes(contract_name, fill=bonus)) +
  geom_bar()

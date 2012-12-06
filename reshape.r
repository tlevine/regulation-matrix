#!/usr/bin/env Rscript
library(reshape2)
library(plyr)

m <- read.csv('matrix.csv')
names(m)[1] <- 'id'

# The "Questions" column contains two variables: category and question
categories <- m[is.na(m$id),][2]
categories$Questions <- factor(as.character(categories$Questions))
questions <- m[!is.na(m$id),]
questions$category <- categories[nrow(categories),'Questions']

category.ranges <- data.frame(
  # All except the last range, which I already set above
  category = categories[1:(nrow(categories) - 1), 'Questions'],
  before = as.numeric(row.names(categories)[(2:nrow(categories)) - 1]),
  after = as.numeric(row.names(categories)[2:nrow(categories)])
)
d_ply(category.ranges, 'before', function(df){
  .questions <- questions[seq(df[1,'before'] + 1, df[1,'after']-1)),]
  questions[seq(df[1,'before'] + 1, df[1,'after']-1),'category'] <- df[1,'category']
})

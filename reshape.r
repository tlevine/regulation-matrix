#!/usr/bin/env Rscript
library(reshape2)
library(plyr)

m <- read.csv('matrix.csv')
names(m)[1] <- 'id'

#
# The "Questions" column contains two variables: category and question.
# Separate these.
#

categories <- m[is.na(m$id),][2]
categories$Questions <- factor(as.character(categories$Questions))
questions <- m[!is.na(m$id),]
questions$category <- NA

category.ranges <- data.frame(
  category = categories[1:nrow(categories), 'Questions'],
  before = as.numeric(row.names(categories)[1:nrow(categories)]),
  after = c(as.numeric(row.names(categories)[2:nrow(categories)]), nrow(m))
)

questions <- ddply(category.ranges, 'before', function(df){
  .questions <- questions[seq(df[1,'before'] + 1, df[1,'after'] - 1),]
  .questions$category <- df[1,'category']
  .questions
})
questions$before <- NULL
questions$id <- NULL

#
# Turn the columns into a country variable.
#

questions.molten <- melt(questions, c('category', 'Questions'), variable.name = 'Country')
colnames(questions.molten) <- c('Category', 'Question', 'Country', 'Response')

write.csv(questions.molten, file = 'matrix-molten.csv', row.names = F)

#
# How to query
#

library(sqldf)
some.response <- sqldf("SELECT Response FROM [questions.molten] WHERE Country = 'Malaysia' AND Question = 'Are e-money funds/ back-up funds protected against creditors of the issuer?'")

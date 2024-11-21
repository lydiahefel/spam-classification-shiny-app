library(shiny)
library(bslib)
library(here)
library(dplyr)
library(plotly)
library(bayesrules)
library(tidyverse)
library(e1071)
library(janitor)
library(tm)
library(wordcloud)
library(tidytext)



ui <- page_fluid(
  titlePanel("Spam Classification Model"),
  
  # Sidebar layout
  sidebarLayout(
    sidebarPanel(
      # allow for text input
      textInput("text", "Enter SMS text:"),
      
      # add an action button
      actionButton("classify", "Classify"),
      card(textOutput("prediction"))
      
    ),
    
    # the main section of the app
    mainPanel(
      # output
      card(str(data)),
      card(plotOutput("plot1")),
      card(plotOutput("plot2")),
      card(plotOutput("plot3")),
      
      card(plotOutput("wc1")),
      card(plotOutput("wc2"))
    )
  )
)

server <- function(input, output) {
  
  
  
  
  
  
  data <- 
    read.table(file = here("SMSSpamCollection"), sep="\t", quote="", comment.char="")
  colnames(data) <- c("type", "message")
  data$has_exclamation <- ifelse(grepl("!", data$message), "yes", "no")
  data$word_count <- sapply(strsplit(data$message, "\\s+"), length)
  spam_count_greater_than_50 <- sum(data$type == "spam" & data$word_count > 50)
  words <- data %>%
    unnest_tokens(word, message) %>%
    anti_join(stop_words)
  
  word_count <- words %>%
    group_by(type, word) %>%
    summarize(count = n()) %>%
    arrange(desc(count))
  
  spam_messages <- subset(data, type == "spam")$message
  
  # Create a text corpus for 'spam' messages
  spam_corpus <- Corpus(VectorSource(spam_messages))
  
  # Clean the text: remove punctuation, stopwords, and convert to lowercase
  spam_corpus <- tm_map(spam_corpus, content_transformer(tolower))
  spam_corpus <- tm_map(spam_corpus, removePunctuation)
  spam_corpus <- tm_map(spam_corpus, removeWords, stopwords("english"))
  spam_corpus <- tm_map(spam_corpus, stripWhitespace)
  
  # Create a term-document matrix
  tdm <- TermDocumentMatrix(spam_corpus)
  
  # Convert term-document matrix to a matrix and get word frequencies
  tdm_matrix <- as.matrix(tdm)
  word_freqs <- rowSums(tdm_matrix)
  
  # Sort word frequencies in decreasing order and get the top 10 words
  top_10_words <- sort(word_freqs, decreasing = TRUE)[1:10]
  
  # Convert to a data frame for readability
  top_10_words_df <- data.frame(word = names(top_10_words), frequency = top_10_words, row.names = NULL)
  
  # Assuming 'top_10' is a list of the top 10 words as created previously
  top_10_words <- unlist(top_10)  # Convert list to vector for pattern matching
  
  # Create a new column 'contains_top_10' in 'data'
  data$contains_top_10 <- sapply(data$message, function(msg) {
    # Check if any of the top 10 words are in the message
    if (any(sapply(top_10_words, function(word) grepl(word, msg, ignore.case = TRUE)))) {
      "yes"
    } else {
      "no"
    }
  })
  
  spam_data <- 
    read.table(file = here("SMSSpamCollection"), sep="\t", quote="", comment.char="") %>%
    mutate(id = row_number()) %>% 
    select(id, everything())
  
  colnames(spam_data)[c(2,3)] <- c("type", "message")
  
  sentiment_by_message <- spam_data %>%
    unnest_tokens(word, message) %>%
    inner_join(get_sentiments("bing"), by = "word") %>%
    count(id, sentiment)
  
  sentiment_by_message <- sentiment_by_message %>%
    spread(key = sentiment, value = n, fill = 0) %>%
    mutate(sentiment_score = positive - negative) %>%
    select(id, sentiment_score)
  
  sentiment_by_message <- sentiment_by_message %>%
    mutate(sentiment = case_when(
      sentiment_score > 0 ~ "positive",
      sentiment_score < 0 ~ "negative",
      TRUE ~ "neutral"))
  
  spam_data <- spam_data %>% 
    left_join(sentiment_by_message, by = "id")
  spam_data <- spam_data %>% select(-sentiment_score)
  
  data <- cbind(data, spam_data)
  
  data <- data[, -c(7, 8)]
  
  data <- data %>%
    select(id, everything())
  data
  
  naive_model_hints <- naiveBayes(type ~ has_exclamation + word_count + contains_top_10 + sentiment, data = data)
  
  our_message <- data.frame(has_exclamation = 'yes', word_count = 15, contains_top_10 = 'no', sentiment = 'negative')
  
  predict(naive_model_hints, newdata = our_message, type = "raw")
  
  data <- data %>% 
    mutate(predicted_type = predict(naive_model_hints, newdata = .))
  
  data %>% 
    tabyl(type, predicted_type) %>% 
    adorn_percentages("row") %>% 
    adorn_pct_formatting(digits = 2) %>%
    adorn_ns
  
  
  
  
  
  
  
  
  
  observeEvent(input$classify, {
    #prediction
    our_prediction <- data.frame(text = input$text)
    our_prediction$word_count <- sapply(strsplit(as.character(our_prediction$text), "\\s+"), length)
    our_prediction$count_exclamations <- sum(grepl("!", our_prediction$text))
    our_prediction$has_exclamation <- ifelse(grepl("!", our_prediction$text), "yes", "no")
    
    prediction <- predict(naive_model_hints, our_prediction)
    
    # Output
    output$prediction <- renderText({
      paste("Prediction: ", prediction)
    })
  })
  
  
  #render all the visuals
   
  output$plot1 <- renderPlot({
    ggplot(data, aes(x = type, fill = has_exclamation)) + 
      geom_bar()
    })
  
  output$plot3 <- renderPlot({
    ggplot(head(word_count, n = 35), aes(x = count, y = word, fill = type)) +
      geom_col()
  })
  # 
  output$plot2 <- renderPlot({
    ggplot(data, aes(x = type, y = word_count, color = has_exclamation)) + 
      geom_point()
  })

  
  output$wc1 <- renderPlot({
    wordcloud(ham_corpus, max.words = 120, random.order = FALSE, colors = brewer.pal(8, "Dark2"), main = "Ham Messages")
  })
  
  output$wc2 <- renderPlot({
    wordcloud(spam_corpus, max.words = 100, random.order = FALSE, colors = brewer.pal(8, "Reds"), main = "Spam Messages")
  })
  
}

  


shinyApp(ui = ui, server = server)
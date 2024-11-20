# SMS Spam Message Naive Bayes Classification Shiny App 📩

![image](https://github.com/user-attachments/assets/9e71d778-bff4-46e7-bd90-4c6ebccd396c) ![image](https://github.com/user-attachments/assets/e937eb63-d60a-45eb-81b2-c91afa01bde3)


For our final project of DS 400: Bayesian Statistics, we were assigned to create a SMS spam message classifier Shiny app which takes in user input using Bayesian Statistics. Raw data: https://archive.ics.uci.edu/dataset/228/sms+spam+collection

For our project, we used RStudio. We uploaded the the dataset, cleaned the data, and created data visulizations to understand the components of our data and identify key variables to implement into a Bayesian model. We chose to create a Naive Bayes Classification model, due to the categorical nature of the types of messages (spam of ham/not spam) and the multiple factors which we found to through our analysis which are contributors to the indentification of message type. The 4 variables, which are assumed to be conditionally independent by definition of Naive Bayes, are: 
1) message has exclamation (boolean)
2) word count of message (int)
3) contains any of the top 10 words contained in a spam message (boolean)
4) sentiment of the message (positive, negative, or neutral)

The confusion matrix output of our model: 
 type            ham         spam
 ham 95.59% (4,614)  4.41% (213)
 spam 25.30%   (189) 74.70% (558)

 Thus, our model correctly predicts spam messages at a 74.70% rate. 

 ![image](https://github.com/user-attachments/assets/fdc27659-39a0-4577-a7b1-2ef91391df2f)

 Group Members: 
[Lydia Hefel](https://github.com/lydiahefel)
[Ashley Holen](https://github.com/ashleyholen)
[Bennet Bush](https://github.com/0xw1nn13)
[Landon Vitug](https://github.com/landonv808)
[Kamryn Lopez](https://github.com/kamrynlopez)



 

   


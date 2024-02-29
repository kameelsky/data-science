# Contents

## Maximum Likelihood Estimation (MLE) and expected value for a continuous variable

Imagine we have a dataset from a shop. Every time a customer enters the shop, a timestamp is recorded. After collecting data for a certain period, the owner analyzes the time intervals between consecutive customer arrivals.

In [MLE_Expected_value](./Toolbox/MLE_Expected_value.ipynb) jupyter notebook I translate and guide step by step through the subject of **Maximum Likelihood Estimation (MLE)**, showing how to calculate it for an exponential distribution. Additionally using sympy we calculate an **expected value** for mentioned distribution and predict probability of specific frequencies according to Poisson distribution.

## Bayes' Theorem

Let's say you want to find out the probability of having a certain rare disease. We know that this disease affects 1 person out of 100,000. The precission of the test detecting the disease is 98%. If a survey was conducted, asking:

***'What is the probability of being infected when we are positively classified by the test?'***

Vast majority of respondents would anwser that we are ill with 98% of confidence. However, this isn't the correct answer. To find the correct one, we need to look at the situation from a slightly [broader perspective](./Toolbox/Bayes_Theorem.ipynb)..

## Entropy of data
In [Entropy](./Toolbox/Entropy.ipynb) jupyter notebook you can find an explanation of what is the data entropy and how to interpret it.

## Kaggle datasets: Titanic

In the notebooks in [Titanic](./Titanic/) folder I am sharing my interpretation of the dataset from Kaggle: [*Titanic - Machine Learning from Disaster*](https://www.kaggle.com/competitions/titanic).

My primary goals are to conduct Exploratory Data Analysis (EDA) and develop machine learning (ML) models, followed by their subsequent comparison. This undertaking was motivated by the need for effective data interpretation, wherein ML models play a crucial role in uncovering patterns and extracting valuable insights from complex datasets.

**ML models and data interpretation:**

1. [Data Cleaning, Feature Engineering, Explanatory Data Analysis](./Titanic/1_Data.ipynb)
2. [ML models screen](./Titanic/2_Model_screen.ipynb)
3. [Random Forest: parameters hypertuning](./Titanic/3_RandomForest.ipynb)
4. [Receiver Operating Characteristic (ROC), Confusion Matrix and Threshold adjustement](./Titanic/4_ROC.ipynb)
5. [Decision Tree: Cost Complexity Pruning (CCP)](./Titanic/5_DecissionTree.ipynb)
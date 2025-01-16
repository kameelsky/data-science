# Design of Experiments -  Screening and optimization designs [[notebook](./Toolbox/DOE.ipynb)]

***Screen***
- How to build a **Full-factorial design ($2^k$)** using categorical data.
- Can we make the same conclusions by reducing the number of runs using a **Fractional-factorial design ($2^{k-n}$)**? Concepts of resolution and factor aliasing will be explained.
- Build and validate a model to predict the output.

***Optimization***
- How to utilize the **Central Composite Design (CCD)**, and build a **response surface model (RSP)**. 
- Step-by-step calculation and classification of a critical points.

# Continous and discrete Fourier transformation [[notebook](./Toolbox/Fourier.ipynb)]

The document provides an exploration of the Continuous Fourier Transform and the Discrete Fourier Transform (DFT), two fundamental mathematical techniques used for analyzing signals in the frequency domain

# Gradient descent algorithm to minimize the cost function [[notebook](./Toolbox/GD_minimization.ipynb)]

I am demonstrating a basic machine learning algorithm and its application in minimizing a loss function to train a linear model. The parameters are computed algebraically using the SymPy library and then compared to the parameters learned by our algorithm and the [scikit-learn: LinearRegression](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LinearRegression.html) one. The theory will be explained in a clear and accessible manner, along with the derivation of the relevant formulas.

# Gradient ascent algorithm to maximize the likelihood of observing the data [[notebook](./Toolbox/GA_maximization.ipynb)]

Following previous chapter I am demonstrating how to train a custom logistic regression model using Gradient Descent algorithm. As previously we compare the performance to the [scikit-learn: LogisticRegression](https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html) one. The theory will be explained in a clear and accessible manner, along with the derivation of the relevant formulas.

# Maximum Likelihood Estimation (MLE) from scratch [[notebook](./Toolbox/MLE_Expected_value.ipynb)]

Imagine we have a dataset from a shop. Every time a customer enters the shop, a timestamp is recorded. After collecting data for a certain period, the owner analyzes the time intervals between consecutive customer arrivals, wishing to find out the probability of more or less customers entering the shop for a given time.

I will translate and guide step by step through the subject of **Maximum Likelihood Estimation (MLE)**, showing how to calculate it for an **exponential distribution**. Additionally using sympy we calculate an **expected value** for mentioned distribution and predict probability of specific frequencies according to **Poisson distribution**.

# Entropy of data [[notebook](./Toolbox/Entropy.ipynb)]
In the jupyter notebook you can find an explanation of what is the data entropy and how to interpret it.

# Bayes' Theorem [[notebook](./Toolbox/Bayes_Theorem.ipynb)]

Let's say you want to find out the probability of having a certain rare disease. We know that this disease affects 1 person out of 100,000. The precission of the test detecting the disease is 98%. If a survey was conducted, asking:

***'What is the probability of being infected when we are positively classified by the test?'***

Vast majority of respondents would anwser that we are ill with 98% of confidence. However, this isn't the correct answer. To find the correct one, we need to look at the situation from a slightly broader perspective.

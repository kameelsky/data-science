import pandas as pd
import numpy as np

def data_transform(data_frame: pd.DataFrame) -> pd.DataFrame:
    """Fills Age column with median; Embarked column with first element which is the most frequently-occurring
Creating TravelAlone predictor; Removing ittelevant predictors; Creating dummy variables; Transforming dtypes"""

    data_frame["Age"].fillna(data_frame["Age"].median(), inplace=True) # Adjusting the Age column
    data_frame["Embarked"].fillna(data_frame["Embarked"].value_counts().idxmax(), inplace=True) # Adjusting the Embarked column

    # Creating a TravelAlone predictor
    data_frame['TravelAlone'] = np.where((data_frame["SibSp"] + data_frame["Parch"]) > 0, 0, 1)
    
    # Removing irrelevant predictors
    data_frame.drop(columns=["PassengerId", "Name", "Ticket", "SibSp", "Parch", "Cabin"], inplace=True)

    #Transforming data types
    data_frame[['Fare']] = data_frame[['Fare']].astype("float")
    data_frame[['Survived', 'Pclass', 'Age', 'TravelAlone']] = data_frame[['Survived', 'Pclass', 'Age', 'TravelAlone']].astype("int32")

    # Creating categorical variables
    df_train_encoded = pd.get_dummies(data_frame, columns=["Pclass","Embarked","Sex"], drop_first=True, dtype=int)

    return df_train_encoded
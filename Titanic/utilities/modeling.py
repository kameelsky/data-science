from typing import Union
from dataclasses import dataclass, field
import pandas as pd
import numpy as np
from sklearn.model_selection import cross_validate
import inspect

@dataclass
class Model:

    model: object = field(repr=False)
    model_name: str = field(init=False)
    X_domain: pd.DataFrame = field(repr=False)
    y_domain: pd.DataFrame = field(repr=False)

    cross_validator: Union[object, int] = field(repr=False)

    accuracy: list[float] = field(default_factory=list[float])
    precission: list[float]  = field(default_factory=list[float])
    roc_auc: list[float]  = field(default_factory=list[float])
    f1: list[float]  = field(default_factory=list[float])
    recall: list[float]  = field(default_factory=list[float])

    def model_name_(self) -> model_name:
        self.model_name = self.model.__name__

    def cross_validation_(self, kwargs: dict = {}) -> (accuracy, precission, roc_auc, f1, recall):

        def cv_iter(self, iterations: int = 5, round_: int = 3):

            accuracy = []
            precission = []
            roc_auc = []
            f1 = []
            recall = []

            for i in range(iterations):

                cross_valitation_results = cross_validate(estimator=self.model(**kwargs, random_state=i), 
                                                        X=self.X_domain, y=self.y_domain, scoring=["accuracy", "precision", "roc_auc", "f1", "recall"], 
                                                        cv=self.cross_validator)
                accuracy.append(cross_valitation_results["test_accuracy"].mean())
                precission.append(cross_valitation_results["test_precision"].mean())
                roc_auc.append(cross_valitation_results["test_roc_auc"].mean())
                f1.append(cross_valitation_results["test_f1"].mean())
                recall.append(cross_valitation_results["test_recall"].mean())
            
            self.accuracy = np.array(accuracy).mean().round(round_)
            self.precission = np.array(precission).mean().round(round_)
            self.roc_auc = np.array(roc_auc).mean().round(round_)
            self.f1 = np.array(f1).mean().round(round_)
            self.recall = np.array(recall).mean().round(round_)
        
        def cv(self, round_: int = 3):

            cross_valitation_results = cross_validate(estimator=self.model(**kwargs), 
                                                        X=self.X_domain, y=self.y_domain, scoring=["accuracy", "precision", "roc_auc", "f1", "recall"], 
                                                        cv=self.cross_validator)
            
            self.accuracy = cross_valitation_results["test_accuracy"].mean().round(round_)
            self.precission = cross_valitation_results["test_precision"].mean().round(round_)
            self.roc_auc = cross_valitation_results["test_roc_auc"].mean().round(round_)
            self.f1 = cross_valitation_results["test_f1"].mean().round(round_)
            self.recall = cross_valitation_results["test_recall"].mean().round(round_)
    
        try:
            parameters = inspect.signature(self.model).parameters
            assert "random_state" in parameters
        except AssertionError:
            cv(self)
        else:
            cv_iter(self)

    def __post_init__(self):
        self.model_name_()
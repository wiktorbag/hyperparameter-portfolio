import itertools
import pandas as pd
import numpy as np
file = pd.read_csv("MementoML.csv")

def get_datasets_all_indexes(file, model):
    """ Get all datasets from file on which all param_indexes have been tested
    """
    model_file = file[file["model"] == model]
    all_param_indexes = set(model_file['param_index'].unique())
    def has_all_param_indexes(group):
        return set(group['param_index']) == all_param_indexes
    return model_file.groupby('dataset').filter(has_all_param_indexes)['dataset'].unique()


def get_mean_metric_dataset(file, model, metric):
    """ This function inputs a pd data frame with ranks for each param_index inside each dataset based on a chosen model, metric and inputted file.
        file needs to be pd, and model and metric need to be present in the model and metric file
    """
    datasets = get_datasets_all_indexes(file, model)
    filtered_df = file[(file["model"] == model) & file["dataset"].isin(datasets)]
    df = filtered_df.groupby(['dataset', 'param_index'])[metric].mean().reset_index()
    df['rank'] = df.groupby('dataset')[metric].rank(ascending=False, method = "min")
    return df



def get_mean_metric_dataset_max_params_max_ds(file, model, metric, number_datasets, number_params):
    """ funkction like get_mean_metric_dataset for tests - outputs a smaller dataframe of number_datasets first datasets and number_params first params. 
    """
    datasets = get_datasets_all_indexes(file, model)
    filtered_df = file[(file["model"] == model) & file["dataset"].isin(datasets[:number_datasets]) & file["param_index"].isin(np.arange(1, number_params+1, 1))]
    df = filtered_df.groupby(['dataset', 'param_index'])[metric].mean().reset_index()
    df['rank'] = df.groupby('dataset')[metric].rank(ascending=False, method = "min")
    return df

def performence(df, new_param, previous_params):
    """ Outputs the sum of minimum ranks for each dataset from previous and new params
        Defined in 2015 IEEE International Conference on Data Mining - Sequential Model-free Hyperparameter Tuning.
    """
    df_chosen_params = df[df["param_index"].isin(previous_params + [new_param])]
    min_ranks = df_chosen_params.groupby('dataset')['rank'].min().reset_index()
    return min_ranks["rank"].sum()

def CANE_optimal_sequence(file, T):
    """ Outputs T best paramters optimizing for ranks inside each dataset. 
    If optimal ranks are reached before T parameters have been chosen, then stops.
    Defined in 2015 IEEE International Conference on Data Mining - Sequential Model-free Hyperparameter Tuning.
    """
    previous_params = []
    for _ in range(1, T+1):
        all_param_indexes = list(file["param_index"].unique())
        performences = [performence(file, param, previous_params) for param in all_param_indexes]
        previous_params.append(all_param_indexes[performences.index(min(performences))])
        if performence(file, previous_params[0], previous_params) == len(file["dataset"].unique()):
            return previous_params
    return previous_params

def ASMFO(file, T):
    """Outputs T best paramters optimizing for ranks inside each dataset. 
    If optimal ranks are reached before T parameters have been chosen, 
    then reruns the CANE optimal sequence whithout the previously chosen hyperparameter configurations.
    Defined in 2015 IEEE International Conference on Data Mining - Sequential Model-free Hyperparameter Tuning.
    """
    params_vector = []
    while T>0:
        params_vector_new = CANE_optimal_sequence(file[~file['param_index'].isin(params_vector)], T)
        T -= len(params_vector_new)
        params_vector += params_vector_new 
    return params_vector

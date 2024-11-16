import itertools
import pandas as pd
import numpy as np
file = pd.read_csv("MementoML.csv")

def get_datasets_all_indexes(file: pd.DataFrame, model: str) -> np.ndarray:
    """ Get all datasets from file on which all param_indexes have been tested
    """
    model_file = file[file["model"] == model]
    all_param_indexes = set(model_file['param_index'].unique())
    def has_all_param_indexes(group):
        return set(group['param_index']) == all_param_indexes
    return model_file.groupby('dataset').filter(has_all_param_indexes)['dataset'].unique()


def get_mean_metric_dataset(file: pd.DataFrame, model: str, metric: str) -> pd.DataFrame:
    """ This function inputs a pd data frame with ranks for each param_index inside each dataset based on a chosen model, metric and inputted file.
        file needs to be pd, and model and metric need to be present in the model and metric file
    """
    datasets = get_datasets_all_indexes(file, model)
    filtered_df = file[(file["model"] == model) & file["dataset"].isin(datasets)]
    df = filtered_df.groupby(['dataset', 'param_index'])[metric].mean().reset_index()
    df['rank'] = df.groupby('dataset')[metric].rank(ascending=False, method="min")
    return df



def get_mean_metric_dataset_max_params_max_ds(file: pd.DataFrame, model: str, metric: str, number_datasets: int, number_params: int) -> pd.DataFrame:
    """ function like get_mean_metric_dataset for tests - outputs a smaller dataframe of number_datasets first datasets and number_params first params. 
    """
    datasets = get_datasets_all_indexes(file, model)
    all_param_indexes = list(file[(file["model"] == model)]['param_index'].unique())
    filtered_df = file[(file["model"] == model) & file["dataset"].isin(datasets[:number_datasets]) & file["param_index"].isin(all_param_indexes[:number_params])]
    df = filtered_df.groupby(['dataset', 'param_index'])[metric].mean().reset_index()
    df['rank'] = df.groupby('dataset')[metric].rank(ascending=False, method = "min")
    return df

def performence(df: pd.DataFrame, new_param: int, previous_params: list[int]) -> np.float64:
    """ Outputs the sum of minimum ranks for each dataset from previous and new params
        Defined in 2015 IEEE International Conference on Data Mining - Sequential Model-free Hyperparameter Tuning.
    """
    df_chosen_params = df[df["param_index"].isin(previous_params + [new_param])].copy()
    min_ranks = df_chosen_params.groupby('dataset')['rank'].min().reset_index()
    return min_ranks["rank"].sum()

def CANE_optimal_sequence(file: pd.DataFrame, T: int) -> list[int]:
    """ Outputs T best paramters optimizing for ranks inside each dataset.
    If optimal ranks are reached before T parameters have been chosen, then stops.
    Defined in 2015 IEEE International Conference on Data Mining - Sequential Model-free Hyperparameter Tuning.
    """
    previous_params = []
    all_param_indexes = [int(param) for param in file["param_index"].unique()]
    for j in range(T):
        performences = [performence(file, param, previous_params) for param in all_param_indexes]
        previous_params.append(all_param_indexes[performences.index(min(performences))])
        if performence(file, previous_params[0], previous_params) == len(file["dataset"].unique()):
            break
    return previous_params

def ASMFO(file: pd.DataFrame, T: int) -> list[int]:
    """Outputs T best paramters optimizing for ranks inside each dataset. 
    If optimal ranks are reached before T parameters have been chosen, 
    then reruns the CANE optimal sequence whithout the previously chosen hyperparameter configurations.
    Defined in 2015 IEEE International Conference on Data Mining - Sequential Model-free Hyperparameter Tuning.
    """
    params_vector = []
    while T>0:
        remaining_file = file[~file['param_index'].isin(params_vector)].copy()
        remaining_file["rank"] = remaining_file.groupby("dataset")["rank"].rank(ascending=True, method="min")
        if remaining_file.empty:
            break
        params_vector_new = CANE_optimal_sequence(remaining_file, T)
        T -= len(params_vector_new)
        params_vector.extend(params_vector_new)
    return params_vector

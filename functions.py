import numpy as np
import pandas as pd


def performence(new_param, previous_params, datasets_evaluations):
    minimum_ranks = []
    for dataset in datasets_evaluations.dataset_id.unique():
        try:
            new_rank = datasets_evaluations[
                (datasets_evaluations['dataset_id'] == dataset) & (datasets_evaluations['params'] == new_param)][
                "ranks"].to_numpy()
        except ValueError:
            new_rank = np.array([])

        previous_ranks = datasets_evaluations[
            (datasets_evaluations['dataset_id'] == dataset) & datasets_evaluations.params.isin(previous_params)][
            "ranks"].to_numpy()
        minimum_ranks.append(np.min(np.concatenate([new_rank, previous_ranks])))
    return sum(minimum_ranks)

def CANE_optimal_sequence(all_param_configs, datasets_evaluations, max_tries):
    all_param_configs = all_param_configs.copy()
    num_datasets = len(datasets_evaluations.dataset_id.unique())
    optimal_sequence = []
    for t in range(max_tries):
        param_performences = [performence(i, optimal_sequence, datasets_evaluations) for i in all_param_configs]
        min_param_index = param_performences.index(min(param_performences))
        optimal_sequence.append(all_param_configs[min_param_index])
        all_param_configs.pop(min_param_index)

        if performence(None, optimal_sequence, datasets_evaluations) == num_datasets:
            return optimal_sequence
    return optimal_sequence

def AvarageSMFO(all_param_config, datasets_evaluations, max_tries):
    param_list = list(range(len(all_param_config)))
    optimal_sequence = []
    params_set = set(param_list)
    while max_tries > 0:
        new_sequence = CANE_optimal_sequence([all_param_config[i] for i in params_set - set(optimal_sequence)], datasets_evaluations, max_tries= max_tries)
        max_tries -= len(new_sequence)
        optimal_sequence += [index for index, value in enumerate(all_param_config) if value in new_sequence]
    return [all_param_config[i] for i in optimal_sequence]
from functions import *
import pandas as pd

def main():
    file = pd.read_csv("MementoML.csv")
    # Deleting the param_indexes 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, which are not present in MementoML documentation
    file = file[~file["param_index"].isin([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])]
    
    models = ['gbm', 'glmnet', 'kknn', 'randomForest']
    portofolios = []
    for model in models:
        model_auc = get_mean_metric_dataset(file=file,metric="auc", model=model )
        portofolios.append(ASMFO(file=model_auc, T=100))
    
    df = pd.DataFrame({name: col for name, col in zip(models, portofolios)})
    output_path = r"\github\hyperparameter-portfolio\portfolios.csv"
    df.to_csv(output_path, index=False)
    
if __name__ == '__main__':
    main()


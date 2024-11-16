from functions import *
import pandas as pd

def main():
    file = pd.read_csv("MementoML.csv")
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


import optuna
from transformers import RobertaForSequenceClassification, Trainer, TrainingArguments
from datasets import load_dataset
from transformers import RobertaTokenizer

# Load tokenizer and dataset
tokenizer = RobertaTokenizer.from_pretrained("cardiffnlp/twitter-roberta-base-sentiment-latest")
dataset = load_dataset('csv', data_files='your_labeled_dataset.csv')

# Tokenize dataset
def tokenize_function(examples):
    return tokenizer(examples['text'], padding="max_length", truncation=True)

tokenized_datasets = dataset.map(tokenize_function, batched=True)
train_dataset = tokenized_datasets['train'].train_test_split(test_size=0.1)['train']
val_dataset = tokenized_datasets['train'].train_test_split(test_size=0.1)['test']

# Define the objective function
def objective(trial):
    # Sample hyperparameters from trial
    learning_rate = trial.suggest_float("learning_rate", 1e-5, 5e-5, log=True)
    batch_size = trial.suggest_categorical("batch_size", [8, 16, 32])
    weight_decay = trial.suggest_float("weight_decay", 0.01, 0.3)
    
    # Define training arguments using the hyperparameters
    training_args = TrainingArguments(
        output_dir="./results",            
        evaluation_strategy="epoch",       
        learning_rate=learning_rate,       
        per_device_train_batch_size=batch_size, 
        per_device_eval_batch_size=64,     
        num_train_epochs=3,                
        weight_decay=weight_decay,         
        logging_dir="./logs",             
        logging_steps=10,                 
    )
    
    # Initialize the model and Trainer
    model = RobertaForSequenceClassification.from_pretrained(
        "cardiffnlp/twitter-roberta-base-sentiment-latest", num_labels=3
    )
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
    )
    
    # Train the model
    trainer.train()
    
    # Evaluate the model and return validation loss (metric to minimize)
    eval_result = trainer.evaluate()
    return eval_result["eval_loss"]

# Create an Optuna study object and optimize
study = optuna.create_study(direction="minimize")
study.optimize(objective, n_trials=10)

# Print the best hyperparameters
print("Best hyperparameters:", study.best_trial.params)

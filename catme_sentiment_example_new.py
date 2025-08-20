import pandas as pd
import spacy
from transformers import pipeline
from spacy.lang.en import English

# Load SpaCy model once
nlp = spacy.load("en_core_web_lg")
nlp.add_pipe('sentencizer')

# Load sentiment model once
sentiment_model = pipeline("sentiment-analysis", model="cardiffnlp/twitter-roberta-base-sentiment-latest")

def remove_name(text):
    doc = nlp(text)
    names = [ent.text for ent in doc.ents if ent.label_ == "PERSON"]
    for name in names:
        text = text.replace(name, "")
    return text

def sentence_segmenter(data_frame, text_column):
    # Use dictionary of lists to collect data during the loop for better efficiency
    new_df_dict = {
        'semester': [], 'rater_gender': [], 'rater_race': [], 'rater_international': [],
        'rater_ps': [], 'rater_sat': [], 'rater_RelConf': [], 'target_gender': [],
        'target_race': [], 'target_international': [], 'target_ps': [], 'target_sat': [],
        'target_RelConf': [], 'original_id': [], 'original_entry': [], 'split_sent': [],
        'sent_num': []
    }
    
    entry_list = data_frame[text_column].to_list()
    
    for i, entry in enumerate(entry_list):
        doc = nlp(entry)
        sentences = [sent.text.strip() for sent in doc.sents]
        
        for j, sent in enumerate(sentences):
            new_sent = remove_name(sent)
            for key, value in data_frame.iloc[i].items():
                if key in new_df_dict:
                    new_df_dict[key].append(value)
            new_df_dict['original_id'].append(i)
            new_df_dict['original_entry'].append(entry)
            new_df_dict['split_sent'].append(new_sent)
            new_df_dict['sent_num'].append(j)
    
    return pd.DataFrame(new_df_dict)

def sentiment_analysis_pipeline(data_frame, batch_size=40):
    result_list = []
    for i in range(0, len(data_frame), batch_size):
        batch_df = data_frame.iloc[i:i + batch_size]
        temp_list = batch_df['split_sent'].to_list()
        
        # Perform sentiment analysis in batches
        sentiments = sentiment_model(temp_list)
        sentiments_df = pd.DataFrame(sentiments)
        
        # Combine results and append to the result list
        combined_df = pd.concat([batch_df.reset_index(drop=True), sentiments_df], axis=1)
        result_list.append(combined_df)
    
    # Concatenate all batch results once at the end
    return pd.concat(result_list, ignore_index=True)

# Example of usage:
# Filter and segment the sentences
catme_filtered_df, _ = select_and_filter(catme_df, 'split_sent')
catme_sentence_df = sentence_segmenter(catme_filtered_df, 'split_sent')

# Perform sentiment analysis and save the result to a CSV
final_df = sentiment_analysis_pipeline(catme_sentence_df)
final_df.to_csv("catme_sentence_sentiment_optimized.csv", index=False)

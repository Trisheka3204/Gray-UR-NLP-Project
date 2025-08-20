
library(tidyverse)
library(udpipe)
library(topicmodels)
library(tidytext)
library(ldatuning)
library(ggraph)
library(widyr)
library(tm)
library(quanteda)



wd_path <- 'G:/Shared drives/Working Group - NLP in Engineering Education Research/Fall 2021 Independent Study/data'
setwd(wd_path)
list.files()

# 
# ijee_df <- read_csv("scopus_ijee_brief_20200806.csv")
# 
# filtered_ijee_df <- ijee_df %>% filter(Abstract != "[No abstract available]") %>% 
#   filter(!is.na(References))
# 
# 
# test_df <- filtered_ijee_df %>% mutate_all(funs(str_replace_all(., ";", "***")))
# test_df %>% view()
# 
# write_csv(test_df, "scopus_ijee_filtered_mod_20200806.csv")
# 
# write_csv(filtered_ijee_df, "scopus_ijee_filtered_20200806.csv")
# 
# 
# ijee_df <- read_csv("scopus_ijee_filtered_20200806.csv")
# 
# 
# 
# ijee_df %>% filter(`Cited by` > 20)
# 
# ijee_30cites_df <- read_csv("PoPCites_IJEE - top 30 citations--EG.csv")
# 
# ijee_30cites_df <- ijee_30cites_df %>% mutate(Abstract = str_to_lower(Abstract))
# 


#sw <- stopwords(kind = "en")
stop_words %>% view()

sw_tidytext <- stop_words$word

#sw_quanteda <- quanteda::stopwords(language = "en", source = "snowball")
# 
# hand_curated_words <- c("tion", "ment", "line", "that we", "pbsl", "engineering", "students",
#                         "design", "learning", "education", "paper", "based", "student", "development",
#                         "teaching", "research", "results", "project", "study", "approach",
#                         "show that", "indicate that", "in which", "this we", "suggest that",
#                         "North Carolina State University")
# 
# 
# # for the top 30 citations
# cleaned_abstracts <- removeWords(ijee_30cites_df$Abstract, hand_curated_words)
# 
# 
# ijee_30cites_df$cleaned_abstracts <- cleaned_abstracts
# 
# 
# 

# 
# ### joining ijee dataframes
# ijee_df <- ijee_df %>% mutate(Title = str_to_lower(Title))
# ijee_30cites_df <- ijee_30cites_df %>% mutate(Title = str_to_lower(Title))
# ijee_30cites_df <- ijee_30cites_df %>% 
#   mutate(abs_token_n = ntoken(Abstract))
# 
# top_30cites_titles <- ijee_30cites_df$Title
# 
# test_filter <- ijee_df %>% filter(Title %in% top_30cites_titles)
# 
# missing_pubs <- ijee_30cites_df %>% anti_join(test_filter, by = "Title")
# missing_pubs %>% view()

# 
# missing_pub_titles <- missing_pubs$Title
# ijee_df %>% filter(Title %in% missing_pub_titles)
# 
# test_filter %>% write_csv("top30cites_scopus_joined_20200827.csv")
# 
# missing_pubs %>% write_csv("top30cites_missing_in_scopus_20200827.csv")
# 
# 
# 
# ijee_joined_df <- read_csv("top30cites_scopus_joined_20200827.csv")


# 
# str_sq
# ### Cleaning dataset separators to replace , with *** ----
# str_replace
# ijee_joined_df <- ijee_joined_df %>%  
#   mutate(Authors = str_replace_all(Authors, pattern = ",", replacement = "***")) %>%
#   mutate(Affiliations = str_replace_all(Affiliations, pattern = ";", replacement = "***")) %>%
#   mutate(References = str_replace_all(References, pattern = ";", replacement = "***")) %>%
#   mutate(`Author Keywords` = str_replace_all(`Author Keywords`, pattern = ";", replacement = "***")) %>% 
#   mutate(`Index Keywords` = str_replace_all(`Index Keywords`, pattern = ";", replacement = "***")) 
# 
# 
# ijee_joined_df %>% write_csv("top30cites_scopus_joined_cleaned_20201002.csv")

#old upload
#ijee_joined_df <- read_csv("top30cites_scopus_joined_cleaned_20201002.csv")


# new version of upload for top articles with at least 30 citations 20201008
# ijee_joined_df <- read_csv("ak_r_top30cites_scopus_joined_cleaned_20201002.csv")

#removeW

# for the top 30 citation articles
# cleaned_abstracts <- removeWords(ijee_joined_df$Abstract, hand_curated_words)
# 
# ijee_joined_df$cleaned_abstracts <- cleaned_abstracts








hand_curated_words <- c("tion", "ment", "line", "that we", "pbsl", "engineering", "students",
                        "design", "learning", "education", "paper", "based", "student", "students", "development",
                        "teaching", "research", "results", "project", "study", "approach",
                        "show that", "indicate that", "in which", "TEMPUS", "Tempus", "publications", "TEMPUS", 
                        "Publications", "Publication", "State University",
                        "this we", "suggest that", "what they", "North Carolina State University", "AR",
                        "State University")


### Processing the full ijee dataset ----
# Cleaning dataset separators to replace , with *** 

# ijee_df <- ijee_df %>%  
#   mutate(Authors = str_replace_all(Authors, pattern = ",", replacement = "***")) %>%
#   mutate(Affiliations = str_replace_all(Affiliations, pattern = ";", replacement = "***")) %>%
#   mutate(References = str_replace_all(References, pattern = ";", replacement = "***")) %>%
#   mutate(`Author Keywords` = str_replace_all(`Author Keywords`, pattern = ";", replacement = "***")) %>% 
#   mutate(`Index Keywords` = str_replace_all(`Index Keywords`, pattern = ";", replacement = "***")) 


#ijee_df %>% write_csv("scopus_ijee_filtered_mod_20201029.csv")




paste0(wd_path, "/scopus_ijee_brief_20200806.csv")

ijee_df <- read_csv(paste0(wd_path, "/scopus_ijee_filtered_mod_20201029.csv"))

### remove stop words and hand curated list of words for all IJEE articles -----
# cleaned_abstracts <- removeWords(ijee_df$Abstract, hand_curated_words)
# 
# ijee_df$cleaned_abstracts <- cleaned_abstracts



# for the full dataset
cleaned_abstracts <- removeWords(ijee_df$Abstract, hand_curated_words)

cleaned_abstracts <- removeWords(cleaned_abstracts, sw_tidytext)

ijee_df$cleaned_abstracts <- cleaned_abstracts

# check to make sure removal worked
#ijee_df %>% filter(str_detect(cleaned_abstracts, "TEMPUS"))
assess_df <- ijee_df %>% 
  filter(str_detect(Abstract, "assessment|grade"))

# backup method in case removeWords didn't work
ijee_df <- ijee_df %>% 
  mutate(cleaned_abstracts = str_replace_all(cleaned_abstracts, pattern = "Tempus|Publications", replacement = "")) %>%
  mutate(cleaned_abstracts = str_replace_all(cleaned_abstracts, pattern = "TEMPUS", replacement = "")) %>%
  mutate(cleaned_abstracts = str_replace_all(cleaned_abstracts, pattern = "Publications", replacement = "")) 






### text network 

ijee_df %>% 
  separate_rows(`Author Keywords`, sep = "[***]") %>% view()
### co-occurrence of keywords

ijee_auth_kw_df <- ijee_df %>% 
  separate_rows(`Author Keywords`, sep = "[***]") %>% 
  mutate(`Author Keywords` = str_trim(`Author Keywords`)) %>% 
  mutate(`Author Keywords` = str_to_lower(`Author Keywords`)) %>% 
  add_count(`Author Keywords`, name = "n_auth_keyword")


ijee_auth_kw_df %>% select(`Author Keywords`, n_auth_keyword) %>% 
  filter(!is.na(`Author Keywords`)) %>% arrange(desc(n_auth_keyword))

# plot top words across all years (removed "ethics" )
ijee_auth_kw_df %>% 
  filter(n_auth_keyword > 1) %>% 
  filter(!is.na(`Author Keywords`)) %>% 
  distinct(`Author Keywords`, .keep_all = TRUE) %>% 
  mutate(`Author Keywords` = fct_reorder(`Author Keywords`, n_auth_keyword)) %>% 
  ggplot(aes(x = `Author Keywords`, y = n_auth_keyword)) +
  geom_col() +
  coord_flip()

# alternative method for plotting using geom_bar instead of geom_col
ijee_auth_kw_df %>% 
  filter(n_auth_keyword > 1) %>% 
  filter(!is.na(`Author Keywords`)) %>% 
  mutate(`Author Keywords` = fct_reorder(`Author Keywords`, n_auth_keyword)) %>% 
  ggplot(aes(x = `Author Keywords`)) +
  geom_bar(stat = "count") +
  coord_flip()


# plotting top words for each year
ijee_auth_kw_df %>%  
  filter(n_auth_keyword > 1) %>% 
  filter(!is.na(`Author Keywords`)) %>% 
  mutate(`Author Keywords` = fct_reorder(`Author Keywords`, n_auth_keyword)) %>% 
  ggplot(aes(x = `Author Keywords`)) +
  geom_bar(stat = "count") +
  facet_wrap(. ~ Year, scales = "free") +
  coord_flip()




ijee_auth_kw_df %>% 
  mutate(decade = case_when(Year < 2000 ~ "1990s", 
                            Year >= 2000 & Year < 2010 ~ "2000s",
                            Year >= 2010 ~ "2010s")) %>% 
  filter(n_auth_keyword > 1) %>% 
  filter(!is.na(`Author Keywords`)) %>% 
  mutate(`Author Keywords` = fct_reorder(`Author Keywords`, n_auth_keyword)) %>% 
  ggplot(aes(x = `Author Keywords`)) +
  geom_bar(stat = "count") +
  facet_grid(decade ~ ., scales = "free") +
  coord_flip()    



ijee_auth_kw_df %>% 
  filter(n_auth_keyword < 200) %>% 
  filter(n_auth_keyword > 5) %>% 
  filter(!is.na(`Author Keywords`)) %>% 
  distinct(`Author Keywords`, .keep_all = TRUE) %>% 
  mutate(`Author Keywords` = fct_reorder(`Author Keywords`, n_auth_keyword)) %>% 
  view()



ijee_auth_kw_df %>% 
  mutate(decade = case_when(Year < 2000 ~ "1990s", 
                            Year >= 2000 & Year < 2010 ~ "2000s",
                            Year >= 2010 ~ "2010s")) %>% 
  group_by(decade) %>% 
  add_count(`Author Keywords`, name = "n_dec_auth_kw") %>% 
  filter(n_auth_keyword > 1) %>% 
  filter(!is.na(`Author Keywords`)) %>% 
  mutate(decade = as.factor(decade),
         `Author Keywords` = reorder_within(`Author Keywords`, n_dec_auth_kw, decade, sep = "___")) %>% 
  distinct(`Author Keywords`, .keep_all = TRUE) %>% 
  group_by(decade) %>% 
  top_n(20, wt = n_dec_auth_kw) %>%
  ungroup() %>% 
  separate(`Author Keywords`, sep = "___", into = "auth_kw", remove = FALSE) %>% 
  ggplot(aes(x = `Author Keywords`, y = n_dec_auth_kw)) +
  geom_col() +
  facet_grid(decade ~ ., scales = "free") +
  coord_flip() +
  scale_x_reordered() + 
  labs(x = "Term Count",
       y = "Author Keyword",
       title = "Author Keyword Counts by Decade") +
  theme(plot.title = element_text(hjust=0.5))








### text network of keywords ---

auth_kw_correlations <- ijee_auth_kw_df %>% 
  filter(!is.na(`Author Keywords`)) %>% 
  filter(n_auth_keyword > 1) %>% 
  pairwise_cor(`Author Keywords`, Title, sort = TRUE)



auth_kw_correlations %>% 
  head(200) %>% 
  ggraph(layout = "fr") +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), repel = TRUE)








## Topic modeling ----


### Using udpipe for phrase topic modeling ---- 

# old version
#ijee_topic_df <- ijee_30cites_df

#alternate version
ijee_topic_df <- ijee_joined_df


# for the full dataset (and not just top 30 citations)
ijee_topic_df <- ijee_df

ijee_topic_df <- ijee_topic_df %>% rowid_to_column("doc_id")


names(ijee_topic_df)
#jee_df_abs <- filtered_jee_df %>% select(doc_id, Title, Abstract, Year)


ud_model <- udpipe_download_model(language = "english")

ud_model <- udpipe_load_model(ud_model$file_model)

ijee_ann <- udpipe_annotate(ud_model, x = ijee_topic_df$cleaned_abstracts, doc_id = ijee_topic_df$doc_id)

ijee_ann_df <- as_tibble(ijee_ann)

#str(jee_ann)

#str(jee_ann_df)

ijee_ann_df$topic_level_id <- unique_identifier(ijee_ann_df, fields = c("doc_id", "paragraph_id", "sentence_id"))





## utility code from udpipe vignette (https://cran.r-project.org/web/packages/udpipe/vignettes/udpipe-usecase-topicmodelling.html#include_keywords_in_topic_models)


## Find keywords with RAKE  (could also use keywords_phrases or keywords_collocation)
keyw_rake <- keywords_rake(ijee_ann_df, 
                           term = "token", group = c("doc_id", "paragraph_id", "sentence_id"), 
                           relevant = ijee_ann_df$upos %in% c("NOUN", "ADJ"), 
                           ngram_max = 4, n_min = 5)

## Find simple noun phrases
ijee_ann_df$phrase_tag <- as_phrasemachine(ijee_ann_df$upos, type = "upos")
keyw_nounphrases <- keywords_phrases(ijee_ann_df$phrase_tag, term = ijee_ann_df$token, 
                                     pattern = "(A|N)*N(P+D*(A|N)*N)*", is_regex = TRUE, 
                                     detailed = FALSE)
keyw_nounphrases <- subset(keyw_nounphrases, ngram > 1)

## Recode terms to keywords
ijee_ann_df$term <- ijee_ann_df$token
ijee_ann_df$term <- txt_recode_ngram(ijee_ann_df$term, 
                                     compound = keyw_rake$keyword, ngram = keyw_rake$ngram)
ijee_ann_df$term <- txt_recode_ngram(ijee_ann_df$term, 
                                     compound = keyw_nounphrases$keyword, ngram = keyw_nounphrases$ngram)

## Keep keyword or just plain nouns
ijee_ann_df$term <- ifelse(ijee_ann_df$upos %in% "NOUN", ijee_ann_df$term,
                           ifelse(ijee_ann_df$term %in% c(keyw_rake$keyword, keyw_nounphrases$keyword), ijee_ann_df$term, NA))

## Build document/term/matrix
dtm <- document_term_frequencies(ijee_ann_df, document = "topic_level_id", term = "term")
dtm <- document_term_matrix(x = dtm)
dtm <- dtm_remove_lowfreq(dtm, minfreq = 4)





m <- LDA(dtm, k = 14, method = "Gibbs", 
         control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))






# summarize the topics

topicterminology <- predict(m, type = "terms", min_posterior = 0.10, min_terms = 10)
#topicterminology




#try to combine all topic dataframes in topicterminology dataframe to one large dataframe

topic_df <- bind_rows(topicterminology, .id = "column_label")
#topic_df %>% view()

topic_df %>% 
  mutate(term = reorder_within(term, prob, column_label)) %>% 
  ggplot(aes(x = term, y = prob, fill = column_label)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(.~ column_label, scales = "free") +
  coord_flip() +
  scale_x_reordered() +
  labs(x = "Phrase",
       y = "Probability",
       title = "Topic Model for IJEE Papers") +
  theme(plot.title = element_text(hjust = 0.5))



### 



### try using ldatuning to identify topic number ---

result_ldatune <- FindTopicsNumber(
  dtm,
  topics = seq(from = 2, to = 30, by = 1),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(seed = 77),
  mc.cores = 2L,
  verbose = TRUE
)


FindTopicsNumber_plot(result_ldatune)

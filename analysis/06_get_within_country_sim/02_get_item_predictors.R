# get item predictors into single file

library(here)
library(tidyverse)
library(janitor)

OUTPATH <- here("data/raw/predictors/within_item_predictors.csv")
SEMANTIC_CAT_PATH <- here("data/raw/google_categories_coded.csv")
CONC_PATH <- "/Users/mollylewis/Documents/research/Projects/1_in_progress/sense-adjectives/data/brysbaert_concreteness.csv"
AOA_PATH <- "/Users/mollylewis/Documents/research/Projects/1_in_progress/sense-adjectives/data/AoA_ratings_Kuperman_et_al_BRM.csv"
FREQ_PATH <- "/Users/mollylewis/Documents/research/Projects/1_in_progress/L2ETS/analyses/05_syntax_control/data/SUBTLEX-US\ frequency\ list\ with\ PoS\ information\ text\ version.txt"
EMOT_PATH <- "/Users/mollylewis/Documents/research/Projects/1_in_progress/WCBC_GENDER/data/raw/other_norms/BRM-emot-submit.csv"
SENS_PATH <- "/Users/mollylewis/Documents/research/Projects/1_in_progress/sense-adjectives/data/Lancaster_sensorimotor_norms_for_39707_words.csv"

semantic_cat <- read_csv(SEMANTIC_CAT_PATH) %>%
  rename(item = google_category_name) %>%
  filter(exclude == 0) %>%
  select(item, category)

conc <- read_csv(CONC_PATH) %>%
  clean_names() %>%
  select(word, conc_m) %>%
  rename(item = word)

aoa <- read_csv(AOA_PATH) %>%
  clean_names() %>%
  select(word, rating_mean) %>%
  rename(item = word,
         aoa = rating_mean)

freq <- read_tsv(FREQ_PATH) %>%
  clean_names() %>%
  select(word, lg10wf) %>%
  rename(item = word,
         log_freq = lg10wf)

emotion <- read_csv(EMOT_PATH) %>%
  clean_names() %>%
  select(word, v_mean_sum, d_mean_sum, a_mean_sum) %>%
  rename(item = word,
         valence = v_mean_sum,
         dominance = d_mean_sum,
         arousal = a_mean_sum)

sensory <- read_csv(SENS_PATH) %>%
  clean_names() %>%
  select(word, auditory_mean, gustatory_mean, haptic_mean, olfactory_mean,
         visual_mean, interoceptive_mean) %>%
  mutate(word = tolower(word)) %>%
  rename(item = word,
         auditory = auditory_mean,
         gustatory = gustatory_mean,
         haptic = haptic_mean,
         olfactory = olfactory_mean,
         visual = visual_mean,
         interoceptive = interoceptive_mean)

all_norms <- semantic_cat %>%
  left_join(conc) %>%
  left_join(aoa) %>%
  left_join(freq) %>%
  left_join(emotion) %>%
  left_join(sensory)

all_norms_tidy <- all_norms %>%
  mutate(category = fct_recode(category,
                               artefact = "A",
                               body_part = "B",
                               food = "F",
                               instrument = "I",
                               structure = "K",
                               tool = "L",
                               weather = "M",
                               animal = "N",
                               shape = "S",
                               transportation = "T",
                               clothing = "W"))
write_csv(all_norms, OUTPATH)

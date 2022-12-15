library(tidyverse)
library(mclm)
library(here)
library(xml2)
theme_set(theme_minimal())

# Get files ----
corpus_directory <- here("corpus")

tei_fnames <- get_fnames(corpus_directory) %>% 
  keep_re(r"--[(?xi) / [a-z] \d\d [.]xml $ ]--")

# Create matrix ----
# 
pos_proportions <- function(pos, nt) {
  pos_mapping <- c(p_ppss = "PPSS", p_adj = "JJ", p_neg = "[*]",
                   p_adv = "RB", p_qual = "QL")
  map_dbl(pos_mapping, ~n_tokens(pos[re(.x)])/nt * 10000) %>% 
    as_tibble_row()
}
d <- as_tibble(tei_fnames) %>%
  mutate(
    xml = map(filename, read_xml),
    ns = map(xml, xml_ns),
    token_tags = map2(xml, ns, ~ find_xpath(.x, "//d1:w | //d1:mw | //d1:c", namespaces = .y)),
    word_tags = map2(xml, ns, ~ find_xpath(.x, "//d1:w", namespaces = .y)),
    mw_tags = map2(xml, ns, ~ find_xpath(.x, "//d1:mw", namespaces = .y)),
    punctuation_tags = map2(xml, ns, ~ find_xpath(.x, "//d1:c", namespaces = .y)),
    all_tokens = map(token_tags, ~ xml_text(.x) %>% tolower() %>% cleanup_spaces() %>% as_tokens()),
    words = map(word_tags, ~ xml_text(.x) %>% tolower() %>% cleanup_spaces() %>% as_tokens()),
    pos_codes = map(token_tags, function(toks) {
      most_pos <- xml_attr(toks, "type")
      mw_pos <- xml_attr(toks, "pos")
      most_pos[is.na(most_pos)] <- mw_pos[!is.na(mw_pos)]
      as_tokens(most_pos)
    }),
    bigrams = map(all_tokens, ~ paste(.x, c(.x[-1], "EOF"), sep = "|") %>% as_tokens()),
    pos_bigrams = map(pos_codes, ~ paste(.x, c(.x[-1], "EOF"), sep = "|") %>% as_tokens()),
    n_tok = map_dbl(all_tokens, n_tokens),
    ttr = map_dbl(all_tokens, n_types)/n_tok,
    p_bigr = map_dbl(bigrams, n_types) / n_tok,
    p_pobi = map_dbl(pos_bigrams, n_types) / n_tok,
    p_mw = map_dbl(mw_tags, length) / n_tok * 10000,
    p_c = map_dbl(punctuation_tags, length) / n_tok,
    word_len = map_dbl(words, ~ sum(nchar(.x))/n_tokens(.x)),
    p_nomin = map_dbl(all_tokens, ~n_tokens(.x[re("..+(tion|ment|ness|ity)$")])) / n_tok * 10000,
    p_noun = map_dbl(pos_codes, ~ n_tokens(.x[re("NN")])) / n_tok,
    sp = map2(pos_codes, n_tok, pos_proportions)) %>%
  unnest(sp) %>%
  mutate(filename = short_names(filename)) %>%
  select(filename, ttr, word_len, starts_with("p_"))

# Save matrix ----
write_tsv(d, here::here("register-analysis.tsv"))

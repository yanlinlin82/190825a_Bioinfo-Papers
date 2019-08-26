library(tidyverse)

a1 <- read_tsv("data/01_extract/pubmed_journal.txt.gz", col_types = cols("pmid" = "c"))
a2 <- read_tsv("data/01_extract/pubmed_author.txt.gz", col_types = cols("pmid" = "c"))

a <- a1 %>%
  count(journal) %>%
  arrange(desc(n)) %>%
  head(20) %>%
  inner_join(a1, by = "journal") %>%
  inner_join(a2 %>% mutate(author_count = sapply(strsplit(author, "; "), length)), by = "pmid")

g <- a %>%
  mutate(journal = gsub("of Sciences", "of\nSciences", journal)) %>%
  group_by(journal) %>%
  mutate(label_1 = ifelse(row_number() == 1, sum(author_count == 1), NA)) %>%
  mutate(label_2 = ifelse(row_number() == 1, n, NA)) %>%
  ggplot(aes(x = reorder(journal, desc(n)), y = author_count)) +
  geom_point(size = .1, position = "jitter") +
  geom_violin(aes(fill = journal), alpha = .5) +
  geom_text(aes(label = label_1, y = .7)) +
  geom_text(aes(label = label_2, y = .4)) +
  theme(axis.text.x = element_text(angle = 75, hjust = 1)) +
  guides(fill = FALSE) +
  scale_y_continuous(trans = "log10",
                     minor_breaks = FALSE,
                     breaks = c(.4,.7,1:5,10,20,50,100,200,500),
                     labels = c("# All Papers",
                                "# Papers of\nSingle Author",
                                1:5,10,20,50,100,200,500)) +
  labs(x = "Journals", y = "# Authors") +
  ggtitle("Search 'Bioinformatics' on PubMed (290903 items, on Aug 25, 2019)")
g %>% ggsave(filename = "public-author.png", width = 12, height = 8)

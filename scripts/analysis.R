library(tidyverse)

a1 <- read_tsv("data/01_extract/pubmed_journal.txt.gz", col_types = cols("pmid" = "c"))
a2 <- read_tsv("data/01_extract/pubmed_date.txt.gz", col_types = cols("pmid" = "c", "date" = "D"))
a <- a1 %>%
  inner_join(a2 %>%
               mutate(type = type %>%
                        gsub("(\\[|\\])", "", .) %>%
                        gsub("-", "_", .)) %>%
               spread(type, date),
             by = "pmid") %>%
  mutate(elapse = pubmed - received) %>%
  filter(!is.na(elapse)) %>%
  mutate(elapse_days = as.integer(elapse)) %>%
  filter(elapse_days > 0, elapse_days < 10000)

g <- a %>%
  count(journal) %>%
  arrange(desc(n)) %>%
  head(20) %>%
  inner_join(a, by = "journal") %>%
  group_by(journal) %>%
  mutate(label = ifelse(row_number() == 1, n, NA)) %>%
  ggplot(aes(x = reorder(journal, desc(n)), y = as.integer(elapse))) +
  geom_point(position = "jitter", size = .1, alpha = .5) +
  geom_violin(aes(fill = journal), alpha = .5) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(trans = "log10",
                     breaks = c(1,15,30,60,90,180,365*c(1,2,5)),
                     labels = c("# Papers", "Half Month", "1 Month", "2 Months", "3 Months",
                                "Half Year", "1 Year", "2 Years", "5 Years")) +
  guides(fill = FALSE) +
  geom_text(aes(y = 1, label = label)) +
  geom_hline(yintercept = c(90,180,365), size = .5, color = "blue", linetype = 2) +
  labs(x = "Journals", y = "Days between Received Date and Publish Date") +
  ggtitle("Search 'Bioinformatics' on PubMed (290903 items, on Aug 25, 2019)")
g %>% ggsave(filename = "public-days.png", width = 12, height = 8)

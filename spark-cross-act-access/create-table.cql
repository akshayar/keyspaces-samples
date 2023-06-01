CREATE TABLE catalog.book_awards (
  year int,
  award text,
  rank int,
  category text,
  book_title text,
  author text,
  publisher text,
  PRIMARY KEY ((year, award), category, rank)
);
CREATE TABLE journal (
  id   INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(128)    NOT NULL
);

CREATE TABLE section (
  id         INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name       VARCHAR(128)    NOT NULL,
  journal_id INT,
  FOREIGN KEY (journal_id) REFERENCES journal (id)
    ON DELETE CASCADE
);

CREATE TABLE journalPubYear (
  id                     INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  year                   INT UNSIGNED    NOT NULL,
  journal_id             INT,
  number_of_publications INT UNSIGNED    NOT NULL,
  FOREIGN KEY (journal_id) REFERENCES journal (id)
    ON DELETE CASCADE
);

CREATE TABLE author (
  id   INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(128)    NOT NULL
);

CREATE TABLE rubric (
  id   INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(128)    NOT NULL
);

CREATE TABLE publication (
  id               INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name             VARCHAR(128)    NOT NULL,
  year_of_creation INT UNSIGNED    NOT NULL,
  first_page       INT UNSIGNED    NOT NULL,
  last_page        INT UNSIGNED    NOT NULL,
  autor_id         INT,
  section_id       INT,
  rubric_id        INT,
  FOREIGN KEY (section_id) REFERENCES section (id)
    ON DELETE CASCADE,
  FOREIGN KEY (autor_id) REFERENCES author (id)
    ON DELETE CASCADE,
  FOREIGN KEY (rubric_id) REFERENCES rubric (id)
    ON DELETE CASCADE
);

#1.1
SELECT
  publication.name AS publication,
  rubric.name      AS rubric
FROM publication
  INNER JOIN rubric ON publication.rubric_id = rubric.id;

#1.2
SELECT publication.name
FROM publication
WHERE publication.year_of_creation > 2014
      AND publication.autor_id = 2;

#1.3
SELECT publication.name
FROM publication
  INNER JOIN section ON publication.section_id = section.id
WHERE section.name = 'Databases'
      OR section.name = 'DBMS';

#1.4
SELECT rubric.name
FROM rubric
WHERE rubric.id NOT IN (
  SELECT rubric.id
  FROM publication
    INNER JOIN rubric
      ON publication.rubric_id = rubric.id);

#2.1
SELECT count(journal.id) AS NumberOfJournals
FROM journal
  INNER JOIN section ON journal.id = section.journal_id
  INNER JOIN publication ON section.id = publication.section_id
WHERE publication.name = 'sql';

#3.1
CREATE PROCEDURE changeRubric(RhsPublication INT, RhsRubric INT)
  BEGIN
    IF RhsRubric NOT IN (SELECT rubric.id
                         FROM rubric)
    THEN
      SIGNAL SQLSTATE '35000'
      SET MESSAGE_TEXT = 'Db does not have such rubric';
    ELSEIF RhsPublication NOT IN (SELECT publication.id
                                  FROM publication)
      THEN
        SIGNAL SQLSTATE '25000'
        SET MESSAGE_TEXT = 'Db does not have such publication';
    ELSE
      UPDATE publication
      SET publication.rubric_id = RhsRubric
      WHERE publication.id = RhsPublication;
    END IF;
  END;

CALL changeRubric(1, 3);

#3.2
CREATE PROCEDURE changePages(RhsPublication INT, RhsFirstPage INT, RhsLastPage INT)
  BEGIN
    IF
    RhsPublication NOT IN (SELECT publication.id
                           FROM publication)
    THEN
      SIGNAL SQLSTATE '25000'
      SET MESSAGE_TEXT = 'Db does not have such publication';
    ELSE
      UPDATE publication
      SET publication.first_page = RhsFirstPage,
        publication.last_page    = RhsLastPage
      WHERE publication.id = RhsPublication;
    END IF;
  END;

CALL changePages(1, 10, 20);

#4.1
CREATE OR REPLACE VIEW Article AS
  SELECT
    publication.name       AS Article,
    journal.name           AS JournalName,
    journal.id             AS JournalNumber,
    publication.first_page AS FirstPage,
    publication.last_page  AS SecondPage
  FROM publication
    INNER JOIN section ON publication.section_id = section.id
    INNER JOIN journal ON section.journal_id = journal.id;

#4.2
CREATE OR REPLACE VIEW SectionsOfJournals AS
  SELECT
    journal.name                  AS Journal,
    section.name                  AS Section,
    count(publication.section_id) AS Articles
  FROM publication
    INNER JOIN section ON publication.section_id = section.id
    INNER JOIN journal ON section.journal_id = journal.id
  GROUP BY section_id
  ORDER BY 1 ASC;

#4.3
CREATE OR REPLACE VIEW JournalsPerYear AS
  SELECT
    journal.name,
    journalPubYear.year,
    journalPubYear.number_of_publications
  FROM journal
    INNER JOIN journalPubYear ON journal.id = journalPubYear.journal_id
  ORDER BY 1 ASC;

-- 1
CREATE TABLE movies
(
    ID        NUMBER(12) PRIMARY KEY,
    TITLE     VARCHAR2(400) NOT NULL,
    CATEGORY  VARCHAR2(50),
    YEAR      CHAR(4),
    CAST      VARCHAR2(4000),
    DIRECTOR  VARCHAR2(4000),
    STORY     VARCHAR2(4000),
    PRICE     NUMBER(5, 2),
    COVER     BLOB,
    MIME_TYPE VARCHAR2(50)
);


-- 2
INSERT INTO movies (id, title, category, year, cast, director, story, price, cover, mime_type)
SELECT d.id,
       d.title,
       d.category,
       TRIM(to_char(d.year, '9999')),
       d.cast,
       d.director,
       d.story,
       d.price,
       c.image,
       c.mime_type
FROM descriptions d
         FULL OUTER JOIN covers c on d.id = c.movie_id;


-- 3
SELECT id, title
FROM movies
WHERE cover IS NULL;


-- 4
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE cover IS NOT NULL;


-- 5
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE cover IS NULL;


-- 6
SELECT directory_name, directory_path
FROM all_directories;


-- 7
UPDATE movies
SET cover     = EMPTY_BLOB(),
    mime_type = 'image/jpeg'
WHERE id = 66;

COMMIT;


-- 8
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE id IN (65, 66);


-- 9
DECLARE
    cover_file BFILE := BFILENAME('ZSBD_DIR', 'escape.jpg');
    cover_blob BLOB;
BEGIN
    SELECT cover
    INTO cover_blob
    FROM movies
    WHERE id = 66
        FOR UPDATE;
    DBMS_LOB.FILEOPEN(cover_file, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(cover_blob, cover_file, DBMS_LOB.GETLENGTH(cover_file));
    DBMS_LOB.FILECLOSE(cover_file);
    COMMIT;
END;


-- 10
CREATE TABLE temp_covers
(
    movie_id  NUMBER(12),
    image     BFILE,
    mime_type VARCHAR2(50)
);


-- 11
INSERT INTO temp_covers
VALUES (65, BFILENAME('ZSBD_DIR', 'eagles.jpg'), 'image/jpeg');

COMMIT;


-- 12
SELECT movie_id, DBMS_LOB.GETLENGTH(image) AS filesize
FROM temp_covers;


-- 13
DECLARE
    cover_blob     blob;
    cover_file     BFILE;
    cover_mimetype VARCHAR2(50);
BEGIN
    SELECT image, mime_type
    INTO cover_file, cover_mimetype
    FROM temp_covers
    WHERE movie_id = 65;
    DBMS_LOB.FILEOPEN(cover_file, DBMS_LOB.file_readonly);
    DBMS_LOB.CREATETEMPORARY(cover_blob, TRUE);
    DBMS_LOB.LOADFROMFILE(cover_blob, cover_file, DBMS_LOB.GETLENGTH(cover_file));
    DBMS_LOB.FILECLOSE(cover_file);
    update movies
    set cover     = cover_blob,
        mime_type = cover_mimetype
    where id = 65;
    DBMS_LOB.FREETEMPORARY(cover_blob);
    COMMIT;
END;


-- 14
SELECT id, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE id IN (65, 66);


-- 15
DROP TABLE movies;
DROP TABLE temp_covers;

-- 1
CREATE TABLE dokumenty (
    id NUMBER(12) PRIMARY KEY,
    dokument CLOB
);


-- 2
DECLARE
    tmp CLOB;
BEGIN
    tmp := '';
    FOR i IN 1..10000
    LOOP
        tmp := tmp || 'Oto tekst';
    END LOOP;
    
    INSERT INTO dokumenty
    VALUES(1, tmp);
END;


-- 3a
SELECT *
FROM dokumenty;


-- 3b
SELECT UPPER(dokument)
FROM dokumenty
WHERE id = 1;


-- 3c
SELECT LENGTH(dokument)
FROM dokumenty
WHERE id = 1;


-- 3d
SELECT DBMS_LOB.GETLENGTH(dokument)
FROM dokumenty
WHERE id = 1;


-- 3e
SELECT SUBSTR(dokument, 5, 1000)
FROM dokumenty
WHERE id = 1;


-- 3f
SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5)
FROM dokumenty
WHERE id = 1;


-- 4
INSERT INTO dokumenty
VALUES (2, EMPTY_CLOB());


-- 5
INSERT INTO dokumenty
VALUES (3, NULL);

COMMIT;


-- 6
SELECT *
FROM dokumenty;

SELECT UPPER(dokument)
FROM dokumenty;

SELECT LENGTH(dokument)
FROM dokumenty;

SELECT DBMS_LOB.GETLENGTH(dokument)
FROM dokumenty;

SELECT SUBSTR(dokument, 5, 1000)
FROM dokumenty;

SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5)
FROM dokumenty;


-- 7
SELECT *
FROM all_directories;


-- 8
DECLARE
 lobd clob;
 fils BFILE := BFILENAME('ZSBD_DIR','dokument.txt');
 doffset integer := 1;
 soffset integer := 1;
 langctx integer := 0;
 warn integer := null;
BEGIN
 SELECT dokument INTO lobd FROM dokumenty
 WHERE id=2 FOR UPDATE;
 DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
 DBMS_LOB.LOADCLOBFROMFILE(lobd, fils, DBMS_LOB.LOBMAXSIZE,
    doffset, soffset, 0, langctx, warn);
 DBMS_LOB.FILECLOSE(fils);
 COMMIT;
 DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;


-- 9
UPDATE dokumenty
SET dokument = TO_CLOB(BFILENAME('ZSBD_DIR', 'dokument.txt'))
WHERE id = 3;


-- 10
SELECT *
FROM dokumenty;


-- 11
SELECT DBMS_LOB.GETLENGTH(dokument)
FROM dokumenty;


-- 12
DROP TABLE dokumenty;


-- 13
create or replace procedure CLOB_CENSOR (clob_in in out clob, text_to_replace in varchar2) as 
    temp integer := 0;
    buffer_temp varchar2(100) := '';
begin
    temp := DBMS_LOB.INSTR(clob_in, text_to_replace);
    buffer_temp := '';
    for counter in 1..length(text_to_replace)
    loop
        buffer_temp := buffer_temp || '.'; 
    end loop;
    while temp > 0
    loop
        DBMS_LOB.write(clob_in, temp, length(buffer_temp), buffer_temp);
        temp := DBMS_LOB.INSTR(clob_in, buffer_temp);
    end loop;
end CLOB_CENSOR;


-- 14
CREATE TABLE biographies AS
SELECT *
FROM ZSBD_TOOLS.BIOGRAPHIES;

declare
    lobd clob;
begin
    select bio into lobd from biographies where id = 1 for update;
    clob_censor(lobd, 'Cimrman');
end;


-- 15
drop table biographies;

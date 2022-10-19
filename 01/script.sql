-- 1
CREATE TYPE Samochod AS OBJECT
(
    marka          VARCHAR2(20),
    model          VARCHAR2(20),
    kilometry      NUMBER,
    data_produkcji DATE,
    cena           NUMBER(10, 2)
);

CREATE TABLE samochody OF Samochod;

INSERT INTO samochody
VALUES (new Samochod('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000));
INSERT INTO samochody
VALUES (new Samochod('FORD', 'MONDEO', 80000, DATE '1997-05-10', 45000));
INSERT INTO samochody
VALUES (new Samochod('MAZDA', '323', 12000, DATE '2000-09-22', 52000));

SELECT *
FROM samochody;


-- 2
CREATE TABLE wlasciciele
(
    imie     VARCHAR2(100),
    nazwisko VARCHAR2(100),
    auto     Samochod
);

INSERT INTO wlasciciele
VALUES ('JAN', 'KOWALSKI', new SAMOCHOD('FIAT', 'SEICENTO', 30000, DATE '0010-12-02', 19500));
INSERT INTO wlasciciele
VALUES ('ADAM', 'NOWAK', new SAMOCHOD('OPEL', 'ASTRA', 34000, DATE '0009-06-01', 33700));

SELECT *
FROM wlasciciele;


-- 3
ALTER TYPE Samochod
    ADD MEMBER FUNCTION wartosc
        RETURN NUMBER
        CASCADE;

CREATE OR REPLACE TYPE BODY Samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN CENA * POWER(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produkcji));
    END wartosc;
END;

SELECT s.marka, s.cena, s.wartosc()
FROM SAMOCHODY s;


-- 4
ALTER TYPE SAMOCHOD
    ADD MAP MEMBER FUNCTION compare
        RETURN NUMBER
        CASCADE;

CREATE OR REPLACE TYPE BODY Samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN CENA * POWER(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produkcji));
    END wartosc;

    MAP MEMBER FUNCTION compare RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM data_produkcji) +
               FLOOR(COALESCE(KILOMETRY, 0) / 10000);
    END compare;
END;

SELECT *
FROM SAMOCHODY s
ORDER BY VALUE(s);


-- 5
CREATE TYPE Wlasciciel AS OBJECT
(
    imie     VARCHAR2(100),
    nazwisko VARCHAR2(100)
);

ALTER TYPE Samochod
    ADD ATTRIBUTE wlasciciel_ref REF Wlasciciel
        CASCADE;

DROP TABLE wlasciciele;
CREATE TABLE wlasciciele OF Wlasciciel;

INSERT INTO wlasciciele
VALUES ('JAN', 'KOWALSKI');
INSERT INTO wlasciciele
VALUES ('ADAM', 'NOWAK');

UPDATE samochody
SET wlasciciel_ref = (SELECT REF(w)
                      FROM wlasciciele w
                      WHERE nazwisko = 'KOWALSKI')
WHERE marka = 'FIAT';

UPDATE samochody
SET wlasciciel_ref = (SELECT REF(w)
                      FROM wlasciciele w
                      WHERE nazwisko = 'NOWAK')
WHERE marka = 'FORD';

SELECT marka, DEREF(wlasciciel_ref)
FROM samochody;


-- 6
DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10
        LOOP
            moje_przedmioty(i) := 'PRZEDMIOT_' || i;
        END LOOP;
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    moje_przedmioty.TRIM(2);
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := 9;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;


-- 7
DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(20);
    ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    ksiazki(1) := 'Ksiazka 1';
    DBMS_OUTPUT.PUT_LINE('Na początek:');
    FOR i IN ksiazki.FIRST()..ksiazki.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(ksiazki(i));
        END LOOP;
    ksiazki.EXTEND(9);
    FOR i IN 2..10
        LOOP
            ksiazki(i) := 'Ksiazka ' || i;
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Rozszerzenie:');
    FOR i IN ksiazki.FIRST()..ksiazki.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(ksiazki(i));
        END LOOP;
    ksiazki.TRIM(5);
    DBMS_OUTPUT.PUT_LINE('Usuniecie:');
    FOR i IN ksiazki.FIRST()..ksiazki.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(ksiazki(i));
        END LOOP;
END;


-- 8
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.EXTEND(8);
    FOR i IN 3..10
        LOOP
            moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
        END LOOP;
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.TRIM(2);
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END LOOP;
    moi_wykladowcy.DELETE(5, 7);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST()
        LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST()
        LOOP
            IF moi_wykladowcy.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
            END IF;
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;


-- 9
DECLARE
    TYPE TMonths IS TABLE OF VARCHAR2(20);
    months TMonths := TMonths();
BEGIN
    months.extend(2);
    months(1) := 'JANUARY';
    months(2) := 'FEBRUARY';

    months.extend(4);
    months(3) := 'MARCH';
    months(4) := 'APRIL';
    months(5) := 'MAY';
    months(6) := 'JUNE';

    FOR i IN months.FIRST()..months.LAST()
        LOOP
            DBMS_OUTPUT.PUT_LINE(months(i));
        end loop;

    months.DELETE(2, 4);


    FOR i IN months.FIRST()..months.LAST()
        LOOP
            IF months.EXISTS(i) THEN
                DBMS_OUTPUT.PUT_LINE(months(i));
            END IF;
        end loop;
END;


-- 10
CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);

CREATE TYPE stypendium AS OBJECT
(
    nazwa  VARCHAR2(50),
    kraj   VARCHAR2(30),
    jezyki jezyki_obce
);

CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia
VALUES ('SOKRATES', 'FRANCJA', jezyki_obce('ANGIELSKI', 'FRANCUSKI', 'NIEMIECKI'));
INSERT INTO stypendia
VALUES ('ERASMUS', 'NIEMCY', jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI'));

SELECT *
FROM stypendia;

SELECT s.jezyki
FROM stypendia s;

UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI', 'FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);

CREATE TYPE semestr AS OBJECT
(
    numer    NUMBER,
    egzaminy lista_egzaminow
);

CREATE TABLE semestry OF semestr
    NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry
VALUES (semestr(1, lista_egzaminow('MATEMATYKA', 'LOGIKA', 'ALGEBRA')));
INSERT INTO semestry
VALUES (semestr(2, lista_egzaminow('BAZY DANYCH', 'SYSTEMY OPERACYJNE')));

SELECT s.numer, e.*
FROM semestry s,
     TABLE (s.egzaminy) e;

SELECT e.*
FROM semestry s,
     TABLE ( s.egzaminy ) e;

SELECT *
FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 1 );

INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 )
VALUES ('METODY NUMERYCZNE');

UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';

DELETE
FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer = 2 ) e
WHERE e.column_value = 'BAZY DANYCH';


-- 11
CREATE TYPE TKoszyk AS TABLE OF VARCHAR2(20);

CREATE TYPE TZakup AS OBJECT
(
    id               NUMBER,
    koszyk_produktow TKoszyk
);

CREATE TABLE zakupy OF TZakup
    NESTED TABLE koszyk_produktow STORE AS tab_koszyk;

INSERT INTO zakupy
VALUES (0, TKoszyk('A', 'B'));
INSERT INTO zakupy
VALUES (1, TKoszyk('A', 'C'));
INSERT INTO zakupy
VALUES (2, TKoszyk('B', 'C'));
INSERT INTO zakupy
VALUES (3, TKoszyk('A', 'C', 'D'));

SELECT *
FROM zakupy;

DELETE
FROM zakupy z
WHERE (SELECT COUNT(*)
       FROM TABLE (z.koszyk_produktow) k
       WHERE k.COLUMN_VALUE = 'B') > 0;

SELECT *
FROM zakupy;


-- 12
CREATE TYPE instrument AS OBJECT
(
    nazwa  VARCHAR2(20),
    dzwiek VARCHAR2(20),
    MEMBER FUNCTION graj RETURN VARCHAR2
) NOT FINAL;
CREATE TYPE BODY instrument AS
    MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN dzwiek;
    END;
END;
/
CREATE TYPE instrument_dety UNDER instrument
(
    material VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2
);
CREATE OR REPLACE TYPE BODY instrument_dety AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'dmucham: ' || dzwiek;
    END;
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN glosnosc || ':' || dzwiek;
    END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument
(
    producent VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2
);
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'stukam w klawisze: ' || dzwiek;
    END;
END;
/
DECLARE
    tamburyn  instrument            := instrument('tamburyn', 'brzdek-brzdek');
    trabka    instrument_dety       := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
    fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian', 'pingping', 'steinway');
BEGIN
    dbms_output.put_line(tamburyn.graj);
    dbms_output.put_line(trabka.graj);
    dbms_output.put_line(trabka.graj('glosno'));
    dbms_output.put_line(fortepian.graj);
END;


-- 13
CREATE TYPE istota AS OBJECT
(
    nazwa VARCHAR2(20),
    NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
)
    NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota
(
    liczba_nog NUMBER,
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
);
CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
    BEGIN
        RETURN 'upolowana ofiara: ' || ofiara;
    END;
END;
DECLARE
    KrolLew lew := lew('LEW', 4);
    -- InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
    DBMS_OUTPUT.PUT_LINE(KrolLew.poluj('antylopa'));
END;


-- 14
DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka   instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn', 'brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki', 'ding-ding', 'metalowe');
    trabka := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
    --  saksofon := instrument('saksofon','tra-taaaa');
--  saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;


-- 15
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty
VALUES (instrument('tamburyn', 'brzdek-brzdek'));
INSERT INTO instrumenty
VALUES (instrument_dety('trabka', 'tra-ta-ta', 'metalowa'));
INSERT INTO instrumenty
VALUES (instrument_klawiszowy('fortepian', 'pingping', 'steinway'));
SELECT i.nazwa, i.graj()
FROM instrumenty i;


-- 16
CREATE TABLE przedmioty1
(
    NAZWA      VARCHAR2(50),
    NAUCZYCIEL NUMBER REFERENCES PRACOWNICY (ID_PRAC)
);
INSERT INTO przedmioty1
VALUES ('BAZY DANYCH', 100);
INSERT INTO przedmioty1
VALUES ('SYSTEMY OPERACYJNE', 100);
INSERT INTO przedmioty1
VALUES ('PROGRAMOWANIE', 110);
INSERT INTO przedmioty1
VALUES ('SIECI KOMPUTEROWE', 110);
INSERT INTO przedmioty1
VALUES ('BADANIA OPERACYJNE', 120);
INSERT INTO przedmioty1
VALUES ('GRAFIKA KOMPUTEROWA', 120);
INSERT INTO przedmioty1
VALUES ('BAZY DANYCH', 130);
INSERT INTO przedmioty1
VALUES ('SYSTEMY OPERACYJNE', 140);
INSERT INTO przedmioty1
VALUES ('PROGRAMOWANIE', 140);
INSERT INTO przedmioty1
VALUES ('SIECI KOMPUTEROWE', 140);
INSERT INTO przedmioty1
VALUES ('BADANIA OPERACYJNE', 150);
INSERT INTO przedmioty1
VALUES ('GRAFIKA KOMPUTEROWA', 150);
INSERT INTO przedmioty1
VALUES ('BAZY DANYCH', 160);
INSERT INTO przedmioty1
VALUES ('SYSTEMY OPERACYJNE', 160);
INSERT INTO przedmioty1
VALUES ('PROGRAMOWANIE', 170);
INSERT INTO przedmioty1
VALUES ('SIECI KOMPUTEROWE', 180);
INSERT INTO przedmioty1
VALUES ('BADANIA OPERACYJNE', 180);
INSERT INTO przedmioty1
VALUES ('GRAFIKA KOMPUTEROWA', 190);
INSERT INTO przedmioty1
VALUES ('GRAFIKA KOMPUTEROWA', 200);
INSERT INTO przedmioty1
VALUES ('GRAFIKA KOMPUTEROWA', 210);
INSERT INTO przedmioty1
VALUES ('PROGRAMOWANIE', 220);
INSERT INTO przedmioty1
VALUES ('SIECI KOMPUTEROWE', 220);
INSERT INTO przedmioty1
VALUES ('BADANIA OPERACYJNE', 230);


-- 17
CREATE TYPE ZESPOL AS OBJECT
(
    ID_ZESP NUMBER,
    NAZWA   VARCHAR2(50),
    ADRES   VARCHAR2(100)
);


-- 18
CREATE OR REPLACE VIEW ZESPOLY_V
            OF ZESPOL
                WITH OBJECT IDENTIFIER (ID_ZESP)
AS
SELECT ID_ZESP, NAZWA, ADRES
FROM ZESPOLY;


-- 19
CREATE TYPE PRZEDMIOTY_TAB AS TABLE OF VARCHAR2(100);
/
CREATE TYPE PRACOWNIK AS OBJECT
(
    ID_PRAC       NUMBER,
    NAZWISKO      VARCHAR2(30),
    ETAT          VARCHAR2(20),
    ZATRUDNIONY   DATE,
    PLACA_POD     NUMBER(10, 2),
    MIEJSCE_PRACY REF ZESPOL,
    PRZEDMIOTY    PRZEDMIOTY_TAB,
    MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY PRACOWNIK AS
    MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER IS
    BEGIN
        RETURN PRZEDMIOTY.COUNT();
    END ILE_PRZEDMIOTOW;
END;


-- 20
CREATE OR REPLACE VIEW PRACOWNICY_V
            OF PRACOWNIK
                WITH OBJECT IDENTIFIER (ID_PRAC)
AS
SELECT ID_PRAC,
       NAZWISKO,
       ETAT,
       ZATRUDNIONY,
       PLACA_POD,
       MAKE_REF(ZESPOLY_V, ID_ZESP),
       CAST(MULTISET(SELECT NAZWA FROM PRZEDMIOTY1 WHERE NAUCZYCIEL = P.ID_PRAC) AS
           PRZEDMIOTY_TAB)
FROM PRACOWNICY P;


-- 21
SELECT *
FROM PRACOWNICY_V;
SELECT P.NAZWISKO, P.ETAT, P.MIEJSCE_PRACY.NAZWA
FROM PRACOWNICY_V P;
SELECT P.NAZWISKO, P.ILE_PRZEDMIOTOW()
FROM PRACOWNICY_V P;
SELECT *
FROM TABLE ( SELECT PRZEDMIOTY FROM PRACOWNICY_V WHERE NAZWISKO = 'WEGLARZ' );
SELECT NAZWISKO,
       CURSOR (SELECT PRZEDMIOTY
               FROM PRACOWNICY_V
               WHERE ID_PRAC = P.ID_PRAC)
FROM PRACOWNICY_V P;


-- 22
CREATE TABLE PISARZE
(
    ID_PISARZA NUMBER PRIMARY KEY,
    NAZWISKO   VARCHAR2(20),
    DATA_UR    DATE
);
CREATE TABLE KSIAZKI
(
    ID_KSIAZKI   NUMBER PRIMARY KEY,
    ID_PISARZA   NUMBER NOT NULL REFERENCES PISARZE,
    TYTUL        VARCHAR2(50),
    DATA_WYDANIE DATE
);
INSERT INTO PISARZE
VALUES (10, 'SIENKIEWICZ', DATE '1880-01-01');
INSERT INTO PISARZE
VALUES (20, 'PRUS', DATE '1890-04-12');
INSERT INTO PISARZE
VALUES (30, 'ZEROMSKI', DATE '1899-09-11');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIE)
VALUES (10, 10, 'OGNIEM I MIECZEM', DATE '1990-01-05');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIE)
VALUES (20, 10, 'POTOP', DATE '1975-12-09');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIE)
VALUES (30, 10, 'PAN WOLODYJOWSKI', DATE '1987-02-15');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIE)
VALUES (40, 20, 'FARAON', DATE '1948-01-21');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIE)
VALUES (50, 20, 'LALKA', DATE '1994-08-01');
INSERT INTO KSIAZKI(ID_KSIAZKI, ID_PISARZA, TYTUL, DATA_WYDANIE)
VALUES (60, 30, 'PRZEDWIOSNIE', DATE '1938-02-02');

CREATE TYPE PISARZ AS OBJECT
(
    ID_PISARZA NUMBER,
    NAZWISKO   VARCHAR2(20),
    DATA_UR    DATE,
    KSIAZEK    NUMBER,
    MEMBER FUNCTION LICZBA_KSIAZEK RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY PISARZ AS
    MEMBER FUNCTION LICZBA_KSIAZEK RETURN NUMBER IS
    BEGIN
        RETURN KSIAZEK;
    END;
END;

CREATE OR REPLACE VIEW PISARZE_V
            OF PISARZ
                WITH OBJECT IDENTIFIER (ID_PISARZA)
AS
SELECT ID_PISARZA,
       NAZWISKO,
       DATA_UR,
       (SELECT COUNT(*) FROM KSIAZKI WHERE ID_PISARZA = P.ID_PISARZA) AS KSIAZEK
FROM PISARZE P;

CREATE TYPE KSIAZKA AS OBJECT
(
    ID_KSIAZKI   NUMBER,
    AUTOR        REF PISARZ,
    TYTUL        VARCHAR2(50),
    DATA_WYDANIE DATE,
    MEMBER FUNCTION WIEK RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY KSIAZKA AS
    MEMBER FUNCTION WIEK RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_WYDANIE);
    END;
END;


CREATE OR REPLACE VIEW KSIAZKI_V
            OF KSIAZKA
                WITH OBJECT IDENTIFIER (ID_KSIAZKI)
AS
SELECT ID_KSIAZKI,
       MAKE_REF(PISARZE_V, ID_PISARZA),
       TYTUL,
       DATA_WYDANIE
FROM KSIAZKI K;

SELECT p.NAZWISKO, p.LICZBA_KSIAZEK()
FROM PISARZE_V p;
SELECT TYTUL, k.AUTOR.NAZWISKO
FROM KSIAZKI_V k;


-- 23
CREATE TYPE AUTO AS OBJECT
(
    MARKA          VARCHAR2(20),
    MODEL          VARCHAR2(20),
    KILOMETRY      NUMBER,
    DATA_PRODUKCJI DATE,
    CENA           NUMBER(10, 2),
    MEMBER FUNCTION WARTOSC RETURN NUMBER
) NOT FINAL;
CREATE OR REPLACE TYPE BODY AUTO AS
    MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        WIEK    NUMBER;
        WARTOSC NUMBER;
    BEGIN
        WIEK := ROUND(MONTHS_BETWEEN(SYSDATE, DATA_PRODUKCJI) / 12);
        WARTOSC := CENA - (WIEK * 0.1 * CENA);
        IF (WARTOSC < 0) THEN
            WARTOSC := 0;
        END IF;
        RETURN WARTOSC;
    END WARTOSC;
END;

CREATE TABLE AUTA OF AUTO;
INSERT INTO AUTA
VALUES (AUTO('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000));
INSERT INTO AUTA
VALUES (AUTO('FORD', 'MONDEO', 80000, DATE '1997-05-10', 45000));
INSERT INTO AUTA
VALUES (AUTO('MAZDA', '323', 12000, DATE '2000-09-22', 52000));

CREATE OR REPLACE TYPE auto_osobowe UNDER auto
(
    liczba_miejsc NUMBER,
    klimatyzacja NUMBER,
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_osobowe AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        bazowa_wartosc NUMBER;
    BEGIN
        bazowa_wartosc := (SELF AS AUTO).WARTOSC();
        if klimatyzacja = 1 THEN
            RETURN bazowa_wartosc * 1.5;
        end if;
        RETURN bazowa_wartosc;
    END;
END;

CREATE TYPE auto_ciezarowe UNDER auto
(
    maks_ladownosc NUMBER,
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_ciezarowe AS
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
        bazowa_wartosc NUMBER;
    BEGIN
        bazowa_wartosc := (SELF AS AUTO).WARTOSC();
        if maks_ladownosc > 10 THEN
            RETURN bazowa_wartosc * 2;
        end if;
        RETURN bazowa_wartosc;
    END;
END;

INSERT INTO AUTA
VALUES (auto_osobowe('OSOBOWE', 'KLIMA', 60000, DATE '2021-11-30', 25000, 4, 1));
INSERT INTO AUTA
VALUES (AUTO_OSOBOWE('OSOBOWE', 'BEZ KLIMY', 60000, DATE '2021-11-30', 25000, 4, 0));
INSERT INTO AUTA
VALUES (AUTO_CIEZAROWE('CIEZAROWE', '12T', 80000, DATE '2021-05-10', 45000, 12));
INSERT INTO AUTA
VALUES (AUTO_CIEZAROWE('CIEZAROWE', '8T', 80000, DATE '2021-05-10', 45000, 8));

SELECT marka, a.wartosc()
FROM auta a;

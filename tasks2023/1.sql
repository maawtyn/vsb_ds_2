-- 1.1
/*
 Nastavte zachytávání konzolového výstupu příkazem
SET SERVEROUTPUT ON nebo z menu View → Dbms Output a pak kliknout na ikonu zelené plus.
 */
SET SERVEROUTPUT ON;

-- 1.2
/*
 Ověřte funkčnost konzolového výstupu spuštěním následující anonymní procedury:
 Poznámka: Konzolový výstup chápejme pouze jako nástroj pro ladění procedur PL/SQL.
 */

BEGIN
    dbms_output.put_line('Hello World!');
END;

------------------------------------------------------------------------------------------------------

-- 2.1
/*
 Spusťte anonymní proceduru
 */
BEGIN
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES ('abc123', 'Petr', 'Novak', 'petr.novak@vsb.cz', 1, TO_DATE('1992/05/06', 'yyyy/mm/dd'));
END;

-- 2.2
/*
 Ošetřete v proceduře výjimku – v případě úspěšného/neúspěšného vložení dojde k výpisu: ’Student byl/nebyl vložen’.
 */

BEGIN
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES ('abc123', 'Petr', 'Novak', 'petr.novak@vsb.cz', 1, TO_DATE('1992/05/06', 'yyyy/mm/dd'));

    dbms_output.put_line('Student byl vlozen.');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Student nebyl vlozen.');
END;

-- 2.3
/*
 Změňte proceduru tak, aby konkrétní hodnoty uložila do lokálních proměnných stejného typu jako jsou atributy tabulky Student.
 */
DECLARE
    v_login CHAR(6);
    v_fname VARCHAR2(30);
    v_lname VARCHAR2(30);
    v_email VARCHAR2(50);
    v_grade INTEGER;
    v_date DATE;
BEGIN
    v_login := 'abc123';
    v_fname := 'Petr';
    v_lname := 'Novak';
    v_email := 'petr.novak@vsb.cz';
    v_grade := 1;
    v_date := TO_DATE('1992/05/06', 'yyyy/mm/dd');

    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, v_fname, v_lname, v_email, v_grade, v_date);

    dbms_output.put_line('Student byl vlozen.');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Student nebyl vlozen.');
END;

-- 2.4
/*
 Změňte proceduru tak, aby konkrétní hodnoty uložila do lokálních proměnných s využitím %TYPE
 */
DECLARE
    v_login Student.login%TYPE;
    v_fname Student.fname%TYPE;
    v_lname Student.lname%TYPE;
    v_email Student.email%TYPE;
    v_grade Student.grade%TYPE;
    v_date Student.date_of_birth%TYPE;
BEGIN
    v_login := 'abc123';
    v_fname := 'Petr';
    v_lname := 'Novak';
    v_email := 'petr.novak@vsb.cz';
    v_grade := 1;
    v_date := TO_DATE('1992/05/06', 'yyyy/mm/dd');

    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, v_fname, v_lname, v_email, v_grade, v_date);

    dbms_output.put_line('Student byl vlozen.');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Student nebyl vlozen.');
END;

------------------------------------------------------------------------------------------------------

-- 3.1
/*
 Napište anonymní proceduru, která načte všechny atributy studenta s loginem ’abc123’ do lokálních proměnných odpovídajícího
 datového typu. Načtené hodnoty vypište pomocí konzolového výstupu
 */
DECLARE
    v_login Student.login%TYPE;
    v_fname Student.fname%TYPE;
    v_lname Student.lname%TYPE;
    v_email Student.email%TYPE;
    v_grade Student.grade%TYPE;
    v_date Student.date_of_birth%TYPE;

BEGIN
    SELECT login, fname, lname, email, grade, date_of_birth INTO v_login, v_fname, v_lname, v_email, v_grade, v_date
    FROM Student
    WHERE login = 'abc123';

    dbms_output.put_line('login:         ' || v_login);
    dbms_output.put_line('fname:         ' || v_fname);
    dbms_output.put_line('lname:         ' || v_lname);
    dbms_output.put_line('email:         ' || v_email);
    dbms_output.put_line('grade:         ' || v_grade);
    dbms_output.put_line('date_of_birth: ' || v_date);
END;

-- 3.2
/*
 Upravte proceduru tak, aby využívala jednu lokální proměnnou typu Student%ROWTYPE
 */
DECLARE
    v_student Student%ROWTYPE;

BEGIN
    SELECT * INTO v_student
    FROM Student
    WHERE login = 'abc123';

    dbms_output.put_line('login:         ' || v_student.login);
    dbms_output.put_line('fname:         ' || v_student.fname);
    dbms_output.put_line('lname:         ' || v_student.lname);
    dbms_output.put_line('email:         ' || v_student.email);
    dbms_output.put_line('grade:         ' || v_student.grade);
    dbms_output.put_line('date_of_birth: ' || v_student.date_of_birth);
END;

-- 3.3
/*
 Ošetřete výjimky TOO_MANY_ROWS a NO_DATA_FOUND – v případě odchycení těchto výjimek vypište text:
 ’Příliš mnoho řádků’ nebo ’Nenalezen žádný záznam’
 */
DECLARE
    v_student Student%ROWTYPE;

BEGIN
    SELECT * INTO v_student
    FROM Student
    WHERE login = 'abc123';

    dbms_output.put_line('login:         ' || v_student.login);
    dbms_output.put_line('fname:         ' || v_student.fname);
    dbms_output.put_line('lname:         ' || v_student.lname);
    dbms_output.put_line('email:         ' || v_student.email);
    dbms_output.put_line('grade:         ' || v_student.grade);
    dbms_output.put_line('date_of_birth: ' || v_student.date_of_birth);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nenalezen zadny zaznam.');
    WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('Prilis mnoho radku.');
END;

-- 3.4
/*
 Upravte dotaz v proceduře tak, aby při spuštění došlo k vygenerování postupně obou výjimek, tj. vyzkoušejte si,
 že ošetření výjimek funguje dle očekávání.
 */
-- Priklad pro vyjimku NO_DATA_FOUND.
DECLARE
    v_student Student%ROWTYPE;

BEGIN
    SELECT * INTO v_student
    FROM Student
    WHERE login = 'xxx000'; -- Takovyto login nema zadny student v databazi.

    dbms_output.put_line('login:         ' || v_student.login);
    dbms_output.put_line('fname:         ' || v_student.fname);
    dbms_output.put_line('lname:         ' || v_student.lname);
    dbms_output.put_line('email:         ' || v_student.email);
    dbms_output.put_line('grade:         ' || v_student.grade);
    dbms_output.put_line('date_of_birth: ' || v_student.date_of_birth);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nenalezen zadny zaznam.');
    WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('Prilis mnoho radku.');
END;

-- Priklad pro vyjimku TOO_MANY_ROWS.
DECLARE
    v_student Student%ROWTYPE;

BEGIN
    SELECT * INTO v_student
    FROM Student
    WHERE grade = 1; -- Existuje vice studentu s rocnikem 1.

    dbms_output.put_line('login:         ' || v_student.login);
    dbms_output.put_line('fname:         ' || v_student.fname);
    dbms_output.put_line('lname:         ' || v_student.lname);
    dbms_output.put_line('email:         ' || v_student.email);
    dbms_output.put_line('grade:         ' || v_student.grade);
    dbms_output.put_line('date_of_birth: ' || v_student.date_of_birth);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nenalezen zadny zaznam.');
    WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('Prilis mnoho radku.');
END;

------------------------------------------------------------------------------------------------------
-- 4.1
/*
 Napište anonymní proceduru, která vloží dva záznamy do tabulky Student a provede COMMIT. V případě selhání jedné s operací provede ROLLBACK.
 Po úspěšném potvrzení transakce bude na konzolový výstup vypsáno ’OK’, v případě výjimky ’Chyba’
 */
BEGIN
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES ('svo001', 'Josef', 'Svoboda', 'josef.svoboda@vsb.cz', 1, TO_DATE('1993/07/02', 'yyyy/mm/dd'));

    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES ('cer001', 'Jana', 'Cerna', 'jana.cerna@vsb.cz', 2, TO_DATE('1991/12/05', 'yyyy/mm/dd'));

    COMMIT;
    dbms_output.put_line('OK');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('Chyba');
END;

-- 4.2
/*
Nasimulujte situaci, kdy při vkládání druhého studenta dojde k chybě. Ujistěte se,
správným ošetřením transakce bude obsah tabulky Student odpovídat stavu před spuštěním procedury.
 */
BEGIN
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES ('svo002', 'Josef', 'Svoboda', 'josef.svoboda@vsb.cz', 1, TO_DATE('1993/07/02', 'yyyy/mm/dd'));

    -- Napr. zopakovanim stejneho INSERT by doslo k vlozeni duplicitni hodnoty PK, coz vyvola vyjimku.
    -- Po rollback tedy nebude vlozen ani jeden student svo002.

    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES ('svo002', 'Josef', 'Svoboda', 'josef.svoboda@vsb.cz', 1, TO_DATE('1993/07/02', 'yyyy/mm/dd'));

    COMMIT;
    dbms_output.put_line('OK');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('Chyba');
END;

------------------------------------------------------------------------------------------------------

-- DU 1
/*
 Napište anonymní proceduru s proměnnými v_student, v_studentCourse, v_course a v_teacher.
 Proměnné budou typu %ROWTYPE pro odpovídající tabulky.
 Do těchto proměnných budou v proceduře nejprve nastavena smyšlená data studentů, účasti na kruzu atd.
 Následně proběhne vložení dat do odpovídajících tabulek.
 V případě úspěšného vložení bude na serverový výstup vypsáno hlášení ‘skript úspěšně dokončen’,
 jinak bude vypsáno ‘při zpracování skriptu došlo k chybě’. Veškeré operace proběhnou v rámci transakce tak,
 aby byl v případě chyby navrácen stav databáze před spuštěním anonymní procedury
 */
DECLARE
    v_student Student%ROWTYPE;
    v_studentCourse StudentCourse%ROWTYPE;
    v_course Course%ROWTYPE;
    v_teacher Teacher%ROWTYPE;

BEGIN
    v_student.login := 'chy001';
    v_student.fname := 'Jiri';
    v_student.lname := 'Chytry';
    v_student.email := 'jiri.chytry@vsb.cz';
    v_student.grade := 1;
    v_student.date_of_birth := TO_DATE('1990/03/03', 'yyyy/mm/dd');

    v_teacher.login := 'pri001';
    v_teacher.fname := 'Karel';
    v_teacher.lname := 'Prisny';
    v_teacher.department := 'Department of Computer Science';

    v_course.code := '460-ds2-022';
    v_course.name := 'Databazove Systemy II';
    v_course.capacity := 10;
    v_course.teacher_login := 'pri001';

    v_studentCourse.student_login := 'chy001';
    v_studentCourse.course_code := '460-ds2-022';
    v_studentCourse.year := 2022;

    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_student.login, v_student.fname, v_student.lname, v_student.email, v_student.grade, v_student.date_of_birth);

    INSERT INTO Teacher (login, fname, lname, department)
    VALUES (v_teacher.login, v_teacher.fname, v_teacher.lname, v_teacher.department);

    INSERT INTO Course (code, name, capacity, teacher_login)
    VALUES (v_course.code, v_course.name, v_course.capacity, v_course.teacher_login);

    INSERT INTO StudentCourse (student_login, course_code, year)
    VALUES (v_studentCourse.student_login, v_studentCourse.course_code, v_studentCourse.year);

    COMMIT;
    dbms_output.put_line('Skript uspesne dokoncen.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('Pri zpracovani skriptu doslo k chybe.');
END;

-- DU 2
/*
 Napište anonymní proceduru s proměnnými v_login1 a v_login2. Do těchto proměnných přiřaďte loginy dvou libovolných učitelů.
 Úkolem anonymní procedury bude těmto dvěma učitelům prohodit kurzy, které vyučují.
 Pro řešení úlohy bude nutné pracovat s fiktivním učitelem,
 který bude na začátku vložen do tabulky Teacher a na konci po prohození kurzů zase odstraněn.
 Všechny operace proběhnou v rámci jedné transakce. Na začátku a na konci procedury bude pro oba učitele vypsán počet předmětů.
 */
DECLARE
    v_login1 Teacher.login%TYPE := 'jor012';
    v_login2 Teacher.login%TYPE := 'per085';
¨
BEGIN
    INSERT INTO Teacher (login, fname, lname, department)
    VALUES ('tmp999', 'Temporary', 'Teacher', 'Temp');

    UPDATE Course
    SET teacher_login = 'tmp999'
    WHERE teacher_login = v_login1;

    UPDATE Course
    SET teacher_login = v_login1
    WHERE teacher_login = v_login2;

    UPDATE Course
    SET teacher_login = v_login2
    WHERE teacher_login = 'tmp999';

    DELETE FROM Teacher
    WHERE login = 'tmp999';

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
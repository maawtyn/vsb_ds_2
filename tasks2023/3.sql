-- 1.1
/*
 Vytvořte proceduru PAddStudentToCourse s parametry p_student_login, p_course_code a p_year.
 Procedura zapíše studenta s daným loginem k danému kurzu v daném roce.
 K zápisu však dojde pouze pokud není naplněna kapacita kurzu (atribut Course.capacity).
 V opačném případě procedura vypíše: ‘Kurz je již plně obsazen’.
 */
CREATE OR REPLACE PROCEDURE PAddStudentToCourse(p_student_login Student.login%TYPE, p_course_code Course.code%TYPE, p_year INT) AS
    v_capacity INT;
    v_cnt INT;
BEGIN
    SELECT capacity INTO v_capacity
    FROM Course
    WHERE code = p_course_code;

    SELECT COUNT(*) INTO v_cnt
    FROM StudentCourse
    WHERE course_code = p_course_code;

    if v_cnt < v_capacity THEN
        INSERT INTO StudentCourse (student_login, course_code, year)
        VALUES (p_student_login, p_course_code, p_year);
    ELSE
        PPrint('Kurz je jiz plne obsazen.');
    END IF;
END;


-- 1.2
/*
 Vytvořte trigger TInsertStudentCourse, který před vložením záznamu do tabulky StudentCourse zkontroluje,
 zda kurz není plně obsazen. Pokud ano, vypíše se varovné hlášení: ‘Kapacita kurzu byla překročena’.
 */

CREATE OR REPLACE TRIGGER TInsertStudentCourse BEFORE INSERT ON StudentCourse FOR EACH ROW
DECLARE
    v_capacity INT;
    v_cnt INT;
BEGIN
    SELECT capacity INTO v_capacity
    FROM Course
    WHERE code = :new.course_code;

    SELECT COUNT(*) INTO v_cnt
    FROM StudentCourse
    WHERE course_code = :new.course_code;

    IF v_cnt >= v_capacity THEN
        PPrint('Kurz je jiz plne obsazen.');
    END IF;
END;

-- 1.3
/*
 Pomocí výjimky upravte trigger TInsertStudentCourse tak, aby v případě plné obsazenosti kurzu k zápisu nedošlo.
 Tj. deklarujte výjimku EXCEPTION, kterou na příslušném místě vyvolejte příkazem RAISE.
 */
CREATE OR REPLACE TRIGGER TInsertStudentCourse BEFORE INSERT ON StudentCourse FOR EACH ROW
DECLARE
    v_capacity INT;
    v_cnt INT;
    v_capacity_exceeded EXCEPTION;
BEGIN
    SELECT capacity INTO v_capacity
    FROM Course
    WHERE code = :new.course_code;

    SELECT COUNT(*) INTO v_cnt
    FROM StudentCourse
    WHERE course_code = :new.course_code;

    IF v_cnt >= v_capacity THEN
        RAISE v_capacity_exceeded;
    END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------

-- 1.4
/*
Vytvořte funkci FAddStudent4 fungující obdobně jako funkce FAddStudent3 (viz předchozí cvičení).
Kromě návratových hodnot ’ok’ a ’error’ bude mít funkce navíc návratovou hodnotu ’full’.
Funkce tuto hodnotu vrátí v případě, že kapacita daného ročníku je již naplněna. Kapacity pro jednotlivé ročníky jsou:
1. - 20, 2. - 15, 3. -10,4. -10,5. -10.
 */

CREATE OR REPLACE FUNCTION FAddStudent4(p_fname Student.fname%TYPE, p_lname Student.lname%TYPE,
    p_email Student.email%TYPE, p_grade Student.grade%TYPE, p_dateOfBirth Student.date_of_birth%TYPE) RETURN VARCHAR AS

    v_login Student.login%TYPE;
    v_gradeCapacity INT;
    v_cnt INT;
BEGIN
    v_login := FGetLogin(p_lname);

    IF p_grade = 1 THEN
        v_gradeCapacity := 20;
    ELSIF p_grade = 2 THEN
        v_gradeCapacity := 15;
    ELSE
        v_gradeCapacity := 10;
    END IF;

    SELECT COUNT(*) INTO v_cnt
    FROM Student
    WHERE grade = p_grade;

    IF v_cnt >= v_gradeCapacity THEN
        RETURN 'full';
    END IF;

    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, p_fname, p_lname, p_email, p_grade, p_dateOfBirth);

    RETURN v_login;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'error';
END;

-- 1.5
/*
 Napište proceduru PDeleteTeacher, s parametrem p_login pro smazání užitele.
 Procedura před smazáním učitele zkontroluje, zda učitel nemá přiřazené nějaké předměty.
 Pokud ano, přiřadí tyto předměty jinému učiteli s nejmenším počtem vyučovaných předmětů.
 Poté proběhne samotné smazání učitele. Pokud žádný jiný učitel neexistuje, ke smazání učitele nedojde.
 Proceduru napište jako transakci.
 */
CREATE OR REPLACE PROCEDURE PDeleteTeacher(p_login Teacher.login%TYPE) AS
    v_teacherLogin Teacher.login%TYPE;
    v_otherTeachers INT;
    v_noOtherTeacher EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_otherTeachers
    FROM Teacher
    WHERE login <> p_login;

    IF v_otherTeachers = 0 THEN
        RETURN;
    END IF;

    SELECT Teacher.login INTO v_teacherLogin
    FROM Teacher LEFT JOIN Course ON Teacher.login = Course.teacher_login
    WHERE Teacher.login <> p_login
    GROUP BY Teacher.login
    ORDER BY COUNT(Course.code)
    FETCH FIRST 1 ROWS ONLY;

    UPDATE Course
    SET teacher_login = v_teacherLogin
    WHERE teacher_login = p_login;

    DELETE FROM Teacher
    WHERE login = p_login;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;

--------------------------------------------------------------------------------------------------------------------------------

-- 2.1
/*
 Vytvořte pomocnou funkci FLoginExists s parametrem p_login, která vrátí true právě když student s daním loginem existuje.
 */

CREATE OR REPLACE FUNCTION FLoginExists(p_login Student.login%TYPE) RETURN BOOLEAN AS
    v_cnt INT;
BEGIN
    SELECT COUNT(*) INTO v_cnt
    FROM Student
    WHERE login = p_login;

    IF v_cnt > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;

-- 2.2
/*
 Vytvořte funkci FGetNextLogin s parametrem p_lname, která bude generovat login ve formátu ‘aaa000’,
 kde ‘aaa’ představuje první tři písmena z příjmení a ‘000’ sekvenční číslo zarovnané na 3 znaky
(s případnými počátečními nulami). Funkce FGetNextLogin pomocí cyklu a pomocné funkce FLoginExists nalezne
 a vrátí neexistující login s nejnižším sekvenčním číslem.
 */

CREATE OR REPLACE FUNCTION FGetNextLogin(p_lname VARCHAR) RETURN VARCHAR AS
    v_i INT;
    v_login VARCHAR(6);
BEGIN
    v_i := 1;

    LOOP
        v_login := LOWER(SUBSTR(p_lname, 1, 3)) || LPAD(v_i, 3, '0');
        EXIT WHEN NOT FLoginExists(v_login);
        v_i := v_i + 1;
    END LOOP;

    RETURN v_login;
END;

-- 2.3
/*
 Upravte funkci FAddStudent4 (viz předchozí slide) tak, aby pro generování loginu použila FGetNextLogin.
 Ověřte generování loginu opakovaným voláním FAddStudent4 se stejným příjmením.
 */
CREATE OR REPLACE FUNCTION FAddStudent4(p_fname Student.fname%TYPE, p_lname Student.lname%TYPE,
    p_email Student.email%TYPE, p_grade Student.grade%TYPE, p_dateOfBirth Student.date_of_birth%TYPE) RETURN VARCHAR AS

    v_login Student.login%TYPE;
    v_gradeCapacity INT;
    v_cnt INT;
BEGIN
    v_login := FGetNextLogin(p_lname);

    IF p_grade = 1 THEN
        v_gradeCapacity := 20;
    ELSIF p_grade = 2 THEN
        v_gradeCapacity := 15;
    ELSE
        v_gradeCapacity := 10;
    END IF;

    SELECT COUNT(*) INTO v_cnt
    FROM Student
    WHERE grade = p_grade;

    IF v_cnt >= v_gradeCapacity THEN
        RETURN 'full';
    END IF;

    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, p_fname, p_lname, p_email, p_grade, p_dateOfBirth);

    RETURN v_login;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'error';
END;

--------------------------------------------------------------------------------------------------------------------------------

-- 3.1
/*
 Vytvořte anonymní proceduru, která za pomocí kurzoru vypíše jména a příjmení všech studentů.
 Vyzkoušejte si jak syntaxi explicitního kurzoru (OPEN, FETCH, CLOSE), tak syntaxi kurzoru FOR LOOP.
 */

-- explicitni kurzor
DECLARE
    v_fname Student.fname%TYPE;
    v_lname Student.lname%TYPE;
    CURSOR c_student IS SELECT fname, lname FROM Student;
BEGIN
    OPEN c_student;

    LOOP
        EXIT WHEN c_student%NOTFOUND;
        FETCH c_student INTO v_fname, v_lname;

        PPrint(v_fname || ' ' || v_lname);
    END LOOP;

    CLOSE c_student;
END;

-- kurzor FOR LOOP;
BEGIN
    FOR c_student IN (SELECT fname, lname FROM Student) LOOP
        PPrint(c_student.fname || ' ' || c_student.lname);
    END LOOP;
END;

-- 3.2
/*
 Vytvořte proceduru PAwardStudents s parametry p_year a p_amount, která udělí stipendium 5-ti nejlepším studentům
 dle nasbíraných bodů ze všech předmětů v daném roce. Prvnímu ze studentů bude na účet připsána celá částka p_amount,
 každému dalšímu se pak částka sníží o polovinu.
 */

CREATE OR REPLACE PROCEDURE PAwardStudents(p_year INT, p_amount NUMBER) AS
    v_i INT := 0;
    v_amount NUMBER := p_amount;
BEGIN
    FOR c_student IN (
        SELECT student_login, SUM(points) AS pts
        FROM StudentCourse
        WHERE year = p_year
        GROUP BY student_login
        ORDER BY pts DESC
    ) LOOP
        EXIT WHEN v_i >= 5;

        UPDATE Student
        SET account_balance = account_balance + v_amount
        WHERE login = c_student.student_login;

        v_amount := v_amount / 2;
        v_i := v_i + 1;
    END LOOP;
END;

-- 3.3
/*
 Vytvořte funkci FExportPointsCSV s parametrem p_year. Funkce bude vracet textový řetězec reprezentující tabulku
 s body studentů v daném ročníku. Tabulka bude formátována jako CSV (comma separated values).
 Na každém řádku bude vždy uveden login, jméno, příjmení a celkový počet bodů. Příklad výstupu:
  nov123,Jan,Novák,557
  svo321,Petr,Svoboda,457
Uvažujte jen studenty, kteří v daném roce studují alespoň jeden předmět.
 */

CREATE OR REPLACE FUNCTION FExportPointsCSV(p_year INT) RETURN VARCHAR AS
    v_ret VARCHAR(1024);
BEGIN
    v_ret := '';

    FOR c_student IN (
        SELECT Student.login, Student.fname, Student.lname, SUM(StudentCourse.points) AS pts
        FROM Student JOIN StudentCourse ON Student.login = StudentCourse.student_login
        WHERE year = p_year
        GROUP BY Student.login, Student.fname, Student.lname
        ORDER BY pts DESC
    ) LOOP
        v_ret := v_ret || c_student.login || ',' || c_student.fname || ',' || c_student.lname || ',' || c_student.pts || CHR(13) || CHR(10);
    END LOOP;

    RETURN v_ret;
END;

-- DU1
/*
 Vytvořte proceduru PMoveToNextGrade, která každému úspěšnému studentovi zvýší ročník (atribut grade) o 1
 a zapíše mu všechny volné předměty daného ročníku. U studentů posledního ročníku bude nový ročník nastaven na -1.
 Úspěšný student musí za každý zapsaný předmět ve svém ročníku získat alespoň 51 bodů. Při procházení studentů
 a zvyšování ročníku postupujte od nejvyššího po nejnižší ročník.
 */
/*
 Funkce FAllSubjectsPass s parametrem p_login, která zkontroluje,
 zda má student úspěšně ukončené všechny předměty svého ročníku. Pokud ano, funkce vrátí true, jinak false.
 */
CREATE OR REPLACE FUNCTION FAllSubjectsPass(p_login Student.login%TYPE) RETURN BOOLEAN AS
    v_grade Student.grade%TYPE;
    v_cnt INT;
BEGIN
    SELECT grade INTO v_grade
    FROM Student
    WHERE login = p_login;

    SELECT COUNT(*) INTO v_cnt
    FROM
        Course
        LEFT JOIN StudentCourse ON Course.code = StudentCourse.course_code AND StudentCourse.student_login = p_login
    WHERE grade = v_grade AND COALESCE(StudentCourse.points, 0) < 51;

    IF v_cnt > 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END;
/*
 Funkce FNextGrade s parametrem p_login, vrátí následující ročník, který se má studentovi zapsat.
 */
CREATE OR REPLACE FUNCTION FNextGrade(p_login Student.login%TYPE) RETURN INT AS
    v_currentGrade Student.grade%TYPE;
BEGIN
    SELECT grade INTO v_currentGrade
    FROM Student
    WHERE login = p_login;

    IF v_currentGrade < 5 THEN
        RETURN v_currentGrade + 1;
    ELSE
        RETURN -1;
    END IF;
END;
/*
 Procedura PSetFreeCourses s parametry p_login a p_grade, která studentovi zapíše všechny předměty daného ročníku,
 které v daném akademickém roce (atribut year) ještě mají volnou kapacitu.
 Při zjišťování obsazenosti kurzu nezapočítávejte studenty, kteří již z daného kurzu získali 51 bodů.
 Jako akademický rok uvažujte rok z aktuálního data.
 */

CREATE OR REPLACE PROCEDURE PSetFreeCourses(p_login Student.login%TYPE) AS
    v_year StudentCourse.year%TYPE;
    v_grade Student.grade%TYPE;
BEGIN
    v_year := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

    SELECT grade INTO v_grade
    FROM Student
    WHERE login = p_login;

    INSERT INTO StudentCourse(student_login, course_code, year)
    SELECT p_login, code, v_year
    FROM Course
    WHERE grade = v_grade AND (
        SELECT COUNT(*)
        FROM StudentCourse
        WHERE year = v_year AND StudentCourse.course_code = Course.code AND COALESCE(StudentCourse.points, 0) < 51
        ) < Course.capacity;
END;

CREATE OR REPLACE PROCEDURE PMoveToNextGrade AS
    v_nextGrade INT;
BEGIN
    FOR c_student IN (SELECT login FROM Student ORDER BY grade DESC) LOOP
        IF FAllSubjectsPass(c_student.login) THEN
            v_nextGrade := FNextGrade(c_student.login);

            UPDATE Student
            SET grade = v_nextGrade
            WHERE login = c_student.login;

            PSetFreeCourses(c_student.login);
        END IF;
    END LOOP;
END;

-- DU 2
/*
 Vytvořte funkci FGetCreateScript s parametrem p_tableName,
 která pro tabulku definovanou parametrem vytvoří a vrátí SQL skript pro vytvoření dané tabulky.
 Při sestavování skriptu uvažujte pouze strukturu tabulky bez klíčů a dalších integritních omezení. Data ignorujte.
 */

CREATE OR REPLACE FUNCTION FGetCreateScript(p_tableName VARCHAR2)
return VARCHAR2
as
  cursor c_columns is select * from user_tab_columns where table_name = UPPER(p_tableName) order by column_id;
  v_command VARCHAR2(1000);
begin
  v_command := 'CREATE TABLE ' || UPPER(p_tableName) || '_OLD (';
  for one_column in c_columns loop
    if c_columns%ROWCOUNT > 1 then
      v_command := v_command || ',';
    end if;
      v_command := v_command || ' ' || one_column.column_name || ' ' || one_column.data_type || '(' || one_column.data_length || ')';
  end loop;
  v_command := v_command || ')';

  return v_command;
end;
/*
 Vytvořte trigger TChangeCourseCapacity, který před aktualizací nad tabulkou Course zkontroluje,
 zda došlo ke změně kapacity kurzu a provede následující:

 - Pokud jde o snížení kapacity, trigger zkontroluje, zda počet studentů aktuálně studujících daný předmět
 (tj. mají zapsaný předmět, ale zatím nedosáhli 51 bodů) není vyšší než nová kapacita.
 Pokud ano, dojde k výjimce a aktualizace kapacity se neprovede.

 - Pokud jde o zvýšení kapacity, trigger zkontroluje, zda všichni studenti ročníku, ve kterém se předmět vyučuje,
 mají tento předmět zapsaný. Pokud ne, studentům se daný předmět přiřadí abecedně (dle jejich příjmení)
 až do naplnění kapacity.
 */
create or replace TRIGGER TChangeCourseCapacity
BEFORE UPDATE ON COURSE
FOR EACH ROW
DECLARE
  studentsCount integer;
  e_no_change exception;
BEGIN
  if (:NEW.Capacity < :OLD.Capacity) then
    select count(*) into studentsCount from studentcourse where course_code = :NEW.code and (points is null or points < 51);
    if (studentsCount > :NEW.Capacity) then
      RAISE e_no_change;
    end if;
  elsif (:NEW.Capacity > :OLD.Capacity) then
    studentsCount := :NEW.Capacity - :OLD.Capacity;
    for student in (select login from student
                    where grade = :NEW.grade
                      and login not in (select login from studentcourse
                                        where course_code = :NEW.code)
                    order by lname asc) loop
      insert into studentcourse (student_login, course_code, year, points) values (student.login, :NEW.code, EXTRACT(YEAR FROM CURRENT_TIMESTAMP), 0);
      studentsCount := studentsCount - 1;
      if (studentsCount = 0) then
        exit;
      end if;
    end loop;
  end if;
exception
   WHEN e_no_change THEN
     dbms_output.put_line('Error');
     RAISE;
END;
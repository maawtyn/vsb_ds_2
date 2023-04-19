# PL/SQL 3 (řídící konstrukce a kurzory)   

# Podmínky

Vytvořte proceduru PAddStudentToCourse s parametry p_student_login, p_course_code a p_year. Procedura zapíše studenta s daným loginem k danému kurzu v daném roce. K zápisu však dojde pouze pokud není naplněna kapacita kurzu (atribut Course.capacity). V opačném případě procedura vypíše: ‘Kurz je již plně obsazen’.

```sql
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
```

2. Vytvořte trigger TInsertStudentCourse, který před vložením záznamu do tabulky StudentCourse zkontroluje, zda kurz není plně obsazen. Pokud ano, vypíše se varovné hlášení: ‘Kapacita kurzu byla překročena’.

```sql
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
```

3. Pomocí výjimky upravte trigger TInsertStudentCourse tak, aby v případě plné obsazenosti kurzu k zápisu nedošlo. Tj. deklarujte výjimku EXCEPTION, kterou na příslušném místě vyvolejte příkazem RAISE

```sql
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
```
4. Vytvořte funkci FAddStudent4 fungující obdobně jako funkce FAddStudent3 (viz předchozí cvičení). Kromě návratových hodnot ’ok’ a ’error’ bude mít funkce navíc návratovou hodnotu ’full’. Funkce tuto hodnotu vrátí v případě, že kapacita daného ročníku je již naplněna. Kapacity pro jednotlivé ročníky jsou: 1. - 20, 2. - 15, 3. - 10, 4. - 10, 5. - 10.

```sql
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
```













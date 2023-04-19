# PL/SQL 2 (procedury, triggery)

# Uložené procedury

1. Vytvořte proceduru PAddStudent2 pro vložení nového studenta sestejnými parametry jako PAddStudent1 kromě parametru p_login. Login studenta bude sestaven automaticky z prvních tří písmen příjmení, ke kterým bude přidán řetězec ’000’. Znaky v loginu budou vždy převedeny na malá písmena.

```sql
CREATE OR REPLACE PROCEDURE PAddStudent2(p_fname Student.fname%TYPE, p_lname Student.lname%TYPE,
    p_email Student.email%TYPE, p_grade Student.grade%TYPE, p_dateOfBirth Student.date_of_birth%TYPE) AS
    
    v_login Student.login%TYPE;
BEGIN
    v_login := LOWER(SUBSTR(p_lname, 1, 3)) || '000';
    
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, p_fname, p_lname, p_email, p_grade, p_dateOfBirth);
END;
```

2. Vytvořte proceduru PAddStudent3. Procedura bude fungovat obdobně jako PAddStudent2. Login však bude sestaven tak, že k prvním třem písmenům z příjmení (převedených na malá písmena) budou přidány 3 číslice představující počet studentů (před vložením nového studenta) + 1.

```sql
CREATE OR REPLACE PROCEDURE PAddStudent3(p_fname Student.fname%TYPE, p_lname Student.lname%TYPE,
    p_email Student.email%TYPE, p_grade Student.grade%TYPE, p_dateOfBirth Student.date_of_birth%TYPE) AS
    
    v_studentCount INT;
    v_login Student.login%TYPE;
BEGIN
    SELECT COUNT(*) + 1 INTO v_studentCount
    FROM Student;

    v_login := LOWER(SUBSTR(p_lname, 1, 3)) || LPAD(v_studentCount, 3, '0');
    
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, p_fname, p_lname, p_email, p_grade, p_dateOfBirth);
END;
```

# Uložené funkce

3. Vytvořte uloženou funkci FAddStudent2, která bude fungovat obdobně jako procedura PAddStudent3. Při úspěšném vložení funkce vrátí login studenta. V případě chyby funkce vrátí ’error’.

```sql
CREATE OR REPLACE FUNCTION FAddStudent2(p_fname Student.fname%TYPE, p_lname Student.lname%TYPE,
    p_email Student.email%TYPE, p_grade Student.grade%TYPE, p_dateOfBirth Student.date_of_birth%TYPE) RETURN VARCHAR AS
    
    v_studentCount INT;
    v_login Student.login%TYPE;
BEGIN
    SELECT COUNT(*) + 1 INTO v_studentCount
    FROM Student;

    v_login := LOWER(SUBSTR(p_lname, 1, 3)) || LPAD(v_studentCount, 3, '0');
    
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, p_fname, p_lname, p_email, p_grade, p_dateOfBirth);
    
    RETURN v_login;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'error';
END;
```

4. Vytvořte uloženou funkci FGetLogin s parametrem p_lname, která vrátí login sestavený z prvních tří písmen příjmení (parametr p_lname) převedených na malá písmena přidáním aktuálního počtu studentů + 1 (tj. logika bude obdobná jako v PAddStudent3).

```sql
CREATE OR REPLACE FUNCTION FGetLogin(p_lname Student.lname%TYPE) RETURN Student.login%TYPE AS
    v_studentCount INT;
BEGIN   
    SELECT COUNT(*) + 1 INTO v_studentCount
    FROM Student;

    RETURN LOWER(SUBSTR(p_lname, 1, 3)) || LPAD(v_studentCount, 3, '0');
END;
```

5. Vytvořte uloženou funkci FAddStudent3 fungující obdobně jako funkce FAddStudent2, přičemž bude využívat funkci FGetLogin

```sql
CREATE OR REPLACE FUNCTION FAddStudent3(p_fname Student.fname%TYPE, p_lname Student.lname%TYPE,
    p_email Student.email%TYPE, p_grade Student.grade%TYPE, p_dateOfBirth Student.date_of_birth%TYPE) RETURN VARCHAR AS
    
    v_login Student.login%TYPE;
BEGIN
    v_login := FGetLogin(p_lname);
    
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, p_fname, p_lname, p_email, p_grade, p_dateOfBirth);

    RETURN v_login;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'error';
END;
```

# Triggery

Vytvořte trigger TInsertStudent, který po vložení studenta vypíše jeho login a celé jméno. Pro vyzkoušení triggeru přidejte pomocí procedury PAddStudent3 smyšleného studenta.

```sql
CREATE OR REPLACE TRIGGER TInsertStudent AFTER INSERT ON Student FOR EACH ROW
BEGIN
    PPrint(:new.login || ': ' || :new.fname || ' ' || :new.lname);
END;
```

Vytvořte trigger TDeleteStudent, který vypíše login a celé jméno studenta před jeho odstraněním. Pro vyzkoušení triggeru odstraňte studenta vloženého v předchozím bodě.

```sql
CREATE OR REPLACE TRIGGER TDeleteStudent BEFORE DELETE ON Student FOR EACH ROW
BEGIN
    PPrint(:old.login || ': ' || :old.fname || ' ' || :old.lname);
END;
```

Vytvořte trigger TUpdateStudent, který při aktualizaci studenta vypíše na obrazovku hodnoty atributů fname, lname a grade platné před a po změně. Pro vyzkoušení triggeru přeřaďte studenty ’mcc676’ a ’kow007’ jedním příkazem UPDATE do (o jedna) vyššího ročníku.

```sql
CREATE OR REPLACE TRIGGER TUpdateStudent AFTER UPDATE ON Student FOR EACH ROW
BEGIN
    PPrint('Pred zmenou: ' || :old.fname || ' ' || :old.lname || ', rocnik ' || :old.grade);
    PPrint('Po zmene:    ' || :new.fname || ' ' || :new.lname || ', rocnik ' || :new.grade);
END;

UPDATE Student
SET grade = grade + 1
WHERE login IN ('mcc676', 'kow007');
```

# Transakce v procedurach

Vytvořte proceduru StudentBecomeTeacher se dvěma parametry p_login a p_department, která přesune záznam studenta s daným loginem z tabulky Student do tabulky Teacher. Pro procvičení se vyhněte použití jakýchkoli lokálních proměnných (mimo dané vstupní parametry). Procedura bude napsána tak, aby představovala jednu transakci.

```sql
CREATE OR REPLACE PROCEDURE PStudentBecomeTeacher(p_login Student.login%TYPE,
    p_department Teacher.department%TYPE) AS

BEGIN
    INSERT INTO Teacher (login, fname, lname, department)
    SELECT login, fname, lname, p_department
    FROM Student
    WHERE login = p_login;
    
    DELETE FROM Student
    WHERE login = p_login;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
```

Vytvořte proceduru PStudentAssignment s parametry p_fname, p_lname a p_dateOfBirth. Procedura vloží nového studenta, přičemž jeho login bude vygenerován funkcí FGetLogin(), e-mail bude složen z loginu přidáním ’@vsb.cz’ a ročník bude nastaven na 1. Procedura dále zapíše studentovi všechny předměty prvního ročníku. Procedura bude řešena jako transakce

```sql
CREATE OR REPLACE PROCEDURE PStudentAssignment(p_fname Student.fname%TYPE, p_lname Student.lname%TYPE,
    p_dateOfBirth DATE) AS
    
    v_login Student.login%TYPE;
    v_email Student.email%TYPE;
    v_year StudentCourse.year%TYPE;
BEGIN
    v_login := FGetLogin(p_lname);
    v_email := v_login || '@vsb.cz';
    v_year := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    
    INSERT INTO Student (login, fname, lname, email, grade, date_of_birth)
    VALUES (v_login, p_fname, p_lname, v_email, 1, p_dateOfBirth);
    
    INSERT INTO StudentCourse (student_login, course_code, year)
    SELECT v_login, code, v_year
    FROM Course
    WHERE grade = 1;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;    
END;
```

# DU

1.1 Napište proceduru PSendEMail s parametry p_email, p_subject a p_body. Procedura bude simulovat zaslání e-mailu s obsahem p_body na adresu p_email s předmětem p_subject tím, že tyto parametry vypíše na serverový výstup.

```sql
CREATE OR REPLACE PROCEDURE PSendEMail(p_email VARCHAR2, p_subject VARCHAR2, p_body VARCHAR2) AS
BEGIN
    PPrint('-----------------------------------------------------------------------------');
    PPrint('e-mail to: ' || p_email || ', subject: ' || p_subject);
    PPrint(p_body);
    PPrint('-----------------------------------------------------------------------------');
END;
```

1.2 Napište trigger TSendEMail, který při přihlášení studenta ke kurzu studentovi zašle za pomocí procedury PSendEMail e-mail s předmětem ‘Přihlášení ke kurzu [název kurzu]’ a obsahem:
‘Vážený studente [jméno a příjmení], dne [aktuální datum a čas] jste byl přihlášen ke kurzu [kód a název kurzu]. Vyučujícím kurzu je [jméno a příjmení učitele].

```sql
CREATE OR REPLACE TRIGGER TSendEMail AFTER INSERT ON StudentCourse FOR EACH ROW
DECLARE
    v_student_fname Student.fname%TYPE;
    v_student_lname Student.lname%TYPE;
    v_student_email Student.email%TYPE;
    v_teacher_fname Teacher.fname%TYPE;
    v_teacher_lname Teacher.lname%TYPE;
    v_course_name Course.name%TYPE;
    v_subject VARCHAR2(100);
    v_body VARCHAR2(500);
BEGIN
    SELECT fname, lname, email INTO v_student_fname, v_student_lname, v_student_email
    FROM Student
    WHERE login = :new.student_login;
    
    SELECT Course.name, Teacher.fname, Teacher.lname INTO v_course_name, v_teacher_fname, v_teacher_lname
    FROM Teacher JOIN Course ON Teacher.login = Course.teacher_login
    WHERE Course.code = :new.course_code;
    
    v_subject := 'Prihlaseni ke kurzu ' || v_course_name;
    
    v_body := 'Vazeny studente ' || v_student_fname || ' ' || v_student_lname || ', dne ' || TO_CHAR(CURRENT_TIMESTAMP, 'dd.mm.yyyy hh24:mi:ss') ||
        ' jste byl prihlasen do kurzu ' || v_course_name || '. Vyucujicim kurzu je ' || v_teacher_fname ||
        ' ' || v_teacher_lname || '.';
        
    PSendEMail(v_student_email, v_subject, v_body);
END;
```

2.1 Napište funkci FGetStudentScore s parametrem p_login, která pro studenta s daným loginem vypočte a vrátí jeho skóre. Skóre bude vypočteno jako podíl všech jeho nasbíraných bodů ku bodům, které může celkově získat. Za každý předmět může student získat maximálně 100b. Předpokládejte, že studenti žádný ze zapsaných předmětů neopakovali. Skóre studenta tedy může být v nejlepším případě rovno 1.

```sql
CREATE OR REPLACE FUNCTION FGetStudentScore(p_login Student.login%TYPE) RETURN NUMBER AS
    v_ptsReceived INT;
    v_ptsTotal INT;
BEGIN
    SELECT COALESCE(SUM(points), 0), COUNT(*) * 100 INTO v_ptsReceived, v_ptsTotal
    FROM StudentCourse
    WHERE student_login = p_login;
    
    RETURN v_ptsReceived / v_ptsTotal;
END;
```

2.2 Napište proceduru PCheckStudents s parametrem p_amount, která všem studentům s nadprůměrným získaným počtem bodů ze všech předmětů přičte na účet částku p_amount a naopak všem podprůměrným studentům tuto částku odečte. Studenti, kteří budou mít po této operaci záporný stav účtu, budou vymazáni. Procedura bude napsána jako transakce.

```sql
BEGIN
    SELECT AVG(sum_points) INTO v_avgPts
    FROM
    (
        SELECT SUM(points) AS sum_points
        FROM StudentCourse
        GROUP BY student_login
    ) T;
    
    UPDATE Student
    SET account_balance = account_balance + p_amount
    WHERE
    (
        SELECT SUM(points)
        FROM StudentCourse
        WHERE StudentCourse.student_login = Student.login
    ) > v_avgPts;

    UPDATE Student
    SET account_balance = account_balance - p_amount
    WHERE
    (
        SELECT SUM(points)
        FROM StudentCourse
        WHERE StudentCourse.student_login = Student.login
    ) < v_avgPts;
    
    DELETE FROM Student
    WHERE account_balance < 0;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
```

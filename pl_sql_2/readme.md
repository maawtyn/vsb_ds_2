# PL/SQL 2 (procedury, triggery)

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

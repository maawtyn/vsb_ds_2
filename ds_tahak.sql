Proměnné v PL/SQL 

Syntaxe					Příklad
-------					-------
jmeno promenne := hodnota 		v_vek := 20
SELECT sloupec 				SELECT vek INTO v_vek
INTO jmeno promenne 			FROM student
FROM jmeno tabulky 			WHERE login LIKE ’bon007’

Operátor %TYPE: 	v_login Student.login%TYPE; ... [v_login bude stejného typu jako login tybulky Student]
Operátor %ROWTYPE:	v_student Student%ROWTYPE; ... [v_student bude obsahovat stejné proměnné a datové typy jako tabulka Student]
 
-------------------------------------------------------------------------------------------------------------
EXCEPTIONS

Syntaxe								Příklad
----------							-------
EXCEPTION							EXCEPTION
WHEN typ_exception 	[OTHERS je defaultni handling]		WHEN no_data_found
THEN reseni_exception 						THEN dbms_output.put_line('No data found!');

RAISING EXCEPTIONS

Syntaxe
----------
DECLARE 
   exception_name EXCEPTION; 
BEGIN 
   IF condition THEN 
      RAISE exception_name; 
   END IF; 
EXCEPTION 
   WHEN exception_name THEN 
   statement; 
END; 
-------------------------------------------------------------------------------------------------------------
PROCEDURES
- Anonymní procedury		[nemají jméno a nemohou být volány z jiné procedury]
- Pojmenované procedury		[obsahují hlavičku se jménem a prametry procedury - Je možno ji spouštět příkazem EXECUTE]
- Pojmenované funkce		[jsou velmi podobné procedurám akortá mají návratový type a musí vracet hodnotu]	

Struktura pojmenované procedury										Příklad
-------------------------------										--------
CREATE [OR REPLACE] PROCEDURE jmeno_procedury[(jmeno_parametru [mod] datovy_typ , . . . )] 		CREATE OR REPLACE PROCEDUR InsertEmail ( p_login VARCHAR2)
AS 													AS	
      def. lok. promennych											v_email VARCHAR2( 6 0 ) ;
BEGIN													BEGIN
	telo procedury												SELECT email INTO v_email
END														FROM Student WHERE l o g i n =p_login ;
														INSERT INTO Email VALUES( v_email ) ;
													END;

													EXECUTE InsertEmail ( ’ jan440 ’ ) ; - Proceduru je třeba později spustit 


- jména parametrů většinou píšeme s prefixem p_ abychom je odlišili od normálních parametrů
- jména lokalních proměnných většinou mají prefix v_


FUNKCE

Struktura funkce:											Příklad:
-----------------											--------
CREATE [OR REPLACE] FUNCTION jmeno_funkce								CREATE OR REPLACE FUNCTION GetStudentEmail(p_logni IN Student.login%TYPE)
[ ( jmeno_parametru [mod] datovy_typ , . . . ) ]							RETURN Student.email%TYPE
RETURN navratovy_datovy_typ										AS
AS														v_email Student.email%TYPE;
	definice lok. promennych									BEGIN	
BEGIN													SELECT INTO v_email FROM Student
	telo procedury												WHERE login = p_login;
END													RETURN v_email;
													END GetStudentEmail;

													EXECUTE dbms_output.put_line(GetStudentEmail('sob28'))

Vstupní a výstupní parametry procedury
------------------------------------
Syntaxe:												Použití:
-------													--------
CREATE OR REPLACE PROCEDURE GetStudentEmail (								DECLARE 
   p_login IN Student.login%TYPE,									  v_email Student.email%TYPE
   p_email OUT Student.email%TYPE)									BEGIN
...													  GetStudentEmail('kra22', v_email);
													  dbms_output.put_line(v_email);
													END;

-------------------------------------------------------------------------------------------------------------

TRIGGERS
- Je to blok který je spouštěn v závislosti na nějakém příkazu DML jako je INSERT, UPDATE nebo DELETE
- Obecně je možné triggery navěsit na další operaci jako DDL nebo systémové události

Syntaxe
-------
CREATE [OR REPLACE ] TRIGGER jmeno_triggeru
{BEFORE | AFTER | INSTEAD OF }
{INSERT [OR] | UPDATE [OR] | DELETE}
[OF jmeno_sloupce ]
ON jmeno_tabulky
[REFERENCING OLD AS stara_hodnota NEW AS nova_hodnota ]
[FOR EACH ROW [WHEN ( podminka ) ] ]
BEGIN
příkazy
END;

- {BEFORE | AFTER | INSTEAD OF} − This specifies when the trigger will be executed. The INSTEAD OF clause is used for creating trigger on a view.

- {INSERT [OR] | UPDATE [OR] | DELETE} − This specifies the DML operation.

- [OF col_name] − This specifies the column name that will be updated.

- [ON table_name] − This specifies the name of the table associated with the trigger.

- [REFERENCING OLD AS o NEW AS n] − This allows you to refer new and old values for various DML statements, such as INSERT, UPDATE, and DELETE.

- [FOR EACH ROW] − This specifies a row-level trigger, i.e., the trigger will be executed for each row being affected. Otherwise the trigger will execute just once when the SQL statement is executed, which is called a table level trigger.

- WHEN (condition) − This provides a condition for rows for which the trigger would fire. This clause is valid only for row-level triggers.

Příklad:
--------
CREATE OR REPLACE TRIGGER display_salary_changes 
BEFORE DELETE OR INSERT OR UPDATE ON customers 
FOR EACH ROW 
WHEN (NEW.ID > 0) 
DECLARE 
   sal_diff number; 
BEGIN 
   sal_diff := :NEW.salary  - :OLD.salary; 
   dbms_output.put_line('Old salary: ' || :OLD.salary); 
   dbms_output.put_line('New salary: ' || :NEW.salary); 
   dbms_output.put_line('Salary difference: ' || sal_diff); 
END; 

- Tenhle trigger se teda aktivuje když budeme vkládat nový záznam nebo upravovat už existující záznam a napíše nám old a new salary


Příklad:
--------
CREATE OR REPLACE TRIGGER t
  BEFORE
    INSERT OR
    UPDATE OF salary, department_id OR
    DELETE
  ON employees
BEGIN
  CASE
    WHEN INSERTING THEN
      DBMS_OUTPUT.PUT_LINE('Inserting');
    WHEN UPDATING('salary') THEN
      DBMS_OUTPUT.PUT_LINE('Updating salary');
    WHEN UPDATING('department_id') THEN
      DBMS_OUTPUT.PUT_LINE('Updating department ID');
    WHEN DELETING THEN
      DBMS_OUTPUT.PUT_LINE('Deleting');
  END CASE;
END;
-------------------------------------------------------------------------------------------------------------

VĚTVENÍ 

IF podminka1 THEN
príkazy
[ELSIF podminka2 THEN príkazy ]
[ELSE príkazy]
END IF;

-------------------------------------------------------------------------------------------------------------

CYKLY 

- První druh cyklu se ukončuje pomocí klíčového slova EXIT 

Syntaxe cyklu s podmínkou na konci:
-----------------------------------
LOOP
   prikazy cyklu
   [EXIT; | EXIT WHEN podminky; ]
END LOOP;

DECLARE
 v_i i n t := 0;
BEGIN
 LOOP
    DBMS_OUTPUT. PUT_LINE ( ’ v_i : ’ | | v_i ) ;
    EXIT WHEN v_i >= 5;
    v_i := v_i + 1;
  END LOOP;
END;
-----------------------------------

- Druhý typ cyklu je cyklus s podmínkou na začátku:

Syntaxe cyklu s podmínkou na začátku: 
-------------------------------------
WHILE podminka LOOP
    prikazy cyklu
END LOOP;

DECLARE
  v_i i n t := 0;
BEGIN
  WHILE v_i < 6 LOOP
    DBMS_OUTPUT. PUT_LINE ( ’ v_i : ’ | | v_i ) ;
    v_i := v_i + 1;
  END LOOP;
END;
-------------------------------------

- Třetí a poslední typ cyklu je cyklus FOR, kde předem známe počet iterací
- Proměnná value1 představuje váchozí hodnotu proměnné jmeno_promenne a value2 koncovou hodnotu

FOR jmeno_promenne IN [REVERSE] value1 .. value2
LOOP
príkazy cyklu
END LOOP;


DECLARE
  v_i i n t ;
BEGIN
  FOR v_i IN 0 . . 5
  LOOP
    DBMS_OUTPUT.PUT( v_i ) ;
    IF v_i <> 5 THEN
      DBMS_OUTPUT.PUT( ’ , ’ ) ;
    END IF ;
  END LOOP;
  DBMS_OUTPUT.NEW_LINE ( ) ;
END;
-------------------------------------------------------------------------------------------------------------


KURZORY - https://dbedu.cs.vsb.cz/files/2022-2023/DS2/ds2-4.pdf

Dva typy kurzorů:
- Implicitní kurzor - vytváří se automaticky po provedení příkazů jako INSERT, DELETE nebo UPDATE
- Explicitní kurzor - definuje se již v definiční části procedury podobně jako proměnná

EXPLICITNÍ KURZOR
-----------------
DECLARE
  CURSOR c_emp IS SELECT * FROM employees;
BEGIN
  -- code to manipulate the cursor data goes here
END;


DECLARE
  CURSOR c_emp IS SELECT * FROM employees;
  emp_record employees%ROWTYPE;
BEGIN
  OPEN c_emp;
  LOOP
    FETCH c_emp INTO emp_record;
    EXIT WHEN c_emp%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Employee ' || emp_record.employee_id || ': ' || emp_record.first_name || ' ' || emp_record.last_name);
  END LOOP;
  CLOSE c_emp;
END;

- V novějších verzích oracle je doporučeno použíca
DECLARE
  CURSOR c_surname IS SELECT surname FROM Student ;
  v_surname Student . surname%TYPE;
  v_tmp NUMBER := 0;
BEGIN
  FOR one_surname IN c_surname LOOP
    v_tmp := c_surname%ROWCOUNT;
    v_surname := one_surname . surname ;
    DBMS_OUTPUT. PUT_LINE( v_tmp | | ’ ’ | | v_surname ) ;
  END LOOP;
END;
-------------------------------------------------------------------------------------------------------------

COALESCE - vrátí první nenulovou hodnotu z počtu proměnných 

příklad: 
-------
    SELECT COALESCE(SUM(kusu), 0) INTO v_kusu
    FROM Sklad
    WHERE zID = p_zID AND pID = p_pID1;

COALESCE tady dá nulu do v_kusu pokud se stane že SUM(kusu) bude NULL
-------------------------------------------------------------------------------------------------------------



https://dbedu.cs.vsb.cz/cs/Files/GetFiles/2022-2023/DS2/ds2-6.pdf - Transakce 

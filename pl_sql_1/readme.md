# Úkol 1: Úvodní kroky

1. Nastavte zachytávání konzolového výstupu příkazem
SET SERVEROUTPUT ON nebo z menu View → Dbms Output a pak
kliknout na ikonu zelené plus.

2. Ověřte funkčnost konzolového výstupu spuštěním následující
anonymní procedury:
BEGIN
dbms_output.put_line(’Hello World!’);
END;
Poznámka: Konzolový výstup chápejme pouze jako nástroj pro ladění
procedur PL/SQL.

# Úkol 2: Proměnné, výjimky
1. Spusťte anonymní proceduru:
BEGIN
INSERT INTO Student (login, fname, lname, email,
grade, date_of_birth)
VALUES (’abc123’, ’Petr’, ’Novak’, ’petr.novak@vsb.cz’,
1, TO_DATE(’1992/05/06’, ’yyyy/mm/dd’));
END;

2. Ošetřete v proceduře výjimku – v případě úspěšného/neúspěšného
vložení dojde k výpisu: ’Student byl/nebyl vložen’.

3. Změňte proceduru tak, aby konkrétní hodnoty uložila do lokálních
proměnných stejného typu jako jsou atributy tabulky Student.

4. Změňte proceduru tak, aby konkrétní hodnoty uložila do lokálních
proměnných s využitím %TYPE.

# Úkol 3: Proměnné, výjimky
1. Napište anonymní proceduru, která načte všechny atributy studenta
s loginem ’abc123’ do lokálních proměnných odpovídajícího datového
typu. Načtené hodnoty vypište pomocí konzolového výstupu.

2. Upravte proceduru tak, aby využívala jednu lokální proměnnou typu
Student%ROWTYPE.

3. Ošetřete výjimky TOO_MANY_ROWS a NO_DATA_FOUND – v případě
odchycení těchto výjimek vypište text: ’Příliš mnoho řádků’ nebo
’Nenalezen žádný záznam’.

4. Upravte dotaz v proceduře tak, aby při spuštění došlo k vygenerování
postupně obou výjimek, tj. vyzkoušejte si, že ošetření výjimek
funguje dle očekávání.

# Úkol 4: Transakce
1. Napište anonymní proceduru, která vloží dva záznamy do tabulky
Student a provede COMMIT. V případě selhání jedné s operací
provede ROLLBACK. Po úspěšném potvrzení transakce bude na
konzolový výstup vypsáno ’OK’, v případě výjimky ’Chyba’.

2. Nasimulujte situaci, kdy při vkládání druhého studenta dojde k chybě.
Ujistěte se, správným ošetřením transakce bude obsah tabulky
Student odpovídat stavu před spuštěním procedury.

# Domácí úloha (1)
1. Napište anonymní proceduru s proměnnými v_student,
v_studentCourse, v_course a v_teacher. Proměnné budou typu
%ROWTYPE pro odpovídající tabulky. Do těchto proměnných
budou v proceduře nejprve nastavena smyšlená data studentů, účasti
na kruzu atd. Následně proběhne vložení dat do odpovídajících
tabulek. V případě úspěšného vložení bude na serverový výstup
vypsáno hlášení ‘skript úspěšně dokončen’, jinak bude vypsáno ‘při
zpracování skriptu došlo k chybě’. Veškeré operace proběhnou v
rámci transakce tak, aby byl v případě chyby navrácen stav databáze
před spuštěním anonymní procedury.

# Domácí úloha (2)
1. Napište anonymní proceduru s proměnnými v_login1 a v_login2.
Do těchto proměnných přiřaďte loginy dvou libovolných učitelů.
Úkolem anonymní procedury bude těmto dvěma učitelům prohodit
kurzy, které vyučují. Pro řešení úlohy bude nutné pracovat s fiktivním
učitelem, který bude na začátku vložen do tabulky Teacher a na
konci po prohození kurzů zase odstraněn. Všechny operace
proběhnou v rámci jedné transakce. Na začátku a na konci procedury
bude pro oba učitele vypsán počet předmětů.

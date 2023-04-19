# Úkol 1: Dynamické SQL (1)

1. Vytvořte bezparametrickou uloženou proceduru PPrepareTableReward,
která bude sloužit pro podmíněné vytvoření tabulky Reward. Procedura
pomocí systémového katalogu zkontroluje, zda tabulka existuje. Pokud
ano, tabulku příkazem DROP TABLE smaže. Poté vytvoří novou tabulku
Reward s atributy id INTEGER (primární klíč), student_login CHAR(6)
(cizí klíč do tabulky Student), winter_reward INTEGER NULL,
summer_reward INTEGER NULL a thesis_reward INTEGER NULL.

2. Napište uloženou proceduru PSetStudentReward s parametry p_login,
p_rewardType a p_reward. Parametr p_reward bude typu INTEGER
a parametr p_rewardType bude řetězec s možnými hodnotami ‘winter’,
‘summer’ nebo ‘thesis’. Procedura bude vkládat záznam do tabulky
Reward. Jako id použijte nejvyšší id inkrementované o 1. V proceduře se
vyhněte použití podmínek.
Pozn.: Předávání hodnot dynamickému SQL provádějte pokud možno s využitím
vázaných proměnných.

# Úkol 2: Dynamické SQL (2)

1. Vytvořte uloženou proceduru PUpdateGradeStatic s parametry
p_grade, p_fname a p_lname, která nastaví studentovi
definovanému parametry p_fname a p_lname ročník na hodnotu
v parametru p_grade.

2. Vytvořte uloženou proceduru PUpdateGradeDynamic fungující
obdobně jako PUpdateGradeStatic, přičemž parametry p_fname
a p_lname nemusí být definovány. Pokud nebude parametr definován
(hodnota NULL), nebude součástí podmínky příkazu UPDATE.

3. Vytvořte uloženou proceduru PUpdateGrade s parametry p_grade,
p_fname, p_lname a p_type. Parametr p_type je řetězec s
možnými hodnotami ‘Static’ a ‘Dynamic’ a na základě něj bude
zavolána procedura PUpdateGradeStatic nebo
PUpdateGradeDynamic. Proceduru napište bez použití podmínek.

# Domácí úloha
1. Vytvořte uloženou funkci FGetStudentInfo1 s parametrem
p_login, která vrátí všechny informace o daném studentovi
z tabulky Student v podobě textového řetězce. Řetězec bude složen
z dvojic atribut=‘hodnota’, které budou odděleny středníkem.

2. Napište uloženou funkci FGetStudentInfo2 s parametry p_login
a p_attributes. Parametr p_attributes bude obsahovat seznam
atributů (identifikátorů) oddělených středníkem. Procedura bude
fungovat obdobně jako FGetStudentInfo1, ale bude vracet jen
požadované atributy.

## Probleme MIPS - Tema ASC Anul 1, Semestrul 1

II.26) (15 puncte)
 Program de inmultire a doua matrici liniarizate. Matricile sursa se dau
  sub forma unor variabile initializate la declarare cu siruri de word-uri,
  dimensiunile lor se dau sub forma a trei variabile byte declarate cu
  initializare, pentru matricea rezultat se va declara o variabila
  urmata de un numar corespunzator de bytes neinitializati.

III.26) (20 puncte)
 Implementati un alocator de memorie astfel:
- declarati in zona ".data":
 * o zona mare "mem" (.space) din care ulterior se vor aloca diverse bucati;
 * un vector "log" (declarat initial tot cu .space, dar folosit ulterior ca
   vector de word), in care se vor inregistra adresele bucatilor alocate si
   lungimile lor;
 * alte variabile necesare gestionarii vectorilor de mai sus (de ex. pt. a
   retine dimensiunile lor si pana unde s-au ocupat);
- scrieti doua functii:
   "malloc" - primeste ca parametru un word "d", gaseste in "mem" o zona
     nerezervata de "d" octeti, o rezerva (adaugand la "log" doua worduri - 
     offsetul zonei fata de inceputul vectorului si dimensiunea ei "d"), si
     returneaza (prin $v0) adresa ei de memorie; daca nu exista o zona libera
     de dimensiunea ceruta nu rezerva nimic si ret. 0;
   "free" - primeste ca parametru un word, desemnand o adresa de memorie
     (care se doreste a fi din zona de date statice, unde se afla "mem"),
     cauta in "log" inregistrarea ce corespunde acestei adrese, o elimina,
     apoi translateaza celelalte inregistrari (sau o pune pe ultima in locul
     celei eliminate); daca nu exista o asemenea inregistrare, nu face nimic;
   eventual (pentru inca 10 puncte) "compact" - translateaza zonele alocate
     in "mem" si modifica inregistrarile corespunzatoare in "log" a.i. zonele
     alocate sa fie adiacente.

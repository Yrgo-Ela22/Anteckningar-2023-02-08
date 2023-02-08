# Anteckningar 2022-02-08
Introduktion till ALU samt övningsuppgift innefattande timer- och PCI-avbrott i assembler.
ALU:ns Syfte och arbetssätt samt hur resultatet från en given beräkning medför 
uppdatering av statusbitar SNZVC is CPU:ns statusregister.

Under nästa lektion ska ALU:n implementeras tillsammans med diverse aritmetiska samt 
logiska instruktionser såsom ORI, ANDI, ADD och INC, hoppinstruktioner BREQ, BRNE, BRGE, BRGT, 
BRLE samt BRLT, som alla använder sig av en eller flera statusbitar satta av ALU:n.

Filen "alu.png" utgör en bild som demonstrerar ALU:ns arbetssätt visuellt samt via text.

Filen "alu_emulator.zip" utgör en ALU-emulator, som kan användas för att testa ALU:ns funktion från en terminal. Operation samt operander kan matas in från terminalen, följt av att resultatet skrivs ut både decimalt och binärt, tillsammans med statusbitar SNZVC. Fem exempelfall skrivas ut vid start, som demonstrerar när de olika statusbitarna ettställs.

Filen "timer0_exercise.asm" utgör en övningsuppgift innefattande timer- samt PCI-avbrott i assembler.

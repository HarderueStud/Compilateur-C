%{

// inclusions de fichiers d'en-tête
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "Structure.h"
// -

// Variables globales
Fonctions *listfonctions; // Liste des fonctions
Blocks *block; // Liste des blocs

Sommets *sommets; // Liste des Sommets
Sommets *sommets2; // Une deuxieme liste de Sommets (pour pallier la lecture inversé du parseur parfois)

Arretes *arretes; // Liste des arretes
BlocksArr *blocksarr; // Liste bloc - arr

int yylineno;
char stockervar[100];
char stockervar2[100];
char stockertab[100];
char stockertab2[100];

char stockertabaff[50];
char stockertabaff2[50];
int esttableauaff;

int estvariable;
int estfonction;
int esttableau;
int nombrepar;
int estfonctdansfonct;

int idDot;  //nom du sommet pour le Dot
char listop[20];
char listcomp[20];
int hautaffecta[20];
char opaprestab[20];
char opaprespar[20];
int finfonc[20];
int parametresDot[20];
int zeroParametres;
int enregistrer[20];
int enraff1; enraff2; enrif; enrif2; enrif3;
int enrfor1, enrfor2, enrfor3;
int enrwhile1; enrwhile2;
int enrswitchaff;
int enrswitch[50];
int boucleblock[20];

char declarationblock[200]; // pour verifier si des variables sont declarés lors de creation de fonction

// -
%}

%union{
    char *name[50];
    int val;
}

%token <name> IDENTIFICATEUR
%token CONSTANTE VOID INT FOR WHILE IF SWITCH CASE DEFAULT
%token BREAK RETURN LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN
%token <val> NOMBRE
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc ELSE

%%

R1:
    R {
        printf("pas d'erreur, fichier Dot généré.\n");
    }

R:
    S
    | S R

S:
    EXTERN EX
    | CONSTANTE INT IDENTIFICATEUR S1   {
        if (stockertab2[0] != '\0') {        // c'est un tableau
            char nom[50]; int cop = 0; 

            while($3[cop] != '\0') {
                nom[cop]=$3[cop];
                cop++;
            }; 
            
            nom[cop]='\0';
            printf("un tableau ne peut pas être constant: %s\n", nom);
            yyerror();
        }
        if (estvariable == 1){      // c'est une variable globale
            char nom[50]; int cop = 0; 
            
            while($3[cop] != '\0') {
                nom[cop]=$3[cop];
                cop++;
            }; 

            nom[cop]='\0';
            int dec = DeclarationVariableBlockCourrant(block, nom);

            if (dec == 1 || dec == 2) {
                printf("variable %s déjà declaré\n", nom);
                yyerror();
            }

            ajoutervariable(block, nom);
            estvariable = 0;
        }
        if (estfonction == 1) {
            char nom[50]; int cop = 0; 
            
            while($3[cop] != '\0'){
                nom[cop]=$3[cop];
                cop++;
            }; 
            
            nom[cop]='\0';
            printf("une fonction ne peut pas être constante: %s\n", nom);
            yyerror();
        }

    }
    | INT IDENTIFICATEUR S1     {
        if (stockertab2[0] != '\0') {        // c'est un tableau
            char nom[50]; int cop = 0; 
            
            while($2[cop] != '\0') {
                nom[cop]=$2[cop];
                cop++;
            }; 
            
            nom[cop]='\0';
            int i = 0; int j = 0;

            while(nom[i] != '\0') {
                stockertab[i]=nom[i]; i++;
            }

            while(stockertab2[j] != '\0') {
                stockertab[i] = stockertab2[j]; i++; j++;
            }

            vider(stockertab2);
            int dec = DeclarationVariableBlockCourrant(block, stockertab);

            if (dec == 2) {
                printf("tableau %s déjà déclaré\n", nom);
                yyerror();
            }

            if (dec == 1) {
                printf("nom: %s déjà possédé par une variable\n", nom);
                yyerror();
            }

            ajoutervariable(block, stockertab);
            vider(stockertab);
        }
        if (estvariable == 1) {      // c'est une variable globale
            char nom[50]; int cop = 0; 

            while($2[cop] != '\0') {
                nom[cop]=$2[cop];
                cop++;
            }; 

            nom[cop]='\0';
            int dec = DeclarationVariableBlockCourrant(block, nom);

            if (dec == 1 || dec == 2) {
                printf("variable: %s déjà declaré\n", nom);
                yyerror();
            }

            ajoutervariable(block, nom);
            estvariable = 0;
        }
        if (estfonction == 1) {
            estfonction = 0;
            char nom[50]; int cop = 0; 
            
            while($2[cop] != '\0') {
                nom[cop]=$2[cop];
                cop++;
            }; 
            
            nom[cop]='\0';  //$2 copié dans nom car yacc copie que le &er caractère quand juste $2
            int dec = DeclarationFonction(listfonctions, nom);
            
            if (dec == 1) {
                printf("fonction: %s déjà declaré\n", nom);
                yyerror();
            }
            insertionFonction(listfonctions, nom, stockervar2, 1);
            
            if (AffichePossedeReturn(block) == 0) {
                printf("la fonction: %s doit renvoyer un int\n", nom);
                yyerror();
            }

            int i=0;
            int j;
            char element[20];
            int e;

            while(declarationblock[i] != '\0') {
                if (declarationblock[i] == '/') {
                    i++;
                }

                j=i;
                e=0;

                while(declarationblock[i] != '\0' && declarationblock[i] != '/') {
                    element[e] = declarationblock[i];
                    i++; e++;
                }

                if (estDansTableau(stockervar2, element) == 1) {
                    SupprimerDansTab(declarationblock, element);
                    i=j;
                }

                vider(element);
            }
            if (declarationblock[0] != '\0') {
                int p=0;

                while(declarationblock[p] != '\0' && declarationblock[p] != '/') {
                    p++;
                }

                if (declarationblock[p] == '\0') {
                    printf("variable: %s non declaré\n", declarationblock);
                    yyerror();
                }
                else {
                    p=0;
                    while(declarationblock[p] != '\0') {
                        if (declarationblock[p] == '/') {
                            declarationblock[p] = ';';
                        }
                        p++;
                    }
                    
                    printf("variables: %s non declarés\n", declarationblock);
                    yyerror();
                }     
            }

            vider(stockervar2);
            suppressionBlock(block);         // quand on quitte la fonction on supprime son block    

            idDot++;
            nom[cop] = ','; 
            cop++; 
            nom[cop] = ' '; 
            cop++; 
            nom[cop] = 'i'; 
            nom[cop+1] = 'n'; 
            nom[cop+2] = 't'; 
            nom[cop+3] = '\0';

            insertionSommets(sommets, nom, idDot, 1, 1);
            insertionSommetBlocksArr(blocksarr, idDot);
            creerArretes(blocksarr, arretes);
            suppressionBlocksArr(blocksarr);
        }
    }
    | VOID IDENTIFICATEUR '(' FONC  {
         
        estfonction = 0;
        char nom[50]; int cop = 0; 
        
        while($2[cop] != '\0') {
            nom[cop]=$2[cop];
            cop++;
        }; 
        
        nom[cop]='\0';  //je copie $2 dans nom car yacc bizarement copie que le 1er caractère quand je mets juste $2
        int dec = DeclarationFonction(listfonctions, nom);
        
        if (dec == 1) {
            printf("fonction: %s déjà declaré\n", nom);
            yyerror();
        }

        insertionFonction(listfonctions, nom, stockervar2, 1);
    
        if (AffichePossedeReturn(block) == 1) {
            printf("la fonction: %s doit renvoyer void\n", nom);
            yyerror();
        }
        
        int i=0;
        int j;
        char element[20];
        int e;

        while(declarationblock[i] != '\0') {
            if (declarationblock[i] == '/') {
                i++;
            }

            j=i;
            e=0;

            while(declarationblock[i] != '\0' && declarationblock[i] != '/') {
                element[e] = declarationblock[i];
                i++; e++;
            }

            if (estDansTableau(stockervar2, element) == 1) {
                SupprimerDansTab(declarationblock, element);
                i=j;
            }

            vider(element);
        }

        if (declarationblock[0] != '\0') {
            int p=0;

            while(declarationblock[p] != '\0' && declarationblock[p] != '/'){
                p++;
            }

            if (declarationblock[p] == '\0'){
                printf("variable: %s non declaré\n", declarationblock);
                yyerror();
            }
            else {
                p=0;
                
                while(declarationblock[p] != '\0') {
                    if (declarationblock[p] == '/') {
                        declarationblock[p] = ';';
                    }
                    p++;
                }

                printf("variables: %s non declarés\n", declarationblock);
                yyerror();
            }
        }

        vider(stockervar2);
        suppressionBlock(block);

        idDot++;
        nom[cop] = ','; 
        cop++; 
        nom[cop] = ' '; 
        cop++; 
        nom[cop] = 'v'; 
        nom[cop+1] = 'o'; 
        nom[cop+2] = 'i'; 
        nom[cop+3] = 'd'; 
        nom[cop+4] = '\0';

        insertionSommets(sommets, nom, idDot, 1, 1);
        insertionSommetBlocksArr(blocksarr, idDot);
        creerArretes(blocksarr, arretes);
        suppressionBlocksArr(blocksarr);
        
    }
    | IDENTIFICATEUR S2     {
        if (estvariable == 1){
            char nom[50]; int cop = 0; 
            
            while($1[cop] != '\0'){
                nom[cop]=$1[cop];
                cop++;
            }; 
            
            nom[cop]='\0';
            int dec = DeclarationVariable(block, nom);

            if (dec == 0){
                printf("variable: %s non declaré\n", nom);
                yyerror();
            }

            estvariable = 0;

            idDot++;
            insertionSommets(sommets, nom, idDot, 0, 0);
            idDot++;
            char egal[3] = {':', '=', '\0'};

            insertionSommets(sommets, egal, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, idDot-2);
        }

        if (esttableau == 1) {
            esttableau =0;
            char nom[50]; int cop = 0; 
            
            while($1[cop] != '\0'){
                nom[cop]=$1[cop];
                cop++;
            }; 
            
            nom[cop]='\0';
            int dec = DeclarationVariable(block, nom);

            if (dec == 0){
                printf("tableau: %s non declaré\n", nom);
                yyerror();
            }

            if (dec == 1){
                printf("%s n'est pas un tableau\n", nom);
                yyerror();
            }

            int i = 0; int j = 0;
            while(nom[i] != '\0') {
                stockertab[i]=nom[i]; i++;
            }

            while(stockertab2[j] != '\0') {
                stockertab[i] = stockertab2[j]; i++; j++;
            }

            dec = ControleTailleTableauBlocks(block, stockertab);
            if (dec == 0){
                printf("erreur de segmentation avec le tableau: %s\n", nom);
                yyerror();
            }

            vider(stockertab);

            int enregistreraff = idDot;
            idDot++;
            insertionSommets(sommets2, nom, idDot, 0, 0);
            int debut = idDot;
            char stockeraffpourDot[7];
            i=0; j=0;

            while(stockertab2[i] != '\0'){
                j=0;
                vider(stockeraffpourDot);
                i++;

                while(stockertab2[i] != ']'){
                    stockeraffpourDot[j] = stockertab2[i];
                    i++; j++;
                }

                i++;
                idDot++;
                if (stockeraffpourDot[0] == '\0'){stockeraffpourDot[0] = '0';}   //si = 0;
                
                insertionSommets(sommets2, stockeraffpourDot, idDot, 0, 0);
            }

            ViderPileSommets2();
            idDot++;
            char tabl[4] = {'T', 'A', 'B', '\0'};
            insertionSommets(sommets, tabl, idDot, 0, 0);

            while(debut < idDot){
                insertionArretes(arretes, idDot, debut);
                debut++;
            }

            vider(stockertab2);

            idDot++;
            char egal[3] = {':', '=', '\0'};
            insertionSommets(sommets, egal, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, enregistreraff);
        }
        if (estfonction == 1){
            estfonction = 0;
            char nom[50]; int cop = 0; 
            
            while($1[cop] != '\0'){
                nom[cop]=$1[cop];
                cop++;
            }; 
            
            nom[cop]='\0';
            int dec = DeclarationFonction(listfonctions, nom);
            
            if (dec == 0){
                printf("fonction: %s non declaré\n", nom);
                yyerror();
            }
            
            int n;
            n = NombreParametreFonction(listfonctions, nom);
            
            if (nombrepar != n){
                printf("nombre de paramètres incorrecte pour la fonction %s\n", nom);
                yyerror();
            }
            
            nombrepar = 0;
            idDot++;
            insertionSommets(sommets, nom, idDot, 5, 0);
            int k=0;
            
            while(parametresDot[k] != -1){
                insertionArretes(arretes, idDot, parametresDot[k]);
                parametresDot[k] = -1;
                k++;
            }
            
            k=0; 
            while(finfonc[k] != -1) {
                k++;
            }

            finfonc[k-1] = -1;
        }
    }

EX: 
    INT IDENTIFICATEUR '(' FONCEXT      {
        char nom[50]; int cop = 0; 
        
        while($2[cop] != '\0'){
            nom[cop]=$2[cop];
            cop++;
        }; 
        
        nom[cop]='\0';  //je copie $2 dans nom car yacc bizarement copie que le &er caractère quand je mets juste $2
        int dec = DeclarationFonction(listfonctions, nom);

        if (dec == 1){
            printf("fonction: %s déjà declaré\n", nom);
            yyerror();
        }

        insertionFonction(listfonctions, nom, stockervar2, 1);
        vider(stockervar2);
    }
    | VOID IDENTIFICATEUR '(' FONCEXT   {
        char nom[50]; int cop = 0; 
        
        while($2[cop] != '\0'){
            nom[cop]=$2[cop];
            cop++;
        }; 
        
        nom[cop]='\0'; 
        int dec = DeclarationFonction(listfonctions, nom);
        
        if (dec == 1){
            printf("fonction: %s déjà declaré\n", nom);
            yyerror();
        }

        insertionFonction(listfonctions, nom, stockervar2, 0); 
        vider(stockervar2);
    }

FONCEXT:
    ')' ';'
    | INT IDENTIFICATEUR EXTPLUSIEURSPARAM  {
        char nom[50]; int cop = 0; 
        
        while($2[cop] != '\0'){
            nom[cop]=$2[cop];
            cop++;
        }; 
        
        nom[cop]='\0';
        int i=0;

        while(nom[i] != '\0'){
            stockervar2[i] = nom[i];
            i++;
        }

        if (stockervar[0] != '\0'){
            stockervar2[i] = '/';
            i++;
        }

        int j=0;
        while(stockervar[j] != '\0'){
            stockervar2[i] = stockervar[j];
            i++;
            j++;
        }

        vider(stockervar);
    }

EXTPLUSIEURSPARAM:
    ')' ';'
    | ',' INT IDENTIFICATEUR EXTPLUSIEURSPARAM  {
        int i=0; while(stockervar[i] != '\0'){
            i++;
        }

        if (i != 0){
            stockervar[i] = '/'; i++;
        }

        char nom[50]; int cop = 0; 
        while($3[cop] != '\0'){
            nom[cop]=$3[cop];
            cop++;
        }; 
        
        nom[cop]='\0';
        int j=0;

        while(nom[j] != '\0'){
            stockervar[i] = nom[j];
            j++;
        }
    }

S1:
    '[' NOMBRE ']' TABL     {
        int i=0;
        while(stockertab[i] != '\0'){ 
            i++;
        };

        stockertab[i] = '['; i++;
        int nombre = $2;
        char tabintermed[10];
        int n2;
        char n3;

        while(nombre > 0) {
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertab[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }

        stockertab[i] = ']', i++;
        i =0; int j = 0; int k = 0;            //le tableau est à l'envers, donc on le met à l'endroit
        while(stockertab[i] != '\0'){
            i++;
        }
        
        j = i-2;
        while(i>0) {
            while(stockertab[i] != '['){
                i--;
            }

            stockertab2[k] = '['; k++;

            while(stockertab[j] != '['){
                stockertab2[k] = stockertab[j]; k++; j--;
            }

            stockertab2[k] = ']'; k++;
            i--;
            j = i-1;
        }

        vider(stockertab);
    }
    | '(' FONC  {
        estfonction = 1;
    }
    | PLUSIEURSIDS  {
        estvariable = 1;
    }

PLUSIEURSIDS:
    ';'
    | ',' IDENTIFICATEUR PLUSIEURSIDS   {
        char nom[50]; int cop = 0; 
        while($2[cop] != '\0'){
            nom[cop]=$2[cop];
            cop++;
        }; 
        
        nom[cop]='\0';
        int dec = DeclarationVariableBlockCourrant(block, nom);
        
        if (dec == 1 || dec == 2){
            printf("variable: %s déjà declaré\n", nom);
            yyerror();
        }

        ajoutervariable(block, nom);
    }

TABL:
    ';'
    | '[' NOMBRE ']' TABL   {
        int i=0;
        while(stockertab[i] != '\0'){ 
            i++;
        };

        stockertab[i] = '['; i++;
        int nombre = $2;
        char tabintermed[10];
        int n2;
        char n3;

        while(nombre > 0) {
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertab[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }

        stockertab[i] = ']', i++;
    }

TABLAFF1:
    '='
    | '[' NOMBRE ']' TABLAFF1   {
        int i=0;
        while(stockertab[i] != '\0'){ 
            i++;
        };

        stockertab[i] = '['; i++;
        int nombre = $2;
        char tabintermed[10];
        int n2;
        char n3;

        while(nombre > 0) {
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertab[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }

        stockertab[i] = ']', i++;
    }

S2:
    '=' AFFECTA ';' {
        estvariable = 1;

    }
    | '[' NOMBRE ']' TABLAFF1 AFFECTA ';'   {
        esttableau = 1;
        int i=0;
        while(stockertab[i] != '\0'){ i++;};
        stockertab[i] = '['; i++;
        int nombre = $2;
        char tabintermed[10];
        int n2;
        char n3;
        while(nombre > 0){
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertab[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }
        stockertab[i] = ']', i++;
        i =0; int j = 0; int k = 0;            //le tableau est à l'envers, donc on le met à l'endroit
        while(stockertab[i] != '\0'){i++;}
        j = i-2;
        while(i>0){
            while(stockertab[i] != '['){
                i--;
            }
            stockertab2[k] = '['; k++;
            while(stockertab[j] != '['){
                stockertab2[k] = stockertab[j]; k++; j--;
            }
            stockertab2[k] = ']'; k++;
            i--;
            j = i-1;
        }
        vider(stockertab);

    }
    | '(' MOINSCHOISIRPAR ';'   {
        estfonction = 1;
        nombrepar++;
    }
    | '(' ')' ';'   {
        estfonction = 1;
    }


FONC:
    ')' '{' RT BLOCK1  
    | INT IDENTIFICATEUR FPLUSIEURSIDS  {
        char nom[50]; int cop = 0; 
        
        while($2[cop] != '\0'){
            nom[cop]=$2[cop];
            cop++;
        }; 
            
        nom[cop]='\0';
        int i=0;

        while(nom[i] != '\0') {
            stockervar2[i] = nom[i];
            i++;
        }

        if (stockervar[0] != '\0'){
            stockervar2[i] = '/';
            i++;
        }

        int j=0;

        while(stockervar[j] != '\0'){
            stockervar2[i] = stockervar[j];
            i++;
            j++;
        }
        
        vider(stockervar);
    }
    

RT : { 
    char variables[2] = {'\0'};
    insertionBlock(block, variables, 0, 0);
    insertionBlocksArr(blocksarr, 0);
    }

BLOCK1:

    '}'   
    | BLOCK BLOCK1

FPLUSIEURSIDS:
    ',' INT IDENTIFICATEUR FPLUSIEURSIDS    {
        int i=0; while(stockervar[i] != '\0'){i++;}
        if (i != 0){
            stockervar[i] = '/'; i++;
        }
        char nom[50]; int cop = 0; while($3[cop] != '\0'){nom[cop]=$3[cop];cop++;}; nom[cop]='\0';
        int j=0;
        while(nom[j] != '\0'){
            stockervar[i] = nom[j];
            j++;
            i++;
        }
    }
    | ')' '{' RT BLOCK1 

MOINSCHOISIRPAR:    
    MOINS CHOISIRPAR {
        char zero[2] = {'0', '\0'}; idDot++;
        insertionSommets(sommets, zero, idDot, 0, 0);
        char moins[2] = {'-', '\0'}; idDot++;
        insertionSommets(sommets, moins, idDot, 0, 0);
        insertionArretes(arretes, idDot, idDot-1);
        insertionArretes(arretes, idDot, idDot-2);
        int i=0; while(parametresDot[i] != -1){i++;} parametresDot[i]=idDot; parametresDot[i+1]=-1;
    }
    | CHOISIRPAR {int i=0; while(parametresDot[i] != -1){i++;} parametresDot[i]=idDot; parametresDot[i+1]=-1;}

ENR:    {int i=0; while(enregistrer[i]!=-1){i++;} enregistrer[i] = idDot; enregistrer[i+1] = -1;}
CHOISIRPAR:
    '(' MOINSCHOISIRPARSANSVIRGULE ENR OPOUFIN {
        int j=0; while(enregistrer[j] != -1){j++;}
        if (opaprespar[0] != '\0'){
            int oo=0; while(opaprespar[oo] != '\0'){oo++;} opaprespar[oo-1] = '\0';
            idDot++;
            int i=0; while(listop[i]!='\0'){i++;}
            char oper[3] = {listop[i-1], '\0'};
            if (listop[i-1] == 'r'){
                oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
            }
            if (listop[i-1] == 'l'){
                oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
            }
            listop[i-1] = '\0';
            insertionSommets(sommets, oper, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, enregistrer[j-1]);
        }
        else{
            idDot++;
            char vide[1] = {'\0'};
            insertionSommets(sommets, vide, idDot, 0, 0);    // todo effacer à la fin
            insertionArretes(arretes, idDot, enregistrer[j-1]);
        }
        enregistrer[j-1] = -1;
    }
    | IDENTIFICATEUR OPOUFINOUFONC  {           // fonction dans appel de fonction
        if (estfonctdansfonct == 1){
            estfonctdansfonct = 0;
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int n;
            n = DeclarationFonction(listfonctions, nom);
            if (n == 0){
                printf("fonction: %s non declaré\n", nom);
                yyerror();
            }
            n = NombreParametreFonction(listfonctions, nom);
            nombrepar = nombrepar - n;
            int ret = AfficheFonctionReturn(listfonctions, nom);
            if (ret == 0){
                printf("la fonction %s ne renvoi pas de int, donc ne peut pas être un paramètre\n", nom);
                yyerror();
            }

            if (zeroParametres == 1){
                idDot++;
                insertionSommets(sommets, nom, idDot, 5, 0);
            }
            else{
                
                idDot++;
                insertionSommets(sommets, nom, idDot, 5, 0);
                int k=0;
                int kk=0; while(finfonc[kk] != -1){kk++;}
                while(parametresDot[k] <= finfonc[kk-1] && parametresDot[k] != -1){
                    insertionArretes(arretes, idDot, parametresDot[k]);
                    k++;
                }
                int k2 = 0;
                while(parametresDot[k] != -1){
                    parametresDot[k2] = parametresDot[k];
                    k++; k2++;
                }
                while(parametresDot[k2] != -1){
                    parametresDot[k2] = -1;
                    k2++;
                }
                finfonc[kk-1] = -1;

            }
        }
        else{
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int n;
            n = DeclarationVariable(block, nom);

            if (n == 0){
                ajouterDansTableau(declarationblock, nom);
            }
            if (n == 2){
                printf("les fonctions n'acceptent pas les tableaux en paramètre, fonction: %s\n", nom);
                yyerror();
            }

            if (opaprespar[0] != '\0'){
                int x=0; while(opaprespar[x]!='\0'){x++;} opaprespar[x-1] = '\0';
                idDot++;
                insertionSommets(sommets, nom, idDot, 0, 0);
                idDot++;
                int i=0; while(listop[i]!='\0'){i++;}
                char oper[3] = {listop[i-1], '\0'};
                if (listop[i-1] == 'r'){
                    oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
                }
                if (listop[i-1] == 'l'){
                    oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
                }
                listop[i-1] = '\0';
                insertionSommets(sommets, oper, idDot, 0, 0);
                insertionArretes(arretes, idDot, idDot-2);
                insertionArretes(arretes, idDot, idDot-1);
            }
            else{
                idDot++;
                insertionSommets(sommets, nom, idDot, 0, 0);
            }

        }
    }
    | NOMBRE OPOUFIN {
        if (opaprespar[0] != '\0'){
            int x=0; while(opaprespar[x]!='\0'){x++;} opaprespar[x-1] = '\0';
            int t1 = $1;
            int div = 10;
            int jj = 0;
            char chaine[10] = {'0', '\0'};
            while(t1/div >= 1){
                div = div * 10;
            }
            div = div/10;
            while(div>1){
                
                chaine[jj] = floor(t1/div) + '0';
                t1 = t1 - floor(t1/div)*div;
                div = div/10;
                jj++;
            }
            chaine[jj] = t1 + '0';
            idDot++;
            insertionSommets(sommets, chaine, idDot, 0, 0);
            idDot++;
            int i=0; while(listop[i]!='\0'){i++;}
            char oper[3] = {listop[i-1], '\0'};
            if (listop[i-1] == 'r'){
                oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
            }
            if (listop[i-1] == 'l'){
                oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
            }
            listop[i-1] = '\0';
            insertionSommets(sommets, oper, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-2);
            insertionArretes(arretes, idDot, idDot-1);

        }
        else{
            int t1 = $1;
            int div = 10;
            int jj = 0;
            char chaine[10] = {'0', '\0'};
            while(t1/div >= 1){
                div = div * 10;
            }
            div = div/10;
            while(div>1){
                
                chaine[jj] = floor(t1/div) + '0';
                t1 = t1 - floor(t1/div)*div;
                div = div/10;
                jj++;
            }
            chaine[jj] = t1 + '0';
            idDot++;
            insertionSommets(sommets, chaine, idDot, 0, 0);
        }
    }


OPOUFIN:
    ')'     {int i=0; while(finfonc[i] != -1){i++;} finfonc[i] = idDot, finfonc[i+1] = -1;}
    | OPERATEUR CHOISIRPAR  {int i=0; while(opaprespar[i]!='\0'){i++;} opaprespar[i]='a';}
    | ',' MOINSCHOISIRPAR {
        nombrepar++;
    }

OPOUFINOUFONC:   
    OPERATEUR CHOISIRPAR  {int i=0; while(opaprespar[i]!='\0'){i++;} opaprespar[i]='a';}
    | '(' ')' OPOUFIN   {estfonctdansfonct = 1;
        zeroParametres = 1;
    }
    | '(' MOINSCHOISIRPAR OPOUFIN   {estfonctdansfonct = 1; nombrepar++;
        zeroParametres = 0;
    } 
    | ',' MOINSCHOISIRPAR {
        nombrepar++;
    }
    | ')' {int i=0; while(finfonc[i] != -1){i++;} finfonc[i] = idDot, finfonc[i+1] = -1;}

OPERATEUR:  
    PLUS    {int i=0; while(listop[i] != '\0'){i++;} listop[i] = '+';}
    | MOINS {int i=0; while(listop[i] != '\0'){i++;} listop[i] = '-';}
    | MUL   {int i=0; while(listop[i] != '\0'){i++;} listop[i] = '*';}
    | DIV   {int i=0; while(listop[i] != '\0'){i++;} listop[i] = '/';}
    | '&'   {int i=0; while(listop[i] != '\0'){i++;} listop[i] = '&';}
    | '|'   {int i=0; while(listop[i] != '\0'){i++;} listop[i] = '|';}
    | RSHIFT    {int i=0; while(listop[i] != '\0'){i++;} listop[i] = 'r';}
    | LSHIFT    {int i=0; while(listop[i] != '\0'){i++;} listop[i] = 'l';}

MOINSCHOISIRPARSANSVIRGULE:
    MOINS CHOISIRPARSANSVIRGULE {
        char zero[2] = {'0', '\0'}; idDot++;
        insertionSommets(sommets, zero, idDot, 0, 0);
        char moins[2] = {'-', '\0'}; idDot++;
        insertionSommets(sommets, moins, idDot, 0, 0);
        insertionArretes(arretes, idDot, idDot-1);
        insertionArretes(arretes, idDot, idDot-2);
    }
    | CHOISIRPARSANSVIRGULE

CHOISIRPARSANSVIRGULE:
    '(' MOINSCHOISIRPARSANSVIRGULE ENR OPOUFINSANSVIRGULE   {
        int j=0; while(enregistrer[j] != -1){j++;}
        if (opaprespar[0] != '\0'){
            int oo=0; while(opaprespar[oo] != '\0'){oo++;} opaprespar[oo-1] = '\0';
            idDot++;
            int i=0; while(listop[i]!='\0'){i++;}
            char oper[3] = {listop[i-1], '\0'};
            if (listop[i-1] == 'r'){
                oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
            }
            if (listop[i-1] == 'l'){
                oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
            }
            listop[i-1] = '\0';
            insertionSommets(sommets, oper, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, enregistrer[j-1]);
        }
        else{
            idDot++;
            char vide[1] = {'\0'};
            insertionSommets(sommets, vide, idDot, 0, 0);    
            insertionArretes(arretes, idDot, enregistrer[j-1]);
        }
        enregistrer[j-1] = -1;
    }
    | IDENTIFICATEUR OPOUFINOUFONCSANSVIRGULE {           // fonction dans appel de fonction
        if (estfonctdansfonct == 1){
            estfonctdansfonct = 0;
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int n;
            n = DeclarationFonction(listfonctions, nom);
            if (n == 0){
                printf("fonction: %s non declaré\n", nom);
                yyerror();
            }
            n = NombreParametreFonction(listfonctions, nom);
            nombrepar = nombrepar - n;
            int ret = AfficheFonctionReturn(listfonctions, nom);
            if (ret == 0){
                printf("la fonction %s ne renvoi pas de int, donc ne peut pas être un paramètre\n", nom);
                yyerror();
            }

            if (zeroParametres == 1){
                idDot++;
                insertionSommets(sommets, nom, idDot, 5, 0);
            }
            else{
                
                idDot++;
                insertionSommets(sommets, nom, idDot, 5, 0);
                int k=0;
                int kk=0; while(finfonc[kk] != -1){kk++;}
                while(parametresDot[k] <= finfonc[kk-1] && parametresDot[k] != -1){
                    insertionArretes(arretes, idDot, parametresDot[k]);
                    k++;
                }
                int k2 = 0;
                while(parametresDot[k] != -1){
                    parametresDot[k2] = parametresDot[k];
                    k++; k2++;
                }
                while(parametresDot[k2] != -1){
                    parametresDot[k2] = -1;
                    k2++;
                }
                finfonc[kk-1] = -1;

            }
        }
        else{
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int n;
            n = DeclarationVariable(block, nom);
            if (n == 0){
                ajouterDansTableau(declarationblock, nom);
            }
            if (n == 2){
                printf("les fonctions n'acceptent pas les tableaux en paramètre, fonction: %s\n", nom);
                yyerror();
            }

            if (opaprespar[0] != '\0'){
                int x=0; while(opaprespar[x]!='\0'){x++;} opaprespar[x-1] = '\0';
                idDot++;
                insertionSommets(sommets, nom, idDot, 0, 0);
                idDot++;
                int i=0; while(listop[i]!='\0'){i++;}
                char oper[3] = {listop[i-1], '\0'};
                if (listop[i-1] == 'r'){
                    oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
                }
                if (listop[i-1] == 'l'){
                    oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
                }
                listop[i-1] = '\0';
                insertionSommets(sommets, oper, idDot, 0, 0);
                insertionArretes(arretes, idDot, idDot-2);
                insertionArretes(arretes, idDot, idDot-1);
            }
            else{
                idDot++;
                insertionSommets(sommets, nom, idDot, 0, 0);
            }
        }
    }
    | NOMBRE OPOUFINSANSVIRGULE {
        if (opaprespar[0] != '\0'){
            int x=0; while(opaprespar[x]!='\0'){x++;} opaprespar[x-1] = '\0';
            int t1 = $1;
            int div = 10;
            int jj = 0;
            char chaine[10] = {'0', '\0'};
            while(t1/div >= 1){
                div = div * 10;
            }
            div = div/10;
            while(div>1){
                
                chaine[jj] = floor(t1/div) + '0';
                t1 = t1 - floor(t1/div)*div;
                div = div/10;
                jj++;
            }
            chaine[jj] = t1 + '0';
            idDot++;
            insertionSommets(sommets, chaine, idDot, 0, 0);
            idDot++;
            int i=0; while(listop[i]!='\0'){i++;}
            char oper[3] = {listop[i-1], '\0'};
            if (listop[i-1] == 'r'){
                oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
            }
            if (listop[i-1] == 'l'){
                oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
            }
            listop[i-1] = '\0';
            insertionSommets(sommets, oper, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-2);
            insertionArretes(arretes, idDot, idDot-1);
        }
        else{
            int t1 = $1;
            int div = 10;
            int jj = 0;
            char chaine[10] = {'0', '\0'};
            while(t1/div >= 1){
                div = div * 10;
            }
            div = div/10;
            while(div>1){
                
                chaine[jj] = floor(t1/div) + '0';
                t1 = t1 - floor(t1/div)*div;
                div = div/10;
                jj++;
            }
            chaine[jj] = t1 + '0';
            idDot++;
            insertionSommets(sommets, chaine, idDot, 0, 0);
        }
    }

OPOUFINSANSVIRGULE:
    ')' 
    | OPERATEUR CHOISIRPARSANSVIRGULE   {int i=0; while(opaprespar[i]!='\0'){i++;} opaprespar[i]='a';}

OPOUFINOUFONCSANSVIRGULE:
    ')' 
    | OPERATEUR CHOISIRPARSANSVIRGULE   {int i=0; while(opaprespar[i]!='\0'){i++;} opaprespar[i]='a';}
    | '(' ')' OPOUFINSANSVIRGULE    {estfonctdansfonct = 1; zeroParametres = 1;}
    | '(' MOINSCHOISIRPAR OPOUFINSANSVIRGULE    {estfonctdansfonct = 1; nombrepar++; zeroParametres = 0;}


AFFECTA:
    MOINS AFFECTASANSMOINS  {
        idDot++;
        char moin[2] = {'-', '\0'};
        char zero[2] = {'0', '\0'};
        insertionSommets(sommets, zero, idDot, 0, 0);
        idDot++;
        insertionSommets(sommets, moin, idDot, 0, 0);
        insertionArretes(arretes, idDot, idDot-1);
        insertionArretes(arretes, idDot, idDot-2);
    }
    | AFFECTASANSMOINS

PARANTHESE:     // pour pouvoir enregistrer des choses
    ')' {int i=0; while(hautaffecta[i]!=0){i++;} hautaffecta[i] = idDot; hautaffecta[i+1] = 0;}

AFFECTASANSMOINS:   
    '(' AFFECTA PARANTHESE OPERATEUR AFFECTASANSMOINS  {
        idDot++;    // l'opperateur
        int i=0; while(listop[i]!='\0'){i++;}
        char oper[3] = {listop[i-1], '\0'};
        if (listop[i-1] == 'r'){
            oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
        }
        if (listop[i-1] == 'l'){
            oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
        }
        listop[i-1] = '\0';
        insertionSommets(sommets, oper, idDot, 0, 0);

        insertionArretes(arretes, idDot, idDot-1);  // celui de droite
        int j=0; while(hautaffecta[j]!=0){j++;}
        insertionArretes(arretes, idDot, hautaffecta[j-1]);
        hautaffecta[j-1] = 0;

        
    }
    | '(' AFFECTA ')'
    | NOMBRE OPERATEUR AFFECTASANSMOINS {
        int t1 = $1;
        int div = 10;
        int jj = 0;
        char chaine[10] = {'0', '\0'};
        while(t1/div >= 1){
            div = div * 10;
        }
        div = div/10;
        while(div>1){
            
            chaine[jj] = floor(t1/div) + '0';
            t1 = t1 - floor(t1/div)*div;
            div = div/10;
            jj++;
        }
        chaine[jj] = t1 + '0';
        idDot++;
        insertionSommets(sommets, chaine, idDot, 0, 0);
        idDot++;
        int i=0; while(listop[i]!='\0'){i++;}
        char oper[3] = {listop[i-1], '\0'};
        if (listop[i-1] == 'r'){
            oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
        }
        if (listop[i-1] == 'l'){
            oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
        }
        listop[i-1] = '\0';
        insertionSommets(sommets, oper, idDot, 0, 0);
        insertionArretes(arretes, idDot, idDot-2);
        insertionArretes(arretes, idDot, idDot-1);
        
    }
    | NOMBRE    {
        int t1 = $1;
        int div = 10;
        int jj = 0;
        char chaine[10] = {'0', '\0'};
        while(t1/div >= 1){
            div = div * 10;
        }
        div = div/10;
        while(div>1){
            
            chaine[jj] = floor(t1/div) + '0';
            t1 = t1 - floor(t1/div)*div;
            div = div/10;
            jj++;
        }
        chaine[jj] = t1 + '0';
        idDot++;
        insertionSommets(sommets, chaine, idDot, 0, 0);
        
    }
    | IDENTIFICATEUR AFF1  {
        if (esttableauaff == 1){
            esttableauaff =0;
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationVariable(block, nom);
            if (dec == 0){
                printf("tableau: %s non declaré\n", nom);
                yyerror();
            }
            if (dec == 1){
                printf("%s n'est pas un tableau\n", nom);
                yyerror();
            }
            int i = 0; int j = 0;
            while(nom[i] != '\0'){
                stockertabaff[i]=nom[i]; i++;
            }
            while(stockertabaff2[j] != '\0'){
                stockertabaff[i] = stockertabaff2[j]; i++; j++;
            }

            dec = ControleTailleTableauBlocks(block, stockertabaff);
            if (dec == 0){
                printf("erreur de segmentation avec le tableau: %s\n");
                yyerror();
            }
            vider(stockertabaff);

            int aoper = 0;
            if (opaprestab[0] != '\0'){   //si on fait une operation après le tableau
                aoper = idDot;
                int m=0; while(opaprestab[m] != '\0'){m++;} opaprestab[m-1] = '\0';
            }

            idDot++;
            insertionSommets(sommets2, nom, idDot, 0, 0);
            int debut = idDot;
            char stockeraffpourDot[7];
            i=0; j=0;
            while(stockertabaff2[i] != '\0'){
                j=0;
                vider(stockeraffpourDot);
                i++;
                while(stockertabaff2[i] != ']'){
                    stockeraffpourDot[j] = stockertabaff2[i];
                    i++; j++;
                }
                i++;
                idDot++;
                if (stockeraffpourDot[0] == '\0'){stockeraffpourDot[0] = '0';}   //si = 0;
                insertionSommets(sommets2, stockeraffpourDot, idDot, 0, 0);
            }
            ViderPileSommets2();
            idDot++;
            char tabl[4] = {'T', 'A', 'B', '\0'};
            insertionSommets(sommets, tabl, idDot, 0, 0);
            while(debut < idDot){
                insertionArretes(arretes, idDot, debut);
                debut++;
            }
            if (aoper != 0){    //operation après tableau, suite
                idDot++;
                int i=0; while(listop[i]!='\0'){i++;}
                char oper[3] = {listop[i-1], '\0'};
                if (listop[i-1] == 'r'){
                    oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
                }
                if (listop[i-1] == 'l'){
                    oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
                }
                listop[i-1] = '\0';
                insertionSommets(sommets, oper, idDot, 0, 0);
                insertionArretes(arretes, idDot, aoper);
                insertionArretes(arretes, idDot, idDot-1);
            }

            vider(stockertabaff2);
        }
        if (estfonction == 1){
            estfonction = 0;
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationFonction(listfonctions, nom);
            if (dec == 0){
                printf("fonction: %s non declaré\n", nom);
                yyerror();
            }
            int n;
            n = NombreParametreFonction(listfonctions, nom);
            if (nombrepar != n){
                printf("nombre de paramètres incorrecte pour la fonction: %s\n", nom);
                yyerror();
            }
            nombrepar = 0;

            idDot++;
            insertionSommets(sommets, nom, idDot, 5, 0);
            int k=0;
            while(parametresDot[k] != -1){
                insertionArretes(arretes, idDot, parametresDot[k]);
                parametresDot[k] = -1;
                k++;
            }
            k=0; while(finfonc[k] != -1){k++;}
            finfonc[k-1] = -1;
        }
    }
    | IDENTIFICATEUR OPERATEUR AFFECTASANSMOINS {
        char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
        int dec;
        dec = DeclarationVariable(block, nom);
        if (dec == 0){
            ajouterDansTableau(declarationblock, nom);
        }

        idDot++;
        insertionSommets(sommets, nom, idDot, 0, 0);
        idDot++;
        int i=0; while(listop[i]!='\0'){i++;}
        char oper[3] = {listop[i-1], '\0'};
        if (listop[i-1] == 'r'){
            oper[0] = '>'; oper[1] = '>'; oper[2] = '\0';
        }
        if (listop[i-1] == 'l'){
            oper[0] = '<'; oper[1] = '<'; oper[2] = '\0';
        }
        listop[i-1] = '\0';
        insertionSommets(sommets, oper, idDot, 0, 0);
        insertionArretes(arretes, idDot, idDot-2);
        insertionArretes(arretes, idDot, idDot-1);
    }
    | IDENTIFICATEUR    {
        char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
        int dec;
        dec = DeclarationVariable(block, nom);
        if (dec == 0){
            ajouterDansTableau(declarationblock, nom);
        }
        idDot++;
        insertionSommets(sommets, nom, idDot, 0, 0);
    }

AFF1:
    '[' NOMBRE ']' TABLAFF  {
        esttableauaff = 1;
        int i=0;
        while(stockertabaff[i] != '\0'){ i++;};
        stockertabaff[i] = '['; i++;
        int nombre = $2;
        int n2;
        char n3;
        while(nombre > 0){
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertabaff[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }
        stockertabaff[i] = ']', i++;
        i =0; int j = 0; int k = 0;            //le tableau est à l'envers, donc on le met à l'endroit
        while(stockertabaff[i] != '\0'){i++;}
        j = i-2;
        while(i>0){
            while(stockertabaff[i] != '['){
                i--;
            }
            stockertabaff2[k] = '['; k++;
            while(stockertabaff[j] != '['){
                stockertabaff2[k] = stockertabaff[j]; k++; j--;
            }
            stockertabaff2[k] = ']'; k++;
            i--;
            j = i-1;
        }
        vider(stockertabaff);

    }

    | '[' NOMBRE ']'    {
        esttableauaff = 1;
        int i=0;
        stockertabaff[i] = '['; i++;
        int nombre = $2;
        int n2;
        char n3;
        while(nombre > 0){
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertabaff[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }
        stockertabaff[i] = ']';
        i =0; int j = 0; int k = 0;            //le tableau est à l'envers, donc on le met à l'endroit
        while(stockertabaff[i] != '\0'){i++;}
        j = i-2;
        while(i>0){
            while(stockertabaff[i] != '['){
                i--;
            }
            stockertabaff2[k] = '['; k++;
            while(stockertabaff[j] != '['){
                stockertabaff2[k] = stockertabaff[j]; k++; j--;
            }
            stockertabaff2[k] = ']'; k++;
            i--;
            j = i-1;
        }
        vider(stockertabaff);

    }
    | '(' ')' OPERATEUR AFFECTASANSMOINS {
        estfonction = 1;
    }
    | '(' ')'   {
        estfonction = 1;
    }
    | '(' MOINSCHOISIRPAR OPERATEUR AFFECTASANSMOINS    {
        estfonction = 1;
        nombrepar++;
    }
    | '(' MOINSCHOISIRPAR   {
        estfonction = 1;
        nombrepar++;


    }
    

TABLAFF:
    '[' NOMBRE ']' TABLAFF  {
        int i=0;
        while(stockertabaff[i] != '\0'){ i++;};
        stockertabaff[i] = '['; i++;
        int nombre = $2;
        char tabintermed[10];
        int n2;
        char n3;
        while(nombre > 0){
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertabaff[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }
        stockertabaff[i] = ']', i++;
    }
        
    | OPERATEUR AFFECTASANSMOINS    {
        int i=0; while(opaprestab[i] != '\0'){i++;} opaprestab[i] = 'a';
    }
    | '[' NOMBRE ']'   {
        int i=0;
        while(stockertabaff[i] != '\0'){ i++;};
        stockertabaff[i] = '['; i++;
        int nombre = $2;
        char tabintermed[10];
        int n2;
        char n3;
        while(nombre > 0){
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertabaff[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }
        stockertabaff[i] = ']', i++;
    }

BLOCK:
    IDENTIFICATEUR S2   {
        if (estvariable == 1){
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationVariable(block, nom);
            if (dec == 0){
                ajouterDansTableau(declarationblock, nom);
            }
            estvariable = 0;

            idDot++;
            insertionSommets(sommets, nom, idDot, 0, 0);
            idDot++;
            char egal[3] = {':', '=', '\0'};
            insertionSommets(sommets, egal, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, idDot-2);
            insertionId(blocksarr, idDot);
        }
        if (esttableau == 1){
            esttableau =0;
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationVariable(block, nom);
            if (dec == 0){
                printf("tableau: %s non declaré\n", nom);
                yyerror();
            }
            if (dec == 1){
                printf("%s n'est pas un tableau\n", nom);
                yyerror();
            }
            int i = 0; int j = 0;
            while(nom[i] != '\0'){
                stockertab[i]=nom[i]; i++;
            }
            while(stockertab2[j] != '\0'){
                stockertab[i] = stockertab2[j]; i++; j++;
            }
            //vider(stockertab2);
            dec = ControleTailleTableauBlocks(block, stockertab);
            if (dec == 0){
                printf("erreur de segmentation avec le tableau: %s\n", nom);
                yyerror();
            }
            vider(stockertab);

            int enregistreraff = idDot;
            idDot++;
            insertionSommets(sommets2, nom, idDot, 0, 0);
            int debut = idDot;
            char stockeraffpourDot[7];
            i=0; j=0;
            while(stockertab2[i] != '\0'){
                j=0;
                vider(stockeraffpourDot);
                i++;
                while(stockertab2[i] != ']'){
                    stockeraffpourDot[j] = stockertab2[i];
                    i++; j++;
                }
                i++;
                idDot++;
                if (stockeraffpourDot[0] == '\0'){stockeraffpourDot[0] = '0';}   //si = 0;
                insertionSommets(sommets2, stockeraffpourDot, idDot, 0, 0);
            }
            ViderPileSommets2();
            idDot++;
            char tabl[4] = {'T', 'A', 'B', '\0'};
            insertionSommets(sommets, tabl, idDot, 0, 0);
            while(debut < idDot){
                insertionArretes(arretes, idDot, debut);
                debut++;
            }
            vider(stockertab2);

            idDot++;
            char egal[3] = {':', '=', '\0'};
            insertionSommets(sommets, egal, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, enregistreraff);
            insertionId(blocksarr, idDot);
        }
        if (estfonction == 1){
            estfonction = 0;
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationFonction(listfonctions, nom);
            if (dec == 0){
                printf("fonction: %s non declaré\n", nom);
                yyerror();
            }
            int n;
            n = NombreParametreFonction(listfonctions, nom);
            if (nombrepar != n){
                printf("nombre de paramètres incorrecte pour la fonction: %s\n", nom);
                yyerror();
            }
            nombrepar = 0;

            idDot++;
            insertionSommets(sommets, nom, idDot, 5, 0);
            int k=0;
            while(parametresDot[k] != -1){
                insertionArretes(arretes, idDot, parametresDot[k]);
                parametresDot[k] = -1;
                k++;
            }
            k=0; while(finfonc[k] != -1){k++;}
            finfonc[k-1] = -1;
            insertionId(blocksarr, idDot);
        }
        
    }
    | CONSTANTE INT IDENTIFICATEUR IDS  {
        char nom[50]; int cop = 0; while($3[cop] != '\0'){nom[cop]=$3[cop];cop++;}; nom[cop]='\0';
        int dec = DeclarationVariableBlockCourrant(block, nom);
        if (dec == 1 || dec == 2){
            printf("variable: %s déjà declaré\n", nom);
            yyerror();
        }
        ajoutervariable(block, nom);
    }
    | INT IDENTIFICATEUR IDST   {
        if (stockertab2[0] != '\0'){        // c'est un tab
            char nom[50]; int cop = 0; while($2[cop] != '\0'){nom[cop]=$2[cop];cop++;}; nom[cop]='\0';
            int i = 0; int j = 0;
            while(nom[i] != '\0'){
                stockertab[i]=nom[i]; i++;
            }
            while(stockertab2[j] != '\0'){
                stockertab[i] = stockertab2[j]; i++; j++;
            }
            vider(stockertab2);
            int dec = DeclarationVariableBlockCourrant(block, stockertab);
            if (dec == 2){
                printf("tableau: %s déjà declaré\n", nom);
                yyerror();
            }
            if (dec == 1){
                printf("nom: %s déjà possédé par une variable\n", nom);
                yyerror();
            }
            ajoutervariable(block, stockertab);
            vider(stockertab);
        }
        if (estvariable == 1){      // c'est un variable
            char nom[50]; int cop = 0; while($2[cop] != '\0'){nom[cop]=$2[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationVariableBlockCourrant(block, nom);
            if (dec == 1 || dec == 2){
                printf("variable: %s déjà declaré\n", nom);
                yyerror();
            }
            ajoutervariable(block, nom);
            estvariable = 0;
        }
        
    }
    | RETURN RETURNA    {
        insertionId(blocksarr, idDot);
    }
    | BREAK ';' {
        idDot++;
        char break_[6] ={ 'B', 'R', 'E', 'A', 'K', '\0'};
        insertionSommets(sommets, break_, idDot, 4, 0);
        insertionId(blocksarr, idDot);
    }
    | FOR CFOR
    | WHILE CWHILE
    | IF CIF {
        insertionSommetBlocksArr(blocksarr, enrif);
        creerArretes(blocksarr, arretes);
        suppressionBlocksArr(blocksarr);
        insertionId(blocksarr, idDot);
    }
    | IF CIF ENRIF ELSE CELSE {
        insertionSommetBlocksArr(blocksarr, enrif2);
        creerArretes(blocksarr, arretes);
        suppressionBlocksArr(blocksarr);
        insertionSommetBlocksArr(blocksarr, enrif3);
        creerArretes(blocksarr, arretes);
        suppressionBlocksArr(blocksarr);
        insertionId(blocksarr, enrif3);
    }
    | SWITCH CSWITCH

ENRIF: {enrif2 = enrif; enrif3 = idDot;}

RETURNA:
    AFFECTA ';'   {
        AjoutePoosedeReturn(block);
        idDot++;
        char return_[7] = {'R', 'E', 'T', 'U', 'R', 'N', '\0'};
        insertionSommets(sommets, return_, idDot, 2, 1);
        insertionArretes(arretes, idDot, idDot-1);
        
    }
    | ';'   {
        idDot++;
        char return_[7] = {'R', 'E', 'T', 'U', 'R', 'N', '\0'};
        insertionSommets(sommets, return_, idDot, 2, 1);
        
    }

IDS:
    ';'
    | ',' IDENTIFICATEUR IDS    {
        char nom[50]; int cop = 0; while($2[cop] != '\0'){nom[cop]=$2[cop];cop++;}; nom[cop]='\0';
        int dec = DeclarationVariableBlockCourrant(block, nom);
        if (dec == 1 || dec == 2){
            printf("variable: %s déjà declaré\n", nom);
            yyerror();
        }
        ajoutervariable(block, nom); 
    }

IDST:
    PLUSIEURSIDSBLOCK   {
        estvariable = 1;
    }
    | '[' NOMBRE ']' TABBLOCK   {
        int i=0;
        while(stockertab[i] != '\0'){ i++;};
        stockertab[i] = '['; i++;
        int nombre = $2;
        char tabintermed[10];
        int n2;
        char n3;
        while(nombre > 0){
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertab[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }
        stockertab[i] = ']', i++;
        i =0; int j = 0; int k = 0;            //le tableau est à l'envers, donc on le met à l'endroit
        while(stockertab[i] != '\0'){i++;}
        j = i-2;
        while(i>0){
            while(stockertab[i] != '['){
                i--;
            }
            stockertab2[k] = '['; k++;
            while(stockertab[j] != '['){
                stockertab2[k] = stockertab[j]; k++; j--;
            }
            stockertab2[k] = ']'; k++;
            i--;
            j = i-1;
        }
        vider(stockertab);
    }

PLUSIEURSIDSBLOCK:
    ';'
    | ',' IDENTIFICATEUR PLUSIEURSIDSBLOCK  {
        char nom[50]; int cop = 0; while($2[cop] != '\0'){nom[cop]=$2[cop];cop++;}; nom[cop]='\0';
        int dec = DeclarationVariableBlockCourrant(block, nom);
        if (dec == 1 || dec == 2){
            printf("variable: %s déjà declaré\n", nom);
            yyerror();
        }
        ajoutervariable(block, nom);
    }

TABBLOCK:
    ';'
    | '[' NOMBRE ']' TABBLOCK   {
        int i=0;
        while(stockertab[i] != '\0'){ i++;};
        stockertab[i] = '['; i++;
        int nombre = $2;
        char tabintermed[10];
        int n2;
        char n3;
        while(nombre > 0){
            n2 = nombre%10;
            n3 = n2 + '0';
            stockertab[i] = n3; i++;
            nombre = nombre - n2;
            nombre = nombre / 10;
        }
        stockertab[i] = ']', i++;
    }

ENRFOR1:    {enrfor1 = idDot;}
ENRFOR2:    {enrfor2 = idDot;}
ENRFOR3:    {enrfor3 = idDot;}
CFOR:
    '(' IDENTIFICATEUR '=' AFFECTA ENRFOR1 ';' IDENTIFICATEUR COMP AFFECTA ENRFOR2 ';' IDENTIFICATEUR '=' AFFECTA ENRFOR3 ')' BOUCLE{
        char nom[50]; int cop = 0; while($2[cop] != '\0'){nom[cop]=$2[cop];cop++;}; nom[cop]='\0';
        int dec = DeclarationVariable(block, nom);
        if (dec == 0){
            ajouterDansTableau(declarationblock, nom);
        }
        char nom2[50]; int cop2 = 0; while($7[cop2] != '\0'){nom2[cop2]=$7[cop2];cop2++;}; nom2[cop2]='\0';
        dec = DeclarationVariable(block, nom2);
        if (dec == 0){
            ajouterDansTableau(declarationblock, nom2);
        }
        char nom3[50]; int cop3 = 0; while($12[cop3] != '\0'){nom3[cop3]=$12[cop3];cop3++;}; nom3[cop3]='\0';
        dec = DeclarationVariable(block, nom3);
        if (dec == 0){
            ajouterDansTableau(declarationblock, nom3);
        }

        char eg[3] = {':', '=', '\0'};
        idDot++;
        insertionSommets(sommets, nom, idDot, 0, 0);
        idDot++;
        insertionSommets(sommets2, eg, idDot, 0, 0);
        insertionArretes(arretes, idDot, idDot-1);
        insertionArretes(arretes, idDot, enrfor1);

        idDot++;
        insertionSommets(sommets, nom2, idDot, 0, 0);
        idDot++;    // le comparateur
        int i=0; while(listcomp[i]!='\0'){i++;}
        char compar[3] = {listcomp[i-1], '\0'};
        if (listcomp[i-1] == 'l'){
            compar[0] = '<'; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'g'){
            compar[0] = '>'; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'e'){
            compar[0] = '='; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'n'){
            compar[0] = '!'; compar[1] = '='; compar[2] = '\0';
        }
        listcomp[i-1] = '\0';
        insertionSommets(sommets2, compar, idDot, 0, 0);
        insertionArretes(arretes, idDot, idDot-1);
        insertionArretes(arretes, idDot, enrfor2);


        idDot++;
        insertionSommets(sommets, nom3, idDot, 0, 0);
        idDot++;
        insertionSommets(sommets2, eg, idDot, 0, 0);
        insertionArretes(arretes, idDot, idDot-1);
        insertionArretes(arretes, idDot, enrfor3);
        
        int j=0; while(boucleblock[j] != -1){j++;}
        if (boucleblock[j-1] == 0){
            ViderPileSommets2();
            boucleblock[j-1] = -1;
            idDot++;
            char nomfor[4] = {'F', 'O', 'R', '\0'};
            insertionSommets(sommets, nomfor, idDot, 0, 0);

            insertionSommetBlocksArr(blocksarr, idDot);
            creerArretes(blocksarr, arretes);
            suppressionBlocksArr(blocksarr);
            insertionId(blocksarr, idDot);

            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, idDot-3);
            insertionArretes(arretes, idDot, idDot-5);
        } else{     // si block
            boucleblock[j-1] = -1;
            idDot++;
            char nomblock[5] = {'B', 'L', 'O', 'C', '\0'};
            insertionSommets(sommets, nomblock, idDot, 0, 0);
            insertionSommetBlocksArr(blocksarr, idDot);
            creerArretes(blocksarr, arretes);
            suppressionBlocksArr(blocksarr);
            idDot++;
            char nomfor[4] = {'F', 'O', 'R', '\0'};
            insertionSommets(sommets, nomfor, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);

            insertionArretes(arretes, idDot, idDot-2);
            insertionArretes(arretes, idDot, idDot-4);
            insertionArretes(arretes, idDot, idDot-6);
            insertionId(blocksarr, idDot);
            ViderPileSommets2();
        }
    }

COMP:
    '<'     {int i=0; while(listcomp[i] != '\0'){i++;} listcomp[i] = '<';}
    | '>'   {int i=0; while(listcomp[i] != '\0'){i++;} listcomp[i] = '>';}
    | LEQ   {int i=0; while(listcomp[i] != '\0'){i++;} listcomp[i] = 'l';}
    | GEQ   {int i=0; while(listcomp[i] != '\0'){i++;} listcomp[i] = 'g';}
    | EQ    {int i=0; while(listcomp[i] != '\0'){i++;} listcomp[i] = 'e';}
    | NEQ   {int i=0; while(listcomp[i] != '\0'){i++;} listcomp[i] = 'n';}

BOUCLE:
    '{' RT BLOCK1 {
        int ret = AffichePossedeReturn(block);  //lorsqu'on quitte un boucle et que son possede return est à 1
        suppressionBlock(block);                //on met egalement à 1 dans son block (fonction)
        if (ret == 1){
            AjoutePoosedeReturn(block);
        }
        int i=0; while(boucleblock[i] != -1){i++;} boucleblock[i] = 1; boucleblock[i+1] = -1; 
    
    }
    | BREAK ';'     {
        insertionBlocksArr(blocksarr, 0);
        idDot++;
        char break_[6] = {'B', 'R', 'E', 'A', 'K', '\0'};
        insertionSommets(sommets, break_, idDot, 4, 0);
        insertionId(blocksarr, idDot);
        int i=0; while(boucleblock[i] != -1){i++;} boucleblock[i] = 0; boucleblock[i+1] = -1;

    }
    | RETURN RETURNA    {AjoutePoosedeReturn(block);
        insertionBlocksArr(blocksarr, 0);
        insertionId(blocksarr, idDot);
        int i=0; while(boucleblock[i] != -1){i++;} boucleblock[i] = 0; boucleblock[i+1] = -1;
    }
    | IDENTIFICATEUR S2     {
        if (estvariable == 1){
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationVariable(block, nom);
            if (dec == 0){
                printf("variable: %s non declaré\n", nom);
                yyerror();
            }
            estvariable = 0;

            insertionBlocksArr(blocksarr, 0);
            idDot++;
            insertionSommets(sommets, nom, idDot, 0, 0);
            idDot++;
            char egal[3] = {':', '=', '\0'};
            insertionSommets(sommets, egal, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, idDot-2);
            insertionId(blocksarr, idDot);
        }
        if (esttableau == 1){
            esttableau =0;
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationVariable(block, nom);
            if (dec == 0){
                printf("tableau: %s non declaré\n", nom);
                yyerror();
            }
            if (dec == 1){
                printf("%s n'est pas un tableau\n", nom);
                yyerror();
            }
            int i = 0; int j = 0;
            while(nom[i] != '\0'){
                stockertab[i]=nom[i]; i++;
            }
            while(stockertab2[j] != '\0'){
                stockertab[i] = stockertab2[j]; i++; j++;
            }
            
            dec = ControleTailleTableauBlocks(block, stockertab);
            if (dec == 0){
                printf("erreur de segmentation avec le tableau: %s\n", nom);
                yyerror();
            }
            vider(stockertab);

            insertionBlocksArr(blocksarr, 0);
            int enregistreraff = idDot;
            idDot++;
            insertionSommets(sommets2, nom, idDot, 0, 0);
            int debut = idDot;
            char stockeraffpourDot[7];
            i=0; j=0;
            while(stockertab2[i] != '\0'){
                j=0;
                vider(stockeraffpourDot);
                i++;
                while(stockertab2[i] != ']'){
                    stockeraffpourDot[j] = stockertab2[i];
                    i++; j++;
                }
                i++;
                idDot++;
                if (stockeraffpourDot[0] == '\0'){stockeraffpourDot[0] = '0';}   //si = 0;
                insertionSommets(sommets2, stockeraffpourDot, idDot, 0, 0);
            }
            ViderPileSommets2();
            idDot++;
            char tabl[4] = {'T', 'A', 'B', '\0'};
            insertionSommets(sommets, tabl, idDot, 0, 0);
            while(debut < idDot){
                insertionArretes(arretes, idDot, debut);
                debut++;
            }
            vider(stockertab2);

            idDot++;
            char egal[3] = {':', '=', '\0'};
            insertionSommets(sommets, egal, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, enregistreraff);
            insertionId(blocksarr, idDot);

        }
        if (estfonction == 1){
            estfonction = 0;
            char nom[50]; int cop = 0; while($1[cop] != '\0'){nom[cop]=$1[cop];cop++;}; nom[cop]='\0';
            int dec = DeclarationFonction(listfonctions, nom);
            if (dec == 0){
                printf("fonction: %s non declaré\n", nom);
                yyerror();
            }
            int n;
            n = NombreParametreFonction(listfonctions, nom);
            if (nombrepar != n){
                printf("nombre de paramètres incorrecte pour la fonction: %s\n", nom);
                yyerror();
            }
            nombrepar = 0;

            insertionBlocksArr(blocksarr, 0);
            idDot++;
            insertionSommets(sommets, nom, idDot, 5, 0);
            int k=0;
            while(parametresDot[k] != -1){
                insertionArretes(arretes, idDot, parametresDot[k]);
                parametresDot[k] = -1;
                k++;
            }
            k=0; while(finfonc[k] != -1){k++;}
            finfonc[k-1] = -1;
            insertionId(blocksarr, idDot);
        }
        int i=0; while(boucleblock[i] != -1){i++;} boucleblock[i] = 0; boucleblock[i+1] = -1;
    }

ENRWHILE1: {enrwhile1 = idDot;}
ENRWHILE2: {enrwhile2 = idDot;}
CWHILE:
    '(' AFFECTA ENRWHILE1 COMP AFFECTA ENRWHILE2 ')' BOUCLE  {
        idDot++;    // le comparateur
        int i=0; while(listcomp[i]!='\0'){i++;}
        char compar[3] = {listcomp[i-1], '\0'};
        if (listcomp[i-1] == 'l'){
            compar[0] = '<'; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'g'){
            compar[0] = '>'; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'e'){
            compar[0] = '='; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'n'){
            compar[0] = '!'; compar[1] = '='; compar[2] = '\0';
        }
        listcomp[i-1] = '\0';
        insertionSommets(sommets2, compar, idDot, 0, 0);
        insertionArretes(arretes, idDot, enrwhile1);
        insertionArretes(arretes, idDot, enrwhile2);

        int j=0; while(boucleblock[j] != -1){j++;}
        if (boucleblock[j-1] == 0){
            ViderPileSommets2();
            boucleblock[j-1] = -1;
            idDot++;
            char nomwhile[6] = {'W', 'H', 'I', 'L', 'E', '\0'};
            insertionSommets(sommets, nomwhile, idDot, 0, 0);

            insertionSommetBlocksArr(blocksarr, idDot);
            creerArretes(blocksarr, arretes);
            suppressionBlocksArr(blocksarr);
            insertionId(blocksarr, idDot);

            insertionArretes(arretes, idDot, idDot-1);
        }
        else{
            boucleblock[j-1] = -1;
            idDot++;
            char nomblock[5] = {'B', 'L', 'O', 'C', '\0'};
            insertionSommets(sommets, nomblock, idDot, 0, 0);
            insertionSommetBlocksArr(blocksarr, idDot);
            creerArretes(blocksarr, arretes);
            suppressionBlocksArr(blocksarr);
            idDot++;
            ViderPileSommets2();
            char nomwhile[6] = {'W', 'H', 'I', 'L', 'E', '\0'};
            insertionSommets(sommets, nomwhile, idDot, 0, 0);
            insertionArretes(arretes, idDot, idDot-1);

            insertionArretes(arretes, idDot, idDot-2);
            insertionId(blocksarr, idDot);
        }
    }
    
ENR1:    {enraff1 = idDot; EneleverPileSommet();}
ENR2:    {enraff2 = idDot; ViderPileSommets2();}
CIF:
    | '(' AFFECTA ENR1 COMP AFFECTA ENR2 ')' BOUCLE   {
        idDot++;    // le comparateur
        int i=0; while(listcomp[i]!='\0'){i++;}
        char compar[3] = {listcomp[i-1], '\0'};
        if (listcomp[i-1] == 'l'){
            compar[0] = '<'; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'g'){
            compar[0] = '>'; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'e'){
            compar[0] = '='; compar[1] = '='; compar[2] = '\0';
        }
        if (listcomp[i-1] == 'n'){
            compar[0] = '!'; compar[1] = '='; compar[2] = '\0';
        }
        listcomp[i-1] = '\0';
        insertionSommets(sommets, compar, idDot, 0, 0);

        insertionArretes(arretes, idDot, enraff1);
        insertionArretes(arretes, idDot, enraff2);


        int j=0; while(boucleblock[j] != -1){j++;}
        if (boucleblock[j-1] == 1){
            boucleblock[j-1] = -1;

            idDot++;
            char nomblock[5] = {'B', 'L', 'O', 'C', '\0'};
            insertionSommets(sommets, nomblock, idDot, 0, 0);
            idDot++;
            char if_[3] = {'I', 'F', '\0'};
            insertionSommets(sommets, if_, idDot, 3, 0);
            insertionArretes(arretes, idDot, idDot-1);
            insertionArretes(arretes, idDot, idDot-2);
            enrif=idDot-1;
        }
        else{
            boucleblock[j-1] = -1;
            idDot++;
            char if_[3] = {'I', 'F', '\0'};
            insertionSommets(sommets, if_, idDot, 3, 0);
            insertionArretes(arretes, idDot, idDot-1);

            enrif=idDot;
        }
    }

CELSE:
    IF CIF
    | BOUCLE

NVBLOCKID: {int i=0; while(enrswitch[i] != -1){enrswitch[i] = -1;i++;}; enrswitchaff = idDot;}
CSWITCH:
    '(' AFFECTA ')' NVBLOCKID '{' CCASE   {
        int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = enrswitchaff; enrswitch[i+1] = -1;
        idDot++;
        char nomswitch[7] = {'S', 'W', 'I', 'T', 'C', 'H', '\0'};
        insertionSommets(sommets, nomswitch, idDot, 0, 0);
        int j=0;
        while(enrswitch[j] != -1){
            insertionArretes(arretes, idDot, enrswitch[j]);
            j++;
        }
        insertionId(blocksarr, idDot);
    }

NOAFF: {suppressionSommets(sommets);} 

CCASE:
    CASE AFFECTA NOAFF ':' BOUCLE BREAK ';' CCASE {
        int j=0; while(boucleblock[j] != -1){j++;}
        boucleblock[j-1] = -1;
        idDot++;
        char break_[6] = {'B', 'R', 'E', 'A', 'K', '\0'};
        insertionSommets(sommets, break_, idDot, 4, 0);
        insertionId(blocksarr, idDot);
        idDot++;
        char nomblock[5] = {'B', 'L', 'O', 'C', '\0'};
        insertionSommets(sommets, nomblock, idDot, 0, 0);
        insertionSommetBlocksArr(blocksarr, idDot);
        creerArretes(blocksarr, arretes);
        suppressionBlocksArr(blocksarr);
        int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = idDot; enrswitch[i+1] = -1;
    }
    | CASE AFFECTA NOAFF ':' BOUCLE CCASE {
        int j=0; while(boucleblock[j] != -1){j++;}
        if (boucleblock[j-1] == 1){
            boucleblock[j-1] = -1;
            idDot++;
            char nomblock[5] = {'B', 'L', 'O', 'C', '\0'};
            insertionSommets(sommets, nomblock, idDot, 0, 0);
            insertionSommetBlocksArr(blocksarr, idDot);
            creerArretes(blocksarr, arretes);
            suppressionBlocksArr(blocksarr);
            int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = idDot; enrswitch[i+1] = -1;
        } else{
            boucleblock[j-1] = -1;
            ElemBlocksArr *actuel = blocksarr->premier;
            int s = actuel->tabids[0];
            suppressionBlocksArr(blocksarr);
            int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = s; enrswitch[i+1] = -1;
        }
    }
    | DEFAULT ':' BOUCLE '}'    {
        int j=0; while(boucleblock[j] != -1){j++;}
        if (boucleblock[j-1] == 1){
            boucleblock[j-1] = -1;
            idDot++;
            char nomblock[5] = {'B', 'L', 'O', 'C', '\0'};
            insertionSommets(sommets, nomblock, idDot, 0, 0);
            insertionSommetBlocksArr(blocksarr, idDot);
            creerArretes(blocksarr, arretes);
            suppressionBlocksArr(blocksarr);
            int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = idDot; enrswitch[i+1] = -1;
        } else{
            boucleblock[j-1] = -1;
            ElemBlocksArr *actuel = blocksarr->premier;
            int s = actuel->tabids[0];
            suppressionBlocksArr(blocksarr);
            int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = s; enrswitch[i+1] = -1;
        }
    }
    | CASE AFFECTA NOAFF ':' BOUCLE BREAK ';' '}' {
        int j=0; while(boucleblock[j] != -1){j++;}
        boucleblock[j-1] = -1;
        idDot++;
        char break_[6] = {'B', 'R', 'E', 'A', 'K', '\0'};
        insertionSommets(sommets, break_, idDot, 4, 0);
        insertionId(blocksarr, idDot);
        idDot++;
        char nomblock[5] = {'B', 'L', 'O', 'C', '\0'};
        insertionSommets(sommets, nomblock, idDot, 0, 0);
        insertionSommetBlocksArr(blocksarr, idDot);
        creerArretes(blocksarr, arretes);
        suppressionBlocksArr(blocksarr);
        int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = idDot; enrswitch[i+1] = -1;
    }
    | CASE AFFECTA NOAFF ':' BOUCLE '}'{
        int j=0; while(boucleblock[j] != -1){j++;}
        if (boucleblock[j-1] == 1){
            boucleblock[j-1] = -1;
            idDot++;
            char nomblock[5] = {'B', 'L', 'O', 'C', '\0'};
            insertionSommets(sommets, nomblock, idDot, 0, 0);
            insertionSommetBlocksArr(blocksarr, idDot);
            creerArretes(blocksarr, arretes);
            suppressionBlocksArr(blocksarr);
            int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = idDot; enrswitch[i+1] = -1;
        } else{
            boucleblock[j-1] = -1;
            ElemBlocksArr *actuel = blocksarr->premier;
            int s = actuel->tabids[0];
            suppressionBlocksArr(blocksarr);
            int i=0; while(enrswitch[i] != -1){i++;} enrswitch[i] = s; enrswitch[i+1] = -1;
        }
    }

%%

Fonctions *initialisationFonctions()    
{
    Fonctions *fonctions = malloc(sizeof(*fonctions));
    ElemFonc *elemfonc = malloc(sizeof(*elemfonc));

    elemfonc->nom[0] = '\0';
    elemfonc->suivant = NULL;
    fonctions->premier = elemfonc;
    elemfonc->typereturn = 0;
    elemfonc-> parametres[0] = '\0';

    return fonctions;
}

void insertionFonction(Fonctions *liste, char nvNom[50], char nvParametres[100], int nvTypereturn)
{
    // Création du nouvel élément 
    ElemFonc *nouveau = malloc(sizeof(*nouveau));
    
    int i=0;
    while(nvNom[i] != '\0')
    {
        nouveau->nom[i] = nvNom[i];
        i++;
    }
    i=0;
    while(nvParametres[i] != '\0')
    {   
        nouveau->parametres[i] = nvParametres[i];
        i++;
    }
    nouveau->typereturn = nvTypereturn;

    // Insertion de l'élément au début de la liste 
    nouveau->suivant = liste->premier;
    liste->premier = nouveau;
}

void insertionParametre(Fonctions *fonctions, char nvParametre[100], char NomFonction[20]) //ajoute dans le fonction 1er de la liste un parametre
{
    ElemFonc *actuel = fonctions->premier;

    while (actuel != NULL)
    {
        
        int i=0;
        while(actuel->nom[i] != '\0'){
            
            if (actuel->nom[i] != NomFonction[i]){
                break;
            }
            i++;
        }
        if (actuel->nom[i] == '\0' && NomFonction[i] == '\0'){
            i=0;
            while(actuel->parametres[i] != '\0'){
                i++;
            }
            if (i != 0){        // si pas de parametres
                actuel->parametres[i] = '/';
                i++;
            }
            while(nvParametre[i] != '\0')
            {   
                actuel->parametres[i] = nvParametre[i];
                i++;
            }
            return 0;
        }
        i=0;
        actuel = actuel->suivant;
    }
}

void afficherListeFonctions(Fonctions *fonctions)
{

    ElemFonc *actuel = fonctions->premier;

    while (actuel != NULL)
    {
        
        int i=0;
        while(actuel->nom[i] != '\0'){
            printf("%c", actuel->nom[i]);
            i++;
        }
        printf(" ");
        actuel = actuel->suivant;
    }
    printf("fin\n");
}


int DeclarationFonction(Fonctions *fonctions, char tab[100]){ // renvoi 1 si la fonction inscrit
    ElemFonc *actuel = fonctions->premier;          // dans tab existe dans fonctions (nom), 0 sinon

    while (actuel != NULL)
    {
        
        int i=0;
        while(actuel->nom[i] != '\0'){
            
            if (actuel->nom[i] != tab[i]){
                break;
            }
            i++;
        }
        if (actuel->nom[i] == '\0' && tab[i] == '\0'){
            return 1;
        }
        i=0;
        actuel = actuel->suivant;
    }
    return 0;
}

int NombreParametreFonction(Fonctions *fonctions, char NomFonction[20]){ //retourne le nombre de prametres qu'a cette fonction
    ElemFonc *actuel = fonctions->premier;
    while (actuel != NULL)
    {
        
        int i=0;
        while(actuel->nom[i] != '\0'){
            
            if (actuel->nom[i] != NomFonction[i]){
                break;
            }
            i++;
        }
        if (actuel->nom[i] == '\0' && NomFonction[i] == '\0'){      // l'a trouvé
            int nbr = 0;
            i = 0;
            while(actuel->parametres[i] != '\0'){
                nbr++;
                i++;
                while(actuel->parametres[i] != '/' && actuel->parametres[i] != '\0'){
                    i++;
                }
            }
            return nbr;

        }
        i=0;
        actuel = actuel->suivant;
    }
}






Blocks *initialisationBlocks()
{
    Blocks *blocks = malloc(sizeof(*blocks));
    ElemBlock *elemblock = malloc(sizeof(*elemblock));

    elemblock->suivant = NULL;
    blocks->premier = elemblock;
    elemblock->possedereturn = 0;
    elemblock->attendreturn = 0;
    elemblock-> variables[0] = '\0';

    return blocks;
}

void insertionBlock(Blocks *liste, char nvVariables[100], int nvPossedereturn, int nvAttendreturn)
{
    // Création du nouvel élément
    ElemBlock *nouveau = malloc(sizeof(*nouveau));
    
    int i=0;
    while(nvVariables[i] != '\0')
    {
        nouveau->variables[i] = nvVariables[i];
        i++;
    }
    nouveau->possedereturn = nvPossedereturn;
    nouveau->attendreturn = nvAttendreturn;


    // Insertion de l'élément au début de la liste 
    nouveau->suivant = liste->premier;
    liste->premier = nouveau;
}

void suppressionBlock(Blocks *blocks)   // Lorsqu'on quitte un block on le supprime
{


    if (blocks->premier != NULL)
    {
        ElemBlock *aSupprimer = blocks->premier;
        ElemBlock *a = blocks->premier;
        blocks->premier = a->suivant;
        free(aSupprimer);
    }
}


DeclarationVariable(Blocks *blocks, char tab[100]){  //renvoi 1 si le variable a été declaré dans un
                                            // block, 2 si c'est un tableau, sinon 0 (si declaré nul part).
    ElemBlock *actuel = blocks->premier;
    int br = 0;
    while (actuel != NULL){
        int i=0;
        int j=0;
        while(actuel->variables[i] != '\0'){
        
            if (tab[j] == '\0'){
                if (actuel->variables[i] == '/' || actuel->variables[i] == '=' || actuel->variables[i] == '['){
                    if (actuel->variables[i] == '['){
                        return 2;
                    }
                    
                    return 1;
                }
            
            }
            if (tab[j] != actuel->variables[i]){
                j = (-1);
                while(actuel->variables[i] != '\0' && actuel->variables[i] != '/'){
                    i++;
                }
                if (actuel->variables[i] == '\0'){
                    br = 1;
                    break;
                }
            }
            i++;
            j++;
        }
        if (br == 0){ 
            if (tab[j] == '\0'){        
                return 1;
            }
            if (tab[j] == '['){        
                return 2;
            }
        }
        br = 0;
        actuel = actuel->suivant;
    }
    return 0;
}

DeclarationVariableBlockCourrant(Blocks *blocks, char tab[100]){  //renvoi 1 si le variable a été declaré dans
                                            // block actuel, 2 si c'est un tableau, sinon 0.
    ElemBlock *actuel = blocks->premier;
    int br = 0;
    int i=0;
    int j=0;
    while(actuel->variables[i] != '\0'){
    
        if (tab[j] == '\0'){
            if (actuel->variables[i] == '/' || actuel->variables[i] == '=' || actuel->variables[i] == '['){
                if (actuel->variables[i] == '['){
                    return 2;
                }
                
                return 1;
            }
        
        }
        if (tab[j] != actuel->variables[i]){
            j = (-1);
            while(actuel->variables[i] != '\0' && actuel->variables[i] != '/'){
                i++;
            }
            if (actuel->variables[i] == '\0'){
                br = 1;
                break;
            }
        }
        i++;
        j++;
    }
    if (br == 0){ 
        if (tab[j] == '\0'){        
            return 1;
        }
        if (tab[j] == '['){        
            return 2;
        }
    }
    return 0;
}

ControleTailleTableau(char tab[100], ElemBlock *actuel){           // si tab a les bonnes dimensions et si la case
                                                // qu'on essaye d'acceder existe dans le tableau on renvoi 1.
                                                // dans le block actuel!
    int i=0;
    int j=0;
    while(tab[j] != '[' && (actuel->variables[i] != '[' && actuel->variables[i] != '/' && actuel->variables[i] != '=')){    //on le trouve
    
        if (actuel->variables == '\0'){
            return 0;
        }
        if (tab[j] != actuel->variables[i]){
            j= -1;
            while(actuel->variables[i] != '\0' && actuel->variables[i] != '/'){
                i++;
            }
            if (actuel->variables[i] == '\0'){
                return 0;
            }
        }
        i++;
        j++;
    }
    if (actuel->variables[i] == '\0' || actuel->variables[i] == '=' || actuel->variables[i] == '/'){
        return 0;
    }
    while (tab[j] != '\0' && actuel->variables[i] != '\0' && actuel->variables[i] != '/'){
        i++;
        j++;    //on passe le [
        int b=1;  
        while (tab[j] != ']' && actuel->variables[i] != ']'){ // on controle que l'indice de variables >= indice de tab
            if (((int)(tab[j])) > (int)(actuel->variables[i])){
                b=0;
                break;
            }
            if (((int)(tab[j])) < (int)(actuel->variables[i])){
                break;
            }
            i++;
            j++;
        }
        int jj=0;
        int ii=0;   //compte nombre de chiffres entre les crochets des deux tableaux
        while (tab[j] != ']'){
            jj++;
            j++;
        }
        while (actuel->variables[i] != ']'){
            ii++;
            i++;
        }
        if (jj > ii){
            return 0;
        }
        if (jj == ii){
            if (b == 0){
                return 0;
            }
        }
        i++;
        j++;
    }
    if (tab[j] == '[' || actuel->variables[i] == '['){
        return 0;
    }
    return 1;
}

ControleTailleTableauBlocks(Blocks *blocks, char tab[100]){  // idem pour tous les blocks
    
    ElemBlock *actuel = blocks->premier;
    int bon = 0;
    while (actuel != NULL){
        bon = ControleTailleTableau(tab, actuel);
        if (bon == 1){
            return 1;
        }
        actuel = actuel->suivant;
    }
    return 0;
}

void afficherListeBlocks(Blocks *blocks)    // pour tester des choses
{

    ElemBlock *actuel = blocks->premier;
  
    int i=0;
    while(actuel->variables[i] != '\0'){
        printf("%c", actuel->variables[i]);
        i++;
    }
    printf(" \n");
}

void decalertableau(int cases, int depart, Blocks *blocks){   //decale variables des cases a droite a partir de depart
    ElemBlock *actuel = blocks->premier;
    int i=0;
    while( actuel->variables[i] != '\0'){
        i++;
    }
    while(i>=depart){
        actuel->variables[i+cases] = actuel->variables[i];
        i--;
    }

}

void insererMilieuTableau(Blocks *blocks, char tabainserer[10], int indice){   //insere un autre tableau dans variables de Blocks
    ElemBlock *actuel = blocks->premier;
    int taille = 0;
    while(tabainserer[taille] != '\0'){
        taille++;
    }
    decalertableau(taille, indice, blocks);
    int i=0;
    while(i<taille){
        actuel->variables[indice] = tabainserer[i];
        indice++;
        i++;
    }
}


void ajoutervariable(Blocks *blocks, char nvVariable[20]){  // ajout variable ou tableau après une declaration
    ElemBlock *actuel = blocks->premier;
    int i=0;
    while(actuel->variables[i] != '\0'){    // on accede à la fin de la liste des variables
        i++;
    }
    if (i != 0){
        actuel->variables[i] = '/';
        i++;
    }
    int j=0;
    while(nvVariable[j] != '\0'){
        actuel->variables[i] = nvVariable[j];
        i++;
        j++;
    }
    actuel->variables[i] = '\0';
}


int ControleValeurVariable(Blocks *blocks, char variable[20]){ //renvoi 1 si le variable possede un valeur, 0 sinon
    ElemBlock *actuel = blocks->premier;
    int i=0;
    int j=0;
    while ((actuel->variables[i] != '/' && actuel->variables[i] != '\0' && actuel->variables[i] != '=') || variable[j] != '\0'){
        if (actuel->variables[i] != variable[j]){
            j= -1;
            while (actuel->variables[i] != '/'){
                i++;
            }

        }
        j++;
        i++;
    }
    if (actuel->variables[i] == '='){
        return 1;
    }
    return 0;
}

void AjoutePoosedeReturn(Blocks *blocks){    // met possedereturn du block courant à 1
    ElemBlock *actuel = blocks->premier;
    actuel->possedereturn = 1;
}

int AfficheAttendReturn(Blocks *blocks){     // renvoi attendreturn du block courant
    ElemBlock *actuel = blocks->premier;
    return (actuel->attendreturn);
}

int AffichePossedeReturn(Blocks *blocks){     // renvoi possedereturn du block courant
    ElemBlock *actuel = blocks->premier;
    return (actuel->possedereturn);
}

void copier(char tab1[20], char tab2[20]){
    //printf("%c\n", tab1[1]);
    int i=0;
    while(tab1[i] != '\0' && tab1[i] != NULL){
        tab2[i] = tab1[i];
        //printf("%c\n", tab1[i]);
        i++;
    }
    tab2[i] = '\0';
}

void vider(char tab[20]){
    for (int i=0; i<20; i++){
        tab[i] = NULL;
    }
}

void ajouterDansTableau(char tab[100], char element[30]){
    int i=0;
    while(tab[i] != '\0'){
        i++;
    }
    if (i != 0){
        tab[i] = '/';
        i++;
    }
    int j=0;
    while(element[j] != '\0'){
        tab[i] = element[j];
        i++;
        j++;
    }
}

int SupprimerDansTab(char tab[100], char element[20]){  // supprime element dans tab si il y est
    int i=0;
    int j=0;
    int taille=0;
    while(element[taille] != '\0'){
        taille++;
    }
    while(tab[i] != '\0'){
    
        if (element[j] == '\0'){
            if (tab[i] == '/'){
        
                i++;
                taille++;
                while(tab[i] != '\0'){
                    tab[i-taille] = tab[i];
                    i++;
                }
                i= i - taille;
                while(tab[i] != '\0'){
                    tab[i] = '\0';
                    i++;
                }
            }
        
        }
        if (element[j] != tab[i]){
            j = (-1);
            while(tab[i] != '\0' && tab[i] != '/'){
                i++;
            }
            if (tab[i] == '\0'){
                return 0;
            }
        }
        i++;
        j++;
    }
    if (element[j] != '\0'){        
        return 0;
    }

    taille++;
    i= i - taille;
    if (i == -1){
        i++;
    }
    while(tab[i] != '\0'){
        tab[i] = '\0';
        i++;
    }
    return 0;
}

int estDansTableau(char tab[100], char element[20]){    // 1 si est dans tableau 0 sinon
    int i=0;
    int j=0;
    while(tab[i] != '\0' && element[j] != '\0'){
        if (tab[i] != element[j]){
            j=0;
            while(tab[i] != '/' && tab[i] != '\0'){
                i++;
            }
            if (tab[i] == '\0'){
                return 0;
            }
            i++;
        }
        else{
            i++; j++;
            if (element[j] == '\0' && tab[i] != '\0' && tab[i] != '/'){
                while(tab[i] != '/' && tab[i] != '\0'){
                    i++;
                }
                if (tab[i] == '\0'){
                    return 0;
                }
                i++;
                j=0;
            }
        }        
    }
    if (element[j] == '\0' && (tab[i] == '\0' || tab[i] == '/')){
        return 1;
    }
    return 0;
}

int AfficheFonctionReturn(Fonctions *fonctions, char nom[20]){     // renvoi typereturn de la fonction
    ElemFonc *actuel = fonctions->premier;
    while (actuel != NULL){

        int i=0;
        while (nom[i] != '\0'){
            if (nom[i] != actuel->nom[i]){
                break;
            }
            i++;
        }
        if (actuel->nom[i] == '\0'){
            return actuel->typereturn;
        }
        actuel = actuel->suivant;
    }
}


Sommets *initialisationSommets()    
{
    Sommets *sommets = malloc(sizeof(*sommets));
    ElemSommets *elemsommets = malloc(sizeof(*elemsommets));

    elemsommets->nom[0] = '\0';
    elemsommets->suivant = NULL;
    sommets->premier = elemsommets;
    elemsommets->id = 0;
    elemsommets->forme = 0;
    elemsommets->couleur = 0;

    return sommets;
}

Arretes *initialisationArretes()    
{
    Arretes *arretes = malloc(sizeof(*arretes));
    ElemArretes *elemarretes = malloc(sizeof(*elemarretes));

    elemarretes->suivant = NULL;
    arretes->premier = elemarretes;
    elemarretes->id1 = 0;
    elemarretes->id2 = 0;

    return arretes;
}

BlocksArr *initialisationBlocksArr()    
{
    BlocksArr *blocksarr = malloc(sizeof(*blocksarr));
    ElemBlocksArr *elemblocksarr = malloc(sizeof(*elemblocksarr));

    elemblocksarr->suivant = NULL;
    blocksarr->premier = elemblocksarr;
    elemblocksarr->sommet = 0;
    elemblocksarr->tabids[0] = 0;       // termine tjrs par un 0 (equivalant du '\0' quand string)

    return elemblocksarr;
}


void insertionSommets(Sommets *liste, char nvNom[50], int nvId, int nvForme, int nvCouleur)
{
    // Création du nouvel élément 
    ElemSommets *nouveau = malloc(sizeof(*nouveau));
    
    int i=0;
    while(nvNom[i] != '\0')
    {
        nouveau->nom[i] = nvNom[i];
        i++;
    }
    nouveau->id = nvId;
    nouveau->forme = nvForme;
    nouveau->couleur = nvCouleur;

    // Insertion de l'élément au début de la liste 
    nouveau->suivant = liste->premier;
    liste->premier = nouveau;
}

void insertionArretes(Arretes *liste, int nvId1, int nvId2)
{
    // Création du nouvel élément 
    ElemArretes *nouveau = malloc(sizeof(*nouveau));
    
    nouveau->id1 = nvId1;
    nouveau->id2 = nvId2;

    // Insertion de l'élément au début de la liste 
    nouveau->suivant = liste->premier;
    liste->premier = nouveau;
}

void insertionBlocksArr(BlocksArr *liste, int nvSommet)
{
    // Création du nouvel élément 
    ElemBlocksArr *nouveau = malloc(sizeof(*nouveau));
    
    
    nouveau->sommet = nvSommet;
    nouveau->tabids[0] = 0;

    // Insertion de l'élément au début de la liste 
    nouveau->suivant = liste->premier;
    liste->premier = nouveau;
}

void insertionId(BlocksArr *blocksarr, int nvId) //ajoute dans le block courrant un nouveau id dans la liste
{
    ElemBlocksArr *actuel = blocksarr->premier;
    int i=0;
    while(actuel->tabids[i] != 0){
        i++;
    }
    actuel->tabids[i] = nvId;
    actuel->tabids[i+1] = 0;
}

void insertionSommetBlocksArr(BlocksArr *blocksarr, int nvSommet) //ajoute dans le block courrant un sommet
{
    ElemBlocksArr *actuel = blocksarr->premier;
    actuel->sommet = nvSommet;
}

void suppressionBlocksArr(BlocksArr *blocksarr)  
{
    if (blocksarr->premier != NULL)
    {
        ElemBlocksArr *aSupprimer = blocksarr->premier;
        ElemBlocksArr *a = blocksarr->premier;
        blocksarr->premier = a->suivant;
        free(aSupprimer);
    }
}

void suppressionSommets(Sommets *sommets)
{
    if (sommets->premier != NULL)
    {
        ElemSommets *aSupprimer = sommets->premier;
        ElemSommets *a = sommets->premier;
        sommets->premier = a->suivant;
        free(aSupprimer);
    }
}

void creerArretes(BlocksArr *blocksarr, Arretes *arretes){
    ElemBlocksArr *actuel = blocksarr->premier;
    int i=0;
    while(actuel->tabids[i] != 0){
        insertionArretes(arretes, actuel->sommet, actuel->tabids[i]);
        i++;
    }
}

/*
int CreationfichierDot(Sommets *sommets, Arretes *arretes) {
    ElemSommets *actuelS = sommets->premier;
    ElemArretes *actuelA = arretes->premier;
    FILE *f;

    f = fopen("FichierDot.dot", "w");
    if (f == NULL) {
        perror("FichierDot.dot");
        return -1;
    }

    fprintf(f, "digraph mon_programme {\n");

    // Parcours des sommets
    while (actuelS != NULL) {
        fprintf(f, "\tnode_%d [label=\"%s\" shape=", actuelS->id, actuelS->nom);

        // Choix de la forme en fonction du type de sommet
        switch (actuelS->forme) {
            case 0:
                fprintf(f, "ellipse");
                break;
            case 1:
                fprintf(f, "invtrapezium");
                break;
            case 2:
                fprintf(f, "trapezium");
                break;
            case 3:
                fprintf(f, "diamond");
                break;
            case 4:
                fprintf(f, "rect");
                break;
            case 5:
                fprintf(f, "septagon"); // polygon fait des rectangles bizarrement
                break;
            default:
                break;
        }

        fprintf(f, " color=");
        if (actuelS->couleur == 0) {
            fprintf(f, "black");
        } else if (actuelS->couleur == 1) {
            fprintf(f, "blue");
        }

        fprintf(f, "];\n");
        actuelS = actuelS->suivant;
    }

    fprintf(f, "\n");

    // Parcours des arêtes
    while (actuelA != NULL) {
        fprintf(f, "\tnode_%d -> node_%d;\n", actuelA->id1, actuelA->id2);
        actuelA = actuelA->suivant;
    }

    fprintf(f, "}");
    fclose(f);

    return 0;
}*/

// Création du fichier DOT
int CreationfichierDot(Sommets *sommets, Arretes *arretes){

    ElemSommets *actuelS = sommets->premier;
    ElemArretes *actuelA = arretes->premier;
    FILE * f;

    f = fopen("FichierDot.dot", "w");
    if (f != NULL)
    {
        fprintf(f, "digraph mon_programme {\n");
        while (actuelS->suivant != NULL){

            fprintf(f, "\tnode_%d [label=", actuelS->id);
            fprintf(f, "\"");
            fprintf(f, "%s", actuelS->nom);
            fprintf(f, "\"");
            fprintf(f, " shape=");
            if (actuelS->forme == 0){
                fprintf(f, "ellipse");
            }
            if (actuelS->forme ==1){
                fprintf(f, "invtrapezium");
            }
            if (actuelS->forme ==2){
                fprintf(f, "trapezium");
            }
            if (actuelS->forme ==3){
                fprintf(f, "diamond");
            }
            if (actuelS->forme ==4){
                fprintf(f, "rect");
            }
            if (actuelS->forme ==5){
                fprintf(f, "septagon");     //polygon fait des rectangles bizzarement
            }
            fprintf(f, " color=");
            if (actuelS->couleur ==0){
                fprintf(f, "black");
            }
            if (actuelS->couleur ==1){
                fprintf(f, "blue");
            }
            fprintf(f, "];\n");
            actuelS = actuelS->suivant;
        }
        fprintf(f, "\n");
        while (actuelA->suivant != NULL){
            fprintf(f, "\tnode_%d -> node_%d;\n", actuelA->id1, actuelA->id2);
            actuelA = actuelA->suivant;
        }

        fprintf(f, "}");
        fclose(f);
    }
    else
        perror("FichierDot.dot");
    return 0;
}



// FOnction pour vider sommets2 dans sommets
void ViderPileSommets2()
{
    ElemSommets* sommetCourant2 = sommets2->premier;
    
    while (sommetCourant2->suivant != NULL){
        insertionSommets(sommets, sommetCourant2->nom, sommetCourant2->id, sommetCourant2->forme, sommetCourant2->couleur);
        suppressionSommets(sommets2);
        sommetCourant2 = sommetCourant2->suivant;
    }
}

void EneleverPileSommet()
{
    ElemSommets* sommetCourant = sommets->premier;
    insertionSommets(sommets2, sommetCourant->nom, sommetCourant->id, sommetCourant->forme, sommetCourant->couleur);
    suppressionSommets(sommets);
}


int yyerror( char *s) {
    fprintf( stderr, "ligne %d, %s\n", yylineno, s);
    exit(1); /* erreur de synthaxe */
}

int main(){
    hautaffecta[0] = 0;
    finfonc[0] = -1;
    parametresDot[0] = -1;
    enregistrer[0] = -1;
    boucleblock[0] = -1;    // 1 = on doit creer un sommet block, sinon 0
    enrswitch[0] = -1;
    idDot = 0;
    listfonctions = initialisationFonctions();
    block = initialisationBlocks();
    sommets = initialisationBlocks();
    sommets2 = initialisationBlocks();
    arretes = initialisationArretes();
    blocksarr = initialisationBlocksArr();
    yyparse();
    CreationfichierDot(sommets, arretes);
    system("dot -Tpdf FichierDot.dot -o FichierDotOut.pdf");
    return 0;
}
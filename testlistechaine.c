#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

typedef struct ElemFonc ElemFonc;   // liste chainé des fonctions declarés.
struct ElemFonc
{
    char nom[50];
    int typereturn;     // 0 = void et 1 = int
    char parametres[200];    // chaque nom de parametre est separé par un '_'
    ElemFonc *suivant;
};

typedef struct Fonctions Fonctions;
struct Fonctions
{
    Fonctions *premier;
};

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
                actuel->parametres[i] = '_';
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
                while(actuel->parametres[i] != '_' && actuel->parametres[i] != '\0'){
                    i++;
                }
            }
            return nbr;

        }
        i=0;
        actuel = actuel->suivant;
    }
}






typedef struct ElemBlock ElemBlock;
struct ElemBlock
{
    int attendreturn;   // 0 = non et 1 = oui, si block d'une fonction qui a un type return de int alors = 1.
    int possedereturn;     // 0 = non et 1 = oui (de base 0, quand trouve return : ca passe à 1)
    char variables[200];    // chaque variable est separé par un '_', il peut etre ecrit de
                            // la facon var=nombre si il a une valeur ou de la facon
                            // var[nrb][nbr]... si un tableau
    ElemBlock *suivant;
};

typedef struct Blocks Blocks;
struct Blocks
{
    Blocks *premier;
};

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


DeclarationVariable(Blocks *blocks, char tab[100]){  //renvoi 1 si le variable ou tableau a 
                                            // été declaré dans le block actuel (premier), sinon 0.
    ElemBlock *actuel = blocks->premier;
    while (actuel != NULL){
        int i=0;
        int j=0;
        while(actuel->variables[i] != '\0'){
        
            if (tab[j] == '\0'){
                if (actuel->variables[i] == '_' || actuel->variables[i] == '=' || actuel->variables[i] == '['){
                    return 1;
                }
            
            }
            if (tab[j] != actuel->variables[i]){
                j = (-1);
                while(actuel->variables[i] != '\0' && actuel->variables[i] != '_'){
                    i++;
                }
                if (actuel->variables[i] == '\0'){
                    return 0;
                }
            }
            i++;
            j++;
        }
        if (tab[j] == '\0'){        
            return 1;
        }
        actuel = actuel->suivant;
    }
    return 0;
}

ControleTailleTableau(Blocks *blocks, char tab[100]){ // si tab a les bonnes dimensions et si la case
                                                // qu'on essaye d'acceder existe dans le tableau on renvoi 1.
    ElemBlock *actuel = blocks->premier;
    int i=0;
    int j=0;
    while(tab[j] != '[' && (actuel->variables[i] != '[' && actuel->variables[i] != '_' && actuel->variables[i] != '=')){    //on le trouve
    
        if (actuel->variables == '\0'){
            return 0;
        }
        if (tab[j] != actuel->variables[i]){
            j= -1;
            while(actuel->variables[i] != '\0' && actuel->variables[i] != '_'){
                i++;
            }
            if (actuel->variables[i] == '\0'){
                return 0;
            }
        }
        i++;
        j++;
    }
    if (actuel->variables[i] == '\0' || actuel->variables[i] == '=' || actuel->variables[i] == '_'){
        return 0;
    }
    while (tab[j] != '\0' && actuel->variables[i] != '\0' && actuel->variables[i] != '_'){
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
        if (b == 0){
            return 0;
        }
        i++;
        j++;
    }
    if (tab[j] == '[' || actuel->variables[i] == '['){
        return 0;
    }
    return 1;
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
        actuel->variables[i] = '_';
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

void AjouterValeurVariable(Blocks *blocks, char variable[20], char valeur[20]){ // ajoute un '=' et une valeur après un variable si on lui donne une valeur (qui n'en a pas encore)
    ElemBlock *actuel = blocks->premier;
    int i=0;
    int j=0;
    while ((actuel->variables[i] != '_' && actuel->variables[i] != '\0') || variable[j] != '\0'){
        if (actuel->variables[i] != variable[j]){
            j= -1;
            while (actuel->variables[i] != '_'){
                i++;
            }

        }
        j++;
        i++;
    }
    char egal[2] = {'=', '\0'};
    insererMilieuTableau(blocks, egal, i);
    insererMilieuTableau(blocks, valeur, i+1);
}

int ControleValeurVariable(Blocks *blocks, char variable[20]){ //renvoi 1 si le variable possede un valeur, 0 sinon
    ElemBlock *actuel = blocks->premier;
    int i=0;
    int j=0;
    while ((actuel->variables[i] != '_' && actuel->variables[i] != '\0' && actuel->variables[i] != '=') || variable[j] != '\0'){
        if (actuel->variables[i] != variable[j]){
            j= -1;
            while (actuel->variables[i] != '_'){
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

int SupprimerDansTab(char tab[100], char element[20]){  // supprime element dans tab si il y est
    int i=0;
    int j=0;
    int taille=0;
    while(element[taille] != '\0'){
        taille++;
    }
    while(tab[i] != '\0'){
    
        if (element[j] == '\0'){
            if (tab[i] == '_'){
        
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
            while(tab[i] != '\0' && tab[i] != '_'){
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
            while(tab[i] != '_' && tab[i] != '\0'){
                i++;
            }
            if (tab[i] == '\0'){
                return 0;
            }
            i++;
        }
        else{
            i++; j++;
            if (element[j] == '\0' && tab[i] != '\0' && tab[i] != '_'){
                while(tab[i] != '_' && tab[i] != '\0'){
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
    if (element[j] == '\0' && (tab[i] == '\0' || tab[i] == '_')){
        return 1;
    }
    return 0;
}


int main()
{
    Fonctions *maListe = initialisationFonctions();

    char nom1[50] ={ 'N', 'o', 'm', '1', '\0' };
    char nom2[50] ={ 'N', 'o', 'm', '2', '\0' };
    char nom3[50] ={ 'N', 'o', 'm', '3', '\0' };

    char par1[100] = {'i', '_', 'i','y','_', 'j', '\0'};
    char par2[100] = {'i','y','\0'};
    char par3[100] = {'i', 'k', 'l', '_', 'j', '\0'};

    insertionFonction(maListe, nom1, par1, 0);
    insertionFonction(maListe, nom2, par2, 1);
    insertionFonction(maListe, nom3, par3, 1);
    insertionParametre(maListe, par2, nom3);
    insertionParametre(maListe, par2, nom3);
    int nn = NombreParametreFonction(maListe, nom3);
    printf("nombre de par:%d\n", nn);

    Blocks *listeblocks = initialisationBlocks();
    char variabless[100] = {'i', 'k', 'l', '_', 'j','[','5',']','[','1','0','0',']', '\0'};
    insertionBlock(listeblocks, variabless, 0, 0);

    char vari[100] = {'i', 'k', 'l', '\0'};
    char valeur[10] = {'6','9','\0'};
    AjouterValeurVariable(listeblocks, vari, valeur);
    afficherListeBlocks(listeblocks);
    AjoutePoosedeReturn(listeblocks);
    int a = AfficheAttendReturn(listeblocks);
    int p = AffichePossedeReturn(listeblocks);
    printf("a = %d, p = %d\n", a, p);


    char p1[100] = {'i','\0'};
    char p2[100] = {'i','\0'};
    
    if (estDansTableau(p1, p2)){
        SupprimerDansTab(p1, p2);
    }
    printf(":%c%c%c%c%c%c%c:\n\n\n", p1[0], p1[1], p1[2], p1[3], p1[4], p1[5], p1[6]);

    int hh = AfficheFonctionReturn(maListe, nom2);
    printf("%d\n", hh);
   
    return 0;
}
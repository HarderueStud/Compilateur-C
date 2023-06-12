typedef struct ElemFonc ElemFonc;   // liste chainé des fonctions declarés.
struct ElemFonc
{
    char nom[50];       // Ex: si je declare les fonctions i, toto et titi, 
                        // nom va ressemble à: {'i', '/', 't', 'o', 't', 'o',
                        // '/', 't', 'i', 't', 'i', '\0'}
    int typereturn;     // 0 = void et 1 = int      si il est sensé renvoyer un int ou void
    char parametres[200];    // chaque nom de parametre est separé par un '/'
    ElemFonc *suivant;
};

typedef struct Fonctions Fonctions;
struct Fonctions
{
    Fonctions *premier;
};

typedef struct ElemBlock ElemBlock;     // les variables déclarés dans chaque block
struct ElemBlock
{
    int attendreturn;   // 0 = non et 1 = oui, si block d'une fonction qui a un typereturn de int alors = 1.
    int possedereturn;     // 0 = non et 1 = oui (de base 0, quand trouve return : ça passe à 1)
    char variables[200];    // chaque variable est separé par un '/', il peut etre ecrit de
                            // la facon var=nombre si il a une valeur ou de la façon
                            // var[nrb][nbr]... si un tableau
    ElemBlock *suivant;
};

typedef struct Blocks Blocks;
struct Blocks
{
    Blocks *premier;
};

typedef struct ElemSommets ElemSommets;   // liste chainé des sommets.
struct ElemSommets
{
    char nom[50];
    int id;     // son identificateur
    int forme;    //    0=cercle 1=trapèze_vers_le_bas 2=trapèze_vers_haut 3=losange 4=rectangle 5=polygone
    int couleur;    //  0 = noir et 1 = bleu
    ElemSommets *suivant;
};

typedef struct Sommets Sommets;
struct Sommets
{
    Sommets *premier;
};

typedef struct ElemArretes ElemArretes;   // liste chainé des arretes.
struct ElemArretes
{
    int id1;     
    int id2;    //  On obtiendra id1 ---> id2
    ElemArretes *suivant;
};

typedef struct Arretes Arretes;
struct Arretes
{
    Arretes *premier;
};

typedef struct ElemBlocksArr ElemBlocksArr;   // liste chainé pour stocker les éléments d'un block.
struct ElemBlocksArr
{
    int tabids[50];    // liste des identificateurs vers qui le sommet du block devra pointer
    int sommet;     // identificateur du sommet qui est le block qui pointe vers touts ces fils
    ElemBlocksArr *suivant;
};

typedef struct BlocksArr BlocksArr;
struct BlocksArr
{
    BlocksArr *premier;
};
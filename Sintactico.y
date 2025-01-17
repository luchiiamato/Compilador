%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"


int yystopparser=0;
FILE *yyin;
%}

%union {
int intval;
double val;
char *str_val;
}

%token <str_val>ID <int>CTE_E <double>CTE_R <str_val>CTE_S
%token C_REPEAT_A C_REPEAT_C C_IF_A C_IF_E C_IF_C
%token C_FILTER C_FILTER_REFENTEROS
%token PRINT READ
%token VAR ENDVAR CONST INTEGER FLOAT STRING
%token OP_ASIG OP_SUMARESTA OP_MULDIV
%token PARENTESIS_A PARENTESIS_C LLAVE_A LLAVE_C CORCHETE_A CORCHETE_C COMA PYC DOSPUNTOS
%token OP_COMPARACION OP_LOGICO OP_NEGACION


%%

start				:		archivo ; /* SIMBOLO INICIAL */

/* DECLARACION GENERAL DE PROGRAMA
	- DECLARACIONES Y CUERPO DE PROGRAMA
	- CUERPO DE PROGRAMA
*/
archivo				:		{ printf("\t\t---INICIO PRINCIPAL DEL PROGRAMA---\n\n"); } VAR { printf("INICIO DECLARACIONES\n"); } bloqdeclaracion ENDVAR { printf("FIN DECLARACIONES\n\n"); } { printf("INICIO PROGRAMA\n"); } bloqprograma { printf("\n\n\t\t---FIN PRINCIPAL DEL PROGRAMA---\n\n"); };

/* REGLAS BLOQUE DE DECLARACIONES */
bloqdeclaracion		:		bloqdeclaracion declaracion ;
bloqdeclaracion		:		declaracion ;

declaracion			:		CORCHETE_A listatipos CORCHETE_C DOSPUNTOS CORCHETE_A listavariables CORCHETE_C PYC ;

listatipos			:		listatipos COMA INTEGER |
							listatipos COMA FLOAT 	;
listatipos			:		INTEGER |
							FLOAT	;
							
listavariables		:		listavariables COMA ID ;
listavariables		:		ID;
/* FIN REGLAS BLOQUE DE DECLARACIONES */

/* REGLAS BLOQUE DE CUERPO DE PROGRAMA */
bloqprograma		:		bloqprograma sentencia ;
bloqprograma		:		sentencia ;

sentencia			:		constante 	| /* DEFINICION DE CONSTANTE */
							asignacion	| 
							decision	| /* IF */
							bucle		| /* REPEAT */
							imprimir	| /* PRINT */
							leer		; /* READ */
							/*	VA FILTRO? */
imprimir			:		PRINT CTE_S	PYC	|
							PRINT ID PYC	;
leer				:		READ ID	PYC		;
							
							
constante			:		CONST ID OP_ASIG varconstante PYC ;
varconstante		:		CTE_E	|
							CTE_R	|
							CTE_S	;

asignacion			:		ID OP_ASIG varconstante PYC |
							ID OP_ASIG ID PYC			;
							
decision			:		C_IF_A PARENTESIS_A condicion PARENTESIS_C LLAVE_A bloqprograma LLAVE_C ;
/* VA CON ELSE? */

condicion			:		comparacion											|
							OP_NEGACION PARENTESIS_A comparacion PARENTESIS_C	|
							comparacion OP_LOGICO comparacion					;


comparacion			:		expresion OP_COMPARACION expresion	|
							filtro OP_COMPARACION expresion		;
							
expresion			:		termino							|
							expresion OP_SUMARESTA termino	;
							
termino				:		factor						|
							termino OP_MULDIV factor	;
							
factor				:		ID				|
							varconstante	|
							PARENTESIS_A expresion PARENTESIS_C;
							
bucle				:		C_REPEAT_A bloqprograma C_REPEAT_C PARENTESIS_A condicion PARENTESIS_C PYC ;

filtro				:		C_FILTER PARENTESIS_A condfiltro COMA CORCHETE_A listavariables CORCHETE_C PARENTESIS_C	;

condfiltro			:		C_FILTER_REFENTEROS OP_COMPARACION expresion |
							C_FILTER_REFENTEROS OP_COMPARACION expresion OP_LOGICO C_FILTER_REFENTEROS OP_COMPARACION expresion ;
							/* NO FUNCIONA DOBLE CONDICION */

%%
int main(int argc,char *argv[]){
	if ((yyin = fopen(argv[1], "rt")) == NULL){
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	else{
		yyparse();
	}
	
	fclose(yyin);
	return 0;
}

int yyerror(void){
	printf("\n\n\n----- Syntax Error -----\n");
	system ("Pause");
	exit (1);
}
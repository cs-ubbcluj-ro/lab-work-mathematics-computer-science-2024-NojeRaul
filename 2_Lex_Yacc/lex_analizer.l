%{
#include <stdio.h>
#include <string.h>

typedef struct {
    char token[257];
    int symbolTableCode;
} PIF;

typedef struct {
    char token[257];
    int index;
} ST;

ST SymbolTable[100];
int stLength = 0;

PIF ProgramInternalForm[300];
int pifLength = 0;

int errorFound = 0;
int lineNumber = 1;

FILE *outputFile;

int addToST(char* token) {
    for (int i = 0; i < stLength; i++) {
        if (strcmp(SymbolTable[i].token, token) == 0) {
            return SymbolTable[i].index;
        }
    }
    strcpy(SymbolTable[stLength].token, token);
    SymbolTable[stLength].index = stLength;
    stLength++;
    return stLength - 1;
}

void addToPIF(char* token, int stCode) {
    strcpy(ProgramInternalForm[pifLength].token, token);
    ProgramInternalForm[pifLength].symbolTableCode = stCode;
    pifLength++;
}

void showSymbolTable() {
    fprintf(outputFile, "------- Symbol table -------\n");
    for (int i = 0; i < stLength; i++) {
        fprintf(outputFile, " %s  %d\n", SymbolTable[i].token, SymbolTable[i].index);
    }
    fprintf(outputFile, "-------- End ST -------\n\n");
}

void showProgramInternalForm() {
    fprintf(outputFile, "-------- Program internal form -------\n");
    for (int i = 0; i < pifLength; i++) {
        fprintf(outputFile, " %s  %d\n", ProgramInternalForm[i].token, ProgramInternalForm[i].symbolTableCode);
    }
    fprintf(outputFile, "-------- End PIF --------\n\n");
}

%}

REAL_NUMBER  [+-]?(0|[1-9][0-9]*)(\.[0-9]+)?
IDENTIFIER   [a-z][a-z0-9_]*
STRING       \".*\"

/*** Rule Section ***/
%%
					/* yytext is the text in the buffer */
begin                                   { addToPIF(yytext, -1); }
end					{ addToPIF(yytext, -1); }
start					{ addToPIF(yytext, -1); }
stop					{ addToPIF(yytext, -1); }
if                                    	{ addToPIF(yytext, -1); }
while                                   { addToPIF(yytext, -1); }
for                                    	{ addToPIF(yytext, -1); }
write                                   { addToPIF(yytext, -1); }
read                                    { addToPIF(yytext, -1); }
else                                    { addToPIF(yytext, -1); }
int                                    	{ addToPIF(yytext, -1); }
real                                    { addToPIF(yytext, -1); }
char                                    { addToPIF(yytext, -1); }
\{                                      { addToPIF(yytext, -1); }
\}                                      { addToPIF(yytext, -1); }
\;                                    	{ addToPIF(yytext, -1); }
\(                                    	{ addToPIF(yytext, -1); }
\)                                    	{ addToPIF(yytext, -1); }
\,                                    	{ addToPIF(yytext, -1); }
\+                                    	{ addToPIF(yytext, -1); }
\-                                    	{ addToPIF(yytext, -1); }
\*                                    	{ addToPIF(yytext, -1); }
\/                                    	{ addToPIF(yytext, -1); }
\%                                    	{ addToPIF(yytext, -1); }
\>                                    	{ addToPIF(yytext, -1); }
\<                                    	{ addToPIF(yytext, -1); }
\>=                                    	{ addToPIF(yytext, -1); }
\<=                                    	{ addToPIF(yytext, -1); }
\=                                    	{ addToPIF(yytext, -1); }
\==                                    	{ addToPIF(yytext, -1); }
\and                                    { addToPIF(yytext, -1); }
\or                                    	{ addToPIF(yytext, -1); }
\.                                    	{ addToPIF(yytext, -1); }
\!=                                    	{ addToPIF(yytext, -1); }
{IDENTIFIER}				{ int stCode = addToST(yytext); addToPIF(yytext, stCode); }
{REAL_NUMBER}                           { int stCode = addToST(yytext); addToPIF(yytext, stCode); }
{STRING}				{ int stCode = addToST(yytext); addToPIF(yytext, stCode); }
[\n]					{ ++lineNumber; }
[ \t\n]+             			{ ; /* eat up whitespace */ }
.                			{ errorFound = 1; printf("Illegal token %s at line %d !", yytext, lineNumber); printf("\n"); }
%%

/* yywrap() - wraps the above rule section */
int yywrap() { return 1; }

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <input_file> <output_file>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        perror("Error opening input file");
        return 1;
    }

    outputFile = fopen(argv[2], "w");
    if (!outputFile) {
        perror("Error opening output file");
        fclose(fp);
        return 1;
    }

    yyin = fp;
    yylex();

    if (errorFound == 0) {
        showSymbolTable();
        showProgramInternalForm();
    }

    fclose(fp);
    fclose(outputFile);

    return 0;
}

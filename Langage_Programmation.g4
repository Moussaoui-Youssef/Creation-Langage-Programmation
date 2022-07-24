grammar Langage_Programmation;

@members {
    private TableSymboles tablesSymboles = new TableSymboles();
    int lab=0;

}



start: a = calcul EOF;

calcul
	returns[ String code ]
	@init { $code = new String(); }
	@after { System.out.println($code); }: (decl { $code += $decl.code; })* NEWLINE* (
instruction { $code += $instruction.code; }
	)* { $code += "HALT\n"; };





decl
	returns[ String code ]:
	TYPE IDENTIFIANT finInstruction{
            tablesSymboles.putVar($IDENTIFIANT.text, $TYPE.text);
            if($TYPE.text.equals("int")){$code = "PUSHI " + "0" + "\n";}
            if($TYPE.text.equals("float")){$code = "PUSHF " + "0.0" + "\n";}
            if($TYPE.text.equals("bool")){$code= "PUSHI " + "0" + "\n";}
        } 
        ;
   






instruction
	returns[ String code ]:
	 expression finInstruction {
            $code = $expression.code;
        }
	| assignation finInstruction {
            $code = $assignation.code;
        }
	| entrer finInstruction {
            $code = $entrer.code;
        }
	| sortie finInstruction {
            $code = $sortie.code;
        }
	| lesi {
            $code = $lesi.code;
    }
   | repeat{
        $code =$repeat.code;
    }
   | cond { 
   	  $code= $cond.code;
    }
   | bloc finInstruction?{
            $code = $bloc.code;
    }
   | finInstruction {
        $code = "";
    };







assignation
	returns[ String code ]:
	IDENTIFIANT '=' expression {
	AdresseType at = tablesSymboles.getAdresseType($IDENTIFIANT.text);
	if(at.type.equals("int"))
            {$code = $expression.code + "STOREG " + at.adresse + "\n";}
	}
	|IDENTIFIANT '=' expF {
	AdresseType at = tablesSymboles.getAdresseType($IDENTIFIANT.text);
   if(at.type.equals("float"))
               {$code = $expF.code + "STOREG " + at.adresse + "\n";}     
		}   
   |IDENTIFIANT '=' cond {
   AdresseType at = tablesSymboles.getAdresseType($IDENTIFIANT.text);
   if(at.type.equals("bool"))
               {$code = $cond.code + "STOREG " + at.adresse + "\n";}     
		}   
        ;



expF 
	returns[ String code ]: 
		 FLOAT {$code= "PUSHF" +$FLOAT.text+ "\n";}
	;

expression
	returns[ String code ]:
	'(' expression ')' {$code = $expression.code;}
	| a= expression '^' b = expression {
	lab++;
	int ret = lab;
	lab ++;
   int fi = lab++;
   lab++;
   int boucl = lab++;
   $code= "PUSHI 0\n" + $b.code + "STOREG 0\n LABEL"+ ret + "\n PUSHG 0\n EQUAL\n JUMPF\n"+ boucl + "JUMP " + fi + "\n LABEL"+ boucl+ "\n" +$a.code+ $a.code+ "MULL \n JUMP" +ret + "\n LABEL "+ fi + "\n";}
	| c = expression '/' d = expression {$code = $c.code + $d.code + "DIV\n";}
	| e = expression '*' f = expression {$code = $e.code + $f.code + "MUL\n";}
	| g = expression '+' h = expression {$code = $g.code + $h.code + "ADD\n";}
	| i = expression '-' j = expression {$code = $i.code + $j.code + "SUB\n";}
	| '-' ENTIER {
        $code = "PUSHI 0 \n" + "PUSHI " + $ENTIER.text + "\n SUB\n";
    }
	| ENTIER {$code = "PUSHI " + $ENTIER.text + "\n";}
	| IDENTIFIANT {
		AdresseType at = tablesSymboles.getAdresseType($IDENTIFIANT.text);
        $code = "  PUSHG " + at.adresse + "\n";
        }
   ;





entrer
	returns[String code]:
	'lire' '(' IDENTIFIANT ')' {
        AdresseType at = tablesSymboles.getAdresseType($IDENTIFIANT.text);
        $code =  " READ \n";
        $code += " STOREG " + at.adresse + "\n";
    };





sortie
	returns[String code]:
	'afficher' '(' expression ')' { $code = $expression.code + " WRITE \n  POP\n";}
	;





cond	
	returns[String code]:
	  a = expression '==' b = expression { $code = $a.code + $b.code + "EQUAL\n";}
	|  a = expression '>' b = expression { $code = $a.code + $b.code + "SUP\n";}
	|  a = expression '<' b = expression { $code = $a.code + $b.code + "INF\n";}
	|  a = expression '>=' b = expression { $code = $a.code + $b.code + "SUPEQ\n";}
	|  a = expression '<=' b= expression { $code = $a.code + $b.code + "INFEQ\n";}
	| a = expression '<>' b = expression { $code = $a.code + $b.code + "NEQ\n";}
	| '(' cond ')' {$code= $cond.code;}
   | 'not' cond { $code = "PUSHI 1 \n" + $cond.code + "SUB\n";}
   | c = cond 'and' d = cond { $code = $c.code + $d.code + "MUL \n";}
   | c = cond 'or' d = cond { $code = $c.code + $d.code + "ADD \n PUSHI 0 \n NEQ \n";}
   | 'true' { $code = "PUSHI 1\n"; }
	| 'false' { $code = "PUSHI 0\n"; }
   ;








bloc
	returns[String code]
	: {$code = "";}
	'{' NEWLINE? (
		instruction {
        $code += $instruction.code + "\n";
  }
	)* NEWLINE? '}';








repeat
  returns[String code]:
  'repeter' instruction 'tantque' '(' cond ')' {
    lab++;
    int boucle = lab;
    lab++;
    int fin = lab;
    $code = " LABEL " + boucle + "\n";
    $code += $instruction.code + "\n";
    $code += $cond.code;
    $code += " JUMPF " + fin + "\n";
    $code += "JUMP "+ boucle +"\n";
    $code += " LABEL " + fin + "\n";
  };







lesi
    returns[String code]:
    'si' '(' cond ')' NEWLINE? a = instruction {
        lab++;
        int IfOut = lab;
        lab++;
        int Else = lab;
        $code = $cond.code +"JUMPF " + Else +"\n";
        $code += $a.code;
        $code += "JUMP " + IfOut+"\n";
        $code += "LABEL " + Else + "\n";
    }
    ('sinon' b = instruction{$code += $b.code + "\n";})?

    {$code += "LABEL " + IfOut + "\n";}
    | 'si' '(' x=cond ')' NEWLINE? a = instruction {
        lab++;
        int IfOut = lab;
        lab++;
        int ElseIf = lab;
        $code += $x.code +"JUMPF " + ElseIf +"\n";
        $code += $a.code;
        $code += "JUMP " + IfOut+"\n";
        $code += "LABEL " + ElseIf + "\n";
    }
    ('sinon' NEWLINE? 'si' '(' v=cond ')' NEWLINE? b = instruction{
        lab++;
        int ElseIfOut = lab;
        lab++;
        int Else = lab;
        $code += $v.code +"JUMPF " + Else +"\n";
        $code += $b.code;
        $code += "JUMP " + ElseIfOut+"\n";
        $code += "LABEL " + Else + "\n"; 
    }
    'sinon' c = instruction{$code += $c.code + "\n";})?
    ;









// lexer
NEWLINE: '\r'? '\n';
finInstruction: ( NEWLINE | ';')+;

TYPE: 'int' | 'float' | 'bool';
IDENTIFIANT: ('a' ..'z' | 'A' ..'Z' | '_') (
		'a' ..'z'
		| 'A' ..'Z'
		| '_'
		| '0' ..'9'
	)*;

ENTIER: ('0' ..'9')+;

FLOAT: ENTIER '.' ENTIER;


OP: (
		'=='
		| '>'
		| '<'
		| '<='
		| '>='
		| '<>'
		| 'not'
		| 'and'
		| 'or'
	);

WS: (' ' | '\t')+ -> skip;

UNMATCH: . -> skip;
COMMENTAIRE: ('/*' .*? '*/' | '//' .*? NEWLINE) -> skip;

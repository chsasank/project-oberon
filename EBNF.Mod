MODULE EBNF;
    IMPORT Texts, Oberon, Out;
    
    CONST IdLen = 32;
        ident = 0; literal = 2; lparen = 3; lbrak = 4; lbrace = 5; bar = 6;
        eql = 7; rparen = 8; rbrak = 9; rbrace = 10; period = 11; other = 12;
    
    TYPE Identifier = ARRAY IdLen OF CHAR;

    VAR ch: CHAR;
        sym: INTEGER;
        lastpos: LONGINT;
        id: Identifier;
        R: Texts.Reader;
        W: Texts.Writer;

    PROCEDURE error(n: INTEGER); 
        VAR pos: LONGINT;
    BEGIN
        pos := Texts.Pos(R);
        IF pos > lastpos + 4 THEN
            (* Avoid spurious error messages *)
            Texts.WriteString(W, " pos"); Texts.WriteInt(W, pos, 6);
            Texts.WriteString(W, " err"); Texts.WriteInt(W, n, 4); lastpos := pos;
            Texts.WriteString(W, " sym"); Texts.WriteInt(W, sym, 4);
            Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
        END
    END error;

    PROCEDURE GetSym;
        VAR i: INTEGER;
    BEGIN
        WHILE ~R.eot & (ch <= " ") DO
            Texts.Read(R, ch);
        END; (* Skip blanks *)

        CASE ch OF
            "A".."Z", "a".."z":
                sym := ident; i := 0;
                REPEAT
                    id[i] := ch; INC(i); Texts.Read(R, ch)
                UNTIL (CAP(ch) < "A") OR (CAP(ch) > "Z");
                id[i] := 0X;
            | 22X: (*quote*)
                Texts.Read(R, ch); sym := literal; i := 0;
                WHILE (ch # 22X) & (ch > " ") DO
                    id[i] := ch; INC(i); Texts.Read(R, ch)
                END;
                IF ch <= " " THEN error(1) END;
                id[i] := 0X; Texts.Read(R, ch)
            | "=": sym := eql; Texts.Read(R, ch)
            | "(": sym := lparen; Texts.Read(R, ch)
            | ")": sym := rparen; Texts.Read(R, ch)
            | "[": sym := lbrak; Texts.Read(R, ch)
            | "]": sym := rbrak; Texts.Read(R, ch)
            | "{": sym := lbrace; Texts.Read(R, ch)
            | "}": sym := rbrace; Texts.Read(R, ch)
            | "|": sym := bar; Texts.Read(R, ch)
            | ".": sym := period; Texts.Read(R, ch)
            ELSE sym := other; Texts.Read(R, ch);
        END
    END GetSym;
    
    PROCEDURE record(id: Identifier; class: INTEGER);
    BEGIN
        (* Enter id in appropriate list of identifiers *)
    END record;

    PROCEDURE expression;
        PROCEDURE term;
            PROCEDURE factor;
            BEGIN
                IF sym = ident THEN record(id, 1); GetSym
                ELSIF sym = literal THEN record(id, 0); GetSym
                ELSIF sym = lparen THEN
                    GetSym; expression;
                    IF sym = rparen THEN GetSym ELSE error(2) END
                ELSIF sym = lbrak THEN
                    GetSym; expression;
                    IF sym = rbrak THEN GetSym ELSE error(3) END
                ELSIF sym = lbrace THEN
                    GetSym; expression;
                    IF sym = rbrace THEN GetSym ELSE error(4) END
                ELSE error(5)
                END
            END factor;
            
        BEGIN (*term*)
            factor;
            WHILE sym < bar DO factor END
        END term;

    BEGIN (*expression*)
        WHILE sym = bar DO GetSym; term END
    END expression;

    PROCEDURE production;
    BEGIN (*sym=ident*)
        record(id, 2); GetSym;
        IF sym = eql THEN GetSym ELSE error(7) END;
        expression;
        IF sym = period THEN GetSym ELSE error(8) END
    END production;

    PROCEDURE syntax;
    BEGIN
        WHILE sym = ident DO production END
    END syntax;

    PROCEDURE Compile*;
    BEGIN (*Set R to the beginning of the text to be compiled*)
        lastpos:= 0; Texts.Read(R, ch); GetSym; syntax;
        Texts.Append(Oberon.Log, W.buf)
    END Compile;

BEGIN
    Texts.OpenWriter(W);
    Compile;
END EBNF.
MODULE EBNF;
    IMPORT Texts, Oberon;
    
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
                id[i] := 0x; Texts.Read(R, ch)
            
            ELSE sym := other; Texts.Read(R, ch);
        END
    END GetSym;
    
END EBNF.
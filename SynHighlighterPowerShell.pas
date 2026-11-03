{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
-------------------------------------------------------------------------------}
{
@abstract(Provides a Windows PowerShell language syntax highlighter for SynEdit)
@created(2026-06-05)

Lazarus port of SynHighlighterPowerShell.pas of TurboPack SynEdit
(https://github.com/TurboPack/SynEdit, Source/Highlighters).
Same tokens, attributes, colors, ranges and sample source; changes for the
Lazarus SynEdit:
- line given by SetLine as an UTF-8 PChar (GetToken, GetTokenEx, GetTokenPos);
- bytes #128..#255 are identifier characters (letters of UTF-8 identifiers),
  a non ASCII character starting a token is one unknown token (whole code point);
- attributes created with the Lazarus captions and stored names (SYNS_XML_*).
}

UNIT SynHighlighterPowerShell;

{$mode objfpc}{$H+}

INTERFACE

USES
  Classes,
  SysUtils,
  Graphics,
  LazUTF8,
  SynEditTypes,
  SynEditHighlighter,
  SynEditStrConst;

TYPE
  TtkTokenKind = (tkComment, tkIdentifier, tkKey, tkCmdlet, tkVariable,
    tkParameter, tkNumber, tkNull, tkSpace, tkString, tkSymbol, tkUnknown);

  TRangeState = (rsUnknown, rsBlockComment, rsHereStringDouble,
    rsHereStringSingle);

  { TSynPowerShellSyn }

  TSynPowerShellSyn = CLASS(TSynCustomHighlighter)
  PRIVATE
    FLine: PChar;
    Run: Integer;
    FTokenPos: Integer;
    FRange: TRangeState;
    FTokenID: TtkTokenKind;
    FKeywords: TStringList;
    FOperators: TStringList;
    FCommentAttri: TSynHighlighterAttributes;
    FIdentifierAttri: TSynHighlighterAttributes;
    FKeyAttri: TSynHighlighterAttributes;
    FCmdletAttri: TSynHighlighterAttributes;
    FVariableAttri: TSynHighlighterAttributes;
    FParameterAttri: TSynHighlighterAttributes;
    FNumberAttri: TSynHighlighterAttributes;
    FSpaceAttri: TSynHighlighterAttributes;
    FStringAttri: TSynHighlighterAttributes;
    FSymbolAttri: TSynHighlighterAttributes;
    FUnknownAttri: TSynHighlighterAttributes;
    FUNCTION IdentKind(MayBe: PChar): TtkTokenKind;
    FUNCTION IsIdentStart(AChar: Char): Boolean;
    FUNCTION IsIdentChar(AChar: Char): Boolean;
    PROCEDURE AtProc;
    PROCEDURE BackQuoteProc;
    PROCEDURE BlockCommentProc;
    PROCEDURE CommentProc;
    PROCEDURE CRProc;
    PROCEDURE DashProc;
    PROCEDURE DollarProc;
    PROCEDURE HereStringDoubleProc;
    PROCEDURE HereStringSingleProc;
    PROCEDURE IdentProc;
    PROCEDURE LFProc;
    PROCEDURE LowerProc;
    PROCEDURE NullProc;
    PROCEDURE NumberProc;
    PROCEDURE NumberSuffixProc;
    PROCEDURE SingleQuoteProc;
    PROCEDURE SpaceProc;
    PROCEDURE StringProc;
    PROCEDURE SymbolProc;
    PROCEDURE UnknownProc;
  PROTECTED
    FUNCTION GetIdentChars: TSynIdentChars; OVERRIDE;
    FUNCTION GetSampleSource: STRING; OVERRIDE;
    FUNCTION IsFilterStored: Boolean; OVERRIDE;
  PUBLIC
    CLASS FUNCTION GetLanguageName: STRING; OVERRIDE;
    CLASS FUNCTION GetFriendlyLanguageName: STRING;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    FUNCTION GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes; OVERRIDE;
    FUNCTION GetEol: Boolean; OVERRIDE;
    FUNCTION GetRange: Pointer; OVERRIDE;
    FUNCTION GetTokenID: TtkTokenKind;
    FUNCTION GetToken: STRING; OVERRIDE;
    PROCEDURE GetTokenEx(OUT TokenStart: PChar; OUT TokenLength: Integer); OVERRIDE;
    FUNCTION GetTokenAttribute: TSynHighlighterAttributes; OVERRIDE;
    FUNCTION GetTokenKind: Integer; OVERRIDE;
    FUNCTION GetTokenPos: Integer; OVERRIDE;
    PROCEDURE SetLine(CONST NewValue: STRING; LineNumber: Integer); OVERRIDE;
    PROCEDURE Next; OVERRIDE;
    PROCEDURE ResetRange; OVERRIDE;
    PROCEDURE SetRange(Value: Pointer); OVERRIDE;
  PUBLISHED
    PROPERTY CommentAttri: TSynHighlighterAttributes READ FCommentAttri WRITE FCommentAttri;
    PROPERTY IdentifierAttri: TSynHighlighterAttributes READ FIdentifierAttri WRITE FIdentifierAttri;
    PROPERTY KeyAttri: TSynHighlighterAttributes READ FKeyAttri WRITE FKeyAttri;
    PROPERTY CmdletAttri: TSynHighlighterAttributes READ FCmdletAttri WRITE FCmdletAttri;
    PROPERTY VariableAttri: TSynHighlighterAttributes READ FVariableAttri WRITE FVariableAttri;
    PROPERTY ParameterAttri: TSynHighlighterAttributes READ FParameterAttri WRITE FParameterAttri;
    PROPERTY NumberAttri: TSynHighlighterAttributes READ FNumberAttri WRITE FNumberAttri;
    PROPERTY SpaceAttri: TSynHighlighterAttributes READ FSpaceAttri WRITE FSpaceAttri;
    PROPERTY StringAttri: TSynHighlighterAttributes READ FStringAttri WRITE FStringAttri;
    PROPERTY SymbolAttri: TSynHighlighterAttributes READ FSymbolAttri WRITE FSymbolAttri;
    PROPERTY UnknownAttri: TSynHighlighterAttributes READ FUnknownAttri WRITE FUnknownAttri;
  END;

IMPLEMENTATION

CONST
  SYNS_FilterPowerShell = 'PowerShell Files (*.ps1;*.psm1;*.psd1)|*.ps1;*.psm1;*.psd1';
  SYNS_LangPowerShell = 'PowerShell';
  SYNS_FriendlyLangPowerShell = 'PowerShell';

CONSTRUCTOR TSynPowerShellSyn.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);

  FKeywords := TStringList.Create;
  FKeywords.CaseSensitive := False;
  FKeywords.Sorted := True;
  FKeywords.Duplicates := dupIgnore;
  FKeywords.CommaText :=
    'begin,break,catch,class,configuration,continue,data,define,do,' +
    'dynamicparam,else,elseif,end,enum,exit,filter,finally,for,foreach,from,' +
    'function,hidden,if,in,inlinescript,parallel,param,process,return,' +
    'sequence,static,switch,throw,trap,try,until,using,var,while,workflow';

  FOperators := TStringList.Create;
  FOperators.CaseSensitive := False;
  FOperators.Sorted := True;
  FOperators.Duplicates := dupIgnore;
  FOperators.CommaText :=
    'eq,ne,gt,ge,lt,le,like,notlike,match,notmatch,contains,notcontains,in,' +
    'notin,replace,split,join,is,isnot,as,and,or,not,xor,band,bor,bnot,bxor,' +
    'shl,shr,f,' +
    'ceq,cne,cgt,cge,clt,cle,clike,cnotlike,cmatch,cnotmatch,ccontains,' +
    'cnotcontains,cin,cnotin,creplace,csplit,cjoin,cis,cisnot,cas,' +
    'ieq,ine,igt,ige,ilt,ile,ilike,inotlike,imatch,inotmatch,icontains,' +
    'inotcontains,iin,inotin,ireplace,isplit';

  FCommentAttri := TSynHighlighterAttributes.Create(@SYNS_AttrComment, SYNS_XML_AttrComment);
  FCommentAttri.Foreground := clGreen;
  FCommentAttri.Style := [fsItalic];
  AddAttribute(FCommentAttri);

  FIdentifierAttri := TSynHighlighterAttributes.Create(@SYNS_AttrIdentifier, SYNS_XML_AttrIdentifier);
  AddAttribute(FIdentifierAttri);

  FKeyAttri := TSynHighlighterAttributes.Create(@SYNS_AttrReservedWord, SYNS_XML_AttrReservedWord);
  FKeyAttri.Foreground := clBlue;
  FKeyAttri.Style := [fsBold];
  AddAttribute(FKeyAttri);

  FCmdletAttri := TSynHighlighterAttributes.Create(@SYNS_AttrFunction, SYNS_XML_AttrFunction);
  FCmdletAttri.Foreground := clTeal;
  AddAttribute(FCmdletAttri);

  FVariableAttri := TSynHighlighterAttributes.Create(@SYNS_AttrVariable, SYNS_XML_AttrVariable);
  FVariableAttri.Foreground := clMaroon;
  AddAttribute(FVariableAttri);

  FParameterAttri := TSynHighlighterAttributes.Create(@SYNS_AttrSpecialVariable, SYNS_XML_AttrSpecialVariable);
  FParameterAttri.Foreground := clOlive;
  AddAttribute(FParameterAttri);

  FNumberAttri := TSynHighlighterAttributes.Create(@SYNS_AttrNumber, SYNS_XML_AttrNumber);
  FNumberAttri.Foreground := clBlue;
  AddAttribute(FNumberAttri);

  FSpaceAttri := TSynHighlighterAttributes.Create(@SYNS_AttrSpace, SYNS_XML_AttrSpace);
  AddAttribute(FSpaceAttri);

  FStringAttri := TSynHighlighterAttributes.Create(@SYNS_AttrString, SYNS_XML_AttrString);
  FStringAttri.Foreground := clPurple;
  AddAttribute(FStringAttri);

  FSymbolAttri := TSynHighlighterAttributes.Create(@SYNS_AttrSymbol, SYNS_XML_AttrSymbol);
  FSymbolAttri.Style := [fsBold];
  AddAttribute(FSymbolAttri);

  FUnknownAttri := TSynHighlighterAttributes.Create(@SYNS_AttrIllegalChar, SYNS_XML_AttrIllegalChar);
  FUnknownAttri.Foreground := clRed;
  AddAttribute(FUnknownAttri);

  SetAttributesOnChange(@DefHighlightChange);
  fDefaultFilter := SYNS_FilterPowerShell;
  FRange := rsUnknown;
END;

DESTRUCTOR TSynPowerShellSyn.Destroy;
BEGIN
  FOperators.Free;
  FKeywords.Free;
  INHERITED Destroy;
END;

FUNCTION TSynPowerShellSyn.IdentKind(MayBe: PChar): TtkTokenKind;
VAR
  S: STRING;
BEGIN
  SetString(S, MayBe, Run - FTokenPos);
  IF FKeywords.IndexOf(S) >= 0 THEN
    Result := tkKey
  ELSE
    Result := tkIdentifier;
END;

FUNCTION TSynPowerShellSyn.IsIdentStart(AChar: Char): Boolean;
// UTF-8: the bytes of a non ASCII character count as letters
BEGIN
  Result := AChar IN ['A'..'Z', 'a'..'z', '_', #128..#255];
END;

FUNCTION TSynPowerShellSyn.IsIdentChar(AChar: Char): Boolean;
BEGIN
  Result := AChar IN ['A'..'Z', 'a'..'z', '0'..'9', '_', #128..#255];
END;

FUNCTION TSynPowerShellSyn.GetIdentChars: TSynIdentChars;
BEGIN
  Result := ['A'..'Z', 'a'..'z', '0'..'9', '_', #128..#255];
END;

PROCEDURE TSynPowerShellSyn.CRProc;
BEGIN
  FTokenID := tkSpace;
  Inc(Run);
  IF FLine[Run] = #10 THEN
    Inc(Run);
END;

PROCEDURE TSynPowerShellSyn.LFProc;
BEGIN
  FTokenID := tkSpace;
  Inc(Run);
END;

PROCEDURE TSynPowerShellSyn.NullProc;
BEGIN
  FTokenID := tkNull;
  // Run not moved: end of line (GetEol)
END;

PROCEDURE TSynPowerShellSyn.SpaceProc;
BEGIN
  FTokenID := tkSpace;
  REPEAT
    Inc(Run);
  UNTIL NOT (FLine[Run] IN [#1..#9, #11, #12, #14..#32]);
END;

PROCEDURE TSynPowerShellSyn.CommentProc;
BEGIN
  FTokenID := tkComment;
  WHILE NOT (FLine[Run] IN [#0, #10, #13]) DO
    Inc(Run);
END;

PROCEDURE TSynPowerShellSyn.BlockCommentProc;
BEGIN
  IF (Run = FTokenPos) AND (FLine[Run] IN [#0, #10, #13]) THEN
  BEGIN
    CASE FLine[Run] OF
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
    END;
    Exit;
  END;

  FTokenID := tkComment;
  WHILE NOT (FLine[Run] IN [#0, #10, #13]) DO
  BEGIN
    IF (FLine[Run] = '#') AND (FLine[Run + 1] = '>') THEN
    BEGIN
      Inc(Run, 2);
      FRange := rsUnknown;
      Exit;
    END;
    Inc(Run);
  END;
END;

PROCEDURE TSynPowerShellSyn.HereStringDoubleProc;
BEGIN
  IF (Run = FTokenPos) AND (FLine[Run] IN [#0, #10, #13]) THEN
  BEGIN
    CASE FLine[Run] OF
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
    END;
    Exit;
  END;

  FTokenID := tkString;

  IF (Run = 0) AND (FLine[0] = '"') AND (FLine[1] = '@') THEN
  BEGIN
    Inc(Run, 2);
    FRange := rsUnknown;
    Exit;
  END;
  WHILE NOT (FLine[Run] IN [#0, #10, #13]) DO
    Inc(Run);
END;

PROCEDURE TSynPowerShellSyn.HereStringSingleProc;
BEGIN
  IF (Run = FTokenPos) AND (FLine[Run] IN [#0, #10, #13]) THEN
  BEGIN
    CASE FLine[Run] OF
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
    END;
    Exit;
  END;

  FTokenID := tkString;

  IF (Run = 0) AND (FLine[0] = '''') AND (FLine[1] = '@') THEN
  BEGIN
    Inc(Run, 2);
    FRange := rsUnknown;
    Exit;
  END;
  WHILE NOT (FLine[Run] IN [#0, #10, #13]) DO
    Inc(Run);
END;

PROCEDURE TSynPowerShellSyn.LowerProc;
BEGIN
  IF FLine[Run + 1] = '#' THEN
  BEGIN
    FRange := rsBlockComment;
    Inc(Run, 2);
    BlockCommentProc;
  END
  ELSE
    SymbolProc;
END;

PROCEDURE TSynPowerShellSyn.AtProc;
BEGIN
  CASE FLine[Run + 1] OF
    '"':
      BEGIN
        FTokenID := tkString;
        FRange := rsHereStringDouble;
        Inc(Run, 2);
        WHILE NOT (FLine[Run] IN [#0, #10, #13]) DO
          Inc(Run);
      END;
    '''':
      BEGIN
        FTokenID := tkString;
        FRange := rsHereStringSingle;
        Inc(Run, 2);
        WHILE NOT (FLine[Run] IN [#0, #10, #13]) DO
          Inc(Run);
      END;
  ELSE
    IF IsIdentStart(FLine[Run + 1]) THEN
    BEGIN
      FTokenID := tkVariable;
      Inc(Run);
      WHILE IsIdentChar(FLine[Run]) DO
        Inc(Run);
    END
    ELSE
    BEGIN
      FTokenID := tkSymbol;
      Inc(Run);
    END;
  END;
END;

PROCEDURE TSynPowerShellSyn.DollarProc;
BEGIN
  FTokenID := tkVariable;
  Inc(Run);
  CASE FLine[Run] OF
    '{':
      BEGIN
        Inc(Run);
        WHILE NOT (FLine[Run] IN [#0, #10, #13, '}']) DO
          Inc(Run);
        IF FLine[Run] = '}' THEN
          Inc(Run);
      END;
    '(':
      // $( subexpression ) : the '$' is the variable sigil; the parenthesised
      // expression is tokenised as ordinary code.
      ;
    '$', '?', '^':
      Inc(Run);
  ELSE
    BEGIN
      WHILE IsIdentChar(FLine[Run]) DO
        Inc(Run);
      IF FLine[Run] = ':' THEN
      BEGIN
        Inc(Run);
        WHILE IsIdentChar(FLine[Run]) DO
          Inc(Run);
      END;
    END;
  END;
END;

PROCEDURE TSynPowerShellSyn.DashProc;
VAR
  WStart: Integer;
  W: STRING;
BEGIN
  IF IsIdentStart(FLine[Run + 1]) THEN
  BEGIN
    Inc(Run);
    WStart := Run;
    WHILE IsIdentChar(FLine[Run]) DO
      Inc(Run);
    SetString(W, FLine + WStart, Run - WStart);
    IF FOperators.IndexOf(W) >= 0 THEN
      FTokenID := tkKey
    ELSE
      FTokenID := tkParameter;
  END
  ELSE
  BEGIN
    FTokenID := tkSymbol;
    IF FLine[Run + 1] IN ['-', '='] THEN
      Inc(Run);
    Inc(Run);
  END;
END;

PROCEDURE TSynPowerShellSyn.IdentProc;
BEGIN
  WHILE IsIdentChar(FLine[Run]) DO
    Inc(Run);
  IF (FLine[Run] = '-') AND IsIdentStart(FLine[Run + 1]) THEN
  BEGIN
    REPEAT
      Inc(Run); // '-'
      WHILE IsIdentChar(FLine[Run]) DO
        Inc(Run);
    UNTIL NOT ((FLine[Run] = '-') AND IsIdentStart(FLine[Run + 1]));
    FTokenID := tkCmdlet;
  END
  ELSE
    FTokenID := IdentKind(FLine + FTokenPos);
END;

PROCEDURE TSynPowerShellSyn.NumberSuffixProc;
BEGIN
  IF FLine[Run] IN
    ['k', 'K', 'm', 'M', 'g', 'G', 't', 'T', 'p', 'P', 'l', 'L', 'd', 'D',
     'u', 'U'] THEN
    WHILE FLine[Run] IN ['a'..'z', 'A'..'Z'] DO
      Inc(Run);
END;

PROCEDURE TSynPowerShellSyn.NumberProc;
BEGIN
  FTokenID := tkNumber;

  IF (FLine[Run] = '0') AND (FLine[Run + 1] IN ['x', 'X']) THEN
  BEGIN
    Inc(Run, 2);
    WHILE FLine[Run] IN ['0'..'9', 'a'..'f', 'A'..'F'] DO
      Inc(Run);
  END
  ELSE IF (FLine[Run] = '0') AND (FLine[Run + 1] IN ['b', 'B']) THEN
  BEGIN
    Inc(Run, 2);
    WHILE FLine[Run] IN ['0', '1'] DO
      Inc(Run);
  END
  ELSE
  BEGIN
    WHILE FLine[Run] IN ['0'..'9'] DO
      Inc(Run);
    IF (FLine[Run] = '.') AND (FLine[Run + 1] IN ['0'..'9']) THEN
    BEGIN
      Inc(Run);
      WHILE FLine[Run] IN ['0'..'9'] DO
        Inc(Run);
    END;
    IF FLine[Run] IN ['e', 'E'] THEN
    BEGIN
      Inc(Run);
      IF FLine[Run] IN ['+', '-'] THEN
        Inc(Run);
      WHILE FLine[Run] IN ['0'..'9'] DO
        Inc(Run);
    END;
  END;

  NumberSuffixProc;
END;

PROCEDURE TSynPowerShellSyn.SingleQuoteProc;
BEGIN
  FTokenID := tkString;
  Inc(Run);
  WHILE NOT (FLine[Run] IN [#0, #10, #13]) DO
  BEGIN
    IF FLine[Run] = '''' THEN
    BEGIN
      IF FLine[Run + 1] = '''' THEN
        Inc(Run, 2)
      ELSE
      BEGIN
        Inc(Run);
        Break;
      END;
    END
    ELSE
      Inc(Run);
  END;
END;

PROCEDURE TSynPowerShellSyn.StringProc;
BEGIN
  FTokenID := tkString;
  Inc(Run);
  WHILE NOT (FLine[Run] IN [#0, #10, #13]) DO
  BEGIN
    IF FLine[Run] = '`' THEN
    BEGIN
      Inc(Run);
      IF NOT (FLine[Run] IN [#0, #10, #13]) THEN
        Inc(Run);
    END
    ELSE IF FLine[Run] = '"' THEN
    BEGIN
      IF FLine[Run + 1] = '"' THEN
        Inc(Run, 2)
      ELSE
      BEGIN
        Inc(Run);
        Break;
      END;
    END
    ELSE
      Inc(Run);
  END;
END;

PROCEDURE TSynPowerShellSyn.BackQuoteProc;
BEGIN
  FTokenID := tkSymbol;
  Inc(Run);
  IF NOT (FLine[Run] IN [#0, #10, #13]) THEN
    Inc(Run, UTF8CodepointSize(FLine + Run));
END;

PROCEDURE TSynPowerShellSyn.SymbolProc;
BEGIN
  FTokenID := tkSymbol;
  CASE FLine[Run] OF
    '+': IF FLine[Run + 1] IN ['+', '='] THEN Inc(Run);
    '*', '/', '%': IF FLine[Run + 1] = '=' THEN Inc(Run);
    '|': IF FLine[Run + 1] = '|' THEN Inc(Run);
    '&': IF FLine[Run + 1] = '&' THEN Inc(Run);
    '.': IF FLine[Run + 1] = '.' THEN Inc(Run);
    ':': IF FLine[Run + 1] = ':' THEN Inc(Run);
    '>': IF FLine[Run + 1] = '>' THEN Inc(Run);
    '?': IF FLine[Run + 1] IN ['?', '.'] THEN Inc(Run);
  END;
  Inc(Run);
END;

PROCEDURE TSynPowerShellSyn.UnknownProc;
// UTF-8: the whole code point
BEGIN
  FTokenID := tkUnknown;
  Inc(Run, UTF8CodepointSize(FLine + Run));
END;

FUNCTION TSynPowerShellSyn.GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes;
BEGIN
  CASE Index OF
    SYN_ATTR_COMMENT: Result := FCommentAttri;
    SYN_ATTR_IDENTIFIER: Result := FIdentifierAttri;
    SYN_ATTR_KEYWORD: Result := FKeyAttri;
    SYN_ATTR_STRING: Result := FStringAttri;
    SYN_ATTR_WHITESPACE: Result := FSpaceAttri;
    SYN_ATTR_SYMBOL: Result := FSymbolAttri;
  ELSE
    Result := NIL;
  END;
END;

FUNCTION TSynPowerShellSyn.GetEol: Boolean;
BEGIN
  Result := FTokenID = tkNull;
END;

CLASS FUNCTION TSynPowerShellSyn.GetFriendlyLanguageName: STRING;
BEGIN
  Result := SYNS_FriendlyLangPowerShell;
END;

CLASS FUNCTION TSynPowerShellSyn.GetLanguageName: STRING;
BEGIN
  Result := SYNS_LangPowerShell;
END;

FUNCTION TSynPowerShellSyn.GetRange: Pointer;
BEGIN
  Result := Pointer(PtrInt(FRange));
END;

FUNCTION TSynPowerShellSyn.GetSampleSource: STRING;
BEGIN
  Result :=
    '<#'#13#10 +
    '.SYNOPSIS'#13#10 +
    '  Demo PowerShell script.'#13#10 +
    '#>'#13#10 +
    'function Get-Greeting {'#13#10 +
    '    param('#13#10 +
    '        [string]$Name = "World",'#13#10 +
    '        [int]$Count = 0x2A'#13#10 +
    '    )'#13#10 +
    '    # Build the message'#13#10 +
    '    $msg = "Hello, $Name!`n"'#13#10 +
    '    if ($Name -eq '''' -or $Count -gt 1kb) {'#13#10 +
    '        $msg = @"'#13#10 +
    'a multi-line'#13#10 +
    'here-string'#13#10 +
    '"@'#13#10 +
    '    }'#13#10 +
    '    Write-Output $msg | Out-Host'#13#10 +
    '}'#13#10 +
    ''#13#10 +
    'Get-Greeting -Name ''PowerShell'' -Count 5';
END;

FUNCTION TSynPowerShellSyn.GetTokenAttribute: TSynHighlighterAttributes;
BEGIN
  CASE FTokenID OF
    tkComment: Result := FCommentAttri;
    tkIdentifier: Result := FIdentifierAttri;
    tkKey: Result := FKeyAttri;
    tkCmdlet: Result := FCmdletAttri;
    tkVariable: Result := FVariableAttri;
    tkParameter: Result := FParameterAttri;
    tkNumber: Result := FNumberAttri;
    tkSpace: Result := FSpaceAttri;
    tkString: Result := FStringAttri;
    tkSymbol: Result := FSymbolAttri;
    tkUnknown: Result := FUnknownAttri;
  ELSE
    Result := NIL;
  END;
END;

FUNCTION TSynPowerShellSyn.GetTokenID: TtkTokenKind;
BEGIN
  Result := FTokenID;
END;

FUNCTION TSynPowerShellSyn.GetToken: STRING;
BEGIN
  Result := '';
  SetString(Result, FLine + FTokenPos, Run - FTokenPos);
END;

PROCEDURE TSynPowerShellSyn.GetTokenEx(OUT TokenStart: PChar; OUT TokenLength: Integer);
BEGIN
  TokenLength := Run - FTokenPos;
  TokenStart := FLine + FTokenPos;
END;

FUNCTION TSynPowerShellSyn.GetTokenKind: Integer;
BEGIN
  Result := Ord(FTokenID);
END;

FUNCTION TSynPowerShellSyn.GetTokenPos: Integer;
BEGIN
  Result := FTokenPos;
END;

FUNCTION TSynPowerShellSyn.IsFilterStored: Boolean;
BEGIN
  Result := fDefaultFilter <> SYNS_FilterPowerShell;
END;

PROCEDURE TSynPowerShellSyn.SetLine(CONST NewValue: STRING; LineNumber: Integer);
BEGIN
  INHERITED;
  FLine := PChar(NewValue);
  Run := 0;
  Next;
END;

PROCEDURE TSynPowerShellSyn.Next;
BEGIN
  FTokenPos := Run;
  CASE FRange OF
    rsBlockComment: BlockCommentProc;
    rsHereStringDouble: HereStringDoubleProc;
    rsHereStringSingle: HereStringSingleProc;
  ELSE
    CASE FLine[Run] OF
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
      #1..#9, #11, #12, #14..#32: SpaceProc;
      '#': CommentProc;
      '<': LowerProc;
      '$': DollarProc;
      '@': AtProc;
      '-': DashProc;
      '`': BackQuoteProc;
      '''': SingleQuoteProc;
      '"': StringProc;
      'A'..'Z', 'a'..'z', '_': IdentProc;
      '0'..'9': NumberProc;
      '.':
        IF FLine[Run + 1] IN ['0'..'9'] THEN
          NumberProc
        ELSE
          SymbolProc;
      '+', '*', '/', '%', '|', '&', '=', ':', ';', ',', '(', ')', '{', '}',
      '[', ']', '>', '?', '~', '^', '!': SymbolProc;
    ELSE
      UnknownProc;
    END;
  END;
END;

PROCEDURE TSynPowerShellSyn.ResetRange;
BEGIN
  FRange := rsUnknown;
END;

PROCEDURE TSynPowerShellSyn.SetRange(Value: Pointer);
BEGIN
  FRange := TRangeState(PtrUInt(Value));
END;

INITIALIZATION
  RegisterPlaceableHighlighter(TSynPowerShellSyn);

END.

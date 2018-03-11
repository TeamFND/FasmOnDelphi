unit FasmOnDelphi;

{Delphi Translation&Tests:Artyom Gavrilov,Vlad Untkin.
 Donate:https://money.yandex.ru/to/410014959153552}

interface

{$Define USEFasm4Delphi}
{$IFNDEF WIN32}
  {$UNDEF USEFasm4Delphi}
{$ENDIF}

{$Define USEIOUtils}
{$IFDEF DCC}
  {$IF CompilerVersion<23.0}
    {$UNDEF USEIOUtils}
  {$ENDIF}
{$ELSE}
  {$UNDEF USEIOUtils}
{$ENDIF}

uses
  SysUtils,
  {$IFDEF USEFasm4Delphi}Fasm4Delphi,{$ENDIF}
  {$IFDEF USEIOUtils}System.IOUtils,{$ENDIF}Windows,Math;

type
  TFasmVersion={$IFDEF USEFasm4Delphi}Fasm4Delphi.TFasmVersion;
  {$ELSE}packed record
    V1,V2:word;
  end;
  {$ENDIF}

const
  //General errors and conditions
  FASM_OK			   =0;//FASM_STATE points to output
  FASM_WORKING			   =1;
  FASM_ERROR			   =2;//FASM_STATE contains error code
  FASM_INVALID_PARAMETER	   =-1;
  FASM_OUT_OF_MEMORY		   =-2;
  FASM_STACK_OVERFLOW		   =-3;
  FASM_SOURCE_NOT_FOUND 	   =-4;
  FASM_UNEXPECTED_END_OF_SOURCE    =-5;
  FASM_CANNOT_GENERATE_CODE	   =-6;
  FASM_FORMAT_LIMITATIONS_EXCEDDED =-7;
  FASM_WRITE_FAILED		   =-8;
  FASM_INVALID_DEFINITION	   =-9;

  //Error codes for FASM_ERROR condition
  FASMERR_FILE_NOT_FOUND		      =-101;
  FASMERR_ERROR_READING_FILE		      =-102;
  FASMERR_INVALID_FILE_FORMAT		      =-103;
  FASMERR_INVALID_MACRO_ARGUMENTS	      =-104;
  FASMERR_INCOMPLETE_MACRO		      =-105;
  FASMERR_UNEXPECTED_CHARACTERS 	      =-106;
  FASMERR_INVALID_ARGUMENT		      =-107;
  FASMERR_ILLEGAL_INSTRUCTION		      =-108;
  FASMERR_INVALID_OPERAND		      =-109;
  FASMERR_INVALID_OPERAND_SIZE		      =-110;
  FASMERR_OPERAND_SIZE_NOT_SPECIFIED	      =-111;
  FASMERR_OPERAND_SIZES_DO_NOT_MATCH	      =-112;
  FASMERR_INVALID_ADDRESS_SIZE		      =-113;
  FASMERR_ADDRESS_SIZES_DO_NOT_AGREE	      =-114;
  FASMERR_DISALLOWED_COMBINATION_OF_REGISTERS =-115;
  FASMERR_LONG_IMMEDIATE_NOT_ENCODABLE	      =-116;
  FASMERR_RELATIVE_JUMP_OUT_OF_RANGE	      =-117;
  FASMERR_INVALID_EXPRESSION		      =-118;
  FASMERR_INVALID_ADDRESS		      =-119;
  FASMERR_INVALID_VALUE 		      =-120;
  FASMERR_VALUE_OUT_OF_RANGE		      =-121;
  FASMERR_UNDEFINED_SYMBOL		      =-122;
  FASMERR_INVALID_USE_OF_SYMBOL 	      =-123;
  FASMERR_NAME_TOO_LONG 		      =-124;
  FASMERR_INVALID_NAME			      =-125;
  FASMERR_RESERVED_WORD_USED_AS_SYMBOL	      =-126;
  FASMERR_SYMBOL_ALREADY_DEFINED	      =-127;
  FASMERR_MISSING_END_QUOTE		      =-128;
  FASMERR_MISSING_END_DIRECTIVE 	      =-129;
  FASMERR_UNEXPECTED_INSTRUCTION	      =-130;
  FASMERR_EXTRA_CHARACTERS_ON_LINE	      =-131;
  FASMERR_SECTION_NOT_ALIGNED_ENOUGH	      =-132;
  FASMERR_SETTING_ALREADY_SPECIFIED	      =-133;
  FASMERR_DATA_ALREADY_DEFINED		      =-134;
  FASMERR_TOO_MANY_REPEATS		      =-135;
  FASMERR_SYMBOL_OUT_OF_SCOPE		      =-136;
  FASMERR_USER_ERROR			      =-140;
  FASMERR_ASSERTION_FAILED		      =-141;

type
  TFasmError=FASMERR_ASSERTION_FAILED ..FASM_ERROR;
  TFasmLine=record
    Line:UInt32;
    &File:string;
  end;
  TFasmResult=record
    OutData:Pointer;
    sb:integer;
    Error:TFasmError;
    OutStr:string;
    Lines:array of TFasmLine;
  end;
  TErrorNamePair=record
    Name:string;
    Code:TFasmError;
  end;

const
  FasmPath='fasm';
  FasmErrorCodeNames:array[TFasmError]of string=('assertion failed',//-141
    'user error',//-140
    '','','',//-139,-138,-137
    'symbol out of scope',//-136
    'too many repeats',//-135
    'data already defined',//-134
    'setting already specified',//-133
    'section not aligned enough',//-132
    'extra characters on line',//-131
    'unexpected instruction',//-130
    'missing end directive',//-129
    'missing end quote',//-128
    'symbol already defined',//-127
    'reserved word used as symbol',//-126
    'invalid name',//-125
    'name too long',//-124
    'invalid use of symbol',//-123
    'undefined symbol',//-122
    'value out of range',//-121
    'invalid value',//-120
    'invalid address',//-119
    'invalid expression',//-118
    'relative jump out of range',//-117
    'long immediate not encodable',//-116
    'disallowed combination of registers',//-115
    'address sizes do not agree',//-114
    'invalid address size',//-113
    'operand sizes do not match',//-112
    'operand size not specified',//-111
    'invalid operand size',//-110
    'invalid operand',//-109
    'illegal instruction',//-108
    'invalid argument',//-107
    'unexpected characters',//-106
    'incomplete macro',//-105
    'invalid macro arguments',//-104
    'invalid file format',//-103
    'error reading file',//-102
    'file not found',//-101
    '','','','','','','','','','','','','','','','','','','','','','','','','',
 //-100-99-98-97-96-95-94-93-92-91-90-89-88-87-86-85-84-83-82-81-80-79-78-77-76
    '','','','','','','','','','','','','','','','','','','','','','','','','',
  //-75-74-73-72-71-70-69-68-67-66-65-64-63-62-61-60-59-58-57-56-55-54-53-52-51
    '','','','','','','','','','','','','','','','','','','','','','','','','',
  //-50-49-48-47-46-45-44-43-42-41-40-39-38-37-36-35-34-33-32-31-30-29-28-27-26
    '','','','','','','','','','','','','','','','',
  //-25-24-23-22-21-20-19-18-17-16-15-14-13-12-11-10
    'invalid definition',//-9
    'write failed',//-8
    'format limitations excedded',//-7
    'cannot generate code',//-6
    'unexpected end of source',//-5
    'source file not found',//-4
    'stack overflow',//-3
    'out of memory',//-2
    'invalid parameter',//-1
    'success.',//0
    'working',//1
    'error'//2
    );

function FasmVersion:TFasmVersion;
function FasmAssemble(const Source:AnsiString;cbMemorySize:cardinal=1024*1024;nPassesLimit:DWORD=100):TFasmResult;
function FasmAssembleToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
function FasmAssembleFile(const Source:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
function FasmAssembleFileToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;

procedure OpenFASM(Location:string=FASMPath;AsDll:boolean=false);
procedure SetFasmTemp(Path:string);

implementation

{$IFDEF FPC}
function GetLongPathNameA(lpszShortPath: LPSTR; lpszLongPath: LPSTR;
  cchBuffer: DWORD): DWORD; stdcall;external 'Kernel32.dll';

function Pos(const SubStr,Str:AnsiString;Offset:Integer): Integer; overload;
var
  I, LIterCnt, L, J: Integer;
  PSubStr, PS: PAnsiChar;
begin
  L := Length(SubStr);
  { Calculate the number of possible iterations. Not valid if Offset < 1. }
  LIterCnt := Length(Str) - Offset - L + 1;

  { Only continue if the number of iterations is positive or zero (there is space to check) }
  if (Offset > 0) and (LIterCnt >= 0) and (L > 0) then
  begin
    PSubStr := PAnsiChar(SubStr);
    PS := PAnsiChar(Str);
    Inc(PS, Offset - 1);

    for I := 0 to LIterCnt do
    begin
      J := 0;
      while (J >= 0) and (J < L) do
      begin
        if PS[I + J] = PSubStr[J] then
          Inc(J)
        else
          J := -1;
      end;
      if J >= L then
        Exit(I + Offset);
    end;
  end;

  Result := 0;
end;
{$ENDIF}

var
  FasmLocation:string='FASM';
  FasmTemp:string;
  IsDll:boolean=false;

function RunFasm(Command:AnsiString):string;
var
  StartupInfo:TStartupInfo;
  ProcessInformation:TProcessInformation;
  OutPut:THandle;
  n:DWORD;
  Buff:AnsiChar;
  SecAtrtrs:TSecurityAttributes;
begin
SecAtrtrs.nLength:=SizeOf(TSecurityAttributes);
SecAtrtrs.lpSecurityDescriptor:=nil;
SecAtrtrs.bInheritHandle:=true;
ZeroMemory(@StartupInfo,SizeOf(StartupInfo));
StartupInfo.cb:=SizeOf(StartupInfo);
StartupInfo.dwFlags:=STARTF_USESTDHANDLES;
Createpipe(OutPut,StartupInfo.hStdOutput,@SecAtrtrs,1024);
StartupInfo.hStdError:=StartupInfo.hStdOutput;
if not CreateProcess(nil,PChar('"'+FasmLocation+'" '+Command),nil,nil,true,NORMAL_PRIORITY_CLASS,nil,nil,StartupInfo,ProcessInformation)then
  RaiseLastOSError;
WaitForSingleObject(ProcessInformation.hProcess,INFINITE);
Result:='';
while PeekNamedPipe(OutPut,@Buff,1,nil,@n,nil) do
  if n<>0 then
  begin
    ReadFile(OutPut,Buff,1,n,nil);
    Result:=Result+Buff;
  end
  else
    break;
CloseHandle(OutPut);
CloseHandle(StartupInfo.hStdOutput);
CloseHandle(ProcessInformation.hThread);
CloseHandle(ProcessInformation.hProcess);
end;

function FasmVersion:TFasmVersion;
const
  preverstr='version ';
var
  s:string;
  i:integer;
begin
{$IFDEF USEFasm4Delphi}
if IsDll then
  Result:=fasm_GetVersion()
else
begin
{$ENDIF}
  s:=RunFasm('');
  i:=Pos(preverstr,s)+length(preverstr);
  Result.V1:=0;
  while s[i]<>'.' do
  begin
    Result.V1:=Result.V1*10+ord(s[i])-ord('0');
    inc(i);
  end;
  inc(i);
  Result.V2:=0;
  while(s[i]>='0')and(s[i]<='9')do
  begin
    Result.V2:=Result.V2*10+ord(s[i])-ord('0');
    inc(i);
  end;
{$IFDEF USEFasm4Delphi}
end;
{$ENDIF}
end;

function FasmAssemble(const Source:AnsiString;cbMemorySize:cardinal=1024*1024;nPassesLimit:DWORD=100):TFasmResult;
var
{$IFDEF USEFasm4Delphi}
  Mem:PFASM_STATE;
  p:PLINE_HEADER;
{$ELSE}
  p:pointer;
{$ENDIF}
  s,s0:string;
  nr:cardinal;
  FileHandle:THandle;
  i,i1:NativeUInt;
  i0:TFasmError;
begin
{$IFDEF USEFasm4Delphi}
if IsDll then
begin
  GetMem(Mem,cbMemorySize);
  ZeroMemory(Mem,cbMemorySize);
  Result.Error:=fasm_Assemble(PAnsiChar(Source),Mem,cbMemorySize,nPassesLimit);
  if Result.Error=FASM_OK then
  begin
    GetMem(Result.OutData,Mem^.output_length);
    CopyMemory(Result.OutData,Mem^.output_data,Mem^.output_length);
    Result.sb:=Mem^.output_length;
    Result.OutStr:='Success.';
  end
  else
  begin
    Result.OutData:=nil;
    Result.sb:=0;
    Result.OutStr:='Error: '+Mem^.error_code.ToString+' '+FasmErrorCodeNames[Mem^.error_code];
    p:=Mem^.error_line;
    nr:=0;
    while(NativeUInt(p)>=NativeUInt(Mem))and(NativeUInt(Mem)+NativeUInt(cbMemorySize)>=NativeUInt(p))do
    begin
      Result.OutStr:=Result.OutStr+sLineBreak+
        string(p^.file_path)+'['+p^.line_number.ToString+']';
      inc(nr);
      SetLength(Result.Lines,nr);
      Result.Lines[nr-1].Line:=p^.line_number;
      Result.Lines[nr-1].&File:=string(p^.file_path);
      p:=p^.macro_calling_line;
    end;
  end;
  FreeMem(Mem);
end
else
begin
{$ENDIF}
  s:=FasmTemp+GetTickCount.ToString();
  FileHandle:=CreateFile(PChar(s+'.in'),GENERIC_WRITE,0,nil,CREATE_ALWAYS,128,0);
  WriteFile(FileHandle,PAnsiChar(Source)^,length(Source),nr,nil);
  CloseHandle(FileHandle);
  Result.OutStr:=RunFasm('-m '+trunc(cbMemorySize/1024).ToString+' -p '+nPassesLimit.ToString+' '+
    s+'.in '+s);
  DeleteFile(PChar(s+'.in'));
  i:=Pos('error: ',Result.OutStr);
  s0:=Copy(Result.OutStr,i+length('error: '),Pos('.',Result.OutStr,i)-i-length('error: '));
  if i=0 then
    Result.Error:=FASM_OK
  else
    for i0:=FASMERR_ASSERTION_FAILED to FASM_ERROR do
      if FasmErrorCodeNames[i0]=s0 then
        Result.Error:=i0;
  if Result.Error=FASM_OK then
  begin
    FileHandle:=CreateFile(PChar(s),GENERIC_READ,0,nil,3,128,0);
    Result.sb:=GetFileSize(FileHandle,nil);
    getmem(Result.OutData,Result.sb);
    ReadFile(FileHandle,Result.OutData,Result.sb,nr,nil);
    CloseHandle(FileHandle);
    DeleteFile(PChar(s));
  end
  else
  begin
    Result.OutData:=nil;
    Result.sb:=0;
    i:=Pos(sLineBreak,Result.OutStr)+length(sLineBreak);
    nr:=0;
    i1:=Pos(']:',Result.OutStr,i);
    while i1<>0 do
    begin
      inc(nr);
      SetLength(Result.Lines,nr);
      i1:=Pos(' [',Result.OutStr,i);
      Result.Lines[nr-1].&File:=Copy(Result.OutStr,i,i1-i);
      i:=i1+2;
      i1:=Pos(']:',Result.OutStr,i);
      Result.Lines[nr-1].Line:=Copy(Result.OutStr,i,i1-i).ToInteger;
      for i0:=0 to 2 do
        i:=Pos(sLineBreak,Result.OutStr,i)+length(sLineBreak);
      i1:=Pos(']:',Result.OutStr,i);
    end;
  end;
{$IFDEF USEFasm4Delphi}
end;
{$ENDIF}
end;

function FasmAssembleToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
var
{$IFDEF USEFasm4Delphi}
  Mem:PFASM_STATE;
  p:PLINE_HEADER;
{$ELSE}
  p:pointer;
{$ENDIF}
  s,s0:string;
  nr:cardinal;
  FileHandle:THandle;
  i,i1:NativeUInt;
  i0:TFasmError;
begin
{$IFDEF USEFasm4Delphi}
if IsDll then
begin
  GetMem(Mem,cbMemorySize);
  ZeroMemory(Mem,cbMemorySize);
  Result.Error:=fasm_Assemble(PAnsiChar(Source),Mem,cbMemorySize,nPassesLimit);
  Result.OutData:=nil;
  Result.sb:=0;
  if Result.Error=FASM_OK then
  begin
    FileHandle:=CreateFile(PChar(OutFile),GENERIC_WRITE,0,nil,3,128,0);
    WriteFile(FileHandle,Mem^.output_data^,Mem^.output_length,nr,nil);
    CloseHandle(FileHandle);
    Result.OutStr:='Success.';
  end
  else
  begin
    Result.OutStr:='Error: '+Mem^.error_code.ToString+' '+FasmErrorCodeNames[Mem^.error_code];
    p:=Mem^.error_line;
    nr:=0;
    while(NativeUInt(p)>=NativeUInt(Mem))and(NativeUInt(Mem)+NativeUInt(cbMemorySize)>=NativeUInt(p))do
    begin
      Result.OutStr:=Result.OutStr+sLineBreak+
        string(p^.file_path)+'['+p^.line_number.ToString+']';
      inc(nr);
      SetLength(Result.Lines,nr);
      Result.Lines[nr-1].Line:=p^.line_number;
      Result.Lines[nr-1].&File:=string(p^.file_path);
      p:=p^.macro_calling_line;
    end;
  end;
  FreeMem(Mem);
end
else
begin
{$ENDIF}
  s:=FasmTemp+GetTickCount.ToString();
  FileHandle:=CreateFile(PChar(s),GENERIC_WRITE,0,nil,CREATE_ALWAYS,128,0);
  WriteFile(FileHandle,PAnsiChar(Source)^,length(Source),nr,nil);
  CloseHandle(FileHandle);
  Result.OutStr:=RunFasm('-m '+trunc(cbMemorySize/1024).ToString+' -p '+nPassesLimit.ToString+' '+
    s+' '+OutFile);
  DeleteFile(PChar(s));
  i:=Pos('error: ',Result.OutStr);
  s0:=Copy(Result.OutStr,i+length('error: '),Pos('.',Result.OutStr,i)-i-length('error: '));
  if i=0 then
    Result.Error:=FASM_OK
  else
    for i0:=FASMERR_ASSERTION_FAILED to FASM_ERROR do
      if FasmErrorCodeNames[i0]=s0 then
        Result.Error:=i0;
  Result.OutData:=nil;
  Result.sb:=0;
  if Result.Error<>FASM_OK then
  begin
    i:=Pos(sLineBreak,Result.OutStr)+length(sLineBreak);
    nr:=0;
    i1:=Pos(']:',Result.OutStr,i);
    while i1<>0 do
    begin
      inc(nr);
      SetLength(Result.Lines,nr);
      i1:=Pos(' [',Result.OutStr,i);
      Result.Lines[nr-1].&File:=Copy(Result.OutStr,i,i1-i);
      i:=i1+2;
      i1:=Pos(']:',Result.OutStr,i);
      Result.Lines[nr-1].Line:=Copy(Result.OutStr,i,i1-i).ToInteger;
      for i0:=0 to 2 do
        i:=Pos(sLineBreak,Result.OutStr,i)+length(sLineBreak);
      i1:=Pos(']:',Result.OutStr,i);
    end;
  end;
{$IFDEF USEFasm4Delphi}
end;
{$ENDIF}
end;

function FasmAssembleFile(const Source:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
var
{$IFDEF USEFasm4Delphi}
  Mem:PFASM_STATE;
  p:PLINE_HEADER;
{$ELSE}
  p:pointer;
{$ENDIF}
  s,s0:string;
  nr:cardinal;
  FileHandle:THandle;
  i,i1:NativeUInt;
  i0:TFasmError;
begin
{$IFDEF USEFasm4Delphi}
if IsDll then
begin
  GetMem(Mem,cbMemorySize);
  ZeroMemory(Mem,cbMemorySize);
  Result.Error:=fasm_AssembleFile(PAnsiChar(Source),Mem,cbMemorySize,nPassesLimit);
  if Result.Error=FASM_OK then
  begin
    GetMem(Result.OutData,Mem^.output_length);
    CopyMemory(Result.OutData,Mem^.output_data,Mem^.output_length);
    Result.sb:=Mem^.output_length;
    Result.OutStr:='Success.';
  end
  else
  begin
    Result.OutData:=nil;
    Result.sb:=0;
    Result.OutStr:='Error: '+Mem^.error_code.ToString+' '+FasmErrorCodeNames[Mem^.error_code];
    p:=Mem^.error_line;
    nr:=0;
    while(NativeUInt(p)>=NativeUInt(Mem))and(NativeUInt(Mem)+NativeUInt(cbMemorySize)>=NativeUInt(p))do
    begin
      Result.OutStr:=Result.OutStr+sLineBreak+
        string(p^.file_path)+'['+p^.line_number.ToString+']';
      inc(nr);
      SetLength(Result.Lines,nr);
      Result.Lines[nr-1].Line:=p^.line_number;
      Result.Lines[nr-1].&File:=string(p^.file_path);
      p:=p^.macro_calling_line;
    end;
  end;
  FreeMem(Mem);
end
else
begin
{$ENDIF}
  s:=FasmTemp+GetTickCount.ToString();
  Result.OutStr:=RunFasm('-m '+trunc(cbMemorySize/1024).ToString+' -p '+nPassesLimit.ToString+' '+
    Source+' '+s);
  i:=Pos('error: ',Result.OutStr);
  s0:=Copy(Result.OutStr,i+length('error: '),Pos('.',Result.OutStr,i)-i-length('error: '));
  if i=0 then
    Result.Error:=FASM_OK
  else
    for i0:=FASMERR_ASSERTION_FAILED to FASM_ERROR do
      if FasmErrorCodeNames[i0]=s0 then
        Result.Error:=i0;
  if Result.Error=FASM_OK then
  begin
    FileHandle:=CreateFile(PChar(s),GENERIC_READ,0,nil,3,128,0);
    Result.sb:=GetFileSize(FileHandle,nil);
    getmem(Result.OutData,Result.sb);
    ReadFile(FileHandle,Result.OutData,Result.sb,nr,nil);
    CloseHandle(FileHandle);
    DeleteFile(PChar(s));
  end
  else
  begin
    Result.OutData:=nil;
    Result.sb:=0;
    i:=Pos(sLineBreak,Result.OutStr)+length(sLineBreak);
    nr:=0;
    i1:=Pos(']:',Result.OutStr,i);
    while i1<>0 do
    begin
      inc(nr);
      SetLength(Result.Lines,nr);
      i1:=Pos(' [',Result.OutStr,i);
      Result.Lines[nr-1].&File:=Copy(Result.OutStr,i,i1-i);
      i:=i1+2;
      i1:=Pos(']:',Result.OutStr,i);
      Result.Lines[nr-1].Line:=Copy(Result.OutStr,i,i1-i).ToInteger;
      for i0:=0 to 2 do
        i:=Pos(sLineBreak,Result.OutStr,i)+length(sLineBreak);
      i1:=Pos(']:',Result.OutStr,i);
    end;
  end;
{$IFDEF USEFasm4Delphi}
end;
{$ENDIF}
end;

function FasmAssembleFileToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
var
{$IFDEF USEFasm4Delphi}
  Mem:PFASM_STATE;
  p:PLINE_HEADER;
  FileHandle:THandle;
{$ELSE}
  p:pointer;
{$ENDIF}
  s0:string;
  nr:cardinal;
  i,i1:NativeUInt;
  i0:TFasmError;
begin
{$IFDEF USEFasm4Delphi}
if IsDll then
begin
  GetMem(Mem,cbMemorySize);
  ZeroMemory(Mem,cbMemorySize);
  Result.Error:=fasm_AssembleFile(PAnsiChar(Source),Mem,cbMemorySize,nPassesLimit);
  Result.OutData:=nil;
  Result.sb:=0;
  if Result.Error=FASM_OK then
  begin
    FileHandle:=CreateFile(PChar(OutFile),GENERIC_READ,0,nil,3,128,0);
    WriteFile(FileHandle,Mem^.output_data^,Mem^.output_length,nr,nil);
    CloseHandle(FileHandle);
    Result.OutStr:='Success.';
  end
  else
  begin
    Result.OutData:=nil;
    Result.sb:=0;
    Result.OutStr:='Error: '+Mem^.error_code.ToString+' '+FasmErrorCodeNames[Mem^.error_code];
    p:=Mem^.error_line;
    nr:=0;
    while(NativeUInt(p)>=NativeUInt(Mem))and(NativeUInt(Mem)+NativeUInt(cbMemorySize)>=NativeUInt(p))do
    begin
      Result.OutStr:=Result.OutStr+sLineBreak+
        string(p^.file_path)+'['+p^.line_number.ToString+']';
      inc(nr);
      SetLength(Result.Lines,nr);
      Result.Lines[nr-1].Line:=p^.line_number;
      Result.Lines[nr-1].&File:=string(p^.file_path);
      p:=p^.macro_calling_line;
    end;
  end;
  FreeMem(Mem);
end
else
begin
{$ENDIF}
  Result.OutStr:=RunFasm('-m '+trunc(cbMemorySize/1024).ToString+' -p '+nPassesLimit.ToString+' '+
    Source+' '+OutFile);
  i:=Pos('error: ',Result.OutStr);
  s0:=Copy(Result.OutStr,i+length('error: '),Pos('.',Result.OutStr,i)-i-length('error: '));
  if i=0 then
    Result.Error:=FASM_OK
  else
    for i0:=FASMERR_ASSERTION_FAILED to FASM_ERROR do
      if FasmErrorCodeNames[i0]=s0 then
        Result.Error:=i0;
  Result.OutData:=nil;
  Result.sb:=0;
  if Result.Error=FASM_OK then
  begin
    i:=Pos(sLineBreak,Result.OutStr)+length(sLineBreak);
    nr:=0;
    i1:=Pos(']:',Result.OutStr,i);
    while i1<>0 do
    begin
      inc(nr);
      SetLength(Result.Lines,nr);
      i1:=Pos(' [',Result.OutStr,i);
      Result.Lines[nr-1].&File:=Copy(Result.OutStr,i,i1-i);
      i:=i1+2;
      i1:=Pos(']:',Result.OutStr,i);
      Result.Lines[nr-1].Line:=Copy(Result.OutStr,i,i1-i).ToInteger;
      for i0:=0 to 2 do
        i:=Pos(sLineBreak,Result.OutStr,i)+length(sLineBreak);
      i1:=Pos(']:',Result.OutStr,i);
    end;
  end;
{$IFDEF USEFasm4Delphi}
end;
{$ENDIF}
end;

procedure OpenFASM(Location:string=FASMPath;AsDll:boolean=false);
begin
{$IFDEF USEFasm4Delphi}
{$IF Declared(FreeFASM)}
if IsDll then
  FreeFASM;
{$ENDIF}
IsDll:=AsDll;
{$IF Declared(LoadFASM)}
if AsDll then
  LoadFASM(Location);
{$ENDIF}
FasmLocation:=Location;
{$ELSE}
if not AsDll then
  FasmLocation:=Location;
{$ENDIF}
end;

procedure SetFasmTemp(Path:string);
begin
FasmTemp:=Path;
end;

{$IFDEF FPC}{$IFDEF WINDOWS}
var
  Len:Integer;
{$ENDIF}{$ENDIF}
initialization
{$IFDEF FPC}
{$IFDEF WINDOWS}
begin
  SetLength(FasmTemp,MAX_PATH);
  Len:=GetTempPath(MAX_PATH,PChar(FasmTemp));
  if Len<>0 then
  begin
    Len:=GetLongPathNameA(PChar(FasmTemp),nil,0);
    GetLongPathNameA(PChar(FasmTemp),PChar(FasmTemp),Len);
    SetLength(FasmTemp,Len-1);
  end
  else
    FasmTemp:='';
end;
{$ELSE}
FasmTemp:='/tmp';
{$ENDIF}
{$ELSE}
FasmTemp:=TPath.GetTempPath;
{$ENDIF}
end.

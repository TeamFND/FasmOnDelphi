unit FasmOnDelphi platform;

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
  System.SysUtils,
  {$IFDEF USEFasm4Delphi}Fasm4Delphi,{$ENDIF}
  {$IFDEF USEIOUtils}System.IOUtils{$ENDIF},Windows;

{$IFNDEF USEFasm4Delphi}
type
  TFasmVersion=packed record
    V1,V2:word;
  end;

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
{$ENDIF}

type
  TFasmError=FASMERR_ASSERTION_FAILED ..FASM_ERROR;
  TFasmOutPut=record
    Error:TFasmError;
    OutStr:string;
  end;
  TFasmOut=record
    OutData:Pointer;
    sb:integer;
    OutPut:TFasmOutPut;
  end;

const
  FASMPath='fasm';

function FasmVersion:TFasmVersion;
function FasmAssemble(const Source:AnsiString;cbMemorySize:cardinal;nPassesLimit:word=100):TFasmOut;
{function FasmAssembleToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal;nPassesLimit:word=100):TFasmOutPut;
function FasmAssembleFile(const Source:AnsiString;cbMemorySize:cardinal;nPassesLimit:word=100):TFasmOut;
function FasmAssembleFileToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal;nPassesLimit:word=100):TFasmOutPut;{}

procedure OpenFASM(Location:string=FASMPath;AsDll:boolean=false);
procedure SetFasmTemp(Path:string);

implementation

var
  FasmLocation:string='FASM';
  FasmTemp:string;
  IsDll:boolean=false;

function RunFasm(Command:string):string;
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
Createpipe(OutPut,StartupInfo.hStdOutput,@SecAtrtrs,0);
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
  Result:=fasm_GetVersion
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

function FasmAssemble(const Source:AnsiString;cbMemorySize:cardinal;nPassesLimit:word=100):TFasmOut;
{$IFDEF USEFasm4Delphi}
var
  Mem:PFASM_STATE;
  hDisp,hOut:THandle;
  n:DWORD;
  Buff:AnsiChar;
  SecAtrtrs:TSecurityAttributes;
{$ENDIF}
begin
{$IFDEF USEFasm4Delphi}
if IsDll then
begin
  SecAtrtrs.nLength:=SizeOf(TSecurityAttributes);
  SecAtrtrs.lpSecurityDescriptor:=nil;
  SecAtrtrs.bInheritHandle:=true;
  CreatePipe(hOut,hDisp,@SecAtrtrs,0);
  GetMem(Mem,cbMemorySize);
  Result.OutPut.Error:=fasm_Assemble(PAnsiChar(Source),Mem,cbMemorySize,nPassesLimit,hDisp);
  if Result.OutPut.Error=FASM_OK then
  begin

  end;
  FreeMem(Mem);
  Result.OutPut.OutStr:='';
  while PeekNamedPipe(hOut,@Buff,1,nil,@n,nil) do
    if n<>0 then
    begin
      ReadFile(hOut,Buff,1,n,nil);
      Result.OutPut.OutStr:=Result.OutPut.OutStr+Buff;
    end
    else
      break;
  CloseHandle(hOut);
  CloseHandle(hDisp);
end
else
begin
{$ENDIF}
{$IFDEF USEFasm4Delphi}
end;
{$ENDIF}
end;

procedure OpenFASM(Location:string=FASMPath;AsDll:boolean=false);
begin
{$IFDEF USEFasm4Delphi}
if IsDll then
  FreeFASM;
IsDll:=AsDll;
if AsDll then
  LoadFASM(Location);
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
  SetLength(Result,MAX_PATH);
  Len:=GetTempPath(MAX_PATH,PChar(FasmTemp));
  if Len<>0 then
  begin
    Len:=GetLongPathName(PChar(FasmTemp),nil,0);
    GetLongPathName(PChar(FasmTemp),PChar(FasmTemp),Len);
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

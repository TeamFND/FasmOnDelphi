# FasmOnDelphi functions description

### function FasmVersion:TFasmVersion;
Return assembler version in TFasmVersion structure.

### function FasmAssemble(const Source:AnsiString;cbMemorySize:cardinal=1024*1024;nPassesLimit:DWORD=100):TFasmResult;
Compiles the code.

Source - contains source code to compile.

cbMemorySize - amount of memory that compiler can use (may be rounded to kilobytes).

nPassesLimit - the maximum number of passes that the compiler can use.

Returns structure TFasmResult with information of error or compiled code.

### function FasmAssembleToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Like FasmAssemble, but output will be in file provided in OutFile.

### function FasmAssembleFile(const Source:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Like FasmAssemble, but input will be used from file provided in Source.

### function FasmAssembleFileToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Like FasmAssembleFile, but output will be in file provided in OutFile.

### procedure OpenFASM(Location:string=FASMPath;AsDll:boolean=false);
Initializes the Flat Assembler.

Location - path to fasm.exe/fasm.dll (only Win32).

AsDll - set to True if using DLL version of compiler, else False (non Win32 targets ignored).

### procedure SetFasmTemp(Path:string);
Selects a directory for temp files.

**********************************************************
# Description of FasmOnDelphi types:

    TFasmError=FASMERR_ASSERTION_FAILED ..FASM_ERROR;

Type for Fasm error codes.

    TFasmVersion=packed record
      V1,V2:word;
    end;

Type for provide the assembler version.

V1 - the first number of the version (to the point).

V2 - the second version number (after the point).

    TFasmResult=record
      OutData:Pointer;
      sb:integer;
      Error:TFasmError;
      OutStr:string;
      Lines:array of TFasmLine;
    end;

OutData - pointer to the result of assembling (nil on error or FasmAssembleToFile/FasmAssembleFileToFile).

sb - the size of the result of assembly (0 on error or FasmAssembleToFile/FasmAssembleFileToFile).

Error - error code (FASM_OK if everything went well).

OutStr - the string that compiler produces.

Lines - detailed information about errors (for more details see TFasmLine).

    TFasmLine=record
      Line:UInt32;
      &File:string;
    end;

Line - number of line with error.

File - name of file with error ('' or a file from the temp folder implies that this is the code passed to FasmAssembleFile or FasmAssembleFileToFile).

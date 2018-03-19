# Описание функций FasmOnDelphi:

### function FasmVersion:TFasmVersion;
Возвращает версию ассемблера в структуре TFasmVersion.

### function FasmAssemble(const Source:AnsiString;cbMemorySize:cardinal=1024*1024;nPassesLimit:DWORD=100):TFasmResult;
Компилирует код.

Source содержит исходный код для компиляции.

cbMemorySize - количество памяти которую может использовать компилятор(может быть округлено до целого количества килобайт).

nPassesLimit - максимальное количество проходов которые может использовать компилятор.

Возвращает структуру TFasmResult с информацией об ошибке или скомпилированным кодом.

### function FasmAssembleToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Эдентично FasmAssemble, но выход будет записан в файл(имя передаётся в OutFile).

### function FasmAssembleFile(const Source:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Эдентично FasmAssemble, но код будет взят из файла(имя передаётся в Source).

### function FasmAssembleFileToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Эдентично FasmAssembleFile, но выход будет записан в файл(имя передаётся в OutFile).

### procedure OpenFASM(Location:string=FASMPath;AsDll:boolean=false);
Инициализирует Flat Assembler. 

Location - путь до fasm.exe/fasm.dll (только Win32).

AsDll - установить в True если используется DLL версия компилятора иначе False (вне Win32 игнорируется).

### procedure SetFasmTemp(Path:string);
Выбирает каталог для temp файлов.

**********************************************************
# Описание типов FasmOnDelphi:

    TFasmError=FASMERR_ASSERTION_FAILED ..FASM_ERROR;

Тип для кодов ошибок Fasm'а.

    TFasmVersion=packed record
      V1,V2:word;
    end;

Тип для передачи версии ассемблера.

V1 - первое число версии(до точки).

V2 - второе число версии(после точки).

    TFasmResult=record
      OutData:Pointer;
      sb:integer;
      Error:TFasmError;
      OutStr:string;
      Lines:array of TFasmLine;
    end;

OutData - указатель на результат ассемблирования(nil при ошибке или FasmAssembleToFile/FasmAssembleFileToFile).

sb - размер результата ассемблирования(0 при ошибке или FasmAssembleToFile/FasmAssembleFileToFile).

Error - код ошибки(FASM_OK если всё прошло успешно).

OutStr - строка которую выдаёт компилятор.

Lines - подробная информашия об ошибках (подробнее см. TFasmLine).

    TFasmLine=record
      Line:UInt32;
      &File:string;
    end;

Line - номер строки с ошибкой.

File - имя файла с ошибкой('' или файл из папки темпа подразумевает что это код реоеданный в FasmAssembleFile или FasmAssembleFileToFile).
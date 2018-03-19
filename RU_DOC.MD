#Описание функций FasmOnDelphi:

###function FasmVersion:TFasmVersion;
Возвращает версию компилятора в структуре TFasmVersion.

###function FasmAssemble(const Source:AnsiString;cbMemorySize:cardinal=1024*1024;nPassesLimit:DWORD=100):TFasmResult;
Компилирует код.

Source содержит исходный код для компиляции.

cbMemorySize - количество памяти которую может использовать компилятор(может быть округлено до целого количества килобайт).

nPassesLimit - максимальное количество проходов которые может использовать компилятор.

Возвращает структуру TFasmResult с информацией об ошибке или скомпилированным кодом.

###function FasmAssembleToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Эдентично FasmAssemble, но выход будет записан в файл(имя передаётся в OutFile).

###function FasmAssembleFile(const Source:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Эдентично FasmAssemble, но код будет взят из файла(имя передаётся в Source).

###function FasmAssembleFileToFile(const Source,OutFile:AnsiString;cbMemorySize:cardinal=1024*1024*8;nPassesLimit:DWORD=100):TFasmResult;
Эдентично FasmAssembleFile, но выход будет записан в файл(имя передаётся в OutFile).

###procedure OpenFASM(Location:string=FASMPath;AsDll:boolean=false);
Инициализирует Flat Assembler. 

Location - путь до fasm.exe/fasm.dll (только Win32).

AsDll - установить в True если используется DLL версия компилятора иначе False (вне Win32 игнорируется).

###procedure SetFasmTemp(Path:string);
Выбирает каталог для temp файлов.

**********************************************************
unit TestCase1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,FasmOnDelphi;

type

  TTestCase1= class(TTestCase)
  published
    procedure TestHookUp;
  end;

implementation

procedure TTestCase1.TestHookUp;
var
  Res:TFasmResult;
begin
Res:=FasmAssembleFileToFile('..\Tests\Test1.ASM','..\Tests\Test1.bin');
if Res.Error<>FASM_OK then
  Fail('Error in test1:'+sLineBreak+
       'Condition:    '+Res.OutStr+sLineBreak+
       'Error Code:   '+IntToStr(Res.Error)+sLineBreak);
Res:=FasmAssemble('add eax,0');
if Res.Error<>FASM_OK then
  Fail('Error in test2:'+sLineBreak+
       'Condition:    '+Res.OutStr+sLineBreak+
       'Error Code:   '+IntToStr(Res.Error)+sLineBreak);
Res:=FasmAssembleFile('..\Fasm4Delphi\FasmDll\FASM.ASH');
if Res.Error=FASM_OK then
  Fail('Error in test3:'+sLineBreak+
       'FASM is compiling something that it is can not compile at all.');
Res:=FasmAssembleToFile('add eax,0','test');
if Res.Error<>FASM_OK then
  Fail('Error in test4:'+sLineBreak+
       'Condition: '+Res.OutStr+sLineBreak+
       'Error Code:'+IntToStr(Res.Error)+sLineBreak);
end;



initialization
  OpenFASM('..\fasmw172\FASM.EXE');
  RegisterTest(TTestCase1);
end.


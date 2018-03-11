unit TesterMain;

interface

uses
  DUnitX.TestFramework,Fasm4Delphi,FasmOnDelphi,SysUtils;

type
  [TestFixture]
  TMyTestObject = class(TObject) 
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Test1;
    [Test]
    procedure Test2;      
    [Test]
    procedure Test3;
    [Test]
    procedure Test4;
  end;
  
implementation

procedure TMyTestObject.Setup;
begin
end;

procedure TMyTestObject.TearDown;
begin
end;

procedure TMyTestObject.Test1;
var
  Res:TFasmResult;
begin
Res:=FasmAssembleFileToFile('..\..\Test1.ASM','..\..\Test1..bin');
if Res.Error<>FASM_OK then
  raise Exception.Create('Condition:    '+Res.OutStr+sLineBreak+
                         'Error Code:   '+IntToStr(Res.Error)+sLineBreak);
end;

procedure TMyTestObject.Test2;
var
  Res:TFasmResult;
begin
Res:=FasmAssemble('add eax,0');
if Res.Error<>FASM_OK then
  raise Exception.Create('Condition:    '+Res.OutStr+sLineBreak+
                         'Error Code:   '+IntToStr(Res.Error)+sLineBreak);
end;

procedure TMyTestObject.Test3;
var
  Res:TFasmResult;
begin
Res:=FasmAssembleFile('..\..\..\Fasm4Delphi\FasmDll\FASM.ASH');
if Res.Error=FASM_OK then
  raise Exception.Create('FASM is compiling something that it is can not compile at all.')
end;

procedure TMyTestObject.Test4;
var
  Res:TFasmResult;
begin
Res:=FasmAssembleToFile('add eax,0','test');
if Res.Error<>FASM_OK then
  raise Exception.Create('Condition: '+Res.OutStr+sLineBreak+
                         'Error Code:'+IntToStr(Res.Error)+sLineBreak);
end;

initialization
  TDUnitX.RegisterTestFixture(TMyTestObject);
  OpenFASM('..\..\..\fasmw172\FASM.EXE');
end.

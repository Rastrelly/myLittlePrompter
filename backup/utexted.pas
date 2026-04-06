unit uTextEd;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, umlp;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.Button1Click(Sender: TObject);
var i:integer;
begin
  Memo1.Clear;
  if Assigned(textLines) then
  for i:=0 to textLines.Count-1 do
  begin
    Memo1.Text:=Memo1.Text+textLines[i];
  end;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  if (fileexists(Form1.OpenDialog1.FileName)) then
  begin
    Memo1.Lines.SaveToFile(Form1.OpenDialog1.FileName);
     Form1.MenuItem8.Click;
     Button1.Click;
  end
  else
  begin
    if (SaveDialog1.Execute) then
    begin
      Memo1.Lines.SaveToFile(SaveDialog1.FileName);
      Form1.OpenDialog1.FileName := SaveDialog1.FileName;
      Form1.MenuItem8.Click;
      Button1.Click;
    end;
  end;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  Button1.Click;
end;

end.


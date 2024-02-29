unit umlpsettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, umlp;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
begin
  if form1.FontDialog1.Execute then
  begin
    Form1.SetSBFont;
  end;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  if Form1.ColorDialog1.Execute then
  bgColor:=Form1.ColorDialog1.Color;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  Form1.SaveSettings;
end;

procedure TForm2.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then filltoleft:=1 else filltoleft:=0;
end;

procedure TForm2.ComboBox1Change(Sender: TObject);
begin
  convtype:=ComboBox1.ItemIndex;
end;

procedure TForm2.Edit1Change(Sender: TObject);
begin
  TryStrToInt(edit1.Text,pll);
end;

procedure TForm2.Edit2Change(Sender: TObject);
begin
  TryStrToInt(edit2.Text,lineMargin);
end;

procedure TForm2.Edit3Change(Sender: TObject);
begin
  TryStrToInt(edit3.Text,scrollSpeed);
end;

end.


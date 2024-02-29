unit umlp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ComCtrls, ExtCtrls, ScrollingText, DateUtils, LConvEncoding;

type

  { TForm1 }

  TForm1 = class(TForm)
    ColorDialog1: TColorDialog;
    FontDialog1: TFontDialog;
    Image1: TImage;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    OpenDialog1: TOpenDialog;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure MenuItem8Click(Sender: TObject);
    procedure MoveText;
    procedure RenderText;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1Resize(Sender: TObject);
    procedure OpenFileToRead;
    procedure QuitApp;
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure SetPrompterSpeed(spd:integer);
    procedure Timer1Timer(Sender: TObject);
    procedure UpdateScrollerActiveState;
    procedure SetSBFont;
    procedure SaveSettings;
    procedure LoadSettings;
  private

  public

  end;

  TGlobTimer = class
  private
    dtLast:TDateTime;
    dtNow:TDateTime;
    delta:integer;
  public
    function getDeltaTime:integer;
    constructor Create;
  end;

  TPrompterRunner = class
    public
      procedure DoRun;
  end;

var
  Form1: TForm1;
  pll:integer=70;
  filltoleft:integer=0;
  lineMargin:integer=10;
  scrollSpeed:integer=100;
  textFont:TFont;
  bgColor:TColor;
  playScroll:boolean;
  scrollPosition:real;
  textLines:TStringList;
  tmr:TGlobTimer;
  pRun:TPrompterRunner;
  exitCall:boolean=false;
  convtype:integer;

implementation

{$R *.lfm}

uses umlpsettings;

{ TForm1 }

function getLineCount:integer;
begin
  if (textLines<>nil) then
  result:=textLines.Count
  else
  result:=0;
end;

function getLineHeight:integer;
begin
  result:=textFont.Size+lineMargin;
end;

function getMaxScrollPosition:integer;
begin
  result:=textLines.Count*getLineHeight;
end;

function GetLineY(lineId:integer):integer;
var dlh:integer;
begin
  dlh:=Form1.Image1.Height+lineId*getLineHeight-round(scrollPosition);
  result:=dlh;
end;

procedure TForm1.MoveText;
begin
  scrollPosition:=scrollPosition+scrollSpeed*(tmr.getDeltaTime/1000);
  if (scrollPosition>(getMaxScrollPosition+Image1.Height)) then scrollPosition:=0;
end;

procedure TForm1.RenderText;
var imgBmp:TBitmap;
    iw,ih:integer;
    i,l,cLineSize:integer;
    cLine:string;
    cx,cy, lh:integer;
    cts:TTextStyle;
begin
  iw:=Image1.Width;
  ih:=Image1.Height;

  lh:=getLineHeight;

  if (textLines<>nil) then
  if (textLines.Count>0) then
  begin

    l:=textLines.Count-1;

    imgBmp:=TBitmap.Create;
    imgBmp.Width:=iw;
    imgBmp.Height:=ih;

    cts:=imgBmp.Canvas.TextStyle;
    cts.Opaque:=false;
    cts.Layout := tlCenter;
    if filltoleft=0 then cts.Alignment:=taLeftJustify;
    if filltoleft=1 then cts.Alignment:=taCenter;
    imgBmp.Canvas.TextStyle:=cts;

    with imgBmp.Canvas do
    begin
      Brush.Color:=bgColor;
      Brush.Style:=bsSolid;
      Font:=textFont;
      Pen.Color:=textFont.Color;
      Rectangle(Rect(0,0,iw,ih));
      Brush.Style:=bsClear;
      for i:=0 to l do
      begin
        cLine:=textLines[i];
        cLineSize:=Length(cLine)*round(textFont.Size/3);
        //if filltoleft=1 then cx:=20 else cx:=Round((iw/2)-(cLineSize/2));
        cy:=GetLineY(i);
        if (cy>-lh) and (cy<ih+lh) then
        begin
          //Rectangle(20,cy,iw-20,cy+getLineHeight);
          TextRect(rect(20,cy,iw-20,cy+getLineHeight),20,0,cLine,cts);
          //TextOut(cx,cy,cLine);
        end;
      end;
    end;

    Image1.Canvas.CopyRect(Rect(0,0,iw,ih),imgBmp.Canvas,Rect(0,0,iw,ih));

    imgBmp.Free;
  end;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  if fileexists(OpenDialog1.FileName) then
  OpenFileToRead
  else
  MessageDlg('Error: no file to re-open','File to-re-open does not exist. Select a file via Open menu item.',mtError,[mbOK],0);
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  if not playScroll then
  begin
    tmr.getDeltaTime;
    playScroll:=true;
  end
  else
  playScroll:=false;

  UpdateScrollerActiveState;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  scrollPosition:=0;
  UpdateScrollerActiveState;
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  Form2.Show;
end;


procedure TForm1.OpenFileToRead;
var ctstr,convstr,tstr,ftstr,cbl:string;
    i,cnt:integer;
    fl:TextFile;
begin
  if fileexists(OpenDialog1.FileName) then
  begin
    tstr:='';

    textLines.Free;
    textLines:=TStringList.Create;

    AssignFile(fl,OpenDialog1.FileName,DefaultSystemCodePage);
    Reset(fl);
    cnt:=0;
    while not eof(fl) do
    begin
      ReadLn(fl,ctstr);
      convstr:='';
      if (convtype=0) then
      convstr := ctstr;                //UTF-8
      if (convtype=1) then
      convstr := CP1252ToUTF8(ctstr);  // Use fixed codepage 1252
      if (convtype=2) then
      convstr := KOI8RToUTF8(ctstr);   // KOI8R
      if (convtype=3) then
      convstr := ANSIToUTF8(ctstr);    // ANSI
      tstr:=tstr+convstr+#13;
    end;

    SetCodePage(RawByteString(tstr), 1252, true);

    ftstr:='';
    for i:=1 to length(tstr)-1 do
    begin
      ftstr:=ftstr+tstr[i];
      inc(cnt);
      if ((cnt>=pll) and ((tstr[i]=' ') or (tstr[i]=#10) or (tstr[i]=#13))) or ((tstr[i]=#10) or (tstr[i]=#13)) or (i=length(tstr)-1) then
      begin
        if (filltoleft=1)then while (length(ftstr)<pll) do ftstr:=ftstr+#9;
        textLines.Add(ftstr);
        ftstr:=''; cnt:=0;
      end;
    end;

    CloseFile(fl);

    StatusBar1.Panels[1].Text:=OpenDialog1.FileName;

  end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin

  If OpenDialog1.Execute then
  OpenFileToRead;

  //ScrollingText1.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  tmr:=TGlobTimer.Create;
  pRun:=TPrompterRunner.Create;
  Timer1.Enabled:=true;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  LoadSettings;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin

end;

procedure TForm1.Image1Resize(Sender: TObject);
begin
  Image1.Picture.Bitmap.Width:=Image1.Width;
  Image1.Picture.Bitmap.Height:=Image1.Height;
end;

procedure TForm1.QuitApp;
begin
  SaveSettings;
  exitCall:=true;
  Application.Terminate;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  QuitApp;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  QuitApp;
end;

procedure TForm1.SetPrompterSpeed(spd:integer);
begin
  {case spd of
  0:ScrollingText1.ScrollSpeed:=ssVerySlow;
  1:ScrollingText1.ScrollSpeed:=ssSlow;
  2:ScrollingText1.ScrollSpeed:=ssNormal;
  3:ScrollingText1.ScrollSpeed:=ssFast;
  4:ScrollingText1.ScrollSpeed:=ssVeryFast;
  end;}
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=false;
  pRun.DoRun;
end;

procedure TForm1.UpdateScrollerActiveState;
begin
   if playScroll then StatusBar1.Panels[0].Text:='ACTIVE' else StatusBar1.Panels[0].Text:='NOT ACTIVE';
end;

procedure TForm1.SetSBFont;
begin
  textFont:=Form1.FontDialog1.Font;
end;

procedure TForm1.SaveSettings;
var pth:string;
    fl:TextFile;
begin
  pth:=ExtractFilePath(Application.ExeName)+'settings.txt';
  AssignFile(fl,pth);
  Rewrite(fl);
  WriteLn(fl,FontDialog1.Font.Name);
  WriteLn(fl,colortostring(FontDialog1.Font.Color));
  WriteLn(fl,inttostr(FontDialog1.Font.Size));
  WriteLn(fl,inttostr(scrollSpeed));
  WriteLn(fl,colortostring(ColorDialog1.Color));
  WriteLn(fl,inttostr(pll));
  WriteLn(fl,inttostr(filltoleft));
  WriteLn(fl,inttostr(lineMargin));
  WriteLn(fl,inttostr(convtype));
  CloseFile(fl);
end;

procedure TForm1.LoadSettings;
var pth,tstr:string;
    fl:TextFile;
begin
  pth:=ExtractFilePath(Application.ExeName)+'settings.txt';
  if not FileExists(pth) then SaveSettings;
  AssignFile(fl,pth);
  Reset(fl);
  ReadLn(fl,tstr);
  FontDialog1.Font.Name:=tstr;
  ReadLn(fl,tstr);
  FontDialog1.Font.Color:=stringtocolor(tstr);
  ReadLn(fl,tstr);
  FontDialog1.Font.Size:=strtoint(tstr);
  SetSBFont;
  ReadLn(fl,tstr);
  scrollSpeed:=strtoint(tstr);
  Form2.Edit3.Text:=inttostr(scrollSpeed);
  ReadLn(fl,tstr);
  ColorDialog1.Color:=StringToColor(tstr);
  bgColor:=ColorDialog1.Color;
  ReadLn(fl,tstr);
  pll:=StrToInt(tstr);
  Form2.Edit1.Text:=inttostr(pll);
  ReadLn(fl,tstr);
  filltoleft:=strtoint(tstr);
  ReadLn(fl,tstr);
  lineMargin:=strtoint(tstr);
  Form2.Edit2.Text:=inttostr(lineMargin);
  if filltoleft=1 then Form2.CheckBox1.Checked:=true else Form2.CheckBox1.Checked:=false;
  ReadLn(fl,tstr);
  convtype:=strtoint(tstr);
  Form2.ComboBox1.ItemIndex:=convtype;
  CloseFile(fl);
end;

function TGlobTimer.getDeltaTime:integer;
begin
  dtNow:=now;
  delta:=MilliSecondsBetween(dtNow,dtLast);
  dtLast:=dtNow;
  result:=delta;
end;

constructor TGlobTimer.Create;
begin
  dtLast:=now;
  dtNow:=now;
end;

procedure TPrompterRunner.DoRun;
begin
  while (true) do
  begin
    if playScroll then
    begin
        Form1.MoveText;
        Form1.RenderText;
    end;
    if (exitCall) then break;
    Application.ProcessMessages;
  end;
end;

end.


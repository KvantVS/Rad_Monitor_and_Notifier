unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, BCPort, TrayIcon, Menus, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    cb_ports: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    btnStart: TButton;
    btnStop: TButton;
    cbBaudRate: TComboBox;
    m_TelNumbers: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    PopupMenu1: TPopupMenu;
    comport: TBComPort;
    TrayIcon1: TTrayIcon;
    Memo1: TMemo;
    Edit1: TEdit;
    Button1: TButton;
    Label5: TLabel;
    Shape1: TShape;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  bComStatusConnected: boolean = false;

implementation


procedure PreparePDUText;
var
  s:  string;
begin
  s:=
end;

function ConvertTextToUCS2(text: string): string;
var
  i:integer;
  h:integer;
  s:string;
begin
  s:='';
  for i:=1 to length(text) do
  begin
    if ord(text[i]) in [192..255] then
      h:=ord(text[i]) - $c0 + $410
    else h:=ord(text[i]);
    s:=s + (inttohex(h,4));
  end;
  result:=s;
end;


function SendSMS: boolean;
begin
  PreparePDUText;
end;


{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  EnumComPorts(cb_ports.Items);
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  if cb_ports.itemindex<>-1 then
  begin
    comport.Port:=cb_ports.Text;
    comport.BaudRate:=TBaudRate(cbBaudRate.itemindex);
    if comport.Open then
      bComStatusConnected:=true;
  end;
  StatusBar1.Repaint;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  if comport.Close then bComStatusConnected:=false;
  StatusBar1.Repaint;  
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;
  TrayIcon1.FormVisible:=not TrayIcon1.FormVisible;
  TrayIcon1.IconVisible:=not TrayIcon1.IconVisible;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i,h:integer;
  s:string;
  ch:char;
begin
  memo1.Lines.add('');
  s:=edit1.text;
  memo1.lines.add(ConvertTextToUCS2(s));
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i:integer;
begin
  if comport.Connected then
    bComStatusConnected:=true
  else bComStatusConnected:=false;
  StatusBar1.Repaint;
end;

procedure TForm1.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if panel.index=1 then begin
    if bComStatusConnected then statusbar.Canvas.Brush.Color:=clLime
    else statusbar.Canvas.Brush.Color:=clRed;
    statusbar.Canvas.Ellipse(statusbar.Width-40,4,statusbar.Width-24,20);
  end;
end;

end.

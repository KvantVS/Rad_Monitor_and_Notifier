unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ShellAPI, StdCtrls, StrUtils, ComCtrls, CommCtrl, ToolWin;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    Label2: TLabel;
    Label1: TLabel;
    ListBox2: TListBox;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Button3: TButton;
    Label3: TLabel;
    ComboBox1: TComboBox;
    Label4: TLabel;
    Button4: TButton;
    Edit2: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    ComboBox2: TComboBox;
    Button6: TButton;
    CheckBox1: TCheckBox;
    btn_Refresh: TButton;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    Label7: TLabel;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure btn_RefreshClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  VUDictAppHandle:  THandle;
  TBHandle, MenuHandle, EditHandle:   THandle;  // TB - handle тулбара
  AppHandle:  THandle;
  ButtonHandles:  TStringList;  // Handl`ы кнопок
  sAppClass, sAppName: string;   // Названия окна и класса окна именно проги VU Dictionary
  function WindowFind(wnd: HWND; param: integer): boolean; stdcall;
  function ElementsFind(wnd: hwnd; param:integer): boolean; stdcall;
  procedure menunew;
  procedure GetProcList;

implementation

{$R *.dfm}

procedure GetProcList;
begin
  Form1.Listbox1.Items.Clear;
  Form1.Listbox1.Items.Add('Handle --- Имя класса --- Название окна');
  Form1.Listbox1.Items.Add('---------------------------------------');
  EnumWindows(@windowFind,0);
  Form1.Label1.Caption:='Всего окон: '+Inttostr(Form1.Listbox1.Items.Count);
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  aName,aClass:  array [0..255] of char;
  k:  integer;
begin
  ListBox2.Clear;
  k:=strtoint(Edit1.text);
  GetClassName(k,aClass,255);
  GetWindowText(k,aName,255);
  Label5.Caption:='Элементы окна "' + string(aName) + '" (' + string(aClass) + '):';
  ComboBox1.Items.Clear;
  Combobox2.Items.Clear;
  ButtonHandles.Clear;
  EnumChildWindows(strtoint(Edit1.text),@ElementsFind,0);
  ListBox2.ItemIndex:=-1;
  Edit2.Text:='';
  Edit2.Enabled:=false;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Listbox2.Clear;
  Label5.Caption:='Элементы окна "' + sAppName + '" (' + sAppClass + '):';
  EnumChildWindows(VUDictAppHandle,@ElementsFind,0);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  hP:  THandle;   // Handle процесса
  butRect: TRect;
  RectPointer: pointer;
  ReadCnt:  Cardinal;
  PID:  DWord;    // ID процесса
begin
  if combobox1.itemindex<>-1 then begin
    // --- получаем ИД процесса:
    GetWindowThreadProcessId(AppHandle,PID);
    // --- присоединяемся к процессу:
    hP:=OpenProcess(PROCESS_VM_READ or PROCESS_VM_OPERATION,false,PID);
    // --- выделяем в памяти процесса место под хранение квадрата кнопки и получаем адрес:
    RectPointer:=VirtualAllocEx(hP, @butRect, SizeOf(TRect), MEM_COMMIT, PAGE_READWRITE);
    // --- Получаем координаты:
    SendMessage(TBHandle, TB_GETITEMRECT, combobox1.ItemIndex, lParam(RectPointer));
    // --- забираем себе координаты кнопки путем чтения памяти по вышеполученому адресу:
    ReadProcessMemory(hP, RectPointer, @butRect, SizeOf(TRect),ReadCnt);
    // --- освобождаем память и отсоединяемся от чужого процесса:
    VirtualFreeEx(hP,RectPointer,SizeOf(TRect),MEM_RELEASE);
    CloseHandle(hP);
  //----- нажимаем кнопку: -------------------------------------------------------
  {  SendMessage(strtoint(s),TB_PRESSBUTTON,0,MAKELONG(word(true),0));
    SendMessage(strtoint(s),TB_PRESSBUTTON,0,MAKELONG(word(false),0));  }
    SendMessage(tbHandle, WM_LBUTTONDOWN, MK_LBUTTON, MAKELONG(butRect.Left+1, butRect.Top+1));
    SendMessage(tbHandle, WM_LBUTTONUP, MK_LBUTTON, MAKELONG(butRect.Left+1, butRect.Top+1));
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  ItemHandle: THandle;
begin
  MenuHandle:=GetSystemMenu(AppHandle,false);
//  MenuHandle:=CreateMenu;
  AppendMenu(MenuHandle, mf_Enabled+mf_string,0{@menunew},'test');
//  form1.Caption:=inttostr(GetLastError);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  s,sh:  string;
begin
  s:=combobox2.Items[combobox2.ItemIndex];
  sh:=buttonHandles[combobox2.ItemIndex];
  SendMessage(strtoint(sh),BM_CLICK,0,0);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  GetProcList;
  Listbox2.Clear;
end;

procedure TForm1.btn_RefreshClick(Sender: TObject);
begin
  GetProcList;
  Listbox2.Clear;
end;

procedure TForm1.Edit2Change(Sender: TObject);
var
  s,sh:  string;  //sh - Handle
  k:  byte;
begin
  if ListBox2.ItemIndex<>-1 then begin
    sh:=ListBox2.Items[Listbox2.ItemIndex];
    k:=pos(':',sh);
    sh:=leftstr(sh,k-1);
    s:=edit2.Text;
    sendmessage(Strtoint(sH),WM_SETTEXT,0,integer(s));
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  hP:  THandle;   // Handle процесса
  astr: array [0..30] of char;
  StrPointer: pointer;
  str:  shortstring;
  ReadCnt:  Cardinal;
  PID:  DWord;    // ID процесса
  I: Integer;
begin
  ButtonHandles:=Tstringlist.Create;
  GetProcList;
  Label2.Caption:='VU Dictionary handle = ' + inttostr(VUDictAppHandle);
  if IsWindowVisible(VUDictAppHandle) then begin
    Label5.Caption:='Элементы окна "' + sAppName + '" (' + sAppClass + '):';
    Combobox2.Items.Clear;
    EnumChildWindows(VUDictAppHandle,@ElementsFind,0);
  // ---- считываем названия кнопок на тулбаре: --------------------------------
    GetWindowThreadProcessId(VUDictAppHandle,PID);
    hP:=OpenProcess(PROCESS_VM_READ or PROCESS_VM_OPERATION,false,PID);
    // --- Читаем названия кнопок, заполняем Combobox: ---
    for I := 0 to 5 do begin
      StrPointer:=VirtualAllocEx(hP, @aStr, 31, MEM_COMMIT, PAGE_READWRITE);
      sendmessage(TBHandle, TB_GETBUTTONTEXT, i, lParam(StrPointer));
      ReadProcessMemory(hP, StrPointer, @aStr, 31,ReadCnt);
      VirtualFreeEx(hP,StrPointer,31,MEM_RELEASE);
      str:=string(Astr);
      Combobox1.Items.Add(str);
    end;
    CloseHandle(hP);
  end;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  ReleaseCapture;
  Perform(wm_syscommand,$f012,0);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
  s:  string;
  k:  byte;
begin
  s:=ListBox1.Items[Listbox1.ItemIndex];
  k:=pos(' ',s);
  s:=leftstr(s,k-1);
  AppHandle:=strtoint(s);
  Edit1.Text:=s;
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  Button1.Click;
end;

procedure TForm1.ListBox2Click(Sender: TObject);
var
  aStr: array [0..255] of char;
  s:  string;
  k:  integer;
  hP:  THandle;   // Handle процесса
  aTBstr: array [0..100] of char;
  StrPointer: pointer;
  str:  shortstring;
  ReadCnt:  Cardinal;
  PID:  DWord;    // ID процесса
  I: Integer;
  tooltipHandle:  THandle;
  aString:  array [0..255] of char;
  strpointer2: pointer;
  ButInfo:  TBBUTTONINFO;
  ButInfoPointer: pointer;
  aTooltipText: array [0..79] of char;
  str2: shortstring;
  k2: integer;
  aText:  array [0..255] of Widechar;
  mypointer:  pointer;
  ptrtooltipinfo: pointer;
  atooltipInfo: array [0..255] of char;
  myToolInfo: TOOLINFO;
  k3: cardinal;
  aClass: array [0..255] of char;
begin
  s:=listbox2.Items[listbox2.ItemIndex];
  k:=pos(':',s);
  s:=leftstr(s,k-1);
  SendMessage(strtoint(s), WM_GETTEXT, length(aStr), integer(@aStr));
  Edit2.Enabled:=true;
  Edit2.Text:=aStr;
  Combobox1.Items.Clear;
  Button3.Enabled:=false;

  GetClassName(StrToInt(s), aClass, 256);
  if pos('toolbar', LowerCase(string(aclass)))<>0 then
  begin
    Button3.Enabled:=true;
    TBHandle:=strtoint(s); // Handle
    GetWindowThreadProcessId(apphandle,PID);
    hP:=OpenProcess(PROCESS_VM_READ or PROCESS_VM_OPERATION,false,PID);

    k:=sendmessage(TBHandle,TB_BUTTONCOUNT,0,0);
    for I:=0 to k-1 do begin

{    // --- Вытаскиваем инфу о кнопке (для выяснения стилей кнопки):
      ButInfoPointer:=VirtualAllocEx(hP, @ButInfo, SizeOf(TBBUTTONINFOW), MEM_COMMIT, PAGE_READWRITE);
      Sendmessage(TBHandle, TB_GETBUTTONINFO, i, lParam(ButInfoPointer));
      ReadProcessMemory(hP, ButInfoPointer, @ButInfo, SizeOf(TBBUTTONINFOW),ReadCnt);
      VirtualFreeEx(hP,ButInfoPointer,SizeOf(TBBUTTONINFOW),MEM_RELEASE);
      { Если стиль НЕ содержит BTNS_SHOWTEXT, то выводить вспылвающую подсказку этой кнопки }
//      s:=IntToHex(k2,0);
//      k2:=HexToBin }

      // --- Ищем текст кнопки (если в стиле кнопки ЕСТЬ стиль BTNS_SHOWTEXT):
      StrPointer:=VirtualAllocEx(hP, @aTBstr, 101, MEM_COMMIT, PAGE_READWRITE);
      sendmessage(TBHandle, TB_GETBUTTONTEXT, i, lParam(StrPointer));
      ReadProcessMemory(hP, StrPointer, @aTBstr, 101,ReadCnt);
      VirtualFreeEx(hP,StrPointer,101,MEM_RELEASE);

{      k3:=sendmessage(TBHandle, TB_GETTOOLTIPS, 0, 0); // handle tootip`а
      ptrTooltipinfo:=VirtualAllocEx(hP, @myToolInfo, SizeOf(TOOLINFO), MEM_COMMIT, PAGE_READWRITE);
      mytoolinfo.cbSize:=sizeof(Toolinfo);
      mytoolinfo.hwnd:=TBHandle;
      mytoolinfo.uId:=1; // mytoolinfo.uId:=tbhandle;
      mytoolinfo.lpszText:=@atooltiptext;
      sendmessage(k3,TTM_GETTEXT, 80, lparam(ptrToolTipInfo));
      ReadProcessMemory(hp, ptrTooltipinfo, @myToolInfo, SizeOf(TOOLINFO), ReadCnt);
      VirtualFreeEx(hP, ptrTooltipinfo, SizeOf(TOOLINFO), MEM_RELEASE);}

      str:=string(aTBstr);
      Combobox1.Items.Add(inttostr(i) + ' - ' + str);
    end;
    CloseHandle(hp);
  end;

//  sendMessage(TBHandle,TB_GETSTRING, MAKEWPARAM(sizeof(aString),0),integer(@aString));

end;


function WindowFind(wnd: HWND; param: integer): boolean; stdcall;
var
  aName,aClass:  array [0..255] of char;
  sName, sClassName:  string;
begin
  GetClassName(wnd,aClass,255);

  GetWindowText(wnd,aName,255);
//  SendMessage(wnd, WM_GETTEXT, length(aName), integer(@aName));

  sName:=String(aName);
  sClassName:=string(aClass);
  if IswindowVisible(wnd)<>Form1.CheckBox1.Checked then
  form1.listbox1.Items.Add(inttostr(wnd)+' --- ' + sClassName + ' --- ' + sName);
  if (AnsiLeftStr(sName,7)='Словарь') or (LeftStr(sName,13)='VU Dictionary') then begin
    if (sClassName='TfrmSelect') then begin
      VUDictAppHandle:=wnd;
      AppHandle:=wnd;
      sAppClass:=string(aClass);
      sAppName:=string(aName);
    end;
  end;
  result:=true;
end;


function ElementsFind(wnd: hwnd; param: integer): boolean; stdcall;
var
  aClName, aText:  array [0..255] of char; // aText - текст элемента через API-функцию
  aText2:  array [0..255] of char; // aText2 - текст элемента через сообщение WM_GETTEXT
{  i: Integer;
  textlength: Integer;
  Text: PChar;
  textstr:  string; }
begin
//  if IsWindowVisible(wnd)<>longbool(0) then begin
    result:=wnd<>0;
    if result then begin
      GetClassName(wnd,aCLName,255);
//      GetWindowText(wnd,aText,255);

     SendMessage(wnd, WM_GETTEXT, length(aText2), integer(@aText2));

     {      textlength := SendMessage(Wnd, WM_GETTEXTLENGTH, 0, 0);
      if textlength = 0 then textstr := ''
      else
      begin
        GetMem(Text, textlength + 1);
        SendMessage(Wnd, WM_GETTEXT, textlength + 0, Integer(Text));
        textstr := Text;
        FreeMem(Text);
      end; }

      Form1.Listbox2.Items.Add(inttostr(wnd) + ': ' + string(aclname){ + ' --- ' + string(aText)} + ' --- ' + string(aText2));
//      Form1.Listbox2.Items.Add(inttostr(wnd) + ': ' + string(aclname){ + ' --- ' + string(aText)} + ' --- ' + textstr);
      if aCLName='TToolBar' then TBHandle:=wnd;  // нашли handle тулбара
      if aCLname='Edit' then EditHandle:=wnd;
      if (aCLName='Button') or (aCLName='TButton') or (pos('BitBtn',string(aCLName))<>0) then begin
        form1.Combobox2.Items.Add({TextStr}string(aText2));
        ButtonHandles.Add(inttostr(wnd));
      end;

//      EnumChildWindows(wnd,@ElementsFind,0);
    end;
end;


procedure menunew;
begin
  Form1.Caption:='Меню пашет!';
end;

end.

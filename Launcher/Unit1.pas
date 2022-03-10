unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ShellAPI, StdCtrls, StrUtils, ComCtrls, CommCtrl, ToolWin, ExtCtrls;

type
  TForm1 = class(TForm)
    Label5: TLabel;
    Timer1: TTimer;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  HWND_GPMonitor, HWND_ConnectionWindow: HWND;
  HWND_ConnButtonOK, HWND_GPMonWaitButton:  hwnd;
  bFirstStart:  boolean = true;
  sGPMonDir:      string = 'C:\GPMonitor3';//'D:\sidorchuk_vv\Мои документы\[Programming]\Delphi\Чужие окна и процессы\GPMonitor3';
  sGPMonFileName: string = 'GPMonitor3.exe';

  function GPMonitorWindowFind(wnd: HWND; param: integer): boolean; stdcall;
  function ConnectionWindowFind(wnd: HWND; param: integer): boolean; stdcall;
  function ConnectionButtonFind(wnd: HWND; param: integer): boolean; stdcall;
  function GPMonitorButtonFind        (wnd: hwnd; param: integer): boolean; stdcall;
  procedure MonitorRun;
  procedure MainProcedure;
  procedure hook(switch: boolean; HAppHandle: HWND); stdcall; external 'hook_dll.dll';

implementation

{$R *.dfm}

// *****************************************************************************
// ******** Процедура поиска окон, элементов и взаимодействия с ними ***********
// *****************************************************************************
procedure MainProcedure;
var
  textLength, k,c : integer;
  aText:  array [0..255] of char;
  sText:  string;
  SysMenu, hhMenu, subMenu: HMenu;
//  MenuID: Cardinal;
//  Mii:  MENUITEMINFO;
//  MenuText: array [0..255] of char;
//  BRes: LongBool;
begin
  HWND_GPMonitor:=0;
  EnumWindows(@GPMonitorWindowFind, 0);
  // === if монитор запущен ====================================================
  if HWND_GPMonitor<>0 then
  begin
    // 1. будем выполнять поиск ОКНА ПОДКЛЮЧЕНИЯ до тех пор, пока оно не появится
    HWND_ConnectionWindow:=0;
    k:=0;

    repeat
      inc(k);
      sleep(300);
      EnumWindows(@ConnectionWindowFind, 0);
    until (HWND_ConnectionWindow<>0) or (k=15);

    if HWND_ConnectionWindow = 0 then form1.Memo1.lines.add('Не было найдено окно подключения к видеокамере, кол-во попыток = ' + inttostr(k))
    else begin
      // === 2. теперь ищем кнопку ОК, и жмем ее ===============================
      HWND_ConnButtonOK:=0;
      k:=0;

      repeat
        inc(k);
        EnumChildWindows(HWND_ConnectionWindow, @ConnectionButtonFind, 0);
        if HWND_ConnButtonOK=0 then sleep(500);
      until (HWND_ConnButtonOK<>0) or (k=10);

      if HWND_ConnButtonOK = 0 then form1.Memo1.lines.add('Не была найдена кнопка ОК в окне подключения, кол-во попыток = ' + inttostr(k))
      else
        SendMessage(HWND_ConnButtonOK, BM_CLICK, 0, 0);
    end;

    // === 3. Ищем кнопку "Ожидать" и жмем ее ==================================
    sleep(500);
    k:=0;
    HWND_GPMonWaitButton:=0;

    repeat
      EnumChildWindows(HWND_GPMonitor, @GPMonitorButtonFind, 0);
      if HWND_GPMonWaitButton=0 then sleep(500);
      inc(k);
    until (HWND_GPMonWaitButton<>0) or (k=10);

    if HWND_GPMonWaitButton=0 then form1.Memo1.lines.add('Не была найдена кнопка Ожидать, кол-во попыток = ' + inttostr(k));
    if HWND_GPMonWaitButton<>0 then
      SendMessage(HWND_GPMonWaitButton, BM_CLICK, 0, 0);

    // === 4. Делаем кнопку "Стоп" недоступной =================================
    sleep(3000);
    textlength := SendMessage(HWND_GPMonWaitButton, WM_GETTEXTLENGTH, 0, 0);
    SendMessage(HWND_GPMonWaitButton, WM_GETTEXT, textlength+1{length(aText2)}, integer(@aText));
    sText:=string(aText);
    if sText='Стоп' then
      EnableWindow(HWND_GPMonWaitButton, false);

    // === 5. Убираем возможность закрыть программу ============================
    try
      SysMenu:=GetSystemMenu(HWND_GPMonitor, False);
      Windows.EnableMenuItem(SysMenu, SC_CLOSE, MF_DISABLED Or MF_GRAYED);
    except
      on e: exception do form1.Memo1.lines.add(e.Message);
    end;

    // === 6. Удаляем пункт меню "Выход" =======================================
    hhMenu:=GetMenu(HWND_GPMonitor);
    subMenu:=GetSubMenu(hhMenu, 0);
    c:=GetMenuItemCount(subMenu);
    {for i := 0 to c-1 do
    begin
      MII.cbSize:=sizeOf(MenuItemInfo);
      MII.fMask:=MIIM_STRING;
      MII.dwTypeData:=@MenuText;
      MII.cch:=256;
      GetMenuItemInfo(subMenu, i, true, MII);
      sText:=string(MenuText);
      k:=pos('&', sText);
      delete(sText, k,1);
      form1.memo1.lines.add(inttostr(i) + ': ' + sText);
      if sText='Выход' then
      begin            }
        k:=longInt(DeleteMenu(subMenu, c-1, MF_BYPOSITION));
        form1.Memo1.lines.add(inttostr(k));
        DeleteMenu(subMenu, c-2, MF_BYPOSITION);
//        break;
//      end;
//    end; //for
  end;
  //============================================================================
end;

// *****************************************************************************
// ************************ Запуск GPMonitor'а *********************************
// *****************************************************************************
procedure MonitorRun;
var
  c:  cardinal;
  k:  byte;
  s:  string;
  b:  longbool;
begin
  b:=false;
//  result:=true;
  c:=ShellExecute(0, PChar('open'), PChar(sGPMonFileName), nil, PChar(sGPMonDir), SW_MAXIMIZE);
  Form1.memo1.lines.add('Попытка запустить монитор');
  if c>32 then
    Form1.memo1.lines.add('Success!')
  else
    Form1.memo1.lines.add('Запуск не удался!');

  Form1.memo1.lines.add('shellexecute вернула: ' + inttostr(c));

  if c>32 {Success!} then
  begin
  // --- Теперь будем ждать, пока окно не появится окончательно на экране ------
    k:=0;
    HWND_GPMonitor:=0;
    repeat
      inc(k);
      EnumWindows(@GPMonitorWindowFind, 0);
      s:='не могу определить visible - handle еще не найден';
      if HWND_GPMonitor<>0 then
      begin
        s:='NOT visible';
        b:=IsWindowVisible(HWND_GPMonitor);
        if b then
          s:='Visible!';
      end;
      Form1.memo1.lines.add(s + ' (Попытка: ' + inttostr(k) + ')');
      sleep(1000);
    until (HWND_GPMonitor<>0) AND ((b) or (k=20));  // 20 попыток (уж за 20 секунд должно появиться)

    if HWND_GPMonitor<>0 then MainProcedure;
  end;
end;


// *****************************************************************************
// ************************ Поиск окна программы *******************************
// *****************************************************************************
function GPMonitorWindowFind(wnd: HWND; param: integer): boolean; stdcall;
var
  aName, aClass:      array [0..255] of char;
  sName, sClassName:  string;
begin
  result:=true;
  GetClassName(wnd, aClass, 255);
  GetWindowText(wnd, aName, 255);
  sName:=String(aName);
  sClassName:=string(aClass);

  if (wnd <> HInstance) and (wnd <> Form1.Handle)
  then begin
    if pos('Afx:400000:', sClassName)<>0 then
      if pos('GPMonitor3', sName)<>0 then
      begin
        // нашли окно
        HWND_GPMonitor:=wnd;
        result:=false;
      end;
  end;
end;

// *****************************************************************************
// ******************** Поиск окна подключения к камере ************************
// *****************************************************************************
function ConnectionWindowFind(wnd: HWND; param: integer): boolean; stdcall;
var
  aName, aClass:      array [0..255] of char;
  sName, sClassName:  string;
begin
  result:=true;
  GetClassName(wnd, aClass, 255);
  GetWindowText(wnd, aName, 255);
  sName:=String(aName);
  sClassName:=string(aClass);

  if (wnd <> HInstance) and (wnd <> Form1.Handle)
  then begin
    if pos('#32770', sClassName)<>0 then
    begin
      if pos('Подключение к 192.168.0.90', sName)<>0 then
      begin
        // нашли окно
        HWND_ConnectionWindow:=wnd;
        form1.Memo1.Lines.Add('Окно подключения найдено');
        result:=false;
      end;
    end;
  end;
end;

// *****************************************************************************
// ******************** Поиск кнопки ОК в окне подключения *********************
// *****************************************************************************
function ConnectionButtonFind(wnd: hwnd; param: integer): boolean; stdcall;
var
  aClName:  array [0..255] of char; // aText - текст элемента через API-функцию
  aText2:  array [0..255] of char; // aText2 - текст элемента через сообщение WM_GETTEXT
  TextLength: integer;
  sCl,sLowCl, sText:  string;
begin
  result:=wnd<>0;
  if result then begin
    GetClassName(wnd, aCLName, 255);
    sCL:=string(aCLName);
//      GetWindowText(wnd,aText,255);   // коряво работает
    textlength := SendMessage(Wnd, WM_GETTEXTLENGTH, 0, 0);
    SendMessage(wnd, WM_GETTEXT, textlength+1, integer(@aText2));
    sText:=string(aText2);

    sLowCl:=AnsiLowerCase(sCL);
    if (pos('btn', sLowCl)<>0) or (pos('button', sLowCl)<>0) then
      if sText='ОК' then begin
        HWND_ConnButtonOK:=wnd;
        form1.Memo1.Lines.Add('Кнопка ОК найдена');
      end;
  end;
end;

// *****************************************************************************
// ***************** Поиск кнопки Ожидать в окне программы *********************
// *****************************************************************************
function GPMonitorButtonFind(wnd: hwnd; param: integer): boolean; stdcall;
var
  aClName:  array [0..255] of char; // aText - текст элемента через API-функцию
  aText2:  array [0..255] of char; // aText2 - текст элемента через сообщение WM_GETTEXT
  TextLength: integer;
  sCl,sLowCl, sText:  string;
begin
  result:=wnd<>0;
  if result then begin
    GetClassName(wnd, aCLName, 255);
    sCL:=string(aCLName);

    textlength := SendMessage(Wnd, WM_GETTEXTLENGTH, 0, 0);
    SendMessage(wnd, WM_GETTEXT, textlength+1{length(aText2)}, integer(@aText2));
    sText:=string(aText2);

    sLowCl:=AnsiLowerCase(sCL);
    if (pos('btn', sLowCl)<>0) or (pos('button', sLowCl)<>0) then
    begin
      if sText='Ожидать' then
      begin
        HWND_GPMonWaitButton:=wnd;
        form1.Memo1.Lines.Add('Кнопка Ожидать найдена');
        result:=false;
      end;
    end;
//    EnumChildWindows(wnd, @GPMonitorButtonFind, 0); { TODO : Проверить! }
  end;
end;

// *****************************************************************************
// ******************** Установка привилегий процессу **************************
// *****************************************************************************
function SetPrivilege(aPrivilegeName: string; aEnabled: boolean ): boolean;
var
  TPPrev, TP: TTokenPrivileges;
  hToken: THandle;
  dwRetLen: DWord;
begin
  Result:= False;
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
  TP.PrivilegeCount:=1;
  if (LookupPrivilegeValue(nil, PChar(aPrivilegeName), TP.Privileges[0].LUID)) then
  begin
    if (aEnabled) then TP.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED
    else TP.Privileges[0].Attributes:=0;
    dwRetLen:=0;
    Result:=AdjustTokenPrivileges(hToken,False,TP, SizeOf(TPPrev), TPPrev,dwRetLen);
  end;
  CloseHandle(hToken);
end;

//==============================================================================


procedure TForm1.FormCreate(Sender: TObject);
begin
  Left := Screen.Width;
  bFirstStart:=true;    // чтобы быстро запустить GPMonitor в первый раз
  Timer1.Enabled:=true;
  if not SetPrivilege('SeDebugPrivilege',True)
    then memo1.Lines.Add('Не удалось установить права');
end;


procedure TForm1.Timer1Timer(Sender: TObject);
var
  s:  string;
begin
  Timer1.Enabled:=false;
  if form1.Visible then Form1.Hide;
  HWND_GPMonitor:=0;
  EnumWindows(@GPMonitorWindowFind, 0);
  // === if монитор не запущен =================================================
  if HWND_GPMonitor = 0 then
  begin
    memo1.Lines.clear;
    s:='Попытка запуска монитора';
    if bFirstStart then s:=s + '...'
                   else s:=s + ' через 4 секунды...';
    form1.Memo1.Lines.Add(s);
    if not bFirstStart then Sleep(4000);
    MonitorRun;
  end;
  bFirstStart:=false;
  Timer1.Enabled:=true;
end;

end.

unit USS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IEParser, XPMan, ComCtrls, ExtCtrls, Menus, IdHTTP,
  AppEvnts, WinInet, Spin, Buttons, ShellAPI, StrUtils;

type
  TForm1 = class(TForm)
    IPrsr: TIEParser;
    Xpmnfst: TXPManifest;
    DlgSave: TSaveDialog;
    Pm1: TPopupMenu;
    MniOpen: TMenuItem;
    Mm: TMainMenu;
    MniMore: TMenuItem;
    MniAbout: TMenuItem;
    pgc: TPageControl;
    tssearch: TTabSheet;
    tsadmin: TTabSheet;
    grpmecanismo: TGroupBox;
    imgyahoo: TImage;
    imggoogle: TImage;
    imgbing: TImage;
    imgbaidu: TImage;
    imgamfibi: TImage;
    imglycos: TImage;
    grpstring: TGroupBox;
    grpfuncoes1: TGroupBox;
    btnpesquisar: TBitBtn;
    BBtnSave1: TBitBtn;
    BBtnClear1: TBitBtn;
    Rb1: TRadioButton;
    Rb2: TRadioButton;
    Rb3: TRadioButton;
    Rb4: TRadioButton;
    Rb5: TRadioButton;
    Rb6: TRadioButton;
    stat2: TStatusBar;
    grpdefinicoes: TGroupBox;
    lblpaginainicial: TLabel;
    sepaginainicial: TSpinEdit;
    lblpaginafinal: TLabel;
    sepaginafinal: TSpinEdit;
    cbbdom1: TComboBox;
    pb2: TProgressBar;
    TmrAtualiza: TTimer;
    stat1: TStatusBar;
    pb1: TProgressBar;
    BBtnCancel1: TBitBtn;
    Pm2: TPopupMenu;
    MniModStr: TMenuItem;
    MniAddStr: TMenuItem;
    MniSave: TMenuItem;
    N1: TMenuItem;
    MniRmvStr: TMenuItem;
    MniClear: TMenuItem;
    N2: TMenuItem;
    DlgOpen: TOpenDialog;
    MniLoad: TMenuItem;
    N3: TMenuItem;
    cbbling1: TComboBox;
    chkdominio: TCheckBox;
    chklinguagem: TCheckBox;
    cbbling2: TComboBox;
    lblresults: TLabel;
    cbbresults: TComboBox;
    lststrings: TListBox;
    grplistalinks: TGroupBox;
    lstencontrados: TListBox;
    grpadmstr: TGroupBox;
    lstadmstrs: TListBox;
    grpalvo: TGroupBox;
    edtalvo: TEdit;
    btnscan: TBitBtn;
    BBtnCancel2: TBitBtn;
    BBtnClear2: TBitBtn;
    BBtnSave2: TBitBtn;
    grpocorrencias: TGroupBox;
    lvvuls: TListView;
    chksubpastas: TCheckBox;
    procedure btnpesquisarClick(Sender: TObject);
    procedure IPrsrAnchor(Sender: TObject; hRef, Target, Rel, Rev, Urn,
      Methods, Name, Host, HostName, PathName, Port, Protocol, Search,
      Hash, AccessKey, ProtocolLong, MimeType, NameProp: String;
      Element: TElementInfo);
    procedure BBtnSave1Click(Sender: TObject);
    procedure BBtnClear1Click(Sender: TObject);
    procedure btnscanClick(Sender: TObject);
    procedure BBtnSave2Click(Sender: TObject);
    procedure BBtnClear2Click(Sender: TObject);
    procedure BBtnCancel2Click(Sender: TObject);
    procedure MniOpenClick(Sender: TObject);
    procedure MniAboutClick(Sender: TObject);
    procedure TmrAtualizaTimer(Sender: TObject);
    procedure BBtnCancel1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MniAddStrClick(Sender: TObject);
    procedure MniRmvStrClick(Sender: TObject);
    procedure MniSaveClick(Sender: TObject);
    procedure MniModStrClick(Sender: TObject);
    procedure MniClearClick(Sender: TObject);
    procedure MniLoadClick(Sender: TObject);
    procedure Rb1Click(Sender: TObject);
    procedure Rb2Click(Sender: TObject);
    procedure Rb3Click(Sender: TObject);
    procedure Rb4Click(Sender: TObject);
    procedure cbbling2KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ThreadSearch;
  end;

var
  Form1             : TForm1;
  Cancel1, Cancel2  : BOOL;
  TSearch           : DWORD;

implementation

{$R *.dfm}

function CheckConexao: Boolean;
 const
  INTERNET_CONNECTION_MODEM = 1;
  INTERNET_CONNECTION_LAN   = 2;
  INTERNET_CONNECTION_PROXY = 4;
  INTERNET_CONNECTION_MODEM_BUSY = 8;
 var
  ConnectionTypes: DWORD;
begin
  ConnectionTypes := INTERNET_CONNECTION_MODEM
  + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
  if InternetGetConnectedState(@ConnectionTypes, 0) then
    Result := True
  else
    Result := False;
end;

function CheckRButton(Frm: TForm): string;
 var
  i: Integer;
begin
  for i := 0 to (Frm.ComponentCount - 1) do
  begin
    if (Frm.Components[i] is TRadioButton) then
    begin
      if TRadioButton(Frm.Components[i]).Checked = True then
      begin
        Result := TRadioButton(Frm.Components[i]).Name;
        Exit;
      end;
    end;
  end;
end;

function ListFocused(Frm: TForm): TComponent;
 var
  i: Integer;
begin
  for i := 0 to (Frm.ComponentCount - 1) do
  begin
    if (Frm.Components[i] is TListBox) then
    begin
      if TListBox(Frm.Components[i]).Focused then
      begin
        Break;
      end;
    end;
  end;
  Result := TListBox(Frm.Components[i]);
end;

procedure SaveListViewToFile(ListView: TListView; FileName: string);
 var
  idxItem, idxSub, IdxImage: Integer;
  F: TFileStream;
  pText: PChar;
  sText: string;
  W, ItemCount, SubCount: Word;
begin
  with ListView do
  begin
    ItemCount := 0;
    SubCount  := 0;
    F := TFileStream.Create(FileName, fmCreate or fmOpenWrite);

    ItemCount := Items.Count;
    F.Write(ItemCount, SizeOf(ItemCount));

    for idxItem := 1 to ItemCount do
    begin
      with Items[idxItem - 1] do
      begin
        //Save subitems count
        SubCount := Subitems.Count;
        F.Write(SubCount, SizeOf(SubCount));
        //Save ImageIndex
        IdxImage := ImageIndex;
        F.Write(IdxImage, SizeOf(IdxImage));
        //Save Caption
        sText := Caption;
        w     := Length(sText);
        pText := StrAlloc(Length(sText) + 1);
        StrPLCopy(pText, sText, Length(sText));
        F.Write(w, SizeOf(w));
        F.Write(pText^, w);
        StrDispose(pText);
        for idxSub := 0 to (SubItems.Count - 1) do
        begin
          //Save Item's subitems
          sText := SubItems[idxSub];
          w     := Length(sText);
          pText := StrAlloc(Length(sText) + 1);
          StrPLCopy(pText, sText, Length(sText));
          F.Write(w, SizeOf(w));
          F.Write(pText^, w);
          StrDispose(pText);
        end;
      end;
    end;
  end;
  F.Free;
end;

function CheckUrl(URL: string): Integer;
 var
  hSession, hFile : hInternet;
  Index, Len      : DWORD;
  Code            : array[1..20] of Char;
begin
  if (Pos('http://', Lowercase(URL)) = 0) then
    URL := 'http://' + URL;
  hSession := InternetOpen('InetURL:/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then
  begin
    hFile := InternetOpenUrl(hSession, PChar(URL), nil, 0, INTERNET_FLAG_RELOAD, 0);
    Index := 0;
    Len := 10;
    HttpQueryInfo(hFile, HTTP_QUERY_STATUS_CODE, @Code, Len, Index);
    if Assigned(hfile) then
      InternetCloseHandle(hFile);
    InternetCloseHandle(hSession);
  end;
  Result := StrToInt(PChar(@Code));
end;

procedure Concat(List: TListView; URL: string);
 var
  IdHtp : TidHTTP;
  LsItem: TListItem;
begin
  IdHtp := TidHTTP.Create(Application);
  IdHtp.ReadTimeout := 2000;
  IdHtp.Host := URL;
  LsItem := List.Items.Add;
  LsItem.Caption := URL;
  try
    IdHtp.Get(URL);
  except
    case CheckUrl(URL) of
      200..206: LsItem.SubItems.Add('Diretório Funcionando!');
      300..307: LsItem.SubItems.Add('Erro, Diretório Redirecionado!');
      401: LsItem.SubItems.Add('Erro, Autorização Requerida!');
      404: LsItem.SubItems.Add('Erro, Diretório Não Econtrado!');
    else
      LsItem.SubItems.Add('Erro, Erro Não Identificado!');
    end;
  end;
  IdHtp.Destroy;
end;

procedure DoMyFormThings(MyURL: string; MyPag: Integer);
 var
  x: Integer;
begin
  Form1.grpmecanismo.Enabled := False;
  Form1.grpstring.Enabled := False;
  Form1.btnpesquisar.Enabled := False;
  Form1.grpdefinicoes.Enabled := False;
  Form1.stat1.Panels[2].Text := 'Pesquisando...';
  Form1.iprsr.URL:= MyURL;
  for x := 0 to 50 do
  begin
    Form1.pb1.Position := Form1.pb1.Position + 5;
  end;
  Form1.iprsr.Go;
  Form1.stat1.Panels[1].Text := 'Página(s): ' + IntToStr(MyPag) + ' de '
  + IntToStr(Form1.sepaginafinal.Value);
  Form1.pb1.Position := 100;
  Form1.stat1.Panels[2].Text := 'Concluido';
  Form1.grpstring.Enabled := True;
  Form1.btnpesquisar.Enabled := True;
  Form1.grpdefinicoes.Enabled := True;
  Form1.grpmecanismo.Enabled := True;
end;

procedure TForm1.btnpesquisarClick(Sender: TObject);
 var
  Search: DWORD;
begin
  TSearch := CreateThread(nil, 0, @TForm1.ThreadSearch, nil, 0, Search);
end;

procedure TForm1.btnscanClick(Sender: TObject);
 var
  s    : string;
  Lista: TStrings;
  x, y : integer;
begin
  if (CheckConexao = False) then
  begin
    MessageBox(
    Handle, 'Verifique Sua Conexão Com a Internet!', 'Erro', MB_OK
    + MB_DEFBUTTON1 + MB_ICONERROR);
    Exit;
  end;
  if ((lstadmstrs.Items.Count - 1) < 0) then
  begin
    MessageBox(Handle, 'Lista do Admin Strings Vazia', 'Erro', MB_OK
    + MB_DEFBUTTON1 + MB_ICONERROR);
    Exit;
  end;
  Cancel1 := False;
  BBtnCancel2.Visible := True;
  pb2.Position := 0;
  Lista := lstadmstrs.Items;
  s := edtalvo.Text;
  y := Lista.Count - 1;
  if (Pos('http', edtalvo.Text) > 0) then
  begin
    edtalvo.Enabled := False;
    grpadmstr.Enabled := False;
    btnscan.Enabled := False;
    if (Copy(s, Length(s), 1) <> '/') then
    begin
      s := edtalvo.Text + '/';
    end;
    pb2.Max := y;
    for x := 0 to y do
    begin
      if (Cancel1 = True) then
        Break;
      lstadmstrs.ItemIndex := x;
      Concat(lvvuls, s + Lista[x]);
      Application.ProcessMessages;
      stat2.Panels[0].Text:= InttoStr(x) + ' | ' + InttoStr(y + 1);
      stat2.Panels[1].Text:= s + Lista[x];
      pb2.Position:= x;
    end;
    BBtnCancel2.Visible := False;
    stat2.Panels[0].Text := InttoStr(x) + ' | ' + InttoStr(y + 1);
    stat2.Panels[1].Text := 'Concluido';
    pb2.Position := 0;
    edtalvo.Enabled := True;
    lstadmstrs.ItemIndex := 0;
    grpadmstr.Enabled := True;
    btnscan.Enabled := True;
  end else
    MessageBox(
    Handle, 'Endereço de URL Inválido!', 'Erro', MB_OK
    + MB_DEFBUTTON1 + MB_ICONERROR);
end;

procedure TForm1.IPrsrAnchor(Sender: TObject; hRef, Target, Rel, Rev,
Urn, Methods, Name, Host, HostName, PathName, Port, Protocol, Search,
Hash, AccessKey, ProtocolLong, MimeType, NameProp: String;
Element: TElementInfo);
begin
  if ((Pos('microsoft', href) or Pos('Microsoft', href) or Pos('google', href)
  or Pos('cache', href) or Pos('yotube', href) or Pos('orkut', href)
  or Pos('tube', href) or Pos('Google', href) or Pos('Cache', href)
  or Pos('Yotube', href) or Pos('Orkut', href) or Pos('Tube', href)
  or Pos ('Yahoo', href) or Pos ('yahoo', href) or Pos ('Bing', href)
  or Pos ('bing', href) or Pos ('javascript', href) or Pos ('baidu', href)
  or Pos ('Baidu', href) or Pos ('Lycos', href) or Pos ('lycos', href)
  or Pos ('Amfibi', href) or Pos ('amfibi', href) or Pos ('MSN', href)
  or Pos ('msn', href)= 0) and (Length(hRef) <> 0)) then
  begin
    if (lstencontrados.Items.IndexOf(hRef) < 0) then
      lstencontrados.Items.Add(href);
  end;
  stat1.Panels[0].Text := 'Encontrados: ' + IntToStr(lstencontrados.Items.Count);
end;

procedure TForm1.BBtnCancel1Click(Sender: TObject);
begin
  Cancel2 := True;
end;

procedure TForm1.BBtnCancel2Click(Sender: TObject);
begin
  Cancel1 := True;
end;

procedure TForm1.BBtnSave1Click(Sender: TObject);
begin
  if dlgSave.Execute then
  begin
    lstencontrados.Items.SavetoFile(dlgSave.FileName);
  end;
end;

procedure TForm1.BBtnSave2Click(Sender: TObject);
begin
  if dlgSave.Execute then
  begin
    SaveListViewToFile(lvvuls, dlgSave.FileName);
  end;
end;

procedure TForm1.BBtnClear1Click(Sender: TObject);
begin
  stat1.Panels[0].Text := 'Encontrados:';
  stat1.Panels[1].Text := 'Página (s):';
  stat1.Panels[2].Text := 'Aguardando...';
  lstencontrados.Items.Clear;
  pb1.Position := 0;
end;

procedure TForm1.BBtnClear2Click(Sender: TObject);
begin
  lvvuls.Clear;
  stat2.Panels[0].Text := '';
  stat2.Panels[1].Text := '';
  pb2.Position := 0;
end;

procedure TForm1.MniOpenClick(Sender: TObject);
 label
  Erro;
begin
  case pgc.ActivePageIndex of
    0:
    begin
      if (lstencontrados.ItemIndex <> - 1) then
      begin
        ShellExecute(Handle, 'Open', PChar(
        lstencontrados.Items.Strings[lstencontrados.ItemIndex]), nil, nil, SW_NORMAL);
        Exit;
      end else
        goto Erro;
    end;
    1:
    begin
      if (lvvuls.ItemIndex <> - 1) then
      begin
        ShellExecute(Handle, 'Open', PChar(
        lvvuls.ItemFocused.Caption), nil, nil, SW_NORMAL);
        Exit;
      end else
        goto Erro;
    end;
  end;
  Erro:
  begin
    MessageBox(Handle, 'Não foi Selecionado Nenhum Item da Lista,' + #13
    + 'Verifique se a Sua Busca foi Feita Corretamente!', 'Erro', MB_OK
    + MB_DEFBUTTON1 + MB_ICONERROR);
  end;
end;

procedure TForm1.MniLoadClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    TListBox(ListFocused(Form1)).Clear;
    TListBox(ListFocused(Form1)).Items.LoadFromFile(dlgOpen.FileName);
  end;
end;

procedure TForm1.MniAddStrClick(Sender: TObject);
 var
  Add: string;
begin
  if InputQuery(
  'Adicionar String', 'Digite Uma String Para Ser Adicionada:', Add) then
  begin
    TListBox(ListFocused(Form1)).Items.Add(Add);
  end;
end;

procedure TForm1.MniModStrClick(Sender: TObject);
 var
  Add: string;
begin
  if (TListBox(ListFocused(Form1)).ItemIndex <> - 1) then
  begin
    Add := TListBox(ListFocused(Form1)).Items[TListBox(ListFocused(Form1)).ItemIndex];
    if InputQuery(
    'Modificar String', 'Digite Uma String Nova:', Add) then
    begin
      TListBox(ListFocused(Form1)).Items[TListBox(ListFocused(Form1)).ItemIndex] := Add;
    end;
  end else begin
    MessageBox(
    Handle, 'Selecione Um Item Para Modificar!', 'Erro', MB_OK
    + MB_DEFBUTTON1 + MB_ICONERROR);
  end;
end;

procedure TForm1.MniRmvStrClick(Sender: TObject);
begin
  if (TListBox(ListFocused(Form1)).ItemIndex <> - 1) Then
  begin
    TListBox(ListFocused(Form1)).DeleteSelected;
    TListBox(ListFocused(Form1)).ItemIndex := TListBox(ListFocused(Form1)).ItemIndex + 1;
  end else
    MessageBox(
    Handle, 'Selecione Uma String Para a Remoção!', 'Aviso', MB_OK
    + MB_DEFBUTTON1 + MB_ICONWARNING);
end;

procedure TForm1.MniClearClick(Sender: TObject);
begin
  if MessageBox(
  Handle, 'Você Perderá Todas as Strings' + #13
  + 'Deseja Realmente Limpar a Lista?', 'Limpar Lista', MB_YESNO +
  MB_DEFBUTTON1 + MB_ICONQUESTION) = IDYES then
  begin
    TListBox(ListFocused(Form1)).Clear;
  end;
end;

procedure TForm1.MniSaveClick(Sender: TObject);
begin
  TListBox(ListFocused(Form1)).Items.SaveToFile(GetCurrentDir + '\'
  + UpperCase(Copy(ListFocused(Form1).Name, 4, Length(ListFocused(Form1).Name))) + '.txt');
  MessageBox(
  Handle, 'Suas Alterações Foram Salvas Com Sucesso!', 'Informação', MB_OK
  + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

procedure TForm1.Rb1Click(Sender: TObject);
begin
  cbbling1.Visible := True;
  cbbling2.Visible := False;
  lblresults.Visible := False;
  cbbresults.Visible := False;
  chklinguagem.Visible := True;
  chkdominio.Visible := True;
  cbbdom1.Visible := True;
end;

procedure TForm1.Rb2Click(Sender: TObject);
begin
  cbbling1.Visible := False;
  cbbling2.Visible := True;
  lblresults.Visible := True;
  cbbresults.Visible := True;
  chklinguagem.Visible := True;
  chkdominio.Visible := True;
  cbbdom1.Visible := True;
end;

procedure TForm1.Rb3Click(Sender: TObject);
begin
  cbbling1.Visible := False;
  cbbling2.Visible := True;
  lblresults.Visible := False;
  cbbresults.Visible := False;
  chklinguagem.Visible := True;
  chkdominio.Visible := True;
  cbbdom1.Visible := True;
end;

procedure TForm1.Rb4Click(Sender: TObject);
begin
  cbbling1.Visible := False;
  cbbling2.Visible := False;
  lblresults.Visible := False;
  cbbresults.Visible := False;
  chklinguagem.Visible := False;
  chkdominio.Visible := False;
  cbbdom1.Visible := False;
end;

procedure TForm1.TmrAtualizaTimer(Sender: TObject);
begin
  case (stat1.Panels[2].Text = 'Pesquisando...') of
    True  : BBtnCancel1.Visible := True;
    False : BBtnCancel1.Visible := False;
  end;

  if (lstencontrados.Items.Count <> 0) then
  begin
    BBtnClear1.Visible := True;
    BBtnSave1.Visible := True;
  end else begin
    BBtnClear1.Visible := False;
    BBtnSave1.Visible := False;
  end;

  if (lvvuls.Items.Count <> 0) then
  begin
    BBtnClear2.Visible := True;
    BBtnSave2.Visible := True;
  end else begin
    BBtnClear2.Visible := False;
    BBtnSave2.Visible := False;
  end;
end;

procedure TForm1.MniAboutClick(Sender: TObject);
begin
  MessageBox(Handle, 'Sherif Search v2.0' + #13 + #13
  + 'Criado Por rios0rios0' + #13 + #13 + 'Contato: rios0rios0@outlook.com',
  'Info (Sobre)', MB_OK + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

procedure TForm1.cbbling2KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    TerminateThread(TSearch, 0);
    tmratualiza.Enabled := False;
    AnimateWindow(Handle, 1000, AW_HIDE + AW_BLEND);
  except
    Exit;
  end;
end;

procedure TForm1.ThreadSearch;
 var
  Pag, X, Y, Op: Integer;
  Aux, S: string;
 label
  Final;
begin
  if (CheckConexao = False) then
  begin
    MessageBox(
    Handle, 'Verifique Sua Conexão Com a Internet!', 'Erro', MB_OK
    + MB_DEFBUTTON1 + MB_ICONERROR);
    Exit;
  end;
  if ((Form1.lststrings.Items.Count - 1) < 0) then
  begin
    MessageBox(Handle, 'Lista de Strings Vazia', 'Erro', MB_OK
    + MB_DEFBUTTON1 + MB_ICONERROR);
    Exit;
  end;

  Form1.lstencontrados.Clear;
  Form1.stat1.Panels[0].Text := 'Encontrados:';
  Form1.stat1.Panels[1].Text := 'Página (s):';

  Op := StrToInt(Copy(CheckRButton(Form1), 3, 1));
  case Op of
    01: // GOOGLE
    begin
      if (Form1.cbbdom1.Text = '') then
      begin
        MessageBox(Handle, 'Insira Um Dominio Para a Busca', 'Aviso', MB_OK
        + MB_DEFBUTTON1 + MB_ICONWARNING);
        Exit;
      end;
      if (Form1.cbbling1.Text = '') then
      begin
        MessageBox(Handle, 'Insira Uma Linguagem Para a Busca', 'Aviso', MB_OK
        + MB_DEFBUTTON1 + MB_ICONWARNING);
        Exit;
      end;

      if ((Form1.chklinguagem.Checked = True) and (Form1.chkdominio.Checked = True)) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://www.google.com.br/search?hl='
            + Form1.cbbling1.Text + '&q=' + Aux + '&as_sitesearch='
            + Form1.cbbdom1.Text + '&num=' + '&start=' + IntToStr(pag) + '0&sa=N', pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if ((Form1.chkdominio.Checked = False) and (Form1.chklinguagem.Checked = False)) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag:=Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://www.google.com.br/search?hl=&q='
            + Aux + '&as_sitesearch=&num=&start='
            + IntToStr(pag) + '0&sa=N', pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if (Form1.chkdominio.Checked = False) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://www.google.com.br/search?hl='
            + Form1.cbbling1.Text + '&q=' + Aux + '&as_sitesearch=&num=&start='
            + IntToStr(pag) + '0&sa=N', pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if (Form1.chklinguagem.Checked = False) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://www.google.com.br/search?hl=&q='
            + Aux + '&as_sitesearch=' + Form1.cbbdom1.Text
            + '&num=&start=' + IntToStr(pag) + '0&sa=N', pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
    end;

    02: // YAHOO
    begin
      if (Form1.cbbdom1.Text = '') then
      begin
        MessageBox(
        Handle, 'Insira Um Dominio Para a Busca', 'Aviso', MB_OK
        + MB_DEFBUTTON1 + MB_ICONWARNING);
        Exit;
      end;
      if (Form1.cbbling2.Text = '') then
      begin
        MessageBox(
        Handle, 'Insira Uma Linguagem Para a Busca', 'Aviso', MB_OK
        + MB_DEFBUTTON1 + MB_ICONWARNING);
        Exit;
      end;

      if ((Form1.chklinguagem.Checked = True) and (Form1.chkdominio.Checked = True)) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://' + Form1.cbbling2.Text
            + '.search.yahoo.com/search;_ylt=A0geu8roY4xOJ1cAWzTz6Qt.?p=' + Aux + '&n='
            + Form1.cbbresults.Text + '&ei=UTF-8&va_vt=any&vo_vt=any&ve_vt=any&vp_vt=any&vd=all&vs='
            + Form1.cbbdom1.Text + '&vf=all&vm=p&fl=2&fr=sfp&xargs=0&pstart=1&b='
            + IntToStr(pag + 20), pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if ((Form1.chkdominio.Checked = False) and (Form1.chklinguagem.Checked = False)) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings(
            'http://search.yahoo.com/search;_ylt=A0geu8roY4xOJ1cAWzTz6Qt.?p='
            + Aux + '&n=' + Form1.cbbresults.Text
            + '&ei=UTF-8&va_vt=any&vo_vt=any&ve_vt=any&vp_vt=any&vd=all&vs=&vf=all&vm=p&fl=2&fr=sfp&xargs=0&pstart=1&b='
            + IntToStr(pag + 20), pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if (Form1.chkdominio.Checked = False) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://' + Form1.cbbling2.Text
            + '.search.yahoo.com/search;_ylt=A0geu8roY4xOJ1cAWzTz6Qt.?p='
            + Aux + '&n=' + Form1.cbbresults.Text
            + '&ei=UTF-8&va_vt=any&vo_vt=any&ve_vt=any&vp_vt=any&vd=all&vs=&vf=all&vm=p&fl=2&fr=sfp&xargs=0&pstart=1&b='
            + IntToStr(pag + 20), pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if (Form1.chklinguagem.Checked = False) then
      begin
        for y := 0 to Form1.lststrings.Items.Count -1 do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings(
            'http://search.yahoo.com/search;_ylt=A0geu8roY4xOJ1cAWzTz6Qt.?p='
            + Aux + '&n=' + Form1.cbbresults.Text + '&ei=UTF-8&va_vt=any&vo_vt=any&ve_vt=any&vp_vt=any&vd=all&vs='
            + Form1.cbbdom1.Text + '&vf=all&vm=p&fl=2&fr=sfp&xargs=0&pstart=1&b='
            + IntToStr(pag + 20), pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
    end;

    03: // BING
    begin
      if (Form1.cbbdom1.Text = '') then
      begin
        MessageBox(
        Handle, 'Insira Um Dominio Para a Busca', 'Aviso', MB_OK
        + MB_DEFBUTTON1 + MB_ICONWARNING);
        Exit;
      end;
      if (Form1.cbbling2.Text = '') then
      begin
        MessageBox(
        Handle, 'Insira Uma Linguagem Para a Busca', 'Aviso', MB_OK
        + MB_DEFBUTTON1 + MB_ICONWARNING);
        Exit;
      end;

      if ((Form1.chklinguagem.Checked = True) and (Form1.chkdominio.Checked = True)) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://' + Form1.cbbling2.Text + '.bing.com/search?q='
            + Aux + '+site%3A' + Form1.cbbdom1.Text + '&form=QBRE&filt=all&qb=' + IntToStr(pag), pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if ((Form1.chkdominio.Checked = False) and (Form1.chklinguagem.Checked = False)) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://bing.com/search?q=' + Aux
            + '+site%3A&form=QBRE&filt=all&qb=' + IntToStr(pag), pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if (Form1.chkdominio.Checked = False) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://' + Form1.cbbling2.Text + '.bing.com/search?q=' + Aux
            + '+site%3A&form=QBRE&filt=all&qb=' + IntToStr(pag), pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if (Form1.chklinguagem.Checked = False) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://bing.com/search?q=' + Aux + '+site%3A'
            + Form1.cbbdom1.Text + '&form=QBRE&filt=all&qb=' + IntToStr(pag), pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
    end;

    04: // BAIDU
    begin
      for y := 0 to (Form1.lststrings.Items.Count - 1) do
      begin
        if (Cancel2 = True) then
          Break;
        Aux := Form1.lststrings.Items[y];
        Form1.lststrings.ItemIndex := y;
        for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
        begin
          DoMyFormThings('http://www.baidu.com/s?wd=' + Aux + '&pn=' + IntToStr(pag) + '&usm=3', pag);
          if (Cancel2 = True) then
            Break;
        end;
      end;
      goto Final;
    end;

    05: // LYCOS 
    begin
      if (Form1.cbbdom1.Text = '') then
      begin
        MessageBox(
        Handle, 'Insira Um Dominio Para a Busca', 'Aviso', MB_OK
        + MB_DEFBUTTON1 + MB_ICONWARNING);
        Exit;
      end;
      if (Form1.cbbling2.Text = '') then
      begin
        MessageBox(
        Handle, 'Insira Uma Linguagem Para a Busca', 'Aviso', MB_OK
        + MB_DEFBUTTON1 + MB_ICONWARNING);
        Exit;
      end;

      if ((Form1.chklinguagem.Checked = True) and (Form1.chkdominio.Checked = True)) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://search.lycos.com/?query='
            + Aux + '&page' + IntToStr(pag) + '=1&tab=web&dfi='
            + Form1.cbbdom1.Text + '&region=' + Form1.cbbling2.Text + '&adf=on', pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if ((Form1.chkdominio.Checked = False) and (Form1.chklinguagem.Checked = False)) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://search.lycos.com/?query='
            + Aux + '&page' + IntToStr(pag) + '=1&tab=web&dfi=&region=&adf=on', pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if (Form1.chkdominio.Checked = False) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://search.lycos.com/?query='
            + Aux + '&page'+IntToStr(pag)
            + '=1&tab=web&dfi=&region=' + Form1.cbbling2.Text + '&adf=on', pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
      if (Form1.chklinguagem.Checked = False) then
      begin
        for y := 0 to (Form1.lststrings.Items.Count - 1) do
        begin
          if (Cancel2 = True) then
            Break;
          Aux := Form1.lststrings.Items[y];
          Form1.lststrings.ItemIndex := y;
          for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
          begin
            DoMyFormThings('http://search.lycos.com/?query='
            + Aux + '&page' + IntToStr(pag) + '=1&tab=web&dfi='
            + Form1.cbbdom1.Text + '&region=&adf=on', pag);
            if (Cancel2 = True) then
              Break;
          end;
        end;
        goto Final;
      end;
    end;

    06: // AMFIBY
    begin
      for y := 0 to (Form1.lststrings.Items.Count - 1) do
      begin
        if (Cancel2 = True) then
          Break;
        Aux := Form1.lststrings.Items[y];
        Form1.lststrings.ItemIndex := y;
        for pag := Form1.sepaginainicial.Value to Form1.sepaginafinal.Value do
        begin
          DoMyFormThings('http://www.amfibi.com/search?query=' + Aux + '&start=' + IntToStr(pag), pag);
          if (Cancel2 = True) then
            Break;
        end;
      end;
      goto Final;
    end;
  end;
  
  Final:
  begin
    Form1.pb1.Position :=0;
    Form1.lststrings.ItemIndex := 0;

    if Form1.chksubpastas.Checked then
    begin
      for X := 0 to (Form1.lstencontrados.Items.Count - 1) do
      begin
        s := Form1.lstencontrados.Items.Names[X];
        if (Pos('https://', s) > 0) then
          Delete(s, 1, 8)
        else
          Delete(s, 1, 7);
        s := Copy(s, 1, Pos('/', s));
        if (Length(s) > 0) then
          Form1.lstencontrados.Items[X] := s;
      end;
    end;
  end;
end;

end.

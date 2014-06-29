unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Zlib,WTExtractorClass, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Menus;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    StatusBar1: TStatusBar;
    FileDlg: TOpenDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    ExtractMenu: TPopupMenu;
    Extract1: TMenuItem;
    Extractall1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Extract1Click(Sender: TObject);
    procedure Extractall1Click(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure UpdateStatusBar(ArchName: string;FilesCount: integer;Compression: boolean);
    Procedure ProcessedFiles(Processed,Total: integer);
    Procedure AddToListView(Filename: string;Offset,Size: integer);
    { Public declarations }
  end;






var
  Form1: TForm1;
  Extractor: TWTExtractor;
  CurrIndex: integer;
implementation
 uses
  VromFSClasses,DXPClasses;

{$R *.dfm}


procedure TForm1.AddToListView(Filename: string; Offset, Size: integer);

function FormatByteSize(const bytes: Longint): string;
 const
   B = 1; //byte
   KB = 1024 * B; //kilobyte
   MB = 1024 * KB; //megabyte
   GB = 1024 * MB; //gigabyte
 begin
   if bytes > GB then
     result := FormatFloat('#.## GB', bytes / GB)
   else
     if bytes > MB then
       result := FormatFloat('#.## MB', bytes / MB)
     else
       if bytes > KB then
         result := FormatFloat('#.## KB', bytes / KB)
       else
         result := FormatFloat('#.## bytes', bytes) ;
 end;

var
 ListItem: TListItem;
begin
 ListItem:=ListView1.Items.Add;

 With ListItem do
  begin
    Caption:=Filename;
    Subitems.Add(FormatByteSize(Size));
    Subitems.Add(IntToHex(Offset,8));
  end;

end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
 Application.Destroy;
end;

procedure TForm1.Extract1Click(Sender: TObject);
begin
 if (ListView1.ItemIndex < 0) then
  raise Exception.Create('We dont have the selected file!');

  Extractor.ExtractFile(ListView1.ItemIndex);
end;

procedure TForm1.Extractall1Click(Sender: TObject);
begin
  Extractor.ExtractAllFiles;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 CurrIndex:=-1;
end;




procedure TForm1.N2Click(Sender: TObject);
begin
 CurrIndex:=-1;
 ListView1.Items.Clear;
 if (Extractor <> nil) then
  Extractor.Free;
 if FileDlg.Execute then
 begin
  case FileDlg.FilterIndex of
    1:Extractor:=TVromFSExtractor.Create;
    2:Extractor:=TDXPExtractor.Create;
  end;

   Extractor.UpdateFunction:=UpdateStatusBar;
   Extractor.ProcessFileFunction:=ProcessedFiles;
   Extractor.UpdateListFunction:=AddToListView;
  Extractor.OpenArchive(FileDlg.Filename)
  end else exit;
end;

procedure TForm1.ProcessedFiles(Processed, Total: integer);
begin
 with StatusBar1.Panels do
  begin
    Items[4].Text:=IntToStr(Processed)+'/'+IntToStr(Total);
  end;
end;

procedure TForm1.UpdateStatusBar(ArchName: string; FilesCount: integer;
  Compression: boolean);
begin
 with StatusBar1.Panels do
  begin
    Items[0].Text:=ExtractFileName(ArchName);
    Items[1].Text:=IntToStr(FilesCount);
    if Compression then
      Items[2].Text:= 'Compressed'
      else
      Items[2].Text:= 'Not Compressed';
  end;

end;

end.

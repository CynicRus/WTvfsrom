unit WTExtractorClass;

interface
  uses
    System.Classes,System.SysUtils;

  type
   TUpdateFunction = procedure (ArchName: string;FilesCount: integer;Compression: boolean) of object;
   TProcessFileFunction = procedure (Processed,Total: integer) of object;
   TUpdateListFunction = procedure (Filename: string;Offset,Size: integer) of object;
   TFileHeader = array [0..0]of byte;

   TAbstractFile = class
   private
      FName: string;
      FSize: integer;
      FOffset: Integer;

    public
      Constructor Create;
      procedure Reset;virtual;abstract;
      property Name: string read Fname write FName;
      property Size: Integer read FSize write FSize;
      property Offset: integer read FOffset write FOffset;
  end;

  TAbstractFileList = class
  private
    FAbstractFiles: TList;
    function GetCount: Integer;
    function GetAbstractFile(Index: Integer): TAbstractFile;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Src: TAbstractFileList);
    procedure Add(aAbstractFile: TAbstractFile); overload;
    procedure Add(aAbstractFiles: TAbstractFileList); overload;
    procedure Delete(Index: Integer); overload;
    procedure Delete(aAbstractFile: TAbstractFile); overload;
    function IndexOf(aAbstractFile: TAbstractFile): Integer;

    property Count: Integer read GetCount;
    property AbstractFile[Index: Integer]: TAbstractFile read GetAbstractFile; default;
  end;

   TWTExtractor = class
     private
      FUpdateFunction: TUpdateFunction;
      FProcessFileFunction: TProcessFileFunction;
      FUpdateListFunction: TUpdateListFunction;
     public
      Constructor Create;
      Destructor Destroy;override;
      procedure OpenArchive(ArchiveName: string);virtual;abstract;
      procedure ExtractFile(Idx: integer);virtual;abstract;
      procedure ExtractAllFiles;virtual;abstract;
      property UpdateFunction: TUpdateFunction read FUpdateFunction write FUpdateFunction;
      property ProcessFileFunction: TProcessFileFunction read FprocessFileFunction write FProcessFileFunction;
      property UpdateListFunction: TUpdateListFunction read FUpdateListFunction write FUpdateListFunction;
   end;
implementation
 const
   ErrItemNotFound = 'Item not found!';

{ TWTExtractor }

constructor TWTExtractor.Create;
begin

end;

destructor TWTExtractor.Destroy;
begin

  inherited;
end;

{ TAbstractFile }

constructor TAbstractFile.Create;
begin

end;

constructor TAbstractFileList.Create;
begin
  FAbstractFiles := TList.Create;
end;

destructor TAbstractFileList.Destroy;
begin
  Clear;
  FAbstractFiles.Free;
  inherited;
end;

procedure TAbstractFileList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= Count) then
    raise Exception.Create(ErrItemNotFound);

  AbstractFile[Index].Free;
  FAbstractFiles.Delete(Index);
end;

procedure TAbstractFileList.Delete(aAbstractFile: TAbstractFile);
begin
  Delete(IndexOf(aAbstractFile));
end;

procedure TAbstractFileList.Add(aAbstractFiles: TAbstractFileList);
var
  I: Integer;
begin
  for I := 0 to aAbstractFiles.Count - 1 do
    Add(aAbstractFiles[I]);
end;

procedure TAbstractFileList.Add(aAbstractFile: TAbstractFile);
begin
  FAbstractFiles.Add(aAbstractFile);
end;

procedure TAbstractFileList.Assign(Src: TAbstractFileList);
begin
  Clear;
  Add(Src);
end;

procedure TAbstractFileList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    AbstractFile[I].Free;
  FAbstractFiles.Clear;
end;


function TAbstractFileList.GetCount: Integer;
begin
  Result := FAbstractFiles.Count;
end;

function TAbstractFileList.GetAbstractFile(Index: Integer): TAbstractFile;
begin
  if (Index >= 0) and (Index < Count) then
    Result := TAbstractFile(FAbstractFiles[Index])
  else
    Result := nil;
end;

function TAbstractFileList.IndexOf(aAbstractFile: TAbstractFile): Integer;
begin
  Result := FAbstractFiles.IndexOf(aAbstractFile);
end;

end.

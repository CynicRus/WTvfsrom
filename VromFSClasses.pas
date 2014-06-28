unit VromFSClasses;

interface
  uses
    System.Classes,System.SysUtils,FileCtrl,Dialogs,Windows,Zlib;
  type
   TUpdateFunction = procedure (ArchName: string;FilesCount: integer;Compression: boolean) of object;
   TProcessFileFunction = procedure (Processed,Total: integer) of object;
   TUpdateListFunction = procedure (Filename: string;Offset,Size: integer) of object;
   TVromFSFileStruct = class
    private
      FName: string;
      FSize: integer;
      FOffset: Integer;
    public
      Constructor Create;
      procedure Reset;
      property Name: string read Fname write FName;
      property Size: Integer read FSize write FSize;
      property Offset: integer read FOffset write FOffset;
  end;

  TVromFSFileList = class
  private
    FVromFSFileStructs: TList;
    function GetCount: Integer;
    function GetVromFSFileStruct(Index: Integer): TVromFSFileStruct;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Src: TVromFSFileList);
    procedure Add(aVromFSFileStruct: TVromFSFileStruct); overload;
    procedure Add(aVromFSFileStructs: TVromFSFileList); overload;
    procedure Delete(Index: Integer); overload;
    procedure Delete(aVromFSFileStruct: TVromFSFileStruct); overload;
    function IndexOf(aVromFSFileStruct: TVromFSFileStruct): Integer;

    property Count: Integer read GetCount;
    property VromFSFileStruct[Index: Integer]: TVromFSFileStruct read GetVromFSFileStruct; default;
  end;

  TVromFSExtractor = class
    private
      FOpenFile: TFileStream;
      FOutputFile: TFileStream;
      FFileList: TVromFSFileList;
      FZip: TZDecompressionStream;
      FCompressFlag: boolean;
      FTotalFiles: integer;
      FArchName: string;
      FExtractionPath: string;
      FWorker: TMemoryStream;
      FUpdateFunction: TUpdateFunction;
      FProcessFileFunction: TProcessFileFunction;
      FUpdateListFunction: TUpdateListFunction;
      Procedure Reset;
    public
      Constructor Create;
      Destructor Destroy;override;
      procedure OpenArchive(ArchiveName: string);
      procedure ExtractFile(Idx: integer);
      procedure ExtractAllFiles;
    //  procedure
      property UpdateFunction: TUpdateFunction read FUpdateFunction write FUpdateFunction;
      property ProcessFileFunction: TProcessFileFunction read FprocessFileFunction write FProcessFileFunction;
      property UpdateListFunction: TUpdateListFunction read FUpdateListFunction write FUpdateListFunction;
  end;

implementation
  const
   ErrItemNotFound = 'Item not found!';
constructor TVromFSFileStruct.Create;
begin
 Reset;
end;

procedure TVromFSFileStruct.Reset;
begin
 Name:='';
 Size:=-1;
 Offset:=-1;
end;

constructor TVromFSFileList.Create;
begin
  FVromFSFileStructs := TList.Create;
end;

destructor TVromFSFileList.Destroy;
begin
  Clear;
  FVromFSFileStructs.Free;
  inherited;
end;

procedure TVromFSFileList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= Count) then
    raise Exception.Create(ErrItemNotFound);

  VromFSFileStruct[Index].Free;
  FVromFSFileStructs.Delete(Index);
end;

procedure TVromFSFileList.Delete(aVromFSFileStruct: TVromFSFileStruct);
begin
  Delete(IndexOf(aVromFSFileStruct));
end;

procedure TVromFSFileList.Add(aVromFSFileStructs: TVromFSFileList);
var
  I: Integer;
begin
  for I := 0 to aVromFSFileStructs.Count - 1 do
    Add(aVromFSFileStructs[I]);
end;

procedure TVromFSFileList.Add(aVromFSFileStruct: TVromFSFileStruct);
begin
  FVromFSFileStructs.Add(aVromFSFileStruct);
end;

procedure TVromFSFileList.Assign(Src: TVromFSFileList);
begin
  Clear;
  Add(Src);
end;

procedure TVromFSFileList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    VromFSFileStruct[I].Free;
  FVromFSFileStructs.Clear;
end;


function TVromFSFileList.GetCount: Integer;
begin
  Result := FVromFSFileStructs.Count;
end;

function TVromFSFileList.GetVromFSFileStruct(Index: Integer): TVromFSFileStruct;
begin
  if (Index >= 0) and (Index < Count) then
    Result := TVromFSFileStruct(FVromFSFileStructs[Index])
  else
    Result := nil;
end;

function TVromFSFileList.IndexOf(aVromFSFileStruct: TVromFSFileStruct): Integer;
begin
  Result := FVromFSFileStructs.IndexOf(aVromFSFileStruct);
end;
{ TVromFSExtractor }

constructor TVromFSExtractor.Create;
begin
  FFileList:= TVromFSFileList.Create;
  FWorker:= TMemoryStream.Create;
  FExtractionPath:='';
end;

destructor TVromFSExtractor.Destroy;
begin
  FFileList.Free;
  FWorker.Free;
  inherited;
end;

procedure TVromFSExtractor.ExtractAllFiles;
var
 i: integer;
 VFSFile: TVromFSFileStruct;
 Dir: string;
 FileData: TArray<Byte>;
begin
 if SelectDirectory('Select Directory' ,ExtractFileDrive(Dir), Dir,
             [sdNewUI, sdNewFolder] )then
      FExtractionPath:=dir else
      raise Exception.Create('Path not selected!');
 for i:=0  to FFileList.Count - 1 do
   begin
     VFSFile:=FFileList[i];
     FOutputFile:=TfileStream.Create(FExtractionPath+'\'+VFSFile.Name,fmCreate);
     try
       SetLength(FileData,VFSFile.Size);
       FWorker.Seek(VFSFile.Offset,SoFromBeginning);
       FWorker.Read(FileData,VFSFile.Size);
       FOutputFile.Write(FileData,VFSFile.Size);
      finally
       FOutputfile.Free;
       Setlength(Filedata,0);
      end;
  end;
  ShowMessage('Exctraction succesful completed!');


end;

procedure TVromFSExtractor.ExtractFile(Idx: integer);
var
 Dir: string;
 VFSFile: TVromFSFileStruct;
 FileData: TArray<Byte>;
begin
 if SelectDirectory('Select Directory' ,ExtractFileDrive(Dir), Dir,
             [sdNewUI, sdNewFolder] )then
      FExtractionPath:=dir else
      raise Exception.Create('Path not selected!');
  VFSFile:=FFileList[idx];
  FOutputFile:=TfileStream.Create(FExtractionPath+'\'+VFSFile.Name,fmCreate);
  try
    SetLength(FileData,VFSFile.Size);
    FWorker.Seek(VFSFile.Offset,SoFromBeginning);
    FWorker.Read(FileData,VFSFile.Size);
    FOutputFile.Write(FileData,VFSFile.Size);
    ShowMessage('Exctraction '+VFSFile.Name+'successful completed!');
  finally
    FOutputfile.Free;
    Setlength(Filedata,0);
  end;

end;

procedure TVromFSExtractor.OpenArchive(ArchiveName: string);
var
 VFSFile: TVromFSFileStruct;
 Signature: word;
 BufferSize,NameSectionEnd,BaseOffset,NameOffset,FileOffset,FileSize: integer;
 I: integer;
 Name: AnsiString;
 C: AnsiChar;
 Off: integer;
 Buff: TmemoryStream;
begin
 Reset;
 FArchName:=ArchiveName;
 FOpenFile:=TFileStream.Create(FArchName,fmShareDenyRead);
 try
  FWorker.Clear;
  FOpenFile.Seek($10,soFromBeginning);
  FOpenFile.Read(Signature,2);
  FOpenFile.Seek($10,soFromBeginning);
  if (Signature = 40056) then
   FCompressFlag:= true;
  BufferSize:=FOpenFile.Size - FOpenFile.Position;
  FWorker.CopyFrom(FOpenFile,BufferSize);
  FWorker.Seek(0,soFromBeginning);
  if FCompressFlag then
  begin
       Buff:=TMemoryStream.Create;
       try
       Buff.CopyFrom(FWorker,0);
       Buff.Seek(0,soFromBeginning);
       FZip:=TZDecompressionStream.Create(Buff);
       FWorker.Clear;
       FWorker.CopyFrom(FZip,0);
       finally
         Buff.Free;
       end;
  end;
  FWorker.Seek(0,soFromBeginning);
  FWorker.Read(BaseOffset,4);
  FWorker.Read(FTotalFiles,4);
  FWorker.Seek(8,soFromCurrent);
  FWorker.Read(NameSectionEnd,4);
  FWorker.Seek(BaseOffset,soFromBeginning);
  UpdateFunction(ArchiveName,FTotalFiles,FCompressFlag);
  for i := 0 to (FTotalFiles - 1) do
    begin
      VFSFile:=TVromFSFileStruct.Create;

      NameOffset:=0;
      Name:='';
      FWorker.Read(NameOffset,8);
      Off:=FWorker.Position;
      FWorker.Seek(NameOffset,soFromBeginning);
      repeat
        FWorker.Read(C,1);
        Name:=Name+C;
      until (Byte(C) = $00);
      Name:=stringreplace(Name,'/','\', [rfReplaceAll]);
      VFSFile.Name:=ExtractFileName(name);
      FWorker.seek(NameSectionEnd,soFromBeginning);
      FWorker.Read(FileOffset,4);
      VFSFile.Offset:=FileOffset;
      FWorker.Read(FileSize,4);
      VFSFile.Size:=FileSize;
      FProcessFileFunction(i,FTotalFiles);
      FWorker.Seek(8,soFromCurrent);
      NameSectionEnd:=FWorker.Position;
      FFileList.Add(VFSFile);
      UpdateListFunction(VFSFile.Name,VFSFile.Offset,VFSFile.Size);
      FWorker.Seek(Off,soFromBeginning);
      end;
 finally
   FOpenFile.Free;
 end;

end;

procedure TVromFSExtractor.Reset;
begin
  FCompressFlag:=false;
  FTotalFiles:=-1;
  FArchName:='';
  //FExtractionPath:='';
  FWorker.Clear;
end;

end.

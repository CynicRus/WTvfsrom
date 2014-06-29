unit DXPClasses;

interface
  uses
    System.Classes,System.SysUtils,Dialogs,FileCtrl,WTExtractorClass;

  type
   TDXPFileStruct = class(TAbstractFile)
     private
       FFileHeader: TArray<Byte>;
     public
      Constructor Create;
      Procedure Reset;
      property Name;
      property Size;
      property Offset;
      property FileHeader: TArray<Byte> read FFileHeader write FFileHeader;
   end;

   TDXPExtractor = class(TWTExtractor)
    private
      FOpenFile: TFileStream;
      FOutputFile: TFileStream;
      FFileList: TAbstractFileList;
      FTotalFiles: integer;
      FArchName: string;
      FExtractionPath: string;
      FWorker: TMemoryStream;
      Procedure Reset;
    public
      Constructor Create;
      Destructor Destroy;override;
      procedure OpenArchive(ArchiveName: string);override;
      procedure ExtractFile(Idx: integer);override;
      procedure ExtractAllFiles;override;
    //  procedure
      property UpdateFunction;
      property ProcessFileFunction;
      property UpdateListFunction;
  end;

implementation
 const
    ErrIncorrectDXPFile = 'Incorrect dxp file!';
{ TDXPFileStruct }

constructor TDXPFileStruct.Create;
begin
 Reset;
end;

procedure TDXPFileStruct.Reset;
begin
 Name:='';
 Size:=-1;
 Offset:=-1;
 SetLength(FFileHeader,32);
end;

{ TDXPExtractor }

constructor TDXPExtractor.Create;
begin
  FFileList:= TAbstractFileList.Create;
  FWorker:= TMemoryStream.Create;
  FExtractionPath:='';
end;

destructor TDXPExtractor.Destroy;
begin
  FFileList.Free;
  FWorker.Free;
  inherited;
end;

procedure TDXPExtractor.ExtractAllFiles;
var
 i: integer;
 DXPFile: TDXPFileStruct;
 Dir: string;
 FileData: TArray<Byte>;
begin
 if SelectDirectory('Select Directory' ,ExtractFileDrive(Dir), Dir,
             [sdNewUI, sdNewFolder] )then
      FExtractionPath:=dir else
      raise Exception.Create('Path not selected!');
 for i:=0  to FFileList.Count - 1 do
   begin
     DXPFile:=TDXPFileStruct(FFileList[i]);
     FOutputFile:=TfileStream.Create(FExtractionPath+'\'+DXPFile.Name,fmCreate);
     try
       SetLength(FileData,DXPFile.Size+Length(DXPFile.FileHeader));
       Move(DXPFile.FileHeader[0],FileData[0],Length(DXPFile.FileHeader));
       FWorker.Seek(DXPFile.Offset-8,SoFromBeginning);
       FWorker.Read(FileData[Length(DXPFile.FileHeader)],DXPFile.Size);
       FOutputFile.Write(FileData,DXPFile.Size);
       ProcessFileFunction(I,FTotalFiles);
      finally
       FOutputfile.Free;
       Setlength(Filedata,0);
      end;
  end;
  ShowMessage('Exctraction succesful completed!');


end;

procedure TDXPExtractor.ExtractFile(Idx: integer);
var
 Dir: string;
 DXPFile: TDXPFileStruct;
 FileData: TArray<Byte>;
begin
 if SelectDirectory('Select Directory' ,ExtractFileDrive(Dir), Dir,
             [sdNewUI, sdNewFolder] )then
      FExtractionPath:=dir else
      raise Exception.Create('Path not selected!');
  DXPFile:=TDXPFileStruct(FFileList[idx]);
  FOutputFile:=TfileStream.Create(FExtractionPath+'\'+DXPFile.Name,fmCreate);
  try
    SetLength(FileData,DXPFile.Size+Length(DXPFile.FileHeader));
    Move(DXPFile.FileHeader[0],FileData[0],Length(DXPFile.FileHeader));
    FWorker.Seek(DXPFile.Offset-8,SoFromBeginning);
    FWorker.Read(FileData[Length(DXPFile.FileHeader)],DXPFile.Size);
    FOutputFile.Write(FileData,DXPFile.Size);
    ShowMessage('Exctracted: '+DXPFile.Name+'!');
  finally
    FOutputfile.Free;
    Setlength(Filedata,0);
  end;
end;

procedure TDXPExtractor.OpenArchive(ArchiveName: string);

procedure DeleteStopSymbols(var AText: String);
const
 cntStopSym = ['>','<','|','?','*','/','\',':','"'];
var
  i : Integer;
begin
  for i:=Length(AText) downto 1 do
    if AText[i] in  cntStopSym then Delete(AText, i , 1);
end;

var
 DXPFile: TDXPFileStruct;
 BufferSize,NameOffset,FileOffset,FileSize,HeadersOffset,EndSectionNames,FileInfoOffset,EndHeadersSection: integer;
 I: integer;
 Name: String;
 C: AnsiChar;
 CurrNameOff,CurrHeaderOff,CurrFileInfoOff: integer;
 Buff: TmemoryStream;
 FileSign: int64;
 HeaderBuff: TArray<byte>;
begin
 Reset;
 FArchName:=ArchiveName;
 FOpenFile:=TFileStream.Create(FArchName,fmShareDenyRead);
 try
  FOpenFile.Read(FileSign,8);
  if AnsiCompareText(inttohex(FileSign,8),'232507844') > 0 then
    raise Exception.Create(ErrIncorrectDXPFile);
  BufferSize:=FOpenFile.Size - FOpenFile.Position;
  FWorker.CopyFrom(FOpenFile,BufferSize);
  FWorker.Seek(0,soFromBeginning);
  Fworker.Read(FTotalFiles,4);
  FWorker.Read(EndHeadersSection,4);
  FWorker.Read(EndSectionNames,4);
  FWorker.Seek(12,soFromCurrent);
  FWorker.Read(HeadersOffset,4);
  FWorker.Seek(12,soFromCurrent);
  FWorker.Read(FileInfoOffset,4);
  FWorker.Seek(20,soFromCurrent);
  CurrNameOff:=FWorker.Position;
  FWorker.Seek((HeadersOffset+16) - 8,soFromBeginning);
  CurrHeaderOff:=FWorker.Position;
  FWorker.Seek(FileInfoOffset+24,soFromBeginning);
  CurrFileInfoOff:=(FWorker.Position+4)-8;
  UpdateFunction(ArchiveName,FTotalFiles,false);
  for I := 0 to FTotalFiles - 1 do
    begin
      DXPFile:=TDXPFileStruct.Create;
      FWorker.Seek(CurrNameOff,soFromBeginning);
      Name:='';
      repeat
        FWorker.Read(C,1);
        Name:=Name+C;
      until (Byte(C) = $00);
      Name.Insert(Name.Length-1,'.ddsx');
      DeleteStopSymbols(Name);
      DXPFile.Name:=Name;
      CurrNameOff:=FWorker.Position;
      SetLength(HeaderBuff,32);
      FWorker.Seek(CurrHeaderOff,soFromBeginning);
      FWorker.Read(HeaderBuff,32);
      Move(HeaderBuff[0],DXPFile.FileHeader[0],32);
      SetLength(HeaderBuff,0);
      CurrHeaderOff:=FWorker.Position;
      FWorker.Seek(CurrFileInfoOff,SoFromBeginning);
      FWorker.Read(FileOffset,4);
      FWorker.Read(FileSize,4);
      DXPFile.Offset:=FileOffset;
      DXPFile.Size:=FileSize;
      FWorker.Seek(16,soFromCurrent);
      CurrFileInfoOff:=FWorker.Position;
      FFileList.Add(DXPFile);
      UpdateListFunction(DXPFile.Name,DXPFile.Offset,DXPFile.Size);
    end;
 finally
   FOpenFile.Free;
 end;

end;

procedure TDXPExtractor.Reset;
begin
  FTotalFiles:=-1;
  FArchName:='';
  FFileList.Clear;
  FWorker.Clear;
end;

end.

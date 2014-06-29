unit VromFSClasses;

interface
  uses
    System.Classes,System.SysUtils,FileCtrl,Dialogs,Windows,Zlib,WTExtractorClass;
  type

   TVromFSFileStruct = class(TAbstractFile)
    private
      FName: string;
      FSize: integer;
      FOffset: Integer;
    public
      Constructor Create;
      procedure Reset;overload;
      property Name;
      property Size;
      property Offset;
  end;

  TVromFSExtractor = class(TWTExtractor)
    private
      FOpenFile: TFileStream;
      FOutputFile: TFileStream;
      FFileList: TAbstractFileList;
      FZip: TZDecompressionStream;
      FCompressFlag: boolean;
      FTotalFiles: integer;
      FArchName: string;
      FExtractionPath: string;
      FWorker: TMemoryStream;
      //FUpdateFunction: TUpdateFunction;
     // FProcessFileFunction: TProcessFileFunction;
     // FUpdateListFunction: TUpdateListFunction;
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


{ TVromFSExtractor }

constructor TVromFSExtractor.Create;
begin
  FFileList:= TAbstractFileList.Create;
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
     ProcessFileFunction(I,FTotalFiles);
     VFSFile:=TVromFSFileStruct(FFileList[i]);
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
  VFSFile:=TVromFSFileStruct(FFileList[idx]);
  FOutputFile:=TfileStream.Create(FExtractionPath+'\'+VFSFile.Name,fmCreate);
  try
    SetLength(FileData,VFSFile.Size);
    FWorker.Seek(VFSFile.Offset,SoFromBeginning);
    FWorker.Read(FileData,VFSFile.Size);
    FOutputFile.Write(FileData,VFSFile.Size);
    ShowMessage('Exctracted: '+VFSFile.Name+'!');
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
      ProcessFileFunction(i,FTotalFiles);
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
  FFileList.Clear;
  //FExtractionPath:='';
  FWorker.Clear;
end;

end.

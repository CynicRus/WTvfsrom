unit WTExtractor;

interface
  uses
    System.Classes,System.SysUtils;

  type
   TUpdateFunction = procedure (ArchName: string;FilesCount: integer;Compression: boolean) of object;
   TProcessFileFunction = procedure (Processed,Total: integer) of object;
   TUpdateListFunction = procedure (Filename: string;Offset,Size: integer) of object;

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

{ TWTExtractor }

constructor TWTExtractor.Create;
begin

end;

destructor TWTExtractor.Destroy;
begin

  inherited;
end;

end.

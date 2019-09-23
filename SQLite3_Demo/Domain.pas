unit Domain;

interface

uses disqlite3_encryption_db,  RTTI,
  Generics.Collections;

type
  UserInBox = class(TMailBoxConfigDatabase)
     function Add: Int64; overload;
  end;

implementation

{ UserInBox }

function UserInBox.Add: Int64;
begin
   inherited Add(
end;

end.

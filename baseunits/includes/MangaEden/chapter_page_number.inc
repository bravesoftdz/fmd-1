  function GetMangaEdenPageNumber: Boolean;
  var
    s   : String;
    i, j: Cardinal;
    l   : TStringList;
  begin
    l:= TStringList.Create;
    parse:= TStringList.Create;
    if manager.container.mangaSiteID = MANGAEDEN_ID then
      s:= DecodeUrl(WebsiteRoots[MANGAEDEN_ID,1] + URL + '1/')
    else
      s:= DecodeUrl(WebsiteRoots[PERVEDEN_ID,1] + URL + '1/');
    Result:= GetPage(TObject(l),
                     s,
                     manager.container.manager.retryConnect);
    Parser:= TjsFastHTMLParser.Create(PChar(l.Text));
    Parser.OnFoundTag := OnTag;
    Parser.OnFoundText:= OnText;
    Parser.Exec;
    Parser.Free;
    if parse.Count>0 then
    begin
      manager.container.pageNumber:= 0;
      for i:= 0 to parse.Count-1 do
      begin
        if (Pos('span class="next"', parse.Strings[i])>0) then
        begin
          s:= parse.Strings[i-3];
          manager.container.pageNumber:= StrToInt(TrimLeft(TrimRight(s)));
          break;
        end;
      end;
    end;
    parse.Free;
    l.Free;
  end;

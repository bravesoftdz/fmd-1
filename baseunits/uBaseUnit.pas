{
        File: uBaseUnit.pas
        License: GPLv2
        This unit is a part of Free Manga Downloader
}

unit uBaseUnit;

{$MODE DELPHI}
{$MACRO ON}
{$DEFINE DOWNLOADER}

interface

uses
  SysUtils, Classes, graphics, IniFiles, strutils,
  zstream, fgl,
  HTTPSend, ssl_openssl, Synacode, Synautil;

const
  MUTEX              = '_FMD_MUTEX_';
  FMD_REVISION       = '$WCREV$';

  JPG_HEADER: array[0..2] of Byte = ($FF, $D8, $FF);
  GIF_HEADER: array[0..2] of Byte = ($47, $49, $46);
  PNG_HEADER: array[0..2] of Byte = ($89, $50, $4E);
  CS_DIRECTORY_COUNT = 0;
  CS_DIRECTORY_PAGE  = 1;
  CS_INFO            = 2;
  CS_GETPAGENUMBER   = 3;
  CS_GETPAGELINK     = 4;
  CS_DOWNLOAD        = 5;

  DATA_PARAM_NAME       = 0;
  DATA_PARAM_LINK       = 1;
  DATA_PARAM_AUTHORS    = 2;
  DATA_PARAM_ARTISTS    = 3;
  DATA_PARAM_GENRES     = 4;
  DATA_PARAM_STATUS     = 5;
  DATA_PARAM_SUMMARY    = 6;
  DATA_PARAM_NUMCHAPTER = 7;
  DATA_PARAM_JDN        = 8;
  DATA_PARAM_READ       = 9;

  FILTER_HIDE           = 0;
  FILTER_SHOW           = 1;

  defaultGenres: array [0..37] of String =
    ('Action'       , 'Adult'        , 'Adventure'    , 'Comedy',
     'Doujinshi'    , 'Drama'        , 'Ecchi'        , 'Fantasy',
     'Gender Bender', 'Harem'        , 'Hentai'       , 'Historical',
     'Horror'       , 'Josei'        , 'Lolicon'      , 'Martial Arts',
     'Mature'       , 'Mecha'        , 'Musical'      , 'Mystery',
     'Psychological', 'Romance'      , 'School Life'  , 'Sci-fi',
     'Seinen'       , 'Shotacon'     , 'Shoujo'       , 'Shoujo Ai',
     'Shounen'      , 'Shounen Ai'   , 'Slice of Life', 'Smut',
     'Sports'       , 'Supernatural' , 'Tragedy'       , 'Yaoi',
     'Yuri'         , 'Webtoons');

  Symbols: array [0..8] of Char =
    ('\', '/', ':', '*', '?', '"', '<', '>', '|');

  {$IFDEF WINDOWS}
  DEFAULT_PATH  = 'c:/downloads';
  {$ELSE}
  DEFAULT_PATH  = '/downloads';
  {$ENDIF}

  README_FILE       = 'readme.rtf';

  WORK_FOLDER       = 'works/';
  WORK_FILE         = 'works.ini';
  DOWNLOADEDCHAPTERS_FILE = 'downloadedchapters.ini';

  FAVORITES_FILE    = 'favorites.ini';
  IMAGE_FOLDER      = 'images/';
  DATA_FOLDER       = 'data/';
  DATA_EXT          = '.dat';
  CONFIG_FOLDER     = 'config/';
  CONFIG_FILE       = 'config.ini';
  REVISION_FILE     = 'revision.ini';
  UPDATE_FILE       = 'updates.ini';
  MANGALIST_FILE    = 'mangalist.ini';
  LANGUAGE_FILE     = 'languages.ini';
  LOG_FILE          = 'changelog.txt';

  OPTION_MANGALIST = 0;
  OPTION_RECONNECT = 1;

  STATUS_STOP      = 0;
  STATUS_WAIT      = 1;
  STATUS_PREPARE   = 2;
  STATUS_DOWNLOAD  = 3;
  STATUS_FINISH    = 4;

  DO_EXIT_FMD      = 1;
  DO_TURNOFF       = 2;
  DO_HIBERNATE     = 3;

  NO_ERROR              = 0;
  NET_PROBLEM           = 1;
  INFORMATION_NOT_FOUND = 2;

  ANIMEA_ID      = 0;
  MANGAHERE_ID   = 1;
  MANGAINN_ID    = 2;
  OURMANGA_ID    = 3;
  KISSMANGA_ID   = 4;
  BATOTO_ID      = 5;
  MANGA24H_ID    = 6;
  VNSHARING_ID   = 7;
  HENTAI2READ_ID = 8;
  FAKKU_ID       = 9;
  TRUYEN18_ID    = 10;
  MANGAREADER_ID = 11;
  MANGAPARK_ID   = 12;
 // GEHENTAI_ID    = 13;
  MANGAFOX_ID    = 14;
  MANGATRADERS_ID= 15;
  MANGASTREAM_ID = 16;
  MANGAEDEN_ID   = 17;
  PERVEDEN_ID    = 18;
  TRUYENTRANHTUAN_ID = 19;
  TURKCRAFT_ID   = 20;
  MANGAVADISI_ID = 21;
  MANGAFRAME_ID  = 22;
  EATMANGA_ID    = 23;
  STARKANA_ID    = 24;
  MANGAPANDA_ID  = 25;
  REDHAWKSCANS_ID= 26;
  BLOGTRUYEN_ID  = 27;
  KOMIKID_ID     = 28;
  SUBMANGA_ID    = 29;
  ESMANGAHERE_ID = 30;
  ANIMEEXTREMIST_ID = 31;
  PECINTAKOMIK_ID= 32;
  HUGEMANGA_ID   = 33;
  S2SCAN_ID      = 34;
  SENMANGA_ID    = 35;
  IMANHUA_ID     = 36;
  MABUNS_ID      = 37;
  MANGAESTA_ID   = 38;
  CENTRALDEMANGAS_ID = 39;
  EGSCANS_ID     = 40;
  MANGAAR_ID     = 41;
  MANGAAE_ID     = 42;
  ANIMESTORY_ID  = 43;
  LEE_ID         = 44;
  SCANMANGA_ID   = 45;
  MANGAGO_ID     = 46;
  DM5_ID         = 47;
  Pururin_ID     = 48;
  MANGACOW_ID    = 49;
  KIVMANGA_ID    = 50;
  MANGACAN_ID    = 51;
  MEINMANGA_ID   = 52;
  MANGASPROJECT_ID   = 53;
  MANGAREADER_POR_ID = 54;
  MANGA2U_ID     = 55;

  DEFAULT_LIST = 'AnimeA!%~MangaFox!%~MangaHere!%~MangaInn!%~MangaReader!%~';
  DEFAULT_CUSTOM_RENAME = '%NUMBERING% - %CHAPTER%';

  FMDFormatSettings : TFormatSettings = (
    CurrencyFormat: 1;
    NegCurrFormat: 5;
    ThousandSeparator: ',';
    DecimalSeparator: '.';
    CurrencyDecimals: 2;
    DateSeparator: '/';
    TimeSeparator: ':';
    ListSeparator: ',';
    CurrencyString: '$';
    ShortDateFormat: 'm/d/y';
    LongDateFormat: 'dd" "mmmm" "yyyy';
    TimeAMString: 'AM';
    TimePMString: 'PM';
    ShortTimeFormat: 'hh:nn';
    LongTimeFormat: 'hh:nn:ss';
    ShortMonthNames: ('Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec');
    LongMonthNames: ('January','February','March','April','May','June',
                     'July','August','September','October','November','December');
    ShortDayNames: ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
    LongDayNames:  ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
    TwoDigitYearCenturyWindow: 50;
  );

var
  Genre: array [0..37] of String;

  // cbOptionLetFMDDoItemIndex
  cbOptionLetFMDDoItemIndex: Cardinal = 0;

  Revision         : Cardinal;
  currentJDN       : Cardinal;
  isChangeDirectory: Boolean = FALSE;

  currentWebsite,
  stModeAll,
  stModeFilter,
  stSoftware,
  stSoftwarePath,
  stImport,

  stCompressing,
  stPreparing,
  stDownload,
  stCancel,
  stAddToQueue,
  stNewChapterNotification,
  stDownloading,
  stWait,
  stStop,
  stFinish: String;

  Host  : String = '';
  Port  : String = '';
  User  : String = '';
  Pass  : String = '';
  fmdDirectory: String;
  // EN: Param seperator
  SEPERATOR: String = '!%~';
  SEPERATOR2: String = '~%!';

  WebsiteRoots  : array[0..55] of array [0..1] of String =
    (('AnimeA', 'http://manga.animea.net'),
     ('MangaHere', 'http://www.mangahere.com'),
     ('MangaInn', 'http://www.mangainn.com'),
     ('OurManga', 'http://www.ourmanga.com'),
     ('KissManga', 'http://kissmanga.com'),
     ('Batoto', 'http://www.batoto.net'),
     ('Manga24h', 'http://manga24h.com'),
     ('VnSharing', 'http://truyen.vnsharing.net'),
     ('Hentai2Read', 'http://hentai2read.com'),
     ('Fakku', 'http://www.fakku.net'),
     ('Truyen18', 'http://www.truyen18.org'),
     ('MangaReader', 'http://www.mangareader.net'),
     ('MangaPark', 'http://www.mangapark.com'),
     ('E-Hentai', 'http://g.e-hentai.org'),
     ('MangaFox', 'http://mangafox.me'),
     ('MangaTraders', 'http://www.mangatraders.com'),
     ('MangaStream', 'http://mangastream.com'),
     ('MangaEden', 'http://www.mangaeden.com'),
     ('PervEden', 'http://www.perveden.com'),
     ('TruyenTranhTuan', 'http://truyentranhtuan.com'),
     ('Turkcraft', 'http://turkcraft.com'),
     ('MangaVadisi', 'http://www.mangavadisi.net'),
     ('MangaFrame', 'http://www.mngfrm.com'),
     ('EatManga', 'http://eatmanga.com'),
     ('Starkana', 'https://starkana.org'),
     ('MangaPanda', 'http://www.mangapanda.com'),
     ('RedHawkScans', 'http://manga.redhawkscans.com'),
     ('BlogTruyen', 'http://blogtruyen.com'),
     ('Komikid', 'http://komikid.com'),
     ('SubManga', 'http://submanga.com'),
     ('ESMangaHere', 'http://es.mangahere.com'),
     ('AnimExtremist', 'http://www.animextremist.com'),
     ('PecintaKomik', 'http://www.pecintakomik.com'),
     ('HugeManga', 'http://hugemanga.com'),
     ('S2scanlations', 'http://s2scanlations.com'),
     ('SenManga', 'http://raw.senmanga.com'),
     ('imanhua', 'http://www.imanhua.com'),
     ('Mabuns', 'http://www.mabuns.web.id'),
     ('MangaEsta', 'http://www.mangaesta.net'),
     ('CentralDeMangas', 'http://centraldemangas.com.br'),
     ('EGScans', 'http://readonline.egscans.com'),
     ('MangaAr', 'http://manga-ar.com'),
     ('MangaAe', 'http://www.manga.ae/'),
     ('AnimeStory', 'http://www.anime-story.com'),
     ('LectureEnLigne', 'http://www.lecture-en-ligne.com'),
     ('ScanManga', 'http://www.scan-manga.com'),
     ('MangaGo', 'http://www.mangago.com'),
     ('DM5', 'http://www.dm5.com'),
     ('Pururin', 'http://pururin.com'),
     ('Mangacow', 'http://mngacow.com'),
     ('KivManga', 'http://www.kivmanga.com'),
     ('Mangacan', 'http://mangacanblog.com'),
     ('MeinManga', 'http://www.meinmanga.com/'),
     ('MangasPROJECT', 'http://www.mangasproject.net'),
     ('MangaREADER_POR', 'http://www.mangareader.com.br'),
     ('Manga2u', 'http://www.manga2u.me')
    );

  ANIMEA_BROWSER: String = '/browse.html?page=';
  ANIMEA_SKIP   : String = '?skip=1';

  MANGAHERE_BROWSER: String = '/mangalist/';

  MANGAINN_BROWSER: String = '/mangalist/';

  OURMANGA_BROWSER: String = '/directory/';

  KISSMANGA_BROWSER: String = '/MangaList';

  BATOTO_BROWSER   : String = '/search';

  MANGA24H_BROWSER: String = '/manga/update/page/';

  VNSHARING_BROWSER: String = '/DanhSach';

  HENTAI2READ_ROOT   : String = 'http://hentai2read.com';
  HENTAI2READ_MROOT  : String = 'http://m.hentai2read.com';
  HENTAI2READ_BROWSER: String = '/hentai-list/all/any/name-az/';

  FAKKU_BROWSER          : String = '/manga/newest';
  FAKKU_MANGA_BROWSER    : String = '/manga/newest';
  FAKKU_DOUJINSHI_BROWSER: String = '/doujinshi/newest';

  TRUYEN18_ROOT   : String = 'http://www.truyen18.org';
  TRUYEN18_BROWSER: String = '/moi-dang/danhsach';

  MANGAREADER_BROWSER: String = '/alphabetical';

  MANGAPARK_BROWSER: String = '/list/';

 // GEHENTAI_BROWSER: String = '&f_doujinshi=on&advsearch=1&f_search=Search+Keywords&f_srdd=2&f_sname=on&f_stags=on&f_apply=Apply+Filter';

  MANGAFOX_BROWSER: String = '/directory/';

  MANGATRADERS_BROWSER: String = '/manga/serieslist/';

  MANGASTREAM_ROOT   : String = 'http://mangastream.com';
  MANGASTREAM_ROOT2  : String = 'http://readms.com';
  MANGASTREAM_BROWSER: String = '/manga';

  MANGAEDEN_BROWSER   : String = '/en-directory/';
  MANGAEDEN_EN_BROWSER: String = '/en-directory/';
  MANGAEDEN_IT_BROWSER: String = '/it-directory/';

  PERVEDEN_BROWSER   : String = '/en-directory/';
  PERVEDEN_EN_BROWSER: String = '/en-directory/';
  PERVEDEN_IT_BROWSER: String = '/it-directory/';

  TRUYENTRANHTUAN_BROWSER: String = '/danh-sach-truyen';

  TURKCRAFT_BROWSER: String = '/';

  MANGAVADISI_BROWSER: String = '/hemenoku/';

  MANGAFRAME_BROWSER: String = '/Okuyucu/reader/list/';

  EATMANGA_BROWSER: String = '/Manga-Scan/';

  STARKANA_BROWSER: String = '/manga/list';

  MANGAPANDA_ROOT   : String = 'http://www.mangapanda.com';
  MANGAPANDA_BROWSER: String = '/alphabetical';

  REDHAWKSCANS_BROWSER: String = '/reader/list/';

  BLOGTRUYEN_BROWSER   : String = '/danhsach/tatca';
  BLOGTRUYEN_JS_BROWSER: String = '/ListStory/GetListStory/';
  BLOGTRUYEN_POST_FORM : String = 'Url=tatca&OrderBy=1&PageIndex=';

  KOMIKID_BROWSER: String = '/';

  SUBMANGA_BROWSER: String = '/series/n';

  ESMANGAHERE_BROWSER: String = '/mangalist/';

  ANIMEEXTREMIST_BROWSER: String = '/mangas.htm?ord=todos';

  MANGAKU_BROWSER: String = '/2009/06/daftar-isi.html';

  PECINTAKOMIK_BROWSER: String = '/directory/';

  HUGEMANGA_BROWSER: String = '/';

  S2SCAN_BROWSER: String = '/online/read/denpa_kyoushi/en/0/90/page/1';

  SENMANGA_BROWSER: String = '/Manga/';

  IMANHUA_BROWSER: String = '/all.html';

  MABUNS_BROWSER: String = '/p/mabuns-manga-list.html';

  MANGAESTA_BROWSER: String = '/p/manga-list.html';

  CENTRALDEMANGAS_BROWSER: String = '/mangas/list/*';

  EGSCANS_BROWSER: String = '/';

  MANGAAR_BROWSER: String = '/directory';

  MANGAAE_BROWSER: String = '/manga/all/';

  ANIMESTORY_BROWSER: String = '/mangas/';

  LEE_BROWSER: String = '/index.php?page=liste&ordre=titre';

  SCANMANGA_BROWSER: String = '/scanlation/liste_des_mangas.html';

  MANGAGO_BROWSER: String = '/list/directory/all/';

  DM5_BROWSER: String = '/manhua-new';
  
  PURURIN_BROWSER: String = '/browse/';
  
  MANGACOW_BROWSER: String = '/manga-list/';
  
  KIVMANGA_BROWSER: String = '/';
  
  MANGACAN_BROWSER: String = '/daftar-komik-manga-bahasa-indonesia.html';

  MEINMANGA_BROWSER: String = '/directory/all/';
  
  MANGASPROJECT_BROWSER: String = '/AJAX/listaMangas/all';
  
  MANGAREADER_POR_BROWSER: String = '/AJAX/listaMangas/all';
  
  MANGA2U_BROWSER: String = '/list/all/any/most-popular/';

  UPDATE_URL      : String = 'http://jaist.dl.sourceforge.net/project/fmd/FMD/updates/';

  OptionAutoCheckMinutes,
  OptionCustomRename,
  // dialog messages
  infoCustomGenres,
  infoName,
  infoAuthors,
  infoArtists,
  infoGenres,
  infoStatus,
  infoSummary,
  infoLink ,

  // this is for erasing the "Search..." message
  stSearch,
  stInProgress,
  stAllDownloads,
  stFilters,

  stHistory,
  stToday,
  stYesterday,
  stOneWeek,
  stOneMonth,

  stDownloadManga,
  stDownloadStatus,
  stDownloadProgress,
  stDownloadWebsite,
  stDownloadSaveto,
  stDownloadAdded,
  stFavoritesCurrentChapter,
  stFavoritesHasNewChapter,

  stFavoritesCheck,
  stFavoritesChecking,

  stUpdaterCheck,
  stSelected,
  stImportList,
  stImportCompleted,

  stOptionAutoCheckMinutesCaption,
  stIsCompressing,
  stDlgUpdaterVersionRequire,
  stDlgUpdaterIsRunning,
  stDlgLatestVersion,
  stDlgNewVersion,
  stDlgURLNotSupport,
  stDldMangaListSelect,
  stDlgUpdateAlreadyRunning,
  stDlgNewManga,
  stDlgQuit,
  stDlgRemoveTask,
  stDlgRemoveFinishTasks,
  stDlgTypeInNewChapter,
  stDlgTypeInNewSavePath,
  stDlgCannotGetMangaInfo,
  stDlgFavoritesIsRunning,
  stDlgNoNewChapter,
  stDlgHasNewChapter,
  stDlgRemoveCompletedManga,
  stDlgUpdaterWantToUpdateDB,
  stDlgUpdaterCannotConnectToServer: String;

  OptionCheckMinutes: Cardinal = 0;
  OptionPDFQuality  : Cardinal = 95;
  OptionMaxRetry    : Cardinal = 0;

  OptionShowBatotoSG      : Boolean = TRUE;
  OptionShowAllLang       : Boolean = TRUE;
  OptionAutoDlFav       : Boolean = TRUE;
  OptionBatotoUseIEChecked: Boolean = FALSE;
  OptionEnableLoadCover: Boolean = FALSE;
  OptionAutoNumberChapterChecked: Boolean = TRUE;
  OptionAutoRemoveCompletedManga: Boolean = TRUE;
  OptionAutoCheckFavStartup: Boolean = FALSE;

type
  TMemory = Pointer;

  PMangaListItem = ^TMangaListItem;
  TMangaListItem = record
    Text: String;
  end;

  PSingleItem = ^TSingleItem;
  TSingleItem = record
    Text: String;
  end;

  PMangaInfo = ^TMangaInfo;
  TMangaInfo = record
    url,
    title,
    link,
    website,
    coverLink,
    authors,
    artists,
    genres,
    status,
    summary     : String;
    numChapter  : Cardinal;
    chapterName,
    chapterLinks: TStringList;
  end;

  PDownloadInfo = ^TDownloadInfo;
  TDownloadInfo = record
    title,
    Status,
    Progress,
    Website,
    SaveTo,
    dateTime : String;
    iProgress: Integer;
  end;

  PFavoriteInfo = ^TFavoriteInfo;
  TFavoriteInfo = record
    numbering,
    title,
    downloadedChapterList,
    currentChapter,
    Website,
    SaveTo,
    Link     : String;
  end;

  TCardinalList = TFPGList<Cardinal>;
  TByteList   = TFPGList<Byte>;

  TDownloadPageThread = class(TThread)
  protected
    procedure Execute; override;
  public
    isSuccess,
    isDone: Boolean;
    Retry : Cardinal;
    URL,
    Path  : String;
    constructor Create(CreateSuspended: Boolean);
  end;

function  UnicodeRemove(const S: String): String;
// Check a directory to see if it's empty (return TRUE) or not
function  IsDirectoryEmpty(const ADir: String): Boolean;
function  CheckRedirect(const HTTP: THTTPSend): String;
function  CorrectFilePath(const APath: String): String;
function  CorrectURL(const URL: String): String;
procedure CheckPath(const S: String);

function  GetMangaSiteID(const name: String): Cardinal;
function  GetMangaSiteName(const ID: Cardinal): String;
function  GetMangaDatabaseURL(const name: String): String;
// Return true if the website doesn't contain manga information
function  sitesWithoutInformation(const website: String): Boolean;

function  RemoveSymbols(const input: String): String;

// custom rename feature
function  CustomRename(const AString, AWebsite, AMangaName, AChapter, ANumbering: String; const AIsUnicodeRemove: Boolean): String;

// Get substring from source
function  GetString(const source, sStart, sEnd: String): String;

function  Find(const S: String; var List: TStringList; out index: Integer): Boolean;

// Get param from input
procedure GetParams(const output: TStringList; input: String); overload;
procedure GetParams(var output: TCardinalList; input: String); overload;
procedure GetParams(var output: TList; input: String); overload;

function  RemoveDuplicateNumbersInString(const AString: String): String;
// Set param from input
function  SetParams(input: TObject): String; overload;
function  SetParams(const input: array of String): String; overload;

procedure CustomGenres(var output: TStringList; input: String);

function  FixPath(const path: String): String;
function  GetLastDir(const path: String): String;
function  StringFilter(const source: String): String;
function  HTMLEntitiesFilter(const source: String): String;
function  StringBreaks(const source: String): String;
function  RemoveStringBreaks(const source: String): String;

function  PrepareSummaryForHint(const source: String):  String;

// deal with sourceforge URL.
function  SourceForgeURL(URL: string): string;
// Get HTML source code from a URL.
function  GetPage(const AHTTP: THTTPSend; var output: TObject; URL: String; const Reconnect: Cardinal; const isByPassHTTP: Boolean): Boolean; overload;
function  GetPage(var output: TObject; URL: String; const Reconnect: Cardinal; const isByPassHTTP: Boolean): Boolean; overload; inline;
function  GetPage(var output: TObject; URL: String; const Reconnect: Cardinal): Boolean; overload; inline;
function  GetPage(const AHTTP: THTTPSend; var output: TObject; URL: String; const Reconnect: Cardinal): Boolean; overload; inline;
// Get url from a bitly url.
function  GetURLFromBitly(const URL: String): String;
// Download an image from url and save it to a specific location.
function  SaveImage(const AOwner: TObject; const AHTTP: THTTPSend; const mangaSiteID: Integer; URL: String; const Path, name, prefix: String; const Reconnect: Cardinal): Boolean; overload;
function  SaveImage(const mangaSiteID: Integer; URL: String; const Path, name, prefix: String; const Reconnect: Cardinal): Boolean; overload; inline;

procedure QuickSortChapters(var chapterList, linkList: TStringList);
procedure QuickSortData(var merge: TStringList);
// This method uses to sort the data. Use when we load all the lists.
procedure QuickSortDataWithWebID(var merge: TStringList; const webIDList: TByteList);


function  GetCurrentJDN: LongInt;
function  DateToJDN(const year, month, day: Word): LongInt;

{function  ConvertInt32ToStr(const aValue: Cardinal)  : String;
function  ConvertStrToInt32(const aStr  : String): Cardinal;}
procedure TransferMangaInfo(var dest: TMangaInfo; const source: TMangaInfo);

// cross platform funcs

function  fmdGetTempPath: String;
function  fmdGetTickCount: Cardinal;
procedure fmdPowerOff;
procedure fmdHibernate;
function  fmdRunAsAdmin(path, params: String; isPersistent: Boolean): Boolean;

implementation

uses
  Process, FileUtil{$IFDEF WINDOWS}, ShellApi, Windows{$ENDIF},
  lazutf8classes
  {$IFDEF DOWNLOADER},uDownloadsManager{$ENDIF};

{$IFDEF WINDOWS}

// thanks Leledumbo for the code
const
  SE_CREATE_TOKEN_NAME = 'SeCreateTokenPrivilege';
  SE_ASSIGNPRIMARYTOKEN_NAME = 'SeAssignPrimaryTokenPrivilege';
  SE_LOCK_MEMORY_NAME = 'SeLockMemoryPrivilege';
  SE_INCREASE_QUOTA_NAME = 'SeIncreaseQuotaPrivilege';
  SE_UNSOLICITED_INPUT_NAME = 'SeUnsolicitedInputPrivilege';
  SE_MACHINE_ACCOUNT_NAME = 'SeMachineAccountPrivilege';
  SE_TCB_NAME = 'SeTcbPrivilege';
  SE_SECURITY_NAME = 'SeSecurityPrivilege';
  SE_TAKE_OWNERSHIP_NAME = 'SeTakeOwnershipPrivilege';
  SE_LOAD_DRIVER_NAME = 'SeLoadDriverPrivilege';
  SE_SYSTEM_PROFILE_NAME = 'SeSystemProfilePrivilege';
  SE_SYSTEMTIME_NAME = 'SeSystemtimePrivilege';
  SE_PROF_SINGLE_PROCESS_NAME = 'SeProfileSingleProcessPrivilege';
  SE_INC_BASE_PRIORITY_NAME = 'SeIncreaseBasePriorityPrivilege';
  SE_CREATE_PAGEFILE_NAME = 'SeCreatePagefilePrivilege';
  SE_CREATE_PERMANENT_NAME = 'SeCreatePermanentPrivilege';
  SE_BACKUP_NAME = 'SeBackupPrivilege';
  SE_RESTORE_NAME = 'SeRestorePrivilege';
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
  SE_DEBUG_NAME = 'SeDebugPrivilege';
  SE_AUDIT_NAME = 'SeAuditPrivilege';
  SE_SYSTEM_ENVIRONMENT_NAME = 'SeSystemEnvironmentPrivilege';
  SE_CHANGE_NOTIFY_NAME = 'SeChangeNotifyPrivilege';
  SE_REMOTE_SHUTDOWN_NAME = 'SeRemoteShutdownPrivilege';
  SE_UNDOCK_NAME = 'SeUndockPrivilege';
  SE_SYNC_AGENT_NAME = 'SeSyncAgentPrivilege';
  SE_ENABLE_DELEGATION_NAME = 'SeEnableDelegationPrivilege';
  SE_MANAGE_VOLUME_NAME = 'SeManageVolumePrivilege';

function SetSuspendState(hibernate, forcecritical, disablewakeevent: Boolean): Boolean; stdcall; external 'powrprof.dll' name 'SetSuspendState';
function IsHibernateAllowed: Boolean; stdcall; external 'powrprof.dll' name 'IsPwrHibernateAllowed';
function IsPwrSuspendAllowed: Boolean; stdcall; external 'powrprof.dll' name 'IsPwrSuspendAllowed';
function IsPwrShutdownAllowed: Boolean; stdcall; external 'powrprof.dll' name 'IsPwrShutdownAllowed';
function LockWorkStation: Boolean; stdcall; external 'user32.dll' name 'LockWorkStation';

function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;
var
  hToken: THandle;
  TokenPriv: TOKEN_PRIVILEGES;
  PrevTokenPriv: TOKEN_PRIVILEGES;
  ReturnLength: Cardinal;
begin
  Result := True;
  // Only for Windows NT/2000/XP and later.
  if not (Win32Platform = VER_PLATFORM_WIN32_NT) then Exit;
  Result := False;

  // obtain the processes token
  if OpenProcessToken(GetCurrentProcess(),
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  begin
    try
      // Get the locally unique identifier (LUID) .
      if LookupPrivilegeValue(nil, PChar(sPrivilege),
        TokenPriv.Privileges[0].Luid) then
      begin
        TokenPriv.PrivilegeCount := 1; // one privilege to set

        case bEnabled of
          True: TokenPriv.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
          False: TokenPriv.Privileges[0].Attributes := 0;
        end;

        ReturnLength := 0; // replaces a var parameter
        PrevTokenPriv := TokenPriv;

        // enable or disable the privilege

        AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv),
          PrevTokenPriv, ReturnLength);
      end;
    finally
      CloseHandle(hToken);
    end;
  end;
  // test the return value of AdjustTokenPrivileges.
  Result := GetLastError = ERROR_SUCCESS;
  if not Result then
    raise Exception.Create(SysErrorMessage(GetLastError));
end;
{$ENDIF}

function  UnicodeRemove(const S: String): String;
var i: Cardinal;
begin
  Result:= S;
  for i:= 1 to Length(Result) do
  begin
    if (Byte(Result[i])<31) OR (Byte(Result[i])>127) then
    begin
      Delete(Result, i, 1);
      Insert('_', Result, i);
    end;
  end;
end;

function IsDirectoryEmpty(const ADir: String): Boolean;
var
  searchRec :TSearchRec;
begin
  try
    Result:= (FindFirstUTF8(CorrectFilePath(ADir)+'*.*', faAnyFile {$ifdef unix} OR faSymLink {$endif unix}, searchRec) = 0) AND
             (FindNextUTF8(searchRec) = 0) AND
             (FindNextUTF8(searchRec) <> 0);
  finally
    FindCloseUTF8(searchRec);
  end;
end;

function  CorrectURL(const URL: String): String;
begin
  Result:= StringReplace(URL, ' ', '%20', [rfReplaceAll]);
end;

function  CorrectFilePath(const APath: String): String;
var I: Integer;
begin
  if APath = '' then exit('');
  Result:= APath;
  for I:=1 to Length(Result) do
    if Result[I]= '\' then
      Result[I]:= '/';
  if Result[Length(Result)]<>'/' then
    Result:= Result + '/';
  while system.Pos('//', Result) > 0 do
    Result:= StringReplace(Result, '//', '/', []);
end;

// took from an old project - maybe bad code
procedure CheckPath(const S: String);
var
    wS,
    lcS,
    lcS2: String;
    i,
    j   : Word;
begin
  wS:= s;
  lcS2:= '';
  if wS[2]<>':' then
  begin
    {$IFDEF WIN32}
    lcS2:= CorrectFilePath(fmdDirectory);
    {$ELSE}
    lcS2:= '';
    {$ENDIF}
    Insert('/', wS, 1);
  end
  else
  begin
    if Length(wS)=2 then
      wS:= wS+'/';
  end;
  for i:= 1 to Length(wS) do
  begin
    lcS2:= lcS2+wS[i];
    if (wS[i]='/') AND ((wS[i+1]<>'/') OR (wS[i+1]<>' ')) AND
       (i<Length(wS)) then
    begin
      j:= i+1;
      lcS:= '';
      repeat
        lcS:= lcS+wS[j];
        Inc(j);
      until wS[j]='/';
      if NOT DirectoryExistsUTF8(lcS2+lcS) then
      begin
        CreateDirUTF8(lcS2+lcS);
      end;
    end;
  end;
  SetCurrentDirUTF8(fmdDirectory);
end;

function  GetMangaSiteID(const name: String): Cardinal;
var
  i: Cardinal;
begin
  for i:= 0 to High(WebsiteRoots) do
    if Name = WebsiteRoots[i,0] then
      exit(i);
end;

function  GetMangaSiteName(const ID: Cardinal): String;
begin
  Result:= WebsiteRoots[ID,0];
end;

// bad coding.. but this is how FMD works
function  GetMangaDatabaseURL(const name: String): String;
var
  i: Byte;
begin
  Result:= 'http://jaist.dl.sourceforge.net/project/fmd/FMD/lists/'+name+'.zip';
end;

function  sitesWithoutInformation(const website: String): Boolean;
begin
  Result:= ((website = WebsiteRoots[MANGASTREAM_ID,0]) OR
            (website = WebsiteRoots[MANGAVADISI_ID,0]) OR
            (website = WebsiteRoots[SENMANGA_ID,0]) OR
            (website = WebsiteRoots[MANGAFRAME_ID,0]) OR
            (website = WebsiteRoots[S2SCAN_ID,0]) OR
            (website = WebsiteRoots[EGSCANS_ID,0]) OR
            (website = WebsiteRoots[TURKCRAFT_ID,0]) OR
            (website = WebsiteRoots[HUGEMANGA_ID,0]) OR
            (website = WebsiteRoots[KOMIKID_ID,0]) OR
	    (website = WebsiteRoots[KIVMANGA_ID,0]) OR
	    (website = WebsiteRoots[MANGACAN_ID,0]) OR
	    (website = WebsiteRoots[MANGAREADER_ID,0]));
end;

function  RemoveSymbols(const input: String): String;
var
  i     : Cardinal;
  isDone: Boolean;
begin
  Result:= input;
  repeat
    isDone:= TRUE;
    for i:= 0 to 8 do
      if Pos(Symbols[i], Result)<>0 then
      begin
        isDone:= FALSE;
        Result:= StringReplace(Result, Symbols[i], '', [rfReplaceAll]);
      end;
  until isDone;
  if (Length(Result)>0) AND
     (Result[Length(Result)] = '.') then
  begin
    Result[Length(Result)]:= '-';
  end;
end;

function  CustomRename(const AString, AWebsite, AMangaName, AChapter, ANumbering: String; const AIsUnicodeRemove: Boolean): String;
begin
  if (Pos('%NUMBERING%', AString) = 0) AND (Pos('%CHAPTER%', AString) = 0) then
    Result:= ANumbering + AString
  else
    Result:= AString;
  Result:= TrimLeft(TrimRight(Result));
  Result:= StringReplace(Result, '%WEBSITE%', AWebsite, [rfReplaceAll]);
  Result:= StringReplace(Result, '%MANGA%', AMangaName, [rfReplaceAll]);
  Result:= StringReplace(Result, '%CHAPTER%', AChapter, [rfReplaceAll]);
  if (AWebsite = WebsiteRoots[FAKKU_ID,0]) OR (AWebsite = WebsiteRoots[MANGASTREAM_ID,0]) then
    Result:= StringReplace(Result, '%NUMBERING%', '', [rfReplaceAll])
  else
    Result:= StringReplace(Result, '%NUMBERING%', ANumbering, [rfReplaceAll]);
  Result:= StringReplace(Result, '/', '', [rfReplaceAll]);
  Result:= StringReplace(Result, '\', '', [rfReplaceAll]);

  if Result = '' then
  begin
    if (AWebsite = WebsiteRoots[FAKKU_ID,0]) OR (AWebsite = WebsiteRoots[MANGASTREAM_ID,0]) then
      Result:= AChapter
    else
      Result:= ANumbering;
  end;
  if AIsUnicodeRemove then
    Result:= UnicodeRemove(Result);

  Result:= TrimLeft(TrimRight(Result));
  Result:= RemoveSymbols(HTMLEntitiesFilter(StringFilter(Result)));
end;

function  GetString(const source, sStart, sEnd: String): String;
var
  l: Word;
  s: String;
begin
  Result:= '';
  l:= Pos(sStart, source);
  if (l<>0) AND (source[l+Length(sStart)]<>sEnd[1]) then
  begin
    s:= RightStr(source, Length(source)-l-Length(sStart)+1);
    l:= Pos(sEnd, s);
    if (l<>0) then
      Result:= LeftStr(s, l-1);
  end;
end;

function  Find(const S: String; var List: TStringList; out index: Integer): Boolean;
var
  i: Cardinal;
begin
  Result:= FALSE;
  index:= -1;
  if List.Count = 0 then exit;
  for i:= 0 to List.Count-1 do
  begin
    if CompareStr(S, List.Strings[i])=0 then
    begin
      index:= i;
      Result:= TRUE;
      break;
    end;
  end;
end;

procedure GetParams(const output: TStringList; input: String);
var l: Word;
begin
  repeat
    l:= Pos(SEPERATOR, input);
    if l<>0 then
    begin
      output.Add(LeftStr(input, l-1));
      input:= RightStr(input, Length(input)-l-Length(SEPERATOR)+1);
    end;
  until l = 0;
end;

procedure GetParams(var output: TCardinalList; input: String);
var l: Word;
begin
  repeat
    l:= Pos(SEPERATOR, input);
    if l<>0 then
    begin
      output.Add(StrToInt(LeftStr(input, l-1)));
      input:= RightStr(input, Length(input)-l-Length(SEPERATOR)+1);
    end;
  until l = 0;
end;

procedure GetParams(var output: TList; input: String);
var l: Word;
begin
  repeat
    l:= Pos(SEPERATOR, input);
    if l<>0 then
    begin
      output.Add(Pointer(StrToInt(LeftStr(input, l-1))));
      input:= RightStr(input, Length(input)-l-Length(SEPERATOR)+1);
    end;
  until l = 0;
end;

function  RemoveDuplicateNumbersInString(const AString: String): String;
var
  i, j: Integer;
  list: TList;
begin
  if AString = '' then exit;
  list:= TList.Create;
  GetParams(list, AString);
  i:= 0;
  while i < list.Count do
  begin
    j:= i;
    while j < list.Count do
    begin
      if (i<>j) AND (list.Items[i] = list.Items[j]) then
        list.Delete(j)
      else
        Inc(j);
    end;
    Inc(i);
  end;
  Result:= '';
  for i:= 0 to list.Count-1 do
    Result:= Result + IntToStr(Integer(list.Items[i])) + SEPERATOR;
  list.Free;
end;

function  SetParams(input: TObject): String;
var
  i: Cardinal;
begin
  Result:= '';
  if input is TStringList then
  begin
    if TStringList(input).Count = 0 then exit;
    for i:= 0 to TStringList(input).Count-1 do
      Result:= Result + TStringList(input).Strings[i] + SEPERATOR;
  end
  else
  if input is TCardinalList then
  begin
    if TCardinalList(input).Count = 0 then exit;
    for i:= 0 to TCardinalList(input).Count-1 do
      Result:= Result + IntToStr(TCardinalList(input).Items[i]) + SEPERATOR;
  end
  else
  if input is TByteList then
  begin
    if TByteList(input).Count = 0 then exit;
    for i:= 0 to TByteList(input).Count-1 do
      Result:= Result + IntToStr(TByteList(input).Items[i]) + SEPERATOR;
  end;
end;

function  SetParams(const input: array of String): String;
var
  i: Cardinal;
begin
  Result:= '';
  if Length(input) = 0 then exit;
  for i:= 0 to Length(input)-1 do
    Result:= Result + input[i] + SEPERATOR;
end;

function  FixPath(const path: String): String;
var
  i: Cardinal;
begin
  Result:= '';
  if Length(path)=0 then exit;
  for i:= 1 to Length(path) do
  begin
    if Byte(path[i])>=128 then
      Result:= Result+'_'
    else
      Result:= Result+path[i];
  end;
end;

function  GetLastDir(const path: String): String;
var
  i, p: Cardinal;
begin
  Result:= '';
  if Length(path)=0 then exit;
  i:= Length(path);
  for i:= 1 to Length(path) do
  begin
    Result:= Result+path[i];
    if path[i] = '/' then
      p:= i;
  end;
end;

function  StringFilter(const source: String): String;
begin
  if Length(source) = 0 then exit;
  Result:= StringReplace(source, '&#33;', '!', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#36;', '$', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#39;', '''', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#033;', '!', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#036;', '$', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#039;', '''', [rfReplaceAll]);
  Result:= StringReplace(Result, '&gt;', '>', [rfReplaceAll]);
  Result:= StringReplace(Result, '&lt;', '<', [rfReplaceAll]);
  Result:= StringReplace(Result, '&amp;', '&', [rfReplaceAll]);
  Result:= StringReplace(Result, '&nbsp;', '', [rfReplaceAll]);
  Result:= StringReplace(Result, '&ldquo;', '"', [rfReplaceAll]);
  Result:= StringReplace(Result, '&ldquo;', '"', [rfReplaceAll]);
  Result:= StringReplace(Result, '&rdquo;', '"', [rfReplaceAll]);
  Result:= StringReplace(Result, '&quot;', '"', [rfReplaceAll]);
  Result:= StringReplace(Result, '&lsquo;', '''', [rfReplaceAll]);
  Result:= StringReplace(Result, '&rsquo;', '''', [rfReplaceAll]);
 // Result:= StringReplace(Result, '&nbsp;', ' ', [rfReplaceAll]);
  Result:= StringReplace(Result, #10, '\n',  [rfReplaceAll]);
  Result:= StringReplace(Result, #13, '\r',  [rfReplaceAll]);
end;

function  HTMLEntitiesFilter(const source: String): String;
begin
  if Length(source) = 0 then exit;

  // uppercase

  Result:= StringReplace(source, '&#171;', '«', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#176;', '°', [rfReplaceAll]);

  Result:= StringReplace(Result, '&Agrave;', 'À', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#192;', 'À', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Aacute;', 'Á', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#193;', 'Á', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Acirc;' , 'Â', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#194;' , 'Â', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Atilde;', 'Ã', [rfReplaceAll]);

  Result:= StringReplace(Result, '&Egrave;', 'È', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Eacute;', 'É', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Ecirc;' , 'Ê', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#202;' , 'Ê', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Etilde;', 'Ẽ', [rfReplaceAll]);

  Result:= StringReplace(Result, '&Igrave;', 'Ì', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Iacute;', 'Í', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Itilde;', 'Ĩ', [rfReplaceAll]);

  Result:= StringReplace(Result, '&ETH;'   , 'Đ', [rfReplaceAll]);

  Result:= StringReplace(Result, '&Ograve;', 'Ò', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Oacute;', 'Ó', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Ocirc;' , 'Ô', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#212;' , 'Ô', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Otilde;', 'Õ', [rfReplaceAll]);

  Result:= StringReplace(Result, '&Ugrave;', 'Ù', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Uacute;', 'Ú', [rfReplaceAll]);

  Result:= StringReplace(Result, '&Yacute;', 'Ý', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#221;', 'Ý', [rfReplaceAll]);

  // lowercase

  Result:= StringReplace(Result, '&agrave;', 'à', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#224;', 'à', [rfReplaceAll]);
  Result:= StringReplace(Result, '&aacute;', 'á', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#225;', 'á', [rfReplaceAll]);
  Result:= StringReplace(Result, '&acirc;' , 'â', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#226;' , 'â', [rfReplaceAll]);
  Result:= StringReplace(Result, '&atilde;', 'ã', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#227;', 'ã', [rfReplaceAll]);

  Result:= StringReplace(Result, '&#231;', 'ç', [rfReplaceAll]);
  Result:= StringReplace(Result, '&egrave;', 'è', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#232;', 'è', [rfReplaceAll]);
  Result:= StringReplace(Result, '&eacute;', 'é', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#233;', 'é', [rfReplaceAll]);
  Result:= StringReplace(Result, '&etilde;', 'ẽ', [rfReplaceAll]);
  Result:= StringReplace(Result, '&ecirc;' , 'ê', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#234;' , 'ê', [rfReplaceAll]);

  Result:= StringReplace(Result, '&igrave;', 'ì', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#236;', 'ì', [rfReplaceAll]);
  Result:= StringReplace(Result, '&iacute;', 'í', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#237;', 'í', [rfReplaceAll]);
  Result:= StringReplace(Result, '&itilde;', 'ĩ', [rfReplaceAll]);

  Result:= StringReplace(Result, '&#238;', 'î', [rfReplaceAll]);

  Result:= StringReplace(Result, '&eth;'   , 'đ', [rfReplaceAll]);

  Result:= StringReplace(Result, '&ograve;', 'ò', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#242;', 'ò', [rfReplaceAll]);
  Result:= StringReplace(Result, '&oacute;', 'ó', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#243;', 'ó', [rfReplaceAll]);
  Result:= StringReplace(Result, '&ocirc;' , 'ô', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#244;' , 'ô', [rfReplaceAll]);
  Result:= StringReplace(Result, '&otilde;', 'õ', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#245;', 'õ', [rfReplaceAll]);

  Result:= StringReplace(Result, '&ugrave;', 'ù', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#249;', 'ù', [rfReplaceAll]);
  Result:= StringReplace(Result, '&uacute;', 'ú', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#250;', 'ú', [rfReplaceAll]);

  Result:= StringReplace(Result, '&yacute;', 'ý', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#253;', 'ý', [rfReplaceAll]);

  Result:= StringReplace(Result, '&#8217;', '''', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#8220;', '"', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#8221;', '"', [rfReplaceAll]);
  Result:= StringReplace(Result, '&#8230;', '...', [rfReplaceAll]);


  Result:= StringReplace(Result, '&Auml;', 'Ä', [rfReplaceAll]);
  Result:= StringReplace(Result, '&auml;', 'ä', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Ouml;', 'Ö', [rfReplaceAll]);
  Result:= StringReplace(Result, '&ouml;', 'ö', [rfReplaceAll]);
  Result:= StringReplace(Result, '&Uuml;', 'Ü', [rfReplaceAll]);
  Result:= StringReplace(Result, '&uuml;', 'ü', [rfReplaceAll]);
  Result:= StringReplace(Result, '&szlig;', 'ß', [rfReplaceAll]);
end;

procedure  CustomGenres(var output: TStringList; input: String);
var
  s: String = '';
  i: Word;
begin
  if Length(input) = 0 then exit;
  for i:= 1 to Length(input) do
  begin
    if (input[i] = ',') OR (input[i] = ';') then
    begin
      TrimLeft(TrimRight(s));
      if Length(s) <> 0 then
      begin
        output.Add(s);
        s:= '';
      end;
    end
    else
      s:= s+input[i];
  end;
  TrimLeft(TrimRight(s));
  if Length(s) <> 0 then
    output.Add(s);
end;

function  StringBreaks(const source: String): String;
begin
  if Length(source) = 0 then exit;
  Result:= source;
  Result:= StringReplace(Result, '\n', #10,  [rfReplaceAll]);
  Result:= StringReplace(Result, '\r', #13,  [rfReplaceAll]);
end;

function  RemoveStringBreaks(const source: String): String;
begin
  if Length(source) = 0 then exit;
  Result:= StringReplace(source, #10, '', [rfReplaceAll]);
  Result:= StringReplace(Result, #13, '', [rfReplaceAll]);
end;

function  PrepareSummaryForHint(const source: String):  String;
var
  i: Cardinal = 1;
  j: Cardinal = 1;
begin
  Result:= source;
  repeat
    if (j>80) AND (Result[i] = ' ') then
    begin
      Insert(#10#13, Result, i);
      Inc(i, 2);
      j:= 1;
    end;
    Inc(j);
    Inc(i);
  until i >= Length(Result);
  Result:= StringReplace(Result, '\n', #10,  [rfReplaceAll]);
  Result:= StringReplace(Result, '\r', #13,  [rfReplaceAll]);
  Result:= TrimLeft(TrimRight(Result));
end;

function  CheckRedirect(const HTTP: THTTPSend): String;
var
  lineHeader: String;
  i: Byte;
begin
  Result:= '';
  i:= 0;
  while (Result = '') AND (i < HTTP.Headers.Count) do
  begin
    lineHeader:= HTTP.Headers[I];
    if Pos('Location: ', lineHeader) = 1 then
      Result:= Copy(lineHeader, 11, Length(lineHeader));
    Inc(i);
  end;
end;

function SFDirectLinkURL(URL: string; Document: TMemoryStream): string;
{
Transform this part of the body:
<noscript>
<meta http-equiv="refresh" content="5; url=http://downloads.sourceforge.net/project/base64decoder/base64decoder/version%202.0/b64util.zip?r=&amp;ts=1329648745&amp;use_mirror=kent">
</noscript>
into a valid URL:
http://downloads.sourceforge.net/project/base64decoder/base64decoder/version%202.0/b64util.zip?r=&amp;ts=1329648745&amp;use_mirror=kent
}
const
  Refresh='<meta http-equiv="refresh"';
  URLMarker='url=';
var
  Counter: integer;
  HTMLBody: TStringList;
  RefreshStart: integer;
  URLStart: integer;
begin
  HTMLBody:=TStringList.Create;
  try
    HTMLBody.LoadFromStream(Document);
    for Counter:=0 to HTMLBody.Count-1 do
    begin
      // This line should be between noscript tags and give the direct download locations:
      RefreshStart:=Ansipos(Refresh, HTMLBody[Counter]);
      if RefreshStart>0 then
      begin
        URLStart:=AnsiPos(URLMarker, HTMLBody[Counter])+Length(URLMarker);
        if URLStart>RefreshStart then
        begin
          // Look for closing "
          URL:=Copy(HTMLBody[Counter],
            URLStart,
            PosEx('"',HTMLBody[Counter],URLStart+1)-URLStart);
          break;
        end;
      end;
    end;
  finally
    HTMLBody.Free;
  end;
  result:=URL;
end;

function SourceForgeURL(URL: string): string;
// Detects sourceforge download and tries to deal with
// redirection, and extracting direct download link.
// Thanks to
// Ocye: http://lazarus.freepascal.org/index.php/topic,13425.msg70575.html#msg70575
const
  SFProjectPart = '//sourceforge.net/projects/';
  SFFilesPart = '/files/';
  SFDownloadPart ='/download';
var
  HTTPSender: THTTPSend;
  i, j: integer;
  FoundCorrectURL: boolean;
  SFDirectory: string; //Sourceforge directory
  SFDirectoryBegin: integer;
  SFFileBegin: integer;
  SFFilename: string; //Sourceforge name of file
  SFProject: string;
  SFProjectBegin: integer;
label
  loop;
begin
  // Detect SourceForge download; e.g. from URL
  //          1         2         3         4         5         6         7         8         9
  // 1234557890123456789012345578901234567890123455789012345678901234557890123456789012345578901234567890
  // http://sourceforge.net/projects/base64decoder/files/base64decoder/version%202.0/b64util.zip/download
  //                                 ^^^project^^^       ^^^directory............^^^ ^^^file^^^
  FoundCorrectURL:=true; //Assume not a SF download
  i:=Pos(SFProjectPart, URL);
  if i>0 then
  begin
    // Possibly found project; now extract project, directory and filename parts.
    SFProjectBegin:=i+Length(SFProjectPart);
    j := PosEx(SFFilesPart, URL, SFProjectBegin);
    if (j>0) then
    begin
      SFProject:=Copy(URL, SFProjectBegin, j-SFProjectBegin);
      SFDirectoryBegin:=PosEx(SFFilesPart, URL, SFProjectBegin)+Length(SFFilesPart);
      if SFDirectoryBegin>0 then
      begin
        // Find file
        // URL might have trailing arguments... so: search for first
        // /download coming up from the right, but it should be after
        // /files/
        i:=RPos(SFDownloadPart, URL);
        // Now look for previous / so we can make out the file
        // This might perhaps be the trailing / in /files/
        SFFileBegin:=RPosEx('/',URL,i-1)+1;

        if SFFileBegin>0 then
        begin
          SFFilename:=Copy(URL,SFFileBegin, i-SFFileBegin);
          //Include trailing /
          SFDirectory:=Copy(URL, SFDirectoryBegin, SFFileBegin-SFDirectoryBegin);
          FoundCorrectURL:=false;
        end;
      end;
    end;
  end;

  if not FoundCorrectURL then
  begin
    try
      // Rewrite URL if needed for Sourceforge download redirection
      // Detect direct link in HTML body and get URL from that
    loop:
      HTTPSender := THTTPSend.Create;
      //Who knows, this might help:
      HTTPSender.UserAgent:='curl/7.21.0 (i686-pc-linux-gnu) libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.3.4 libidn/1.18';
      while not FoundCorrectURL do
      begin
        HTTPSender.HTTPMethod('GET', URL);
        case HTTPSender.Resultcode of
          301, 302, 307:
            begin
              for i := 0 to HTTPSender.Headers.Count - 1 do
                if (Pos('Location: ', HTTPSender.Headers.Strings[i]) > 0) or
                  (Pos('location: ', HTTPSender.Headers.Strings[i]) > 0) then
                begin
                  j := Pos('use_mirror=', HTTPSender.Headers.Strings[i]);
                  if j > 0 then
                    URL :=
                      'http://' + RightStr(HTTPSender.Headers.Strings[i],
                      length(HTTPSender.Headers.Strings[i]) - j - 10) +
                      '.dl.sourceforge.net/project/' +
                      SFProject + '/' + SFDirectory + SFFilename
                  else
                    URL:=StringReplace(
                      HTTPSender.Headers.Strings[i], 'Location: ', '', []);
                  HTTPSender.Clear;//httpsend
                  FoundCorrectURL:=true;
                  break; //out of rewriting loop
              end;
            end;
          100..200:
            begin
              //Assume a sourceforge timer/direct link page
              URL:=SFDirectLinkURL(URL, HTTPSender.Document); //Find out
              FoundCorrectURL:=true; //We're done by now
            end;
          else
            begin
              HTTPSender.Free;
              goto loop;
            end;
        end;//case
      end;//while
    finally
      HTTPSender.Free;
    end;
  end;
  result:=URL;
end;

function  GetPage(const AHTTP: THTTPSend; var output: TObject; URL: String; const Reconnect: Cardinal; const isByPassHTTP: Boolean): Boolean;
// If AHTTP <> nil, we will use it as http sender. Otherwise we create a new
// instance.
var
  i      : Cardinal;
  HTTP   : THTTPSend;
  code   : Cardinal;
  counter: Cardinal = 0;
  s      : String;
  zstream: TGZFileStream;
  isGZip : Boolean = FALSE;
label
  globReturn;

begin
  Result:= FALSE;
  if (isByPassHTTP) AND
     (Pos('HTTP://', UpCase(URL)) = 0) AND
     (Pos('HTTPS://', UpCase(URL)) = 0) then
    exit;
  if AHTTP <> nil then
    HTTP:= AHTTP
  else
    HTTP:= THTTPSend.Create;
globReturn:

  // Site that require HTTPS request should define here
  if Pos('https://', URL) <> 0 then
  begin
    HTTP.Sock.CreateWithSSL(TSSLOpenSSL);
    HTTP.Sock.SSLDoConnect;
  end;

  HTTP.ProxyHost:= Host;
  HTTP.ProxyPort:= Port;
  HTTP.ProxyUser:= User;
  HTTP.ProxyPass:= Pass;
  if isGZip then
  begin
    HTTP.MimeType := 'application/x-www-form-urlencoded';
    HTTP.Headers.Add('Accept-Encoding: gzip, deflate');
  end
  else
  if Pos(WebsiteRoots[MEINMANGA_ID,1], URL) = 0 then
  begin
    HTTP.Headers.Add('Accept-Charset: utf-8');
    HTTP.UserAgent:= 'curl/7.21.0 (i686-pc-linux-gnu) libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.3.4 libidn/1.18';
  end;

  while (NOT HTTP.HTTPMethod('GET', URL)) OR
        (HTTP.ResultCode > 500) do
  begin
    code:= HTTP.ResultCode;
    if Reconnect <> 0 then
    begin
      if Reconnect <= counter then
      begin
        if AHTTP = nil then
          HTTP.Free;
        exit;
      end;
      Inc(counter);
    end;
    HTTP.Clear;
    Sleep(500);
  end;
  if Pos('?nw=session', URL) > 0 then
  begin
    HTTP.Clear;
    Delete(URL, Length(URL)-10, 11);
    goto globReturn;
  end;

  while (HTTP.ResultCode = 302) OR (HTTP.ResultCode = 301) do
  begin
    s:= CheckRedirect(HTTP);
    if Pos('http://', s) = 0 then
      URL:= 'http://' + GetString(URL, 'http://', '/')
    else
      URL:= s;

    HTTP.Clear;
    HTTP.RangeStart:= 0;
    if Pos(HENTAI2READ_ROOT, URL) <> 0 then
      HTTP.Headers.Insert(0, 'Referer:'+HENTAI2READ_ROOT+'/');
    while (NOT HTTP.HTTPMethod('GET', URL)) OR
          (HTTP.ResultCode >= 500) do
    begin
      if Reconnect <> 0 then
      begin
        if Reconnect <= counter then
        begin
          if AHTTP = nil then
            HTTP.Free;
          exit;
        end;
        Inc(counter);
      end;
      HTTP.Clear;
      Sleep(500);
    end;
  end;

  if HTTP.ResultCode <> 404 then
  begin
    if (HTTP.Headers.Count > 0) AND (output is TStringList) then
      for i:= 0 to HTTP.Headers.Count-1 do
        if Pos('gzip', HTTP.Headers.Strings[i]) > 0 then
        begin
          isGZip:= TRUE;
          break;
        end;

    // Decompress the html file
    if isGZip then
    begin
      i:= Random(9999999);
      HTTP.Document.Position:= 0;
      s:= fmdGetTempPath + ' ';
      s:= TrimLeft(TrimRight(s)) + IntToStr(i) + '.tmp';
      HTTP.Document.SaveToFile(s);

      zstream:= TGZFileStream.create(s, gzopenread);
      TStringList(output).LoadFromStream(zstream);

      zstream.Free;
      DeleteFileUTF8(s);
    end
    else
    try
      if output is TStringList then
        TStringList(output).LoadFromStream(HTTP.Document)
      else
      if output is TPicture then
        TPicture(output).LoadFromStream(HTTP.Document);
    except
      on E: Exception do;
    end;
    Result:= TRUE;
  end
  else
    Result:= FALSE;
  if AHTTP = nil then
    HTTP.Free;
end;

function  GetPage(var output: TObject; URL: String; const Reconnect: Cardinal; const isByPassHTTP: Boolean): Boolean;
begin
  Result:= GetPage(nil, output, URL, Reconnect, isByPassHTTP);
end;

function  GetPage(var output: TObject; URL: String; const Reconnect: Cardinal): Boolean;
begin
  Result:= GetPage(nil, output, URL, Reconnect, FALSE);
end;

function  GetPage(const AHTTP: THTTPSend; var output: TObject; URL: String; const Reconnect: Cardinal): Boolean;
begin
  Result:= GetPage(AHTTP, output, URL, Reconnect, FALSE);
end;

function  GetURLFromBitly(const URL: String): String;
var
  i         : Cardinal;
  httpSource: TStringList;
begin
  Result:= '';
  httpSource:= TStringList.Create;
  GetPage(TObject(httpSource), URL, 4);
  if httpSource.Count > 0 then
    for i:= 0 to httpSource.Count do
      if Pos(';url=', httpSource.Strings[i])>0 then
      begin
        Result:= GetString(httpSource.Strings[i], ';url=', '&amp;');
        break;
      end;
  httpSource.Free;
end;

function  SaveImage(const AOwner: TObject; const AHTTP: THTTPSend; const mangaSiteID: Integer; URL: String; const Path, name, prefix: String; const Reconnect: Cardinal): Boolean;
// prefix: For example: 000<our prefix>.jpg.
var
  retryToSave: Boolean = FALSE;
  header    : array [0..3] of Byte;
  ext       : String;
  HTTPHeader: TStringList;
  HTTP      : THTTPSend;
  i         : Cardinal;
  counter   : Cardinal = 0;
  s         : String;
  dest,
  source    : TPicture;
  fstream   : TFileStreamUTF8;

label
  jmpTerminate;

begin
  s:= Path+'/'+name;

  // Check to see if a file with similar name was already exist. If so then we
  // skip the download process.
  if (FileExists(s+'.jpg')) OR
     (FileExists(s+'.png')) OR
     (FileExists(s+'.gif')) OR
     (Pos('http', URL) = 0) then
  begin
    Result:= TRUE;
    exit;
  end;
  Result:= FALSE;
  if AHTTP <> nil then
  begin
    HTTPHeader:= TStringList.Create;
    HTTPHeader.Text:= AHTTP.Headers.Text;
    HTTP:= AHTTP;
  end
  else
    HTTP:= THTTPSend.Create;

  // Site that require HTTPS request should define here
  if Pos('https://', URL) <> 0 then
  begin
    HTTP.Sock.CreateWithSSL(TSSLOpenSSL);
    HTTP.Sock.SSLDoConnect;
  end;

  HTTP.ProxyHost:= Host;
  HTTP.ProxyPort:= Port;
  HTTP.ProxyUser:= User;
  HTTP.ProxyPass:= Pass;

  if (mangaSiteID <> MANGAAR_ID) AND
     (mangaSiteID <> MEINMANGA_ID) AND
     (mangaSiteID <> PECINTAKOMIK_ID) then
    HTTP.UserAgent:= 'curl/7.21.0 (i686-pc-linux-gnu) libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.3.4 libidn/1.18';

  if (mangaSiteID >= 0) AND
     (mangaSiteID <= High(WebsiteRoots)) AND
     (mangaSiteID <> MEINMANGA_ID) AND
     (mangaSiteID <> PECINTAKOMIK_ID) then
    HTTP.Headers.Insert(0, 'Referer: '+WebsiteRoots[mangaSiteID,1]);

  {$IFDEF DOWNLOADER}
  if (AOwner <> nil) AND
     (AOwner is TDownloadThread) then
    if TDownloadThread(AOwner).IsTerminateCalled then
      goto jmpTerminate;
  {$ENDIF}
  while (NOT HTTP.HTTPMethod('GET', URL)) OR
        (HTTP.ResultCode >= 500) OR
        (HTTP.ResultCode = 403) do
  begin
    {$IFDEF DOWNLOADER}
    if (AOwner <> nil) AND
       (AOwner is TDownloadThread) then
      if TDownloadThread(AOwner).IsTerminateCalled then
        goto jmpTerminate;
    {$ENDIF}
    if Reconnect <> 0 then
    begin
      if Reconnect <= counter then
      begin
        if AHTTP = nil then
          HTTP.Free;
        exit;
      end;
      Inc(counter);
    end;
    HTTP.Clear;
    if AHTTP <> nil then
      HTTP.Headers.Text:= HTTPHeader.Text;
    Sleep(500);
  end;

  while (HTTP.ResultCode = 302) OR (HTTP.ResultCode = 301) do
  begin
    {$IFDEF DOWNLOADER}
    if (AOwner <> nil) AND
       (AOwner is TDownloadThread) then
      if TDownloadThread(AOwner).IsTerminateCalled then
        goto jmpTerminate;
    {$ENDIF}
    URL:= CheckRedirect(HTTP);
    HTTP.Clear;
    if AHTTP <> nil then
      HTTP.Headers.Text:= HTTPHeader.Text;
    HTTP.RangeStart:= 0;
    if (mangaSiteID >= 0) AND (mangaSiteID <= High(WebsiteRoots)) then
      HTTP.Headers.Insert(0, 'Referer: '+WebsiteRoots[mangaSiteID,1]);
    while (NOT HTTP.HTTPMethod('GET', URL)) OR
          (HTTP.ResultCode >= 500) OR
          (HTTP.ResultCode = 403) do
    begin
      {$IFDEF DOWNLOADER}
      if (AOwner <> nil) AND
         (AOwner is TDownloadThread) then
        if TDownloadThread(AOwner).IsTerminateCalled then
          goto jmpTerminate;
      {$ENDIF}
      if Reconnect <> 0 then
      begin
        if Reconnect <= counter then
        begin
          if AHTTP = nil then
            HTTP.Free;
          exit;
        end;
        Inc(counter);
      end;
      HTTP.Clear;
      if AHTTP <> nil then
        HTTP.Headers.Text:= HTTPHeader.Text;
      Sleep(500);
    end;
  end;
  HTTP.Document.Seek(0, soBeginning);
  HTTP.Document.Read(header[0], 4);
  if (header[0] = JPG_HEADER[0]) AND
     (header[1] = JPG_HEADER[1]) AND
     (header[2] = JPG_HEADER[2]) then
    ext:= '.jpg'
  else
  if (header[0] = PNG_HEADER[0]) AND
     (header[1] = PNG_HEADER[1]) AND
     (header[2] = PNG_HEADER[2]) then
    ext:= '.png'
  else
  if (header[0] = GIF_HEADER[0]) AND
     (header[1] = GIF_HEADER[1]) AND
     (header[2] = GIF_HEADER[2]) then
    ext:= '.gif'
  else
    ext:= '';
  if ext <> '' then
  begin
    // If an error occured, verify the path and redo the job.
    // If the error still persists, break the loop.
    repeat
      try
        {$IFDEF DOWNLOADER}
        if (AOwner <> nil) AND
           (AOwner is TDownloadThread) then
          if TDownloadThread(AOwner).IsTerminateCalled then
            break;
        {$ENDIF}
        fstream:= TFileStreamUTF8.Create(Path+'/'+name+prefix+ext, fmCreate);
        HTTP.Document.SaveToStream(fstream);
        fstream.Free;
        break;
      except
        on E: Exception do
        begin
          {$IFDEF DOWNLOADER}
          if (AOwner <> nil) AND
             (AOwner is TDownloadThread) then
            if TDownloadThread(AOwner).IsTerminateCalled then
              break;
          {$ENDIF}
          // TODO: Write this error to log.
          if NOT retryToSave then
          begin
            CheckPath(Path);
            retryToSave:= TRUE;
          end
          else
            break;
        end;
      end;
    until FALSE;
  end
  else
  begin
    // TODO: A logging system should be applied in order to log this "error".
  end;
jmpTerminate:
  if AHTTP = nil then
    HTTP.Free
  else
    HTTPHeader.Free;
  Result:= TRUE;
end;

function  SaveImage(const mangaSiteID: Integer; URL: String; const Path, name, prefix: String; const Reconnect: Cardinal): Boolean;
begin
  Result:= SaveImage(nil, nil, mangaSiteID, URL, Path, name, prefix, Reconnect);
end;

procedure QuickSortChapters(var chapterList, linkList: TStringList);
  procedure QSort(L, R: Cardinal);
  var i, j: Cardinal;
         X: String;
  begin
    X:= chapterList.Strings[(L+R) div 2];
    i:= L;
    j:= R;
    while i<=j do
    begin
      while StrComp(PChar(chapterList.Strings[i]), PChar(X))<0 do Inc(i);
      while StrComp(PChar(chapterList.Strings[j]), PChar(X))>0 do Dec(j);
      if i<=j then
      begin
        chapterList.Exchange(i, j);
        linkList   .Exchange(i, j);
        Inc(i);
        if j > 0 then
          Dec(j);
      end;
    end;
    if L < j then QSort(L, j);
    if i < R then QSort(i, R);
  end;

var
  i: Cardinal;

begin
  if chapterList.Count <= 2 then
    exit;
  QSort(0, chapterList.Count-1);
end;

procedure QuickSortData(var merge: TStringList);
var
  names, output: TStringList;

  procedure QSort(L, R: Cardinal);
  var i, j: Cardinal;
         X: String;
  begin
    X:= names.Strings[(L+R) div 2];
    i:= L;
    j:= R;
    while i<=j do
    begin
      while StrComp(PChar(names.Strings[i]), PChar(X))<0 do Inc(i);
      while StrComp(PChar(names.Strings[j]), PChar(X))>0 do Dec(j);
      if i<=j then
      begin
        names.Exchange(i, j);
        merge.Exchange(i, j);
        Inc(i);
        if j > 0 then
          Dec(j);
      end;
    end;
    if L < j then QSort(L, j);
    if i < R then QSort(i, R);
  end;

var
  i: Cardinal;

begin
  names := TStringList.Create;
  output:= TStringList.Create;
  for i:= 0 to merge.Count-1 do
  begin
    output.Clear;
    GetParams(output, merge.Strings[i]);
    names.Add(output.Strings[DATA_PARAM_NAME]);
  end;
  QSort(0, names.Count-1);
  output.Free;
  names.Free;
end;

// this procedure is similar to QuickSortData except it sort the siteID as well
procedure QuickSortDataWithWebID(var merge: TStringList; const webIDList: TByteList);
var
  names, output: TStringList;

  procedure QSort(L, R: Cardinal);
  var i, j: Cardinal;
         X: String;
  begin
    X:= names.Strings[(L+R) div 2];
    i:= L;
    j:= R;
    while i<=j do
    begin
      while StrComp(PChar(names.Strings[i]), PChar(X))<0 do Inc(i);
      while StrComp(PChar(names.Strings[j]), PChar(X))>0 do Dec(j);
      if i<=j then
      begin
        names.Exchange(i, j);
        merge.Exchange(i, j);
        webIDList.Exchange(i, j);
        Inc(i);
        if j > 0 then
          Dec(j);
      end;
    end;
    if L < j then QSort(L, j);
    if i < R then QSort(i, R);
  end;

var
  i: Cardinal;

begin
  names := TStringList.Create;
  output:= TStringList.Create;
  for i:= 0 to merge.Count-1 do
  begin
    output.Clear;
    GetParams(output, merge.Strings[i]);
    names.Add(output.Strings[DATA_PARAM_NAME]);
  end;
  QSort(0, names.Count-1);
  output.Free;
  names.Free;
end;

function  DateToJDN(const year, month, day: Word): LongInt;
var
  a, y, m: Single;
begin
  a:= (14 - month) / 12;
  y:= year + 4800 - a;
  m:= month + 12*a - 3;
  Result:= Round(day + (153*m+2)/5 + 365*y + y/4 - y/100 + y/400 - 32045);
end;

function  GetCurrentJDN: LongInt;
var
  day, month, year: Word;
begin
  DecodeDate(Now, year, month, day);
  Result:= DateToJDN(year, month, day);
end;

procedure TransferMangaInfo(var dest: TMangaInfo; const source: TMangaInfo);
var
  i: Cardinal;
begin
  dest.url        := source.url;
  dest.title      := source.title;
  dest.link       := source.link;
  dest.website    := source.website;
  dest.coverLink  := source.coverLink;
  dest.authors    := source.authors;
  dest.artists    := source.artists;
  dest.genres     := source.genres;
  dest.status     := source.status;
  dest.summary    := source.summary;
  dest.numChapter := source.numChapter;
  dest.chapterName .Clear;
  dest.chapterLinks.Clear;
  if source.chapterLinks.Count <> 0 then
    for i:= 0 to source.chapterLinks.Count-1 do
    begin
      dest.chapterName .Add(source.chapterName .Strings[i]);
      dest.chapterLinks.Add(source.chapterLinks.Strings[i]);
    end;
end;

constructor TDownloadPageThread.Create(CreateSuspended: Boolean);
begin
  isDone:= FALSE;
  FreeOnTerminate:= TRUE;
  inherited Create(CreateSuspended);
end;

procedure   TDownloadPageThread.Execute;
begin
  isDone   := TRUE;
  Suspend;
end;

// OS dependent
function    fmdGetTempPath: String;
var
  l: Cardinal;
begin
{$IFDEF WINDOWS}
  SetLength(Result, 4096);
  l:= GetTempPath(4096, PChar(Result));
  SetLength(Result, l+1);
{$ENDIF}
{$IFDEF UNIX}
  Result:= GetTempDir(FALSE);
{$ENDIF}
end;

function  fmdGetTickCount: Cardinal;
begin
 {$IFDEF WINDOWS}
  Result:= GetTickCount;
 {$ENDIF}
end;

procedure fmdPowerOff;
const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
var
  Process: TProcess;
begin
{$IFDEF WINDOWS}
  if IsPwrShutdownAllowed then
  begin
    NTSetPrivilege(SE_SHUTDOWN_NAME, True);
    ExitWindowsEx(EWX_POWEROFF OR EWX_FORCE, 0);
  end;
{$ENDIF}
{$IFDEF UNIX}
  // This process require admin rights in order to execute
  Process:= TProcessUTF8.Create(nil);
  Process.CommandLine:= 'poweroff';
  Process.Execute;
  Process.Free;
{$ENDIF}
end;

procedure fmdHibernate;
begin
  {$IFDEF WINDOWS}
  SetSuspendState(TRUE, FALSE, FALSE);
  {$ENDIF}
end;

function  fmdRunAsAdmin(path, params: String; isPersistent: Boolean): Boolean;
{$IFDEF WINDOWS}
var
  sei: TShellExecuteInfoA;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.Wnd    := 0;
  sei.fMask  := SEE_MASK_FLAG_DDEWAIT OR SEE_MASK_FLAG_NO_UI;
  if isPersistent then
    sei.fMask:= sei.fMask OR SEE_MASK_NOCLOSEPROCESS;
  sei.lpVerb := 'runas';
  sei.lpFile := PAnsiChar(path);
  sei.lpParameters := PAnsiChar(params);
  sei.nShow  := SW_SHOWNORMAL;
  Result     := ShellExecuteExA(@sei);
  if isPersistent then
    WaitForSingleObject(sei.hProcess, INFINITE);
end;
{$ELSE}
var
  Process: TProcess;
begin
  Process:= TProcessUTF8.Create(nil);
  Process.CommandLine:= path + ' ' + params;
  Process.Execute;
  Process.Free;
end;
{$ENDIF}

end.

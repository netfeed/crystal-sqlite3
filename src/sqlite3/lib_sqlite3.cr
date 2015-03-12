@[Link("sqlite3")]
lib LibSQLite3
  type SQLite3 = Void*
  type Statement = Void*

  enum Flag
    READONLY         = 0x00000001  # Ok for sqlite3_open_v2()
    READWRITE        = 0x00000002  # Ok for sqlite3_open_v2()
    CREATE           = 0x00000004  # Ok for sqlite3_open_v2()
    DELETEONCLOSE    = 0x00000008  # VFS only
    EXCLUSIVE        = 0x00000010  # VFS only
    AUTOPROXY        = 0x00000020  # VFS only
    URI              = 0x00000040  # Ok for sqlite3_open_v2()
    MEMORY           = 0x00000080  # Ok for sqlite3_open_v2()
    MAIN_DB          = 0x00000100  # VFS only
    TEMP_DB          = 0x00000200  # VFS only
    TRANSIENT_DB     = 0x00000400  # VFS only
    MAIN_JOURNAL     = 0x00000800  # VFS only
    TEMP_JOURNAL     = 0x00001000  # VFS only
    SUBJOURNAL       = 0x00002000  # VFS only
    MASTER_JOURNAL   = 0x00004000  # VFS only
    NOMUTEX          = 0x00008000  # Ok for sqlite3_open_v2()
    FULLMUTEX        = 0x00010000  # Ok for sqlite3_open_v2()
    SHAREDCACHE      = 0x00020000  # Ok for sqlite3_open_v2()
    PRIVATECACHE     = 0x00040000  # Ok for sqlite3_open_v2()
    WAL              = 0x00080000  # VFS only
  end

  enum Code
    ROW = 100
    DONE = 101
  end

  enum Type
    INTEGER = 1
    FLOAT = 2
    BLOB = 4
    NULL = 5
    TEXT = 3
  end

  alias Callback = (Void*, Int32, UInt8**, UInt8**) -> Int32

  fun open = sqlite3_open_v2(filename : UInt8*, db : SQLite3*) : Int32
  fun open_v2 = sqlite3_open_v2(filename : UInt8*, db : SQLite3*, flags: Flag, zVfs : UInt8*) : Int32

  fun errcode = sqlite3_errcode(SQLite3) : Int32
  fun errmsg = sqlite3_errmsg(SQLite3) : UInt8*

  fun prepare_v2 = sqlite3_prepare_v2(db : SQLite3, zSql : UInt8*, nByte : Int32, ppStmt : Statement*, pzTail : UInt8**) : Int32
  fun step = sqlite3_step(stmt : Statement) : Int32
  fun column_count = sqlite3_column_count(stmt : Statement) : Int32
  fun column_type = sqlite3_column_type(stmt : Statement, iCol : Int32) : Int32
  fun column_int64 = sqlite3_column_int64(stmt : Statement, iCol : Int32) : Int64
  fun column_double = sqlite3_column_double(stmt : Statement, iCol : Int32) : Float64
  fun column_text = sqlite3_column_text(stmt : Statement, iCol : Int32) : UInt8*
  fun column_bytes = sqlite3_column_bytes(stmt : Statement, iCol : Int32) : Int32
  fun column_blob = sqlite3_column_blob(stmt : Statement, iCol : Int32) : UInt8*

  fun bind_int = sqlite3_bind_int(stmt : Statement, idx : Int32, value : Int32) : Int32
  fun bind_int64 = sqlite3_bind_int64(stmt : Statement, idx : Int32, value : Int64) : Int32
  fun bind_text = sqlite3_bind_text(stmt : Statement, idx : Int32, value : UInt8*, bytes : Int32, destructor : Void* ->) : Int32
  fun bind_blob = sqlite3_bind_text(stmt : Statement, idx : Int32, value : UInt8*, bytes : Int32, destructor : Void* ->) : Int32
  fun bind_null = sqlite3_bind_null(stmt : Statement, idx : Int32) : Int32
  fun bind_double = sqlite3_bind_double(stmt : Statement, idx : Int32, value : Float64) : Int32

  fun bind_parameter_index = sqlite3_bind_parameter_index(stmt : Statement, name : UInt8*) : Int32
  fun reset = sqlite3_reset(stmt : Statement) : Int32
  fun column_name = sqlite3_column_name(stmt : Statement, idx : Int32) : UInt8*
  fun last_insert_rowid = sqlite3_last_insert_rowid(db : SQLite3) : Int64

  fun finalize = sqlite3_finalize(stmt : Statement) : Int32
  fun close_v2 = sqlite3_close_v2(SQLite3) : Int32
end

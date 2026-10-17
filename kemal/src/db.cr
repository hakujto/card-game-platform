require "sqlite3"
require "db"

module AppDB
  @@db : DB::Database? = nil

  def self.db : DB::Database
    @@db ||= DB.open(ENV["DATABASE_URL"]? || "sqlite3://./app.db")
  end

  def self.exec(query : String, *args)
    db.exec(query, *args)
  end

  def self.exec(query : String, args : Array)
    db.exec(query, args: args)
  end

  def self.query_all(query : String, *args, as type : T.class) : Array(T) forall T
    db.query_all(query, *args, as: type)
  end

  def self.query_one?(query : String, *args, as type : T.class) : T? forall T
    db.query_one?(query, *args, as: type)
  end

  def self.query_one(query : String, *args, as type : T.class) : T forall T
    db.query_one(query, *args, as: type)
  end

  def self.last_insert_id : Int64
    db.query_one("SELECT last_insert_rowid()", as: Int64)
  end

  def self.close
    @@db.try(&.close)
    @@db = nil
  end
end

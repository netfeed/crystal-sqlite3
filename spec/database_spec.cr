require "./spec_helper"

DB_FILENAME = "./test.db"

private def with_db
  yield Database.new DB_FILENAME
ensure
  File.delete(DB_FILENAME)
end

describe Database do
  it "opens a database" do
    with_db do |db|
      File.exists?(DB_FILENAME).should be_true
    end
  end

  [nil, 1, 1_i64, "hello", 1.5, 1.5_f32].each do |value|
    it "executes and select #{value}" do
      with_db(&.execute("select #{value ? value.inspect : "null"}")).should eq([[value]])
    end

    it "executes with bind #{value}" do
      with_db(&.execute(%(select ?), value)).should eq([[value]])
    end

    it "executes with bind #{value} as array" do
      with_db(&.execute(%(select ?), [value])).should eq([[value]])
    end
  end

  it "executes and selects blob" do
    rows = with_db(&.execute(%(select X'53514C697465')))
    row = rows[0]
    cell = row[0] as Slice(UInt8)
    cell.to_a.should eq([0x53, 0x51, 0x4C, 0x69, 0x74, 0x65])
  end

  it "executes with named bind using symbol" do
    with_db(&.execute(%(select :value), {value: "hello"})).should eq([["hello"]])
  end

  it "executes with named bind using string" do
    with_db(&.execute(%(select :value), {"value": "hello"})).should eq([["hello"]])
  end

  it "executes with bind blob" do
    ary = UInt8[0x53, 0x51, 0x4C, 0x69, 0x74, 0x65]
    rows = with_db(&.execute(%(select cast(? as BLOB)), Slice.new(ary.buffer, ary.length)))
    row = rows[0]
    cell = row[0] as Slice(UInt8)
    cell.to_a.should eq(ary)
  end

  it "gets column names" do
    Database.new(":memory:") do |db|
      db.execute "create table person (name string, age integer)"
      stmt = db.prepare("select * from person")
      stmt.columns.should eq(%w(name age))
      stmt.close
    end
  end

  it "gets column types" do
    Database.new(":memory:") do |db|
      db.execute "create table person (name string, age integer)"
      db.execute %(insert into person values ("foo", 10))
      stmt = db.prepare("select * from person")
      stmt.execute
      stmt.step
      stmt.types.should eq([Type::TEXT, Type::INTEGER])
      stmt.close
    end
  end

  it "gets column by name" do
    Database.new(":memory:") do |db|
      db.execute "create table person (name string, age integer)"
      db.execute %(insert into person values ("foo", 10))
      db.query("select * from person") do |result_set|
        result_set.next.should be_true
        result_set["name"].should eq("foo")
        result_set["age"].should eq(10)
        expect_raises { result_set["lala"] }
      end
    end
  end

  it "gets last insert row id" do
    Database.new(":memory:") do |db|
      db.execute "create table person (name string, age integer)"

      db.last_insert_row_id.should eq(0)
      db.execute %(insert into person values ("foo", 10))
      db.last_insert_row_id.should eq(1)
    end
  end

  it "quotes" do
    db = Database.new(":memory:")
    db.quote("'hello'").should eq("''hello''")
  end

  it "gets first row" do
    with_db(&.get_first_row(%(select 1))).should eq([1])
  end


  it "gets first value" do
    with_db(&.get_first_value(%(select 1))).should eq(1)
  end
end

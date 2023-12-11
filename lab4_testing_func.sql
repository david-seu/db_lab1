create or alter procedure add_to_tables (@table_name varchar(50)) as
    if @table_name in (select Name from Tables) begin
        print 'Table already present in Tables'
        return
    end
    if @table_name not in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES) begin
        print 'Table not present in the database'
        return
    end
    insert into Tables (Name) values (@table_name)


create or alter procedure add_to_views (@view_name varchar(50)) as
    if @view_name in (select Name from Views) begin
        print 'View already present in Views'
        return
    end
    if @view_name not in (select TABLE_NAME from INFORMATION_SCHEMA.VIEWS) begin
        print 'View not present in the database'
        return
    end
    insert into Views (Name) values (@view_name)

create or alter procedure add_to_tests (@test_name varchar(50)) as
    if @test_name in (select Name from Tests) begin
        print 'Test already present in Tests'
    end
    insert into Tests (Name) values (@test_name)

create or alter procedure connect_table_to_test (@table_name varchar(50), @test_name varchar(50), @rows int, @pos int) as
    if @table_name not in (select Name from Tables) begin
        print 'Table not present in Tables'
        return
    end
    if @test_name not in (select  Name from Tests) begin
        print 'Test not present in Tests'
        return
    end

    if exists(
        select *
        from TestTables t1 join Tests t2 on t1.TestID = t2.TestID
        where T2.Name=@test_name and Position=@pos
    ) begin
        print 'Position provided conflicts with previous positions'
        return
    end
    insert into TestTables (TestID, TableID, NoOfRows, Position) values (
        (select Tests.TestID from Tests where Name=@test_name),
        (select Tables.TableID from Tables where Name=@table_name),
        @rows,
        @pos)


create or alter procedure connect_view_to_test (@view_name varchar(50), @test_name varchar(50)) as
    if @view_name not in (select Name from Views) begin
        print 'View not present in Views'
    end
    if @test_name not in (select Name from Tests) begin
        print 'Test not present in Tests'
    end
    insert into TestViews (TestID, ViewID) values (
        (select TestID from Tests where Name = @test_name),
        (select ViewID from Views where Name = @view_name)
                                                  )


create or alter procedure run_test(@test_name varchar(50)) as
    if @test_name not in (select Name from Tests) begin
        print 'Test not in Tests'
        return
    end
    declare @command varchar(100)
    declare @test_start_time datetime2
    declare @start_time datetime2
    declare @end_time datetime2
    declare @table varchar(50)
    declare @rows int
    declare @pos int
    declare @view varchar(50)
    declare @test_id int
    select @test_id=TestID from Tests where Name=@test_name
    declare @test_run_id int
    set @test_run_id = (select max(TestRunID)+ 1 from TestRuns)
    if @test_run_id is null
        set @test_run_id = 0
    declare table_cursor cursor scroll for
        select t1.name, t2.NoOfRows, t2.Position
        from Tables t1 join TestTables t2 on t1.TableID = t2.TableID
        where t2.TestID = @test_id
        order by T2.Position
    declare view_cursor cursor for
        select v.name
        from Views v join TestViews tv on v.ViewID = tv.ViewID
        where tv.TestID = @test_id

    set @test_start_time = sysdatetime()
    open table_cursor
    fetch last from table_cursor into @table, @rows, @pos
    while @@FETCH_STATUS = 0 begin
        exec ('delete from ' + @table)
        fetch prior from table_cursor into @table, @rows, @pos
    end
    close table_cursor

    open table_cursor
    set IDENTITY_INSERT TestRuns ON
    insert into TestRuns (TestRunID, Description, StartAt) values (@test_run_id, 'Test results for: ' + @test_name, @test_start_time)
    set IDENTITY_INSERT TestRuns OFF
    fetch table_cursor into @table, @rows, @pos
    while @@FETCH_STATUS = 0 begin
        set @command = 'populate_table_' + @table
        if @command not in (select ROUTINE_NAME from INFORMATION_SCHEMA.ROUTINES) begin
            print @command + 'does not exist'
            return
        end
        set @start_time = sysdatetime()
        exec @command @rows
        set @end_time = sysdatetime()
        insert into TestRunTables (TESTRUNID, TABLEID, STARTAT, ENDAT) values (@test_run_id, (select TableID from Tables where Name=@table), @start_time, @end_time)
        fetch table_cursor into @table, @rows, @pos
    end
    close table_cursor
    deallocate table_cursor

    open view_cursor
    fetch view_cursor into @view
    while @@FETCH_STATUS = 0 begin
        set @command = 'select * from ' + @view
        set @start_time = sysdatetime()
        exec (@command)
        set @end_time = sysdatetime()
        insert into TestRunViews (testrunid, viewid, startat, endat) values (@test_run_id, (select ViewID from Views where Name=@view), @start_time, @end_time)
        fetch view_cursor into @view
    end
    close view_cursor
    deallocate view_cursor

    update TestRuns
    set EndAt=sysdatetime()
    where TestRunID = @test_run_id

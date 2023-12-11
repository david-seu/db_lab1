exec add_to_tables 'videos'

create or alter view get_format_groups as
    select format, count(*) as number_of_videos
    from videos
    group by format

exec add_to_views 'get_format_groups'
exec add_to_tests 'test1'
exec connect_table_to_test 'videos', 'test1', 1000, 1
exec connect_view_to_test 'get_format_groups', 'test1'

create or alter procedure populate_table_videos (@rows int) as
    while @rows > 0 begin
        insert into videos (video_id, title, type, description, size, creator, duration, format) values
                                                                                                     (@rows, ('Testing1'),'Type', 'Testing', floor(rand()*1000), 'creator', sysdatetime(), (select top 1 name
                                                                                                                                                                                                      from formats
                                                                                                                                                                                                      order by newid()
                                                                                                                                                                                                      ))
        set @rows = @rows -1
    end


alter table videos_notes
drop constraint fk_videos_notes_videos

alter table videos_notes
add constraint fk_videos_notes_videos
foreign key (video_id)
references videos(video_id)
on delete cascade

insert into formats (format_id, name) values (1,'MP4'),(2,'MOV'),(3,'AVI'),(4,'WMV'),(5,'H.265')

execute run_test 'test1'

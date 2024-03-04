exec add_to_tables 'authors';
exec add_to_tables 'authors_notes';
exec add_to_tables 'notes';
exec add_to_tables 'resources';
exec add_to_tables 'projects';
exec add_to_tables 'areas';

create or alter view get_top_10_paid_authors_with_notes as
    select distinct top 10 full_name, username, email, salary
    from authors join authors_notes on authors.author_id = authors_notes.author_id
    where salary > 3000
    order by salary;

create or alter view get_avg_salary_authors_grouped_project as
    select avg(salary) as avg_salary, authors.project_id
    from  projects join authors on projects.project_id = authors.project_id
    group by authors.project_id;

exec add_to_views 'get_top_10_paid_authors_with_notes';
exec add_to_views 'get_avg_salary_authors_grouped_project';
exec add_to_tests 'test2';
exec connect_table_to_test 'areas', 'test2', 3, 1;
exec connect_table_to_test 'projects', 'test2', 6, 2;
exec connect_table_to_test 'resources', 'test2', 10, 3;
exec connect_table_to_test 'notes', 'test2', 500, 4;
exec connect_table_to_test 'authors', 'test2', 50, 5;
exec connect_table_to_test 'authors_notes', 'test2', 500, 6;
exec connect_view_to_test 'get_top_10_paid_authors_with_notes', 'test2';
exec connect_view_to_test 'get_avg_salary_authors_grouped_project', 'test2';

create or alter procedure populate_table_areas(@rows int) as
    while @rows > 0 begin
        declare @rows_string varchar(max)
        set @rows_string = cast(@rows as varchar(50))
        insert into areas (area_id, name, archive, description) values
                        (@rows, 'project_title_'+@rows_string, 0, 'project_description_'+@rows_string)
        set @rows = @rows - 1
    end;

create or alter procedure populate_table_projects(@rows int) as
    while @rows > 0 begin
        declare @rows_string varchar(max)
        set @rows_string = cast(@rows as varchar(50))
        insert into projects (project_id, title, archive, area_id, status, description) values
                            (@rows,'project_title_'+@rows_string, 0, (select top 1 area_id from areas order by newid()), round(rand(),0) , 'project_description_'+@rows_string)
        set @rows = @rows - 1
    end;


create or alter procedure populate_table_resources(@rows int) as
    while @rows > 0 begin
        declare @rows_string varchar(max)
        set @rows_string = cast(@rows as varchar(50))
        insert into resources (resource_id, name, archive, description, project_id) values
                             (@rows, 'resource_name_'+@rows_string, 0, 'resource_description_'+@rows_string, (select top 1 project_id from projects order by newid()))
        set @rows = @rows - 1
    end;

create or alter procedure populate_table_authors (@rows int) as
    while @rows > 0 begin
        declare @rows_string varchar(max)
        set @rows_string = cast(@rows as varchar(50))
        insert into authors (author_id, full_name, username, email, role, salary, password, project_id, bio, cnp) values
                            (@rows, 'name' + @rows_string , 'username'+ @rows_string, @rows_string+'@gmail.com', 'role', floor(rand() * (10000 - 1001 + 1) + 1001), 'password', floor(rand()*5+1), 'bio', @rows+100)
        set @rows = @rows - 1
    end;

create or alter procedure populate_table_notes (@rows int) as
    while @rows > 0 begin
        declare @rows_string varchar(max)
        set @rows_string = cast(@rows as varchar(50))
        insert into notes (note_id, title, tags, archive, creation_date, resource_id, content, size) values
                            (@rows, 'note_title'+@rows_string, 'tags', 0, getdate(), (select top 1 resource_id from resources order by newid()), 'resource_content_'+@rows_string, floor(rand() * (9900) + 100))
        set @rows = @rows - 1
    end;

create or alter procedure populate_table_authors_notes (@rows int) as
    while @rows > 0 begin
        insert into authors_notes (note_id, author_id) values (@rows, (select top 1 author_id from authors order by newid()))
        set @rows = @rows - 1
    end;

exec run_test 'test2'


alter table authors
drop constraint fk_project_id

alter table authors
add constraint fk_project_id
foreign key (project_id)
references projects(project_id)
on delete cascade

alter table notes
drop constraint fk_resource_id

alter table notes
add constraint fk_resource_id
foreign key (resource_id)
references resources(resource_id)
on delete cascade

alter table resources
drop constraint fk_projects

alter table resources
add constraint fk_projects
foreign key (project_id)
references projects(project_id)
on delete cascade

alter table projects
drop constraint fk_area

alter table projects
add constraint fk_area
foreign key (area_id)
references areas(area_id)
on delete cascade

alter table tasks
drop constraint fk_author_id

alter table tasks
add constraint fk_author_id
foreign key (author_id)
references authors(author_id)
on delete cascade

alter table tasks
drop constraint fk_project

alter table tasks
add constraint fk_project
foreign key (project_id)
references projects(project_id)

alter table videos_notes
drop constraint fk_videos_notes_notes

alter table videos_notes
add constraint fk_videos_notes_notes
foreign key (note_id)
references notes(note_id)
on delete cascade

alter table audios_notes
drop constraint fk_audios_notes_notes

alter table audios_notes
add constraint fk_audios_notes_notes
foreign key (note_id)
references notes(note_id)
on delete cascade

alter table images_notes
drop constraint fk_images_notes_notes

alter table images_notes
add constraint fk_images_notes_notes
foreign key (note_id)
references notes(note_id)
on delete cascade

alter table webclips_notes
drop constraint fk_webclips_notes_notes

alter table webclips_notes
add constraint fk_webclips_notes_notes
foreign key (note_id)
references notes(note_id)
on delete cascade







delete from TestTables
where Position = 6

exec run_test 'test2'

select *
from notes
where note_id = 5
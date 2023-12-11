create procedure set_salary_from_authors_bigint as
    alter table authors alter column salary bigint;

create procedure set_salary_from_authors_int as
    alter table authors alter column salary int;

create procedure add_description_to_tasks as
    alter table tasks add description varchar(max);

create procedure remove_description_from_tasks as
    alter table tasks drop column description;


create procedure add_default_to_salary_from_authors as
    alter table authors add constraint default1000 default(1000) for salary;

create procedure remove_default_from_salary_from_authors as
    alter table authors drop constraint default1000;

create procedure add_project_managers as
    create table project_managers(
        project_manager_id int not null,
        constraint pk_project_manager primary key (project_manager_id),
        salary int default 4000,
        full_name varchar(50) not null,
        username  varchar(50) not null,
        email     varchar(30) not null,
        password  varchar(100) not null,
        project_id int not null,
    );

create procedure drop_project_managers as
    drop table project_managers;


create procedure add_username_project_id_primary_key_project_managers as
    alter table project_managers
            drop constraint pk_project_managers
    alter table project_managers
            add constraint pk_project_managers primary key (username,project_id);

create procedure remove_username_project_id_primary_key_project_managers as
    alter table project_managers
            drop constraint pk_project_managers
    alter table project_managers
            add constraint pk_project_managers primary key (project_manager_id);

create procedure add_candidate_key_notes as
    alter table notes
            add constraint notes_candidate_key_1 unique (title, tags, creation_date);

create procedure remove_candidate_key_notes as
    alter table notes
            drop constraint notes_candidate_key_1;


create procedure add_foreign_key_project_manager_to_project as
    alter table project_managers
        add constraint fk_project_id foreign key(project_id) references projects(project_id);

create procedure remove_foreign_key_project_manager_to_project as
    alter table project_managers
        drop constraint fk_project_id;


create table version_table (
    version int
);

insert into version_table values (1);

create table procedures_table (
    from_version int,
    to_version int,
    constraint pk_procedures_table primary key (from_version,to_version),
    name_proc varchar(max)
);

insert into procedures_table values (1,2, 'set_salary_from_authors_bigint');
insert into procedures_table values (2,1, 'set_salary_from_authors_int');
insert into procedures_table values (2,3, 'add_description_to_tasks');
insert into procedures_table values (3,2, 'remove_description_from_tasks');
insert into procedures_table values (3,4, 'add_default_to_salary_from_authors');
insert into procedures_table values (4,3, 'remove_default_from_salary_from_authors');
insert into procedures_table values (4,5, 'add_project_managers');
insert into procedures_table values (5,4, 'drop_project_managers');
insert into procedures_table values (5,6, 'add_username_project_id_primary_key_project_managers');
insert into procedures_table values (6,5, 'remove_username_project_id_primary_key_project_managers');
insert into procedures_table values (6,7, 'add_candidate_key_notes');
insert into procedures_table values (7,6, 'remove_candidate_key_notes');
insert into procedures_table values (7,8, 'add_foreign_key_project_manager_to_project');
insert into procedures_table values (8,7, 'remove_foreign_key_project_manager_to_project');


create procedure go_to_version(@new_version int) as
    declare @curr int
    declare @var varchar(max)
    select @curr=version from version_table

    if @new_version > (select max(to_version) from procedures_table)
        raiserror ('Bad version',10,1)

    while @curr > @new_version begin
        select @var=name_proc from procedures_table where from_version=@curr and to_version=@curr-1
        exec (@var)
        set @curr=@curr-1
    end

    while @curr < @new_version begin
        select @var=name_proc from procedures_table where from_version=@curr and to_version=@curr+1
        exec (@var)
        set @curr=@curr+1
    end
    update version_table set version=@new_version;

execute go_to_version 1

drop table version_table
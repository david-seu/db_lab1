drop index idx_ncl_cnp on authors
drop index idx_ncl_salary on authors
go

create nonclustered index idx_ncl_cnp
    on authors(cnp)

create nonclustered index idx_ncl_salary
    on authors(salary)
go


exec populate_table_authors 10000

delete from authors



-- clustered index scan
select *
from authors
where salary > 3000

--clustered index seek
select author_id, username
from authors
where author_id = 5

--nonclustered index seek
select salary
from authors
where salary > 100


--nonclustered inded scan
select salary
from authors
order by salary


--key lookup
select salary
from authors
where cnp = 1000

exec sp_helpindex authors

--b
select size
from notes
where size = 250

drop index idx_ncl_size on

go

create nonclustered index idx_ncl_size
    on notes(size)
go


--c
create or alter view get_high_salary_authors_with_notes as
    select a.author_id, a.username, a.salary
    from authors a join authors_notes an on a.author_id = an.author_id
    where a.salary > 2500

drop index idx_ncl_salary2 on authors
go

create nonclustered index idx_ncl_salary2
    on authors(salary)
    include(author_id, username)


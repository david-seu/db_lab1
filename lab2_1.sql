-- a. 2 queries with the union operation; use UNION [ALL] and OR;

select a.username, a.email, a.role, a.project_id, t.author_id
from authors a, tasks t
where (t.author_id = 16 and a.author_id = 15) or (a.author_id = 21 and t.author_id = 21);

select username, email, role, project_id
from authors
where project_id = 1
union
select username, email, role, project_id
from authors
where project_id = 2
order by project_id;

--b. 2 queries with the intersection operation; use INTERSECT and IN;


select distinct resource_id
from notes
where tags like '%UI/UX%'
intersect
select  resource_id
from notes
where tags like '%Design%';

select top 2 name, due
from tasks
where author_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);

--c. 2 queries with the difference operation; use EXCEPT and NOT IN;

select  distinct a.full_name, a.email, a.project_id, a.author_id
from authors a
where a.author_id in (
select a.author_id
from authors a, tasks t
where a.author_id = t.author_id
except
select a.author_id
from authors a, tasks t
where a.project_id = 1)
order by a.author_id;


select a.full_name, a.email, a.project_id, a.author_id
from authors a
where a.author_id not in (
select a.author_id
from authors a, tasks t
where a.author_id = t.author_id
except
select a.author_id
from authors a, tasks t
where a.project_id = 1)
order by a.author_id;

--d. 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator);
-- one query will join at least 3 tables, while another one will join at least two many-to-many relationships;


select *
from notes n inner join resources r
on n.resource_id = r.resource_id
inner join projects p on r.project_id = p.project_id;

select *
from tasks t right join authors a
on a.author_id = t.author_id;

select *
from notes n left join audios_notes an on n.note_id = an.note_id
left join audios a on a.audio_id = an.audio_id
left join videos_notes vn on n.note_id = vn.note_id
left join videos v on v.video_id = vn.video_id;

select *
from tasks t full join authors a on a.author_id = t.author_id;


--e. 2 queries with the IN operator and a subquery in the WHERE clause;
-- in at least one case, the subquery must include a subquery in its own WHERE clause;

select a.author_id, a.full_name, a.role
from authors a
where a.author_id in
(select a1.author_id
from authors a1, tasks t1
where a1.author_id = t1.author_id and t1.project_id = 1
union
select a2.author_id
from authors a2, tasks t2
where a2.author_id = t2.author_id and t2.project_id = 2);


select n.note_id, n.title, n.creation_date
from notes n
where n.note_id in
(select n.note_id
from notes n, audios_notes an
where n.note_id = an.note_id and an.audio_id in (
select an.audio_id
from audios a, audios_notes an
where a.audio_id = an.audio_id and a.format = 'MP3')
);

--f. 2 queries with the EXISTS operator and a subquery in the WHERE clause;

select a.author_id, a.username
from authors a
where exists 
(select 1
from tasks t
where t.author_id = a.author_id and t.due <= '2023-12-01');


select a.author_id, a.username
from authors a
where exists
(select 1
from tasks t
where t.author_id = a.author_id and t.status = 0 and t.project_id = 2);


--g. 2 queries with a subquery in the FROM clause;


select a.full_name, p.title as project_title, COUNT(an.note_id) AS total_notes
from authors as a
join projects as p on a.project_id = p.project_id
left join authors_notes as an on a.author_id = an.author_id
group by a.full_name, p.title
order by a.full_name, p.title;

select p.title as project_title, r.name as resource_name, r.description as resource_description
from projects as p
left join (
    select resource_id, name, description, project_id
    from resources
) as r on p.project_id = r.project_id
order by p.title, r.name;



--h. 4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause;
-- 2 of the latter will also have a subquery in the HAVING clause; use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;


select top 3 p.title as project_title, avg(a.salary) as avg_salary
from projects p
join authors a on a.project_id = p.project_id
group by p.title

select au.full_name as author_name, count(an.note_id) as total_notes_authored
from authors au
join authors_notes an on au.author_id = an.author_id
group by au.full_name
having count(an.note_id) > 1;

select p.title as project_title, sum(aud.size) as total_audio_size
from projects p
join resources r on p.project_id = r.project_id
join audios_notes an on r.resource_id = an.note_id
join audios aud on an.audio_id = aud.audio_id
group by p.title
having sum(aud.size) > (
        select avg(aud.size) from audios aud
    );

select top 5 p.title as project_title, avg(a.salary) as project_salary
from projects p
left join authors a on a.project_id = p.project_id
group by p.title
having avg(a.salary) >= (
    select avg(a.salary) from authors a
    )

--i. 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator);
    -- rewrite 2 of them with aggregation operators, and the other 2 with IN / [NOT] IN.


select full_name
from authors
where author_id = any (
    select author_id
    from authors_notes
);
select full_name
from authors
where author_id in (
    select author_id
    from authors_notes
);

select full_name
from authors
where project_id = any (
    select project_id
    from projects
    where status = 1
    )
select full_name
from authors
where project_id in (select project_id from projects where status = 1);

select full_name
from authors
where salary > all (select AVG(salary)
                    from authors);
select full_name
from authors
where salary > (select MAX(avg_salary)
               from (select AVG(salary) as avg_salary
                     from authors) as subquery);


select full_name
from authors
where salary = all (
    select MAX(salary)
    from authors
);
select full_name
from authors
where salary = (select MAX(salary) from authors);

--insert data into the tables

create table financialeducation
(
    fk1 int not null ,
    fk2 int not null,
    primary key (fk1, fk2),
    c1 varchar(100),
    c2 varchar(100),
    c3 int,
    c4 int,
    c5 varchar(2)
)

drop table financialeducation



insert into financialeducation (fk1, fk2, c1, c2, c3, c4, c5) values
(1,3,'Rich Dad poor Dad', 'Robert Kiyosaki', 100,5,'AE'),
(4,3,'The intelligent invsetor', 'Benjamin Graham', 80, 50, 'DS'),
(1,4,'The richest Man in Babylon', 'George S. Clason', 50, 10, 'CD'),
(3,4,'Stop acting rich','Thomas Stanley',30,30,'FG'),
(1,2,'The millionare next door','Thomas Stanley',20,10,'GF'),
(1,1,'Think and grow rich','Napolean Hill',40,20,'TH'),
(2,3,'The riches engineer','Abhishek Kumar',10,15,'YH'),
(3,2,'From The Rat Race to Financial Freedom','Manoj Arora',15,40,'RG'),
(4,4,'The Simplest Path to Wealth','J.L. Collins',20,15,'FN')
go

select c2, sum(c3) as totalc3, avg(c3) as avgc3
from financialeducation
where c3 <= 30 and c5 like '%G%'
group by c2
having sum(c4) > 30
go

select *
from
(select fk1,fk2,c3
 from financialeducation where fk1 >= financialeducation.fk2 and c3 > 20) r1
inner join
(select fk1, fk2, c4, c5 from financialeducation where c3 < 50 and c5 like '%H%') r2
on r1.fk1 = r2.fk1 and r1.fk2 = r2.fk2








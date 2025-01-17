-- Hold all media
SET search_path = catalogs,public,pg_catalog;

create table media (
       media_id uuid primary key default public.gen_random_uuid(),
       title text,
       contents bytea,
       mime_type text,
       thumbnail_png bytea,
       thumbnail2x_png bytea,
       ocr text,
       q tsvector
);

CREATE TRIGGER q_tsvectorupdate BEFORE INSERT OR UPDATE
ON media FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(q, 'public.wine', title, ocr);

CREATE TABLE catalogs (
    catalog_id uuid primary key default public.gen_random_uuid(),
    user_id text,
    title text,
    publisher text,
    year bigint,
    editable boolean default true,
    completed boolean default false,
    created_at timestamp without time zone default now(),
    updated_at timestamp without time zone default now()
);


CREATE FUNCTION q(catalogs) RETURNS tsvector AS $$
  SELECT q from catalogs.media where media_id=$1.catalog_id;
$$ LANGUAGE SQL IMMUTABLE;

-- (optional) add an index to speed up anticipated query
CREATE INDEX  catalogs_q_idx ON catalogs
  USING GIN (q(catalogs));

CREATE TABLE pages (
    page_id uuid primary key default public.gen_random_uuid(),
    catalog_id uuid references catalogs,
    page bigint,
    editable boolean default true,
    completed boolean default false,
    created_at timestamp without time zone default now()
);

CREATE FUNCTION q(pages) RETURNS tsvector AS $$
  SELECT q from catalogs.media where media_id=$1.page_id;
$$ LANGUAGE SQL IMMUTABLE;

create type catalog_page_count as (
total bigint,
finished bigint,
not_finished bigint);

CREATE FUNCTION page_count(catalogs) RETURNS catalog_page_count AS $$
   SELECT (count(*),
   sum(case when (p.editable is false or p.completed is true) then 1 else 0 end),
   sum(case when (p.editable is true and p.completed is false) then 1 else 0 end)
   )::catalog_page_count from pages p
   where catalog_id=$1.catalog_id
$$ LANGUAGE SQL IMMUTABLE;


CREATE FUNCTION pages(catalogs) RETURNS bigint AS $$
  SELECT count(*) from catalogs.pages p
  where catalog_id=$1.catalog_id
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION pages_finished(catalogs) RETURNS bigint AS $$
  SELECT count(*) from catalogs.pages p
  where
  catalog_id=$1.catalog_id and
  (p.editable is false or p.completed is true)
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION pages_not_finished(catalogs) RETURNS bigint AS $$
   SELECT count(*)
   from pages p
   where catalog_id=$1.catalog_id and
   (p.editable is true and p.completed is false);
$$ LANGUAGE SQL IMMUTABLE;


-- (optional) add an index to speed up anticipated query
CREATE INDEX  pages_q_idx ON pages
  USING GIN (q(pages));

CREATE TABLE mark_type (
 type text primary key
);
insert into mark_type
values ('wine'),('spirit');

CREATE TABLE wine_type (
 wine_type text primary key
);
insert into wine_type
values ('Still'),('Sparkling'),('Fortified');

CREATE TABLE wine_color (
 color text primary key
);
insert into wine_color
values ('Red'),('White'),('Rosé');

CREATE TABLE pending_mark_index (
   mark_id uuid primary key,
   page_id uuid,
   score float,
   created timestamp without time zone,
   updated timestamp without time zone
);
create index on pending_mark_index(page_id);
create index on pending_mark_index(score);
create index on pending_mark_index(created);
create index on pending_mark_index(updated);

create view pending_marks_by_page as 
with a as (
 select
 catalog_id,page_id,
 count(*) as mark_count,
 max(i.updated) as updated
 from pending_mark_index i join pages p using (page_id)
 group by catalog_id,page_id
)
select
 c.catalog_id,page_id,
 c.title,p.page,
 mark_count,updated
 from a join catalogs c using (catalog_id)
 join pages p using (page_id);
 



CREATE TABLE marks (
   mark_id uuid primary key,
   user_id text,
   page_id uuid not null,
   xy integer[2],
   type text references mark_type (type),
   wine_type text references wine_type(wine_type),
   color text references wine_color(color),
   country text references countries(country) default null,
   name text not null,
   section text default null,
   anonymous boolean,
   vintage integer default null,
   bottle_type text references bottle_info(bottle_type),
   perprice double precision,
   caseprice double precision,
   created timestamp without time zone,
   updated timestamp without time zone
);
create index on marks(user_id);

CREATE FUNCTION marks(pages) RETURNS bigint AS $$
  SELECT count(*) from catalogs.marks where page_id=$1.page_id;
$$ LANGUAGE SQL IMMUTABLE;


create view prices as
select
mark_id,name,vintage,type,
wine_type,color,country,k.country_code,
section,
bottle_type,
perprice::decimal(10,2),
caseprice::decimal(10,2),
page_id,page,
-- xy,
catalog_id,title,publisher,c.year as publication_date,
updated
from marks
join pages using (page_id)
join catalogs c using (catalog_id)
left join countries k using (country)
order by publication_date,vintage;

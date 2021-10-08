/*
File: Test max dop instance 
Configuration: 3 virtual processors in instance Sql Server.

*/
use AdventureWorks2019
go

exec sp_configure 'max degree of parallelism',3
RECONFIGURE
go

exec sp_configure 'cost threshold for parallelism',8
RECONFIGURE

select
	   name,
	   value
from sys.configurations
where  name in('max degree of parallelism','cost threshold for parallelism')
go

create schema test
go

create table test.Person
(
	BusinessEntityID int primary key identity,
	NamePerson varchar(200)
)
go

insert into test.Person  
SELECT  
      isnull(FirstName,'') + ' ' + isnull(MiddleName,'')
from [AdventureWorks2019].[Person].[Person]
go 100
 
SELECT [BusinessEntityID]
      ,[NamePerson]
FROM [AdventureWorks2019].[test].[Person]
where NamePerson like '%Ad%' order by NamePerson desc
go
-- image result this execution https://i.ibb.co/SNgQhxy/image.png
  

--If you will want to have only 2 processors for execution this query

SELECT [BusinessEntityID]
      ,[NamePerson]
FROM [AdventureWorks2019].[test].[Person]
where NamePerson like '%Ad%' order by NamePerson desc
option (maxdop 2)
go
-- image result this execution https://i.ibb.co/bK2kNjk/image.png


--Change 'cost threshold for parallelism' and execution the query again. Now, It hasn't Parallelism.
exec sp_configure 'cost threshold for parallelism',15
reconfigure

SELECT [BusinessEntityID]
      ,[NamePerson]
FROM [AdventureWorks2019].[test].[Person]
where NamePerson like '%Ad%' order by NamePerson desc
go

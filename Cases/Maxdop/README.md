# MAXDOP


### What's MAXDOP?
Max Degree of Parallelism (MAXDOP) is a configuration to define the number of processors that will be made available to each individual execution of a query. MAXDOP is divided into two options are **max degree of parallelism** and **cost threshold for parallelism**. 

- **Max degree of parallelism:** Is the limit of processors that can execute to each individual query.
- **Cost threshold for parallelism:** Is the value that it will know if execute parallelism.

We can configure through **graphic interface** or **sp_configure** 

### Have Parallelism is a problem??
Maybe, It can high levels indicate missing or fragmented index, and until out-of-date statistics.

### Why should I configure maxdop?
Because the default value for maxdop is 0, it signifies that Sql Server can use all processors available, until 64 processors. According to the documentation of Microsoft, the default value is not recommended.

### What's the best value for maxdop?
I think that depends. Maybe, one value could help you, but another person not. I will suggest a change and rate, but you will be careful. 

I have seen some forums recommending the following value cost threshold for parallelism 25 and 50.  

In common OLAP systems, there are many MAXDOP because the transactions are bit and more complex.

### Wait type
The wait type **CXPACKET** show up when SQL Server executes a query using the parallel plan. Not always is reference problem, because it's a normal. 

## How many virtual processors do you have


 <img width="250" alt="img_processors_logic" src="https://i.ibb.co/qFKDhMc/image.png">


## Enable option
```tsql
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
```

## See value in option
```tsql
select configuration_id,
	   name,
	   value,
	   minimum,
	   maximum,
	   value_in_use
from sys.configurations
where  name in('max degree of parallelism','cost threshold for parallelism')
```

## Change value in instance
```tsql
exec sp_configure 'max degree of parallelism',2
RECONFIGURE
```
and

```tsql
exec sp_configure 'cost threshold for parallelism',25
RECONFIGURE
```
## Change value in database (version only 2016 more)
```tsql
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8;
```
We can define value for database secondary replica 

```tsql
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = 1;
```

```tsql
SELECT * 
FROM  sys.database_scoped_configurations
where name='MAXDOP'
```

## Set value maxdop query hint
```tsql
SELECT ExpYEar,
       CardType,
	   count(CardType) as Total
FROM [AdventureWorks2019].[Sales].[CreditCard]
group by CardType,ExpYEar
order by CardType desc
OPTION (MAXDOP 2)
```

## Set value maxdop index option
```tsql
create INDEX  IX_Sales_maxdop_example ON [AdventureWorks2019].[Sales].[CreditCard] (cardNumber)  
with (MAXDOP =1 , SORT_IN_TEMPDB = ON)
```

or alter

```tsql
alter  INDEX all  ON [AdventureWorks2019].[Sales].[CreditCard] 
REBUILD WITH (MAXDOP =1 , SORT_IN_TEMPDB = ON, ONLINE = ON)
```

## Find queries with parallelism
```tsql
--Query is running
select r.session_id,
	   r.status,
	   r.dop,
	   t.text,
	   r.parallel_worker_count
from sys.dm_exec_requests as r
cross apply sys.dm_exec_sql_text(r.sql_handle) as t
-- where session_id in ()

--Tasks 
select session_id, *
from sys.dm_os_tasks
-- where session_id in()
order by worker_address
```


```tsql
SELECT TOP 10
p.*,
q.*,
qs.*,
cp.plan_handle
FROM
sys.dm_exec_cached_plans cp
CROSS apply sys.dm_exec_query_plan(cp.plan_handle) p
CROSS apply sys.dm_exec_sql_text(cp.plan_handle) AS q
JOIN sys.dm_exec_query_stats qs
ON qs.plan_handle = cp.plan_handle
WHERE
cp.cacheobjtype = 'Compiled Plan' AND
p.query_plan.value('declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
max(//p:RelOp/@Parallel)', 'float') > 0
OPTION (MAXDOP 1)
```

[Reference query](https://blog.sqlauthority.com/2010/07/24/sql-server-find-queries-using-parallelism-from-cached-plan/)

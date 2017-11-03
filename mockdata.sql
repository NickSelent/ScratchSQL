--Mock data to be sorted different ways
INSERT INTO work (Field1,Field2,Field3) VALUES ('Adata','2017-04-01',200)
INSERT INTO work (Field1,Field2,Field3) VALUES ('Bdata','2017-03-01',100)
INSERT INTO work (Field1,Field2,Field3) VALUES ('Cdata','2017-02-01',400)
INSERT INTO work (Field1,Field2,Field3) VALUES ('Ddata','2017-01-01',300)

Select * from WORK

--Truncate Table Scratch
--Populate Scratch Table in Order of Field 1
Insert Into Scratch (FKid)
Select id From Work Order BY Field1
--OR Field2
Insert Into Scratch (FKid)
Select id From Work Order BY Field2
--OR Field3
Insert Into Scratch (FKid)
Select id From Work Order BY Field3

--See how it's ordered...
Select * from Scratch


--This will be what a "get next" looks like...
--It should return the key from your work table of next highest priorty item that has not been assigned.
--Notice all the sorting and priority code happens in "preprocessing" and is isolated from get next.
--Now it is easy to change your priority logic without touching get next... and get next stays super fast...
--AND it is easy to reserve a block by prefilling [WHO] with a "Special" username
--You also have a paper trail if you ever suspect that something is getting worked out of order you can verify your sort logic...
DECLARE @fkid int
UPDATE Scratch SET @fkid = fkid , [Who] = 'UserNameA', [When] = GetUTCDate() WHERE id = (Select Top 1 id from Scratch Where [WHO] IS NULL Order By id ASC)

SELECT @fkid









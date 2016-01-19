create or replace procedure ch.fkList(
    @parent integer,
    @child integer
)
begin

select u.user_name + '.' + t.table_name as parentName,
    uc.user_name + '.' + tc.table_name as childName,
    pcol.column_name as primaryColumn,
    fcol.column_name as foreignColumn
from sys.sysfkey fk join sys.systable t on fk.primary_table_id = t.table_id
    join sys.systable tc on fk.foreign_table_id = tc.table_id
    join sys.sysuserperm u on u.user_id = t.creator
    join sys.sysuserperm uc on uc.user_id = tc.creator
    join sys.sysidx i on i.table_id =  fk.foreign_table_id and i.index_id =  fk.foreign_index_id
    join sys.sysidxcol ic on ic.table_id  =i.table_id and ic.index_id = i.index_id
    join sys.syscolumn fcol on fcol.table_id = fk.foreign_table_id and fcol.column_id = ic.column_id
    join sys.syscolumn pcol on pcol.table_id = fk.primary_table_id and pcol.column_id = ic.primary_column_id
where (fk.primary_table_id = @parent
    or @parent is null)
    and (fk.foreign_table_id = @child
    or @child is null);

end
;

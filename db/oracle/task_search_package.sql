-- Oracle PL/SQL package for task search
-- This is a reference artifact — it does not run locally against H2.
-- It mirrors the logic used by the Spring Data repository and is
-- representative of the kind of Oracle PL/SQL found in production.

create or replace package task_search_pkg as
   type task_record is record (
         id          number,
         title       varchar2(255),
         description varchar2(1000),
         status      varchar2(20),
         priority    varchar2(10),
         assignee    varchar2(100),
         created_at  timestamp
   );
   type task_cursor is ref cursor return task_record;
   procedure search_tasks (
      p_search_term in varchar2 default null,
      p_status      in varchar2 default null,
      p_page        in number default 1,
      p_page_size   in number default 10,
      p_results     out task_cursor,
      p_total_count out number
   );

end task_search_pkg;
/

create or replace package body task_search_pkg as

   procedure search_tasks (
      p_search_term in varchar2 default null,
      p_status      in varchar2 default null,
      p_page        in number default 1,
      p_page_size   in number default 10,
      p_results     out task_cursor,
      p_total_count out number
   ) is
      v_term   varchar2(257);
      v_offset number;
   begin
      v_term := '%'
                || lower(nvl(
         p_search_term,
         ''
      ))
                || '%';
      v_offset := ( p_page - 1 ) * p_page_size;

        -- Total count for pagination metadata
      select count(*)
        into p_total_count
        from tasks
       where archived = 0
         and ( lower(title) like v_term
          or lower(description) like v_term )
         and ( p_status is null
          or status = p_status );

        -- Paginated results using ROWNUM (pre-12c pattern)
      open p_results for select id,
                                title,
                                description,
                                status,
                                priority,
                                assignee,
                                created_at
        from (
         select t.*,
                rownum as rn
           from (
            select id,
                   title,
                   description,
                   status,
                   priority,
                   assignee,
                   created_at
              from tasks
             where archived = 0
               and ( lower(title) like v_term
                or lower(description) like v_term )
               and ( p_status is null
                or status = p_status )
             order by created_at desc
         ) t
          where rownum <= v_offset + p_page_size
      )
       where rn > v_offset;

   end search_tasks;

end task_search_pkg;
/
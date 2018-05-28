return {
    {
      name = "2018-05-28-postgres-ctk2",
      up = [[
        CREATE TABLE IF NOT EXISTS ctk2(
          id uuid,
          "jwt" text ON DELETE CASCADE,
          created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
          PRIMARY KEY (id)
        );
  
        DO $$
        BEGIN
          IF (SELECT to_regclass('ctk2_jwt')) IS NULL THEN
            CREATE INDEX ctk2_jwt ON ctk2("jwt");
          END IF;
        END$$;
      ]],
      down = [[
        DROP TABLE ctk2;
      ]]
    }
  }
  
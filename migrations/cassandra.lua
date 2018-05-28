return {
    {
      name = "2018-05-28-cassandra-ctk2",
      up = [[
        CREATE TABLE IF NOT EXISTS ctk2(
          id uuid,
          jwt text,
          created_at timestamp,
          PRIMARY KEY (id)
        );
  
        CREATE INDEX IF NOT EXISTS ON ctk2(jwt);
    ]],
      down = [[
        DROP TABLE ctk2;
      ]]
    }
  }
  
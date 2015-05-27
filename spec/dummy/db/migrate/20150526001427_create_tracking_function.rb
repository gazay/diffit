class CreateTrackingFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION tracking_function() RETURNS TRIGGER AS $$
      DECLARE

        n   JSON;       -- NEW as JSON
        o   JSON;       -- OLD as JSON
        t   TIMESTAMP;  -- current timestamp
        a   RECORD;     -- attribute

      BEGIN

        t := current_timestamp;

        -- on UPDATE

        IF (TG_OP = 'UPDATE') THEN

          -- convert OLD and NEW into JSON

          n := row_to_json(NEW);
          o := row_to_json(OLD);

          -- select attributes (without pkeys)

          FOR a IN SELECT
            pga.attname AS name
          FROM pg_attribute pga
          LEFT JOIN pg_index pgi ON pgi.indrelid = pga.attrelid AND pga.attnum = ANY(pgi.indkey)
          WHERE pga.attnum > 0 AND
                pgi.indisprimary IS NOT true AND
                pga.attrelid = TG_TABLE_NAME::regclass AND
                NOT pga.attisdropped
          ORDER BY pga.attnum
          LOOP

            IF (n->(a.name))::text IS DISTINCT FROM (o->(a.name))::text THEN

              -- UPSERT

              UPDATE tracked_changes
              SET
                value       = n->(a.name),
                changed_at  = t
              WHERE
                table_name  = TG_TABLE_NAME AND
                record_id   = NEW.id AND
                column_name = a.name;

              IF NOT FOUND THEN

                BEGIN

                  INSERT INTO tracked_changes
                    (table_name, record_id, column_name, value, changed_at)
                  VALUES
                    (TG_TABLE_NAME, NEW.id, a.name, n->(a.name), t);

                EXCEPTION WHEN OTHERS THEN

                  UPDATE tracked_changes
                  SET
                    value       = n->(a.name),
                    changed_at  = t
                  WHERE
                    table_name  = TG_TABLE_NAME AND
                    record_id   = NEW.id AND
                    column_name = a.name;

                END;
              END IF;
            END IF;
          END LOOP;

          RETURN NEW;

        -- on INSERT

        ELSIF (TG_OP = 'INSERT') THEN

          n := row_to_json(NEW);

          FOR a IN SELECT
            pga.attname AS name
          FROM pg_attribute pga
          LEFT JOIN pg_index pgi ON pgi.indrelid = pga.attrelid AND pga.attnum = ANY(pgi.indkey)
          WHERE pga.attnum > 0 AND
                pgi.indisprimary IS NOT true AND
                pga.attrelid = TG_TABLE_NAME::regclass AND
                NOT pga.attisdropped
          ORDER BY pga.attnum
          LOOP

            INSERT INTO tracked_changes
              (table_name, record_id, column_name, value, changed_at)
            VALUES
              (TG_TABLE_NAME, NEW.id, a.name, n->(a.name), t);

          END LOOP;

          RETURN NEW;

        END IF;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION IF EXISTS tracking_function();
    SQL
  end
end

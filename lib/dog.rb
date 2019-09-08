class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize (id: id, name: name, breed: breed)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql_create = "CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT);"
        
        DB[:conn].execute(sql_create)
    end

    def self.drop_table
        sql_drop = "DROP TABLE dogs;"

        DB[:conn].execute(sql_drop)
    end

    def self.new_from_db (row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end
   
    def self.find_by_name(name)
        sql_select = "SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1;"
        
        # nested = DB[:conn].execute(sql_select, name)
        
        # dog = self.new_from_db(nested[0])

        DB[:conn].execute(sql_select, name).map do |row|
            self.new_from_db(row)
          end.first
    end

    def self.find_by_id(id)
        sql_select = "SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1;"
        
        row = DB[:conn].execute(sql_select, id)[0]
        
        dog = self.new_from_db(row)
    end

    def self.find_or_create_by(name: name, breed: breed, id: id)
        sql_check = "SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
            LIMIT 1;"
        check = DB[:conn].execute(sql_check, name, breed)
        
        if !check.empty?
            dog_data = check[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def update
        sql_update = "UPDATE dogs
        SET name = ?,
        breed = ?
        WHERE id = ?;"

        DB[:conn].execute(sql_update, self.name, self.breed, self.id)
    end

    def save
        # sql_check = "SELECT *
        #     FROM dogs
        #     WHERE id = ?
        #     LIMIT 1;"
        # check = DB[:conn].execute(sql_check, self.id)
        
        # if check.empty?
        #     sql_insert = "INSERT INTO dogs
        #         (name, breed)
        #         VALUES (?, ?);"
        #     DB[:conn].execute(sql_insert, self.name, self.breed)
        # else 
        #     self.update
        # end
        # self
        if self.id
            self.update
        else
            sql = <<-SQL
              INSERT INTO dogs (name, breed)
              VALUES (?, ?)
            SQL
       
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end
end

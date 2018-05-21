require 'pry'
class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    id = row[0]
    name = row[1]
    grade = row[2]
    new_student = Student.new
    new_student.id = id
    new_student.name = name
    new_student.grade = grade
    new_student
  end

  def self.count_all_students_in_grade_9
    sql = <<-SQL
    SELECT COUNT(name) FROM students WHERE grade = ?
    SQL

    DB[:conn].execute(sql, 9)
  end

  def self.students_below_12th_grade
    sql = <<-SQL
    SELECT * FROM students WHERE grade < ?
    SQL

    students = DB[:conn].execute(sql, 12)
    students = students.map do |student|
      find_by_name(student[1])
    end
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
    SELECT * FROM students
    SQL

    all_students = DB[:conn].execute(sql)
    all_students.map do |student|
      new_from_db(student)
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL

    found_student = DB[:conn].execute(sql, name).flatten
    Student.new_from_db(found_student)
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.first_X_students_in_grade_10(x)
    sql = <<-SQL
    SELECT * FROM students WHERE grade = 10 LIMIT ?
    SQL

    student_list = DB[:conn].execute(sql, x)
  end

  def self.first_student_in_grade_10
    new_student = new_from_db(first_X_students_in_grade_10(1).flatten)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.all_students_in_grade_X(grade)
    sql = <<-SQL
    SELECT * FROM students WHERE grade = ?
    SQL
    DB[:conn].execute(sql, grade)
  end
end

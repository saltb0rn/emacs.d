import os
import peewee

DATABASE = os.environ.get('DATEBASE')

if DATABASE == 'MYSQL':
    database = peewee.MySQLDatabase(
        database="USERDB",
        host=os.environ.get('MYSQL_HOST'),
        user="root",
        password="root",
        charset="utf8mb4")
else:
    database = peewee.SqliteDatabase(os.path.join(
        os.path.dirname(__file__), 'example.db'))


class BaseModel(peewee.Model):
    class Meta:
        database = database


# Example below
# class User(BaseModel):
#     id = peewee.AutoField()
#     username = peewee.CharField(unique=True)
#     email = peewee.CharField()
#     join_date = peewee.DateTimeField(formats="%y/%m/%d %H:%M:%S")


def create_tables():
    # with database:
    #     database.create_tables([
    #         User
    #     ])
    pass

import sqlite3
import pandas as pd
from contextlib import contextmanager
from dataclasses import dataclass, field


@dataclass
class SQL:

    database: str
    tables: list[str] = field(default_factory=list, init=False)

    @contextmanager
    def sql(self):
        try:
            connection = sqlite3.connect(self.database)
            cursor = connection.cursor()
            yield cursor
        finally:
            connection.commit()
            cursor.close()
            connection.close()
    
    def tables_(self):
        with self.sql() as connection:
            connection.execute("SELECT name FROM sqlite_master WHERE type='table'")
            self.tabales = [i[2:-3] for i in [str(i) for i in connection.fetchall()]]
            self.tables.sort()
            return self.tables
        
    def data_frame(self, table: str):
        return pd.read_sql(sql=f"SELECT * FROM {table}", con=sqlite3.connect(self.database))
        
    def __post_init__(self):
        self.tables_()
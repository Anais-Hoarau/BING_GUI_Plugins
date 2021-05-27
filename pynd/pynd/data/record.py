from sqlite3 import Cursor
from typing import List, Any


class Record:

    def __init__(self, cursor: Cursor):
        self._names: List[str] = list(next(zip(*cursor.description)))
        self._data: List[Any] = list(zip(*cursor.fetchall()))

    def get_variable_values(self, variable_name: str) -> List[Any]:
        try:
            idx = self._names.index(variable_name)
        except ValueError:
            raise Exception('The requested variable is not present in this Record')
        else:
            if not self._data:
                return []
            return list(self._data[idx])

    def get_variables_values(self, *variables_names: str) -> List[Any]:
        """
        Yields values for the given variables names
        :param variables_names: 
        :return: 
        """
        # Getting indexes of required data
        idxs = []
        for var in variables_names:
            try:
                idx = self._names.index(var)
            except ValueError:
                continue
            else:
                idxs.append(idx)

        # Yielding data
        for data in zip(*self._data):
            yield [data[idx] for idx in idxs]

    def get_variable_names(self) -> List[str]:
        return self._names

    def is_empty(self) -> bool:
        return not self._names or not self._data

from abc import ABC, abstractmethod

from pynd import MetaVariableBase, MetaVariableBaseType


class TripTableManipulator(ABC):
    def __init__(self, trip):
        self._trip = trip
        self._table_name: str = None

    @abstractmethod
    def create_table(self, table_name: str) -> None:
        pass

    @staticmethod
    @abstractmethod
    def create_meta_variable(var_name: str, var_type: MetaVariableBaseType,
                             var_unit: str='', comment: str='') -> MetaVariableBase:
        pass

    @abstractmethod
    def add_variable(self, meta_variable: MetaVariableBase) -> None:
        pass

    @abstractmethod
    def set_batch_of_variable_pairs(self, datum_name, timecode, datum) -> None:
        pass

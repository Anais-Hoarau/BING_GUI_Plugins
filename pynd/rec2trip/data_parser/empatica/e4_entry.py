from abc import ABC, abstractmethod
from typing import List, Any

from pynd import SQLiteTrip, MetaDataVariable, MetaVariableBaseType
from rec2trip.ttm import TripTableManipulator, DataTableManipulator, EventTableManipulator


class E4Entry(ABC):
    def __init__(self, key):
        self._key: str = str(key)
        self._ttm: TripTableManipulator = None
        self._table_name: str = ''
        self._meta_vars: List[MetaDataVariable] = []
        self._data: List[Any] = []

    def uuid(self):
        return self._key

    def add_to_trip(self):
        self._ttm.create_table(self._table_name)
        for meta_var in self._meta_vars:
            self._ttm.add_variable(meta_var)

        timecode, data = zip(*self._data)
        for i, datum in enumerate(zip(*data)):
            datum_name = self._meta_vars[i].get_name()
            self._ttm.set_batch_of_variable_pairs(datum_name, timecode, datum)

    @abstractmethod
    def add_data(self, ts, data) -> None:
        pass

    @abstractmethod
    def _generate_metavar(self, key) -> None:
        pass


class E4SingleDataEntry(E4Entry):
    def __init__(self, key: str, trip: SQLiteTrip):
        E4Entry.__init__(self, key)
        self._ttm = DataTableManipulator(trip)
        self._generate_metavar(key)

    def add_data(self, ts: float, data: str) -> None:
        self._data.append((ts, [float(data)]))

    def _generate_metavar(self, key: str) -> None:
        if key in ['Bvp']:
            self._table_name = 'EMPATICA_E4_Bvp'
        elif key in ['Hr', 'Ibi']:
            self._table_name = 'EMPATICA_E4_Hr_Ibi'
        elif key in ['Gsr']:
            self._table_name = 'EMPATICA_E4_Gsr'
        elif key in ['Temperature']:
            self._table_name = 'EMPATICA_E4_Temperature'
        elif key in ['Battery']:
            self._table_name = 'EMPATICA_E4_Battery'
        else:
            # TODO Raise a warning or an error here
            pass

        meta_var = self._ttm.create_meta_variable(key, MetaVariableBaseType.REAL,
                                                  comment="Imported from rec file")
        self._meta_vars.append(meta_var)


class E4SingleEventEntry(E4Entry):
    def __init__(self, key: str, trip: SQLiteTrip):
        E4Entry.__init__(self, key)
        self._ttm = EventTableManipulator(trip)
        self._generate_metavar(key)

    def add_data(self, ts: float, data: str) -> None:
        self._data.append((ts, [float(data)]))

    def _generate_metavar(self, key: str) -> None:
        if key in ['Tag']:
            self._table_name = 'EMPATICA_E4_Trigger'
        else:
            # TODO Raise a warning or an error here
            pass

        meta_var = self._ttm.create_meta_variable(key, MetaVariableBaseType.REAL,
                                                  comment="Imported from rec file")
        self._meta_vars.append(meta_var)


class E4TripleDataEntry(E4Entry):
    def __init__(self, key: str, trip: SQLiteTrip):
        E4Entry.__init__(self, key)
        self._ttm = DataTableManipulator(trip)
        self._generate_metavar(key)

    def add_data(self, ts: float, data: str) -> None:
        self._data.append((ts, [int(d) for d in data.split(' ')]))

    def _generate_metavar(self, key: str) -> None:
        if key in ['Acc']:
            self._table_name = 'EMPATICA_E4_Acc'
        else:
            # TODO Raise a warning or an error here
            pass

        for suffix in ['x', 'y', 'z']:
            meta_var = self._ttm.create_meta_variable(f'{key}_{suffix}', MetaVariableBaseType.REAL,
                                                      comment="Imported from rec file")
            self._meta_vars.append(meta_var)

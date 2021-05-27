from abc import ABC, abstractmethod
from typing import List, Any

from pynd import SQLiteTrip, MetaVariableBase, MetaVariableBaseType
from rec2trip.ttm import TripTableManipulator, DataTableManipulator, EventTableManipulator


class Dr2Entry(ABC):
    """
    This class holds information about a DR2 element, particularly concerning how it will be stored in the trip.
    """
    def __init__(self, key: str):
        self._key = key
        self._ttm: TripTableManipulator = None
        self._table_name: str = ''
        self._meta_var: MetaVariableBase = None
        self._data: List[Any] = []

    def uuid(self):
        return self._key

    def add_data(self, ts: float, data: Any) -> None:
        self._data.append((ts, data))

    def add_to_trip(self) -> None:
        self._ttm.create_table(self._table_name)
        self._ttm.add_variable(self._meta_var)

        timecode, datum = zip(*self._data)
        datum_name = self._meta_var.get_name()
        self._ttm.set_batch_of_variable_pairs(datum_name, timecode, datum)

    @abstractmethod
    def _generate_metavar(self, key: str) -> None:
        pass


class Dr2GenericEntry(Dr2Entry):
    def __init__(self, key: str, trip: SQLiteTrip):
        Dr2Entry.__init__(self, key)
        self._ttm = DataTableManipulator(trip)
        self._table_name = 'DR2_Simulateur'
        self._generate_metavar(key)

    def _generate_metavar(self, key: str) -> None:
        # TODO Add Units
        if key in ['Temps', 'HeureGMT']:
            self._meta_var = self._ttm.create_meta_variable(key, MetaVariableBaseType.TEXT,
                                                            comment="Imported from rec file")
        else:
            self._meta_var = self._ttm.create_meta_variable(key, MetaVariableBaseType.REAL,
                                                            comment="Imported from rec file")


class Dr2VehicleEntry(Dr2Entry):
    def __init__(self, key: str, trip: SQLiteTrip):
        Dr2Entry.__init__(self, key)
        self._ttm = DataTableManipulator(trip)
        # Squeeze the vehicle identifier 'V_'
        key = key.split('_')[1]
        if '-' in key:
            # Vehicle manually created in DR2 scenarii are always called -XXX. '-' is not usable in table names.
            key = key.strip('-')
            self._table_name = f'DR2_Vehicule_SCE_{key.split(":")[0]}'
        else:
            self._table_name = f'DR2_Vehicule_VHS_{key.split(":")[0]}'
        self._generate_metavar(key.split(":")[1])

    def _generate_metavar(self, key: str) -> None:
        # TODO Add Units
        if key in ['Route', 'Sens', 'Cab.Indics']:
            self._meta_var = self._ttm.create_meta_variable(key, MetaVariableBaseType.TEXT,
                                                            comment="Imported from rec file")
        else:
            self._meta_var = self._ttm.create_meta_variable(key, MetaVariableBaseType.REAL,
                                                            comment="Imported from rec file")


class Dr2PedestrianEntry(Dr2Entry):
    def __init__(self, key: str, trip: SQLiteTrip):
        Dr2Entry.__init__(self, key)
        self._ttm = DataTableManipulator(trip)
        # Squeeze the pedestrian identifier 'P_'
        key = key.split('_')[1]
        self._table_name = f'DR2_Pedestrian_SCE_{key.split(":")[0]}'
        self._generate_metavar(key.split(":")[1])

    def _generate_metavar(self, key: str) -> None:
        # TODO Add Units
        self._meta_var = self._ttm.create_meta_variable(key, MetaVariableBaseType.REAL,
                                                            comment="Imported from rec file")


class Dr2CommentEntry(Dr2Entry):
    def __init__(self, key: str, trip: SQLiteTrip):
        Dr2Entry.__init__(self, key)
        self._ttm = EventTableManipulator(trip)
        self._table_name = 'DR2_Commentaires'
        self._generate_metavar(key)

    def _generate_metavar(self, key: str) -> None:
        # TODO Regroup comments by category
        self._meta_var = self._ttm.create_meta_variable(key, MetaVariableBaseType.TEXT,
                                                        comment="Imported from rec file")

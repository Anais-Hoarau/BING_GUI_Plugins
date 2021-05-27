from pynd import MetaVariableBaseType
from rec2trip.data_parser import UniqueDataParser


class IntParser(UniqueDataParser):

    def __init__(self, *args, **kwargs):
        UniqueDataParser.__init__(self, *args, **kwargs)

    def _trip_type(self) -> MetaVariableBaseType:
        return MetaVariableBaseType.REAL

    def _convert_to_trip_type(self, data) -> int:
        return int(data)

from pynd.data import MetaBase, MetaDataVariable, MetaVariableBaseType


class MetaData(MetaBase):

    def __init__(self):
        super().__init__()
        self._type: MetaVariableBaseType = MetaVariableBaseType.REAL
        self._frequency: float = 0
        timecode = MetaDataVariable()
        timecode.set_name('timecode')
        timecode.set_type(MetaVariableBaseType.REAL)
        self._set_framework_variables([timecode])

    def get_frequency(self) -> float:
        return self._frequency

    def set_frequency(self, frequency: float) -> None:
        self._frequency = frequency

    def get_type(self) -> MetaVariableBaseType:
        return self._type

    def set_type(self, t: MetaVariableBaseType):
        self._type = t

    def hash(self) -> str:
        return super(MetaData, self).hash() + '|' + str(self._frequency) + '|' + self._type.name + '|' + 'DATA'

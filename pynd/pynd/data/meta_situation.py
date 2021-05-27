from pynd.data import MetaBase, MetaEventVariable, MetaVariableBaseType


class MetaSituation(MetaBase):

    def __init__(self):
        super().__init__()
        start_timecode = MetaEventVariable()
        start_timecode.set_name('startTimecode')
        start_timecode.set_type(MetaVariableBaseType.REAL)
        end_timecode = MetaEventVariable()
        end_timecode.set_name('endTimecode')
        end_timecode.set_type(MetaVariableBaseType.REAL)
        self._set_framework_variables([start_timecode, end_timecode])

    def hash(self) -> str:
        return super(MetaSituation, self).hash() + '|' + 'SITUATION'

from pynd.data import MetaBase, MetaEventVariable, MetaVariableBaseType


class MetaEvent(MetaBase):

    def __init__(self):
        super().__init__()
        timecode = MetaEventVariable()
        timecode.set_name('timecode')
        timecode.set_type(MetaVariableBaseType.REAL)
        self._set_framework_variables([timecode])

    def hash(self) -> str:
        return super(MetaEvent, self).hash() + '|' + 'EVENT'

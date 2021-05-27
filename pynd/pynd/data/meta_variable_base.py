from enum import Enum


class MetaVariableBaseType(Enum):
    REAL = 'REAL'
    TEXT = 'TEXT'
    NONE = ''


class MetaVariableBase:
    def __init__(self):
        self._name: str = ''
        self._type: MetaVariableBaseType = MetaVariableBaseType.REAL
        self._unit: str = ''
        self._comments: str = ''

    def get_name(self) -> str:
        return self._name

    def set_name(self, name: str) -> None:
        self._name = name

    def get_type(self) -> MetaVariableBaseType:
        return self._type

    def set_type(self, t: MetaVariableBaseType) -> None:
        self._type = t

    def get_unit(self) -> str:
        return self._unit

    def set_unit(self, unit: str) -> None:
        self._unit = unit

    def get_comments(self) -> str:
        return self._comments

    def set_comment(self, comments: str) -> None:
        self._comments = comments

    def hash(self) -> str:
        return self._name + '|' + self._type.name + '|' + self._unit + '|' + self._comments

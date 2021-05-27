from typing import List
from pynd.data import MetaVariableBase


class MetaBase:
    __RESERVED_VARIABLES_NAMES = ['timecode', 'startTimecode', 'endTimecode']

    def __init__(self):
        self._name: str = ''
        self._comments: str = ''
        self._is_base_attr: bool = False
        self._user_variables: List[MetaVariableBase] = []
        self._framework_variables: List[MetaVariableBase] = []

    @classmethod
    def get_reserved_variables_names(cls):
        return cls.__RESERVED_VARIABLES_NAMES

    def is_base(self) -> bool:
        return self._is_base_attr

    def set_is_base(self, is_base: bool) -> None:
        self._is_base_attr = is_base

    def get_name(self) -> str:
        return self._name

    def set_name(self, name: str) -> None:
        self._name = name

    def get_comments(self) -> str:
        return self._comments

    def set_comments(self, comments: str) -> None:
        self._comments = comments

    def get_variables(self) -> List[MetaVariableBase]:
        return self._user_variables

    def set_variables(self, variables: List[MetaVariableBase]) -> None:
        self._user_variables = [v for v in variables if v.get_name() not in self.__RESERVED_VARIABLES_NAMES]

    def get_framework_variables(self) -> List[MetaVariableBase]:
        return self._framework_variables

    def get_variables_and_framework_variables(self) -> List[MetaVariableBase]:
        return self.get_framework_variables() + self.get_variables()

    def hash(self) -> str:
        return self._name + '|' + self._comments + '|' + str(self._is_base_attr)

    def _set_framework_variables(self, variables: List[MetaVariableBase]) -> None:
        self._framework_variables = variables

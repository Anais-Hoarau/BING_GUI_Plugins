from typing import Dict, List, Any, Tuple


class MetaParticipant:
    def __init__(self):
        self._data: Dict[Any, Any] = {}

    def set_attribute(self, key: Any, value: Any) -> None:
        self._data[key] = value

    def get_attribute(self, key: Any) -> Any:
        return self._data[key]

    def remove_attribute(self, key: Any) -> None:
        del self._data[key]

    def get_attributes_list(self) -> List[Any]:
        return list(self._data.keys())

    def get_attributes(self) -> Tuple[Any, Any]:
        for k, v in self._data.items():
            yield k, v

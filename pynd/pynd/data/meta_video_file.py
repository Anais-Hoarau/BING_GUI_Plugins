class MetaVideoFile:
    def __init__(self, file_name: str, offset: float, description: str):
        self._description: str = description
        self._file_name: str = file_name
        self._offset: float = offset

    def get_description(self) -> str:
        return self._description

    def set_description(self, description: str) -> None:
        self._description = description

    def get_file_name(self) -> str:
        return self._file_name

    def set_file_name(self, file_name: str) -> None:
        self._file_name = file_name

    def get_offset(self) -> float:
        return self._offset

    def set_offset(self, offset: float) -> None:
        self._offset = offset

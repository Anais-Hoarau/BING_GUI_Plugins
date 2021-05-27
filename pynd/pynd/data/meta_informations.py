from typing import List

from pynd.data import MetaData, MetaEvent, MetaSituation, MetaParticipant, MetaVideoFile


class MetaInformations:

    def __init__(self):
        self._datas_list: List[MetaData] = []
        self._events_list: List[MetaEvent] = []
        self._situations_list: List[MetaSituation] = []
        self._attributes_list: List[str] = []
        self._participant: MetaParticipant = None
        self._video_files: List[MetaVideoFile] = []

    def get_events_list(self) -> List[MetaEvent]:
        return self._events_list

    def get_events_names_list(self) -> List[str]:
        return [e.get_name() for e in self.get_events_list()]

    def get_event_variables_name_list(self, event_name: str) -> List[str]:
        return [v.get_name() for v in self.get_meta_event(event_name).get_variables_and_framework_variables()]

    def set_event_list(self, events_list: List[MetaEvent]) -> None:
        self._events_list = events_list

    def get_situations_list(self) -> List[MetaSituation]:
        return self._situations_list

    def get_situations_names_list(self) -> List[str]:
        return [e.get_name() for e in self.get_situations_list()]

    def get_situation_variables_name_list(self, situation_name: str) -> List[str]:
        return [v.get_name() for v in self.get_meta_situation(situation_name).get_variables_and_framework_variables()]

    def set_situation_list(self, situations_list: List[MetaSituation]) -> None:
        self._situations_list = situations_list

    def get_datas_list(self) -> List[MetaData]:
        return self._datas_list

    def get_datas_names_list(self) -> List[str]:
        return [e.get_name() for e in self.get_datas_list()]

    def get_data_variables_name_list(self, data_name: str) -> List[str]:
        return [v.get_name() for v in self.get_meta_data(data_name).get_variables_and_framework_variables()]

    def set_data_list(self, datas_list: List[MetaData]) -> None:
        self._datas_list = datas_list

    def get_trip_attributes_list(self) -> List[str]:
        return self._attributes_list

    def set_trip_attributes_list(self, attributes_list: List[str]) -> None:
        self._attributes_list = attributes_list

    def get_meta_data(self, data_name: str) -> MetaData:
        for data in self._datas_list:
            if data.get_name() == data_name:
                return data
        raise Exception('The requested data was not found in the metainformations')

    def get_meta_event(self, event_name: str) -> MetaEvent:
        for event in self._events_list:
            if event.get_name() == event_name:
                return event
        raise Exception('The requested event was not found in the metainformations')

    def get_meta_situation(self, situation_name: str) -> MetaSituation:
        for situation in self._situations_list:
            if situation.get_name() == situation_name:
                return situation
        raise Exception('The requested situation was not found in the metainformations')

    def set_participant(self, participant: MetaParticipant) -> None:
        self._participant = participant

    def get_participant(self) -> MetaParticipant:
        return self._participant

    def set_video_files(self, video_files: List[MetaVideoFile]) -> None:
        self._video_files = video_files

    def get_video_files(self) -> List[MetaVideoFile]:
        return self._video_files

    def exist_data(self, data_name: str) -> bool:
        for data in self.get_datas_names_list():
            if data == data_name:
                return True
        return False

    def exist_data_variable(self, data_name: str, variable_name: str) -> bool:
        if not self.exist_data(data_name):
            return False
        for variable in self.get_data_variables_name_list(data_name):
            if variable == variable_name:
                return True
        return False

    def exist_event(self, event_name: str) -> bool:
        for event in self.get_events_names_list():
            if event == event_name:
                return True
        return False

    def exist_event_variable(self, event_name: str, variable_name: str) -> bool:
        if not self.exist_event(event_name):
            return False
        for variable in self.get_event_variables_name_list(event_name):
            if variable == variable_name:
                return True
        return False

    def exist_situation(self, situation_name: str) -> bool:
        for situation in self.get_situations_names_list():
            if situation == situation_name:
                return True
        return False

    def exist_situation_variable(self, situation_name: str, variable_name: str) -> bool:
        if not self.exist_situation(situation_name):
            return False
        for variable in self.get_situation_variables_name_list(situation_name):
            if variable == variable_name:
                return True
        return False

    def exist_attribute(self, attribute_name: str) -> bool:
        for attribute in self.get_trip_attributes_list():
            if attribute == attribute_name:
                return True
        return False

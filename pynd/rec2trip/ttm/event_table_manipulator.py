import logging as log

from pynd import MetaEvent, MetaEventVariable, MetaVariableBaseType
from .trip_table_manipulator import TripTableManipulator


class EventTableManipulator(TripTableManipulator):
    def __init__(self, trip):
        TripTableManipulator.__init__(self, trip)
        self._meta_event: MetaEvent = None

    def create_table(self, table_name: str) -> None:
        """
        Creates an event table in the trip and returns its metaevent. If the table already exists, this methods simply
        returns the metaevent
        :param table_name: Name of the table to create
        :return: Meta event of the table with the requested name
        """
        self._table_name = table_name
        meta_info = self._trip.get_meta_informations()

        # Check if event table already exists
        for event in meta_info.get_events_list():
            if event.get_name() == table_name:
                self._meta_event = event
                log.debug(f"{table_name} table already exists in trip")
                break
        else:
            log.debug(f"Creating meta event {table_name}")
            self._meta_event = MetaEvent()
            self._meta_event.set_name(table_name)
            # TODO Can't set isBase here because we're adding variables just below
            # meta_event.set_is_base(True)
            self._meta_event.set_comments("Imported from pynd's rec2trip")
            # TODO How to set other metaevent values? (e.g. comment, etc.)
            self._trip.add_event(self._meta_event)

    @staticmethod
    def create_meta_variable(var_name: str, var_type: MetaVariableBaseType,
                             var_unit: str = '', comment: str = '') -> MetaEventVariable:
        meta_var = MetaEventVariable()
        meta_var.set_name(var_name)
        meta_var.set_unit(var_unit)
        meta_var.set_type(var_type)
        meta_var.set_comment(comment)
        return meta_var

    def add_variable(self, meta_variable) -> None:
        """

        :param meta_variable:
        :return:
        """
        name = meta_variable.get_name()

        # Check if event column already exists in table
        for meta_var in self._meta_event.get_variables():
            if meta_var.get_name() == name:
                log.warning(f"{name} already exists in table {self._table_name}")
                return
        else:
            log.debug(f"Creating meta event variable {self._table_name}.{name}")
            self._trip.add_event_variable(self._table_name, meta_variable)

            # Update meta event
            variable_list = self._meta_event.get_variables()
            variable_list.append(meta_variable)
            self._meta_event.set_variables(variable_list)

    def set_batch_of_variable_pairs(self, event_name, timecode, event) -> None:
        """

        :param event_name:
        :param timecode:
        :param event:
        :return:
        """
        log.debug(f"Loading {self._table_name}.{event_name} to trip")
        self._trip.set_batch_of_time_event_variable_pairs(self._table_name, event_name, zip(timecode, event))

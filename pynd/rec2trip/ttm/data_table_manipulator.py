import logging as log

from pynd import MetaData, MetaDataVariable, MetaVariableBaseType
from .trip_table_manipulator import TripTableManipulator


class DataTableManipulator(TripTableManipulator):
    def __init__(self, trip):
        TripTableManipulator.__init__(self, trip)
        self._meta_data: MetaData = None

    def create_table(self, table_name: str) -> None:
        """
        Creates a data table in the trip and returns its metadata. If the table already exists, this methods simply
        returns the metadata
        :param table_name: Name of the table to create
        :return: Meta data of the table with the requested name
        """
        self._table_name = table_name
        meta_info = self._trip.get_meta_informations()

        # Check if data table already exists
        for data in meta_info.get_datas_list():
            if data.get_name() == table_name:
                self._meta_data = data
                log.debug(f"{table_name} table already exists in trip")
                break
        else:
            log.debug(f"Creating meta data {table_name}")
            self._meta_data = MetaData()
            self._meta_data.set_name(table_name)
            # TODO Can't set isBase here because we're adding variables just below
            # meta_data.set_is_base(True)
            self._meta_data.set_comments("Imported from pynd's rec2trip")
            # TODO How to set other metadata values? (e.g. frequency, comment, etc.)
            self._trip.add_data(self._meta_data)

    @staticmethod
    def create_meta_variable(var_name: str, var_type: MetaVariableBaseType,
                             var_unit: str = '', comment: str = '') -> MetaDataVariable:
        meta_var = MetaDataVariable()
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

        # Check if data column already exists in table
        for meta_var in self._meta_data.get_variables():
            if meta_var.get_name() == name:
                log.warning(f"{name} already exists in table {self._table_name}")
                return
        else:
            log.debug(f"Creating meta data variable {self._table_name}.{name}")
            self._trip.add_data_variable(self._table_name, meta_variable)

            # Update meta data
            variable_list = self._meta_data.get_variables()
            variable_list.append(meta_variable)
            self._meta_data.set_variables(variable_list)

    def set_batch_of_variable_pairs(self, datum_name, timecode, datum) -> None:
        """

        :param datum_name:
        :param timecode:
        :param datum:
        :return:
        """
        log.debug(f"Loading {self._table_name}.{datum_name} to trip")
        self._trip.set_batch_of_time_data_variable_pairs(self._table_name, datum_name, zip(timecode, datum))

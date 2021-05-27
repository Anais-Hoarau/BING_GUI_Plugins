"""
Python implementation of SQLiteTrip, ported from the Matlab's implementation
"""
import os
import sqlite3
import math
from typing import Any, List, Tuple

import pynd
from pynd.data import Record, MetaInformations, MetaData, MetaVideoFile, MetaParticipant, MetaEvent, MetaSituation, \
    MetaSituationVariable, MetaEventVariable, MetaDataVariable, MetaBase, MetaVariableBaseType, MetaVariableBase
from pynd.kernel import Trip


class SQLiteTrip(Trip):
    connection: sqlite3.Connection
    path_to_file: str

    def __init__(self, database_path: str, period: float, create: bool):
        super().__init__(period)
        if os.path.isfile(database_path):
            # Before making the connection, we ensure that the db is not a 0 byte file
            if os.path.getsize(database_path) == 0:
                raise pynd.FileException('The file passed to the constructor is an empty file. Cannot instantiate trip')
            else:
                self.connection = sqlite3.connect(database_path)
                c = self.connection.cursor()
                # To ensure an exception is thrown if the file is not a valid db
                try:
                    c.execute('SELECT * FROM sqlite_master')
                except:
                    raise pynd.FileException('The file passed to the constructor is not a valid SQLite database')
                columns_list_record = Record(c.execute('PRAGMA table_info(MetaDataVariables)'))
                columns_list = columns_list_record.get_variable_values('name')
                if 'unit' not in columns_list:
                    raise NotImplementedError("Conversion of old SQLite trips not implemented yet")
        elif create:
            self.connection = sqlite3.connect(database_path)
            c = self.connection.cursor()
            # The tables that contains the informations about the trip context
            c.execute('CREATE TABLE "MetaTripDatas" ( '
                      '"key" TEXT NOT NULL, '
                      '"value" TEXT NOT NULL, '
                      'PRIMARY KEY ("key") '
                      ')')
            c.execute('CREATE TABLE "MetaParticipantDatas" ( '
                      '"key" TEXT NOT NULL , '
                      '"value" TEXT NULL , '
                      'PRIMARY KEY ("key") '
                      ')')
            c.execute('CREATE TABLE "MetaTripVideos" ( '
                      '"filename" TEXT NOT NULL , '
                      '"offset" DOUBLE NOT NULL DEFAULT 0, '
                      '"description" TEXT, '
                      'PRIMARY KEY ("filename") '
                      ')')
            # The tables that contains the informations about the temporal datas ans its subdivisions
            c.execute('CREATE TABLE "MetaDatas" ( '
                      '"name" TEXT NOT NULL, '
                      '"type" TEXT NOT NULL, '
                      '"frequency" INT NOT NULL DEFAULT -1, '
                      '"comments" TEXT NULL, '
                      '"isBase" BOOL NOT NULL DEFAULT 0, '
                      'PRIMARY KEY ("name") '
                      ')')
            c.execute('CREATE TABLE "MetaDataVariables" ( '
                      '"data_name" TEXT NOT NULL, '
                      '"name" TEXT NOT NULL, '
                      '"type" TEXT NOT NULL DEFAULT "REAL", '
                      '"unit" TEXT NULL, '
                      '"comments" TEXT NULL, '
                      'PRIMARY KEY ("name", "data_name") '
                      ')')
            # The tables that contains the informations about the instantaneous events
            c.execute('CREATE TABLE "MetaEvents" ( '
                      '"name" TEXT NOT NULL, '
                      '"comments" TEXT NULL, '
                      '"isBase" BOOL NOT NULL DEFAULT 1, '
                      'PRIMARY KEY ("name") '
                      ')')
            c.execute('CREATE TABLE "MetaEventVariables" ( '
                      '"event_name" TEXT NOT NULL, '
                      '"name" TEXT NOT NULL, '
                      '"type" TEXT NOT NULL DEFAULT "REAL", '
                      '"unit" TEXT NULL, '
                      '"comments" TEXT NULL, '
                      'PRIMARY KEY ("name", "event_name") '
                      ')')
            # The tables that contains the informations about the situations(events with a start and end time).
            c.execute('CREATE TABLE "MetaSituations" ( '
                      '"name" TEXT NOT NULL, '
                      '"comments" TEXT NULL, '
                      '"isBase" BOOL NOT NULL DEFAULT 1, '
                      'PRIMARY KEY ("name") '
                      ')')
            c.execute('CREATE TABLE "MetaSituationVariables" ( '
                      '"situation_name" TEXT NOT NULL, '
                      '"name" TEXT NOT NULL, '
                      '"type" TEXT NOT NULL DEFAULT "REAL", '
                      '"unit" TEXT NULL, '
                      '"comments" TEXT NULL, '
                      'PRIMARY KEY ("name", "situation_name") '
                      ')')
        else:
            raise pynd.FileException('The file passed to the constructor was not found, and the create argument is set '
                                     'to false, so we were unable to instanciate the SQLiteTrip')

        # If the trip does not permit the calculation of "max time", which is needed for the timer, it will not be
        # possible to instanciate the trip, BUT it is required to close the sqlite connection to free sqlite handlers
        # TODO Uncomment when timer is implement
        # try:
        #     max_time = self.get_max_time_in_datas()
        # except:
        #     self.release()
        #     raise pynd.FileException('Impossible to obtain "max time" from data: impossible to instanciate the '
        #                              'SQLiteTrip. Check data and metadata structure and verify it is compliant with '
        #                              'the BIND specifications. DB connection was closed.')
        # else:
        #     self.set_max_time_in_seconds(max_time)
        self.path_to_file = database_path

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.release()

    def release(self):
        self.connection.close()

    def _rollback(func):
        """
        Decorator to rollback the SQLite trip in case of error during manipulation
        :return: 
        """

        def wrap(self, *args, **kwargs):
            c = self.connection.cursor()
            c.execute(f"SAVEPOINT {func.__name__}")

            def release():
                c.execute(f"RELEASE SAVEPOINT {func.__name__}")

            try:
                r = func(self, *args, *kwargs)
            except sqlite3.Error:
                c.execute(f"ROLLBACK TRANSACTION TO SAVEPOINT {func.__name__}")
                raise
            except:
                release()
                raise
            else:
                release()
                return r

        return wrap

    def _emit(msg):
        """
        Decorator to emit message after the execution of a method
        :return: 
        """

        def emit_decorator(func):
            def wrap(self, *args, **kwargs):
                r = func(self, *args, **kwargs)
                # TODO emit msg
                return r

            return wrap

        return emit_decorator

    def get_trip_path(self) -> str:
        return self.path_to_file

    def remove_all_data_occurences(self, data_name: str) -> None:
        self._remove_table_content(f"data_{data_name}")

    def remove_all_event_occurences(self, event_name: str) -> None:
        self._remove_table_content(f"event_{event_name}")

    def remove_all_situation_occurences(self, situation_name: str) -> None:
        self._remove_table_content(f"situation_{situation_name}")

    def get_all_data_occurences(self, data_name: str) -> Record:
        return self._get_table_content(f"data_{data_name}")

    def get_all_event_occurences(self, event_name: str) -> Record:
        return self._get_table_content(f"event_{event_name}")

    def get_all_situation_occurences(self, situation_name: str) -> Record:
        return Record(self.connection.execute(f'SELECT * FROM "situation_{situation_name}" '
                                              f'ORDER BY startTimecode ASC, endTimecode ASC'))

    def get_data_occurence_near_time(self, data_name: str, t) -> Record:
        return self._get_line_near_time(f"data_{data_name}", t)

    def get_event_occurence_near_time(self, event_name: str, t) -> Record:
        return self._get_line_near_time(f"event_{event_name}", t)

    def get_data_occurence_at_time(self, data_name: str, t) -> Record:
        return self._get_line_at_time(f"data_{data_name}", t)

    def get_event_occurence_at_time(self, event_name: str, t) -> Record:
        return self._get_line_at_time(f"event_{event_name}", t)

    def get_situation_occurence_at_time(self, situation_name: str, start_time, end_time) -> Record:
        return Record(self.connection.execute(f'SELECT * FROM "situation_{situation_name}" '
                                              f'WHERE startTimecode = \'{start_time:.12f}\' '
                                              f'AND endTimecode = \'{end_time:.12f}\''))

    def get_situation_occurences_around_time(self, situation_name: str, t) -> Record:
        return Record(self.connection.execute(f'SELECT * FROM "situation_{situation_name}" '
                                              f'WHERE startTimecode <= \'{t:.12f}\' AND \'{t:.12f}\' <= endTimecode '
                                              f'ORDER BY startTimecode ASC, endTimecode ASC'))

    def get_data_occurences_in_time_interval(self, data_name: str, start_time, end_time) -> Record:
        return self._get_lines_in_time_interval(f"data_{data_name}", start_time, end_time)

    def get_event_occurences_in_time_interval(self, event_name: str, start_time, end_time) -> Record:
        return self._get_lines_in_time_interval(f"event_{event_name}", start_time, end_time)

    def get_situation_occurences_in_time_interval(self, situation_name: str, start_time, end_time) -> Record:
        return Record(self.connection.execute(f'SELECT * FROM "situation_{situation_name}" '
                                              f'WHERE \'{start_time:.12f}\' <= startTimecode'
                                              f'AND \'{end_time:.12f}\' >= endTimecode  '
                                              f'ORDER BY startTimecode ASC, endTimecode ASC'))

    def get_data_variable_minimum(self, data_name: str, variable_name: str):
        return self._get_column_minimum(f"data_{data_name}", variable_name)

    def get_event_variable_minimum(self, event_name: str, variable_name: str):
        return self._get_column_minimum(f"event_{event_name}", variable_name)

    def get_situation_variable_minimum(self, situation_name: str, variable_name: str):
        return self._get_column_minimum(f"situation_{situation_name}", variable_name)

    def get_data_variable_maximum(self, data_name: str, variable_name: str):
        return self._get_column_maximum(f"data_{data_name}", variable_name)

    def get_event_variable_maximum(self, event_name: str, variable_name: str):
        return self._get_column_maximum(f"event_{event_name}", variable_name)

    def get_situation_variable_maximum(self, situation_name: str, variable_name: str):
        return self._get_column_maximum(f"situation_{situation_name}", variable_name)

    def get_data_variable_occurences_in_time_interval(self, data_name: str, variable_name: str,
                                                      start_time, end_time) -> Record:
        return self._get_column_in_time_interval(f"data_{data_name}", variable_name, start_time, end_time)

    def get_event_variable_occurences_in_time_interval(self, event_name: str, variable_name: str,
                                                       start_time, end_time) -> Record:
        return self._get_column_in_time_interval(f"event_{event_name}", variable_name, start_time, end_time)

    def get_situation_variable_occurences_in_time_interval(self, situation_name: str, variable_name: str,
                                                           start_time, end_time) -> Record:
        return Record(self.connection.execute(f'SELECT "{variable_name}", startTimecode, endTimecode '
                                              f'FROM "situation_{situation_name}" '
                                              f'WHERE \'{start_time:.12f}\' <= startTimecode'
                                              f'AND \'{end_time:.12f}\' >= endTimecode  '
                                              f'ORDER BY startTimecode ASC, endTimecode ASC'))

    def get_meta_informations(self) -> MetaInformations:
        meta_informations: MetaInformations = MetaInformations()
        c = self.connection.cursor()

        # Datas
        datas_record = Record(c.execute('SELECT * FROM MetaDatas'))
        datas_list = []
        for s_name, d_type, d_frequency, s_comment, is_base in datas_record.get_variables_values('name', 'type',
                                                                                                 'frequency',
                                                                                                 'comments',
                                                                                                 'isBase'):
            metadata = MetaData()
            metadata.set_name(s_name)
            metadata.set_type(MetaVariableBaseType(d_type))
            metadata.set_frequency(d_frequency)
            metadata.set_comments(s_comment)
            metadata.set_is_base(is_base)

            vars_from_sql = Record(c.execute('SELECT * FROM MetaDataVariables WHERE data_name=?', (s_name,)))
            variables = []
            for v_name, v_type, v_unit, v_comment in vars_from_sql.get_variables_values('name', 'type', 'unit',
                                                                                        'comments'):
                if v_name not in MetaBase.get_reserved_variables_names():
                    variable = MetaDataVariable()
                    variable.set_name(v_name)
                    variable.set_type(MetaVariableBaseType(v_type))
                    variable.set_unit(v_unit)
                    variable.set_comment(v_comment)
                    variables.append(variable)
            metadata.set_variables(variables)
            datas_list.append(metadata)
        meta_informations.set_data_list(datas_list)

        # Events
        events_record = Record(c.execute('SELECT * FROM MetaEvents'))
        events_list = []
        for s_name, s_comment, is_base in events_record.get_variables_values('name', 'comments', 'isBase'):
            metaevent = MetaEvent()
            metaevent.set_name(s_name)
            metaevent.set_comments(s_comment)
            metaevent.set_is_base(is_base)

            vars_from_sql = Record(c.execute('SELECT * FROM MetaEventVariables WHERE event_name=?', (s_name,)))
            variables = []
            for v_name, v_type, v_unit, v_comment in vars_from_sql.get_variables_values('name', 'type', 'unit',
                                                                                        'comments'):
                if v_name not in MetaBase.get_reserved_variables_names():
                    variable = MetaEventVariable()
                    variable.set_name(v_name)
                    variable.set_type(MetaVariableBaseType(v_type))
                    variable.set_unit(v_unit)
                    variable.set_comment(v_comment)
                    variables.append(variable)
            metaevent.set_variables(variables)
            events_list.append(metaevent)
        meta_informations.set_event_list(events_list)

        # Situations
        situations_record = Record(c.execute('SELECT * FROM MetaSituations'))
        situations_list = []
        for s_name, s_comment, is_base in situations_record.get_variables_values('name', 'comments', 'isBase'):
            metasituation = MetaSituation()
            metasituation.set_name(s_name)
            metasituation.set_comments(s_comment)
            metasituation.set_is_base(is_base)

            vars_from_sql = Record(c.execute('SELECT * FROM MetaSituationVariables WHERE situation_name=?', (s_name,)))
            variables = []
            for v_name, v_type, v_unit, v_comment in vars_from_sql.get_variables_values('name', 'type', 'unit',
                                                                                        'comments'):
                if v_name not in MetaBase.get_reserved_variables_names():
                    variable = MetaSituationVariable()
                    variable.set_name(v_name)
                    variable.set_type(MetaVariableBaseType(v_type))
                    variable.set_unit(v_unit)
                    variable.set_comment(v_comment)
                    variables.append(variable)
            metasituation.set_variables(variables)
            situations_list.append(metasituation)
        meta_informations.set_situation_list(situations_list)

        # Participant
        participant: MetaParticipant = MetaParticipant()
        participant_record = Record(c.execute('SELECT * FROM MetaParticipantDatas'))
        for k, v in participant_record.get_variables_values('key', 'value'):
            participant.set_attribute(k, v)
        meta_informations.set_participant(participant)

        # Videos
        video_files = []
        video_record = Record(c.execute('SELECT * FROM MetaTripVideos'))
        for f, desc, offset in video_record.get_variables_values('filename', 'description', 'offset'):
            video_files.append(MetaVideoFile(f, offset, desc))
        meta_informations.set_video_files(video_files)

        # Attributes
        attributes_record = Record(c.execute('SELECT * FROM MetaTripDatas'))
        if not attributes_record.is_empty():
            meta_informations.set_trip_attributes_list(attributes_record.get_variable_values('key'))

        return meta_informations

    @_emit("DATA_CONTENT_CHANGED")
    def set_data_variable_at_time(self, data_name: str, variable_name: str, data_time: float, value: Any) -> None:
        self._check_if_is_base_data(data_name)
        data_type = self.get_data_variable_type(data_name, variable_name)
        data_value = self._check_input_type_and_convert(value, data_type)
        self._set_column_value_at_time(f"data_{data_name}", variable_name, data_time, data_value)

    @_emit("EVENT_CONTENT_CHANGED")
    def set_event_variable_at_time(self, event_name: str, variable_name: str, event_time: float, value: Any) -> None:
        self._check_if_is_base_event(event_name)
        event_type = self.get_event_variable_type(event_name, variable_name)
        event_value = self._check_input_type_and_convert(value, event_type)
        self._set_column_value_at_time(f"event_{event_name}", variable_name, event_time, event_value)

    @_emit("SITUATION_CONTENT_CHANGED")
    @_rollback
    def set_situation_variable_at_time(self, situation_name: str, variable_name: str, start_time: float,
                                       end_time: float, value: Any) -> None:
        self._check_if_is_base_situation(situation_name)
        if start_time >= end_time:
            raise pynd.ArgumentException("endTimecode must be superior and different from startTimecode. "
                                         "A situation with startTimecode == endTimecode is an event.")
        situation_type = self.get_situation_variable_type(situation_name, variable_name)
        situation_value = self._check_input_type_and_convert(value, situation_type)

        c = self.connection.cursor()
        # We try to insert the timecodes / value triplet. If the timecode pair already exist, we perform an update,
        # else it is an insert. This test is to make up for the lack of INSERT OR UPDATE in SQLite.
        r = Record(c.execute(f'SELECT "startTimecode" FROM "situation_{situation_name}" '
                             f'WHERE startTimecode = \'{start_time:.12f}\' '
                             f'AND endTimecode = \'{end_time:.12f}\''))
        if r.is_empty():
            c.execute(f'INSERT INTO "situation_{situation_name}" '
                      f'("startTimecode", "endTimeCode", "{variable_name}") '
                      f'VALUES(\'{start_time:.12f}\', \'{end_time:.12f}\', \'{situation_value}\')')
        else:
            c.execute(f'UPDATE "situation_{situation_name}" '
                      f'SET "{variable_name}" = \'{situation_value}\' '
                      f'WHERE startTimecode = \'{start_time:.12f}\' '
                      f'AND endTimecode = \'{end_time:.12f}\'')

    @_emit("DATA_CONTENT_CHANGED")
    def remove_data_occurence_at_time(self, data_name: str, timecode: float) -> None:
        self._remove_line_from_table(f"data_{data_name}", timecode)

    @_emit("DATA_CONTENT_CHANGED")
    def remove_data_occurences_in_time_interval(self, data_name: str, start_time: float, end_time: float) -> None:
        self._remove_lines_from_table(f"data_{data_name}", start_time, end_time)

    @_emit("EVENT_CONTENT_CHANGED")
    def remove_event_occurence_at_time(self, event_name: str, timecode: float) -> None:
        self._remove_line_from_table(f"event_{event_name}", timecode)

    @_emit("SITUATION_CONTENT_CHANGED")
    @_rollback
    def remove_situation_occurence_at_time(self, situation_name: str, start_time: float, end_time: float) -> None:
        self.connection.execute(f'DELETE FROM "situation_{situation_name}" '
                                f'WHERE startTimecode = \'{start_time:.12f}\' '
                                f'AND endTimecode = \'{end_time:.12f}\'')

    @_emit("DATA_CONTENT_CHANGED")
    def set_batch_of_time_data_variable_pairs(self, data_name: str, variable_name: str,
                                              time_value: List[Tuple[float, Any]]) -> None:
        self._check_if_is_base_data(data_name)
        data_type = self.get_data_variable_type(data_name, variable_name)
        cleaned_time_value = []
        for t, value in time_value:
            cleaned_time_value.append((t, self._check_input_type_and_convert(value, data_type)))
        self._set_batch_of_time_value_pairs(f"data_{data_name}", variable_name, cleaned_time_value)

    @_emit("EVENT_CONTENT_CHANGED")
    def set_batch_of_time_event_variable_pairs(self, event_name: str, variable_name: str,
                                               time_value: List[Tuple[float, Any]]) -> None:
        self._check_if_is_base_event(event_name)
        event_type = self.get_event_variable_type(event_name, variable_name)
        cleaned_time_value = []
        for t, value in time_value:
            cleaned_time_value.append((t, self._check_input_type_and_convert(value, event_type)))
        self._set_batch_of_time_value_pairs(f"event_{event_name}", variable_name, cleaned_time_value)

    @_emit("SITUATION_CONTENT_CHANGED")
    @_rollback
    def set_batch_of_time_situation_variable_triplets(self, situation_name: str, variable_name: str,
                                                      time_value: List[Tuple[float, Any]]) -> None:
        self._check_if_is_base_situation(situation_name)
        situation_type = self.get_situation_variable_type(situation_name, variable_name)
        cleaned_time_value = []
        for start_t, end_t, value in time_value:
            cleaned_time_value.append((start_t, end_t, self._check_input_type_and_convert(value, situation_type)))
            if start_t >= end_t:
                raise pynd.SituationException('endTimecode must be superior and different from startTimecode. '
                                              'A situation with startTimecode == endTimecode is an event')

        c = self.connection.cursor()
        for start_time, end_time, situation_value in cleaned_time_value:
            # We try to insert the timecode / value pair. If we catch an exception, we assume that the timecode
            # already exist, and we perform an update instead of an insert. There's no cleaner way to do it.
            r = Record(c.execute(f'SELECT "startTimecode" FROM "situation_{situation_name}" '
                                 f'WHERE startTimecode = \'{start_time:.12f}\' '
                                 f'AND endTimecode = \'{end_time:.12f}\''))
            if r.is_empty():
                c.execute(f'UPDATE "situation_{situation_name}" '
                          f'SET "{variable_name}" = \'{situation_value}\' '
                          f'WHERE startTimecode = \'{start_time:.12f}\' '
                          f'AND endTimecode = \'{end_time:.12f}\'')
            else:
                c.execute(f'INSERT INTO "situation_{situation_name}" '
                          f'("startTimecode", "endTimeCode", "{variable_name}") '
                          f'VALUES(\'{start_time:.12f}\', \'{end_time:.12f}\', \'{situation_value}\')')

    def set_event_at_time(self, event_name: str, timecode: float) -> None:
        self.set_batch_of_events_at_time(event_name, [(timecode,)])

    def set_situation_at_time(self, situation_name: str, start_time: float, end_time: float) -> None:
        self.set_batch_of_situations_at_time(situation_name, [(start_time, end_time)])

    @_rollback
    def set_batch_of_events_at_time(self, event_name: str, timecodes: List[Tuple[float]]) -> None:
        self._check_if_is_base_event(event_name)
        # We try to insert the timecode. If the timecode already exist, the event is just ignored.
        self.connection.executemany(f'INSERT OR IGNORE INTO "event_{event_name}" ("timecode") VALUES (?)',
                                    [(f'{t:.12f}',) for t in timecodes])

    @_rollback
    def set_batch_of_situations_at_time(self, situation_name: str, timecodes: List[Tuple[float, float]]) -> None:
        self._check_if_is_base_situation(situation_name)
        for start_time, end_time in timecodes:
            if start_time >= end_time:
                raise pynd.SituationException('endTimecode must be superior and different from startTimecode. '
                                              'A situation with startTimecode == endTimecode is an event.')
        # We try to insert the timecode. If the timecode already exist, the situation is just ignored.
        self.connection.executemany(f'INSERT OR IGNORE INTO "situation_{situation_name}" '
                                    f'("startTimecode", "endTimecode") VALUES (?, ?)',
                                    [(f'{st:.12f}', f'{et:.12f}') for st, et in timecodes])

    def get_max_time_in_datas(self) -> float:
        r = Record(self.connection.execute('SELECT Name FROM MetaDatas'))
        table_names = []
        for name in r.get_variable_values('name'):
            table_names.append(f'data_{name}')
        return self._get_max_value_of_variable_in_tables_list(table_names, 'timecode')

    def get_max_time_in_events(self) -> float:
        r = Record(self.connection.execute('SELECT Name FROM MetaEvents'))
        table_names = []
        for name in r.get_variable_values('name'):
            table_names.append(f'event_{name}')
        return self._get_max_value_of_variable_in_tables_list(table_names, 'timecode')

    def get_max_time_in_situations(self) -> float:
        r = Record(self.connection.execute('SELECT Name FROM MetaSituations'))
        table_names = []
        for name in r.get_variable_values('name'):
            table_names.append(f'situation_{name}')
        return self._get_max_value_of_variable_in_tables_list(table_names, 'timecode')

    @_emit("DATA_ADDED")
    @_rollback
    def add_data(self, meta_data: MetaData) -> None:
        c = self.connection.cursor()
        # Creating the table for the data
        self._create_storage_table_from_meta_base(meta_data, 'data')
        n = meta_data.get_name()
        # Creating the SQL entries in the metadatas table
        c.execute("INSERT INTO MetaDatas VALUES(?,?,?,?,?)",
                  (n, meta_data.get_type().name, meta_data.get_frequency(), meta_data.get_comments(),
                   int(meta_data.is_base())))
        c.executemany('INSERT INTO MetaDataVariables VALUES(?,?,?,?,?)',
                      [(n, v.get_name(), v.get_type().name, v.get_unit(), v.get_comments())
                       for v in meta_data.get_variables_and_framework_variables()])

    @_emit("EVENT_ADDED")
    @_rollback
    def add_event(self, meta_event: MetaEvent) -> None:
        c = self.connection.cursor()  # Creating the table for the event
        self._create_storage_table_from_meta_base(meta_event, 'event')
        n = meta_event.get_name()
        # Creating the SQL entries in the metaevents table
        c.execute("INSERT INTO MetaEvents VALUES(?,?,?)", (n, meta_event.get_comments(), int(meta_event.is_base())))
        c.executemany('INSERT INTO MetaEventVariables VALUES(?,?,?,?,?)',
                      [(n, v.get_name(), v.get_type().name, v.get_unit(), v.get_comments())
                       for v in meta_event.get_variables_and_framework_variables()])

    @_emit("SITUATION_ADDED")
    @_rollback
    def add_situation(self, meta_situation: MetaSituation) -> None:
        c = self.connection.cursor()  # Creating the table for the event
        self._create_storage_table_from_meta_base(meta_situation, 'situation')
        n = meta_situation.get_name()
        # Creating the SQL entries in the metasituations table
        c.execute("INSERT INTO MetaSituations VALUES(?,?,?)",
                  (n, meta_situation.get_comments(), int(meta_situation.is_base())))
        c.executemany('INSERT INTO MetaSituationVariables VALUES(?,?,?,?,?)',
                      [(n, v.get_name(), v.get_type().name, v.get_unit(), v.get_comments())
                       for v in meta_situation.get_variables_and_framework_variables()])

    @_emit("DATA_VARIABLE_ADDED")
    @_rollback
    def add_data_variable(self, data_name: str, meta_variable: MetaDataVariable) -> None:
        self._check_if_is_base_data(data_name)
        self._add_column_from_meta_variable_base(data_name, meta_variable, 'data')

        # Creating the SQL entries in the metadatas table
        self.connection.execute("INSERT INTO MetaDataVariables VALUES(?,?,?,?,?)", (data_name,
                                                                                    meta_variable.get_name(),
                                                                                    meta_variable.get_type().name,
                                                                                    meta_variable.get_unit(),
                                                                                    meta_variable.get_comments()))

    @_emit("EVENT_VARIABLE_ADDED")
    @_rollback
    def add_event_variable(self, event_name: str, meta_variable: MetaEventVariable) -> None:
        self._check_if_is_base_event(event_name)
        self._add_column_from_meta_variable_base(event_name, meta_variable, 'event')

        # Creating the SQL entries in the metaevents table
        self.connection.execute("INSERT INTO MetaEventVariables VALUES(?,?,?,?,?)", (event_name,
                                                                                     meta_variable.get_name(),
                                                                                     meta_variable.get_type().name,
                                                                                     meta_variable.get_unit(),
                                                                                     meta_variable.get_comments()))

    @_emit("SITUATION_VARIABLE_ADDED")
    @_rollback
    def add_situation_variable(self, situation_name: str, meta_variable: MetaSituationVariable) -> None:
        self._check_if_is_base_situation(situation_name)
        self._add_column_from_meta_variable_base(situation_name, meta_variable, 'situation')

        # Creating the SQL entries in the metasituations table
        self.connection.execute("INSERT INTO MetaSituationVariables VALUES(?,?,?,?,?)", (situation_name,
                                                                                         meta_variable.get_name(),
                                                                                         meta_variable.get_type().name,
                                                                                         meta_variable.get_unit(),
                                                                                         meta_variable.get_comments()))

    @_emit("DATA_VARIABLE_REMOVED")
    @_rollback
    def remove_data_variable(self, data_name: str, var_name: str) -> None:
        self._check_if_is_base_data(data_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaDataVariables WHERE data_name=? AND name=?", (data_name, var_name)))
        if not r.get_variable_values('name'):
            raise pynd.DataException("The variable couldn't be found in the designated data in this database and "
                                     "couldn't be deleted")
        c.execute("DELETE FROM MetaDataVariables WHERE data_name=? AND name=?", (data_name, var_name))
        self._drop_column(f'data_{data_name}', var_name)

    @_emit("EVENT_VARIABLE_REMOVED")
    @_rollback
    def remove_event_variable(self, event_name: str, var_name: str) -> None:
        self._check_if_is_base_event(event_name)
        c = self.connection.cursor()
        r = Record(
            c.execute("SELECT name FROM MetaEventVariables WHERE event_name=? AND name=?", (event_name, var_name)))
        if not r.get_variable_values('name'):
            raise pynd.EventException("The variable couldn't be found in the designated event in this database and "
                                      "couldn't be deleted")
        c.execute("DELETE FROM MetaEventVariables WHERE event_name=? AND name=?", (event_name, var_name))
        self._drop_column(f'event_{event_name}', var_name)

    @_emit("SITUATION_VARIABLE_REMOVED")
    @_rollback
    def remove_situation_variable(self, situation_name: str, var_name: str) -> None:
        self._check_if_is_base_situation(situation_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaSituationVariables WHERE situation_name=? AND name=?",
                             (situation_name, var_name)))
        if not r.get_variable_values('name'):
            raise pynd.SituationException("The variable couldn't be found in the designated situation in this database "
                                          "and couldn't be deleted")
        c.execute("DELETE FROM MetaSituationVariables WHERE situation_name=? AND name=?", (situation_name, var_name))
        self._drop_column(f'situation_{situation_name}', var_name)

    @_emit("DATA_REMOVED")
    @_rollback
    def remove_data(self, data_name: str) -> None:
        self._check_if_is_base_data(data_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaDatas WHERE name=?", (data_name,)))
        if not r.get_variable_values('name'):
            raise pynd.DataException("The data was not found in this database and couldn't be deleted")
        c.execute("DELETE FROM MetaDatas WHERE name=?", (data_name,))
        c.execute("DELETE FROM MetaDataVariables WHERE data_name=?", (data_name,))
        c.execute(f'DROP TABLE "data_{data_name}"')

    @_emit("EVENT_REMOVED")
    @_rollback
    def remove_event(self, event_name: str) -> None:
        self._check_if_is_base_event(event_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaEvents WHERE name=?", (event_name,)))
        if not r.get_variable_values('name'):
            raise pynd.EventException("The event was not found in this database and couldn't be deleted")
        c.execute("DELETE FROM MetaEvents WHERE name=?", (event_name,))
        c.execute("DELETE FROM MetaEventVariables WHERE event_name=?", (event_name,))
        c.execute(f'DROP TABLE "event_{event_name}"')

    @_emit("SITUATION_REMOVED")
    @_rollback
    def remove_situation(self, situation_name: str) -> None:
        self._check_if_is_base_situation(situation_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaSituations WHERE name=?", (situation_name,)))
        if not r.get_variable_values('name'):
            raise pynd.SituationException("The situation was not found in this database and couldn't be deleted")
        c.execute("DELETE FROM MetaSituations WHERE name=?", (situation_name,))
        c.execute("DELETE FROM MetaSituationVariables WHERE situation_name=?", (situation_name,))
        c.execute(f'DROP TABLE "situation_{situation_name}"')

    def get_attribute(self, attribute_name: str) -> str:
        r = Record(self.connection.execute("SELECT value FROM MetaTripDatas WHERE key=?", (attribute_name,)))
        if r.is_empty():
            raise pynd.MetaInfosException("The requested attribute wasn't found in the database")
        else:
            return r.get_variable_values('value')[0]

    @_emit("TRIP_META_CHANGED")
    @_rollback
    def set_attribute(self, attribute_name: str, attribute_value: str) -> None:
        c = self.connection.cursor()
        r = Record(c.execute("SELECT * FROM MetaTripDatas WHERE key=?", (attribute_name,)))
        if not r.get_variable_values('key'):
            request = f"INSERT INTO MetaTripDatas VALUES('{attribute_name}','{attribute_value}')"
        else:
            request = f"UPDATE MetaTripDatas SET value='{attribute_value}' WHERE key='{attribute_name}'"
        c.execute(request)

    @_emit("TRIP_META_CHANGED")
    @_rollback
    def remove_attribute(self, attribute_name: str) -> None:
        c = self.connection.cursor()
        r = Record(c.execute("SELECT * FROM MetaTripDatas WHERE key=?", (attribute_name,)))
        if not r.get_variable_values('key'):
            raise pynd.MetaInfosException("Can't remove the requested attribute as it doesn't exist in the database")
        c.execute("DELETE FROM MetaTripDatas WHERE key=?", (attribute_name,))

    @_emit("TRIP_META_CHANGED")
    @_rollback
    def add_video_file(self, video_file: MetaVideoFile) -> None:
        c = self.connection.cursor()
        video_fn = video_file.get_file_name()
        if not video_fn.startswith('.'):
            raise pynd.ArgumentException("This implementation of Trip supports only adding videos whose path is "
                                         "relative to the path of the .trip file. No absolute path is allowed.")
        r = Record(c.execute("SELECT * FROM MetaTripVideos WHERE filename=?", (video_fn,)))
        if not r.get_variable_values('filename'):
            c.execute("INSERT INTO MetaTripVideos VALUES(?,?,?)",
                      (video_file.get_file_name(), video_file.get_offset(), video_file.get_description()))
        else:
            c.execute("UPDATE MetaTripVideos SET offset=?, description=? WHERE filename=?",
                      (video_file.get_offset(), video_file.get_description(), video_file.get_file_name()))

    @_rollback
    def update_medta_data_variable(self, data_name: str, meta_data_variable: MetaDataVariable) -> None:
        self._check_if_is_base_data(data_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaDatas WHERE name=?", (data_name,)))
        if not r.get_variable_values('name'):
            raise pynd.DataException("The data was not found in this database and couldn't be updated")
        r = Record(c.execute("SELECT name FROM MetaDataVariables WHERE data_name=? AND name=?",
                             (data_name, meta_data_variable.get_name())))
        if r.get_variable_values('name'):
            raise pynd.DataException("The variable was not found in this database and couldn't be updated")
        c.execute("UPDATE MetaDataVariables SET type=?, unit=?, comments=? WHERE data_name=? AND name=?",
                  (meta_data_variable.get_type().name,
                   meta_data_variable.get_unit(),
                   meta_data_variable.get_comments(),
                   data_name,
                   meta_data_variable.get_name()))

    @_emit("DATA_ADDED")
    @_rollback
    def update_meta_data(self, meta_data: MetaData) -> None:
        data_name = meta_data.get_name()
        self._check_if_is_base_data(data_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaDatas WHERE name=?", (data_name,)))
        if not r.get_variable_values('name'):
            raise pynd.DataException("The data was not found in this database and couldn't be updated")
        c.execute("UPDATE MetaDatas SET type=?, frequency=?, comments=? WHERE name=?",
                  (meta_data.get_type().name, meta_data.get_frequency(), meta_data.get_comments(), data_name))
        for v in meta_data.get_variables():
            self.update_medta_data_variable(v)

    @_rollback
    def update_medta_event_variable(self, event_name: str, meta_event_variable: MetaEventVariable) -> None:
        self._check_if_is_base_event(event_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaEvents WHERE name=?", (event_name,)))
        if not r.get_variable_values('name'):
            raise pynd.EventException("The event was not found in this database and couldn't be updated")
        r = Record(c.execute("SELECT name FROM MetaEventVariables WHERE event_name=? AND name=?",
                             (event_name, meta_event_variable.get_name())))
        if r.get_variable_values('name'):
            raise pynd.EventException("The variable was not found in this database and couldn't be updated")
        c.execute("UPDATE MetaEventVariables SET type=?, unit=?, comments=? WHERE event_name=? AND name=?",
                  (meta_event_variable.get_type().name,
                   meta_event_variable.get_unit(),
                   meta_event_variable.get_comments(),
                   event_name,
                   meta_event_variable.get_name()))

    @_emit("EVENT_ADDED")
    @_rollback
    def update_meta_event(self, meta_event: MetaEvent) -> None:
        event_name = meta_event.get_name()
        self._check_if_is_base_event(event_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaEvents WHERE name=?", (event_name,)))
        if not r.get_variable_values('name'):
            raise pynd.EventException("The event was not found in this database and couldn't be updated")
        c.execute("UPDATE MetaEvents SET comments=? WHERE name=?", (meta_event.get_comments(), event_name))
        for v in meta_event.get_variables():
            self.update_medta_event_variable(v)

    @_rollback
    def update_medta_situation_variable(self, situation_name: str,
                                        meta_situation_variable: MetaSituationVariable) -> None:
        self._check_if_is_base_situation(situation_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaSituations WHERE name=?", (situation_name,)))
        if not r.get_variable_values('name'):
            raise pynd.SituationException("The situation was not found in this database and couldn't be updated")
        r = Record(c.execute("SELECT name FROM MetaSituationVariables WHERE situation_name=? AND name=?",
                             (situation_name, meta_situation_variable.get_name())))
        if r.get_variable_values('name'):
            raise pynd.SituationException("The variable was not found in this database and couldn't be updated")
        c.execute("UPDATE MetaSituationVariables SET type=?, unit=?, comments=? WHERE situation_name=? AND name=?",
                  (meta_situation_variable.get_type().name,
                   meta_situation_variable.get_unit(),
                   meta_situation_variable.get_comments(),
                   situation_name,
                   meta_situation_variable.get_name()))

    @_emit("SITUATION_ADDED")
    @_rollback
    def update_meta_situation(self, meta_situation: MetaSituation) -> None:
        situation_name = meta_situation.get_name()
        self._check_if_is_base_situation(situation_name)
        c = self.connection.cursor()
        r = Record(c.execute("SELECT name FROM MetaSituations WHERE name=?", (situation_name,)))
        if not r.get_variable_values('name'):
            raise pynd.SituationException("The situation was not found in this database and couldn't be updated")
        c.execute("UPDATE MetaSituations SET comments=? WHERE name=?", (meta_situation.get_comments(), situation_name))
        for v in meta_situation.get_variables():
            self.update_medta_situation_variable(v)

    @_emit("TRIP_META_CHANGED")
    @_rollback
    def remove_video_file(self, file_name: str) -> None:
        c = self.connection.cursor()
        r = Record(c.execute("SELECT * FROM MetaTripVideos WHERE filename=?", (file_name,)))
        if not r.get_variable_values('filename'):
            raise pynd.MetaInfosException("Can''t remove video file as it doesn't exist in the database")
        c.execute("DELETE FROM MetaTripVideos WHERE filename=?", (file_name,))

    @_emit("TRIP_META_CHANGED")
    @_rollback
    def set_participant(self, participant: MetaParticipant) -> None:
        c = self.connection.cursor()
        for k, v in participant.get_attributes():
            r = Record(c.execute("SELECT key FROM MetaParticipantDatas WHERE key=?", (k,)))
            if r.is_empty():
                c.execute("INSERT INTO MetaParticipantDatas SET value=? WHERE key=?", (v, k))
            else:
                c.execute("UPDATE MetaParticipantDatas (key, value) VALUES (?,?)", (k, v))

    @_rollback
    def set_frequency_data(self, data_name: str, frequency: float) -> None:
        c = self.connection.cursor()
        r = Record(c.execute("SELECT frequency FROM MetaDatas WHERE name=?", (data_name,)))
        if not r.get_variable_values('frequency'):
            raise pynd.MetaInfosException("Can't set frequency value as the data doesn't exist in the database")
        c.execute("UPDATE MetaDatas SET frequency=? WHERE name=?", (frequency, data_name))

    @_rollback
    def set_is_base_data(self, data_name: str, is_base: bool) -> None:
        c = self.connection.cursor()
        r = Record(c.execute("SELECT isBase FROM MetaDatas WHERE name=?", (data_name,)))
        if not r.get_variable_values('isBase'):
            raise pynd.MetaInfosException("Can't set isBase value as the data doesn't exist in the database")
        c.execute("UPDATE MetaDatas SET isBase=? WHERE name=?", (str(int(is_base)), data_name))

    @_rollback
    def set_is_base_event(self, event_name: str, is_base: bool) -> None:
        c = self.connection.cursor()
        r = Record(c.execute("SELECT isBase FROM MetaEvents WHERE name=?", (event_name,)))
        if not r.get_variable_values('isBase'):
            raise pynd.MetaInfosException("Can't set isBase value as the event doesn't exist in the database")
        c.execute("UPDATE MetaEvents SET isBase=? WHERE name=?", (str(int(is_base)), event_name))

    @_rollback
    def set_is_base_situation(self, situation_name: str, is_base: bool) -> None:
        c = self.connection.cursor()
        r = Record(c.execute("SELECT isBase FROM MetaSituations WHERE name=?", (situation_name,)))
        if not r.get_variable_values('isBase'):
            raise pynd.MetaInfosException("Can't set isBase value as the situation doesn't exist in the database")
        c.execute("UPDATE MetaSituations SET isBase=? WHERE name=?", (str(int(is_base)), situation_name))

    def get_data_variable_type(self, data_name: str, variable_name: str) -> MetaVariableBaseType:
        r = Record(self.connection.execute("SELECT type FROM MetaDataVariables WHERE data_name=? and name=?",
                                           (data_name, variable_name)))
        t = r.get_variable_values('type')
        if not t:
            raise pynd.ArgumentException("Could not find type for the variable")
        return MetaVariableBaseType(t[0])

    def get_event_variable_type(self, event_name: str, variable_name: str) -> MetaVariableBaseType:
        r = Record(self.connection.execute("SELECT type FROM MetaEventVariables WHERE event_name=? and name=?",
                                           (event_name, variable_name)))
        t = r.get_variable_values('type')
        if not t:
            raise pynd.ArgumentException("Could not find type for the variable")
        return MetaVariableBaseType(t[0])

    def get_situation_variable_type(self, situation_name: str, variable_name: str) -> MetaVariableBaseType:
        r = Record(self.connection.execute("SELECT type FROM MetaSituationVariables WHERE situation_name=? and name=?",
                                           (situation_name, variable_name)))
        t = r.get_variable_values('type')
        if not t:
            raise pynd.ArgumentException("Could not find type for the variable")
        return MetaVariableBaseType(t[0])

    @staticmethod
    def _check_input_type_and_convert(value: Any, t: MetaVariableBaseType) -> Any:
        if t == MetaVariableBaseType.REAL:
            return float(value)
        elif t == MetaVariableBaseType.TEXT:
            return str(value)
        elif t == MetaVariableBaseType.NONE:
            raise pynd.ArgumentException("Can't convert to NONE type")
        else:
            raise pynd.ArgumentException("Unknown destination type")

    @_rollback
    def _remove_line_from_table(self, table_name: str, timecode: float) -> None:
        self.connection.execute(f"DELETE FROM {table_name} WHERE timecode={timecode:.12f}")

    @_rollback
    def _remove_lines_from_table(self, table_name: str, start_time: float, end_time: float):
        self.connection.execute(f"DELETE FROM {table_name} "
                                f"WHERE timecode BETWEEN {start_time:.12f} AND {end_time:.12f}")

    @_rollback
    def _add_column_from_meta_variable_base(self, data_name: str, meta_variable_base: MetaVariableBase,
                                            prefix: str) -> None:
        table_name: str = f"{prefix}_{data_name}"
        var_name: str = meta_variable_base.get_name()
        var_type = meta_variable_base.get_type().name
        self.connection.execute(f'ALTER TABLE {table_name} ADD COLUMN "{var_name}" {var_type}')
        self._create_index(table_name, var_name)

    @_rollback
    def _create_storage_table_from_meta_base(self, meta_base: MetaBase, prefix: str) -> None:
        name = meta_base.get_name()
        if not name:
            raise pynd.ArgumentException("MetaBase object name musn't be empty")

        # Building request
        table_name = f"{prefix}_{name}"
        create_request = f"CREATE TABLE {table_name} ("
        for v in meta_base.get_variables_and_framework_variables():
            create_request += f'"{v.get_name()}" {v.get_type().name}, '
        create_request += "PRIMARY KEY("
        for v in meta_base.get_framework_variables():
            create_request += f"{v.get_name()}, "
        # Removing last comma
        create_request = create_request[:-2]
        create_request += "))"

        # Executing request
        self.connection.execute(create_request)

        for v in meta_base.get_variables_and_framework_variables():
            self._create_index(table_name, v.get_name())

    @_rollback
    def _set_batch_of_time_value_pairs(self, table_name: str, column_name: str,
                                       time_values: List[Tuple[float, Any]]) -> None:
        c = self.connection.cursor()
        # c.execute("PRAGMA synchronous = OFF")
        # c.execute("PRAGMA journal_mode = MEMORY")

        check_existence_statement = f'SELECT rowid FROM "{table_name}" WHERE timecode=?'
        update_statement = f'UPDATE "{table_name}" SET "{column_name}"=? WHERE timecode=?'
        insert_statement = f'INSERT INTO "{table_name}" (timecode,"{column_name}") VALUES (?,?)'

        for t, v in time_values:
            formatted_t = f'{t:.12f}'
            r = Record(c.execute(check_existence_statement, (formatted_t,)))
            if r.is_empty():
                c.execute(insert_statement, (formatted_t, v))
            else:
                c.execute(update_statement, (v, formatted_t))

        # c.execute("PRAGMA synchronous = ON")
        # c.execute("PRAGMA journal_mode = DELETE")

    def _set_column_value_at_time(self, table_name: str, column_name: str, time: float, value: Any) -> None:
        self._set_batch_of_time_value_pairs(table_name, column_name, [(time, value)])

    def _get_column_in_time_interval(self, table_name: str, column_name: str, start_time: float,
                                     end_time: float) -> Record:
        return Record(self.connection.execute(f'SELECT "{column_name}", timecode '
                                              f'FROM "{table_name}" '
                                              f'WHERE timecode BETWEEN {start_time:.12f} AND {end_time:.12f} '
                                              f'ORDER BY timecode ASC'))

    def _get_max_value_of_variable_in_tables_list(self, table_names: List[str], column_name: str) -> float:
        maxis: List[float] = []
        for table_name in table_names:
            maxi: float = self._get_column_maximum(table_name, column_name)
            if not math.isnan(maxi):
                maxis.append(maxi)
        return max(maxis)

    def _get_column_maximum(self, table_name: str, column_name: str) -> float:
        # TODO check nan conversion from Python to SQLite
        r = Record(self.connection.execute(f'SELECT MAX({column_name} AS "{column_name}" '
                                           f'FROM "{table_name}" '
                                           f'WHERE "{column_name}" <> "NaN"'))
        values = r.get_variable_values(column_name)
        if not values:
            return float('nan')
        return values[0]

    def _get_column_minimum(self, table_name: str, column_name: str) -> float:
        r = Record(self.connection.execute(f'SELECT MIN({column_name} AS "{column_name}" '
                                           f'FROM "{table_name}" '
                                           f'WHERE "{column_name}" <> "NaN"'))
        values = r.get_variable_values(column_name)
        if not values:
            return float('nan')
        return values[0]

    def _get_lines_in_time_interval(self, table_name: str, start_time: float, end_time: float) -> Record:
        return Record(self.connection.execute(f'SELECT * FROM "{table_name}" '
                                              f'WHERE timecode BETWEEN {start_time:.12f} AND {end_time:.12f} '
                                              f'ORDER BY "timecode" ASC'))

    def _get_line_at_time(self, table_name: str, timecode: float) -> Record:
        r = Record(self.connection.execute(f'SELECT * FROM {table_name} WHERE timecode={timecode:.12f}'))
        if not r.get_variable_values('timecode'):
            raise pynd.ContentException('The time code was not found in the table')
        return r

    def _get_line_near_time(self, table_name: str, timecode: float) -> Record:
        c = self.connection.cursor()
        r = Record(c.execute(f'SELECT timecode FROM "{table_name}" '
                             f'ORDBER BY ABS(timecode-{timecode:.12f}) ASC LIMIT 1'))
        closest_timecode = r.get_variable_values('timecode')[0]
        return Record(c.execute(f'SELECT * FROM "{table_name}" WHERE timecode={closest_timecode:.12f}'))

    def _get_table_content(self, table_name: str) -> Record:
        return Record(self.connection.execute(f'SELECT * FROM "{table_name}" ORDER BY timecode ASC'))

    def _remove_table_content(self, table_name: str) -> None:
        self.connection.execute(f'DELETE FROM "{table_name}"')

    def _check_if_is_base_data(self, data_name: str) -> None:
        r = Record(self.connection.execute(f'SELECT isBase FROM MetaDatas WHERE name=?', (data_name,)))
        try:
            if r.get_variable_values('isBase')[0]:
                raise pynd.DataException("Modification of data could not be performed because this data is marked as "
                                         "base")
        except IndexError:
            raise pynd.DataException("The data was not found in this database")

    def _check_if_is_base_event(self, event_name: str) -> None:
        r = Record(self.connection.execute(f'SELECT isBase FROM MetaEvents WHERE name=?', (event_name,)))
        try:
            if r.get_variable_values('isBase')[0]:
                raise pynd.EventException("Modification of event could not be performed because this event is marked "
                                          "as base")
        except IndexError:
            raise pynd.EventException("The event was not found in this database")

    def _check_if_is_base_situation(self, situation_name: str) -> None:
        r = Record(self.connection.execute(f'SELECT isBase FROM MetaSituations WHERE name=?', (situation_name,)))
        try:
            if r.get_variable_values('isBase')[0]:
                raise pynd.SituationException("Modification of situation could not be performed because this "
                                              "situation is marked as base")
        except IndexError:
            raise pynd.SituationException("The situation was not found in this database")

    @_rollback
    def _drop_column(self, table_name: str, column_name: str) -> None:
        c = self.connection.cursor()
        r = Record(c.execute(f'PRAGMA table_info("{table_name}")'))
        var_list = r.get_variable_values('name')

        if column_name not in var_list:
            raise pynd.ArgumentException("The column was not found in the specified table")

        var_list.remove(column_name)
        table_name_temp = f'{table_name}_temp'
        create_request = f'CREATE TABLE "{table_name_temp}" ('
        insert_request = f'INSERT INTO "{table_name_temp}" SELECT '

        for name, pk, t in r.get_variables_values('name', 'pk', 'type'):
            if name == column_name:
                continue
            if pk:
                is_unique = 'UNIQUE '
            else:
                is_unique = ''
            create_request += f'"{name}" {t} {is_unique}, '
            insert_request += f'"{name}", '

        # Removing extra comma
        create_request = create_request[:-2]
        insert_request = insert_request[:-2]

        create_request += ')'
        insert_request += f' FROM "{table_name}"'

        c.execute(create_request)
        c.execute(insert_request)
        c.execute(f'DROP TABLE "{table_name}"')
        c.execute(f'ALTER TABLE "{table_name_temp}" RENAME TO "{table_name}"')

        for v in var_list:
            self._create_index(table_name, v)

    def _create_index(self, table_name: str, column_name: str) -> None:
        self.connection.execute(f'CREATE INDEX "index_{table_name}_{column_name}" ON "{table_name}" ("{column_name}")')

    def _remove_index(self, table_name: str, column_name: str) -> None:
        self.connection.execute(f'DROP INDEX "index_{table_name}_{column_name}"')

    _rollback = staticmethod(_rollback)
    _emit = staticmethod(_emit)

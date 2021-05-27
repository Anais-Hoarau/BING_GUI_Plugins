import os
import unittest
from tempfile import TemporaryDirectory

import pynd
from pynd.kernel.implementation import SQLiteTrip
from pynd.data import MetaData, MetaDataVariable, MetaVariableBaseType, MetaEvent, MetaEventVariable, MetaSituation, \
    MetaSituationVariable, MetaVideoFile


class SQLiteTripTest(unittest.TestCase):

    def setUp(self):
        self.temp_dir = TemporaryDirectory()
        self.trip_file = os.path.join(self.temp_dir.name, "test.trip")
        self.trip = SQLiteTrip(self.trip_file, 0.04, True)

    def tearDown(self):
        self.trip.release()
        self.temp_dir.cleanup()

    def testAttributes(self):
        self.trip.set_attribute("testAttr", "42")
        self.assertEqual("42", self.trip.get_attribute("testAttr"))
        self.trip.set_attribute("testAttr", "45")
        self.assertEqual("45", self.trip.get_attribute("testAttr"))
        self.trip.remove_attribute("testAttr")
        # TODO Better exceptions
        self.assertRaises(pynd.MetaInfosException, self.trip.get_attribute, "testAttr")
        self.assertRaises(pynd.MetaInfosException, self.trip.get_attribute, "toto")
        self.assertRaises(pynd.MetaInfosException, self.trip.remove_attribute, "bob")

    def testDataAndDataVariablesManagement(self):
        d1: MetaData = MetaData()
        d1.set_name("data1")

        d1v1 = MetaDataVariable()
        d1v1.set_name("d1v1")
        d1v1.set_type(MetaVariableBaseType.TEXT)

        d1v2 = MetaDataVariable()
        d1v2.set_name("d1v2")
        d1v2.set_type(MetaVariableBaseType.REAL)

        d1v3 = MetaDataVariable()
        d1v3.set_name("d1v3")

        d1.set_variables([d1v1, d1v2, d1v3])

        d2: MetaData = MetaData()
        d2.set_name("data2")

        d2v1 = MetaDataVariable()
        d2v1.set_name("d2v1")
        d2v1.set_type(MetaVariableBaseType.TEXT)

        d2v2 = MetaDataVariable()
        d2v2.set_name("d2v2")
        d2v2.set_type(MetaVariableBaseType.TEXT)

        d2.set_variables([d2v1, d2v2])

        self.trip.add_data(d1)
        self.trip.add_data(d2)

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_datas_names_list(), ['data1', 'data2'])

        # Check data1
        meta_vars = meta_infos.get_meta_data("data1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "d1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["d1v2", "d1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check data2
        meta_vars = meta_infos.get_meta_data("data2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["d2v1", "d2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        # Removing d1v3
        self.trip.remove_data_variable('data1', 'd1v3')

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_datas_names_list(), ['data1', 'data2'])

        # Check data1
        meta_vars = meta_infos.get_meta_data("data1").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "d1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name == "d1v2":
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check data2
        meta_vars = meta_infos.get_meta_data("data2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["d2v1", "d2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        # Add back d1v3
        self.trip.add_data_variable('data1', d1v3)

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_datas_names_list(), ['data1', 'data2'])

        # Check data1
        meta_vars = meta_infos.get_meta_data("data1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "d1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["d1v2", "d1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check data2
        meta_vars = meta_infos.get_meta_data("data2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["d2v1", "d2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        self.trip.remove_data('data2')

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_datas_names_list(), ['data1'])
        
        # Check data1
        meta_vars = meta_infos.get_meta_data("data1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "d1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["d1v2", "d1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        self.assertRaises(pynd.DataException, self.trip.remove_data, 'non_data')
        self.assertRaises(pynd.DataException, self.trip.remove_data_variable, 'non_data', 'non_var')
        self.assertRaises(pynd.DataException, self.trip.remove_data_variable, 'data1', 'non_var')

    def testEventAndEventVariablesManagement(self):
        e1: MetaEvent = MetaEvent()
        e1.set_name("event1")

        e1v1 = MetaEventVariable()
        e1v1.set_name("e1v1")
        e1v1.set_type(MetaVariableBaseType.TEXT)

        e1v2 = MetaEventVariable()
        e1v2.set_name("e1v2")
        e1v2.set_type(MetaVariableBaseType.REAL)

        e1v3 = MetaEventVariable()
        e1v3.set_name("e1v3")

        e1.set_variables([e1v1, e1v2, e1v3])

        e2: MetaEvent = MetaEvent()
        e2.set_name("event2")

        e2v1 = MetaEventVariable()
        e2v1.set_name("e2v1")
        e2v1.set_type(MetaVariableBaseType.TEXT)

        e2v2 = MetaEventVariable()
        e2v2.set_name("e2v2")
        e2v2.set_type(MetaVariableBaseType.TEXT)

        e2.set_variables([e2v1, e2v2])

        self.trip.add_event(e1)
        self.trip.add_event(e2)

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_events_names_list(), ['event1', 'event2'])

        # Check event1
        meta_vars = meta_infos.get_meta_event("event1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "e1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["e1v2", "e1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check event2
        meta_vars = meta_infos.get_meta_event("event2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["e2v1", "e2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        # Removing e1v3
        self.trip.remove_event_variable('event1', 'e1v3')

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_events_names_list(), ['event1', 'event2'])

        # Check event1
        meta_vars = meta_infos.get_meta_event("event1").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "e1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name == "e1v2":
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check event2
        meta_vars = meta_infos.get_meta_event("event2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["e2v1", "e2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        # Add back e1v3
        self.trip.add_event_variable('event1', e1v3)

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_events_names_list(), ['event1', 'event2'])

        # Check event1
        meta_vars = meta_infos.get_meta_event("event1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "e1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["e1v2", "e1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check event2
        meta_vars = meta_infos.get_meta_event("event2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["e2v1", "e2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        self.trip.remove_event('event2')

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_events_names_list(), ['event1'])
        
        # Check event1
        meta_vars = meta_infos.get_meta_event("event1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "e1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["e1v2", "e1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        self.assertRaises(pynd.EventException, self.trip.remove_event, 'non_event')
        self.assertRaises(pynd.EventException, self.trip.remove_event_variable, 'non_event', 'non_var')
        self.assertRaises(pynd.EventException, self.trip.remove_event_variable, 'event1', 'non_var')

    def testSituationAndSituationVariablesManagement(self):
        s1: MetaSituation = MetaSituation()
        s1.set_name("situation1")

        s1v1 = MetaSituationVariable()
        s1v1.set_name("s1v1")
        s1v1.set_type(MetaVariableBaseType.TEXT)

        s1v2 = MetaSituationVariable()
        s1v2.set_name("s1v2")
        s1v2.set_type(MetaVariableBaseType.REAL)

        s1v3 = MetaSituationVariable()
        s1v3.set_name("s1v3")

        s1.set_variables([s1v1, s1v2, s1v3])

        s2: MetaSituation = MetaSituation()
        s2.set_name("situation2")

        s2v1 = MetaSituationVariable()
        s2v1.set_name("s2v1")
        s2v1.set_type(MetaVariableBaseType.TEXT)

        s2v2 = MetaSituationVariable()
        s2v2.set_name("s2v2")
        s2v2.set_type(MetaVariableBaseType.TEXT)

        s2.set_variables([s2v1, s2v2])

        self.trip.add_situation(s1)
        self.trip.add_situation(s2)

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_situations_names_list(), ['situation1', 'situation2'])

        # Check situation1
        meta_vars = meta_infos.get_meta_situation("situation1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "s1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["s1v2", "s1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check situation2
        meta_vars = meta_infos.get_meta_situation("situation2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["s2v1", "s2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        # Removing s1v3
        self.trip.remove_situation_variable('situation1', 's1v3')

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_situations_names_list(), ['situation1', 'situation2'])

        # Check situation1
        meta_vars = meta_infos.get_meta_situation("situation1").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "s1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name == "s1v2":
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check situation2
        meta_vars = meta_infos.get_meta_situation("situation2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["s2v1", "s2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        # Add back s1v3
        self.trip.add_situation_variable('situation1', s1v3)

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_situations_names_list(), ['situation1', 'situation2'])

        # Check situation1
        meta_vars = meta_infos.get_meta_situation("situation1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "s1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["s1v2", "s1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        # Check situation2
        meta_vars = meta_infos.get_meta_situation("situation2").get_variables()
        self.assertEqual(len(meta_vars), 2)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name in ["s2v1", "s2v2"]:
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            else:
                self.assertTrue(False)

        self.trip.remove_situation('situation2')

        meta_infos = self.trip.get_meta_informations()
        self.assertListEqual(meta_infos.get_situations_names_list(), ['situation1'])
        
        # Check situation1
        meta_vars = meta_infos.get_meta_situation("situation1").get_variables()
        self.assertEqual(len(meta_vars), 3)
        for meta_var in meta_vars:
            name = meta_var.get_name()
            t = meta_var.get_type()
            if name == "s1v1":
                self.assertEqual(t, MetaVariableBaseType.TEXT)
            elif name in ["s1v2", "s1v3"]:
                self.assertEqual(t, MetaVariableBaseType.REAL)
            else:
                self.assertTrue(False)

        self.assertRaises(pynd.SituationException, self.trip.remove_situation, 'non_situation')
        self.assertRaises(pynd.SituationException, self.trip.remove_situation_variable, 'non_situation', 'non_var')
        self.assertRaises(pynd.SituationException, self.trip.remove_situation_variable, 'situation1', 'non_var')

    def testVideoFilesManagement(self):
        video_file: MetaVideoFile = MetaVideoFile('./toto.avi', 0, 'A video file')
        self.trip.add_video_file(video_file)
        meta_infos = self.trip.get_meta_informations()
        self.assertEqual(1, len(meta_infos.get_video_files()))
        video_file_from_trip = meta_infos.get_video_files()[0]
        self.assertEqual('./toto.avi', video_file_from_trip.get_file_name())
        self.assertEqual(0., video_file_from_trip.get_offset())
        self.assertEqual('A video file', video_file_from_trip.get_description())

        # Removing file
        self.trip.remove_video_file('./toto.avi')
        self.assertEqual(0, len(self.trip.get_meta_informations().get_video_files()))

        # Add again
        self.trip.add_video_file(video_file)
        meta_infos = self.trip.get_meta_informations()
        self.assertEqual(1, len(meta_infos.get_video_files()))
        video_file_from_trip = meta_infos.get_video_files()[0]
        self.assertEqual('./toto.avi', video_file_from_trip.get_file_name())
        self.assertEqual(0., video_file_from_trip.get_offset())
        self.assertEqual('A video file', video_file_from_trip.get_description())

        # Modify
        video_file.set_description("A very nice video file")
        self.trip.add_video_file(video_file)
        meta_infos = self.trip.get_meta_informations()
        self.assertEqual(1, len(meta_infos.get_video_files()))
        video_file_from_trip = meta_infos.get_video_files()[0]
        self.assertEqual('./toto.avi', video_file_from_trip.get_file_name())
        self.assertEqual(0., video_file_from_trip.get_offset())
        self.assertEqual('A very nice video file', video_file_from_trip.get_description())

        # Abs path
        video_file.set_file_name(r'c:\toto.avi')
        self.assertRaises(pynd.ArgumentException, self.trip.add_video_file, video_file)
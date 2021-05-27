"""
All structured data classes and their loaders
"""
import csv
import os
import numpy as np
import logging as log
import math
from collections import defaultdict

from dirs import DIR_DOC, DIR_DATA_SIMU
from split_raw_simu_data import DUPLICATE_SCENARIO_SEPARATOR, str2time


def read_csv_line(csv_file, has_header=False, delim=";"):
    """
    Yields lines from a CSV file
    :param csv_file: Full path of the csv file
    :return:
    """
    with open(csv_file) as f:
        reader = csv.reader(f, delimiter=delim)
        if has_header:
            next(reader)
        for l in reader:
            yield l


def floatify(f):
    return float(f.replace(',', '.'))


def clean_scenario_name(n):
    n = n[11:]
    if n.startswith("2_"):
        n = n[2:]
    return n


def load_structured_csv(csv_file, data_type, has_header=False, delim=";"):
    """
    Loads a CSV and yields it as objects
    :param csv_file: CSV file to load
    :param data_type: Type to load the CSV rows into
    :param has_header: Whether the CSV file has a header
    :param delim: CSV file columbs delimiter
    :return:
    """
    for l in read_csv_line(csv_file, has_header, delim):
        yield data_type(*l)


def build_scenario_path(subject, scenario, src_dir=DIR_DATA_SIMU):
    """
    Builds the path where to find the simu data for the subject and scenario. Takes into account errors that occured
    during scenarios to only returns the valid one
    :param subject:
    :param scenario:
    :param src_dir:
    :return:
    """
    # Finding which prefix is used for this subject
    prefixes = ["", "EvtRoute90_", "EvtRoute90_2_"]
    base_path = None
    for prefix in prefixes:
        p = os.path.join(src_dir, subject, prefix + scenario)
        if os.path.exists(p):
            if base_path is not None:
                log.error("{subject} has two scenarios named {scenario} with different prefixes".format(subject=subject,
                                                                                                        scenario=scenario))
            base_path = p

    # No scenario found with any prefix
    if base_path is None:
        raise IOError("{subject} has no scenario named {scenario}".format(subject=subject, scenario=scenario))

    # Finding possible scenario duplicates due to simulation issues. We need to return the last one
    i = 1
    current_path = base_path
    next_path = current_path
    while os.path.exists(next_path):
        current_path = next_path
        next_path = base_path + DUPLICATE_SCENARIO_SEPARATOR + str(i)
        i += 1
    return current_path


def sort_by(some_list, *items):
    """
    Returns the given list as a dict based on list element's attributes. For example, if you have a list of objects
    which have "scenario" and "subjects" attribute, you can use this method to convert it to a dict shaped like:
    dict[scenario][subject] = object
    :param some_list: List you want to order as dict
    :param items: Ordered list of items from which the dict will take its structure
    :return: The structured dict, with items as layers
    """
    l = lambda: defaultdict(l)
    count = len(items)
    sorted_dict = l()
    for el in some_list:
        sub_dict = sorted_dict
        for i, item in enumerate(items):
            if i == count - 1:
                sub_dict[el.__getattribute__(item)] = el
            else:
                sub_dict = sub_dict[el.__getattribute__(item)]
    return sorted_dict


class Vehicule:
    """
    Information about a vehicule's pose
    """

    def __init__(self, pos, rot=None, speed=None, acc=None, timestamp=None):
        self.pos = self.build_vector(pos)
        self.rot = self.build_vector(rot)
        self.speed = self.build_vector(speed)
        self.acc = self.build_vector(acc)
        self.timestamp = str2time(timestamp) if timestamp is not None else None

    @staticmethod
    def build_vector(v):
        if v is None:
            return None
        return np.array([floatify(i) for i in v])

    @classmethod
    def load_last_pose(cls, subject, scenario, *car_ids):
        """
        Returns the last pose for the given car in the given scenario for the given subject
        :param subject:
        :param scenario:
        :param car_ids:
        :return:
        """
        car_ids = [str(i) for i in car_ids]
        last_pose = {}
        vehicule_fn = os.path.join(build_scenario_path(subject, scenario), "vehicule.csv")
        for vehicule_line in read_csv_line(vehicule_fn):
            car_id = vehicule_line[1]
            if car_id in car_ids:
                last_pose[car_id] = vehicule_line
                # last_pose = cls(vehicule_line[3:6], vehicule_line[6:9])
        poses = ()
        for car in car_ids:
            try:
                line = last_pose[car]
            except IndexError:
                pose = None
            else:
                pose = cls(line[3:6], line[6:9], line[9:12], line[-3:], line[0])
            finally:
                poses += (pose,)
        return poses

    def dist(self, other):
        """

        :param other:
        :return: Euclidian distance between this car and the other
        """
        return np.linalg.norm(self.pos - other.pos)

    def dist_long(self, other):
        """

        :param other:
        :return: Longitudinal distance between this car and the other
        """
        distance = (other.pos - self.pos)[:2]
        return np.dot(distance, self.orientation())

    def dist_lat(self, other):
        """

        :param other:
        :return: Lateral distance between this car and the other
        """
        distance = (other.pos - self.pos)[:2]
        return np.linalg.norm(distance - self.orientation() * self.dist_long(other))

    def orientation(self):
        """

        :return: The unit orientation vector of the car in 2D
        """
        angle = self.rot[2]
        orientation_raw = np.array([math.cos(angle), math.sin(angle)])
        orientation = orientation_raw / np.linalg.norm(orientation_raw)
        return orientation

    def speed_long(self):
        """

        :return: Longitudinal speed
        """
        return np.dot(self.speed[:2], self.orientation())


class FreezeStaticData:
    """
    The description of a freeze that occurs during a scenario. This isn't subject related, and contains constant
    information about what changes during a freeze
    """

    __CSV_PATH = os.path.join(DIR_DOC, "FreezeChanges.csv")

    def __init__(self, recordable, scenario, car_id, action, mesh):
        self.recordable = recordable
        self.scenario = scenario
        self.car_id = car_id
        self.action = action
        self.mesh = mesh

    @classmethod
    def load_all(cls):
        return load_structured_csv(cls.__CSV_PATH, cls, has_header=True, delim=",")


class FreezeMove:
    """
    Information about the position at which a vehicule was move during a "move" freeze. The information cannot be
    reliably found in vehicule.csv files, so it's stored in a specific file
    """

    __CSV_PATH = os.path.join(DIR_DOC, "FreezeMovePosition.csv")

    def __init__(self, scenario, *pos):
        self.scenario = scenario
        self.vehicule = Vehicule(pos)

    @classmethod
    def load_all(cls):
        return load_structured_csv(cls.__CSV_PATH, cls, has_header=True, delim=",")


class FreezeResult:
    """
    Result of a freeze trial
    """

    def __init__(self, mesh, vehicule):
        self.mesh = mesh
        self.vehicule = vehicule

    @classmethod
    def load(cls, subject, scenario):
        """
        Loads the freeze result for this subject and scenario.

        Raises TooManyUserChanges if the user spotted more than 1 change
        :param subject:
        :param scenario:
        :return:
        """
        freeze_fn = os.path.join(build_scenario_path(subject, scenario), "freeze.csv")
        # No result file => no change spotted
        if not os.path.exists(freeze_fn):
            return None

        spotted_changes = list(read_csv_line(freeze_fn))
        valid_changes = []
        for l in read_csv_line(freeze_fn):
            # Filtering valid changes
            vehicule = Vehicule(l[2:5], l[5:8], timestamp=l[1])
            mesh = l[8]

            # Z out-of-bounds (sign of error)
            z = vehicule.pos[2]
            if not -1 < z < 1:
                log.warning("In {scenario}, {subject} added a vehicule with an OOB Z coordinate ({z:.2f})".format(
                    scenario=scenario,
                    subject=subject,
                    z=z))
                continue

            # Wrong meshes
            if mesh == "No Mesh to this object":# or mesh == "406/406verte":
                continue

            valid_changes.append(cls(mesh, vehicule))

        changes_count = len(valid_changes)
        if changes_count > 1:
            raise TooManyUserChanges("Too many user changes", changes_count)
        if changes_count == 0:
            return None
        return valid_changes[0]


class ParticipantInfo:

    __CSV_PATH = os.path.join(DIR_DOC, "participants_informations_cleaned.csv")

    def __init__(self, id, exp, *l):
        self.id = id
        self.exp = exp
        self.l = l

    @classmethod
    def load_all(cls):
        return load_structured_csv(cls.__CSV_PATH, cls, has_header=True, delim=";")


class TooManyScenarioChanges(Exception):
    pass


class TooManyUserChanges(Exception):

    def __init__(self, message, changes):
        super(TooManyUserChanges, self).__init__(message)

        self.changes = changes

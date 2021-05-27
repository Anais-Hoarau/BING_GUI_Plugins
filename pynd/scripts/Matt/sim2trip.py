import shutil
import os
import csv
import logging as log
from collections import defaultdict
from typing import List

import pynd
from dirs import DIR_DATA_SIMU, DIR_DOC, DIR_TOBII
from utils import read_csv_line, build_scenario_path, load_structured_csv, sort_by, str2time, floatify


class ScenarioName:

    __CSV_PATH = os.path.join(DIR_DOC, "scenario_naming_tobii_simu.csv")

    def __init__(self, tobii_name: str, simu_name: str):
        self.tobii_name = tobii_name
        self.simu_name = simu_name

    @classmethod
    def load_all(cls):
        return load_structured_csv(cls.__CSV_PATH, cls, has_header=True, delim=";")


class EgoData:

    def __init__(self, *l):
        self.timecode = str2time(l[0])
        self.steering = floatify(l[1])
        self.acc = floatify(l[2])
        self.brk = floatify(l[3])

    @classmethod
    def load(cls, subject: str, scenario: str):
        ego_fn = os.path.join(build_scenario_path(subject, scenario), "ego.csv")
        if not os.path.exists(ego_fn):
            return None

        egos = []
        for l in read_csv_line(ego_fn):
            # Filtering valid changes
            egos.append(EgoData(*l))
        return egos


def create_meta_data(trip):
    meta_data_ego: pynd.MetaData = pynd.MetaData()
    meta_data_ego.set_name("simu_ego")
    meta_data_ego.set_comments("Donnees ego du simulateur")
    # meta_data_ego.set_is_base(True)

    meta_data_var_steer = pynd.MetaDataVariable()
    meta_data_var_steer.set_name("steering")

    meta_data_var_pedal_acc = pynd.MetaDataVariable()
    meta_data_var_pedal_acc.set_name("pedal_acc")

    meta_data_var_pedal_brk = pynd.MetaDataVariable()
    meta_data_var_pedal_brk.set_name("pedal_brake")

    meta_data_ego.set_variables([meta_data_var_steer, meta_data_var_pedal_acc, meta_data_var_pedal_brk])

    trip.add_data(meta_data_ego)


def sim_2_trip(trip_file):
    log.debug(f"Adding simu data to {trip_file}")
    scenario_names = sort_by(ScenarioName.load_all(), "tobii_name")

    with pynd.SQLiteTrip(trip_file, 0.04, False) as trip:
        create_meta_data(trip)
        trip_name = os.path.splitext(os.path.basename(trip_file))[0]
        subject, *scenario = trip_name.split("_")
        scenario = "_".join(scenario)

        if len(subject) > 4:
            return

        meta_infos = trip.get_meta_informations()
        try:
            freeze_time_tobii = float(trip.get_attribute("mask_timecode"))
        except pynd.MetaInfosException:
            log.warning(f"Trip {trip_name} does not have tobii timecode data")
            return

        try:
            ego_data: List[EgoData] = EgoData.load(subject, scenario_names[scenario].simu_name)
        except IOError:
            log.warning(f"Subject {subject} does not have data for scenario {scenario}")
            return

        if ego_data is None:
            log.warning(f"No ego data for subject {subject} in scenario {scenario}")
            return

        freeze_time_simu = ego_data[-1].timecode
        ego_data.reverse()

        steer_data = []
        acc_data = []
        brk_data = []
        # We iterate over simu data starting from the back
        for ego in ego_data:
            timecode = freeze_time_tobii - (freeze_time_simu - ego.timecode).total_seconds()
            if timecode < 0:
                break
            steer_data.append((timecode, ego.steering))
            acc_data.append((timecode, ego.acc))
            brk_data.append((timecode, ego.brk))

        trip.set_batch_of_time_data_variable_pairs("simu_ego", "steering", steer_data)
        trip.set_batch_of_time_data_variable_pairs("simu_ego", "pedal_acc", acc_data)
        trip.set_batch_of_time_data_variable_pairs("simu_ego", "pedal_brake", brk_data)


def main():
    log.basicConfig(format='%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.INFO)

    trip_dest = r"D:\Temp\trip_test"
    for root, dirs, files in os.walk(DIR_TOBII):
        for f in files:
            if f.endswith(".trip"):
                src = os.path.join(root, f)
                # dst = os.path.join(trip_dest, f)
                # shutil.copy(src, dst)
                # sim_2_trip(dst)
                sim_2_trip(src)


def check_sensor_data():
    """
    Outputs 3 csv file (1 per sensor) with matrices that cross subject and scenario to check whether the sensor data
    is available in each case.
    :return: 
    """
    results = defaultdict(dict)
    scenarios = set()
    for subject in os.listdir(DIR_DATA_SIMU):
        subject_path = os.path.join(DIR_DATA_SIMU, subject)

        for scenario in os.listdir(subject_path):
            scenario_path = os.path.join(subject_path, scenario)

            scenarios.add(scenario)

            has_brk = False
            has_acc = False
            has_steer = False
            f_path = os.path.join(scenario_path, "ego.csv")
            for l in read_csv_line(f_path):
                if not has_steer and l[1] != "0":
                    has_steer = True
                if not has_acc and l[2] != "0":
                    has_acc = True
                if not has_brk and l[3] != "0":
                    has_brk = True
            results[subject][scenario] = (has_steer, has_acc, has_brk)

    scenarios = list(scenarios)
    with open("res_steer.csv", 'w+') as res_steer:
        with open("res_acc.csv", 'w+') as res_acc:
            with open("res_brk.csv", 'w+') as res_brk:
                res_steer_writer = csv.writer(res_steer, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                              lineterminator='\n')
                res_acc_writer = csv.writer(res_acc, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                            lineterminator='\n')
                res_brk_writer = csv.writer(res_brk, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                            lineterminator='\n')

                res_steer_writer.writerow(['subject'] + scenarios)
                res_acc_writer.writerow(['subject'] + scenarios)
                res_brk_writer.writerow(['subject'] + scenarios)

                for subject, subject_scenarios in results.items():
                    l_steer = [subject]
                    l_acc = [subject]
                    l_back = [subject]
                    for scenario in scenarios:
                        if scenario in subject_scenarios:
                            l_steer.append(subject_scenarios[scenario][0])
                            l_acc.append(subject_scenarios[scenario][1])
                            l_back.append(subject_scenarios[scenario][2])
                        else:
                            l_steer.append("N/A")
                            l_acc.append("N/A")
                            l_back.append("N/A")

                    res_steer_writer.writerow(l_steer)
                    res_acc_writer.writerow(l_acc)
                    res_brk_writer.writerow(l_back)


if __name__ == "__main__":
    main()

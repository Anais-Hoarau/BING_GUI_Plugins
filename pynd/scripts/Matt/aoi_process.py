import os
import csv
import logging as log
from enum import Enum

import xlrd

from dirs import DIR_TOBII, DIR_DOC, DIR_PROCESSED
from utils import ParticipantInfo, sort_by, load_structured_csv
from merge_sub_subjects import SubjectAggregate


class AOIType(Enum):
    AOI_Rearview = 1
    AOI_Sideview = 2
    AOI_LeadCar = 3
    AOI_Speedo = 4
    AOI_Insert_R = 11
    AOI_Intruder_L = 12
    AOI_Panne = 13
    AOI_BAU_Obstacle = 14


class Scenario:
    def __init__(self, name):
        self.name = name
        self.subjects = {}

    def add_subject(self, subject):
        self.subjects[subject.id] = subject


class Subject:
    def __init__(self, id):
        self.id = id
        self.aois = {}

    def add_aoi(self, aoi):
        self.aois[aoi.name] = aoi


class AOI:
    def __init__(self, name):
        self.name = name
        self.visits = []

    def add_visit(self, visit):
        self.visits.append(visit)


class AOIVisit:
    def __init__(self, name, start, end, duration):
        self.name = AOIType[name]
        self.start = start
        self.end = end or 0
        self.duration = abs(self.start - self.end)


def load_aois():
    # Getting a map that allows us to easily remap a subject ID to its actual main ID
    subject_main_ids = {}
    for subject in load_structured_csv(os.path.join(DIR_DOC, "Subject_number_clarification.csv"), SubjectAggregate,
                                       has_header=True,
                                       delim=","):
        subject_main_ids[subject.id] = subject.id
        for add_id in subject.add_ids:
            subject_main_ids[add_id] = subject.id

    scenarios = {}
    dir_aoi = os.path.join(DIR_TOBII, "Bind_outputs", "graphs_with_legend")
    for f in os.listdir(dir_aoi):
        if not f.endswith('.xls'):
            continue
        if f.startswith("Stop"):
            continue

        *tmp, subject_id, _ = f.split(".")[0].split("_")
        scenario_name = "_".join(tmp)

        if subject_id not in subject_main_ids:
            continue

        subject = Subject(subject_main_ids[subject_id])
        wb = xlrd.open_workbook(os.path.join(dir_aoi, f), True)
        sh = wb.sheet_by_index(0)
        for rx in range(1, sh.nrows):
            r = sh.row(rx)
            if len(r) != 4:
                log.warning(f"No data for {subject_id} in {scenario_name}")
                continue
            visit = AOIVisit(*[v.value for v in r])
            subject.aois.setdefault(visit.name, AOI(visit.name)).add_visit(visit)
        scenarios.setdefault(scenario_name, Scenario(scenario_name)).add_subject(subject)
    return scenarios


def write_result(subjects_info, scenario_data, scenario_name, aoi_names):
    scenario = scenario_data[scenario_name]
    res_fn = os.path.join(DIR_PROCESSED, "AOI", f"{scenario_name}.csv")
    header = ["subject", "experience", "aoi_name", "aoi_sights_count", "aoi_total_time", "aoi_avg_time"]
    with open(res_fn, 'w+') as acc_f:
        acc_res_writer = csv.writer(acc_f, delimiter=';', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                        lineterminator='\n')
        acc_res_writer.writerow(header)
        for _, subject in scenario.subjects.items():
            for aoi_name in aoi_names:
            # for _, aoi in subject.aois.items():
                if aoi_name in subject.aois:
                    aoi = subject.aois[aoi_name]
                    count = len(aoi.visits)
                    duration = sum([a.duration for a in aoi.visits])
                    avg_duration = duration / count
                else:
                    count = 0
                    duration = 0
                    avg_duration = 0
                # If we have AOI data for a subject but don't have participant info, it means the subject has been
                # trashed
                if subject.id not in subjects_info:
                    continue
                line = [subject.id,
                        subjects_info[subject.id].exp,
                        aoi_name.name,
                        count,
                        duration,
                        avg_duration]
                assert(len(line) == len(header))
                acc_res_writer.writerow(line)


def main():
    log.basicConfig(format='%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.DEBUG)
    subjects_info = sort_by(ParticipantInfo.load_all(), 'id')
    scenario_data = load_aois()

    default_aois = [AOIType.AOI_Rearview, AOIType.AOI_Sideview, AOIType.AOI_LeadCar, AOIType.AOI_Speedo]
    for scenario in scenario_data.keys():
        if "BAU" in scenario:
            extra_aoi = [AOIType.AOI_BAU_Obstacle]
        elif "Panne" in scenario:
            extra_aoi = [AOIType.AOI_Panne]
        elif "Intruder" in scenario:
            extra_aoi = [AOIType.AOI_Intruder_L]
        elif "Insert" in scenario:
            extra_aoi = [AOIType.AOI_Insert_R]
        write_result(subjects_info, scenario_data, scenario, default_aois + extra_aoi)

if __name__ == '__main__':
    main()
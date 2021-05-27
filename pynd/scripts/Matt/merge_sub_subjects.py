"""
Merges all sub subjects generated by the simulator into a single subject. This is used when there was a crash and a
single subject had multiple ID attributed by the simulator.
"""
import os
import logging as log
import shutil
from time import sleep

from utils import load_structured_csv, build_scenario_path, clean_scenario_name
from dirs import DIR_DOC, DIR_DATA_SIMU, DIR_DATA_SPLIT
from split_raw_simu_data import DUPLICATE_SCENARIO_SEPARATOR

SUBJECT_FOLDER_PREFIX = "Sujet_"


class SubjectAggregate:
    def __init__(self, date, id, *add_ids):
        self.date = date
        self.id = id
        self.add_ids = list(filter(None, add_ids))


def subject_folder_name(id):
    return SUBJECT_FOLDER_PREFIX + id


def copy_valid_scenarios(src_id, dst_id=None):
    """
    Copies valid scenarios from the source ID to the destination ID
    :param src_id:
    :param dst_id:
    :return:
    """
    dst_id = dst_id or src_id
    log.debug("Moving {src_id} to {dst_id}".format(src_id=src_id, dst_id=dst_id))

    subject_dir_src = os.path.join(DIR_DATA_SPLIT, subject_folder_name(src_id))
    subject_dir_dst = os.path.join(DIR_DATA_SIMU, dst_id)

    if not os.path.exists(subject_dir_src):
        log.error("No data for subject {src_id} (destination id: {dst_id})".format(src_id=src_id, dst_id=dst_id))
        return

    for scenario in os.listdir(subject_dir_src):
        # Ignoring retries, we get them using build_scenario_path()
        if DUPLICATE_SCENARIO_SEPARATOR in scenario:
            continue

        scenario_dir_src = build_scenario_path(subject_folder_name(src_id), scenario, src_dir=DIR_DATA_SPLIT)

        # If src dir doesn't have an ego.csv file, it's probably a crashed scenario
        if not os.path.exists(os.path.join(scenario_dir_src, "ego.csv")):
            log.warning(f"Subject {dst_id} doesn't have ego data for {scenario}, skipping")
            continue

        # Removing useless prefixes
        scenario = clean_scenario_name(scenario)

        scenario_dir_dst = os.path.join(subject_dir_dst, scenario)

        if os.path.exists(scenario_dir_dst):
            log.warning("Subject {subject} already has data for {scenario}, but its additional ID ({add}) also "
                        "has data".format(subject=dst_id, scenario=scenario, add=src_id))
            shutil.rmtree(scenario_dir_dst)
        # os.makedirs(scenario_dir_dst)
        shutil.copytree(scenario_dir_src, scenario_dir_dst)


def main():
    log.basicConfig(format='%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.DEBUG)
    try:
        os.makedirs(DIR_DATA_SIMU)
    except OSError:
        pass
    # Deleting previously generated files
    for d in os.listdir(DIR_DATA_SIMU):
        shutil.rmtree(os.path.join(DIR_DATA_SIMU, d), ignore_errors=True)
    for subject in load_structured_csv(os.path.join(DIR_DOC, "Subject_number_clarification.csv"), SubjectAggregate,
                                       has_header=True,
                                       delim=","):
        if "abandoned" in subject.id:
            continue

        #  Copying valid scenarios for the main ID...
        copy_valid_scenarios(subject.id)

        #  ... and for all the sub IDs
        for add_id in subject.add_ids:
            copy_valid_scenarios(add_id, subject.id)


if __name__ == "__main__":
    main()

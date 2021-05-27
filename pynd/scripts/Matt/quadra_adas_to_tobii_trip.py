"""
This script adds all quadravision videos for ADAS scenarios to the existing Tobii trips, therefore resynchronizing them
"""
import os
import logging as log
import tempfile
import shutil
from typing import List, Tuple, Dict
from collections import defaultdict

import cv2
import pynd

from utils import load_structured_csv, build_scenario_path, clean_scenario_name
from merge_sub_subjects import SubjectAggregate
from dirs import DIR_DOC, DIR_DATA_VIDEO_QUADRA, DIR_TOBII
from split_raw_simu_data import DUPLICATE_SCENARIO_SEPARATOR
from sim2trip import ScenarioName
from resync_all import VideoSplitter
from mutiprocessing_log import LoggingPool


def get_valid_scenarios(subject: str) -> Dict[str, str]:
    videos: Dict[str, str] = {}
    subject_dir = os.path.join(DIR_DATA_VIDEO_QUADRA, subject)

    if not os.path.exists(subject_dir):
        log.error(f"No videos for subject {subject}")
        return videos

    for scenario in os.listdir(subject_dir):
        # Ignoring retries, we get them using build_scenario_path()
        if DUPLICATE_SCENARIO_SEPARATOR in scenario:
            continue

        scenario_dir = build_scenario_path(subject, scenario, src_dir=DIR_DATA_VIDEO_QUADRA)

        videos_files = [os.path.join(scenario_dir, f) for f in os.listdir(scenario_dir) if f.endswith('.avi')]
        video_count = len(videos_files)
        if video_count == 0:
            log.warning(f"Subject {subject} doesn't have video for {scenario}, skipping")
            continue
        elif video_count > 1:
            log.warning(f"Subject {subject} has {video_count} videos for {scenario}, skipping")
            continue

        videos[clean_scenario_name(scenario)] = videos_files[0]
    return videos


def get_videos() -> Dict[str, Dict[str, str]]:
    videos = {}
    for subject in load_structured_csv(os.path.join(DIR_DOC, "Subject_number_clarification.csv"), SubjectAggregate,
                                       has_header=True,
                                       delim=","):
        if "abandoned" in subject.id:
            continue

        #  Copying valid scenarios for the main ID...
        subject_videos = get_valid_scenarios(subject.id)

        #  ... and for all the sub IDs
        for add_id in subject.add_ids:
            subject_videos = {**subject_videos, **get_valid_scenarios(add_id)}

        videos[subject.id] = subject_videos
    return videos


def find_freeze_offset(video: str) -> float:
    cap = cv2.VideoCapture(video)
    frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    while cap.isOpened():
        ret, frame = cap.read()
        if frame is None:
            break

        if VideoSplitter.is_screen_frozen(frame):
            frame = int(cap.get(cv2.CAP_PROP_POS_FRAMES))
            # There can be a frozen screen at the beginning or end of the scenario, so we exclude those
            if 100 < frame < frames - 100:
                return cap.get(cv2.CAP_PROP_POS_MSEC) / 1000.
    return None


def add_video_to_trip(trip_file: str, video_file: str) -> None:
    log.info(f"Processing {trip_file}")
    offset = find_freeze_offset(video_file)
    if offset is None:
        log.error(f"Failed to find freeze time in {video_file}")
        return
    log.debug(f"Freeze found at {offset}s in {video_file}")

    with pynd.SQLiteTrip(trip_file, 0.04, False) as trip:
        try:
            freeze_time_tobii = float(trip.get_attribute("mask_timecode"))
        except pynd.MetaInfosException:
            log.warning(f"Trip {trip_file} does not have tobii timecode data")
            return
        rel_offset = offset - freeze_time_tobii
        rel_path = os.path.relpath(video_file, os.path.dirname(trip_file))
        meta_video = pynd.MetaVideoFile(rel_path, rel_offset, "Quadravision")
        trip.add_video_file(meta_video)


def main():
    with LoggingPool('%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.WARNING, filename='quadra_to_trip.log') as _:
        log.info("Finding all valid videos for all subjects")
        videos = get_videos()
        scenario_names = {}
        for scenario in ScenarioName.load_all():
            s = scenario.tobii_name.lower()
            if "adas" in s or "stop&go" in s:
                scenario_names[scenario.tobii_name] = scenario.simu_name

        log.info("Processing all valid videos")
        with LoggingPool().make_pool() as pool:
            for subject in os.listdir(DIR_TOBII):
                try:
                    # Checking that it is indeed a subject folder
                    int(subject)
                except ValueError:
                    continue

                subject_dir = os.path.join(DIR_TOBII, subject)
                for scenario in os.listdir(subject_dir):
                    scenario_dir = os.path.join(subject_dir, scenario)
                    # There are some random files in subject folders, we need to ignore them
                    if not os.path.isdir(scenario_dir):
                        continue
                    if scenario not in scenario_names.keys():
                        continue

                    try:
                        subject_video = videos[subject][scenario_names[scenario]]
                    except KeyError:
                        log.error(f"Failed to get video for subject {subject} in {scenario}")
                        continue
                    log.debug(f"For subject {subject} in {scenario}, processing video {subject_video}")

                    trip_src = os.path.join(scenario_dir, f"{subject}_{scenario}.trip")
                    pool.apply_async(add_video_to_trip, (trip_src, subject_video))
            pool.close()
            pool.join()
        log.info("Finished")

if __name__ == "__main__":
    main()
import os
import csv
import logging as log
from datetime import datetime as dt

import pynd
from pynd import MetaVariableBaseType as T
from rec2trip.ttm import DataTableManipulator
from scripts.Matt.mutiprocessing_log import LoggingPool

DIR_EXPE = r"\\vrlescot\EQUIPE_SIGMA\These_Jonathan\Experiment_data"


def import_pupil(trip_dir: str, trip_file: str) -> None:
    trip_file_path = os.path.join(trip_dir, trip_file)
    with pynd.SQLiteTrip (trip_file_path, 0.04, False) as trip:
        meta_inf = trip.get_meta_informations()
        for d in meta_inf.get_datas_list():
            if d.get_name().startswith("pupil_surface"):
                log.debug(f"Pupil data already imported for {trip_dir}")
                return
    pupil_dir = os.path.join(trip_dir, "000", "exports", "surfaces")
    if not os.path.isdir(pupil_dir):
        log.warning(f"No Pupil exported data for {trip_dir}")
        return
    log.info(f"Adding Pupil data to {trip_dir}")

    for pupil_file in os.listdir(pupil_dir):
        pupil_file_path = os.path.join(pupil_dir, pupil_file)
        if pupil_file.startswith("srf_positons"):
            retro = pupil_file.split("_")[3]
            timestamps, targets = [], []
            with open(pupil_file_path, "r") as fh:
                for l in fh:
                    if l[0].isdigit():
                        timestamps.append(float(l.split(',')[1]))
                    target = l.strip()[-1]
                    if target.isdigit():
                        targets.append(target)
            with pynd.SQLiteTrip(trip_file_path, 0.04, False) as trip:
                ttm = DataTableManipulator(trip)
                ttm.create_table(f"pupil_surface_targets_retro_{retro}")
                meta_var = ttm.create_meta_variable("targets", T.REAL, "",
                                                    "Number of visible targets for the surface")
                ttm.add_variable(meta_var)
                ttm.set_batch_of_variable_pairs("targets", timestamps, targets)
        if pupil_file.startswith("gaze_positions"):
            retro = pupil_file.split("_")[5]
            with open(pupil_file_path, "r") as fh:
                pupil_reader = csv.reader(fh, delimiter=',')
                next(pupil_reader)
                lines = [line for line in pupil_reader]
                with pynd.SQLiteTrip(trip_file_path, 0.04, False) as trip:
                    ttm = DataTableManipulator(trip)
                    ttm.create_table(f"pupil_surface_retro_{retro}")
                    meta_vars = [
                        ttm.create_meta_variable("x", T.REAL, "[0..1]", "Gaze X position on the surface"),
                        ttm.create_meta_variable("y", T.REAL, "[0..1]", "Gaze Y position on the surface"),
                        ttm.create_meta_variable("on_srf", T.REAL, "bool",
                                                 "Whether gaze is on surface or not"),
                        ttm.create_meta_variable("confidence", T.REAL, "[0..1]",
                                                 "Confidence for the gaze value, not including surface "
                                                 "positioning"),
                    ]
                    for meta_var in meta_vars:
                        ttm.add_variable(meta_var)

                    _, _, timestamp, x, y, _, _, on_srf, confidence = zip(*lines)
                    timestamp = list(map(float, timestamp))
                    x = list(map(float, x))
                    y = list(map(float, y))
                    confidence = list(map(float, confidence))
                    on_srf = [0 if x == 'False' else 1 for x in on_srf]
                    ttm.set_batch_of_variable_pairs("x", timestamp, x)
                    ttm.set_batch_of_variable_pairs("y", timestamp, y)
                    ttm.set_batch_of_variable_pairs("on_srf", timestamp, on_srf)
                    ttm.set_batch_of_variable_pairs("confidence", timestamp, confidence)


def main():
    with LoggingPool('%(asctime)-15s (PID %(process)-5d) [%(levelname)-8s]: %(message)s', level=log.INFO,
                     filename='pupil.log') as _:
        start_time = dt.now()
        count = 0
        with LoggingPool().make_pool() as pool:
            for root, dirs, files in os.walk(DIR_EXPE):
                for f in files:
                    if f.endswith(".trip"):
                        count += 1
                        pool.apply_async(import_pupil, (root, f))
            pool.close()
            pool.join()
            log.info(f"Imported {count} Pupil data in {dt.now() - start_time}")


if __name__ == '__main__':
    main()
